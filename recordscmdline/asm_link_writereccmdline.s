#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/writereccmdline
rm writereccmdline.o
rm write-record.o
as --32 writereccmdline.s -o writereccmdline.o &&
as --32 write-record.s -o write-record.o &&
ld -m elf_i386 read-record.o write-record.o writereccmdline.o -o ./build/writereccmdline
