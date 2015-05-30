#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/add-year
rm add-year.o
as --32 add-year.s -o add-year.o &&
ld -m elf_i386 add-year.o read-record.o write-record.o -o ./build/add-year
