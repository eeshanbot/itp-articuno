#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 14 18:46:07 2020

@author: alexandrarivera
"""
import ftplib
import hashlib
import os
import fnmatch
import zipfile
import shutil
import glob

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

# Get only files ending in "final.zip"
filematch = '*final.zip'
filtered = fnmatch.filter(ls, filematch)

# Get only files ending in "grddata.zip"
filematch_grd = '*grddata.zip'
filtered_grd = fnmatch.filter(ls, filematch_grd)

# For each profiler, append most updated zip file (final or grddata)
final = {}
grddata = {}
all_machines = []

for old in filtered:
    o = old.split()[-1][:-9]
    final[o] = old
for active in filtered_grd:
    a = active.split()[-1][:-11]
    grddata[a] = active

mach_nums = range(1, 123)
for num in mach_nums:
    if 'itp' + str(num) not in final.keys():
        if 'itp' + str(num) in grddata.keys():
            all_machines.append(grddata.get('itp' + str(num)))

for filtered_entry in filtered:
	all_machines.append(filtered_entry)

# Download and unzip all files
for entry in all_machines:
	filename = entry.split()[-1][:-4]
	print("Processing %s.zip..." % filename)
	downloaded = False

	# If a local zip file exists with the same name as a remote zip file
	if(os.path.exists(os.path.join(savedir, '%s.zip' % filename))):
		remote_zip_hash = None
		local_zip_hash = None
		# Delete temporary local zip file if exists (e.g. from an incomplete run of program)
		if(os.path.exists('%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX))):
			os.remove('%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX))
		# Process remote zip
		with open('%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX) ,'wb') as fp:
			# Retrieve remote zip
			print(ASCII_LASTLINE + "Retrieving %s.zip..." % filename)
			ftp.retrbinary('RETR %s.zip' % filename, fp.write)
			fp.close()
			downloaded = True
			# Calculate remote zip MD5 hash
			with open(os.path.join(savedir, '%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX)), "rb") as remotefile:
				# Calculate remote zip (now downloaded) MD5 hash
				remote_zip_hashdigest = hashlib.md5(remotefile.read()).hexdigest()
		# Process local zip
		with open(os.path.join(savedir, '%s.zip' % filename), "rb") as localfile:
			# Calculate local zip MD5 hash
			local_zip_hashdigest = hashlib.md5(localfile.read()).hexdigest()
		# Compare hashes if both files have been properly hashed (if an error occurred, download & extract as normal)
		if((local_zip_hashdigest is not None and remote_zip_hashdigest is not None) and local_zip_hashdigest == remote_zip_hashdigest):
			# Delete downloaded file
			os.remove('%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX))
			print(ASCII_LASTLINE + "Skipped %s.zip (%s)" % (filename, local_zip_hashdigest))
			continue
		# If they don't match, delete the local zip file
		else:
			# Delete local zip file
			os.remove('%s.zip' % filename)
			# Since downloaded is still True, the new remote zip file (downloaded with the temporary suffix) will be renamed and processed as usual
	
	if(downloaded):
		# Remove the temporary suffix from the local file previously downloaded for hashing
		os.rename('%s%s.zip' % (filename, PREHASH_FILENAME_SUFFIX), '%s.zip' % filename)
	else:
		# Download/retrieve the zip file
		with open('%s.zip' % filename ,'wb') as fp:
			print(ASCII_LASTLINE + "Retrieving %s.zip..." % filename)
			ftp.retrbinary('RETR %s.zip' % filename, fp.write)
			fp.close()
	
	# Delete the zip-named folder if it exists
	if os.path.exists(os.path.join(savedir, filename)):
		shutil.rmtree(os.path.join(savedir, filename))
	# Create a folder named after the zip
	os.mkdir(os.path.join(savedir, filename))

	# Extract the zip contents into the folder named after it
	with zipfile.ZipFile(os.path.join(savedir, '%s.zip' % filename), 'r') as zip_ref:
		print(ASCII_LASTLINE + "Extracting %s.zip..." % filename)
		zip_ref.extractall(path=os.path.join(savedir, filename))

	# Delete extra files that are organized separately (rawlocs)
	rawLocFiles = glob.glob(os.path.join(savedir,filename,'*rawlocs*'))
	for bf in rawLocFiles:
		os.remove(bf)
	
	print(ASCII_LASTLINE + "Extracted %s.zip    " % filename)