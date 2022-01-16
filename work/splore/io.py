import functools
import gzip
import logging
import os.path
from typing import TYPE_CHECKING, Generator, List, Literal, Optional

from rdkit import Chem
from rdkit.Chem import rdDepictor, rdmolfiles
from rdkit.Chem.Draw import rdMolDraw2D

if TYPE_CHECKING:
    from qcportal import FractalClient

_logger = logging.getLogger(__name__)

IMAGE_UNAVAILABLE_SVG = """
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="isolation:isolate" viewBox="0 0 200 200" width="200pt" height="200pt"><defs><clipPath id="_clipPath_eSdCSpw1sB1xWp7flmMoZ0WjTPwPpzQh"><rect width="200" height="200"/></clipPath></defs><g clip-path="url(#_clipPath_eSdCSpw1sB1xWp7flmMoZ0WjTPwPpzQh)"><g clip-path="url(#_clipPath_LvpdWbrYj1cREqoXz8Lwbk3ZilfC6tg9)"><text transform="matrix(1,0,0,1,44.039,91.211)" style="font-family:'Open Sans';font-weight:400;font-size:30px;font-style:normal;fill:#000000;stroke:none;">Preview</text><text transform="matrix(1,0,0,1,17.342,132.065)" style="font-family:'Open Sans';font-weight:400;font-size:30px;font-style:normal;fill:#000000;stroke:none;">Unavailable</text></g><defs><clipPath id="_clipPath_LvpdWbrYj1cREqoXz8Lwbk3ZilfC6tg9"><rect x="0" y="0" width="166" height="81.709" transform="matrix(1,0,0,1,17,59.146)"/></clipPath></defs></g></svg>
"""


def molecules_from_file(file_path: str) -> Generator[Chem.Mol, None, None]:

    from rdkit import Chem

    extension = os.path.splitext(file_path)[-1].lower()

    if extension in (".smi", ".txt"):
        supplier = Chem.SmilesMolSupplier(
            file_path, delimiter="\n", titleLine=False, nameColumn=-1
        )
    elif extension == ".sdf":
        supplier = Chem.SDMolSupplier(file_path)
    elif extension == ".gz":
        supplier = Chem.ForwardSDMolSupplier(gzip.open(file_path))
    else:
        raise NotImplementedError(f"{extension} not supported")

    for rd_molecule in supplier:

        if rd_molecule is None:
            continue

        yield rd_molecule


def molecules_from_qcfractal(
    dataset_name: str,
    dataset_type: Literal["basic", "opt", "td"],
    client: Optional["FractalClient"] = None,
) -> List[Chem.Mol]:

    try:
        from qcportal import FractalClient
    except (ImportError, ModuleNotFoundError):

        raise RuntimeError(
            "The optional `qcportal` dependency could not be imported. Please install "
            "it by running `conda install -c conda-forge qcportal` if you want to load "
            "molecules from a QCFractal dataset."
        )

    from rdkit import Chem

    dataset_class: str = {
        "basic": "Dataset",
        "opt": "OptimizationDataset",
        "td": "TorsionDriveDataset",
    }[dataset_type]

    client = client if client is not None else FractalClient()

    dataset = client.get_collection(dataset_class, dataset_name)

    if dataset_type != "basic":

        cmiles = [
            entry.attributes["canonical_isomeric_explicit_hydrogen_mapped_smiles"]
            for entry in dataset.data.records.values()
            if "canonical_isomeric_explicit_hydrogen_mapped_smiles" in entry.attributes
        ]
        n_missing_cmiles = sum(
            1
            for entry in dataset.data.records.values()
            if "canonical_isomeric_explicit_hydrogen_mapped_smiles"
            not in entry.attributes
        )
    else:
        from qcportal.collections import Dataset

        dataset: Dataset

        qc_molecules = dataset.get_molecules().molecule.values

        cmiles = [
            qc_molecule.extras["canonical_isomeric_explicit_hydrogen_mapped_smiles"]
            for qc_molecule in qc_molecules
            if qc_molecule.extras is not None
            and "canonical_isomeric_explicit_hydrogen_mapped_smiles"
            in qc_molecule.extras
        ]
        n_missing_cmiles = sum(
            1
            for qc_molecule in qc_molecules
            if qc_molecule.extras is None
            or "canonical_isomeric_explicit_hydrogen_mapped_smiles"
            not in qc_molecule.extras
        )

    if n_missing_cmiles > 0:

        _logger.warning(
            f"{n_missing_cmiles} records did not have CMILES information and were "
            f"ignored"
        )

    rd_molecules = []
    found_cmiles = set()

    for pattern in cmiles:
        rd_molecule: Chem.Mol = Chem.MolFromSmiles(pattern)
        rd_atom: Chem.Atom

        for rd_atom in rd_molecule.GetAtoms():
            rd_atom.SetAtomMapNum(0)

        smiles = Chem.MolToSmiles(rd_molecule)

        if smiles in found_cmiles:
            continue

        found_cmiles.add(smiles)
        rd_molecules.append(rd_molecule)

    return rd_molecules


@functools.lru_cache(maxsize=4096)
def molecule_to_svg(smiles: str) -> str:

    smiles_parser = rdmolfiles.SmilesParserParams()
    smiles_parser.removeHs = True

    molecule: Chem.Mol = Chem.MolFromSmiles(smiles, smiles_parser)

    for atom in molecule.GetAtoms():
        atom.SetAtomMapNum(0)

    rdDepictor.Compute2DCoords(molecule)

    drawer = rdMolDraw2D.MolDraw2DSVG(200, 200, 150, 200)
    drawer.SetOffset(25, 0)
    drawer.DrawMolecule(molecule)
    drawer.FinishDrawing()

    svg_content = drawer.GetDrawingText().replace(
        "<rect style='opacity:1.0", "<rect style='opacity: 0"
    )
    return svg_content
