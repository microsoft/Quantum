#!/bin/bash 

ver=$1
pkgs=$2

if [ "$(uname)" == "Darwin" ]; then
  backup="''"
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
Microsoft.Quantum.Research"}

for pkg in `echo $pkgs | tr ";" "\n"`; do 
  echo Will update package $pkg with version $ver...

  grep --include=\packages.config -lri -e "package *id=\"$pkg\" *version=" * | xargs sed -i $backup "s/package *id=\"$pkg\" *version=\"\([^\"]*\)\"/package id=\"$pkg\" version=\"$ver\"/i"
  grep --include=\*proj -lri -e "PackageReference *Include=\"$pkg\" *Version=" * | xargs sed -i $backup "s/PackageReference *Include=\"$pkg\" *Version=\"\([^\"]*\)\"/PackageReference Include=\"$pkg\" Version=\"$ver\"/i"
done 


# Update Python version in environment.yml files:
case $ver in
   *-alpha) py_version=`echo $ver | sed  "s/\(.*\)-.*/\1a1/g"`;;
   *-beta) py_version=`echo $ver | sed  "s/\(.*\)-.*/\1b1/g"`;;   
   *) py_version=$ver;;
esac
grep --include=\environment.yml -lri -e "qsharp==" * | xargs sed -i $backup "s/qsharp==\([^ ]*\)/qsharp==$py_version/i"

# Update Dockerfile:
sed -i $backup "s/qsharp==\([^ ]*\)/qsharp==$py_version/i" Dockerfile
sed -i $backup "s/Microsoft.Quantum.IQSharp[ ]*--version[ ]*\([^ ]*\)/Microsoft.Quantum.IQSharp --version $ver/i" Dockerfile

echo done!
echo

# For debugging....
git status
git --no-pager diff
