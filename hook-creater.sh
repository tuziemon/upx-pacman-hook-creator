#!/bin/sh

# check_filesize() {
#   du_info=$(du -sh $1)
#   file_size="${du_info%%[[:space:]]*}"

#   if test "${file_size#*M}" != "$file_size"; then
#     echo 0
#   else
#     echo 1
#   fi
# }

# query_installed_file_list() {
#   for e in $(pacman -Qlq "$1" | xargs)
#   do
#     if test "${e%/}" = "$e"; then
#       files="${files} ${e}"
#     fi
#   done

#   echo "$files"
# }

# check_binary_format() {
#   file_info=$(file $1)

#   if test "${file_info#*executable}" != "$file_info"; then
#     echo 0
#   else
#     echo 1
#   fi
# }

# select_compressible_file() {
#   for e in $(query_installed_file_list "$1")
#   do
#     if test "$(check_binary_format "${e}")" -eq 0 && test "$(check_filesize "${e}")" -eq 0; then
#       ret="${ret} ${e}"
#     fi
#   done

#   echo "${ret}"
# }

select_compressible_file() {
  pacman -Qlq "$1" | xargs file -F ' ' | grep executable | cut -d' ' -f1 | xargs -n 1 du -h --threshold=1M | cut -f2 | xargs
}

create_hook() {
  output_hook="$1"
  package_name="$2"
  compress_bin_list=$(select_compressible_file "${package_name}")



  cat << EOF > "$output_hook"
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
EOF
  for e in $compress_bin_list
  do
    echo "Target = ${e#/}" >> "$output_hook"
  done

  cat << EOF >> "$output_hook"

[Action]
Depends = upx
Description = Packing ${package_name} binary to UPX...
When = PostTransaction
Exec = /usr/sbin/upx ${compress_bin_list# }
NeedsTargets
EOF
}
