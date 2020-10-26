#!/usr/bin/env bats

load fixture

@test "a second readonly invocation while another is still running proceeds immediately" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --read-only -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait

    assert_file "second
first"
}

@test "second and third readonly invocations while another is still running proceeds immediately" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first -c 'sleep 2; echo first >> {}' &
    sleep 0.1
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner second -c 'sleep 1; echo second >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --read-only -c 'echo third >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ] || { echo "$output" | prefix \# >&3; }
    wait

    assert_file "third
second
first"
}

@test "a second mutable invocation while another readonly is still running waits until the first is done" {
    withTransaction --transacted-file "$FILE" --read-only --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait

    assert_file "first
second"
}

@test "a second readonly invocation while another mutable is still running waits until the first is done" {
    withTransaction --transacted-file "$FILE" --transaction-owner first -c 'sleep 1; echo first >> {}' &
    sleep 0.1
    run withTransaction --transacted-file "$FILE" --read-only -c 'echo second >> {}'
    [ $status -eq 0 ]
    [ "$output" = "" ]
    wait

    assert_file "first
second"
}
