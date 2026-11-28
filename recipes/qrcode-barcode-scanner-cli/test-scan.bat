@echo off
rem The installed qrscan reads the QR code and the Code 128 of the mixed fixture in every profile.
for %%p in (fast frame full) do (
  qrscan --profile %%p --budget-ms 0 %1 > scan-%%p.json || exit /b 1
  findstr /C:"\"text\": \"https://qrc-ai.com/76xMa\"" scan-%%p.json > nul || exit /b 1
  findstr /C:"\"text\": \"STOCK-4827\"" scan-%%p.json > nul || exit /b 1
  echo ok %%p
)
