#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/stdinupper
rm stdinupper.o
as --32 stdinupper.s -o stdinupper.o &&
ld -m elf_i386 stdinupper.o -o ./build/stdinupper
