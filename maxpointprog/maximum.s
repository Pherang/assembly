#PURPOSE: Find the maximum value of the numbers in a list.
#	  We'll use function and  a pointer in the list

#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item to be examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used: 
# data_items - contains the item data. A 0 is used to terminate the data
#

.section .data

data_items:		#These are the data items. Note that 0 is the end.
	.long 3,67,34,245,45,75,54,34,44,33,22,11,66,0

.section .text

.global _start

.globl find_max


_start:

	pushl data_items	# This should put the start address of 
				# data_items on the stack
	call  find_max		# Call the function to search the list

	addl $4, %esp		# Clean up the stack.

	movl %eax, %ebx		# Put the result into status code register
	movl $1, %eax		# Setup %eax for call the kernel
	int  $8x80		# Interrupt x80. Control to kernel


.type find_max,@function

find_max:
	pushl %ebp		# Standard function prep. Save %ebp on stack
	movl %esp, %ebp		# Save current position to %ebp.	 
				# Remember 8(%ebp) would the start address
				# of data_items
	
	movl $0, %edi			# move 0 into the index register
	movl data_items(,%edi,4), %eax	# load the first byte of data
	movl %eax, %ebx			# since this is the first item
					# %eax is the largest.

	start_loop:
	cmpl $0, %eax			# check to see if we hit the end.
	je loop_exit
	incl %edi			# load the next value
	movl data_items(,%edi,4), %eax	
	cmpl %ebx, %eax			# compare the values.
	jle start_loop			# jump to loop beginning if new one isn'					# bigger
	movl %eax, %ebx			# move the value as the largest
	jmp start_loop			# jump to loop beginning

	loop_exit:
	movl %ebp, %esp
	popl %ebp
	ret	