#!/bin/sh

query_installed_file_list() {
  for e in $(pacman -Qlq "$1" | xargs)
  do
    if test "${e%/}" = "$e"; then
      files="${files} ${e}"
    fi
  done

  echo "$files"
}

check_binary_format() {
    file_info=$(file $1)

    if test "${file_info#*ELF}" != "$file_info"; then
        echo 0
    else
        echo 1
    fi
}
