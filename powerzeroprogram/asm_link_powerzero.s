#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm powerzero
rm powerzero.o
as --32 powerzero.s -o powerzero.o &&
ld -m elf_i386 powerzero.o -o powerzero
