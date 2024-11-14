#!/bin/bash

# this script holds a function responsible for a copy of a directory, recursively

# this function takes in as parameters: 
# item
# DST
# value of flag -c (0 or 1)
# value of flag -b (0 or 1)
# b_files_arr -> array with the files that are not to be copied
# b_filename -> path to the file that contains the files not to be copied
# value of flag -r (0 or 1)
# regex -> regex pattern to be respected

cp_dir()
{
    local item="$1"
    local DST="$2"
    local c="$3"
    local b="$4"
    local b_files_arr="$5"
    local b_filename="$6"
    local r="$7"
    local regex="$8"

    new_dst="${DST}/$(basename "${item}")"

    if [[ -d "${new_dst}" ]]; then # if directory exists then go into it and check its files
                    
        cp_new_mod_files "${item}" "${new_dst}" $c $b "${b_files_arr[@]}" "${b_filename}" $r "${regex}"


    else # if directory does not exist then create it and then go into it and check its files
                    
        echo "mkdir "${new_dst}""
                    
        if [[ $c == 0 ]]; then
                    
            mkdir "${new_dst}"
                    
        fi

        cp_new_mod_files "${item}" "${new_dst}" $c $b "${b_files_arr[@]}" "${b_filename}" $r "${regex}"

    fi 

}