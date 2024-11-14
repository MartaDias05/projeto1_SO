#!/bin/bash

regex=''

declare -a not_to_cp_files
declare -a matched_regex_files

# checks if -r and -b were passed as flags
while getopts ${OPTSTRING} opt; do

    case ${opt} in
        c)
            checking=1
            ;;
        
        r)
            regex="${OPTARG}"
            r=1

            # build an array with the files / directories whose name matches regex (this code is only triggered when r is passed in)
            # cant do this here -> SRC is not defined yet...
            for item in "$SRC"/*; do
                echo "${item}"
                if [[ "$(basename "$item")" =~ $regex ]]; then

                    matched_regex_files+=("${item}")
                    #control
                    echo "${matched_regex_files[@]}"
                fi

            done

            ;;
        b)
            # check if the file passed in as argument is a valid file
            if ! [[ -f "${OPTARG}" ]]; then
               echo "${OPTARG} file does not exist!"
               echo "Usage: ./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
               exit 1
            fi

            b=1

            # read the file and add each not to copy file to the array
            while read -r LINE; do
                # append files to not_to_cp_files;
                not_to_cp_files+=("${LINE}")
            done < "${OPTARG}"
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
            ;;
        
        ?)
            echo "Invalid option. Options should only include: -c (checking); -b tfile; -r regexpr."
            exit 1
            ;;
    esac

done

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

# create DST if does not exist and parent path is valid
if ! [[ -d ${DST} ]]; then

    first_run=1  

    if ((${checking} == 0)); then
    
        mkdir ${DST}
        echo "mkdir ${DST}"

    else

        echo "mkdir ${DST}"
    
    fi

fi


#if c was passed in as a flag then simulate the backup
if (( ${checking} == 1 )); then

    if ((${first_run} == 1)); then

        # check if -r was triggered
        if [[ ${r} == 1 ]]; then

            # build an array that holds the files that match the regex expression
            
            if [[ ${b} == 1 ]]; then

                # check if any of the files on the array built above belongs to not_to_cp_files
                # if any belongs -> ignore (do not copy)

            else

                # copy all the files in the array built above

            fi

        elif [[ ${b} == 1 ]]; then

            # copy all the files that do not belong to not_to_cp_files

        else

            cp_all_files "${SRC}" "${DST}" ${checking} # mofify this function to deal with directories
        
        fi
    
    else
    
        cp_new_mod_files "${SRC}" "${DST}" ${checking}
        remove_deleted_files "${DST}" "${SRC}" ${checking}
    
    fi

else # if c was not passed in as a flag, do the actual backup
    
    if ((${first_run} == 1)); then
        cp_all_files "${SRC}" "${DST}" ${checking}
    else
        cp_new_mod_files "${SRC}" "${DST}" ${checking}
        remove_deleted_files "${DST}" "${SRC}" ${checking} 
    fi
fi


# iterating througth src directory
for item in "$SRC"/*; do

    echo "${item}"

    if [[ -d ${item} ]]; then
        new_dst="${DST}/$(basename "$item")"
        mkdir -p "$new_dst"

        $0 "${item}" "${new_dst}" # Script recursively spawns a new instance of itself


    # if -r was passed as a flag
    elif [[ -f ${item} ]]; then
        if [[ -n ${regex} ]]; then
            if [[ "$(basename "$item")" =~ $regex ]]; then
                cp -a "$item" "$DST"
            fi
        fi
    fi
done
