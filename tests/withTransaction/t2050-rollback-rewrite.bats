#!/usr/bin/env bats

load fixture

@test "a failing command's changes to the file are rolled back and a hard link is kept by default" {
    rm --force -- "${FILE}.link"
    echo -e 'all\ninitial' > "$FILE"
    run withTransaction --transacted-file "$FILE" --rollback-on-failure -c 'sed -i y/ainlt/AINLT/ {}; cp --link -- {} {}.link; false'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait

    assert_file "all
initial"
    cmp --silent -- "$FILE" "${FILE}.link"
}

@test "a failing command's changes to the file are rolled back and a hard link can be broken" {
    rm --force -- "${FILE}.link"
    echo -e 'all\ninitial' > "$FILE"
    run withTransaction --rewrite --transacted-file "$FILE" --rollback-on-failure -c 'sed -i y/ainlt/AINLT/ {}; cp --link -- {} {}.link; false'
    [ $status -eq 1 ]
    [ "$output" = "" ]
    wait

    assert_file "all
initial"
    ! cmp --silent -- "$FILE" "${FILE}.link"
    [ "$(cat -- "${FILE}.link")" = "ALL
INITIAL" ]
}
