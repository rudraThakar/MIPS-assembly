.data
  prompt1: .asciiz "Enter N : "
 
.text
main:
  la $a0, prompt1 
  addi $v0, $zero, 4
  syscall
  
  addi $v0, $zero, 5
  syscall
  move $a0, $v0
  
  jal factorial
  
  move $a0, $v0
  
  li $v0, 1
  syscall
  
  li $v0, 10
  syscall
  
factorial:
  addi $sp, $sp, -8    #store the $ra and arguement(n) in the stack
  sw $ra, 4($sp)
  sw $a0, 0($sp)
  add $t0, $zero, $a0    #t0 stores n
  
  ble $t0, 1, base_case
  
  addi $t0, $t0, -1
  move $a0, $t0
  jal factorial
  
  lw $a0, 0($sp)    #load the original n
  mul $v0, $a0, $v0
  j end
  
base_case:
  li $v0, 1
  
end:
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  jr $ra
  
  
  
  
   