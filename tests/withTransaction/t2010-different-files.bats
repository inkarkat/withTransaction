#!/usr/bin/env bats

load fixture

export FILE2="${BATS_TMPDIR}/file2"

setup()
{
    fixtureSetup
    > "$FILE2"
}

assert_file2()
{
    [ "$(cat -- "$FILE2")" = "${1?}" ]
}

@test "a second invocation with zero timeout but using a different file proceeds" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE2" --timeout 0 -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait
    assert_file "first"
    assert_file2 "second"
}
