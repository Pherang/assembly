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

open_fd_in:
##Open input file
#The fd suffix stands for file descriptor
#open syscall
movl $SYS_OPEN, %eax
#input filename into %ebx
movl ST_ARGV_1(%ebp), %ebx
#read-only flag
movl $O_RDONLY, %ecx
#this next line doesn't really matter for reading
movl $0666, %edx
#call linux
int $LINUX_SYSCALL

store_fd_in:
#save the input file descriptor
movl %eax, ST_FD_IN(%ebp)

open_fd_out:
#OPEN OUTPUT FILE
#open the file
movl $SYS_OPEN, %eax
#output filename into %ebx
movl ST_ARGV_2(%ebp), %ebx
#flags for writing to the file
movl $O_CREAT_WRONLY_TRUNC, %ecx
#mode for new file (if it's created)
movl $0666, %edx
#call linux
int $LINUX_SYSCALL

store_fd_out:
#store the output file descriptor here
movl %eax, ST_FD_OUT(%ebp)

###BEGIN MAIN LOOP###
read_loop_begin:

#Read in a block from the input file
movl $SYS_READ, %eax
#get the input file descriptor
movl ST_FD_IN(%ebp), %ebx
#the location to read into.
movl $BUFFER_DATA, %ecx
#the size of the buffer
movl $BUFFER_SIZE, %edx
#Size of buffer read is returned in %eax
int $LINUX_SYSCALL

###NEXT if we've reached the end###
#check for the end of file marker
cmpl $END_OF_FILE, %eax
#if found or on error, go to the end
jle end_loop

continue_read_loop:
###CONVERT THE BLOCK TO UPPERCASE###
pushl $BUFFER_DATA
pushl %eax
call convert_to_upper
popl %eax
addl $4, %esp

###Write the block out to the output file###
#size of the buffer
movl %eax, %edx
movl $SYS_WRITE, %eax
#file to use
movl ST_FD_OUT(%ebp), %ebx
#location of the buffer
movl $BUFFER_DATA, %ecx
int $LINUX_SYSCALL

###Continue the loop###
jmp read_loop_begin

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

#PURPOSE This function actually does the conversion.
#INPUT: The first parameter is the location of the block
#of memory to convert.
#The second parameter is the length of that buffer

#Output: This function overwrites the current buffer
#with the uppercase version.

#Variables
# %eax - beginning of buffer
# %ebx - length of buffer
# %edi - current buffer offset
# %cl - current byte being examined first part of %ecx

#CONSTANTS
#The lower boundary of our search
.equ LOWERCASE_A, 'a'
#The upper boundary of our search
.equ LOWERCASE_Z, 'z'
#Conversion between upper and lower case
.equ UPPER_CONVERSION, 'A' - 'a'

#STACK STUFF#
.equ ST_BUFFER_LEN, 8 #length of buffer
.equ ST_BUFFER, 12    #actual buffer
convert_to_upper:
pushl %ebp
movl %esp, %ebp

#Setup variables
movl ST_BUFFER(%ebp), %eax
movl ST_BUFFER_LEN(%ebp), %ebx
movl $0, %edi

#if a buffer with a zero length was given to us just leave
cmpl $0, %ebx
je end_convert_loop

convert_loop:
#get the current byte
movb (%eax,%edi,1), %cl

#go to the next byte unless it is between
#'a' and 'z'
cmpb $LOWERCASE_A, %cl
jl next_byte
cmpb $LOWERCASE_Z, %cl
jg next_byte

#Otherwise convert the byte to uppercase
addb $UPPER_CONVERSION, %cl
#and store it back
movb %cl, (%eax,%edi,1)

next_byte:
incl %edi
cmpl %edi, %ebx

jne convert_loop

end_convert_loop:
#no return value, just leave
movl %ebp, %esp
popl %ebp
ret
