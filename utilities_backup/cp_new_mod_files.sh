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
    local not_to_cp_filename="$5"
    local r=$6
    local regex="$7"
    local not_to_cp_files=("${@:8}")

    for item in "${SRC}"/*;do

        item=$(realpath -m "${item}")
        
        if [[ $b == 1 ]]; then

            contains_element "${item}" "${not_to_cp_files[@]}"
            
            if [[ $? == 0 ]]; then
            
                continue
            
            fi
            
        fi

        if [[ -d "${item}" ]]; then

            cp_dir "${item}" "${DST}" $c $b "${not_to_cp_filename}" $r "${regex}" "${not_to_cp_files[@]}"

        elif [[ -f "${item}"  ]]; then

            # check if item matches regex
            if [[ $r == 1 && ! "$(basename "$item")" =~ ${regex} ]]; then

                continue

            fi

            cp_file "${item}" "${DST}" $c
                        
        fi

    done

}
