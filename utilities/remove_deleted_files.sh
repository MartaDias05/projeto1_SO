#!/bin/bash

# funtcion to remove the files in the backup that are not in SRC
DST=$1
SRC=$2
c=$3


remove_deleted_files() {

    echo ${files_in_dst}

    for file in "${files_in_dst}"; do   
        src_file="${SRC}/$(basename "$file")"
        if ! [[ -f "${src_file}" ]]; then
            deleted=$(($deleted + 1))
            size_deleted=$(($size_deleted + $(stat -c%s "$file")))
            if [[ ${c} == 0 ]]; then
                rm $file
                echo "rm $file"
            else
                echo "rm $file"
            fi
        fi 
    done
}