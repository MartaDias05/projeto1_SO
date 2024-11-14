#!/bin/bash

# this script holds a function responsible for removing any files in DST directory 
# that are not present in the SRC directory

# this function takes in as parameters:
# SRC
# DST
# value of flag -c (0 or 1)


remove_deleted_files() {

    local DST=$1
    local SRC=$2
    local c=$3

    find "${DST}" -maxdepth 1 -type f | while read file; do
        src_file="${SRC}/$(basename "${file}")"
        if ! [[ -f "${src_file}" ]]; then
            #deleted=$(($deleted + 1))
            #size_deleted=$(($size_deleted + $(stat -c%s "$file")))
            if [[ ${c} == 0 ]]; then
                rm "${DST}/$(basename "${file}")"
                echo "rm ${DST}/$(basename "${file}")"
            else
                echo "rm $file"
            fi
        fi 
    done
}