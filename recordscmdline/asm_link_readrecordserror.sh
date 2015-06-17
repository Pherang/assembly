#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/read-records-error
rm read-records-error.o
rm write-newline.o
rm read-record.o
rm count-chars.o
as --32 count-chars.s -o count-chars.o &&
as --32 read-records-error.s -o read-records-error.o &&
as --32 read-record.s -o read-record.o &&
as --32 write-newline.s -o write-newline.o &&
ld -m elf_i386 read-record.o read-records-error.o count-chars.o write-newline.o -o ./build/read-records-error
