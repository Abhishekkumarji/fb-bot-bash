#!/bin/bash
#
# Facebook command line status update bot v1.0
# Author: Luka Pusic <pusic93@gmail.com>
#
email="email@domain.com"
pass="your_password"
status="yay" #must be less than 420 chars

touch "cookie.txt" #create a temp. cookie file
loginpage=`curl -s -c ./cookie.txt -A "Mozilla/5.0" "http://m.facebook.com"` #initial cookies

#LOGIN PARAMETERS
form_action=`echo "$loginpage" | tr '"' "\n" | grep "https://www.facebook.com/login.php"`
form_data=`echo "$loginpage" | sed -e 's/.*<form//' | sed -e 's/form>.*//' | tr '/>' "\n" | grep 'input ' | grep -v "email\|pass"`

#FUNCTION PARSES FORM DATA
function parse_form() {
    form_data="$1"
    params=""
        for (( i=1; i <= `echo "$form_data" | wc -l` ; i++ ))
            do
                name=`echo "$form_data" | sed -n "$i"p | tr ' ' "\n" | grep 'name' | cut -d '"' -f 2`
                value=`echo "$form_data" | sed -n "$i"p | tr ' ' "\n" | grep 'value' | cut -d '"' -f 2`
                params="$params$name=$value&"
            done
         echo "$params"
}

#LOGIN
params="email=$email&pass=$pass&"`parse_form "$form_data"`
logged_in=`curl -s -b ./cookie.txt -c ./cookie.txt -A "Mozilla/5.0" -d "$params" -L "$form_action"`
homepage=`curl -s -b ./cookie.txt -c ./cookie.txt -A "Mozilla/5.0" -L "http://m.facebook.com/profile.php"`

#UPDATE STATUS
status_form=`echo "$homepage" | sed -e 's/.*<form id="composer_form//' | sed -e 's/textarea>.*//' | tr '/>' "\n" | grep 'input ' | grep 'name' | grep -v 'query' | grep -v 'status'`
status_action=`echo "$homepage" | tr '"' "\n" | grep "/a/home.php?refid="`
status_params=`parse_form "$status_form"`"status=$status&update=Share"
update=`curl -s -b ./cookie.txt -c ./cookie.txt -A "Mozilla/5.0" -d "$status_params" -L "http://m.facebook.com$status_action"`
#$callback=`echo "$update" | grep "$status"` #just a primitive example of success checking

#LOGOUT
logout_link=`echo "$update" | tr '"' "\n" | grep "/logout.php?"`
logout=`curl -s -b ./cookie.txt -c ./cookie.txt -A "Mozilla/5.0" -L "http://m.facebook.com$logout_link"`

rm "cookie.txt" #remove cookie file
