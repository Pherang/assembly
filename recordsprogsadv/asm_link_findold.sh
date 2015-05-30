#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/find-old
rm find-old.o
rm read-record.o
as --32 find-old.s -o find-old.o &&
as --32 read-record.s -o read-record.o &&
ld -m elf_i386 read-record.o find-old.o -o ./build/find-old
