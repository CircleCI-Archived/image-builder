test_ghc_version () {
    local version=$1

    ghc --version | grep $version
}

test_happy_version () {
    local version=$1

    happy --version | grep $version
}

test_alex_version () {
    local version=$1

    alex --version | grep $version
}

test_cabal_version () {
    local version=$1

    cabal --version | grep $version
}

test_cabal_parallel_build_disabled () {
    grep -- '-- jobs:$ncpus' .cabal/config
}

test_stack_works () {
    stack --version
}
