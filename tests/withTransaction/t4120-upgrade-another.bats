#!/usr/bin/env bats

load fixture

@test "upgrade a readonly transaction when another was started" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c '{ sleep 2; withTransaction --upgrade-to-write-transaction && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second is already in progress.
ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second
6-invalid"
}

@test "upgrade error can be suppressed when another was started" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c '{ sleep 2; withTransaction --upgrade-to-write-transaction --silence-transaction-errors && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second
6-invalid"
}

@test "upgrade a readonly transaction when another was started but timed out" {
    (sleep 2; withTransaction --transacted-file "$FILE" --transaction-owner second --transaction-timeout 1 -c 'echo second >> {}; sleep 3') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c '{ sleep 4; withTransaction --upgrade-to-write-transaction && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second has started already (and timed out 1 second ago).
ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second
6-invalid"
}

@test "upgrade a readonly transaction when another was completed" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c '{ sleep 2; withTransaction --upgrade-to-write-transaction && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed.
ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed." ]
    wait
    assert_file "second
6-invalid"
}
