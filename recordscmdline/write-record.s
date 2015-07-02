.include "record-def.s"
.include "linux.s"

#PURPOSE: This function writes a record from the file descriptor
#INPUT:   The file descriptor and buffer
#OUTPUT:  This function writes the data to the buffer and
#	  returns a status code.

#STACK LOCAL VARIABLES
.equ ST_BUFFSIZE, 8
.equ ST_WRITE_BUFFER, 12
.equ ST_FILEDES, 16

.section .text
.globl write_record
.type write_record, @function

write_record:
pushl %ebp
movl %esp, %ebp

pushl %ebx
movl ST_FILEDES(%ebp), %ebx
movl ST_WRITE_BUFFER(%ebp), %ecx
movl ST_BUFFSIZE(%ebp), %edx
movl $SYS_WRITE, %eax
int $LINUX_SYSCALL

#NOTE: %eax has the return value, which we will return to calling process
popl %ebx

movl %ebp, %esp
popl %ebp
ret
