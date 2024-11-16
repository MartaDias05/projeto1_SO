#!/bin/bash

# this script holds a function responsible for removing any files in DST directory 
# that are not present in the SRC directory. Additionally, this function supports 
# subdirectories.

# this function takes in as parameters:
# SRC
# DST
# value of flag -c (0 or 1)


remove_deleted_files() {

    local DST=$1
    local SRC=$2
    local c=$3
    local item

    echo "DST -> $DST"

    for item in "${DST}"/*; do

        if [[ -d "${item}" ]]; then

            relative_path=${item#$DST/}
            dir_name_in_src="${SRC}/${relative_path}" || ((errors++))

            # check if directory appears in src
            if ! [[ -d "${dir_name_in_src}" ]]; then

                # if not -> delete;
                echo "rm -r ${item}"

                if [[ $c == 0 ]]; then

                    n_files=$(find "${item}" -type f | wc -l)
                    ((deleted += n_files))
                    deleted_size=$((deleted_size + $(du -sb "${item}" | cut -f1)))

                    rm -r "${item}" || ((errors++))

                fi
            fi

        elif [[ -f "${item}" ]]; then

            relative_path=${item#$DST/}
            file_name_in_src="${SRC}/${relative_path}"

            if ! [[ -f "${file_name_in_src}" ]]; then
               
                echo "rm ${DST}/$(basename "${item}")"

                if [[ ${c} == 0 ]]; then

                    ((deleted++))
                    deleted_size=$((deleted_size + $(stat -c %s "${item}")))

                    rm "${DST}/$(basename "${item}")" || ((errors++))
                
                fi
            fi 

        fi

    done
}