#Purpose: To add a year to records that are read in.
#	Additionally it will read and write to the same file using the LSEEK system call.
#	Register %edi will be used to track and maneouver the file offset.
#Input: A file specified
#
#Output: An output file called testout.dat that contains the modified data.

.include "linux.s"
.include "record-def.s"

.section .data

.section .bss
.lcomm record_buffer, RECORD_SIZE


#These are the locations on the stack 
#where we will store the input and output descriptors
#FYI, we could have used memory addresses in a .data section instead
.equ ST_INPUT_DESCRIPTOR, -4
.equ ST_OUTPUT_DESCRIPTOR, -8
.equ ST_BUFFER_LOCATION, -12

.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.equ O_RDWR, 02

#Main program
.globl _start
_start:

#Copy the stack pointer to %ebp
movl %esp, %ebp
#Allocate space to hold the file descriptors
subl $8, %esp

#Open the input file
#We'll open the same file for input and output. We also
#specify the file using the cmdline.
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $O_RDWR, %ecx
movl $0666, %edx
int $LINUX_SYSCALL

#Save the file descriptor
movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

#Throughout the loop everytime we read or write the file we incremement or decrement %edi 
#by the bytes written or read.

loop_begin:
pushl ST_INPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call read_record
addl $8, %esp
addl %eax, %edi

#Returns the number of bytes read.
#If it isn't the same number we requested
#then its either an end-of-file or an error
#so we're quitting
cmpl $RECORD_SIZE, %eax
jne loop_end

#Increment age
incl record_buffer + RECORD_AGE

subl %eax, %edi

#Move file position back
movl $19, %eax
movl ST_INPUT_DESCRIPTOR(%ebp), %ebx
movl %edi, %ecx
movl $0, %edx
int $LINUX_SYSCALL

#Write the record out
pushl ST_INPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call write_record
addl $8, %esp


#Move file position to the end of the record that was modified.
addl %eax, %edi

movl $19, %eax
movl ST_INPUT_DESCRIPTOR(%ebp), %ebx
movl %edi, %ecx
movl $0, %edx
int $LINUX_SYSCALL

jmp loop_begin

loop_end:
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL
