#!/bin/bash

export FILE="${BATS_TMPDIR}/file"

fixtureSetup()
{
    > "$FILE"
    rm -f -- "${BATS_TMPDIR}/.file*.lock"
}
setup()
{
    fixtureSetup
}

assert_empty_file()
{
    [ ! -s "$FILE" ]
}
assert_file()
{
    if [ "$(cat -- "$FILE")" != "${1?}" ]; then
	dump_file
	return 1
    fi
}
dump_file()
{
    cat -- "$FILE" | prefix \# >&3
}
