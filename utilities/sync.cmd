::
:: This script pushes the changes on the given branch to
:: the public repository (https://github.com/Microsoft/Quantum.git)
::
set branch=%1
IF "%branch%" == "" SET branch=main

git fetch origin
git fetch public || call :addPublic
git push public origin/%branch%:%branch%
GOTO :EOF

:addPublic
git remote add public https://github.com/Microsoft/Quantum.git
git fetch public
EXIT /B

:EOF