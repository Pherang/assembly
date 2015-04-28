#Purpose: Given a number compute its factorial.
#	  4 factorial is 4 * 3 *2 *1
#	  This program also demonstrates recursion.

.section .data

.section .text

.globl _start
.globl factorial

_start:
	pushl $3	# pushes one parameter onto the stack.
	call factorial	# call factorial function defined below.

	addl $4, %esp	# Resets the stack after factorial.
	movl %eax, %ebx # We want the result in our exit status.

	movl $1, %eax	# We want a 1 in %eax to setup an exit
	int  $0x80

#Funtion: Factorial

.type factorial,@function

factorial:
	pushl %ebp		# save %ebp (the return address) 

	movl %esp, %ebp		# This saves %esp's current value which was the 				# same as %ebp. We do this so we can use %ebp to 				# use base pointer addressing on the stack.

	movl 8(%ebp), %eax	# This moves the factorial number into %eax.
	
	cmpl $1, %eax		# Checks if we are at the base case of 1.
	je end_factorial

	decl %eax		# If not, decrease the value
	pushl %eax		# Push it on to stack to prep for factorial
	call factorial		# call the function again. Starting to recurse
	movl 8(%ebp), %ebx	# %eax has return calue so we reload parameter
				# into %ebx
	imull %ebx, %eax	# multiply that by the result of the last
				# call to factorialin %eax, which is good
				# since that's where return values go.

end_factorial:
	movl %ebp, %esp		# standard stack cleaning before returning
	popl %ebp		# %esp and %ebp need to be restored to previous
				# states
	ret			# this pops the return value and puts in %eip
