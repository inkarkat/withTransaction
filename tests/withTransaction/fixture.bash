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

assert_file()
{
    [ "$(cat -- "$FILE")" = "${1?}" ]
}
dump_file()
{
    cat -- "$FILE" | prefix \# >&3
}
