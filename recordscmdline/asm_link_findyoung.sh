#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm ./build/find-young
rm find-young.o
rm read-record.o
as --32 find-young.s -o find-young.o &&
as --32 read-record.s -o read-record.o &&
ld -m elf_i386 read-record.o find-young.o -o ./build/find-young
