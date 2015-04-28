#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm maximum
rm maximum.o
as maximum.s -o maximum.o &&
ld maximum.o -o maximum
