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
	
def copy_file_1build (name_sp):
	file1=dir_build+'/preinstall-regular.sh'
	file2=dir_build+'/preinstall-'+name_sp+'.sh'
	text1='rm -r /tmp/ssh*'
	text2='get_rep sound-'+name_sp+'\n'
	text2=text2+'get_rep wallpaper-'+name_sp+'\n'
	text2=text2+text1
	copy_file (file1, file2, text1, text2)
	
	file1=dir_build+'/desktop-regular.sh'
	file2=dir_build+'/desktop-'+name_sp+'.sh'
	text1='regular'
	text2=name_sp
	copy_file (file1, file2, text1, text2)
	
	file1=dir_build+'/remaster-regular.sh'
	file2=dir_build+'/remaster-'+name_sp+'.sh'
	text1='regular'
	text2=name_sp
	copy_file (file1, file2, text1, text2)
	
#def copy_file_shared (name_sp, name_sp_long):
	

copy_file_1build ('taylorswift')
copy_file_1build ('minnesota')
copy_file_1build ('chicago')

	# FOR shared-xxx: have shared-special.sh file, use copy_file to change
	
	#file1=dir_build+'/shared-regular.sh'
	#file2=dir_build+'/shared-'+name_sp+'.sh'
	#text1='sh $DIR_DEVELOP/1-build/remove_deb.sh'
	#text2=text1
	# Copy sound
	# Copy wallpaper
	# Change Conky
	# Change IceWM
	# Change ROX
