#PURPOSE: To calculate a number to the power of another number
#	  and to learn about functions

# Everything in the main program will be stored in registers so no data to
# declare

.section .data

.section .text

.globl _start

_start:

	pushl   $0	# push second argument
	pushl 	$5	# push first argument
	call power      # call the function
	addl $8, %esp	# move stack pointer back. 
			# This overwrites the 3 and the 2

	pushl %eax	# save the first answer, 
			# result register before function call
	pushl $1
	pushl $4
	call power
	addl $8, %esp		

	popl %ebx	# The second answer is already in %eax
			# We saved the first answer onto the stack
			# so now we can just pop it into %ebx

	addl %eax, %ebx # add them together. The result is in %ebx

	movl $1, %eax
	int $0x80

#PURPOSE: This function is used to compute the value of a number raised
#	  to a power.
#
#
#INPUT:   First argument - the base number
#	  Second argument - the power to raise it to.
#
#OUTPUT:  Will give the result as a return value
#
#NOTES:   The power must be 1 or greater
#
#VARIABLES:
#	  %ebx - holds the base number
#	  %ecx - holds the power
#
#	  -4(%ebp) - holds the current result
#
#	  %eax is used for temporary storage
#
.type power, @function

power:
	pushl %ebp		# save old base pointer
	movl  %esp, %ebp	# put the stack pointer into base pointer
	subl  $4, %esp		# get room for local storage pushes pointer

	movl  8(%ebp), %ebx	# put the first argument in %eax
	movl  12(%ebp), %ecx	# put the second argument in %ecx

	movl  %ebx, -4(%ebp)	# store current result

power_loop_start:
	cmpl  $0, %ecx		# if the power is 0, the result is 1
	je    power_zero
	
	cmpl  $1, %ecx		# if the power is 1, we are done
	je    end_power
	
	movl  -4(%ebp), %eax	# move current result into %eax
	imull %ebx, %eax	# multiply current result by base number
	
	movl  %eax, -4(%ebp)     # store the current result

	decl  %ecx		# decrease the power
	jmp   power_loop_start	# run for the next power

power_zero:
	movl $1, -4(%ebp)
	jmp end_power		

end_power:
	movl  -4(%ebp), %eax    # return value goes into %eax
	movl  %ebp, %esp	# restore the stack pointer
	popl  %ebp		# restore the base pointer
	ret
