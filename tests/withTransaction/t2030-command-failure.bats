#!/usr/bin/env bats

load fixture

@test "a command's failure can be detected" {
    run withTransaction --transacted-file "$FILE" -c 'echo output >> {}; false'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait
    assert_file "output"
}

@test "a failing command's exit status is returned" {
    run withTransaction --transacted-file "$FILE" -c 'echo output >> {}; (exit 42)'
    [ $status -eq 42 ]
    [ "$output" = "" ]
    wait
    assert_file "output"
}
