#!/bin/sh

select_compressible_file() {
  pacman -Qlq "$1" | xargs file -F ' ' | grep executable | cut -d' ' -f1 | xargs -n 1 du -h --threshold="$2" | cut -f2 | xargs
}

create_hook() {
  package_name="$1"
  threshold="$2"
  compress_bin_list=$(select_compressible_file "${package_name}" "${threshold}")

  ret=$(cat << EOS
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
EOS
     )

  for e in $compress_bin_list
  do
    ret="${ret} $( cat << EOS

Target = ${e#/}
EOS
          )"
  done

    ret="${ret} $( cat << EOS


[Action]
Depends = upx
Description = Packing ${package_name} binary to UPX...
When = PostTransaction
Exec = /usr/sbin/upx ${compress_bin_list# }
NeedsTargets
EOS
       )"

  echo "${ret}"
}

needsu() {
  $@ > /dev/null 2>&1 || sudo $@
}

usage() {
  cat <<EOUSAGE
-----------------------------------------------------------------------
Usage: $0 [< options >]

Options:
-o output_hook : Output hook filename.
-p package_name : Compress package name.
-t binary_threshold : Compress binary if greater than this parameter.
-----------------------------------------------------------------------
EOUSAGE
}

main() {
  while getopts o:p:t: flag
  do
    case "${flag}" in
      o) output=${OPTARG};;
      p) package_name=${OPTARG};;
      t) threshold=${OPTARG};;
      *) usage
         exit 1;
    esac
  done

  if [ -z "$output" ] || [ -z "$package_name" ] || [ -z "$threshold" ]; then
    echo "Missing -o or -p or -t" >&2
    usage
    exit 1
  fi

  needsu mkdir -p /test
  create_hook "$package_name" "$threshold" | needsu tee /opt/upx-packer/hooks/"${output}" > /dev/null
}

main "$@"
