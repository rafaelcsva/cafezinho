move $s1, $sp
sw $s0, 0($sp)
addiu $sp, $sp, -60
b MAIN
LeVetor:
move $fp, $sp
sw $ra, 0($sp)
addiu $sp, $sp, -4
addiu $sp, $sp, -4
li $s0, 0
sw $s0, -120($s1)
ENQUANTO0:
lw $s0, -120($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A0
li $s0, 0
b FIM_A0
A0:
li $s0, 1
FIM_A0:
beq $s0, 0, FIMENQUANTO0
lw $s0, -120($s1)
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str1: .asciiz "
"
.text
li $v0, 4
la $a0, str1
syscall
lw $s0, -120($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 1
lw $t1, 4($sp)
addiu $sp, $sp, 4
add $s0, $t1, $s0
sw $s0, -120($s1)
lw $s0, -120($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A1
li $s0, 0
b FIM_A1
A1:
li $s0, 1
FIM_A1:
beq $s0, 1, ENQUANTO0
FIMENQUANTO0:
FIMLeVetor:
somaVetor:
move $fp, $sp
sw $ra, 0($sp)
addiu $sp, $sp, -4
addiu $sp, $sp, -4
li $s0, 0
sw $s0, -124($s1)
ENQUANTO1:
lw $s0, -124($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A2
li $s0, 0
b FIM_A2
A2:
li $s0, 1
FIM_A2:
beq $s0, 0, FIMENQUANTO1
lw $s0, -60($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
lw $s0, -80($s1)
lw $t1, 4($sp)
addiu $sp, $sp, 4
add $s0, $t1, $s0
sw $s0, 0($sp)
addiu $sp, $sp, -4
lw $a0, -800($s1)
lw $s0, -124($s1)
sll $s0, $s0, 2
addu $a1, $s0, $a0
lw $t1, 4($sp)
addiu $sp, $sp, 4
sw $t1, 0($a1)
lw $s0, -124($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 1
lw $t1, 4($sp)
addiu $sp, $sp, 4
add $s0, $t1, $s0
sw $s0, -124($s1)
lw $s0, -124($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A3
li $s0, 0
b FIM_A3
A3:
li $s0, 1
FIM_A3:
beq $s0, 1, ENQUANTO1
FIMENQUANTO1:
FIMsomaVetor:
imprimeVetor:
move $fp, $sp
sw $ra, 0($sp)
addiu $sp, $sp, -4
addiu $sp, $sp, -4
li $s0, 0
sw $s0, -128($s1)
ENQUANTO2:
lw $s0, -128($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A4
li $s0, 0
b FIM_A4
A4:
li $s0, 1
FIM_A4:
beq $s0, 0, FIMENQUANTO2
.data
	str2: .asciiz "O valor do elemento "
.text
li $v0, 4
la $a0, str2
syscall
lw $s0, -128($s1)
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str4: .asciiz " do vetor:"
.text
li $v0, 4
la $a0, str4
syscall
lw $s0, 4($fp)
li $v0, 1
addiu $a0, $s0, 0
syscall
.data
	str6: .asciiz "
"
.text
li $v0, 4
la $a0, str6
syscall
lw $s0, -128($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 1
lw $t1, 4($sp)
addiu $sp, $sp, 4
add $s0, $t1, $s0
sw $s0, -128($s1)
lw $s0, -128($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
li $s0, 5
lw $t1, 4($sp)
addiu $sp, $sp, 4
sub $s0, $t1, $s0
bltz $s0, A5
li $s0, 0
b FIM_A5
A5:
li $s0, 1
FIM_A5:
beq $s0, 1, ENQUANTO2
FIMENQUANTO2:
FIMimprimeVetor:
MAIN:
.data
	str7: .asciiz "Leitura do primeiro vetor"
.text
li $v0, 4
la $a0, str7
syscall
.data
	str8: .asciiz "
"
.text
li $v0, 4
la $a0, str8
syscall
lw $s0, -60($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal LeVetor
.data
	str9: .asciiz "Leitura do segundo vetor"
.text
li $v0, 4
la $a0, str9
syscall
.data
	str10: .asciiz "
"
.text
li $v0, 4
la $a0, str10
syscall
lw $s0, -80($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal LeVetor
lw $s0, -100($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
lw $s0, -80($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
lw $s0, -60($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal somaVetor
.data
	str11: .asciiz "O vetor soma:"
.text
li $v0, 4
la $a0, str11
syscall
.data
	str12: .asciiz "
"
.text
li $v0, 4
la $a0, str12
syscall
lw $s0, -100($s1)
sw $s0, 0($sp)
addiu $sp, $sp, -4
jal imprimeVetor
