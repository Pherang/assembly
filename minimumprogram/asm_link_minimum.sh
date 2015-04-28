#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm minimum
rm minimum.o
as minimum.s -o minimum.o &&
ld minimum.o -o minimum
