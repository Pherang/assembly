#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/maximum3
rm maximum3.o
as --32 maximum3.s -o maximum3.o &&
ld -m elf_i386 maximum3.o -o ./build/maximum3
