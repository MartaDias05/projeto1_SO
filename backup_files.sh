#!/bin/bash

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



# function to calculate copied files and their size
copy_file() {
    local file=$1
    local dest=$2
    cp -a "$file" "$dest"
    copied=$(($copied + 1))
    echo $copied
    size_copied=$(($size_copied + $(stat -c%s "$file")))
}



# funtcion to remove the files in the backup that are not in SRC
remove_deleted_files() {
    for file in "${files_in_dst[@]}"; do
        src_file="${SRC}/$(basename "$file")"

        if ! [[ -f "${src_file}" ]]; then
            deleted=$(($deleted + 1))
            size_deleted=$(($size_deleted + $(stat -c%s "$file")))
        fi 
    done
}



# function to compare modification dates
compare_modification_dates() {
    local src_file=$1
    local dst_file=$2

    src_mod_times=$(stat -c%Y "$src_file")
    dst_mod_times=$(stat -c%Y "$dst_file")

    if [["$dst_mod_times" -gt "$src_mod_times"]]; then
        warnings=$(($warnings + 1))
    fi
}



#if c was passed in as a flag then simulate the backup
if (( ${checking} == 1 )); then
    #simulate the backup
    if ((${first_run} == 1)); then
        echo "here"
        find "${SRC}" -type f | while read file; do
    
            pathname_original_file="${SRC}/${file}"
            pathname_copied_file="${DST}/$(basename "${file}")"

            copy_file "$file" "$pathname_copied_file"
        done 
        echo $copied
    else

        #compare both directories and find anomalies

        # creates arrays that store the files of each directory (only files, not directories)
        files_in_src=($(find "${SRC}" -type f))
        files_in_dst=($(find "${DST}" -type f))


        for file in "${files_in_src[@]}"; do
            dst_file="${DST}/$(basename "$file")"

            # verify if the files exists on DST
            if [[ -f "${dst_file}" ]]; then

                compare_modification_dates "$file" "$dst_file"
            fi
        done


        # checks if there are files in backup that are not in SRC and remove them
        remove_deleted_files
    fi
fi

echo "While backuping ${DST}: $errors Erros; $warnings Warnings; $updated Updated; $copied Copied ($size_copied); $deleted Deleted ($size_deleted)"


# if c was not passed in as a flag, do the actual backup
if(( ${checking} == 0)); then
    
    # actual backup
    if ((${first_run} == 1)); then

        # copy all the files in SRC to DST
        find "${SRC}" -type f | while read file; do

            pathname_original_file="${DST}/${file}"
            pathname_copied_file="${DST}/$(basename "$file")"

            copy_file "$file" "$pathname_copied_file"
        done

    else

        # copy new files or changed files
        files_in_src=($(find "${SRC}" -type f))

        for file in "${files_in_scr[@]}"; do
            dst_file=($(find "${DST}" -type f))

            src_mod_times=$(stat -c%Y "$file")
            dst_mod_times=$(stat -c%Y "$dst_file")

            if [[ ! -f "$dst_file" || "$src_mod_times" -gt "$dst_mod_times" ]]; then
                copy_file "$file" "$dst_file"
            fi
        done

        # checks if there are files in backup that are not in SRC and remove them
        remove_deleted_files
    fi
fi

echo "While backuping ${DST}: $errors Erros; $warnings Warnings; $updated Updated; $copied Copied ($size_copied); $deleted Deleted ($size_deleted)"

