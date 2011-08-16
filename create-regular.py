#! /usr/bin/env python

import sys, commands # Allows checking for root
import os # Needed for removing files
import shutil # Needed for copying files

username = commands.getoutput( "whoami" )
if username == 'root':
	sys.exit( 'You must be non-root to run this script.' )

dir_develop='/home/'+username+'/develop'
dir_build=dir_develop+'/1-build'

def change_text (filename, text_old, text_new):
	text=open(filename, 'r').read()
	text = text.replace(text_old, text_new) 
	open(filename, "w").write(text)
	
def copy_file (file_old, file_new, text_old, text_new):
	os.remove (file_new)
	shutil.copy2 (file_old, file_new)
	change_text(file_new, text_old, text_new)
	
file_diet = dir_build+'/build-diet.sh'
file_regular = dir_build+'/build-regular.sh'
copy_file (file_diet, file_regular, 'diet', 'regular')
	
file_diet = dir_build+'/desktop-diet.sh'
file_regular = dir_build+'/desktop-regular.sh'
copy_file (file_diet, file_regular, 'diet', 'regular')

file_diet = dir_build+'/remaster-diet.sh'
file_regular = dir_build+'/remaster-regular.sh'
copy_file (file_diet, file_regular, 'diet', 'regular')

file_diet = dir_build+'/preinstall-diet.sh'
file_regular = dir_build+'/preinstall-regular.sh'
text1 = 'rm -r /tmp/ssh'
text2 = '# Get repositories for Regular Swift Linux\n'
text2 = text2 + 'get_rep regular\n'
text2 = text2 + 'get_rep forensic\n\n'
text2 = text2 + text1
copy_file (file_diet, file_regular, text1, text2)

