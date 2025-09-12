.data
array:          .space 400        # Maximum 100 integers (4 bytes each)
n:              .word 0
prompt1:       .asciiz "Enter number of elements (n): "
prompt2:   .asciiz "Enter elements one by one : "
sorted_msg:     .asciiz "Sorted Array: "
space:          .asciiz " "
newline:        .asciiz "\n"

.text
.globl main

main:
    # Prompt for number of elements
    li $v0, 4
    la $a0, prompt1
    syscall
    
    # Read n
    li $v0, 5
    syscall
    move $t0, $v0        
    sw $t0, n
    
    # Check if n is valid
    blez $t0, exit_program
    
    # Prompt for elements
    li $v0, 4
    la $a0, prompt2
    syscall
    
    # Read array elements
    la $t1, array          # array pointer
    li $t2, 0              # counter
    
read_loop:
    bge $t2, $t0, read_done
    
    # Read integer
    li $v0, 5
    syscall
    
    # Store integer in array
    sw $v0, 0($t1)
    
    # Move to next position
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j read_loop

read_done:
    # Call quicksort on entire array
    la $a0, array          # array address
    li $a1, 0              # low index
    lw $a2, n
    subi $a2, $a2, 1       # high index (n-1)
    
    jal quicksort
    
    # Print sorted array
    li $v0, 4
    la $a0, sorted_msg
    syscall
    
    la $a0, array
    lw $a1, n
    jal print_array
    
exit_program:
    # Exit
    li $v0, 10
    syscall


# $a0 = array address, $a1 = low, $a2 = high
quicksort:
    # Save registers to stack
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)         
    sw $s1, 8($sp)         
    sw $s2, 12($sp)       
    sw $s3, 16($sp)        
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    # Base case: if low >= high, return
    bge $s1, $s2, quicksort_end
    
    # Call partition to get pivot index
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal partition
    move $s3, $v0          # save pivot index
    # Recursively sort left subarray (low to pivot-1)
    move $a0, $s0
    move $a1, $s1
    move $a2, $s3
    subi $a2, $a2, 1
    jal quicksort
    # Recursively sort right subarray (pivot+1 to high)
    move $a0, $s0
    move $a1, $s3
    addi $a1, $a1, 1
    move $a2, $s2
    jal quicksort

quicksort_end:
    # Restore registers from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra


# $a0 = array address, $a1 = low, $a2 = high
partition:
    # Save registers to stack
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)         # array address
    sw $s1, 8($sp)         # low
    sw $s2, 12($sp)        # high
    sw $s3, 16($sp)        # pivot value
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    # Get pivot element
    sll $t0, $s2, 2        
    add $t0, $s0, $t0      
    lw $s3, 0($t0)        #pivot
        
    move $t1, $s1          # i = low - 1
    subi $t1, $t1, 1
    move $t2, $s1          # j = low
    
partition_loop:
    bge $t2, $s2, partition_end
    
    # Get array[j]
    sll $t3, $t2, 2
    add $t3, $s0, $t3
    lw $t4, 0($t3)         # array[j]
    
    # If array[j] <= pivot
    bgt $t4, $s3, skip_swap
    
    addi $t1, $t1, 1       # i++
    
    # Swap 
    sll $t5, $t1, 2        # i * 4
    add $t5, $s0, $t5      # address of array[i]
    lw $t6, 0($t5)         # temp = array[i]
    
    sw $t4, 0($t5)         # array[i] = array[j]
    sw $t6, 0($t3)         # array[j] = temp

skip_swap:
    addi $t2, $t2, 1       # j++
    j partition_loop

partition_end:
    # Swap array[i+1] and array[high] (pivot)
    addi $t1, $t1, 1       # i++
    sll $t5, $t1, 2        # (i+1) * 4
    add $t5, $s0, $t5      # address of array[i+1]
    lw $t6, 0($t5)         # temp = array[i+1]
    
    sll $t7, $s2, 2        # high * 4
    add $t7, $s0, $t7      # address of array[high]
    lw $t8, 0($t7)         # array[high]
    
    sw $t8, 0($t5)         # array[i+1] = array[high]
    sw $t6, 0($t7)         # array[high] = temp
    
    # Return pivot index (i+1)
    move $v0, $t1
    
    # Restore registers from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# print_array procedure
# $a0 = array address, $a1 = size
print_array:
    move $t0, $a0          # array address
    move $t1, $a1          # size
    li $t2, 0              # counter
    
print_loop:
    beq $t2, $t1, print_done
    
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    addi $t3, $t2, 1
    bge $t3, $t1, no_space
    li $v0, 4
    la $a0, space
    syscall
    
no_space:
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j print_loop

print_done:
    
    li $v0, 4
    la $a0, newline
    syscall
    
    jr $ra