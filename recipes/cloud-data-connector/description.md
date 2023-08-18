Cloud Data Connector is a tool to connect to AzureML, Azure blob, GCP storage, GCP Big Query and AWS storage S3. The goal is provide all cloud managers in one place and provide documentation for an easy integration.

***

### Prerequisites 
- Have either python `3.9` or `3.10` already installed.
- Have [libmamba solver](https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community)  installed in your `base` environment.

***

### Installation Command 
```bash
conda install --solver libmamba cloud-data-connector -c intel -c conda-forge -c microsoft 
```

***

### Notes
- To run [AzureML samples](../samples/azure/azureml_sample.py) install the packages `azureml` & `azureml-core` with PyPI using the following command:
```bash
pip install azureml>=0.2.7 azureml-core>=1.49.0
```

⚠️ **Combining Conda and PyPI packages**: Installing packages from both PyPI and Conda could be unstable. If environment is unstable, try installing them in an empty one as follows:
```bash
conda create -n venv --solver libmamba cloud-data-connector -c intel -c conda-forge -c microsoft 
çonda activate venv
pip install azureml>=0.2.7 azureml-core>=1.49.0
```

***

### PyPI Package
[You can check the PyPI package Here](https://pypi.org/project/cloud-data-connector/)

***

