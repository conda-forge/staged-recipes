from tempfile import NamedTemporaryFile

import click
import rich
import uvicorn
from click import UsageError


@click.command()
@click.option(
    "--file",
    "file_path",
    type=click.Path(exists=True, file_okay=True, dir_okay=False),
    required=False,
    help="The path to the file of molecules (.smi, .sdf, .sdf.gz) to display.",
)
@click.option(
    "--qcf-dataset",
    "qc_dataset_name",
    type=str,
    required=False,
    help="The name of a QC dataset stored in the public QCArchive to extract the "
    "molecules to visualize from.",
)
@click.option(
    "--qcf-datatype",
    "qc_dataset_type",
    type=click.Choice(["basic", "opt", "td"], case_sensitive=False),
    required=False,
    help="The type of dataset referenced by the `--qcf-dataset` input.",
)
@click.option(
    "--port",
    type=int,
    default=8000,
    show_default=True,
    required=True,
    help="The port to run the GUI on.",
)
@click.pass_context
def main(ctx, file_path, qc_dataset_name, qc_dataset_type, port):

    from splore.db import SploreDB
    from splore.io import molecules_from_file, molecules_from_qcfractal
    from splore.utilities import set_env

    if file_path is None and qc_dataset_name is None:
        raise UsageError(
            "Use either the `--file` or `--qcf-dataset` option to specify which "
            "molecules to load",
            ctx,
        )
    if file_path is not None and qc_dataset_name is not None:
        raise UsageError(
            "Only one of the `--file` or `--qcf-dataset` may be provided", ctx
        )
    if qc_dataset_name is not None and qc_dataset_type is None:
        raise UsageError(
            "A `--qcf-datatype` must be provided when specifying a `--qcf-dataset`", ctx
        )

    console = rich.get_console()
    console.rule("SPLORE")

    with NamedTemporaryFile(suffix=".sqlite") as db_file:

        db = SploreDB(db_file.name)

        with console.status(
            f"loading [file]{file_path if file_path else qc_dataset_name}[/file]"
        ):

            if file_path is not None:
                molecules = molecules_from_file(file_path)
            elif qc_dataset_name is not None:
                molecules = molecules_from_qcfractal(qc_dataset_name, qc_dataset_type)
            else:
                raise NotImplementedError()

            db.create(molecules)

        with set_env(
            SPLORE_DB_PATH=db_file.name,
            SPLORE_API_PORT=f"{port}",
        ):

            rich.print(
                f"The GUI will be available at http://localhost:{port} after a few "
                f"seconds."
            )

            uvicorn.run(
                "splore.app:app",
                host="0.0.0.0",
                port=port,
                log_level="error",
            )
