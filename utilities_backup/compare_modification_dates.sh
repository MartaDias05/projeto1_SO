#!/bin/bash

# this script holds a function responsible for comparing 2 modification dates, one from the file in SRC
# and the other from its previous copied file in DST

#the function takes in as parameters:
# src_file -> the file in the SRC directory
# dst_file -> the previous copy made of "src_file" to DST directory
# c -> the value of flag c (0 or 1);


compare_modification_dates() 
{
    local src_file=$1
    local dst_file=$2
    local c=$3

    src_file_time=$(stat -c %Y "$src_file") || ((errors++))
    dst_file_time=$(stat -c %Y "$dst_file") || ((errors++))

    if [[ "$dst_file_time" -gt "$src_file_time" ]]; then

        ((warnings++))
        echo "WARNING: backup entry "${dst_file}" is newer than "${src_file}"; Should not happen"
    
    elif [[ "$dst_file_time" -lt "$src_file_time" ]]; then
    
        echo "cp -a "${src_file}" "${dst_file}""
    
        if [[ $c == 0 ]]; then
    
            cp -a "${src_file}" "${dst_file}"

            ((updated++))
    
        fi
    
    fi
}