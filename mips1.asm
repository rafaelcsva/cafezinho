move $s1, $sp
sw $s0, 0($sp)
addiu $sp, $sp, -4
b MAIN
fatorial:
move $fp, $sp
sw $ra, 0($sp)
addiu $sp, $sp, -4
lw $s0, 4($fp)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 0
lw $t1, 4($sp)
addiu $sp, $sp, 4
beq $s0, $t1, A1
li $s0, 0
b FIM_A1
A1:
li $s0, 1
FIM_A1:
beq $s0, 0, SENAO0
li $s0, 1
lw $ra, 0($fp)
move $sp, $fp
addiu $sp, $sp, 12
move $fp, $sp
addiu $sp, $sp, -8
jr $ra
b FIMSE0
SENAO0:
lw $s0, 4($fp)
sw $s0, 0($sp)
addiu $sp, $sp, -4
lw $s0, 4($fp)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 1
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal fatorial
lw $t1, 4($sp)
addiu $sp, $sp, 4
mult $s0, $t1
mflo $s0
lw $ra, 0($fp)
move $sp, $fp
addiu $sp, $sp, 12
move $fp, $sp
addiu $sp, $sp, -8
jr $ra
FIMSE0:
FIMfatorial:
MAIN:
addiu $sp, $sp, -4
li $s0, 3
sw $s0, -8($s1)
.data
	str0: .asciiz "O fatorial de "
.text
li $v0, 4
la $a0, str0
syscall
lw $s0, -8($s1)
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str2: .asciiz " e: "
.text
li $v0, 4
la $a0, str2
syscall
lw $s0, -8($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal fatorial
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str4: .asciiz "
"
.text
li $v0, 4
la $a0, str4
syscall