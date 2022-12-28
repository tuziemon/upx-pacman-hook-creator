#!/bin/sh

check_filesize() {
    du_info=$(du -sh $1)
    file_size="${du_info%%[[:space:]]*}"

    if test "${file_size#*M}" != "$file_size"; then
        echo 0
    else
        echo 1
    fi
}
