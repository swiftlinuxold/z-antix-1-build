#! /usr/bin/env python

import sys, commands # Allows checking for root
import os, os.path # Needed for removing files
import shutil # Needed for copying files

username = commands.getoutput( "whoami" )
if username == 'root':
	sys.exit( 'You must be non-root to run this script.' )

dir_develop='/home/'+username+'/develop'
dir_build=dir_develop+'/1-build'

os.system ('python '+dir_build+'/create-regular.py')

def change_text (filename, text_old, text_new):
	text=open(filename, 'r').read()
	text = text.replace(text_old, text_new) 
	open(filename, "w").write(text)
	
def copy_file (file_old, file_new, text_old, text_new):
	ret = os.access(file_new, os.F_OK)
	if (ret):
		os.remove (file_new)
	shutil.copy2 (file_old, file_new)
	change_text(file_new, text_old, text_new)
	
def copy_file_1build (name, name_full):
	# name is all-lowercase (taylorswift, minnesota, chicago)
	# name_full is the full name (Taylor Swift Linux, Minnesota Swift Linux,
	# Chicago Swift Linux)
	file1=dir_build+'/preinstall-regular.sh'
	file2=dir_build+'/preinstall-'+name+'.sh'
	text1='rm -r /tmp/ssh*'
	text2='get_rep sound-'+name+'\n'
	text2=text2+'get_rep wallpaper-'+name+'\n'
	text2=text2+text1
	copy_file (file1, file2, text1, text2)
	
	file1=dir_build+'/shared-special.py'
	file2=dir_build+'/shared-'+name+'.py'
	text1='special'
	text2=name
	copy_file (file1, file2, text1, text2)
	change_text(file2, 'NAME_SPECIAL', name_full)
	
	file1=dir_build+'/shared-regular.sh'
	file2=dir_build+'/shared-'+name+'.sh'
	text1 = 'exit 0'
	text2 = 'python $DIR_DEVELOP/1-build/shared-'+name+'.py\n\n'
	text2 = text2 + text1
	copy_file (file1, file2, text1, text2)
	
	file1=dir_build+'/desktop-regular.sh'
	file2=dir_build+'/desktop-'+name+'.sh'
	text1='regular'
	text2=name
	copy_file (file1, file2, text1, text2)
	
	file1=dir_build+'/build-regular.sh'
	file2=dir_build+'/build-'+name+'.sh'
	text1='remaster-regular.sh'
	text2='remaster-'+name+'.sh'
	copy_file (file1, file2, text1, text2)
	change_text (file2, 'preinstall-regular.sh', 'preinstall-'+name+'.sh')
	
	file1=dir_build+'/remaster-regular.sh'
	file2=dir_build+'/remaster-'+name+'.sh'
	text1='shared-regular.sh'
	text2='shared-'+name+'.sh'
	copy_file (file1, file2, text1, text2)
	
copy_file_1build ('taylorswift', 'Taylor Swift Linux')
copy_file_1build ('minnesota', 'Minnesota Swift Linux')
copy_file_1build ('chicago', 'Chicago Swift Linux')


