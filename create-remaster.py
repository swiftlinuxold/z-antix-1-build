#! /usr/bin/env python

import os # allows interaction with the operating system
import getpass # allows the username to be obtained
import os.path # allows you to determine if a directory exists

username=os.environ['XAUTHORITY']
username=username[6:-12]
dir_develop='/home/'+username+'/develop'

diet1=dir_develop+'/1-build/remaster-diet.sh'

def change_remaster(edition):
	path=dir_develop+'/1-build/remaster-'+edition+'.sh'
	if os.path.isfile(path):
		os.remove (path)
	text = open(diet1, 'r').read()
	text = text.replace ('diet', edition)
	open (path, 'w').write(text)

change_remaster ('regular')
change_remaster ('taylorswift')
change_remaster ('minnesota')
change_remaster ('chicago')
