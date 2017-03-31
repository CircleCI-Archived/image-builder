#!/usr/bin/env bats

load ../test_helper_haskell
load ../bats-support/load
load ../bats-assert/load

@test "haskell: ghc 8.0.2 is installed" {
    run test_ghc_version 8.0.2

    assert_success
}

@test "haskell: happy 1.19.5 is installed" {
    run test_happy_version 1.19.5

    assert_success
}

@test "haskell: alex 3.1.7 is installed" {
    run test_alex_version 3.1.7

    assert_success
}

@test "haskell: cabal 1.24 is installed" {
    run test_cabal_version 1.24

    assert_success
}

@test "haskell: cabal parallel build is disabled" {
    run test_cabal_parallel_build_disabled

    assert_success
}

@test "haskell: stack is installed" {
    run test_stack_works

    assert_success
}
