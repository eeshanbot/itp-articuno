#!/bin/sh

# fix itp39_1 nonsense
mv itp39_1final.zip itp39final.zip
mv itp39_1rawlocs.dat itp39rawlocs.dat
for zip in *.zip
do
  dirname=`echo $zip | sed 's/\.zip$//'`
  echo $dirname
  unzip -n -q "$zip" -d $dirname
done