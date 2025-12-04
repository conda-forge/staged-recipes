$ErrorActionPreference = 'Continue';

$xml = Join-Path (Get-Location) 'pytest-report.xml';

python -m pytest tests/ -v --pg-first --skip-boosop --junitxml $xml;

$code = $LASTEXITCODE;

if ($code -eq 0) {
    exit 0
};

if (Test-Path -LiteralPath $xml) {
    [xml]$j = Get-Content -LiteralPath $xml -Raw;

    $s = @();
    if ($j.testsuite) {
        $s = @($j.testsuite)
    } elseif ($j.testsuites) {
        $s = @($j.testsuites.testsuite)
    };

    $fails = ($s | ForEach-Object { [int]$_.failures } | Measure-Object -Sum | Select-Object -ExpandProperty Sum);
    $errs  = ($s | ForEach-Object { [int]$_.errors }   | Measure-Object -Sum | Select-Object -ExpandProperty Sum);
    $tests = ($s | ForEach-Object { [int]$_.tests }    | Measure-Object -Sum | Select-Object -ExpandProperty Sum);

    if ($tests -gt 0 -and $fails -eq 0 -and $errs -eq 0) {
        exit 0
    }
};

exit $code
