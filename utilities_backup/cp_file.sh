#!/bin/bash

# this script holds a function responsible for a copy of a file

# this function takes in as parameters: 
# item
# DST
# value of flag -c (0 or 1)

cp_file()
{

    local item="$1"
    local DST="$2"
    local c="$3"

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

}