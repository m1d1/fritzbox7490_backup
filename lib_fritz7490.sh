#!/usr/bin/env bash


#  Model:   FRITZ!Box 7490
#  OS:      06.80
#  author:  Michael Dinkelaker,
#           michael[dot]dinkelaker[at]gmail[dot]com
#  date:    0.1, 2016-06-03 first release
#           0.2, 2017-03-03 fix for firmware 6.80


#  usage:
#           source lib_fritz7490.sh
#           _FBOX="http://192.178.0.1"
#           _PASSWORD="secret_fbox_login"
#           login
#           export_settings myExportPassword > /some/location/$(date +%Y-%m-%d)_fritz_settings.cfg
#           export_phonebook 0 Telefonbuch > /some/location/$(date +%Y-%m-%d)_telefonbuch.xml
#           export_phonebook 1 Work > /some/location/$(date +%Y-%m-%d)_work.xml


function login() {
    #  check if environment variables are setup correctly
    if [[ -z $_FBOX ]] || [[ -z $_PASSWORD ]]; then
      echo "Error: make sure VARS _FBOX, _PASSWORD are set!!!"
      exit 1
    fi

    get_challenge
    get_md5
    # assemble challenge key and md5
    _RESPONSE="$_CHALLENGE"-"$_MD5"
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
         -F 'sid='$_SID \
         -F 'ImportExportPassword='$_EXPORT_PASSWORD \
         -F 'ConfigExport=' \
       $_FBOX/cgi-bin/firmwarecfg
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
         -F 'sid='$_SID \
         -F 'PhonebookId='$_PhoneBookId \
         -F 'PhonebookExportName='$_PhoneBookExportName \
         -F 'PhonebookExport=' \
         $_FBOX/cgi-bin/firmwarecfg

}

########################################################################################################################
#  authentication helpers

 # get challenge key
function get_challenge() {
    _CHALLENGE=$(curl -s \
                      -k \
                      "$_FBOX" | \
                 grep -Po '(?<="challenge":")[^"]*')
}

# build md5 from challenge key and password
function get_md5() {
    _MD5=$(echo -n \
        $_CHALLENGE"-"$_PASSWORD | \
        iconv -f ISO8859-1 \
              -t UTF-16LE | \
        md5sum -b | \
        awk '{print substr($0,1,32)}')
}

function get_sid() {
    _SID=$(curl -i \
                -s \
                -k \
                -d 'response='$_RESPONSE \
                -d 'page=' \
                -d 'username='$_USERNAME \
                $_FBOX | \
             grep -Po '(?<="sid":")[^"]*')
}
########################################################################################################################
