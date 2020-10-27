#!/usr/bin/env bats

load fixture

@test "check a timed-out transaction when another was completed" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ sleep 2; withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed.
ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed." ]
    wait
    assert_file "second
6-invalid"
}

@test "transaction check error can be suppressed when another was completed" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ sleep 2; withTransaction --check --silence-transaction-errors && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Not inside a transaction, or the transaction has timed out and another transaction was completed." ]
    wait
    assert_file "second
6-invalid"
}
