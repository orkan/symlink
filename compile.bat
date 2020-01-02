@echo off

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

git describe --tags --abbrev=0 > bin\git_ver.txt
set /p LATEST_TAG= < bin\git_ver.txt
git rev-parse --short HEAD > bin\git_rev.txt
set /p LATEST_REV= < bin\git_rev.txt

echo git_version := "%LATEST_TAG%" > src\symlink.ver.ahk
echo git_revision := "%LATEST_REV%" >> src\symlink.ver.ahk
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "src\symlink.ahk" /out "bin\symlink.exe" /icon "res\shell32.dll,16769.ico"

if "%OS%"=="Windows_NT" endlocal
