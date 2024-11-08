#!/bin/bash

# this script holds a function responsible for the copy of files that are present in SRC
# but not in DST, or the files that were modified in SRC

# this function takes in as parameters: 
# SRC
# DST
# value of flag -c (0 or 1)


cp_new_mod_files()
{
    local SRC=$1
    local DST=$2
    local c=$3

    find "${SRC}" -maxdepth 1 -type f | while read file; do
        pathname_copied_file="${DST}/$(basename "${file}")"

        # verify if the files exists on DST
        if [[ -f "${pathname_copied_file}" ]]; then
            compare_modification_dates "${file}" "${pathname_copied_file}" "${c}"
        else
            # if file is not in DST then copy it
            echo "cp -a ${file} ${pathname_copied_file}"
            if [[ ${c} == 0 ]]; then
                cp -a ${file} ${pathname_copied_file}
            fi
        fi
    done
}