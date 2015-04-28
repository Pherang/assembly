#!/bin/bash
# Remove the binary before attempting assemble and link it again.
# Testing
rm factorial
rm factorial.o
as --32 factorial.s -o factorial.o &&
ld -m elf_i386 factorial.o -o factorial
