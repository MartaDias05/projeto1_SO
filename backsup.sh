#!/bin/bash

SRC=${@:OPTIND:1}
DST=${@:OPTIND+1:1}


# checks if -r and -b were passed as flags
while getopts "r" opt; do

    case ${opt} in
    
        r)
            regex="${OPTARG}"
            ;;


        


        * )
            echo "Invalid option. Options should only include: -c (checking); -b; -r."
            exit 1
            ;;
    esac

done




# checks if SRC and DST are valid directories
if ! [[ -d ${SRC} ]]; then   
    echo "The directory '$SRC' isn't valid"
    exit 1
fi


if ! [[ -d ${DST} ]]; then   
    echo "The directory '$DST' isn't valid"
    exit 1
fi




# iterating througth src directory
for item in "$SRC"/*; do

    if [[ -d ${item} ]]; then
        new_dst="$DST/$(basename "$item")"
        mkdir -p "$new_dst"

        ./backsup.sh "$item" "$new_dst"


    elif [[ -f ${item} ]]; then
        if [[ -n ${regex} ]]; then
            if [[ "$(basename "$item")" =~ $regex ]]; then
                cp -a "$item" "$DST"
            fi
        fi
    fi
done
