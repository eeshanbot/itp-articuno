#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 14 18:46:07 2020

@author: alexandrarivera
@author: eeshanbot
"""
import ftplib
import hashlib
import os
import fnmatch
import zipfile
import shutil

ASCII_LASTLINE='\033[F'

# ==================== CONFIG =================== #

# FTP server credentials
FTP_HOST = 'ftp.whoi.edu'
FTP_USER = 'anonymous'
FTP_PASS = ''
# Local save folder
SAVE_FOLDER = '../itp-data'
# Temporary suffix for downloaded files before hashing has completed
PREHASH_FILENAME_SUFFIX = '_tmp'

# =============================================== #

# Initialize ftp session over TLS
ftp = ftplib.FTP_TLS(host=FTP_HOST, user=FTP_USER, passwd=FTP_PASS)
ftp.encoding = 'utf-8'
# Change to secure connection 
ftp.prot_p()
# Print FTP welcome message
print(ftp.getwelcome())

# Change the remote working directory to ITP folder
ftp.cwd('/whoinet/itpdata')
# Create the local save folder if necessary
savedir = os.path.join(os.path.dirname(os.path.abspath(__file__)), SAVE_FOLDER)
if not os.path.exists(savedir):
	os.makedirs(savedir)
# Change the local working directory to the save folder
os.chdir(savedir)

# Empty structure to hold all FTP data
ls = []
ftp.retrlines('LIST', ls.append)

# Get only ITP files ending in rawlocs.dat
filematch = '*itp*rawlocs.dat'
filtered = fnmatch.filter(ls, filematch)

# For each profiler, just get itp name
profiler = {}

for old in filtered:
    o = old.split()[-1][:-11]
    profiler[o] = old

# Download and unzip all files
for entry in profiler:
	filename = entry + 'rawlocs.dat'

	print("Processing %s..." % filename)
	downloaded = False

	# If a local file exists with the same name as a remote dat file
	if(os.path.exists(os.path.join(savedir, '%s' % filename))):
		remote_zip_hash = None
		local_zip_hash = None
		# Delete temporary local dat file if exists (e.g. from an incomplete run of program)
		if(os.path.exists('%s%s' % (filename, PREHASH_FILENAME_SUFFIX))):
			os.remove('%s%s' % (filename, PREHASH_FILENAME_SUFFIX))
		# Process remote dat file
		with open('%s%s' % (filename, PREHASH_FILENAME_SUFFIX) ,'wb') as fp:
			# Retrieve remote dat file
			print(ASCII_LASTLINE + "Retrieving %s..." % filename)
			ftp.retrbinary('RETR %s' % filename, fp.write)
			fp.close()
			downloaded = True
			# Calculate dat file zip MD5 hash
			with open(os.path.join(savedir, '%s%s' % (filename, PREHASH_FILENAME_SUFFIX)), "rb") as remotefile:
				# Calculate remote (now downloaded) MD5 hash
				remote_zip_hashdigest = hashlib.md5(remotefile.read()).hexdigest()
		# Process local dat
		with open(os.path.join(savedir, '%s' % filename), "rb") as localfile:
			# Calculate local dat MD5 hash
			local_zip_hashdigest = hashlib.md5(localfile.read()).hexdigest()
		# Compare hashes if both files have been properly hashed (if an error occurred, download & extract as normal)
		if((local_zip_hashdigest is not None and remote_zip_hashdigest is not None) and local_zip_hashdigest == remote_zip_hashdigest):
			# Delete downloaded file
			os.remove('%s%s' % (filename, PREHASH_FILENAME_SUFFIX))
			print(ASCII_LASTLINE + "Skipped %s (%s)" % (filename, local_zip_hashdigest))
			continue
		# If they don't match, delete the local dat file
		else:
			# Delete local dat file
			os.remove('%s' % filename)
			# Since downloaded is still True, the new remote zip file (downloaded with the temporary suffix) will be renamed and processed as usual
	
	if(downloaded):
		# Remove the temporary suffix from the local file previously downloaded for hashing
		os.rename('%s%s' % (filename, PREHASH_FILENAME_SUFFIX), '%s' % filename)
	else:
		# Download/retrieve the dat file
		with open('%s' % filename ,'wb') as fp:
			print(ASCII_LASTLINE + "Retrieving %s..." % filename)
			ftp.retrbinary('RETR %s' % filename, fp.write)
			fp.close()
	
	print(ASCII_LASTLINE + "Downloaded %s    " % filename)