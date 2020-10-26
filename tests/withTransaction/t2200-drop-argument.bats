#!/usr/bin/env bats

load fixture

@test "one argument is dropped from the passed simple command in all occurrences" {
    run withTransaction --transacted-file "$FILE" --drop-argument bar -- echo foo bar barbara bar quux
    [ $status -eq 0 ]
    [ "$output" = "foo barbara quux" ]

}

@test "three arguments are dropped from the passed simple command" {
    run withTransaction --transacted-file "$FILE" --drop-argument -a --drop-argument -A --drop-argument --all -- echo -a -b -A -B --all --bar
    [ $status -eq 0 ]
    [ "$output" = "-b -B --bar" ]

}

@test "an argument that does not occur in the passed simple command is ignored" {
    run withTransaction --transacted-file "$FILE" --drop-argument here --drop-argument doesNotExist --drop-argument there -- echo there foo quux here
    [ $status -eq 0 ]
    [ "$output" = "foo quux" ]

}

@test "arguments are not dropped from the passed command-lines" {
    run withTransaction --transacted-file "$FILE" --drop-argument bar --drop-argument uname -c "echo we go to a bar" -c uname -- uname echo foo bar quux
    [ $status -eq 0 ]
    [ "$output" = "we go to a bar
$(uname)
foo quux" ]
}
