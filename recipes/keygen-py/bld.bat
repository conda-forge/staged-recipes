maturin build --release

for %%f in (target/wheels/keygen_py-*.whl) do (
    %PYTHON% -m pip install target/wheels/%%f
)
