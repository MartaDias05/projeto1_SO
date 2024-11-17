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
    local item

    # cp the files first;

    for item in "${SRC}"/*;do

        if [[ -f "${item}" ]]; then

            if [[ $b == 1 ]]; then

                contains_element "${item}" "${not_to_cp_files[@]}"
                
                if [[ $? == 0 ]]; then
                
                    continue
                
                fi
                
            fi

            # check if item matches regex
            if [[ $r == 1 && ! "$(basename "$item")" =~ ${regex} ]]; then

                continue

            fi

            cp_file "${item}" "${SRC}" "${DST}" $c 
                        
        else

            continue

        fi

    done

    # then print summary for the current SRC directory
    echo "While backuping "${SRC}": ${errors} Errors; ${warnings} Warnings; ${updated} Updated; ${copied} Copied (${copied_size}B); ${deleted} Deleted (${deleted_size}B)"
    errors=0
    warnings=0
    updated=0
    copied=0
    copied_size=0
    deleted=0
    deleted_size=0

    # finaly, deal with sub-directories
    for item in "${SRC}"/*;do

        if [[ $b == 1 ]]; then

            contains_element "${item}" "${not_to_cp_files[@]}"
            
            if [[ $? == 0 ]]; then
            
                continue
            
            fi
            
        fi

        if [[ -d "${item}" ]]; then

            cp_dir "${item}" "${SRC}" "${DST}" $c $b "${not_to_cp_filename}" $r "${regex}" "${not_to_cp_files[@]}"

                        
        else

            continue

        fi

    done
}
