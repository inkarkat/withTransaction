#!/usr/bin/env bats

load fixture

@test "command can upgrade its readonly transaction to mutable one at the beginning" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 --read-only -c 'withTransaction --upgrade-to-write-transaction && echo okay >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    assert_file "okay"
}

@test "command can upgrade its readonly transaction to mutable one in the middle" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 --read-only -c 'sleep 1; withTransaction --upgrade-to-write-transaction && echo okay >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    assert_file "okay"
}

@test "command can upgrade its readonly transaction to mutable one after the timeout with a warning" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 --read-only -c 'sleep 3.1; withTransaction --upgrade-to-write-transaction && echo okay >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Warning: Current transaction timed out 1 second ago." ]
    assert_file "okay"
}
