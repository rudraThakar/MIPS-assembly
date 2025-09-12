# Write a MIPS assembly program that:
# 1. Reads two positive integers from the user:
# ○ N → numerator
# ○ D → denominator
# 2. Reduces the fraction N/D to its simplest form and displays it as p/q, where p and q have no
# common divisors other than 1.
# 3. If the fraction is already in simplest form, display it unchanged.



.data
prompt1:    .asciiz "Enter numerator (N): "
prompt2:    .asciiz "Enter denominator (D): "
output_msg:  .asciiz "Reduced fraction: "
slash:       .asciiz "/"
newline:     .asciiz "\n"

.text
.globl main

main:
    #Numerator
    li $v0, 4
    la $a0, prompt1
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0    # $S0 = N
    
    # Denominator
    li $v0, 4
    la $a0, prompt2
    syscall
    
    li $v0, 5
    syscall
    move $s1, $v0    # $S1 = D
    
    # Find minimum of N and D.
    #Move them to the arguement registers
    
    move $a0, $s0    #N
    move $a1, $s1    #D
    
    #if N<D -> use_n_as_min
    blt $s0, $s1, use_n_as_min
    move $a2, $s1    # use d as min
    j gcd

use_n_as_min:
    move $a2, $s0    # Use N as min

#LOGIC : Find the min(A, B). Starting from that number, the largest number which divides both A and B is the GCD(A, B)

gcd:
    # $a0 = N, $a1 = D, $a2 = current number to test
    jal find_gcd
    move $s2, $v0    # Store GCD in $s2
    
    # Obtain the Reduced Fraction
    div $s0, $s2     
    mflo $s0         
    
    div $s1, $s2     
    mflo $s1         
    
    # print result
    li $v0, 4
    la $a0, output_msg
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, slash
    syscall
    
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 10
    syscall

#Main Recursive logic whihc finds the GCD

find_gcd:
    
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)
    
    # Base case
    beq $a2, 1, gcd_found
    
    # Check A % candidate == 0
    div $a0, $a2
    mfhi $t0         # remainder of the division
    bne $t0, $zero, try_next_candidate
    
    # Check B % candidate == 0
    div $a1, $a2
    mfhi $t0         
    bne $t0, $zero, try_next_candidate
    
    #GCD found
    j gcd_found

gcd_found:
    move $v0, $a2
    lw $ra, 12($sp)
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 16
    jr $ra

try_next_candidate:
#check for find_gcd(n-1)
    addi $a2, $a2, -1    
    jal find_gcd
    # Result already in $v0, just restore
    lw $ra, 12($sp)
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 16
    jr $ra
