#!/usr/bin/env bats

load fixture

@test "a failing command's file creation is rolled back" {
    run withTransaction --transacted-file "$FILE" --rollback-on-failure -c 'echo output >> {}; false'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait

    assert_empty_file
}

@test "a failing command's additions to the file are rolled back" {
    echo initial > "$FILE"
    run withTransaction --transacted-file "$FILE" --rollback-on-failure -c 'echo -e new\\nadditions >> {}; (exit 42)'
    [ $status -eq 42 ]
    [ "$output" = "" ]
    wait

    assert_file "initial"
}

@test "a failing command's changes to the file are rolled back" {
    echo -e 'all\ninitial' > "$FILE"
    run withTransaction --transacted-file "$FILE" --rollback-on-failure -c 'sed -i y/ainlt/AINLT/ {}; false'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait

    assert_file "all
initial"
}
