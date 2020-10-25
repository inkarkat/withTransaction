#!/usr/bin/env bats

load fixture

@test "a second invocation while another is still running with different given owners waits until the first is done" {
    withTransaction --transacted-file "$FILE" --transaction-owner Alice -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --transaction-owner Bob -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first
second"
}

@test "a second invocation while another is still running with the same given owner causes an error and returns 1" {
    withTransaction --transacted-file "$FILE" --transaction-owner Same -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --transaction-owner Same -c 'echo second >> {}'
    [ $status -eq 1 ]
    [ "$output" = "ERROR: Another write transaction by Same is already in progress." ]
    wait
    assert_file "first"
}

@test "a second invocation with the same given owner after the original one completed works" {
    withTransaction --transacted-file "$FILE" --transaction-owner Same -c 'sleep 1; echo first >> {}'
    run withTransaction --transacted-file "$FILE" --transaction-owner Same -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first
second"
}
