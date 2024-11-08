#!/bin/bash

# function to compare modification dates
compare_modification_dates() {
    local src_file=$1
    local dst_file=$2
    local c=$3

    src_file_time=$(stat -c %Y "$src_file")
    dst_file_time=$(stat -c %Y "$dst_file")

    if [[ "$dst_file_time" -gt "$src_file_time" ]]; then
        #warnings=$(($warnings + 1))
        echo "warning should come up here"
    elif [[ "$dst_file_time" -lt "$src_file_time" ]]; then
        if [[ $c == 0 ]]; then
            cp -a "${src_file}" "${dst_file}"
            echo "cp -a "${src_file}" "${dst_file}""
        else
            echo "cp -a "${src_file}" "${dst_file}""
        fi
    fi
}