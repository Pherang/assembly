#PURPOSE: Simple program that exists and returns to the linux kernel

#INPUT: none

#OUTPUT: returns status code. Can be seen by typing echo $?

#VARIABLES: %eax holds the system call number
#	    %ebx holds the return status
.section .data

.section .text

.globl _start
_start:
	movl $1, %eax	# This is the linux kernel
			# command number (system call)
			# for exiting a program

	movl $101, %ebx	# This is the status number returned.
			# Change this and it will return
			# different things to echo $?

	int $0x80	# This wakes up the kernel to run the 
			# exit command
