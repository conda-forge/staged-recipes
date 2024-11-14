# HWM: Adaptive Hammerstein-Wiener Modeling Toolkit

[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)  
[![PyPI version](https://img.shields.io/pypi/v/hwm.svg)](https://pypi.org/project/hwm/)  
[![Documentation Status](https://readthedocs.org/projects/hwm/badge/?version=latest)](https://hwm.readthedocs.io/en/latest/)

HWM is a **Python toolkit for adaptive dynamic system modeling**, designed to capture complex nonlinear and linear relationships in data through the Hammerstein-Wiener architecture. With a flexible, modular design, HWM integrates seamlessly with [Scikit-learn](https://scikit-learn.org/), enabling streamlined workflows for regression, classification, and time-series forecasting tasks.

## 🚀 Key Features

- **Adaptive Hammerstein-Wiener Models**: Supports both regression and classification with customizable nonlinear and dynamic components.
- **Time-Series and Dynamic System Modeling**: Tools for handling sequence-based and time-dependent data.
- **Scikit-Learn Compatible API**: Designed to integrate easily with Scikit-learn workflows.
- **Flexible Metrics and Utilities**: Custom metrics like `prediction_stability_score` and `twa_score` for model evaluation, along with data handling utilities.

## 📦 Installation

HWM requires **Python 3.9** or later. Install it from [PyPI](https://pypi.org/project/hwm/) using `pip`:

```bash
pip install hwm
```

For detailed installation instructions, refer to the [Installation Guide](https://hwm.readthedocs.io/en/latest/installation.html).

## 🏁 Getting Started

### 🔍 Example: Classification with Hammerstein-Wiener Model

```python
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from hwm.estimators import HammersteinWienerClassifier
from hwm.metrics import prediction_stability_score

# Generate synthetic data
X, y = make_classification(n_samples=1000, n_features=20)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Initialize the model
hw_model = HammersteinWienerClassifier(
    nonlinear_input_estimator=StandardScaler(),
    nonlinear_output_estimator=StandardScaler(),
    p=2,
    loss="cross_entropy"
)

# Train and evaluate
hw_model.fit(X_train, y_train)
y_pred = hw_model.predict(X_test)
stability_score = prediction_stability_score(y_pred)
print(f"Prediction Stability Score: {stability_score:.4f}")
```

For more usage examples, see the [Examples Page](https://hwm.readthedocs.io/en/latest/examples.html).

## 📖 Documentation

Comprehensive documentation is available on [Read the Docs](https://hwm.readthedocs.io). Key sections include:

- [API Documentation](https://hwm.readthedocs.io/en/latest/api.html): Detailed reference for all modules and functions.
- [User Guide](https://hwm.readthedocs.io/en/latest/user_guide.html): Step-by-step guidance for using HWM.
- [Installation Guide](https://hwm.readthedocs.io/en/latest/installation.html): Complete installation instructions.

## 🔗 Project Links

- **Documentation**: [hwm.readthedocs.io](https://hwm.readthedocs.io)
- **Source Code**: [GitHub Repository](https://github.com/earthai-tech/hwm)
- **Issue Tracker**: [GitHub Issues](https://github.com/earthai-tech/hwm/issues)
- **Download**: [PyPI Downloads](https://pypi.org/project/hwm/#files)

## 🤝 Contributing

We welcome contributions! Please submit issues or pull requests via our [GitHub repository](https://github.com/earthai-tech/hwm). For major changes, discuss your ideas in the issues section first to align with project goals.

## 👨‍💼 Maintainers

- **Laurent Kouadio**  
  - Email: [etanoyau@gmail.com](mailto:etanoyau@gmail.com)  

## 📝 License

HWM is licensed under the BSD-3-Clause license. See the [LICENSE](LICENSE) file for details.

## 🏷️ Keywords

`machine learning`, `dynamic systems`, `regression`,  
`classification`, `time-series`, `Scikit-learn compatible`

---

For additional resources, visit the [User Guide](https://hwm.readthedocs.io/en/latest/user_guide.html) and explore our rich tools for dynamic system modeling and time-series analysis. A practical [example of network intrusion detection](https://github.com/earthai-tech/hwm/blob/main/examples/detailed_hwm_vs_lstm.ipynb) is the use of [KDD Cup 1999](https://kdd.ics.uci.edu/databases/kddcup99/kddcup99.html) dataset.

