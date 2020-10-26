#!/usr/bin/env bats

load fixture

@test "a previous long immutable invocation prints a warning" {
    withTransaction --transacted-file "$FILE" --transaction-owner first --transaction-timeout 1 -c 'sleep 2' &
    sleep 1.1
    run withTransaction --transacted-file "$FILE" -c 'true'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Previous write transaction by first timed out 1 second ago but did not do any changes." ]
    wait
}

@test "a previous long invocation is rolled back and prints a warning" {
    withTransaction --transacted-file "$FILE" --transaction-owner first --transaction-timeout 1 -c 'echo first >> {}; sleep 2' &
    sleep 1.1
    run withTransaction --transacted-file "$FILE" -c 'true'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Previous write transaction by first timed out 1 second ago and has been rolled back." ]
    wait
    assert_empty_file
}
