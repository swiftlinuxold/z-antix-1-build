#! /usr/bin/env python

import sys, commands # Allows checking for root
import os # Needed for removing files
import shutil # Needed for copying files

whoami = commands.getoutput( "whoami" )
if whoami != 'root':
	sys.exit( 'You must be root to run this script.' )

is_chroot = os.path.exists('/srv')
dir_develop=''

if (is_chroot):
	dir_develop='/usr/local/bin/develop'	
else:
	username=commands.getoutput("logname")
	dir_develop='/home/'+username+'/develop'
	
print '***********************************************************************'
print 'CREATING Taylor Swift Linux\n'
print 'Copying files'
	
# Copying ROX wallpaper to /usr/share/wallpaper/
jpg1 = dir_develop + '/wallpaper-taylorswift/rox-taylorswift.jpg'
jpg2 = '/usr/share/wallpaper/'
shutil.copy2 (jpg1, jpg2)

# Copying ROX wallpaper to /home/username/Wallpaper
if (not(is_chroot)):
	jpg1 = 	dir_develop + '/wallpaper-taylorswift/rox-taylorswift.jpg'
	jpg2 = '/home/'+username+'/Wallpaper'
	shutil.copy2 (jpg1, jpg2)
	
# Copying SLiM wallpaper to /usr/share/slim/themes/antiX/
jpg1 = dir_develop + '/wallpaper-taylorswift/login-taylorswift.jpg'
jpg2 = '/usr/share/slim/themes/antiX/background.jpg'
shutil.copy2 (jpg1, jpg2)

# Copying sound clip to /usr/share/sounds
s1 = dir_develop + '/sound-taylorswift/sound-taylorswift.mp3'
s2 = '/usr/share/sounds'
shutil.copy2 (s1, s2)

print 'Changing Conky'
if (not(is_chroot)):
    text=open('/home/'+username+'/.conkyrc', 'r').read()
    text = text.replace('Regular Swift Linux', 'Taylor Swift Linux') 
    open('/home/'+username+'/.conkyrc', "w").write(text)

text=open('/etc/skel/.conkyrc', 'r').read()
text = text.replace('Regular Swift Linux', 'Taylor Swift Linux') 
open('/etc/skel/.conkyrc', "w").write(text)

print 'Changing ROX'
def change_text (pathdir):
	file_pb=pathdir+'/pb_antiX-ice'
	text=open(file_pb, 'r').read()
	text_old='rox-swiftlinux.jpg'
	text_new='rox-taylorswift.jpg'
	text=text.replace(text_old, text_new)
	open (file_pb, 'w').write(text)

if (not(is_chroot)):
	change_text('/home/'+username+'/.config/rox.sourceforge.net/ROX-Filer')
change_text('/etc/skel/.config/rox.sourceforge.net/ROX-Filer')
if (is_chroot):
	change_text('/usr/share/antiX-install/icewm')

print 'Changing IceWM'
if (not(is_chroot)):
    text=open('/home/'+username+'/.icewm/startup', 'r').read()
    text_old='rox --pinboard=antiX-ice &'
    text_new=text_old+'\n\n'
    text_new=text_new+'# Play startup sound clip\n'
    text_new=text_new+'mpg123 /usr/share/sounds/sound-taylorswift.mp3\n\n'
    
    text = text.replace(text_old, text_new) 
    open('/home/'+username+'/.icewm/startup', "w").write(text)


text=open('/etc/skel/.icewm/startup', 'r').read()
text_old='rox --pinboard=antiX-ice &'
text_new=text_old+'\n\n'
text_new=text_new+'# Play startup sound clip\n'
text_new=text_new+'mpg123 /usr/share/sounds/sound-taylorswift.mp3\n\n'

text = text.replace(text_old, text_new) 
	

