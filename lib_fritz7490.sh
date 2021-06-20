#!/usr/bin/env bash

#
#  Model:       FRITZ!Box 7490 (7590?)
#  Fritz!OS:    7.27
#  author:      Michael Dinkelaker,
#               michael[dot]dinkelaker[at]gmail[dot]com
#
#  version history:
#   0.1, 2016-06-03, first release
#   0.2, 2017-03-03, fix for Fritz!OS 6.80
#   0.3, 2020-10-05, fix for Fritz!OS 7.21
#   0.4, 2020-06-20, fix for Fritz!OS 7.27
#                    added export_phoneassets. Login needs a Username now.
#
#  example usage:
#      source lib_fritz7490.sh
#      _FBOX="http://192.178.0.1"
#      _PASSWORD="secret_fbox_login"
#      _EXPORT_PASSWORD="same_or_another_secret"
#      login
#      export_settings myExportPassword > /some/location/$(date +%Y-%m-%d)_fritz_settings.export
#      export_phoneassets myExportPassword > /some/location/$(date +%Y-%m-%d)_fritz_phone.assets.zip
#      export_phonebook 0 Telefonbuch > /some/location/$(date +%Y-%m-%d)_telefonbuch.xml
#      export_phonebook 1 Work > /some/location/$(date +%Y-%m-%d)_work.xml
#

function login() {
    #  check if environment variables are setup correctly
    if [[ -z ${_FBOX} ]] || [[ -z ${_PASSWORD} ]] || [[ -z ${_USERNAME} ]]; then
      echo "Error: make sure VARS _FBOX, _PASSWORD and _USERNAME are set!!!"
      exit 1
    fi

    get_challenge
    get_md5
    # assemble challenge key and md5
    _RESPONSE="${_CHALLENGE}"-"${_MD5}"
    get_sid
}

# get configuration from FritzBox and write to STDOUT
# argument 1: export password
function export_settings() {
    local _EXPORT_PASSWORD=$1
    if [[ -z ${_EXPORT_PASSWORD} ]]; then
      echo "Error: EXPORT_PASSWORD is empty!!!"
      exit 1
    fi

    curl -s \
         -k \
         -F 'sid='${_SID} \
         -F 'ImportExportPassword='${_EXPORT_PASSWORD} \
         -F 'ConfigExport=' \
       ${_FBOX}/cgi-bin/firmwarecfg
}

# get phone assets from FritzBox and write to STDOUT
# argument 1: export password
function export_phoneassets() {
    local _EXPORT_PASSWORD=$1
    if [[ -z ${_EXPORT_PASSWORD} ]]; then
      echo "Error: EXPORT_PASSWORD is empty!!!"
      exit 1
    fi

    curl -s \
         -k \
         -F 'sid='${_SID} \
         -F 'AssetsImportExportPassword='${_EXPORT_PASSWORD} \
         -F 'AssetsExport=' \
       ${_FBOX}/cgi-bin/firmwarecfg
}

# get phonebook from FritzBox and write to STDOUT
# argument 1: PhoneBookId
# argument 2: PhoneBookExportName
function export_phonebook() {
    local _PhoneBookId=$1
    local _PhoneBookExportName=$2
    local isnum='^[0-9]+$'
    if [[ -z ${_PhoneBookExportName} ]] || ! [[ ${_PhoneBookId} =~ ${isnum} ]]; then
      echo "Error: PhoneBookExportName is empty or PhoneBookId isn't a number!!!"
      exit 1
    fi

    curl -s \
         -k \
         -F 'sid='${_SID} \
         -F 'PhonebookId='${_PhoneBookId} \
         -F 'PhonebookExportName='${_PhoneBookExportName} \
         -F 'PhonebookExport=' \
         ${_FBOX}/cgi-bin/firmwarecfg

}

########################################################################################################################
#  authentication helpers

 # get challenge key
function get_challenge() {
    _CHALLENGE=$(curl -s \
                      -k \
                      ${_FBOX}/login_sid.lua | \
                 grep -Po '<Challenge>.*?</Challenge>' | \
                 sed 's/\(<Challenge>\|<\/Challenge>\)//g') 

    if [[ -z ${_CHALLENGE} ]]; then
      echo "ERROR: received empty challenge"
      exit 1
    fi
}

# build md5 from challenge key and password
function get_md5() {
    _MD5=$(echo -n \
        ${_CHALLENGE}"-"${_PASSWORD} | \
        iconv -f ISO8859-1 \
              -t UTF-16LE | \
        md5sum -b | \
        awk '{print substr($0,1,32)}')
}

function get_sid() {
    _SID=$(curl -i \
                -s \
                -k \
                -d 'response='${_RESPONSE} \
                -d 'username='${_USERNAME} \
                -d 'page=' \
                ${_FBOX}/login_sid.lua  | \
           grep -Po '<SID>.*?</SID>' | \
           sed 's/\(<SID>\|<\/SID>\)//g')


    if [[ "${_SID}" == "0000000000000000"} ]]; then
        echo "ERROR: got invalid sid!"
        exit 1
    fi
}
########################################################################################################################
