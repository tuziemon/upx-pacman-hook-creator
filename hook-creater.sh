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

  if test "${file_info#*executable}" != "$file_info"; then
    echo 0
  else
    echo 1
  fi
}

create_hook() {
  output_hook="$1"
  compress_bin_list="$2"



  cat << EOF > "$output_hook"
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
EOF
  for e in $compress_bin_list
  do
    echo "Target = $e" >> "$output_hook"
  done

  cat << EOF >> "$output_hook"
[Action]
Depends = upx
Description = Packing binary to UPX...
When = PostTransaction
Exec = /usr/sbin/upx $compress_bin_list
NeedsTargets
EOF
}
