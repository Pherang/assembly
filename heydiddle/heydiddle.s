# PURPOSE: Convert a files contents to uppercase.
#	
# PROCESS: 
#	   1) Open an input file
#	   2) Open an output file
#	   3) While we're not at the end of the input file,
#	      read part of the file into memory.
#	      Go through each byte of memory.
#	      If the byte is in lowercase convert it to upper case.
#	      Write the memory buffer to the output file.
.section .data 
#CONSTANTS

#system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

#Options for open system call. Options can be combined by ORing.
#/usr/include/asm/fcntl.h has more values
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

#Standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

#The phrase

phrase:
	.ascii "Hey diddle diddle! The cat hates the fiddle!\0"


#System call interrupt
.equ LINUX_SYSCALL, 0x80

.equ END_OF_FILE, 0 #Return value when EOF is read.

.equ NUMBER_ARGUMENTS, 2

.section .bss
#BUFFER: This is where data is loaded into 
#from the data file and written from into 
#the output file. Should never exceed 16,000 
#for various reasons.
.equ BUFFER_SIZE, 50
.lcomm BUFFER_DATA, BUFFER_SIZE

#Remember .text is an assembler directive for code and instructions.
.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.globl _start

_start:

#INITIALIZE PROGRAM
#save the stack pointer

movl %esp, %ebp

#allocate space for file descriptors on stack
subl $ST_SIZE_RESERVE, %esp

open_files:

open_fd_out:
#OPEN OUTPUT FILE
#open the file
movl $SYS_OPEN, %eax
#output filename into %ebx
movl ST_ARGV_1(%ebp), %ebx
#flags for writing to the file
movl $O_CREAT_WRONLY_TRUNC, %ecx
#mode for new file (if it's created)
movl $0666, %edx
#call linux
int $LINUX_SYSCALL

store_fd_out:
#store the output file descriptor here
movl %eax, ST_FD_OUT(%ebp)

##My own function or loop to read data into the buffer
#Need to use the %cl register to read each byte
#Will need to check the byte for termination char
#Will need to record size of buffer read.

read_phrase:
#Read a byte into the register.
movb phrase(,%edi,1), %cl
cmpb $0, %cl
je write_phrase
movb %cl, BUFFER_DATA(,%edi,1)
incl %edi
jmp read_phrase


write_phrase:
###Write the block out to the output file###
#size of the buffer
movl %edi, %edx
movl $SYS_WRITE, %eax
#file to use
movl ST_FD_OUT(%ebp), %ebx
#location of the buffer
movl $BUFFER_DATA, %ecx
int $LINUX_SYSCALL


end_loop:
###Close the files###
#NOTE: we don't need to do error checking
# on these, because error conditions
# don't signify anything special here
movl $SYS_CLOSE, %eax
movl ST_FD_OUT(%ebp), %ebx
int $LINUX_SYSCALL

movl $SYS_CLOSE, %eax
movl ST_FD_IN(%ebp), %ebx
int $LINUX_SYSCALL

###EXIT###
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

