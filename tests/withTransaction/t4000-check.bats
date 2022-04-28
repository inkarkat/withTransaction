#!/usr/bin/env bats

load fixture

@test "command can check whether its transaction is still valid at the beginning" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 -c '{ withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    assert_file "okay"
}

@test "command can check whether its transaction is still valid in the middle" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 -c '{ sleep 1; withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    assert_file "okay"
}

@test "command can check whether its transaction is still valid after the timeout" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 -c '{ sleep 3.1; withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "ERROR: Current transaction timed out 1 second ago.
Warning: Current transaction timed out 1 second ago." ] || echo "$output" | failThis prefix \# >&3
    assert_file "6-invalid"
}

@test "transaction check error can be suppressed when the current transaction timed out" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 -c '{ sleep 3.1; withTransaction --check --silence-transaction-errors && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Current transaction timed out 1 second ago." ] || echo "$output" | failThis prefix \# >&3
    assert_file "6-invalid"
}
