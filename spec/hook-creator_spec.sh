Describe 'hook-creator.sh'
  setup() {
    usage="-----------------------------------------------------------------------
Usage: ./hook-creator.sh [< options >]

Options:
-o output_hook : Output hook filename.
-p package_name : Compress package name.
-t binary_threshold : Compress binary if greater than this parameter.
-----------------------------------------------------------------------"
    missing_required_param="Missing -o or -p or -t"
    invalid_param="./hook-creator.sh: illegal option -- "
  }

  BeforeCall 'setup'

  Describe 'normal'
    Parameters
      -o test.hook -p firefox -t 1M spec/testdata/firefox.hook ""
      -o test.hook -p chromium -t 1M spec/testdata/chromium.hook ""
    End

    Example "hook-creator -o param -t param -p param"
      When call ./hook-creator.sh "$1" "$2" "$3" "$4" "$5" "$6" && diff /opt/upx-packer/hooks/"$2" "$7"
      The output should eq "$8"
      The status should be success
    End
  End

  Describe 'missing parameter'
    Parameters
      -o test.hook "" "" "" "" ""
      -p firefox "" "" "" "" ""
      -t 1M "" "" "" "" ""
      -o test.hook -p firefox "" "" ""
      -o test.hook -t 1M "" "" ""
      -p firefox -o /tmp/test.hook "" "" ""
      -p firefox -t 1M "" "" ""
      -t 1M -o /tmp/test.hook "" "" ""
      -t 1M -p firefox "" "" ""
    End

    Example "hook-creator missing param"
      When call ./hook-creator.sh "$1" "$2" "$3" "$4" "$5" "$6"
      The stdout should eq "$usage"
      The stderr should eq "$missing_required_param"
      The status should be failure
    End
  End

  Describe 'invalid parameter'
    Parameters
      -z test.hook "" "" "" "" ""
      -x firefox "" "" "" "" ""
    End

    Example "hook-creator missing param"
      When call ./hook-creator.sh "$1" "$2"
      The stdout should eq "$usage"
      The stderr should eq "$invalid_param${1#-}"
      The status should be failure
    End
  End

  Describe 'pacman hook'
    cleanup() {
      rm /opt/upx-packer/hooks/*
      pacman -Sdd firefox gnome-text-editor --noconfirm > /dev/null 2>&1
    }

    AfterAll 'cleanup'

    Parameters
      -o firefox.hook -p firefox -t 50000 firefox
      -o gnome-text-editor.hook -p gnome-text-editor -t 50000 gnome-text-editor
    End

    Example "executing as pacman hook"
      ./hook-creator.sh "$1" "$2" "$3" "$4" "$5" "$6"
      When call sh -c "pacman -Sdd $7 --noconfirm 2> /dev/null"
      The output should include "Packing $7 binary to UPX..."
      The status should be success
    End
  End

End
