#!/bin/bash

# REDO THE FUNCTIONS TO SUPPORT SUB-DIRECTORIES
. ./utilities_backup/remove_deleted_files.sh
. ./utilities_backup/compare_modification_dates.sh
. ./utilities_backup/cp_all_files.sh
. ./utilities_backup/cp_new_mod_files.sh

regex=''
checking=0
r=0
b=0
first_run=0
OPTSTRING=":cr:b:"

declare -a not_to_copy_files

# checks if -r and -b were passed as flags
while getopts ${OPTSTRING} opt; do

    case ${opt} in
        c)
            checking=1
            ;;
        
        r)
            regex="${OPTARG}"
            r=1
            ;;
        b)
            # check if the file passed in as argument is a valid file
            if ! [[ -f "${OPTARG}" ]]; then
               echo "${OPTARG} file does not exist!"
               exit 1
            fi

            b=1

            # read the file and add each not to copy file to the array
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
            ;;
        
        ?)
            echo "Invalid option. Options should only include: -c (checking); -b tfile; -r regexpr."
            exit 1
            ;;
    esac

done

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

        # check if -r was triggered
        if [[ ${r} == 1 ]]; then
            
        else
            cp_all_files "${SRC}" "${DST}" ${checking}
        fi
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


# iterating througth src directory
for item in "$SRC"/*; do

    echo "${item}"

    if [[ -d ${item} ]]; then
        new_dst="${DST}/$(basename "$item")"
        mkdir -p "$new_dst"

        $0 "${item}" "${new_dst}" # Script recursively spawns a new instance of itself


    # if -r was passed as a flag
    elif [[ -f ${item} ]]; then
        if [[ -n ${regex} ]]; then
            if [[ "$(basename "$item")" =~ $regex ]]; then
                cp -a "$item" "$DST"
            fi
        fi
    fi
done
