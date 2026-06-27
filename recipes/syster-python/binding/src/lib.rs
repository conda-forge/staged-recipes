use pyo3::prelude::*;
use std::path::Path;

/// Parse a SysML v2 or KerML file and return the normalized AST as a string.
#[pyfunction]
fn parse_content(content: &str, path: &str) -> PyResult<String> {
    let path = Path::new(path);
    match syster::syntax::parse_content(content, path) {
        Ok(syntax_file) => Ok(format!("{syntax_file:#?}")),
        Err(e) => Err(PyErr::new::<pyo3::exceptions::PyValueError, _>(e)),
    }
}

/// Parse a SysML v2 or KerML file and return diagnostics.
#[pyfunction]
fn parse_with_diagnostics(content: &str, path: &str) -> PyResult<Vec<String>> {
    let path = Path::new(path);
    let result = syster::syntax::parse_with_result(content, path);
    let diagnostics: Vec<String> = result.errors.iter().map(|e| format!("{e}")).collect();
    Ok(diagnostics)
}

/// Parse raw KerML source text using the low-level parser.
#[pyfunction]
fn parse_kerml(content: &str) -> PyResult<String> {
    let parse = syster::parser::parse_kerml(content);
    Ok(format!("{:#?}", parse.syntax()))
}

/// Parse raw SysML source text using the low-level parser.
#[pyfunction]
fn parse_sysml(content: &str) -> PyResult<String> {
    let parse = syster::parser::parse_sysml(content);
    Ok(format!("{:#?}", parse.syntax()))
}

/// Python module for SysML v2 and KerML analysis.
#[pymodule]
#[pyo3(name = "syster")]
fn syster_python(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(parse_content, m)?)?;
    m.add_function(wrap_pyfunction!(parse_with_diagnostics, m)?)?;
    m.add_function(wrap_pyfunction!(parse_kerml, m)?)?;
    m.add_function(wrap_pyfunction!(parse_sysml, m)?)?;
    Ok(())
}
