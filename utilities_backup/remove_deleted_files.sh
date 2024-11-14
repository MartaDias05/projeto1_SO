#!/bin/bash

# this script holds a function responsible for removing any files in DST directory 
# that are not present in the SRC directory. Additionally, this function supports 
# subdirectories.

# this function takes in as parameters:
# SRC
# DST
# value of flag -c (0 or 1)


remove_deleted_files() {

    local DST=$1
    local SRC=$2
    local c=$3

    find "${DST}" -mindepth 1 -maxdepth 1 | while read item; do

        if [[ -d "${item}" ]]; then

            dir_name_in_src="$SRC/$(basename "$item")"

            # check if directory appears in src
            if ! [[ -d "${dir_name_in_src}" ]]; then

                # if not -> delete;
                echo "rm -r ${item}"

                if [[ $c == 0 ]]; then

                    rm -r "${item}"

                fi

            else

                # if so -> call recursively
                remove_deleted_files "${item}" "${dir_name_in_src}" $c
            
            fi

        elif [[ -f "${item}" ]]; then

            file_name_in_src="${SRC}/$(basename "${item}")"

            if ! [[ -f "${file_name_in_src}" ]]; then
                #deleted=$(($deleted + 1))
                #size_deleted=$(($size_deleted + $(stat -c%s "$file")))
               
                echo "rm ${DST}/$(basename "${item}")"

                if [[ ${c} == 0 ]]; then

                    rm "${DST}/$(basename "${item}")"
                
                fi
            fi 

        fi

    done
}