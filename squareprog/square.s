# Purpose: Function that produces the square of a number.
#	   This will also have a main section to demo the function. 	   

# Design Notes: 
#	
# The program will push a number and call the function.
# When it returns with %eax containing the square
# we will put it into %ebx as the status code
# put 1 into $eax and then call an interrupt. 
#

.section .data

.section .text

.globl _start

.globl square_number

_start:

	pushl $11		# Push the number to be squared.
	call square_number	# Call the square function.
	
	addl $4, %esp		# Clean up the stack. Since we have one param
				# We can just add 4.

	movl %eax, %ebx		# Setup the %ebx register with status code
	movl $1, %eax		# Setup %eax with 1
	int $0x80		# Call the interrupt to exit the program.


.type square_number,@function

square_number:
	pushl %ebp		# standard function startup. 
				# Save the old %ebp		
	movl %esp, %ebp		# %ebp now has reference point of old %ebp

	movl 8(%ebp), %eax	# Copy the number to be squared into %eax
	imull %eax, %eax	# Multiple %eax by itself to square it.

	movl %ebp, %esp		# Standard stack prep for return
	popl %ebp
	ret
	

