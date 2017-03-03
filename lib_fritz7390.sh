#!/usr/bin/env bash

#  File:    lib_fritz7390.sh
#  Model:   FRITZ!Box 7390
#  author:  Michael Dinkelaker,
#           michael[dot]dinkelaker[at]gmail[dot]com
#  date:    2016-06-04

# this lib should work for the older 7390 box
# untested


function login() {
    #  check if environment variables are setup correctly
    if [[ -z $_FBOX ]] || [[ -z $_PASSWORD ]]; then
      echo "Error: make sure VARS _FBOX, _PASSWORD are set!!!"
      exit 1
    fi

    get_challenge
    get_md5
    # assemble challenge key and md5
    _RESPONSE=${_CHALLENGE}"-"${_MD5}
    get_sid
}

# get configuration from FritzBox and write to STDOUT
# argument 1: export password
function export_settings() {
    local _EXPORT_PASSWORD=$1
    if [[ -z $_EXPORT_PASSWORD ]]; then
      echo "Error: EXPORT_PASSWORD is empty!!!"
      exit 1
    fi

    curl -s \
         -k \
         --form 'sid='${_SID} \
         --form 'ImportExportPassword='${_EXPORT_PASSWORD} \
         --form 'ConfigExport=' \
         ${_FBOX}/cgi-bin/firmwarecfg
}

# get phonebook from FritzBox and write to STDOUT
# argument 1: PhoneBookId
# argument 2: PhoneBookExportName
function export_phonebook() {
    local _PhoneBookId=$1
    local _PhoneBookExportName=$2
    local isnum='^[0-9]+$'
    if [[ -z $_PhoneBookExportName ]] || ! [[ $_PhoneBookId =~ $isnum ]]; then
      echo "Error: PhoneBookExportName is empty or PhoneBookId isn't a number!!!"
      exit 1
    fi

    curl -s \
         -k \
         --form 'sid='${_SID} \
         --form 'PhonebookId='${_PhoneBookId} \
         --form 'PhonebookExportName='${_PhoneBookExportName} \
         --form 'PhonebookExport=' \
         ${_FBOX}/cgi-bin/firmwarecfg

}

########################################################################################################################
#  authentication helpers

 # get challenge key
function get_challenge() {
    _CHALLENGE=$(curl -s \
                      -k \
                      "${_FBOX}/login.lua" | \
              grep "^g_challenge" | \
              awk -F'"' '{ print $2 }')
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
                -d 'page=' \
                -d 'username='${_USERNAME} \
                ${_FBOX}/login.lua | \
            grep "Location:" | \
            awk -F'=' {' print $NF '})
}
########################################################################################################################
