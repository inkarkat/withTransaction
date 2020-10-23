#!/bin/bash

export FILE="${BATS_TMPDIR}/file"

setup()
{
    > "$FILE"
}
