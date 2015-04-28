#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm exit
rm exit.o
as exit.s -o exit.o &&
ld exit.o -o exit
