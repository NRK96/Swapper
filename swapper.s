# Author: Nicholas Keen
# Assignment 4
# Date: Nov 2, 2015

	.text
	.global _start
	.equ  EXIT, 1

_start:
	ldr r0, [sp]		@ argc value
	add r1, sp, #4		@ argv address
	bl main			@ call main
	mov r0, #0		@ success exit code
	mov r7, #EXIT
        svc 0			@ return to OS

# program to swap the values at two memory locations
# modifies r0, r1, r2

	.equ WRITE, 4
	.equ STDOUT, 1
	.equ STDERR, 2
main:
	push {r4, r5, r6, r7, lr} @ save registers and push return address
	mov r4, r1		@ save beginning of args array
	mov r5, r0		@ save the parameter count
	add r4, r4, #4		@ skip over program name
	sub r5, r5, #1		@ decrement parameter count
	cmp r5, #2		@ check for appropriate number of params
	beq	1f
#r0 is not equal to 2 here
	mov r0, #STDERR
	ldr r1, =ERROR		@ load error message for println
	bl println		@ call println
	mov r0, #-1		@ ensure non-zero output
	mov r7, #EXIT
	svc 0
1:
	ldr r0, [r4], #4	@ load the string address into r0
	bl atoi			@ if not, call atoi
	ldr r2, =A
	str r0, [r2]		@ store the first digit in A
	ldr r0, [r4], #4	@ load the next string address into r0
	bl atoi
	ldr r2, =B
	str r0, [r2]		@ store the second digit in B
	mov r0, #STDOUT
	ldr r1, =BEFORE
	bl print		@ prints before swap:
	mov r0, #STDOUT
	bl printAB		@ calls printAB
	ldr r0, =A		@ load the address of A into r0
	ldr r1, =B		@ load the address of B into r1
	bl swap			@ call swap
	mov r0, #STDOUT
	ldr r1, =AFTER
	bl print		@ prints after swap:
	mov r0, #STDOUT
	bl printAB		@ calls printAB
# done -- return
	pop {r4, r5, r6, r7, pc}@ return to caller

# swaps the values at memory locations A and B
# parameters
#	r0 - Address of memory location A
#	r1 - Address of memory location B
swap:
	ldr r2, [r0]		@ place A in r2
	ldr r3, [r1]		@ place B in r3
	str r2, [r1]		@ swap A with B
	str r3, [r0]		@ swap B with A


# determine string length
# parameters
#   r0:   address of null-terminated string
# returns
#   r0:   length of string (excluding the null byte)
# modifies r0, r1, r2
strlen:
	@ push {lr}
	mov r1, r0		@ address of string
	mov r0, #0		@ length to return
0:
	ldrb r2, [r1], #1	@ get current char and advance
	cmp r2, #0		@ are we at the end of the string?
	addne r0, #1
	bne 0b
# return
	@ pop  {pc}
	mov pc, lr		@ can do this instead of using the stack

# write a null-terminated string followed by a newline
# parameters
#   r0:  output file descriptor
#   r1:  address of string to print
# modifies r0, r1, r2
println:
	push {r4, r5, r7, lr}
# first get the string length
	mov r4, r0		@ save the fd
	mov r5, r1		@ and the string address
	mov r0, r1		@ the string address
	bl strlen		@ returns the string length in r0
	mov r2, r0		@ put length in r2 for the WRITE syscall
	mov r0, r4		@ restore the fd
	mov r1, r5		@ and the string address
	mov r7, #WRITE
	svc 0
	mov r0, r4		@ retrieve the fd
	adr r1, CR		@ get the address of the CR string
	mov r2, #1		@ one char to write
	mov r7, #WRITE
	svc 0
	pop {r4, r5, r7, pc}	@ restore registers and return to caller

# write a null terminated string
# parameters:
#	r0: output file descriper
#	r1: address of a string to print
# modifies: r0, r1, r2
print:
	push {r4, r5, r7, lr}
# first get the string length
	mov r4, r0		@ save the fd
	mov r5, r1		@ and the string address
	mov r0, r1		@ the string address
	bl strlen		@ returns the string length in r0
	mov r2, r0		@ put length in r2 for the WRITE syscall
	mov r0, r4		@ restore the fd
	mov r1, r5		@ and the string address
	mov r7, #WRITE
	svc 0
	pop {r4, r5, r7, pc}	@ restore registers and return to caller

# presents STDOUT with the contents of memory areas A and B
# parameters:
#	r0: file descriptor
printAB:
	push {r4, lr}
	mov r4, r0		@ save file descriptor
	ldr r0, =A
	ldr r0, [r0]		@ load A into r0
	ldr r1, =Abuff		@ where to convert to ASCII
	bl itoa
	ldr r0, =B		@ load B into r0
	ldr r0, [r0]		@ where to convert to ASCII
	ldr r1, =Bbuff
	bl itoa
	mov r0, r4		@ file descriptor
	ldr r1, =ALine		@ print the A line
	bl print
	mov r0, r4		@ file descriptor
	ldr r1, =BLine		@ print the B line
	bl print
	mov r0, r4		@ print a new line
	ldr r1, =CR
	bl print
	pop {r4, pc}

CR:	.asciz "\n"
ERROR:	.asciz "Inappropriate amount of command-line parameters"
BEFORE:	.asciz "Before Swap: "
AFTER:	.asciz "After Swap: "
	.align 2
	.data
A:	.word 0
B:	.word 0
ALine:	.ascii "A= "
Abuff:	.space 12
BLine:	.ascii " B= "
Bbuff:	.space 12
