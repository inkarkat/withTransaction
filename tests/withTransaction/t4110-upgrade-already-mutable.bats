#!/usr/bin/env bats

load fixture

@test "upgrading its already mutable transaction prints a notice" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 2 -c 'withTransaction --upgrade-to-write-transaction && echo okay >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Note: Current transaction already is a write transaction, no need to upgrade." ]
    assert_file "okay"
}

@test "upgrading its already mutable transaction prolongs the transaction timeout with the default one" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ withTransaction --upgrade-to-write-transaction && echo okay; sleep 2; echo final; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Note: Current transaction already is a write transaction, no need to upgrade." ]
    assert_file "okay
final"
}

@test "upgrading its already mutable transaction prolongs the transaction timeout with the passed one" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 1 -c '{ withTransaction --upgrade-to-write-transaction --transaction-timeout 5 && echo okay; sleep 4; echo final; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Note: Current transaction already is a write transaction, no need to upgrade." ]
    assert_file "okay
final"
}

@test "upgrading its already mutable transaction prolongs the transaction timeout from the current time with the passed one" {
    run withTransaction --transacted-file "$FILE" --transaction-timeout 3 -c '{ sleep 2; withTransaction --upgrade-to-write-transaction --transaction-timeout 5 && echo okay; sleep 4; echo final; } >> {}'
    [ $status -eq 0 ]
    [ "$output" = "Note: Current transaction already is a write transaction, no need to upgrade." ]
    assert_file "okay
final"
}
