#!/bin/bash

# Check if exactly 2 positional arguments were passed in
if [[ $# -ne 2 ]]; then
   
    echo "The program accepts exactly 2 positional arguments: SRC and DST"
    exit 1

fi

SRC=$1
DST=$2

# Check if SRC is a valid directory
if ! [[ -d "${SRC}" ]]; then

    echo "The path '${SRC}' is not a valid directory."
    exit 1

fi

# Check if the parent directory of DST exists
parent_dir=$(dirname "${DST}")
if ! [[ -d "${parent_dir}" ]]; then

    echo "The directory for the destination path '${DST}' is not valid."
    exit 1

fi

# array that hold differing files
declare -a diff_files

# this function checks if a given file belongs to diff_files
contains_elem() {

    local match=$1

    for file in "${diff_files[@]}"; do

        if [[ "$file" == "$match" ]]; then

            return 0 # found it in array

        fi

    done

    return 1 # did not find it in array
}

# this function checks if a fiven file already belongs to diff_files; if not -> adds file to it
add() {

    local file=$1

    if ! contains_elem "$file" ; then

        diff_files+=("$file")

    fi

}

# this function is responsible for comparing the files in a given SRC directory to another given DST directory
compare_dirs() {

    local src_dir=$1
    local dst_dir=$2


    for src_item in "${src_dir}"/*; do
        
        dst_item="${dst_dir}/$(basename "${src_item}")"

        if [[ -d "${src_item}" ]]; then
            
            if  [[ -d "${dst_item}" ]]; then

                compare_dirs "${src_item}" "${dst_item}" 

            
            fi
        
        elif [[ -f "${src_item}" ]]; then
        
            if  [[ -f "${dst_item}" ]]; then

                src_checksum=$(md5sum "${src_item}" | cut -d ' ' -f1)
                dst_checksum=$(md5sum "${dst_item}" | cut -d ' ' -f1)

                if [[ "${src_checksum}" != "${dst_checksum}" ]]; then
                
                    add "${src_item} and ${dst_item} differ."
                
                fi
            
            fi
        
        fi
    
    done
}


compare_dirs "${SRC}" "${DST}"

for item in "${diff_files[@]}"; do
    echo "$item"
done
