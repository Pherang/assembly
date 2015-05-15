#!/bin/bash
gdb --args ./build/upperfile ./upperfile.s ./upperfile.uppercase
echo $?
