#!/bin/bash

# this scrip hold the function responsible for the backup

# this function takes in as parameters:
# SRC
# DST
# value of flag -c (0 or 1)
# value of flag -b (0 or 1)
# b_files_arr -> array with the files that are not to be copied
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
    local not_to_cp_files="$5"
    local not_to_cp_filename="$6"
    local r=$7
    local regex="$8"
    local first_run=$9

    echo ${not_to_cp_files[@]}

    if [[ ${first_run} == 1 ]]; then

        for item in "${SRC}"/*;do

            if [[ $b == 1 && $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 1 ]]; then

                continue

            fi

            if [[ -d "${item}" ]]; then
                            
                new_dst="${DST}/$(basename "${item}")"
                echo "mkdir "${new_dst}""

                if [[ $c == 0 ]]; then

                    mkdir "${new_dst}"

                fi

                backup_function "${item}" "${new_dst}" $c $b "${b_files_arr[@]}" "${not_to_cp_filename}" $r "${regex}" $first_run

            elif [[ -f "${item}"  ]]; then

                if [[ $r == 1 && ! "$(basename "$item")" =~ $regex ]]; then

                    continue
                
                fi

                echo "cp -a "${item}" "${DST}""

                if [[ $c == 0 ]]; then

                    cp -a "${item}" "${DST}"

                fi

            fi

        done

    else

        remove_deleted_files "${DST}" "${SRC}" $c
        cp_new_mod_files "${SRC}" "${DST}" $c $b "${not_to_cp_files[@]}" "${not_to_cp_filename}" $r "${regex}"

    fi

}