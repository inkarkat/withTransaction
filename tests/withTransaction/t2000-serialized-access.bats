#!/usr/bin/env bats

load fixture

@test "a second invocation while another is still running waits until the first is done" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first
second"
}

@test "a second invocation with a long timeout while another is still running waits until the first is done" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --timeout 2 -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first
second"
}

@test "a second invocation with zero timeout while another is still running aborts" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --timeout 0 -c 'echo second >> {}'
    [ $status -eq 5 ]
    [ "$output" = "Timed out while another write transaction by first is in progress." ]
    wait
    assert_file "first"
}

@test "a second invocation with short timeout while another is still running aborts" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 2; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --timeout 1 -c 'echo second >> {}'
    [ $status -eq 5 ]
    [ "$output" = "Timed out while another write transaction by first is in progress." ]
    wait
    assert_file "first"
}
