#!/usr/bin/env bats

load ../test_helper_haskell

@test "haskell: ghc 8.0.1 is installed" {
    run test_ghc_version 8.0.1

    [ "$status" -eq 0 ]
}

@test "haskell: happy 1.19.5 is installed" {
    run test_happy_version 1.19.5

    [ "$status" -eq 0 ]
}

@test "haskell: alex 3.1.7 is installed" {
    run test_alex_version 3.1.7

    [ "$status" -eq 0 ]
}

@test "haskell: cabal 1.24 is installed" {
    run test_cabal_version 1.24

    [ "$status" -eq 0 ]
}

@test "haskell: cabal parallel build is disabled" {
    run test_cabal_parallel_build_disabled

    [ "$status" -eq 0 ]
}
