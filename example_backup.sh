#!/usr/bin/env bash

##
#  An example how to use lib_fritz7490
#  adjust vars _FBOX, _USERNAME, _PASSWORD, DESTINATION 
#  and the export name of the Phonebook xml in lines 28,29
#  to backup your FRITZ!Box settings, phonebook/s and phone assets.
##

#  File:    example_backup.sh
#  author:  Michael Dinkelaker,
#           michael[dot]dinkelaker[at]gmail[dot]com
#  date:    2016-06-03 creation
#           2020-10-05 updated for Fritz!Os 7.21 
#           2021-06-20 updated for Fritz!Os 7.27


_FBOX="http://192.178.0.1"
_USERNAME="fritz12345"
_PASSWORD="secret"
_EXPORT_PASSWORD="same_or_another_secret"
ROTATE_PERIOD=180
DESTINATION="/rainbow/unicorn/FritzBox/"

source ./lib_fritz7490.sh
login
export_settings ${_EXPORT_PASSWORD} >${DESTINATION}/$(date +%Y-%m-%d)_fritzbox_settings.export
export_phoneassets ${_EXPORT_PASSWORD} >${DESTINATION}/$(date +%Y-%m-%d)_fritzbox_phone.assets.zip
export_phonebook 0 Phonebook >${DESTINATION}/$(date +%Y-%m-%d)_fritzbox_phonebook.xml
#export_phonebook 1 Work >${DESTINATION}/$(date +%Y-%m-%d)_fritzbox_phonebook_work.xml

# delete files older than ${ROTATE_PERIOD} days. uncomment to use
#find ${DESTINATION} -mtime +${ROTATE_PERIOD} -exec rm {} \;
