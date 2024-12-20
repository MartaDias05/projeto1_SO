#!/bin/bash

# this scrip hold the function responsible for the backup

# this function takes in as parameters:
# SRC
# DST
# value of flag -c (0 or 1)
# value of flag -b (0 or 1)
# not_to_cp_files -> array with the files that are not to be copied
# b_filename -> path to the file that contains the files not to be copied
# value of flag -r (0 or 1)
# regex -> regex pattern to be respected
# first_run (0 or 1) -> if it is the first time running the scrip or not

backup_function()
{

    local SRC=$1
    local DST=$2
    local c=$3
    local b=$4
    local not_to_cp_filename="$5"
    local r=$6
    local regex="$7"
    local first_run=$8
    local not_to_cp_files=("${@:9}")
    local item


    if [[ ${first_run} == 1 ]]; then

        # cp the files first;
        for item in "${SRC}"/* "${SRC}"/.*; do

            if [[ -f "${item}" ]]; then

                if [[ $b == 1 ]]; then

                    contains_element "${item}" "${not_to_cp_files[@]}"
                    
                    if [[ $? == 0 ]]; then
                    
                        continue
                    
                    fi
                    
                fi

                pathname_copied_file="${DST}/$(basename "${item}")"

                if [[ $r == 1 && ! "$(basename "$item")" =~ $regex ]]; then

                    continue
                
                fi

                echo "cp -a "${item}" "${pathname_copied_file}""

                if [[ $c == 0 ]]; then

                    cp -a "${item}" "${pathname_copied_file}" || ((errors++))

                fi

                ((copied++))
                copied_size=$(($(stat -c %s "${item}") + copied_size))
                            
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
        for item in "${SRC}"/* "${SRC}"/.*; do
    
            [[ "$(basename "${item}")" == "." || "$(basename "${item}")" == ".." ]] && continue


            if [[ $b == 1 ]]; then

                contains_element "${item}" "${not_to_cp_files[@]}"
                
                if [[ $? == 0 ]]; then
                
                    continue
                
                fi
                
            fi

            if [[ -d "${item}" ]]; then

                # checks for special . and .. directories and ignores them
                [[ "$(basename "${item}")" == "." || "$(basename "${item}")" == ".." ]] && continue

                new_dst="${DST}/$(basename "${item}")"
                echo "mkdir "${new_dst}""

                if [[ $c == 0 ]]; then

                    mkdir "${new_dst}" || ((errors++))

                fi

                backup_function "${item}" "${new_dst}" $c $b "${not_to_cp_filename}" $r "${regex}" $first_run "${not_to_cp_files[@]}" 

                            
            else

                continue

            fi

        done

    else

        remove_deleted_files "${DST}" "${SRC}" $c 
        cp_new_mod_files "${SRC}" "${DST}" $c $b "${not_to_cp_filename}" $r "${regex}" "${not_to_cp_files[@]}" 

    fi

}