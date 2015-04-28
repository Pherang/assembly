#PURPOSE: Find the maximum value of the numbers in a list.
#

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

data_items:		#These are the data items. Note that 5 is the end.
	.long 3,67,34,245,45,75,54,34,44,33,22,11,66,5

.section .text

.global _start
_start:
	movl $13, %edi			# The list item is at index 13
	movl data_items(,%edi,4), %ecx  # Put the last item's address into %ecx

	movl $0, %edi			# move 0 into the index register
	movl data_items(,%edi,4), %eax	# load the first byte of data
	movl %eax, %ebx			# since this is the first item
					# %eax is the largest.
	

start_loop:
	cmpl %ecx, %eax			# check to see if we hit the end.
	je loop_exit
	incl %edi			# load the next value
	movl data_items(,%edi,4), %eax	
	cmpl %ebx, %eax			# compare the values.
	jle start_loop			# jump to loop beginning if new one isn'					# bigger
	movl %eax, %ebx			# move the value as the largest
	jmp start_loop			# jump to loop beginning

loop_exit:
# %ebx is the register for the status code of the exit system call
# and it already has the maximum number
# The number 1 in register %eax is required for the exit system call
# Once those two registers have values contained the interrupt is called and the# program exits
	movl $1, %eax
	int $0x80
