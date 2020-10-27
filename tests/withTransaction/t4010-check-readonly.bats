#!/usr/bin/env bats

load fixture

@test "check a timed-out readonly invocation" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first -c 'sleep 3' &
    sleep 2
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 --read-only -c '{ sleep 2; withTransaction --check && echo okay || echo $?-invalid; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Current shared transaction timed out 1 second ago.
Warning: Shared read transaction timed out 1 second ago." ]
    wait
    assert_file "okay"
}
