import os
import shutil
import pytest
import pandas as pd
import numpy as np
from click.testing import CliRunner
from CRMS_Discrete_Hydrographic2subsets import discrete_subcommand
from CRMS2Resample import resample_subcommand
from CRMS2Plot import plot_subcommand, plot_data

@pytest.fixture
def mock_input_directory(tmpdir):
    """Fixture to create a mock Input directory with sample data."""
    input_dir = tmpdir.mkdir("Input")
    process_dir = tmpdir.mkdir("Process")

    # Create a mock CSV file for hydrographic data
    hydro_data = input_dir.join("CRMS_Discrete_Hydrographic.csv")
    hydro_data.write(
        "Date (mm/dd/yyyy),Time (hh:mm),Time Zone,CPRA Station ID,Measurement Depth (ft),Soil Porewater Salinity (ppt),Latitude,Longitude\n"
        "2023-01-01,00:00,CST,CRMS1234-P01,0.328,25.3,29.5,-90.0\n"
        "2023-01-02,00:00,CST,CRMS1234-P02,0.984,27.5,29.5,-90.0\n"
    )

    # Create a mock offsets file
    offsets_data = input_dir.join("GEOID99_TO_GEOID12A.csv")
    offsets_data.write("Offset Data Placeholder\n")

    return str(input_dir), str(process_dir)


def test_discrete_subcommand_help():
    """Test the CLI help command."""
    runner = CliRunner()
    result = runner.invoke(discrete_subcommand, ["--help"])
    assert result.exit_code == 0, "CLI help command should succeed."
    assert "Usage:" in result.output, "Help output should include usage instructions."


def test_discrete_subcommand_execution(mock_input_directory, mocker):
    """Test the discrete_subcommand function."""
    input_dir, process_dir = mock_input_directory

    # Mock the current working directory
    mocker.patch("os.getcwd", return_value=os.path.dirname(input_dir))

    # Mock the download_CRMS function to avoid network calls
    mocker.patch("CRMS_Discrete_Hydrographic2subsets.download_CRMS", return_value=None)

    runner = CliRunner()
    result = runner.invoke(discrete_subcommand)

    # Assert the command runs successfully
    assert result.exit_code == 0, f"Discrete command failed: {result.output}"
    assert "Done Step 1" in result.output, "Expected success message not found."

    # Verify output files for Step 1
    generated_files = [
        "CRMS_Discrete_Hydrographic_pore_origin.csv",
        "Pore_salinity_10.csv",
        "Pore_salinity_30.csv",
        "Pore_salinity_10_Mdata.csv",
        "Pore_salinity_30_Mdata.csv",
        "Pore_salinity_10_Ydata.csv",
        "Pore_salinity_30_Ydata.csv",
    ]
    for file in generated_files:
        file_path = os.path.join(input_dir, file)
        assert os.path.exists(file_path), f"Expected file not found: {file}"


def test_discrete_subcommand_invalid_data(mock_input_directory, mocker):
    """Test the discrete_subcommand function with invalid data."""
    input_dir, process_dir = mock_input_directory

    # Overwrite the mock CSV with invalid data
    hydro_data = os.path.join(input_dir, "CRMS_Discrete_Hydrographic.csv")
    with open(hydro_data, "w") as f:
        f.write("Invalid,Data\n")

    # Mock the current working directory
    mocker.patch("os.getcwd", return_value=os.path.dirname(input_dir))

    runner = CliRunner()
    result = runner.invoke(discrete_subcommand)

    # Assert the command handles invalid data gracefully
    assert result.exit_code != 0, "Command should fail for invalid data."
    assert "Error" in result.output or "exception" in result.output.lower(), (
        "Expected error message not found."
    )

@pytest.fixture
def setup_input_directory(tmpdir):
    """Setup a mock Input directory with sample data."""
    input_dir = tmpdir.mkdir("Input")
    # Create a sample CSV file to simulate CRMS data
    sample_file = input_dir.join("sample_CRMS_data.csv")
    sample_file.write(
        "Date,Station ID,Salinity,Water Elevation\n"
        "2023-01-01,CRMS1234-H01,3.5,1.2\n"
        "2023-01-02,CRMS1234-H01,5.2,2.3\n"
    )
    return str(input_dir)


def test_resample_subcommand_help():
    """Test the CLI help command."""
    runner = CliRunner()
    result = runner.invoke(resample_subcommand, ["--help"])
    assert result.exit_code == 0, "CLI help command should succeed."
    assert "Usage:" in result.output, "Help output should include usage instructions."

def test_resample_subcommand_execution(setup_input_directory, mocker):
    """Test the resample_subcommand function."""
    # Mock the current working directory to point to the temporary input directory
    mocker.patch("os.getcwd", return_value=setup_input_directory)

    runner = CliRunner()
    result = runner.invoke(resample_subcommand)

    # Assert the command runs successfully
    assert result.exit_code == 0, f"Resample command failed: {result.output}"
    assert "Done Step 2" in result.output, "Expected success message not found."

    # Verify generated files in the Input directory
    generated_files = [
        "sample_CRMS_data_Hdata.csv",
        "sample_CRMS_data_Ddata.csv",
        "sample_CRMS_data_Mdata.csv",
        "sample_CRMS_data_Ydata.csv",
    ]
    for file in generated_files:
        file_path = os.path.join(setup_input_directory, file)
        assert os.path.exists(file_path), f"Expected file not found: {file}"

@pytest.fixture
def mock_input_data(tmpdir):
    """Fixture to set up mock input data and directories."""
    input_dir = tmpdir.mkdir("Input")
    photo_dir = tmpdir.mkdir("Photo")
    output_dir = tmpdir.mkdir("Output")

    # Create mock data files
    temp_data = input_dir.join("CRMS_Water_Temp_2006_2024_Mdata.csv")
    temp_data.write(
        "Date,Station1,Station2,num_station\n"
        "2023-01-01,20.0,21.5,2\n"
        "2023-02-01,19.8,22.0,2\n"
    )
    salinity_data = input_dir.join("CRMS_Surface_salinity_2006_2024_Mdata.csv")
    salinity_data.write(
        "Date,Station1,Station2,num_station\n"
        "2023-01-01,15.0,16.5,2\n"
        "2023-02-01,14.8,17.0,2\n"
    )

    return str(input_dir), str(photo_dir), str(output_dir)


def test_plot_subcommand_help():
    """Test the CLI help command."""
    runner = CliRunner()
    result = runner.invoke(plot_subcommand, ["--help"])
    assert result.exit_code == 0, "CLI help command should succeed."
    assert "Usage:" in result.output, "Help output should include usage instructions."


def test_plot_data_execution(mock_input_data, mocker):
    """Test the plot_data function execution."""
    input_dir, photo_dir, output_dir = mock_input_data

    # Mock os.getcwd to use the temporary input directory
    mocker.patch("os.getcwd", return_value=input_dir)

    # Run the plot_data function
    plot_data(
        sdate="2023-01-01",
        edate="2023-02-01",
        stationfile=None,
        data_type="M",
        save=True,
        plotdata="MA",
        specify_ma=None,
    )

    # Verify that the plot output exists in the photo directory
    expected_plot = os.path.join(photo_dir, "Water_level_median.png")
    assert os.path.exists(expected_plot), f"Expected plot file not found: {expected_plot}"


def test_plot_data_invalid_date(mock_input_data, mocker):
    """Test the plot_data function with invalid date range."""
    input_dir, photo_dir, output_dir = mock_input_data

    # Mock os.getcwd to use the temporary input directory
    mocker.patch("os.getcwd", return_value=input_dir)

    with pytest.raises(AssertionError, match="Invalid data period"):
        plot_data(
            sdate="2023-02-01",
            edate="2023-01-01",  # Invalid range
            stationfile=None,
            data_type="M",
            save=True,
            plotdata="MA",
            specify_ma=None,
        )


def test_plot_data_missing_file(mock_input_data, mocker):
    """Test the plot_data function with a missing input file."""
    input_dir, photo_dir, output_dir = mock_input_data

    # Remove one of the mock input files
    os.remove(os.path.join(input_dir, "CRMS_Surface_salinity_2006_2024_Mdata.csv"))

    # Mock os.getcwd to use the temporary input directory
    mocker.patch("os.getcwd", return_value=input_dir)

    with pytest.raises(FileNotFoundError):
        plot_data(
            sdate="2023-01-01",
            edate="2023-02-01",
            stationfile=None,
            data_type="M",
            save=True,
            plotdata="MA",
            specify_ma=None,
        )
