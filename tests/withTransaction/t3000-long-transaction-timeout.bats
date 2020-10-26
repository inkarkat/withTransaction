#!/usr/bin/env bats

load fixture

@test "a long invocation without changes prints a timeout warning" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c 'sleep 2'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Current transaction timed out 1 second ago." ]
}

@test "a long readonly invocation prints a timeout warning" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first -c 'sleep 3' &
    sleep 2
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c 'sleep 2'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Shared read transaction timed out 1 second ago." ]
    wait
}

@test "a long invocation pre-empted by another running transaction has its changes rolled back, prints an error, and exits with 6" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c 'echo first >> {}; sleep 2'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second"
}

@test "a long invocation pre-empted by another running readonly transaction has its changes rolled back, prints an error, and exits with 6" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second --read-only -c 'sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c 'echo first >> {}; sleep 2'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another read transaction by second has been started; any changes have been lost." ]
    wait
    assert_empty_file
}

@test "a long invocation pre-empted by another short transaction has its changes rolled back, prints an error, and exits with 6" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'true') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c 'echo first >> {}; sleep 2'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed." ]
    wait
    assert_empty_file
}
