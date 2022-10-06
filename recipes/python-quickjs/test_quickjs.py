"""Tests from QuickJS Python wrapper.

This is a copy because the tests are not shipped with the source package.

Origin: https://raw.githubusercontent.com/PetterS/quickjs/master/test_quickjs.py
"""
import concurrent.futures
import gc
import json
import unittest

import quickjs


class LoadModule(unittest.TestCase):
    def test_42(self):
        self.assertEqual(quickjs.test(), 42)


class Context(unittest.TestCase):
    def setUp(self):
        self.context = quickjs.Context()

    def test_eval_int(self):
        self.assertEqual(self.context.eval("40 + 2"), 42)

    def test_eval_float(self):
        self.assertEqual(self.context.eval("40.0 + 2.0"), 42.0)

    def test_eval_str(self):
        self.assertEqual(self.context.eval("'4' + '2'"), "42")

    def test_eval_bool(self):
        self.assertEqual(self.context.eval("true || false"), True)
        self.assertEqual(self.context.eval("true && false"), False)

    def test_eval_null(self):
        self.assertIsNone(self.context.eval("null"))

    def test_eval_undefined(self):
        self.assertIsNone(self.context.eval("undefined"))

    def test_wrong_type(self):
        with self.assertRaises(TypeError):
            self.assertEqual(self.context.eval(1), 42)

    def test_context_between_calls(self):
        self.context.eval("x = 40; y = 2;")
        self.assertEqual(self.context.eval("x + y"), 42)

    def test_function(self):
        self.context.eval("""
            function special(x) {
                return 40 + x;
            }
            """)
        self.assertEqual(self.context.eval("special(2)"), 42)

    def test_get(self):
        self.context.eval("x = 42; y = 'foo';")
        self.assertEqual(self.context.get("x"), 42)
        self.assertEqual(self.context.get("y"), "foo")
        self.assertEqual(self.context.get("z"), None)

    def test_set(self):
        self.context.eval("x = 'overriden'")
        self.context.set("x", 42)
        self.context.set("y", "foo")
        self.assertTrue(self.context.eval("x == 42"))
        self.assertTrue(self.context.eval("y == 'foo'"))

    def test_module(self):
        self.context.module("""
            export function test() {
                return 42;
            }
        """)

    def test_error(self):
        with self.assertRaisesRegex(quickjs.JSException, "ReferenceError: 'missing' is not defined"):
            self.context.eval("missing + missing")

    def test_lifetime(self):
        def get_f():
            context = quickjs.Context()
            f = context.eval("""
            a = function(x) {
                return 40 + x;
            }
            """)
            return f

        f = get_f()
        self.assertTrue(f)
        # The context has left the scope after f. f needs to keep the context alive for the
        # its lifetime. Otherwise, we will get problems.

    def test_backtrace(self):
        try:
            self.context.eval("""
                function funcA(x) {
                    x.a.b = 1;
                }
                function funcB(x) {
                    funcA(x);
                }
                funcB({});
            """)
        except Exception as e:
            msg = str(e)
        else:
            self.fail("Expected exception.")

        self.assertIn("at funcA (<input>:3)\n", msg)
        self.assertIn("at funcB (<input>:6)\n", msg)

    def test_memory_limit(self):
        code = """
            (function() {
                let arr = [];
                for (let i = 0; i < 1000; ++i) {
                    arr.push(i);
                }
            })();
        """
        self.context.eval(code)
        self.context.set_memory_limit(1000)
        with self.assertRaisesRegex(quickjs.JSException, "null"):
            self.context.eval(code)
        self.context.set_memory_limit(1000000)
        self.context.eval(code)

    def test_time_limit(self):
        code = """
            (function() {
                let arr = [];
                for (let i = 0; i < 100000; ++i) {
                    arr.push(i);
                }
                return arr;
            })();
        """
        self.context.eval(code)
        self.context.set_time_limit(0)
        with self.assertRaisesRegex(quickjs.JSException, "InternalError: interrupted"):
            self.context.eval(code)
        self.context.set_time_limit(-1)
        self.context.eval(code)

    def test_memory_usage(self):
        self.assertIn("memory_used_size", self.context.memory().keys())

    def test_json_simple(self):
        self.assertEqual(self.context.parse_json("42"), 42)

    def test_json_error(self):
        with self.assertRaisesRegex(quickjs.JSException, "unexpected token"):
            self.context.parse_json("a b c")

    def test_execute_pending_job(self):
        self.context.eval("obj = {}")
        self.assertEqual(self.context.execute_pending_job(), False)
        self.context.eval("Promise.resolve().then(() => {obj.x = 1;})")
        self.assertEqual(self.context.execute_pending_job(), True)
        self.assertEqual(self.context.eval("obj.x"), 1)
        self.assertEqual(self.context.execute_pending_job(), False)

    def test_global(self):
        self.context.set("f", self.context.globalThis)
        self.assertTrue(isinstance(self.context.globalThis, quickjs.Object))
        self.assertTrue(self.context.eval("f === globalThis"))
        with self.assertRaises(AttributeError):
            self.context.globalThis = 1


class CallIntoPython(unittest.TestCase):
    def setUp(self):
        self.context = quickjs.Context()

    def test_make_function(self):
        self.context.add_callable("f", lambda x: x + 2)
        self.assertEqual(self.context.eval("f(40)"), 42)
        self.assertEqual(self.context.eval("f.name"), "f")

    def test_make_two_functions(self):
        for i in range(10):
            self.context.add_callable("f", lambda x: i + x + 2)
            self.context.add_callable("g", lambda x: i + x + 40)
            f = self.context.get("f")
            g = self.context.get("g")
            self.assertEqual(f(40) - i, 42)
            self.assertEqual(g(2) - i, 42)
            self.assertEqual(self.context.eval("((f, a) => f(a))")(f, 40) - i, 42)

    def test_make_function_call_from_js(self):
        self.context.add_callable("f", lambda x: x + 2)
        g = self.context.eval("""(
            function() {
                return f(20) + 20;
            }
        )""")
        self.assertEqual(g(), 42)

    def test_python_function_raises(self):
        def error(a):
            raise ValueError("A")

        self.context.add_callable("error", error)
        with self.assertRaisesRegex(quickjs.JSException, "Python call failed"):
            self.context.eval("error(0)")

    def test_python_function_not_callable(self):
        with self.assertRaisesRegex(TypeError, "Argument must be callable."):
            self.context.add_callable("not_callable", 1)

    def test_python_function_no_slots(self):
        for i in range(2**16):
            self.context.add_callable(f"a{i}", lambda i=i: i + 1)
        self.assertEqual(self.context.eval("a0()"), 1)
        self.assertEqual(self.context.eval(f"a{2**16 - 1}()"), 2**16)

    def test_function_after_context_del(self):
        def make():
            ctx = quickjs.Context()
            ctx.add_callable("f", lambda: 1)
            f = ctx.get("f")
            del ctx
            return f
        gc.collect()
        f = make()
        self.assertEqual(f(), 1)

    def test_python_function_unwritable(self):
        self.context.eval("""
            Object.defineProperty(globalThis, "obj", {
                value: "test",
                writable: false,
            });
        """)
        with self.assertRaisesRegex(TypeError, "Failed adding the callable."):
            self.context.add_callable("obj", lambda: None)

    def test_python_function_is_function(self):
        self.context.add_callable("f", lambda: None)
        self.assertTrue(self.context.eval("f instanceof Function"))
        self.assertTrue(self.context.eval("typeof f === 'function'"))

    def test_make_function_two_args(self):
        def concat(a, b):
            return a + b

        self.context.add_callable("concat", concat)
        result = self.context.eval("concat(40, 2)")
        self.assertEqual(result, 42)

        concat = self.context.get("concat")
        result = self.context.eval("((f, a, b) => 22 + f(a, b))")(concat, 10, 10)
        self.assertEqual(result, 42)

    def test_make_function_two_string_args(self):
        """Without the JS_DupValue in js_c_function, this test crashes."""
        def concat(a, b):
            return a + "-" + b

        self.context.add_callable("concat", concat)
        concat = self.context.get("concat")
        result = concat("aaa", "bbb")
        self.assertEqual(result, "aaa-bbb")

    def test_can_eval_in_same_context(self):
        self.context.add_callable("f", lambda: 40 + self.context.eval("1 + 1"))
        self.assertEqual(self.context.eval("f()"), 42)

    def test_can_call_in_same_context(self):
        inner = self.context.eval("(function() { return 42; })")
        self.context.add_callable("f", lambda: inner())
        self.assertEqual(self.context.eval("f()"), 42)

    def test_delete_function_from_inside_js(self):
        self.context.add_callable("f", lambda: None)
        # Segfaults if js_python_function_finalizer does not handle threading
        # states carefully.
        self.context.eval("delete f")
        self.assertIsNone(self.context.get("f"))

    def test_invalid_argument(self):
        self.context.add_callable("p", lambda: 42)
        self.assertEqual(self.context.eval("p()"), 42)
        with self.assertRaisesRegex(quickjs.JSException, "Python call failed"):
            self.context.eval("p(1)")
        with self.assertRaisesRegex(quickjs.JSException, "Python call failed"):
            self.context.eval("p({})")

    def test_time_limit_disallowed(self):
        self.context.add_callable("f", lambda x: x + 2)
        self.context.set_time_limit(1000)
        with self.assertRaises(quickjs.JSException):
            self.context.eval("f(40)")

    def test_conversion_failure_does_not_raise_system_error(self):
        # https://github.com/PetterS/quickjs/issues/38

        def test_list():
            return [1, 2, 3]

        self.context.add_callable("test_list", test_list)
        with self.assertRaises(quickjs.JSException):
            # With incorrect error handling, this (safely) made Python raise a SystemError
            # instead of a JS exception.
            self.context.eval("test_list()")


class Object(unittest.TestCase):
    def setUp(self):
        self.context = quickjs.Context()

    def test_function_is_object(self):
        f = self.context.eval("""
            a = function(x) {
                return 40 + x;
            }
            """)
        self.assertIsInstance(f, quickjs.Object)

    def test_function_call_int(self):
        f = self.context.eval("""
            f = function(x) {
                return 40 + x;
            }
            """)
        self.assertEqual(f(2), 42)

    def test_function_call_int_two_args(self):
        f = self.context.eval("""
            f = function(x, y) {
                return 40 + x + y;
            }
            """)
        self.assertEqual(f(3, -1), 42)

    def test_function_call_many_times(self):
        n = 1000
        f = self.context.eval("""
            f = function(x, y) {
                return x + y;
            }
            """)
        s = 0
        for i in range(n):
            s += f(1, 1)
        self.assertEqual(s, 2 * n)

    def test_function_call_str(self):
        f = self.context.eval("""
            f = function(a) {
                return a + " hej";
            }
            """)
        self.assertEqual(f("1"), "1 hej")

    def test_function_call_str_three_args(self):
        f = self.context.eval("""
            f = function(a, b, c) {
                return a + " hej " + b + " ho " + c;
            }
            """)
        self.assertEqual(f("1", "2", "3"), "1 hej 2 ho 3")

    def test_function_call_object(self):
        d = self.context.eval("d = {data: 42};")
        f = self.context.eval("""
            f = function(d) {
                return d.data;
            }
            """)
        self.assertEqual(f(d), 42)
        # Try again to make sure refcounting works.
        self.assertEqual(f(d), 42)
        self.assertEqual(f(d), 42)

    def test_function_call_unsupported_arg(self):
        f = self.context.eval("""
            f = function(x) {
                return 40 + x;
            }
            """)
        with self.assertRaisesRegex(TypeError, "Unsupported type"):
            self.assertEqual(f({}), 42)

    def test_json(self):
        d = self.context.eval("d = {data: 42};")
        self.assertEqual(json.loads(d.json()), {"data": 42})

    def test_call_nonfunction(self):
        d = self.context.eval("({data: 42})")
        with self.assertRaisesRegex(quickjs.JSException, "TypeError: not a function"):
            d(1)

    def test_wrong_context(self):
        context1 = quickjs.Context()
        context2 = quickjs.Context()
        f = context1.eval("(function(x) { return x.a; })")
        d = context2.eval("({a: 1})")
        with self.assertRaisesRegex(ValueError, "Can not mix JS objects from different contexts."):
            f(d)


class FunctionTest(unittest.TestCase):
    def test_adder(self):
        f = quickjs.Function(
            "adder", """
            function adder(x, y) {
                return x + y;
            }
            """)
        self.assertEqual(f(1, 1), 2)
        self.assertEqual(f(100, 200), 300)
        self.assertEqual(f("a", "b"), "ab")

    def test_identity(self):
        identity = quickjs.Function(
            "identity", """
            function identity(x) {
                return x;
            }
            """)
        for x in [True, [1], {"a": 2}, 1, 1.5, "hej", None]:
            self.assertEqual(identity(x), x)

    def test_bool(self):
        f = quickjs.Function(
            "f", """
            function f(x) {
                return [typeof x ,!x];
            }
            """)
        self.assertEqual(f(False), ["boolean", True])
        self.assertEqual(f(True), ["boolean", False])

    def test_empty(self):
        f = quickjs.Function("f", "function f() { }")
        self.assertEqual(f(), None)

    def test_lists(self):
        f = quickjs.Function(
            "f", """
            function f(arr) {
                const result = [];
                arr.forEach(function(elem) {
                    result.push(elem + 42);
                });
                return result;
            }""")
        self.assertEqual(f([0, 1, 2]), [42, 43, 44])

    def test_dict(self):
        f = quickjs.Function(
            "f", """
            function f(obj) {
                return obj.data;
            }""")
        self.assertEqual(f({"data": {"value": 42}}), {"value": 42})

    def test_time_limit(self):
        f = quickjs.Function(
            "f", """
            function f() {
                let arr = [];
                for (let i = 0; i < 100000; ++i) {
                    arr.push(i);
                }
                return arr;
            }
        """)
        f()
        f.set_time_limit(0)
        with self.assertRaisesRegex(quickjs.JSException, "InternalError: interrupted"):
            f()
        f.set_time_limit(-1)
        f()

    def test_garbage_collection(self):
        f = quickjs.Function(
            "f", """
            function f() {
                let a = {};
                let b = {};
                a.b = b;
                b.a = a;
                a.i = 42;
                return a.i;
            }
        """)
        initial_count = f.memory()["obj_count"]
        for i in range(10):
            prev_count = f.memory()["obj_count"]
            self.assertEqual(f(run_gc=False), 42)
            current_count = f.memory()["obj_count"]
            self.assertGreater(current_count, prev_count)

        f.gc()
        self.assertLessEqual(f.memory()["obj_count"], initial_count)

    def test_deep_recursion(self):
        f = quickjs.Function(
            "f", """
            function f(v) {
                if (v <= 0) {
                    return 0;
                } else {
                    return 1 + f(v - 1);
                }
            }
        """)

        self.assertEqual(f(100), 100)
        limit = 500
        with self.assertRaises(quickjs.StackOverflow):
            f(limit)
        f.set_max_stack_size(2000 * limit)
        self.assertEqual(f(limit), limit)

    def test_add_callable(self):
        f = quickjs.Function(
            "f", """
            function f() {
                return pfunc();
            }
        """)
        f.add_callable("pfunc", lambda: 42)

        self.assertEqual(f(), 42)

    def test_execute_pending_job(self):
        f = quickjs.Function(
            "f", """
            obj = {x: 0, y: 0};
            async function a() {
                obj.x = await 1;
            }
            a();
            Promise.resolve().then(() => {obj.y = 1});
            function f() {
                return obj.x + obj.y;
            }
        """)
        self.assertEqual(f(), 0)
        self.assertEqual(f.execute_pending_job(), True)
        self.assertEqual(f(), 1)
        self.assertEqual(f.execute_pending_job(), True)
        self.assertEqual(f(), 2)
        self.assertEqual(f.execute_pending_job(), False)

    def test_global(self):
        f = quickjs.Function(
            "f", """
            function f() {
            }
        """)
        self.assertTrue(isinstance(f.globalThis, quickjs.Object))
        with self.assertRaises(AttributeError):
            f.globalThis = 1


class JavascriptFeatures(unittest.TestCase):
    def test_unicode_strings(self):
        identity = quickjs.Function(
            "identity", """
            function identity(x) {
                return x;
            }
            """)
        context = quickjs.Context()
        for x in ["äpple", "≤≥", "☺"]:
            self.assertEqual(identity(x), x)
            self.assertEqual(context.eval('(function(){ return "' + x + '";})()'), x)

    def test_es2020_optional_chaining(self):
        f = quickjs.Function(
            "f", """
            function f(x) {
                return x?.one?.two;
            }
        """)
        self.assertIsNone(f({}))
        self.assertIsNone(f({"one": 12}))
        self.assertEqual(f({"one": {"two": 42}}), 42)

    def test_es2020_null_coalescing(self):
        f = quickjs.Function(
            "f", """
            function f(x) {
                return x ?? 42;
            }
        """)
        self.assertEqual(f(""), "")
        self.assertEqual(f(0), 0)
        self.assertEqual(f(11), 11)
        self.assertEqual(f(None), 42)

    def test_symbol_conversion(self):
        context = quickjs.Context()
        context.eval("a = Symbol();")
        context.set("b", context.eval("a"))
        self.assertTrue(context.eval("a === b"))

    def test_large_python_integers_to_quickjs(self):
        context = quickjs.Context()
        # Without a careful implementation, this made Python raise a SystemError/OverflowError.
        context.set("v", 10**25)
        # There is precision loss occurring in JS due to
        # the floating point implementation of numbers.
        self.assertTrue(context.eval("v == 1e25"))

    def test_bigint(self):
        context = quickjs.Context()
        self.assertEqual(context.eval(f"BigInt('{10**100}')"), 10**100)
        self.assertEqual(context.eval(f"BigInt('{-10**100}')"), -10**100)

class Threads(unittest.TestCase):
    def setUp(self):
        self.context = quickjs.Context()
        self.executor = concurrent.futures.ThreadPoolExecutor()

    def tearDown(self):
        self.executor.shutdown()

    def test_concurrent(self):
        """Demonstrates that the execution will crash unless the function executes on the same
           thread every time.

           If the executor in Function is not present, this test will fail.
        """
        data = list(range(1000))
        jssum = quickjs.Function(
            "sum", """
                function sum(data) {
                    return data.reduce((a, b) => a + b, 0)
                }
            """)

        futures = [self.executor.submit(jssum, data) for _ in range(10)]
        expected = sum(data)
        for future in concurrent.futures.as_completed(futures):
            self.assertEqual(future.result(), expected)

    def test_concurrent_own_executor(self):
        data = list(range(1000))
        jssum1 = quickjs.Function("sum",
                                  """
                                    function sum(data) {
                                        return data.reduce((a, b) => a + b, 0)
                                    }
                                  """,
                                  own_executor=True)
        jssum2 = quickjs.Function("sum",
                                  """
                                    function sum(data) {
                                        return data.reduce((a, b) => a + b, 0)
                                    }
                                  """,
                                  own_executor=True)

        futures = [self.executor.submit(f, data) for _ in range(10) for f in (jssum1, jssum2)]
        expected = sum(data)
        for future in concurrent.futures.as_completed(futures):
            self.assertEqual(future.result(), expected)


class QJS(object):
    def __init__(self):
        self.interp = quickjs.Context()
        self.interp.eval('var foo = "bar";')


class QuickJSContextInClass(unittest.TestCase):
    def test_github_issue_7(self):
        # This used to give stack overflow internal error, due to how QuickJS calculates stack
        # frames. Passes with the 2021-03-27 release.
        qjs = QJS()
        self.assertEqual(qjs.interp.eval('2+2'), 4)
