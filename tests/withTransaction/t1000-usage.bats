#!/usr/bin/env bats

load fixture

@test "no arguments prints message and usage instructions" {
    run withTransaction --transacted-file "$FILE"
    [ $status -eq 2 ]
    [[ "${lines[0]}" =~ ^"ERROR: No COMMAND(s) specified" ]]
    [ "${lines[2]%% *}" = 'Usage:' ]
}

@test "invalid option prints message and usage instructions" {
  run withTransaction --invalid-option
    [ $status -eq 2 ]
    [ "${lines[0]}" = 'ERROR: Unknown option "--invalid-option"!' ]
    [ "${lines[2]%% *}" = 'Usage:' ]
}

@test "-h prints long usage help" {
  run withTransaction -h
    [ $status -eq 0 ]
    [ "${lines[0]%% *}" != 'Usage:' ]
}
