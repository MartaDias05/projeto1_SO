#!/bin/bash

. ./utilities_backup_files/remove_deleted_files.sh
. ./utilities_backup_files/compare_modification_dates.sh
. ./utilities_backup_files/cp_all_files.sh
. ./utilities_backup_files/cp_new_mod_files.sh


checking=0
first_run=0 # holds if it is the first time the script is running or not - to check if we need to copy the whole directory or just update the files

#initialize the option variables with the correct values having in consideration the flag passed in
while getopts "c" opt; do

    case ${opt} in
    
        c)
            checking=1
            ;;
        * )
            echo "Invalid option. Options should only include: -c (checking); -b; -r."
            exit 1
            ;;

    esac

done

# OPTIND is a built-in variable that tracks the index 
# of the next argument to be processsed by getopts.
# access positional arguments using array expansion ${@:START:1} ->> https://web.archive.org/web/20130927000512/http://www.devhands.com/2010/01/handling-positional-and-non-positional-command-line-arguments-from-a-shell-script/
SRC=${@:OPTIND:1}
DST=${@:OPTIND+1:1}


#check if only 2 positional arguments were passed in
if [[ $(($# - OPTIND+1)) -ne 2 ]]; then
    echo "The program accepts 2 and only 2 positional arguments"
    exit 1
fi

#check if SRC and DST are valid paths
if ! [[ -d ${SRC} ]]; then

    echo "The path '${SRC}' is not a valid directory path."
    exit 1

fi

parent_dir=$(dirname "${DST}") # parent dir holds the path to the directory passed in a dst

if ! [[ -d ${parent_dir} ]]; then

    echo "The directory passed in for the destination of the backup is not valid!"
    exit 1

fi

# create DST if does not exist and parent path is valid
if ! [[ -d ${DST} ]]; then

    first_run=1  

    if ((${checking} == 0)); then
    
        mkdir ${DST}
        echo "mkdir ${DST}"

    else

        echo "mkdir ${DST}"
    
    fi

fi



#if c was passed in as a flag then simulate the backup
if (( ${checking} == 1 )); then
    if ((${first_run} == 1)); then
        cp_all_files "${SRC}" "${DST}" ${checking}
    else
        cp_new_mod_files "${SRC}" "${DST}" ${checking}
        remove_deleted_files "${DST}" "${SRC}" ${checking}
    fi

else # if c was not passed in as a flag, do the actual backup
    
    if ((${first_run} == 1)); then
        cp_all_files "${SRC}" "${DST}" ${checking}
    else
        cp_new_mod_files "${SRC}" "${DST}" ${checking}
        remove_deleted_files "${DST}" "${SRC}" ${checking} 
    fi

fi


