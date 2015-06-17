# This will read records from a file from the command line.
# It is also a test for error handling. 
# If no filename is specified the Open systemcall should catch this and exit with the error code.
# 
.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

error_code14:
.ascii "Error no file specified\0"

error_code2:
.ascii "Error specified filename doesn\'t exist\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE


.section .text
#main program
.globl _start
_start:

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

#These are the locations on the stack 
#where we will store the input and output descriptors
#FYI, we could have used memory addresses in a .data section instead
.equ ST_INPUT_DESCRIPTOR, -4
.equ ST_OUTPUT_DESCRIPTOR, -8

#Copy the stack pointer to %ebp
movl %esp, %ebp
#Allocate space to hold the file descriptors
subl $8, %esp

#Open the file
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $0, %ecx
movl $0666, %edx
int $LINUX_SYSCALL

#Check that a file descriptor has been returned. -14 appears to be an error

cmpl $-14, %eax
je error_reading14


cmpl $-2, %eax
je error_reading2
#Save the file descriptor

movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

#Even though its a constant we are saving the output file descriptor
#in a local variable (on the stack) so that if we later decide
#that it isn't always going to be STDOUT, we can change it easily.
movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

record_read_loop:
pushl ST_INPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call read_record
addl $8, %esp

#Returns the number of bytes read.
#If it isn't the same number we requested
#then its either an end-of-file or an error
#so we're quitting
cmpl $RECORD_SIZE, %eax
jne finished_reading

#Otherwise, print out the first name
#but first, we must know it's size
pushl $RECORD_FIRSTNAME + record_buffer
call count_chars
addl $4, %esp

#The write syscall needs the size of buffer to write.
#count_chars returns the size of the buffer.
#This size is put into %edx
movl %eax, %edx
movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
movl $SYS_WRITE, %eax
movl $RECORD_FIRSTNAME + record_buffer , %ecx
int $LINUX_SYSCALL

pushl ST_OUTPUT_DESCRIPTOR(%ebp)
call write_newline
addl $4, %esp

jmp record_read_loop

finished_reading:
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

error_reading14:

#The write syscall needs the size of buffer to write.
#This size is put into %edx since we counted the size of the error message to be 24 characters.

movl $24, %edx
movl $STDOUT, %ebx
movl $SYS_WRITE, %eax
movl $error_code14 , %ecx
int $LINUX_SYSCALL

#Write a new line for neatness
pushl $STDOUT 
call write_newline
addl $4, %esp

movl $0, %ebx
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL

error_reading2:

#The write syscall needs the size of buffer to write.
#This size is put into %edx since we counted the size of the error message to be 24 characters.

movl $42, %edx
movl $STDOUT, %ebx
movl $SYS_WRITE, %eax
movl $error_code2 , %ecx
int $LINUX_SYSCALL

#Write a new line for neatness
pushl $STDOUT 
call write_newline
addl $4, %esp

movl $0, %ebx
movl $SYS_EXIT, %eax
int $LINUX_SYSCALL
