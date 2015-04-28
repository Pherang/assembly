#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm power
rm power.o
as --32 power.s -o power.o &&
ld -m elf_i386 power.o -o power
