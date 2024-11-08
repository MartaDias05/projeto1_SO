#!/bin/bash

. ./utilities/remove_deleted_files.sh
. ./utilities/compare_modification_dates.sh


checking=0
first_run=0 # holds if it is the first time the script is running or not - to check if we need to copy the whole directory or just update the files

warnings=0
errors=0
updated=0
copied=0
size_copied=0
deleted=0
size_deleted=0

declare -a files_in_src # files_in_src will hold all of the files present in src directory
declare -a files_in_bck # holds all of the files present in backup directory

#initialize the option variables with the correct values having in consideration the flag passed in
while getopts "c" opt; do

    case ${opt} in
    
        c)
            checking=1
            ;;
        * )
            echo "Invalid option. Options should only include: -c (checking); -b; -r."
            exit 1

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
    #simulate the backup
    if ((${first_run} == 1)); then
        find "${SRC}" -maxdepth 1 -type f | while read file; do
            pathname_original_file="${SRC}/$(basename "${file}")"
            pathname_copied_file="${DST}/$(basename "${file}")"

            echo "cp -a ${pathname_original_file} ${pathname_copied_file}"
        done 
    else
        #compare both directories and find anomalies
        find "${SRC}" -maxdepth 1 -type f | while read file; do
            pathname_copied_file="${DST}/$(basename "${file}")"

            # verify if the files exists on DST
            if [[ -f "${pathname_copied_file}" ]]; then
                compare_modification_dates "${file}" "${pathname_copied_file}" "${checking}"
            else
                # if file is not in DST then copy it
                echo "cp -a ${file} ${pathname_copied_file}"
            fi
        done
        # checks if there are files in backup that are not in SRC and remove them
        remove_deleted_files "${DST}" "${SRC}" ${checking}
    fi


    #echo "While backuping ${DST}: $errors Erros; $warnings Warnings; $updated Updated; $copied Copied ($size_copied); $deleted Deleted ($size_deleted)"



else # if c was not passed in as a flag, do the actual backup
    
    if ((${first_run} == 1)); then

        # copy all the files in SRC to DST
        find "${SRC}" -maxdepth 1 -type f | while read file; do

            pathname_original_file="${SRC}/$(basename "$file")"
            pathname_copied_file="${DST}/$(basename "$file")"

            cp -a "${pathname_original_file}" "${pathname_copied_file}"
            echo "cp -a ${pathname_original_file} ${pathname_copied_file}"
        done

    else

        find "${SRC}" -maxdepth 1 -type f | while read file; do
            pathname_copied_file="${DST}/$(basename "${file}")"

            # verify if the files exists on DST
            if [[ -f "${pathname_copied_file}" ]]; then
                compare_modification_dates "${file}" "${pathname_copied_file}" "${checking}"
            else
                # if file is not in DST then copy it
                cp -a "${file}" "${pathname_copied_file}"
                echo "cp -a ${file} ${pathname_copied_file}"
            fi
        done
        # checks if there are files in backup that are not in SRC and remove them
        remove_deleted_files "${DST}" "${SRC}" ${checking} #files_in_dst is not being passed as an array -> solve this
    fi
fi

#echo "While backuping ${DST}: $errors Erros; $warnings Warnings; $updated Updated; $copied Copied ($size_copied); $deleted Deleted ($size_deleted)"

