$LIB = Get-ChildItem -Path "$env:PREFIX" -Filter "*.lib" -Recurse | Where-Object { $_.Name -match "dydx_v4_proto" }

$coinMutableDenom = dumpbin /linkermember:1 $LIB | Select-String -Pattern "\?mutable_denom@Coin"
if (-not $coinMutableDenom) {
    Write-Output "Coin::mutable_denom not found in $LIB"
    exit 1
} else {
    Write-Output "Found Coin::mutable_denom in $LIB"
    $coinMutableDenom | ForEach-Object { Write-Output $_.Line }
}

$HEADER = Get-ChildItem -Path "$env:PREFIX" -Filter "Coin.pb.h" -Recurse
$coinMutableDenom = Get-Content $HEADER.FullName | Select-String -Pattern "Coin::mutable_denom"
if (-not $coinMutableDenom) {
    Write-Output "Coin::mutable_denom not found in $HEADER"
    exit 1
} else {
    Write-Output "Found Coin::mutable_denom in $HEADER"
    $coinMutableDenom | ForEach-Object { Write-Output $_.Line }
}
