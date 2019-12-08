move $s1, $sp
addiu $sp, $sp, -8
li $s0, 1
sw $s0, 0($s1)
ENQUANTO0:
lw $s0, 0($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 0
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bgtz $s0, A0
li $s0, 0
b FIM_A0
A0:
li $s0, 1
FIM_A0:
beq $s0, 0, FIMENQUANTO0
.data
	str0: .asciiz "Digite um numero "
.text
li $v0, 4
la $a0, str0
syscall
.data
	str1: .asciiz "
"
.text
li $v0, 4
la $a0, str1
syscall
li $v0, 5
syscall
sw $v0, 0($s1)
lw $s0, 0($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 0
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bgtz $s0, A1
li $s0, 0
b FIM_A1
A1:
li $s0, 1
FIM_A1:
beq $s0, 1, ENQUANTO0
FIMENQUANTO0:
.data
	str2: .asciiz "O fatorial de "
.text
li $v0, 4
la $a0, str2
syscall
lw $s0, 0($s1)
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str4: .asciiz " e: "
.text
li $v0, 4
la $a0, str4
syscall
.data
	str5: .asciiz "
"
.text
li $v0, 4
la $a0, str5
syscall