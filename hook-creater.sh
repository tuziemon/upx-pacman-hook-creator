#!/bin/sh

query_installed_file_list() {
  for e in $(pacman -Qlq $1 | xargs)
  do
    if test "${e%/}" = "$e"; then
      files="${files} ${e}"
    fi
  done

  echo $files
}
