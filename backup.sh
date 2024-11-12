#!/bin/bash

# REDO THE FUNCTIONS TO SUPPORT SUB-DIRECTORIES
#. ./utilities_backup/remove_deleted_files.sh
. ./utilities_backup_files/compare_modification_dates.sh
. ./utilities_backup/cp_all_files.sh
. ./utilities_backup/cp_new_mod_files.sh
. ./utilities_backup/contains_element.sh


BACKUP_SCRIPT_PATH="$(realpath "$0")"
export BACKUP_SCRIPT_PATH

# init variables so they're always passed in the functions
regex="${regex:-""}"
not_to_cp_filename="${not_to_cp_filename:-""}"
checking="${checking:-0}"
r="${r:-0}"
b="${b:-0}"

OPTSTRING=":cr:b:"

declare -a not_to_cp_files
declare -a matched_regex_files

not_to_cp_files=("${not_to_cp_files[@]:-""}")
matched_regex_files=("${matched_regex_files[@]:-""}")

# checks if -r and -b were passed as flags
while getopts ${OPTSTRING} opt; do

    case ${opt} in
        c)
            checking=1
            ;;
        
        r)
            regex="${OPTARG}"
            r=1
            ;;
        b)
            # check if the file passed in as argument is a valid file
            if ! [[ -f "${OPTARG}" ]]; then
               echo "${OPTARG} file does not exist!"
               echo "Usage: ./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
               exit 1
            fi

            b=1
            not_to_cp_filename="${OPTARG}"

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

# only validate if this is the initial call of backup.sh
if [[ -z "${BACKUP_INIT_CALL}" ]]; then

    export BACKUP_INIT_CALL=1

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

        export first_run=1  

        if ((${checking} == 0)); then
        
            mkdir ${DST}
            echo "mkdir ${DST}"

        else

            echo "mkdir ${DST}"
        
        fi

    else
    
        export first_run=0
    
    fi

fi


# build an array with the files / directories whose name matches regex (this code is only triggered when r is passed in)
for item in "${SRC}"/*; do
    if [[ "$(basename "$item")" =~ ${regex} ]]; then

        matched_regex_files+=("${item}")
    fi
done


#if c was passed in as a flag then simulate the backup
if (( ${checking} == 1 )); then

    if ((${first_run} == 1)); then

        if [[ ${r} == 1 ]]; then
            
            if [[ ${b} == 1 ]]; then

                # check if any of the files on the array built for regex matching files belongs to not_to_cp_files
                for item in "${matched_regex_files[@]}";do
               
                    if [[ $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 0 ]]; then
                    
                        if [[ -d "${item}" ]]; then
                        
                            new_dst="${DST}/$(basename "${item}")"
                            echo "mkdir "${new_dst}""
                            $0 -c -r "${regex}" -b "${not_to_cp_filename}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                        elif [[ -f "${item}"  ]]; then

                            echo "cp -a "${item}" "${DST}""

                        fi

                    fi

                done

            else

                # copy all the files in the array built above
                for item in "${matched_regex_files[@]}";do

                    if [[ -d "${item}" ]]; then
                        
                        new_dst="${DST}/$(basename "${item}")"
                        echo "mkdir "${new_dst}""
                        $0 -c -r "${regex}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                    elif [[ -f "${item}"  ]]; then

                        echo "cp -a "${item}" "${DST}""
                    
                    fi

                done

            fi

        elif [[ ${b} == 1 ]]; then

            # copy all the files that do not belong to not_to_cp_files
            for item in "${SRC}"/*;do
               
                if [[ $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 0 ]]; then
                    
                    if [[ -d "${item}" ]]; then
                        
                        new_dst="${DST}/$(basename "${item}")"
                        echo "mkdir "${new_dst}""
                        $0 -c -b "${not_to_cp_filename}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                    elif [[ -f "${item}"  ]]; then

                        echo "cp -a "${item}" "${DST}""

                    fi

                fi

            done

        else

            cp_all_files "${SRC}" "${DST}" ${checking}
        
        fi
    
    else

        cp_new_mod_files "${SRC}" "${DST}" ${checking} ${b} "${not_to_cp_files[@]}" "${not_to_cp_filename}" $r "${matched_regex_files}" "${regex}"
        #remove_deleted_files "${DST}" "${SRC}" ${checking}
    
    fi

else # if c was not passed in as a flag, do the actual backup
    
    if ((${first_run} == 1)); then
        
        # check if -r was triggered
        if [[ ${r} == 1 ]]; then
            
            if [[ ${b} == 1 ]]; then

                # check if any of the files on the array built for regex matching files belongs to not_to_cp_files
                for item in "${matched_regex_files[@]}";do
               
                    if [[ $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 0 ]]; then
                    
                        if [[ -d "${item}" ]]; then
                        
                            new_dst="${DST}/$(basename "${item}")"
                            echo "mkdir "${new_dst}""
                            $0 -r "${regex}" -b "${not_to_cp_filename}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                        elif [[ -f "${item}"  ]]; then

                            echo "cp -a "${item}" "${DST}""

                        fi

                    fi

                done

            else

                # copy all the files in the array built above
                for item in "${matched_regex_files[@]}";do

                    if [[ -d "${item}" ]]; then
                        
                        new_dst="${DST}/$(basename "${item}")"
                        echo "mkdir "${new_dst}""
                        $0 -r "${regex}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                    elif [[ -f "${item}"  ]]; then

                        echo "cp -a "${item}" "${DST}""
                    
                    fi

                done

            fi

        elif [[ ${b} == 1 ]]; then

            # copy all the files that do not belong to not_to_cp_files
            for item in "${SRC}"/*;do
               
                if [[ $( contains_element "${item}" "${not_to_cp_files[@]}" ) == 0 ]]; then
                    
                    if [[ -d "${item}" ]]; then
                        
                        new_dst="${DST}/$(basename "${item}")"
                        echo "mkdir "${new_dst}""
                        $0 -b "${not_to_cp_filename}" "${item}" "${new_dst}" # Script recursively spawns a new instance of itself

                    elif [[ -f "${item}"  ]]; then

                        echo "cp -a "${item}" "${DST}""

                    fi

                fi

            done

        else

            cp_all_files "${SRC}" "${DST}" ${checking}
        
        fi
        
    else

        cp_new_mod_files "${SRC}" "${DST}" ${checking} ${b} "${not_to_cp_files[@]}" "${not_to_cp_filename}" ${r} "${matched_regex_files}" "${regex}"
        #remove_deleted_files "${DST}" "${SRC}" ${checking} 
    fi
fi
