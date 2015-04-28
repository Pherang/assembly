#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/maximum
rm maximum.o
as --32 maximum.s -o maximum.o &&
ld -m elf_i386 maximum.o -o ./build/maximum
