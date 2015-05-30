#Purpose: To add a year to records that are read in.
#
#Input: A file specified
#
#Output: An output file called testout.dat that contains the modified data.

.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
.ascii "test.dat\0"

output_file_name:
.ascii "test.out\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE


#These are the locations on the stack 
#where we will store the input and output descriptors
#FYI, we could have used memory addresses in a .data section instead
.equ ST_INPUT_DESCRIPTOR, -4
.equ ST_OUTPUT_DESCRIPTOR, -8

.section .text
#Main program
.globl _start
_start:

#Copy the stack pointer to %ebp
movl %esp, %ebp
#Allocate space to hold the file descriptors
subl $8, %esp

#Open the input file
movl $SYS_OPEN, %eax
movl $input_file_name, %ebx
movl $0, %ecx
movl $0666, %edx
int $LINUX_SYSCALL

#Save the file descriptor

movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

#Open the output file
movl $SYS_OPEN, %eax
movl $output_file_name, %ebx
movl $0101, %ecx
movl $0666, %edx
int $LINUX_SYSCALL

#Save the file descriptor

movl %eax, ST_OUTPUT_DESCRIPTOR(%ebp)

loop_begin:
pushl ST_INPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call read_record
addl $8, %esp

#Returns the number of bytes read.
#If it isn't the same number we requested
#then its either an end-of-file or an error
#so we're quitting
cmpl $RECORD_SIZE, %eax
jne loop_end

#Increment age
incl record_buffer + RECORD_AGE

#Write the record out
pushl ST_OUTPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call write_record
addl $8, %esp

jmp loop_begin

loop_end:
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL
