#!/bin/bash

# this script holds a function responsible for the check if an element belongs to a given array.

# the function takes in as parameters:
# match -> element to check;
# elemet -> each element of the array of which we want to check if match exists;

# the function has the following return values:
# 0 -> if element not in array
# 1 -> if element in array

set +e
contains_element()
{

    local match=$1
    local element
    shift # this discards $1 (match) from $@ (all arguments passed in)

    for element in "$@"; do # for each element in the array
    
        if [[ "${element}" == "${match}" ]]; then
            return 1;
        fi

    done

    return 0;

}