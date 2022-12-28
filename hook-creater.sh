#!/bin/sh

check_binary_format() {
    file_info=$(file $1)

    if test "${file_info#*ELF}" != "$file_info"; then
        echo 0
    else
        echo 1
    fi
}
