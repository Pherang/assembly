#PURPOSE: Find the maximum value of the numbers in a list.
#	  We'll use function and  a pointer in the list

#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item to be examined
# %ebx - Largest data item found
# %eax - Current data item
# # The following memory locations are used: # data_items - contains the item data. A 0 is used to terminate the data
#

.section .data

data_items1:		#These are the data items. Note that 0 is the end.
	.long 246,67,34,245,54,45,54,34,44,33,22,11,66,0

data_items2:		#These are the data items. Note that 0 is the end.
	.long 123,69,34,246,76,75,54,34,44,33,22,11,66,0

data_items3:		#These are the data items. Note that 0 is the end.
	.long 240,68,34,100,45,75,54,34,56,44,45,23,36,0
.section .text

.global _start

.globl find_max


_start:
	pushl $data_items1	# This should put the start address of 
 	pushl $data_items2	# dta_items on the stack
 	pushl $data_items3	# dta_items on the stack
	call  find_max		# Call the function to search the list

	addl $4, %esp		# Clean up the stack.
	movl $1, %eax		# Setup %eax for call the kernel
	int  $0x80		# Interrupt x80. Control to kernel

.type find_max,@function

find_max:
	pushl %ebp		# Standard function prep. Save %ebp on stack
	movl %esp, %ebp		# Save current position to %ebp.	 
				# Remember 8(%ebp) would the start address
				# of data_items
	
	movl $0, %edi		# move 0 into the index register
	movl 8(%ebp), %ecx	# load the first byte of data movl %ecx, %eax
	movl (%ecx,%edi,4), %ebx		# since this is the first item
        movl %ebx, %eax		# %eax is the largest.

	start_loop:
	cmpl $0, %eax			# check to see if we hit the end.
	je loop_exit

	incl %edi			# load the next value
	movl (%ecx,%edi,4), %eax	# load the next byte of data
	cmpl %ebx, %eax			# compare the values.
	jle start_loop			# jump to loop beginning if new one isn'					# bigger
	movl %eax, %ebx			# move the value as the largest
	jmp start_loop			# jump to loop beginning

	loop_exit:
	movl %ebp, %esp
	popl %ebp
	ret
