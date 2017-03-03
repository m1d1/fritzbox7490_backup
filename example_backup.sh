#!/usr/bin/env bash

##
#  An example how to use lib_fritz7490 (or lib_fritz7390)
#  adjust vars _FBOX, _PASSWORD, DESTINATION 
#  and the export name of the Phonebook in line 26
#  to backup your FRITZ!Box settings and phonebook.
##

#  File:    example_backup.sh
#  author:  Michael Dinkelaker,
#           michael[dot]dinkelaker[at]gmail[dot]com
#  date:    2016-06-03


_FBOX="http://192.178.0.1"
_PASSWORD="secret"
_EXPORT_PASSWORD="same_or_another_secret"
ROTATE_PERIOD=180
DESTINATION="/rainbow/unicorn/FritzBox/"

source ./lib_fritz7490.sh
#source ./lib_fritz7390.sh
login
export_settings $_EXPORT_PASSWORD >$DESTINATION/$(date +%Y-%m-%d)_fritzbox_settings.cfg
export_phonebook 0 Phonebook >$DESTINATION/$(date +%Y-%m-%d)_fritzbox_phonebook.xml
#export_phonebook 1 Work >$DESTINATION/$(date +%Y-%m-%d)_fritzbox_phonebook_work.xml

# delete files older than $ROTATE_PERIOD days 
find $DESTINATION -mtime +$ROTATE_PERIOD -exec rm {} \;
