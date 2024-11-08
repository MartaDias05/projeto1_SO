#!/bin/bash

# funtcion to remove the files in the backup that are not in SRC
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