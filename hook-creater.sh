#!/bin/sh

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

create_hook "$1" "$2"
