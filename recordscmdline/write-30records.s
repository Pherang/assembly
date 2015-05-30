.include "linux.s"
.include "record-def.s"

.section .data

#Constant data of the records we want to write.
#Each text data item is padded to the proper length with null 
#bytes

# .rept is used to pad each item .rept tells
# the assembler to repeat the section between
# .rept and .endr the number of times specified.
# Thisis used in this program to add extra null characters
# at the end of each field to fill it up.

record1:
	.ascii "Frederick\0"
	.rept 30 #Padding to 40 bytes
	.byte 0
	.endr

	.ascii "Bartlett\0"
	.rept 31
	.byte 0
	.endr

	.ascii "4242 S Prairie\nTulsa, OK 55555\0"
	.rept 209
	.byte 0
	.endr
	
	.long 65

file_name:
	.ascii "test30.dat\0"

	.equ ST_FILE_DESCRIPTOR, -4

.section .text
.globl _start

_start:

#Standard stack operations
movl %esp, %ebp
subl $4, %esp

#open the file
movl $SYS_OPEN, %eax
movl $file_name, %ebx
movl $03101, %ecx	#This creates file if it doesn't exist
movl $0666, %edx
int $LINUX_SYSCALL

#Store the file descriptor away
movl %eax, ST_FILE_DESCRIPTOR(%ebp)

movl $0, %edi
#Write the record 30 times

write_loop_begin:
pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record1
call write_record
addl $8, %esp

incl %edi

cmpl $30, %edi
je write_loop_end

jmp write_loop_begin

write_loop_end:
#Close the file descriptor
movl $SYS_CLOSE, %eax
movl ST_FILE_DESCRIPTOR(%ebp), %ebx
int $LINUX_SYSCALL

#Exit the program
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL
