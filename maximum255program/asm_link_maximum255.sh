#!/bin/bash
# Remove the binary before attempting assemble and link it again.
rm maximum255
rm maximum255.o
as maximum255.s -o maximum255.o &&
ld maximum255.o -o maximum255
