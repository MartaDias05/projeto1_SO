#!/bin/bash

# this script holds a function responsible for the copy of all files in a given directory SRC
# to another directory DST. Additionaly it has the ability to deal with subdirectories

# this function takes in as parameters: 
# SRC
# DST
# value of flag -c (0 or 1)

cp_all_files() 
{
    local SRC=$1
    local DST=$2
    local c=$3


    find "${SRC}" -mindepth 1 -maxdepth 1 | while read item; do
        
        if [[ -d "${item}" ]]; then

            new_dst="${DST}/$(basename "${item}")"
            echo "mkdir "${new_dst}""

            if [[ $c == 0 ]]; then

                mkdir "${new_dst}"

            fi

            cp_all_files "${item}" "${new_dst}" $c

        elif [[ -f "${item}" ]]; then

            pathname_original_file="${SRC}/$(basename "${item}")"
            pathname_copied_file="${DST}/$(basename "${item}")"

            echo "cp -a ${pathname_original_file} ${pathname_copied_file}"

            if [[ ${c} == 0 ]]; then

                cp -a ${pathname_original_file} ${pathname_copied_file}
            
            fi

        fi

    done 
}