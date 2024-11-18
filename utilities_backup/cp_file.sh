#!/bin/bash

# this script holds a function responsible for a copy of a file

# this function takes in as parameters: 
# item
# DST
# value of flag -c (0 or 1)

cp_file()
{

    local item="$1"
    local SRC="$2"
    local DST="$3"
    local c="$4"

    pathname_copied_file="${DST}/$(basename "${item}")" 
    
    # verify if the files exists on DST
    if [[ -f "${pathname_copied_file}" ]]; then

        compare_modification_dates "${item}" "${pathname_copied_file}" "${c}"
    
    else
    
        # if file is not in DST then copy it
        echo "cp -a ${item} ${pathname_copied_file}"
    
        if [[ ${c} == 0 ]]; then
    
            cp -a ${item} ${pathname_copied_file} || ((errors++))
    
        fi

        ((copied++))
        copied_size=$(($(stat -c %s "${item}") + $copied_size))
    
    fi

}