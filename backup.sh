#!/bin/bash

. ./utilities_backup/remove_deleted_files.sh
. ./utilities_backup_files/compare_modification_dates.sh
. ./utilities_backup/cp_all_files.sh
. ./utilities_backup/cp_new_mod_files.sh
. ./utilities_backup/contains_element.sh
. ./utilities_backup/cp_dir.sh
. ./utilities_backup/cp_file.sh
. ./utilities_backup/backup_function.sh

# init variables so they're always passed in the functions
regex="${regex:-"some regex"}"
not_to_cp_filename="${not_to_cp_filename:-"some file name"}"
c=0
r=0
b=0
first_run=0


OPTSTRING=":cr:b:"

declare -a not_to_cp_files
declare -a matched_regex_files

# inintialize the arrays so they're always passed in as arguments in function calls
not_to_cp_files=("${not_to_cp_files[@]:-" "}")
matched_regex_files=("${matched_regex_files[@]:-" "}")

# checks if -c, -r and -b were passed as flags
while getopts ${OPTSTRING} opt; do

    case ${opt} in
        c)
            c=1
            ;;
        
        r)
            regex="${OPTARG}"
            r=1
            matched_regex_files=() # clears the array from the initialized value
            ;;
        b)
            # check if the file passed in as argument is a valid file
            if ! [[ -f "${OPTARG}" ]]; then
               echo "${OPTARG} file does not exist!"
               echo "Usage: ./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
               exit 1
            fi

            SRC=${@:OPTIND:1}

            b=1
            not_to_cp_filename="${OPTARG}"
            not_to_cp_files=()

            # read the file and add each not to copy file to the array
            while read -r LINE; do
                # append files to not_to_cp_files;
                not_to_cp_files+=($(realpath -m "${SRC}/${LINE}"))
            done < "${OPTARG}"
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            echo "Usage: ./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
            exit 1
            ;;
        
        ?)
            echo "Invalid option. Options should only include: -c; -b; -r"
            echo "Usage: ./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
            exit 1
            ;;
    esac

done

SRC=${@:OPTIND:1}
DST=${@:OPTIND+1:1}

# only validate if this is the initial call of backup.sh
if [[ -z "${BACKUP_INIT_CALL}" ]]; then

    export BACKUP_INIT_CALL=1

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

        if ((${c} == 0)); then
        
            mkdir ${DST}
            echo "mkdir ${DST}"

        else

            echo "mkdir ${DST}"
        
        fi
    
    fi

fi

backup_function "${SRC}" "${DST}" $c $b "${not_to_cp_filename}" $r "${regex}" ${first_run} "${not_to_cp_files[@]}"