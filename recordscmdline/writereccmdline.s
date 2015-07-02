#This program will take input from STDIN
#and write the data to a file specified from the cmd line as well.

.include "linux.s"
.include "record-def.s"

.section .data

#Input file to be appended.
.equ ST_FILE_DESCRIPTOR, -4

.section .bss
#Record buffer to read from stdin.
.lcomm record_buffer, RECORD_SIZE 

.section .text
.globl _start

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

_start:

#Standard stack operations
movl %esp, %ebp
subl $4, %esp
#open the output file
movl $SYS_OPEN, %eax
movl ST_ARGV_1(%ebp), %ebx
movl $02002, %ecx	#This opens the file in read/write and append
movl $0666, %edx
int $LINUX_SYSCALL

#Store the file descriptor away
movl %eax, ST_FILE_DESCRIPTOR(%ebp)

#We will read three times from STDIN one for each field.
#The age can't be read from STDIN so we will create our own
movl $0, %edi
read_stdin:

cmpl $3, %edi
je end_read_stdin

#Read from stdin into the buffer using read_record function
pushl $0
pushl $record_buffer
call read_record
addl $8, %esp

#Padding loops
cmpl $0, %edi
je firstname_prep

cmpl $1, %edi
je lastname_prep

cmpl $2, %edi
je address_prep

firstname_prep:
movl $40, %ecx
movl $40, %edx
subl %eax, %ecx
jmp pad_firstname

lastname_prep:
movl $40, %ecx
movl $40, %edx
subl %eax, %ecx
jmp pad_lastname

address_prep:
movl $240, %ecx
movl $240, %edx
subl %eax, %ecx
jmp pad_address

pad_firstname:
cmpl $0, %ecx
je write_padded
addl $0, record_buffer
decl %ecx
jmp pad_firstname

pad_lastname:
cmpl $0, %ecx
je write_padded
addl $0, record_buffer
decl %ecx
jmp pad_lastname

pad_address:
cmpl $0, %ecx
je write_padded
addl $0, record_buffer
decl %ecx
jmp pad_address

write_padded:
#Write the record obtained from STDIN
pushl ST_FILE_DESCRIPTOR(%ebp)
pushl $record_buffer
pushl %edx
call write_record
addl $8, %esp

incl %edi
jmp read_stdin

end_read_stdin:
#Close the file descriptor
movl $SYS_CLOSE, %eax
movl ST_FILE_DESCRIPTOR(%ebp), %ebx
int $LINUX_SYSCALL

#Exit the program
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL
