#!/usr/bin/env bats

load fixture

@test "a second invocation with a different lockfile proceeds" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --lock-file "${FILE}.lck" -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "second
first"
}

@test "a second invocation while another is still running both with custom lockfiles waits until the first is done" {
    withTransaction --transacted-file "$FILE" --lock-file "${FILE}.lck" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --lock-file "${FILE}.lck" -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first
second"
}
