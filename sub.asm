.data
	prompt1: .asciiz "a: "
	prompt2: .asciiz "b: "
	result: .asciiz "a-b: "
.text

.globl main
main:

    addi $v0, $zero, 4
    la $a0, prompt1
    syscall
    addi $v0, $zero, 5
    syscall
    move $s0, $v0
    
    
    addi $v0, $zero, 4
    la $a0, prompt2
    syscall
    addi $v0, $zero, 5
    syscall
    move $s1, $v0
    
    # register int k = i + j;
    sub $s2, $s0, $s1
    
    # print("a+b: " + k);
    addi $v0, $zero, 4
    la $a0, result
    syscall
    addi $v0, $zero, 1
    move $a0, $s2
    syscall
    
    #End the program
    addi $v0, $zero, 10
    syscall