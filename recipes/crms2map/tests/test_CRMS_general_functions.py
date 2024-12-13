import os
import shutil
import pytest
import pandas as pd
import numpy as np
from click.testing import CliRunner

from src.CRMS_general_functions import *
# from src.CRMS_Discrete_Hydrographic2subsets import *
# from src.CRMS2Resample import *
# from src.CRMS2Plot import *
# from src.click_main import discrete_subcommand


# def test_download_CRMS(tmpdir):
#     """Test the download_CRMS function with a sample URL."""
#     url = "https://cims.coastal.la.gov/RequestedDownloads/ZippedFiles/CRMS_Discrete_Hydrographic.zip"  # Replace with a real URL if available
#     zip_file = "CRMS_Discrete_Hydrographic.zip"
#     csv_file = "CRMS_Discrete_Hydrographic.csv"
#     input_space = tmpdir.mkdir("input")  # Create a temporary directory for the input space
#
#     # Call the function to download the file
#     result = download_CRMS(url, zip_file, csv_file, str(input_space))


# @pytest.fixture
# def setup_files(tmpdir):
#     """Set up the required files in the temporary directory."""
#     original_input_space = os.path.join(os.getcwd(), "Input")
#     tmp_input_space = tmpdir.mkdir("Input")
#
#     # Copy necessary files from the original input space to tmpdir
#     required_files = ["GEOID99_TO_GEOID12A.csv"]
#     for file_name in required_files:
#         src_file = os.path.join(original_input_space, file_name)
#         dst_file = os.path.join(tmp_input_space, file_name)
#         shutil.copy(src_file, dst_file)
#
#     return tmp_input_space
#
#
# def test_main_function(mocker, tmpdir, setup_files):
#     """Test the main function for CRMS_Discrete_Hydrographic2subsets.py."""
#
#     # Mock the os.getcwd() to return the temporary directory
#     mocker.patch("os.getcwd", return_value=str(tmpdir))
#
#     # Mock the download_CRMS function to avoid actual downloading
#     mocker.patch("src.CRMS_general_functions.download_CRMS", return_value=True)
#
#     # Invoke the Click command using CliRunner
#     runner = CliRunner()
#     result = runner.invoke(discrete_subcommand)
#
#     # Check that the command executed successfully
#     assert result.exit_code == 0, f"Command failed with exit code {result.exit_code}. Output: {result.output}"
#
#     # Define the expected directories and files
#     process_space = os.path.join(str(tmpdir), 'Process')
#
#     expected_files = [
#         os.path.join(setup_files, "GEOID99_TO_GEOID12A.csv"),
#         # Add more expected files if needed
#     ]
#
#     # Check if the expected files were created or exist
#     for file_path in expected_files:
#         assert os.path.exists(file_path), f"Expected file {file_path} does not exist."
#
#     # Check if the Process directory was created
#     assert os.path.exists(process_space), "Process directory was not created."


@pytest.fixture
def sample_data():
    """Fixture that returns a sample pandas DataFrame."""
    data = {
        'Station ID': ['CRMS1234-H01', 'CRMS1234-H02', 'CRMS5678-H01'],
        'Adjusted Salinity (ppt)': [2.5, 3.1, 4.0],
        'Adjusted Water Elevation to Marsh (ft)': [1.2, 1.3, 1.4],
        'Adjusted Water Elevation to Datum (ft)': [0.5, 0.6, 0.7],
        'Adjusted Water Temperature (°C)': [25.0, 26.5, 24.8],
        'Date': ['01/01/2020 00:00:00', '01/01/2020 00:01:00', '01/01/2020 00:02:00'],
        'Time Zone': ['CST', 'CST', 'CST']
    }
    df = pd.DataFrame(data)
    df.index = pd.to_datetime(df['Date'], format='%m/%d/%Y %H:%M:%S')
    return df


def test_pivot_data(sample_data):
    """Test that the pivot operation works as expected."""
    # Pivot the sample data
    pivoted_salinity = sample_data.pivot_table(index=sample_data.index, columns='Station ID',
                                               values='Adjusted Salinity (ppt)')

    # Check the shape of the pivoted DataFrame
    assert pivoted_salinity.shape == (3, 3), "Pivoted DataFrame does not have the expected shape"

    # Check specific values
    assert pivoted_salinity.loc['2020-01-01 00:00:00', 'CRMS1234-H01'] == 2.5, "Unexpected value in pivoted DataFrame"


def test_filter_and_clean_data(sample_data):
    """Test filtering and cleaning of data."""
    # Filter and clean data based on some criteria
    filtered_data = sample_data[sample_data['Station ID'].str.contains('-H')]
    filtered_data['Station ID'] = filtered_data['Station ID'].str.replace('-H\d+', '', regex=True)

    # Check that the filtering worked correctly
    assert filtered_data.shape[0] == 3, "Filtered data does not have the expected number of rows"
    assert all(filtered_data['Station ID'] == ['CRMS1234', 'CRMS1234', 'CRMS5678']), "Station ID cleaning failed"


def test_datetime_conversion(sample_data):
    """Test that datetime conversion and indexing works as expected."""
    sample_data.index.name = "Date"

    # Check if the index is correctly set to datetime
    assert pd.api.types.is_datetime64_any_dtype(sample_data.index), "Index is not datetime type"

    # Check if the datetime conversion is correct
    assert sample_data.index[0] == pd.Timestamp('2020-01-01 00:00:00'), "Datetime conversion failed"


########################################################################################################################
### Resampling test
########################################################################################################################
@pytest.fixture()
def sample_data_hourly():
    """Fixture that returns a sample pandas DataFrame for testing."""
    total_hours = 768
    data = {
        "timestamp": pd.date_range(start="2020-01-01", periods=total_hours, freq="h"),
        "value": range(total_hours),
    }
    df = pd.DataFrame(data)
    df.set_index("timestamp", inplace=True)
    return df, total_hours  # Set 'timestamp' as the index


def test_delta_time(sample_data_hourly):
    """Test the delta_hours"""
    df, total_hours = sample_data_hourly
    delta = (
        df.index.to_series()
        .diff()
        .dt.total_seconds()
        .div(3600)
        .fillna(0)
        .astype(int)[1:]
    )  # Skip the first value
    unique_delta = np.unique(delta)
    assert len(unique_delta) == 1, "Delta between timestamps should be constant."
    assert unique_delta[0] == 1, "Delta between timestamps should be 1 hour."


def test_resample_data_hourly_to_daily(sample_data_hourly):
    """Test resampling data from hourly to daily."""
    df, total_hours = sample_data_hourly
    resampled_df = df.resample("D").mean()  # Resample the DataFrame to daily frequency

    # Check if the resampled DataFrame has the correct number of days and sum of values
    days = np.ceil(total_hours / 24).astype(int)
    assert (
            resampled_df.shape[0] == days
    ), "Resampling to daily should result in the correct number of days."


def test_resample_data_empty_dataframe(sample_data_hourly):
    """Test resampling an empty DataFrame."""
    empty_df, total_hours = sample_data_hourly
    empty_df["value"] = np.nan  # Replace all values with NaN

    resampled_df = empty_df.resample(
        "D"
    ).mean()  # Resample the DataFrame to daily frequency

    # Check if resampling returns a DataFrame where all values are NaN
    assert (
        resampled_df["value"].isna().all()
    ), "Resampling a DataFrame with all NaNs should result in a DataFrame with all NaNs."

    # Optionally, also check if the shape is correct (i.e., the number of days should match)
    days = np.ceil(total_hours / 24).astype(int)
    assert (
            resampled_df.shape[0] == days
    ), f"Expected {days} days, but got {len(resampled_df)} days"


def test_resample_data_hourly_to_monthly(sample_data_hourly):
    """Test resampling data from hourly to monthly."""
    df, total_hours = sample_data_hourly
    # Calculate daily mean values
    daily_mean = df.resample("D").mean()

    # Calculate Monthly mean values
    monthly_mean = (
        daily_mean.resample("MS").mean().where(daily_mean.resample("MS").count() >= 5)
    )

    # Check if the resampled DataFrame has the correct number of months
    months = np.ceil(total_hours / (24 * 30)).astype(int)
    assert (
            monthly_mean.shape[0] == months
    ), "Resampling to monthly should result in the correct number of months."
    assert monthly_mean.index[-1] == pd.Timestamp(
        "2020-02-01"
    ), "Last month should be Feb 2020 when time is set 768 hours."
    assert pd.isna(
        monthly_mean.iloc[-1]["value"]
    ), "Last month should be NaN when count is less than 5."


@pytest.fixture()
def mock_plot_data():
    # Define the time index
    time_index = pd.to_datetime(["2010-01-01", "2014-01-01", "2018-01-01", "2022-01-01"])

    # Mock data to simulate the plot data with the time index
    return {
        'WL': pd.DataFrame({
            'CRMS0002': [1.2, 1.4, 1.1, 1.3],
            'CRMS0003': [0.9, 1.0, 0.8, 0.7]
        }, index=time_index)
    }


def test_plot_CRMS(mock_plot_data, tmpdir):
    # Test the plot generation
    plot_period = ["2008-01-01", "2024-12-31"]
    file_name_o = "WL"

    plot_space = 0.1
    Data_type = "Y"
    output_dir = tmpdir.mkdir("Photo")

    # Update the output directory in the plot_CRMS function call
    output_location = plot_CRMS(mock_plot_data, {}, file_name_o, Data_type, plot_period, plot_space, plot_range=None,
                                station=None, photo_dir=output_dir)

    # Print the output file path for debugging
    output_file = os.path.join(output_dir, f'Water_level_median.png')
    print(f"Expected output file: {output_file}")

    # Check if the file was created
    # assert output_location == output_file, f"The plot should be saved as a PNG file at {output_location}. But made at {output_file}"
    assert os.path.exists(output_file), f"The plot should be saved as a PNG file at {output_file}."
