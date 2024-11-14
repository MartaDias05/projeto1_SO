#!/bin/bash

# this script holds a function responsible for the copy of files that are present in SRC
# but not in DST, or the files that were modified in SRC. Additionaly, it has the ability
# of dealing with subdirectories

# this function takes in as parameters: 
# SRC
# DST
# value of flag -c (0 or 1)
# value of flag -b (0 or 1)
# b_files_arr -> array with the files that are not to be copied
# b_filename -> path to the file that contains the files not to be copied
# value of flag -r (0 or 1)
# regex -> regex pattern to be respected

cp_new_mod_files()
{
    local SRC=$1
    local DST=$2
    local c=$3
    local b=$4
    local b_files_arr="$5"
    local b_filename="$6"
    local r=$7
    local regex="$8"

    for item in "${SRC}"/*;do
        
        if [[ $b == 1 ]]; then

            contains_element "${item}" "${b_files_arr[@]}"
            
            if [[ $? -eq 1 ]]; then
            
                continue
            
            fi
            
        fi

        if [[ -d "${item}" ]]; then

            cp_dir "${item}" "${DST}" $c $b "${b_files_arr[@]}" "${b_filename}" $r "${regex}"

        elif [[ -f "${item}"  ]]; then

            # check if item matches regex
            if [[ $r == 1 && ! "$(basename "$item")" =~ ${regex} ]]; then

                continue

            fi

            cp_file "${item}" "${DST}" $c
                        
        fi

    done

}
