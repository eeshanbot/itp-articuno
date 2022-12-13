#!/bin/sh
for zip in *.zip
do
  dirname=`echo $zip | sed 's/\.zip$//'`
  echo $dirname
  unzip -n -q "$zip" -d $dirname
done