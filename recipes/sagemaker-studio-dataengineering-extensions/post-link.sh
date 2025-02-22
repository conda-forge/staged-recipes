echo $PREFIX
PYTHON_PKG_NAME=sagemaker_studio_dataengineering_extensions
# GET Python version in 3.11 or 3.12 format
PYTHON_VERSION=$(python -V | cut -d ' ' -f2 | cut -d '.' -f1,2)

cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_spark_monitor_widget && pip install .
cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_jupyter_server_extension && pip install .
cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_data_explorer && pip install .
cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_connection_magics_jlextension && pip install .
cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_ui_doc_manager_jl_plugin && pip install .
cd $PREFIX/lib/python$PYTHON_VERSION/site-packages/$PYTHON_PKG_NAME/sagemaker_studio_theme && pip install .
