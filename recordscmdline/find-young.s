.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE


.section .text
#main program
.globl _start
_start:

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
movl $file_name, %ebx
movl $0, %ecx
movl $0666, %edx
int $LINUX_SYSCALL

#Save the file descriptor

movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

#Even though its a constant we are saving the output file descriptor
#in a local variable (on the stack) so that if we later decide
#that it isn't always going to be STDOUT, we can change it easily.
movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

movl $200, %edi

#Find the oldest person in the database
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

movl $RECORD_AGE + record_buffer, %ecx

cmpl %edi, (%ecx)
jge record_read_loop

movl (%ecx), %edi
jmp record_read_loop

finished_reading:
movl $SYS_EXIT, %eax
movl %edi, %ebx
int $LINUX_SYSCALL
