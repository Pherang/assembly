#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm basepoint
rm basepoint.o
as --32 basepoint.s -o basepoint.o &&
ld -m elf_i386 basepoint.o -o basepoint
