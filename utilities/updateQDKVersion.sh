#!/bin/bash 

ver=$1
pkgs=$2

if [ "$(uname)" == "Darwin" ]; then
  backup=".sedbkp"
else
  backup=""
fi

: ${ver:="$NUGET_VERSION"}
: ${pkgs:="
Microsoft.Quantum.Development.Kit;
Microsoft.Quantum.IQSharp.Core;
Microsoft.Quantum.Simulators;
Microsoft.Quantum.Compiler;
Microsoft.Quantum.Standard;
Microsoft.Quantum.Xunit;
Microsoft.Quantum.Chemistry;
Microsoft.Quantum.Chemistry.Jupyter;
Microsoft.Quantum.MachineLearning;
Microsoft.Quantum.Research"}

# Make sure the version is with the right format for
# each application (Nuget packages, Python packages, and Docker image)
# Allowed inputs are in the following format:
#   {major}.{minor}.{YYMM}{build number} with an optional "." separator between {YYMM} and {build number}
#   and optionally ending with "-alpha" or "-beta"
# Examples of inputs:
# - 0.21.2112.180703
# - 0.21.2112180703
# - 0.21.2112.180703-alpha
# - 0.21.2112180703-beta
# Expected outputs are in the following formats:
# - Nuget format is {major}.{minor}.{YYMM}{build number} optionally ending with "-alpha" or "-beta"
# - Python and Docker image format is {major}.{minor}.{YYMM}.{build number} optionally ending with "-alpha" or "-beta"
# Notes:
# - Using \{1,\} instead of \+ because the latter is not supported in all operating systems
# - Using \{0,1\} instead of \? because the latter is not supported in all operating systems
nuget_ver=`echo  $ver | sed  "s/\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{4\}\)\.\{0,1\}\([0-9]\{1,\}\)\(-[a-z]\{1,\}\)\{0,1\}/\1\2\3/g"`
python_ver=`echo $ver | sed  "s/\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{4\}\)\.\{0,1\}\([0-9]\{1,\}\)\(-[a-z]\{1,\}\)\{0,1\}/\1.\2\3/g"`
docker_ver=`echo $ver | sed  "s/\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{4\}\)\.\{0,1\}\([0-9]\{1,\}\)\(-[a-z]\{1,\}\)\{0,1\}/\1.\2\3/g"`
echo Input version is $ver
echo Version in Nuget format will be $nuget_ver
echo Version in Python format will be $python_ver
echo Version in Docker format will be $docker_ver

# Update all Nuget packages
for pkg in `echo $pkgs | tr ";" "\n"`; do 
  echo Will update package $pkg with version $nuget_ver...

  grep --include=\packages.config -lri -e "package *id=\"$pkg\" *version=" * | xargs sed -i $backup "s/package *id=\"$pkg\" *version=\"\([^\"]*\)\"/package id=\"$pkg\" version=\"$nuget_ver\"/i"
  grep --include=\*proj -lri -e "PackageReference *Include=\"$pkg\" *Version=" * | xargs sed -i $backup "s/PackageReference *Include=\"$pkg\" *Version=\"\([^\"]*\)\"/PackageReference Include=\"$pkg\" Version=\"$nuget_ver\"/i"
done 

# Update Python version in environment.yml files:
grep --include=\environment.yml -lri -e "qsharp==" * | xargs sed -i $backup "s/qsharp==\([^ ]*\)/qsharp==$python_ver/i"

# Update Dockerfile:
sed -i $backup "s/qsharp==\([^ ]*\)/qsharp==$python_ver/i" Dockerfile
sed -i $backup "s/Microsoft.Quantum.IQSharp[ ]*--version[ ]*\([^ ]*\)/Microsoft.Quantum.IQSharp --version $docker_ver/i" Dockerfile

# There is an issue with sed generating backup files on MacOS
# even when -i '' is passed
if [ "$(uname)" == "Darwin" ]; then
find . -type f -name "*.sedbkp" -delete
fi

echo done!
echo

# For debugging....
git status
git --no-pager diff
