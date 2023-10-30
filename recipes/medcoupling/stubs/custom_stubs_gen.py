import argparse
import ast
import importlib
import logging
import pathlib
import pkgutil
from typing import Union

import astor

import pybind11_stubgen
from pybind11_stubgen.structs import Function, Identifier, Method, Property, Docstring, Decorator, Class, Argument, \
    Value

logger = logging.getLogger(__name__)

_modifier_map = {
    "classmethod": "class",
    "staticmethod": "static",
}


def iter_py_files(module_name):
    module = importlib.import_module(module_name)
    # If it's a package, recursively explore
    if not hasattr(module, "__path__"):
        raise RuntimeError(f"{module_name} is not a package")

    for _fp, sub_module, is_pkg in pkgutil.walk_packages(module.__path__):
        yield from pathlib.Path(_fp.path).rglob('*.py')


def parse_method(class_node: ast.FunctionDef) -> Union[Method, Property, None]:
    if class_node.name.startswith("__") or class_node.name.startswith("_"):
        return None  # Skip dunder methods and private methods

    # Parse docstring
    docstring_node = ast.get_docstring(class_node)
    docstring = Docstring(docstring_node) if docstring_node else None

    # Parse decorators
    modifier = None
    decorators: list[Decorator] = []
    for deco in class_node.decorator_list:
        if isinstance(deco, ast.Name):
            if deco.id in ('classmethod', 'staticmethod'):
                modifier = _modifier_map.get(deco.id, None)
                if modifier is None:
                    raise NotImplementedError(f"Unknown modifier {deco.id}")
                continue
            decorators.append(Decorator(deco.id))

    # Identify the decorator (beyond class and static methods)
    if len(decorators) == 0:
        is_property = False
    else:
        if any(deco == 'deprecated' for deco in decorators):
            return None

        is_property = any(deco == 'property' for deco in decorators)
        if len(decorators) > 1:
            raise NotImplementedError("Multiple decorators not supported yet")

        modifier = _modifier_map.get(decorators[0], None)

    # Parse arguments
    args: list[Argument] = []
    defaults_start = len(class_node.args.args) - len(class_node.args.defaults)
    for i, arg in enumerate(class_node.args.args):
        arg_name = Identifier(arg.arg)

        # Check if there's a default value
        default = None
        if i >= defaults_start:
            default_node = class_node.args.defaults[i - defaults_start]
            if isinstance(default_node, ast.Constant):
                default_source = repr(default_node.value)
            else:
                default_source = astor.to_source(default_node).strip()

            default = Value(repr=default_source, is_print_safe=True)

        args.append(Argument(name=arg_name, default=default))

    if class_node.args.kwarg is not None:
        arg_name = Identifier(class_node.args.kwarg.arg)
        args.append(Argument(name=arg_name, kw_variadic=True))

    if is_property:
        # Create and return a Property object
        return Property(
            name=Identifier(class_node.name),
            modifier=modifier,  # You might need to fix this based on your actual logic
            doc=docstring,
            getter=Function(name=Identifier(class_node.name), args=args, doc=docstring, decorators=decorators)
        )
    else:
        # interpret modifier
        # Create and return a Function object
        func = Function(
            name=Identifier(class_node.name),
            args=args,
            doc=docstring,
            decorators=decorators
        )
        return Method(function=func, modifier=modifier)


def extract_injected_methods(py_file: pathlib.Path) -> dict[str, Class]:
    text = py_file.read_text()

    classes: dict[str, Class] = dict()
    p = ast.parse(text)
    for node in ast.walk(p):
        if not isinstance(node, ast.ClassDef):
            continue
        # Get the class passed into the @injector decorator attached to class
        if not node.decorator_list:
            continue

        cls_decorator = node.decorator_list[0]
        if not isinstance(cls_decorator, ast.Call):
            continue
        if not isinstance(cls_decorator.func, ast.Name):
            continue
        if cls_decorator.func.id != "injector":
            continue
        if not cls_decorator.args:
            continue
        if not isinstance(cls_decorator.args[0], ast.Name):
            continue

        injector_class_target = cls_decorator.args[0].id

        clas = Class(name=Identifier(node.name))

        # walk the class body and fill in the class struct
        for class_node in node.body:
            if isinstance(class_node, ast.FunctionDef):
                method_obj = parse_method(class_node)
                if method_obj is None:
                    continue
                if isinstance(method_obj, Method):
                    clas.methods.append(method_obj)
                elif isinstance(method_obj, Property):
                    clas.properties.append(method_obj)
                else:
                    raise NotImplementedError(f"Unknown method type {method_obj}")

            elif isinstance(class_node, ast.Assign):
                # We don't care about assignments
                pass
            else:
                # logger.info(f"skipping class node {class_node}")
                pass

        # We are only interested in classes that have methods and properties
        if len(clas.methods) == 0 and len(clas.properties) == 0:
            continue

        classes[injector_class_target] = clas

    return classes


def get_injected_classes(module_name) -> dict[str, Class]:
    stub_entries = dict()
    for py_file in iter_py_files(module_name):
        if '@injector' not in py_file.read_text():
            continue
        classes = extract_injected_methods(py_file)
        stub_entries.update(classes)

    return stub_entries


def run(
        parser: pybind11_stubgen.IParser,
        printer: pybind11_stubgen.Printer,
        module_name: str,
        out_dir: pathlib.Path,
        sub_dir: Union[pathlib.Path, None],
        dry_run: bool,
):
    injected_classes = get_injected_classes("code_aster")

    module = parser.handle_module(
        pybind11_stubgen.QualifiedName.from_str(module_name),
        importlib.import_module(module_name),
    )

    for clas in module.classes:
        # Fix None property (seems to be for enums only)
        for field in clas.fields:
            if field.attribute.name == 'None':
                field.attribute.name = '_None'

        if clas.name not in injected_classes:
            continue

        cls_meth_map = {method.function.name: method for method in clas.methods}
        cls_prop_map = {prop.name: prop for prop in clas.properties}

        for method in injected_classes[clas.name].methods:
            if method.function.name in cls_meth_map:
                continue
            clas.methods.append(method)

        for prop in injected_classes[clas.name].properties:
            if prop.name in cls_prop_map:
                continue
            clas.properties.append(prop)



    parser.finalize()

    if module is None:
        raise RuntimeError(f"Can't parse {module_name}")

    if dry_run:
        return

    writer = pybind11_stubgen.Writer()

    out_dir.mkdir(exist_ok=True)
    writer.write_module(module, printer, to=out_dir, sub_dir=sub_dir)


def main(module_name):

    pyi_dest_dir = pathlib.Path(__import__(module_name).__file__).parent
    # pyi_dest_dir = ".stubs"

    args = argparse.Namespace(
        module_name=module_name,
        ignore_all_errors=None,
        ignore_invalid_identifiers=None,
        ignore_invalid_expressions=None,
        ignore_unresolved_names=None,
        enum_class_locations=None,
        print_invalid_expressions_as_is=False,
        print_safe_value_reprs=None,
        output_dir=pyi_dest_dir,
        root_suffix=None,
        # set_ignored_invalid_identifiers=None,
        # set_ignored_invalid_expressions=None,
        # set_ignored_unresolved_names=None,
        exit_code=False,
        numpy_array_wrap_with_annotated_fixed_size=True,
        numpy_array_remove_parameters=True,
        numpy_array_wrap_with_annotated=True,
        dry_run=False,
    )
    # shutil.copytree('stubs', dummy_lib, dirs_exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(name)s - [%(levelname)7s] %(message)s",
    )

    parser = pybind11_stubgen.stub_parser_from_args(args)
    printer = pybind11_stubgen.Printer(
        invalid_expr_as_ellipses=not args.print_invalid_expressions_as_is
    )

    out_dir = pathlib.Path(args.output_dir)
    out_dir.mkdir(exist_ok=True)

    if args.root_suffix is None:
        sub_dir = None
    else:
        sub_dir = pathlib.Path(f"{args.module_name}{args.root_suffix}")
    try:
        run(
            parser,
            printer,
            args.module_name,
            out_dir,
            sub_dir=sub_dir,
            dry_run=args.dry_run,
        )
    except BaseException as e:
        logger.error(f'generator error -> {e}')


if __name__ == "__main__":
    main(module_name="medcoupling")
