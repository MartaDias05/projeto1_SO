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
# r_files_arr -> array with the files that obey to a certain regex pattern
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
    local r_files_arr="$8"
    local regex="$9"

    echo "r -> "${b_filename}""
    echo "c -> $c"
    echo "b -> $b"

    find "${SRC}" -maxdepth 1 -mindepth 1 | while read item; do

        if [[ $r == 1 ]]; then

            if [[ $b == 1 ]]; then
                
                for item in "${r_files_arr[@]}";do
            
                    if [[ $( contains_element "${item}" "${b_files_arr[@]}" ) == 0 ]]; then
                        
                        if [[ -d "${item}" ]]; then
                            
                            new_dst="${DST}/$(basename "${item}")"

                            if [[ -d "${new_dst}" ]]; then # check if directory already exists in backup
                            
                                if [[ $c == 1 ]]; then

                                    "${BACKUP_SCRIPT_PATH}" -c -r "${regex}" -b "${b_filename}" "${item}" "${new_dst}"

                                else 

                                    "${BACKUP_SCRIPT_PATH}" -r "${regex}" -b "${b_filename}" "${item}" "${new_dst}" 

                                fi

                            else
                            
                                echo "mkdir "${new_dst}""
                                if [[ $c == 1 ]]; then

                                    "${BACKUP_SCRIPT_PATH}" -c -r "${regex}" -b "${b_filename}" "${item}" "${new_dst}" 

                                else 

                                    mkdir "${new_dst}"
                                    "${BACKUP_SCRIPT_PATH}" -r "${regex}" -b "${b_filename}" "${item}" "${new_dst}"

                                fi

                            fi 

                        elif [[ -f "${item}"  ]]; then

                            pathname_copied_file="${DST}/$(basename "${item}")"

                            # verify if the files exists on DST
                            if [[ -f "${pathname_copied_file}" ]]; then
                                compare_modification_dates "${item}" "${pathname_copied_file}" "${c}"
                            else
                                # if file is not in DST then copy it
                                echo "cp -a ${item} ${pathname_copied_file}"
                                if [[ ${c} == 0 ]]; then
                                    cp -a ${item} ${pathname_copied_file}
                                fi
                            fi

                        fi

                    fi

                done

            else

                for item in "${r_files_arr[@]}";do

                    if [[ -d "${item}" ]]; then
                        
                        new_dst="${DST}/$(basename "${item}")"

                        if [[ -d "${new_dst}" ]]; then
                        
                            if [[ $c == 1 ]]; then

                                "${BACKUP_SCRIPT_PATH}" -c -r "${regex}" "${item}" "${new_dst}"

                            else 

                                "${BACKUP_SCRIPT_PATH}" -r "${regex}" "${item}" "${new_dst}" 

                            fi

                        else
                        
                            echo "mkdir "${new_dst}""
                            if [[ $c == 1 ]]; then

                                "${BACKUP_SCRIPT_PATH}" -c -r "${regex}" "${item}" "${new_dst}" 

                            else 

                                mkdir "${new_dst}"
                                "${BACKUP_SCRIPT_PATH}" -r "${regex}" "${item}" "${new_dst}"

                            fi

                        fi 

                    elif [[ -f "${item}"  ]]; then

                        pathname_copied_file="${DST}/$(basename "${item}")"

                        # verify if the files exists on DST
                        if [[ -f "${pathname_copied_file}" ]]; then
                            compare_modification_dates "${item}" "${pathname_copied_file}" "${c}"
                        else
                            # if file is not in DST then copy it
                            echo "cp -a ${item} ${pathname_copied_file}"
                            if [[ ${c} == 0 ]]; then
                                cp -a ${item} ${pathname_copied_file}
                            fi
                        fi
                    
                    fi

                done

            fi

        elif [[ $b == 1 ]]; then

            if [[ $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 0 ]]; then
                    
                if [[ -d "${item}" ]]; then
                        
                    new_dst="${DST}/$(basename "${item}")"

                    if [[ -d "${new_dst}" ]]; then
                    
                        if [[ $c == 1 ]]; then

                            "${BACKUP_SCRIPT_PATH}" -c "${item}" "${new_dst}" 

                        else 

                            "${BACKUP_SCRIPT_PATH}" "${item}" "${new_dst}" 

                        fi

                    else
                    
                        echo "mkdir "${new_dst}""
                        if [[ $c == 1 ]]; then

                            "${BACKUP_SCRIPT_PATH}" -c -b "${b_filename}" "${item}" "${new_dst}" 

                        else 

                            mkdir "${new_dst}"
                            "${BACKUP_SCRIPT_PATH}" -b "${b_filename}" "${item}" "${new_dst}"

                        fi

                    fi 

                elif [[ -f "${item}"  ]]; then

                    pathname_copied_file="${DST}/$(basename "${item}")"

                    # verify if the files exists on DST
                    if [[ -f "${pathname_copied_file}" ]]; then
                        compare_modification_dates "${item}" "${pathname_copied_file}" "${c}"
                    else
                        # if file is not in DST then copy it
                        echo "cp -a ${item} ${pathname_copied_file}"
                        if [[ ${c} == 0 ]]; then
                            cp -a ${item} ${pathname_copied_file}
                        fi
                    fi

                fi

            fi

        else

            if [[ -d "${item}" ]]; then

                new_dst="${DST}/$(basename "${item}")"

                if [[ -d "${new_dst}" ]]; then
                
                    if [[ $c == 1 ]]; then

                        "${BACKUP_SCRIPT_PATH}" -c "${item}" "${new_dst}" 

                    else 

                        "${BACKUP_SCRIPT_PATH}" "${item}" "${new_dst}" 

                    fi

                else
                
                    echo "mkdir "${new_dst}""
                    if [[ $c == 1 ]]; then

                        "${BACKUP_SCRIPT_PATH}" -c "${item}" "${new_dst}" 

                    else 

                        mkdir "${new_dst}"
                        "${BACKUP_SCRIPT_PATH}" "${item}" "${new_dst}" 

                    fi

                fi                

            elif [[ -f "${item}" ]]; then

                pathname_copied_file="${DST}/$(basename "${item}")"

                # verify if the files exists on DST
                if [[ -f "${pathname_copied_file}" ]]; then
                    compare_modification_dates "${item}" "${pathname_copied_file}" "${c}"
                else
                    # if file is not in DST then copy it
                    echo "cp -a ${item} ${pathname_copied_file}"
                    if [[ ${c} == 0 ]]; then
                        cp -a ${item} ${pathname_copied_file}
                    fi
                fi

            fi

        fi

    done
}
