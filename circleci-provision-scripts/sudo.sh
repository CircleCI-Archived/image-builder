#!/bin/bash

# This script ensures that the `circleci` user always has the ability to `sudo` without a password.
# In general this is already true, but we've observed mysterious permission issues when installing CUDA.
echo 'circleci ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/circleci