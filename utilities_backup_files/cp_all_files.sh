#!/bin/bash

# this script holds a function responsible for the copy of all files in a given directory SRC
# to another directory DST

# this function takes in as parameters: 
# SRC
# DST
# value of flag -c (0 or 1)

cp_all_files() 
{
    local SRC=$1
    local DST=$2
    local c=$3

    find "${SRC}" -maxdepth 1 -type f | while read file; do
        pathname_original_file="${SRC}/$(basename "${file}")"
        pathname_copied_file="${DST}/$(basename "${file}")"

        echo "cp -a ${pathname_original_file} ${pathname_copied_file}"

        if [[ ${c} == 0 ]]; then
            cp -a ${pathname_original_file} ${pathname_copied_file}
        fi

    done 
}