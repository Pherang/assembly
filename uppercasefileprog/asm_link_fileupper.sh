#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/upperfile
rm upperfile.o
as --32 upperfile.s -o upperfile.o &&
ld -m elf_i386 upperfile.o -o ./build/upperfile
