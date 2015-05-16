#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/heydiddle
rm heydiddle.o
as --32 heydiddle.s -o heydiddle.o &&
ld -m elf_i386 heydiddle.o -o ./build/heydiddle
