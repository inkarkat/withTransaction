#!/usr/bin/env bats

load fixture

@test "check a timed-out transaction when another was started" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ sleep 2; withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second has been started; any changes have been lost.
ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second
6-invalid"
}

@test "transaction check error can be suppressed when another was started" {
    (sleep 1; withTransaction --transacted-file "$FILE" --transaction-owner second -c 'echo second >> {}; sleep 2') &
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ sleep 2; withTransaction --check --silence-transaction-errors && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 6 ]
    [ "$output" = "ERROR: Another write transaction by second has been started; any changes have been lost." ]
    wait
    assert_file "second
6-invalid"
}
