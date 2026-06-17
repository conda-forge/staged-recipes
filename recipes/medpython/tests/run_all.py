#!/usr/bin/env python
from ETL_Infra.data_fetcher.files_fetcher import files_fetcher
from ETL_Infra.etl_process import (
    prepare_dicts,
    prepare_final_signals,
    finish_prepare_load,
)
import requests
import pandas as pd
import os
import subprocess
from pathlib import Path

import tempfile

# WORK_DIR = "/tmp"
WORK_DIR = tempfile.gettempdir()  # For Cross Platform
WORK_DIR_ETL = os.path.join(WORK_DIR, "NHANES_ETL")


def process_demo(df: pd.DataFrame) -> pd.DataFrame:
    df_gender = df[["pid", "GENDER"]].rename(columns={"GENDER": "value_0"}).copy()
    df_gender["signal"] = "GENDER"
    df_gender = df_gender[["pid", "signal", "value_0"]]
    df_gender.dropna(subset=["value_0"], inplace=True)
    df_gender["value_0"] = df_gender["value_0"].map({1.0: "Male", 2.0: "Female"})

    # Extract Birth Year (approximated from age)
    df_age = df[["pid", "Age"]].copy()
    df_age.dropna(subset=["Age"], inplace=True)
    df_age["signal"] = "BDATE"
    # All input data is from 2017, so we approximate the birth year.
    df_age["value_0"] = (2017 - df_age["Age"].astype(int)) * 10000 + 101
    df_age = df_age[["pid", "signal", "value_0"]]

    # Combine and assign back to the 'df' variable
    df = pd.concat([df_age, df_gender], ignore_index=True)
    return df


def process_labs(df: pd.DataFrame) -> pd.DataFrame:
    df = df.drop(columns=["LBXNRBC", "signal"], errors="ignore")
    sig_list = ["Hemoglobin", "Hematocrit", "RBC", "MCH"]

    # Assume the lab test date was Jan 1, 2017
    df["time_0"] = 20170101

    all_dfs = []
    for sig in sig_list:
        sig_df = df[["pid", "time_0", sig]].rename(columns={sig: "value_0"}).copy()
        sig_df["signal"] = sig
        all_dfs.append(sig_df)

    # Combine all individual signal DataFrames
    df = pd.concat(all_dfs, ignore_index=True)
    df.dropna(subset=["value_0"], inplace=True)
    return df


def get_demo():
    url = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/DEMO_J.xpt"
    cache_file = os.path.join(WORK_DIR, "raw_data", "DEMO_J.xpt")
    if not os.path.exists(os.path.join(WORK_DIR, "raw_data")):
        os.makedirs(os.path.join(WORK_DIR, "raw_data"), exist_ok=True)
    if not os.path.exists(cache_file):
        print("Retrieving demo data from cdc.gov...")
        resp = requests.get(url).content
        with open(cache_file, "wb") as f:
            f.write(resp)

    # Helper function to read and parse the SAS file into a DataFrame
    def read_file(cache_file):
        df = pd.read_sas(cache_file, format="xport")
        df.rename(
            columns={"SEQN": "pid", "RIAGENDR": "GENDER", "RIDAGEYR": "Age"},
            inplace=True,
        )
        df["pid"] = df["pid"].astype(int)
        df = process_demo(df)
        return df

    # Return a callable for lazy data loading, which is good practice for large datasets.
    return lambda batch_size, start_batch: files_fetcher(
        [cache_file], batch_size, read_file, start_batch
    )


def get_labs():
    url = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/CBC_J.xpt"
    cache_file = os.path.join(WORK_DIR, "raw_data", "CBC_J.xpt")
    if not os.path.exists(os.path.join(WORK_DIR, "raw_data")):
        os.makedirs(os.path.join(WORK_DIR, "raw_data"), exist_ok=True)
    if not os.path.exists(cache_file):
        print("Retrieving lab data from cdc.gov...")
        resp = requests.get(url).content
        with open(cache_file, "wb") as f:
            f.write(resp)

    # Helper function to read and parse the SAS file into a DataFrame
    def read_file(cache_file):
        df = pd.read_sas(cache_file, format="xport")
        convert_names = {
            "LBXRBCSI": "RBC",
            "LBXHGB": "Hemoglobin",
            "LBXHCT": "Hematocrit",
            "LBXMCHSI": "MCH",
        }
        df.rename(columns={"SEQN": "pid"}, inplace=True)
        df.rename(columns=convert_names, inplace=True)
        df["pid"] = df["pid"].astype(int)
        df = process_labs(df)
        return df

    # Return a callable for lazy data loading.
    return lambda batch_size, start_batch: files_fetcher(
        [cache_file], batch_size, read_file, start_batch
    )


# Define a working directory for the ETL process


# The system will prompt you to create the processor scripts below (BDATE.py and labs.py)
prepare_final_signals(get_demo(), WORK_DIR_ETL, "BDATE", override="n")
prepare_final_signals(get_labs(), WORK_DIR_ETL, "labs", override="n")

# Finalize the loading process and create the repository
finish_prepare_load(
    WORK_DIR_ETL,
    dest_folder=os.path.join(WORK_DIR, "repository", "NHANES"),
    dest_rep="nhanes",
)

# Run final load:
subprocess.run(["python", os.path.join(WORK_DIR_ETL, "rep_configs", "load_with_medpython.py")], check=True)

# Generate samples:
import med
import random

# Initialize a repository object and load the BDATE signal to get all patient IDs
rep = med.PidRepository()
rep.read_all(
    os.path.join(WORK_DIR, "repository", "NHANES", "nhanes.repository"), [], ["BDATE"]
)

# Create a DataFrame with all patients
all_patients = rep.get_sig("BDATE").rename(columns={"pid": "id"})

# Define the structure for a MedSamples file
all_patients["EVENT_FIELDS"] = "SAMPLE"
all_patients["time"] = 20170101  # The time of prediction
all_patients["outcome"] = [random.randint(0, 1) for _ in range(len(all_patients))]
all_patients["split"] = -1  # Can store split information for cross validation
all_patients["outcomeTime"] = 20500101

# Ensure columns are in the correct order and save to a TSV file
all_patients = all_patients[
    ["EVENT_FIELDS", "id", "time", "outcome", "outcomeTime", "split"]
]
all_patients.to_csv(os.path.join(WORK_DIR, "train_samples"), index=False, sep="\t")


# Train the model:
rep_path = os.path.join(WORK_DIR, "repository", "NHANES", "nhanes.repository")
model_json_path = str(Path(__file__).parent / 'model_architecture.json')
samples_path = os.path.join(WORK_DIR, "train_samples")

# --- 2. Initialize Model and Fit to Repository ---
print("Initializing model...")
model = med.Model()
model.init_from_json_file(model_json_path)

# Initialize the repository to understand its structure. This helps the model
# identify which signals can be generated vs. which need to be fetched.
rep = med.PidRepository()
rep.init(rep_path)
model.fit_for_repository(rep)

# Get the list of signals that must be fetched from the repository.
required_signals = model.get_required_signal_names()

# --- 3. Load Data ---
print("Loading training samples and repository data...")
samples = med.Samples()
samples.read_from_file(samples_path)

# Get patient IDs from the samples to load only the necessary data.
patient_ids = samples.get_ids()

# Load the actual data for the required signals and patients.
rep = med.PidRepository()
rep.read_all(rep_path, patient_ids, required_signals)

# --- 4. Train the Model ---
print("Starting model training...")
model.learn(rep, samples)
print("Training complete.")