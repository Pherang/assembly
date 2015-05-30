#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/write-30records
rm write-30records.o
as --32 write-30records.s -o write-30records.o &&
as --32 write-record.s -o write-record.o &&
ld -m elf_i386 write-record.o write-30records.o -o ./build/write-30records
