#!/bin/sh

select_compressible_file() {
  pacman -Qlq "$1" | xargs file -F ' ' | grep executable | cut -d' ' -f1 | xargs -n 1 du -h --threshold="$2" | cut -f2 | xargs
}

create_hook() {
  output_hook="$1"
  package_name="$2"
  threshold="$3"
  compress_bin_list=$(select_compressible_file "${package_name}" "${threshold}")

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

usage() {
  cat <<EOUSAGE
-----------------------------------------------------------------------
Usage: $0 [< options >]

Options:
-o output_hook : Output hook filename.
-p package_name : Compress package name.
-t binary_threshold : Compress binary if greater than this parameter.
-s save: Save binary threshold to /opt/upx-packer/upx-packer.conf.
-----------------------------------------------------------------------
EOUSAGE
}

main() {
  while getopts o:p:t:s flag
  do
    case "${flag}" in
      o) output=${OPTARG};;
      p) package_name=${OPTARG};;
      t) threshold=${OPTARG};;
      s) save=1;;
      *) usage
         exit 1;
    esac
  done

  if [ -z "$output" ] || [ -z "$package_name" ] || [ -z "$threshold" ]; then
    echo "Missing -o or -p or -t" >&2
    usage
    exit 1
  fi

  if [ -n "$save" ]; then
    mkdir -p /opt/upx-packer 2> /dev/null || sudo mkdir -p /opt/upx-packer
    touch /opt/upx-packer/upx-packer.conf 2> /dev/null || sudo touch /opt/upx-packer/upx-packer.conf
    echo "threshold.$package_name=$threshold" | sudo tee -a /opt/upx-packer/upx-packer.conf > /dev/null 2>&1
    echo "threshold.$package_name=$threshold" | tee -a /opt/upx-packer/upx-packer.conf > /dev/null 2>&1
  fi

  create_hook "$output" "$package_name" "$threshold"
}

main "$@"
