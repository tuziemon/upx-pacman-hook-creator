Describe 'hook-creatter.sh'
  Describe
    Parameters
      /tmp/test.hook firefox spec/testdata/firefox.hook ""
      /tmp/test.hook chromium spec/testdata/chromium.hook ""
    End

    Example "hook-creater $1 $2"
      When call ./hook-creater.sh "$1" "$2" && diff "$1" "$3"
      The output should eq "$4"
      The status should be success
    End
  End
End
