#!/bin/bash
# Menu with options - jnixon 8-18-2015
. /Users/RomeyRome/Documents/Scripts/functions


option () {

  echo  "${RED}#######################################"
  echo  "${RED}#######        MENU             #######"
  echo  "${RED}#######################################\n"


PS3='Please enter your choice:'
options=("Check Disk Space" "Check Process" "Clear Screen" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Check Disk Space")
        Menu ;;

        "Check Process")
         Menu2 ;;

         "Clear Screen")
          Clear ;;

        "Quit")

            break;;

        *) echo invalid option;;
    esac
done
}
option
