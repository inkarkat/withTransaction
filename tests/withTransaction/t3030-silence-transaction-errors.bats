#!/usr/bin/env bats

load fixture

@test "a second invocation with short timeout while another is still running aborts with suppressed error message" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 2; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --timeout 1 --silence-transaction-errors -c 'echo second >> {}'
    [ $status -eq 5 ]
    [ "$output" = "" ]
    wait
    assert_file "first"
}

@test "a second invocation while another with the same owner is still running aborts with suppressed error message" {
    withTransaction --transacted-file "$FILE" --transaction-owner first --transaction-timeout 1 -c 'sleep 2' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --transaction-owner first --silence-transaction-errors -c 'true'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait
}

@test "a long invocation pre-empted by another running transaction has its changes rolled back, exits with 6 with suppressed error message" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --silence-transaction-errors -c 'echo first >> {}; sleep 2'
    [ $status -eq 6 ]
    [ "$output" = "" ]
    wait
    assert_file "second"
}

@test "a long invocation pre-empted by another short transaction has its changes rolled back, exits with 6 with suppressed error message" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'true') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --silence-transaction-errors -c 'echo first >> {}; sleep 2'
    [ $status -eq 6 ]
    [ "$output" = "" ]
    wait
    assert_empty_file
}
