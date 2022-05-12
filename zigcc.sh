#!/bin/bash

# This is a wrapper script that allows the Nim compiler to use the Zig C compiler as a backend.

zig cc "$@"
