#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm square
rm square.o
as --32 square.s -o square.o &&
ld -m elf_i386 square.o -o square
