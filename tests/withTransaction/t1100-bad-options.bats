#!/usr/bin/env bats

load fixture

@test "missing transacted file prints usage error" {
    run withTransaction -- true
    [ $status -eq 2 ]
    [ "${lines[0]}" = 'ERROR: Missing -f|--transacted-file FILE.' ]
    [ "${lines[2]%% *}" = 'Usage:' ]
}

@test "combining rollback with readonly prints usage error" {
    run withTransaction --transacted-file "$FILE" --rollback-on-failure --read-only -- true
    [ $status -eq 2 ]
    [ "${lines[0]}" = 'ERROR: Cannot combine --rollback-on-failure with -r|--read-only.' ]
    [ "${lines[2]%% *}" = 'Usage:' ]
}

@test "bad owner ID prints usage error" {
    run withTransaction --transacted-file "$FILE" --transaction-owner '*foo' -- true
    [ $status -eq 2 ]
    [ "${lines[0]}" = 'ERROR: OWNER-ID must not start with *.' ]
    [ "${lines[2]%% *}" = 'Usage:' ]
}

@test "check without transaction prints error" {
    run withTransaction --check
    [ $status -eq 2 ]
    [ "$output" = 'ERROR: Not within a transaction; --check can only be called by COMMANDs of a withTransaction execution.' ]
}

@test "upgrade to write transaction without transaction prints error" {
    run withTransaction --upgrade-to-write-transaction
    [ $status -eq 2 ]
    [ "$output" = 'ERROR: Not within a transaction; --upgrade-to-write-transaction can only be called by COMMANDs of a withTransaction execution.' ]
}
