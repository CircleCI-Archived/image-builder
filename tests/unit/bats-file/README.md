# bats-file

[![GitHub license](https://img.shields.io/badge/license-CC0-blue.svg)](https://raw.githubusercontent.com/ztombol/bats-file/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/ztombol/bats-file.svg)](https://github.com/ztombol/bats-file/releases/latest)
[![Build Status](https://travis-ci.org/ztombol/bats-file.svg?branch=master)](https://travis-ci.org/ztombol/bats-file)

`bats-file` is a helper library providing common filesystem related
assertions and helpers for [Bats][bats].

Assertions are functions that perform a test and output relevant
information on failure to help debugging. They return 1 on failure and 0
otherwise. Output, [formatted][bats-support-output] for readability, is
sent to the standard error to make assertions usable outside of `@test`
blocks too.

Features:
- [assertions](#usage)
- [temporary directory handling](#working-with-temporary-directories)

Dependencies:
- [`bats-support`][bats-support] - output formatting, function call
  restriction

See the [shared documentation][bats-docs] to learn how to install and
load this library.


## Usage

### `assert_file_exist`

Fail if the given file or directory does not exist.

```bash
@test 'assert_file_exist()' {
  assert_file_exist /path/to/non-existent-file
}
```

On failure, the path is displayed.

```
-- file does not exist --
path : /path/to/non-existent-file
--
```


### `assert_file_not_exist`

Fail if the given file or directory exists.

```bash
@test 'assert_file_not_exist() {
  assert_file_not_exist /path/to/existing-file
}
```

On failure, the path is displayed.

```
-- file exists, but it was expected to be absent --
path : /path/to/existing-file
--
```


## Working with temporary directories

When testing code that manipulates the filesystem, it is good practice
to run tests in clean, throw-away environments to ensure correctness and
reproducibility. Therefore, this library includes convenient functions
to create and destroy temporary directories.


### `temp_make`

Create a temporary directory for the current test in `BATS_TMPDIR`. The
directory is guaranteed to be unique and its name is derived from the
test's filename and number for easy identification.

```
<test-filename>-<test-number>-<random-string>
```

This information is only available in `setup`, `@test` and `teardown`,
thus the function must be called from one of these locations.

The path of the directory is displayed on the standard output and is
meant to be captured into a variable.

```bash
setup() {
  TEST_TEMP_DIR="$(temp_make)"
}
```

For example, for the first test in `sample.bats`, this snippet creates a
directory named `sample.bats-1-XXXXXXXXXX`, where each trailing `X` is a
random alphanumeric character.

If the directory cannot be created, the function fails and displays an
error message on the standard error.

```
-- ERROR: temp_make --
mktemp: failed to create directory via template ‘/etc/samle.bats-1-XXXXXXXXXX’: Permission denied
--
```

#### Directory name prefix

The directory name can be prefixed with an arbitrary string using the `--prefix
<prefix>` option (`-p <prefix>` for short).

```bash
setup() {
  TEST_TEMP_DIR="$(temp_make --prefix 'myapp-')"
}
```

Following the previous example, this will create a directory named
`myapp-sample.bats-1-XXXXXXXXXX`. This can be used to group temporary
directories.

Generally speaking, the directory name is of the following form.

```
<prefix><test-filename>-<test-number>-<random-string>
```


### `temp_del`

Delete a temporary directory, typically created with `temp_make`.

```bash
teardown() {
  temp_del "$TEST_TEMP_DIR"
}
```

If the directory cannot be deleted, the function fails and displays an
error message on the standard error.

```
-- ERROR: temp_del --
rm: cannot remove '/etc/samle.bats-1-04RUVmBP7x': No such file or directory
--
```

_**Note:** Actually, this function can be used to delete any file or
directory. However, it is most useful in deleting temporary directories
created with `temp_make`, hence the naming._

#### Preserve directory

During development, it is useful to peak into temporary directories
post-mortem to see what the tested code has done.

When `BATSLIB_TEMP_PRESERVE` is set to 1, the function succeeds but the
directory is not deleted.

```bash
$ BATSLIB_TEMP_PRESERVE=1 bats sample.bats
```

#### Preserve directory on failure

During debugging, it is useful to preserve the temporary directories of
failing tests.

When `BATSLIB_TEMP_PRESERVE_ON_FAILURE` is set to 1, the function
succeeds but the directory is not deleted if the test has failed.

```bash
$ BATSLIB_TEMP_PRESERVE_ON_FAILURE=1 bats sample.bats
```

The outcome of a test is only known in `teardown`, therefore this
feature can be used only when `temp_del` is called from that location.
Otherwise and error is displayed on the standard error.


## Transforming displayed paths

Sometimes paths can be long and tiresome to parse to the human eye. To
help focus on the interesting bits, all functions support hiding part of
the displayed paths by replacing it with an arbitrary string.

A single [pattern substitution][bash-pe] is performed on the path before
displaying it.

```
${path/$BATSLIB_FILE_PATH_REM/$BATSLIB_FILE_PATH_ADD}
```

The longest match of the pattern `BATSLIB_FILE_PATH_REM` is replaced
with `BATSLIB_FILE_PATH_ADD`. To anchor the pattern to the beginning or
the end, prepend `#` or `%`, respectively.

For example, the following example hides the path of the temporary
directory where the test takes place.

```bash
setup {
  TEST_TEMP_DIR="$(temp_make)"
  BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  BATSLIB_FILE_PATH_ADD='<temp>'
}

@test 'assert_file_exist()' {
  assert_file_exist "${TEST_TEMP_DIR}/path/to/non-existent-file"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}
```

On failure, only the relevant part of the path is shown.

```
-- file does not exist --
path : <temp>/path/to/non-existent-file
--
```


<!-- REFERENCES -->

[bats]: https://github.com/sstephenson/bats
[bats-support-output]: https://github.com/ztombol/bats-support#output-formatting
[bats-support]: https://github.com/ztombol/bats-support
[bats-docs]: https://github.com/ztombol/bats-docs
[bash-pe]: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
