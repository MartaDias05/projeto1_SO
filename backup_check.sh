# !/bin/bash

SRC=${@:OPTIND:1}
DST=${@:OPTIND+1:1}


#check if only 2 positional arguments were passed in
if [[ $(($# - OPTIND+1)) -ne 2 ]]; then
    echo "The program accepts 2 and only 2 positional arguments"
    exit 1
fi

#check if SRC and DST are valid paths
if ! [[ -d ${SRC} ]]; then

    echo "The path '${SRC}' is not a valid directory path."
    exit 1

fi

parent_dir=$(dirname "${DST}") # parent dir holds the path to the directory passed in a dst

if ! [[ -d ${parent_dir} ]]; then

    echo "The directory passed in for the destination of the backup is not valid!"
    exit 1

fi



# function to compare files between the two directories
compare_files() {
    local SRC=$1
    local DST=$2
    local item


    # iterate through SRC 
    for item in "${SRC}"/*; do

        # checks if the item is a directory
        if [[ -d "${item}" ]]; then
            
            relative_path=${item#$SRC/}
            new_dst="${DST}/${relative_path}"

            # checks if the directory exits in DST
            if ! [[ -d "${new_dst}" ]]; then
                echo "${item} ${new_dst} differ"
                
            fi

            compare_files "${item}" "${new_dst}"


        elif [[ -f "${item}" ]]; then

            relative_path=${item#SRC/}
            pathname_dst_file="${DST}/${relative_path}"


            # checks if the file exist in DST
            if ! [[ -f "${pathname_dst_file}" ]]; then
                echo "${item} ${pathname_dst_file} differ"
                

            else
                scr_check=$(md5sum "${item}" | cut -d " " -f1)
                dst_check=$(md5sum "${pathname_dst_file}" | cut -d " " -f1)

                # checks if they differ
                if [[ "${scr_check}" != "${dst_check}" ]]; then
                    echo "${scr_check} ${dst_check} differ"
                fi
            fi
        fi
    done

    # iterate through DST and checks if they exist in SRC
    for item in "${DST}"/*; do

        if [[ -d "${item}" ]]; then
            
            relative_path=${item#$DST/}
            pathname_src_dir="${SRC}/${relative_path}"

            # checks if the directory exits in SRC
            if ![[ -d "${pathname_src_dir}" ]]; then
                echo "${item} ${new_dst} differ"
                
            fi

        elif [[ -f "${item}" ]]; then

            relative_path=${item#DST/}
            pathname_src_file="${SRC}/${relative_path}"


            # checks if the file exist in SRC   
            if ! [[ -f "{pathname_src_file}" ]]; then
                echo "${item} ${pathname_src_file} differ"
                
            fi
        fi
    done
}




