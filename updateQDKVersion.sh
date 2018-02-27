#!/bin/bash 

ver=$1
pkgs=$2

: ${ver:="$NUGET_VERSION"}
: ${pkgs:="Microsoft.Quantum.Development.Kit;Microsoft.Quantum.Canon;Microsoft.Quantum.Xunit"}

for pkg in `echo $pkgs | tr ";" "\n"`; do 
  echo Will update package $pkg with version $ver...

  grep --include=\*proj -lri -e "PackageReference *Include=\"$pkg\" *Version=" | xargs sed -i "s/PackageReference *Include=\"$pkg\" *Version=\"\([^\"]*\)\"/PackageReference Include=\"$pkg\" Version=\"$ver\"/i"
  grep --include=\packages.config -lri -e "package *id=\"$pkg\" *version=" | xargs sed -i "s/package *id=\"$pkg\" *version=\"\([^\"]*\)\"/package id=\"$pkg\" version=\"$ver\"/i"
done 

echo done!
echo

# For debugging....
git status
git --no-pager diff
