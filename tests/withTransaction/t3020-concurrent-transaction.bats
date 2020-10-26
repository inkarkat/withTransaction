#!/usr/bin/env bats

load fixture

@test "a second readonly invocation while another is still running proceeds immediately when it is within the expiry time" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first --transaction-timeout 4 -c 'sleep 3' &
    sleep 1.5
    run withTransaction --transacted-file "$FILE" --read-only --transaction-timeout 2 -c 'sleep 1'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
}

@test "a second invocation while another with the same owner is still running aborts with 1" {
    withTransaction --transacted-file "$FILE" --transaction-owner first --transaction-timeout 1 -c 'sleep 2' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --transaction-owner first -c 'true'
    [ $status -eq 1 ]
    [ "$output" = "ERROR: Another write transaction by first is already in progress." ]
    wait
}
