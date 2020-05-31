	.data
	
FP_END_INICIAL: 
	.word	0x10040000			

MENSAGEM_INICIAL:
	.asciiz "Olá! \n Por favor, digite o tamanho da arvore a ser criada: "

MENSAGEM_OPCOES:
	.asciiz "\nEscolha uma das opções abaixo: \n1 - Imprimir arvore inteira\n2 - Inserir vértice\n3 - Sair do programa\n"  

TAMANHO_INVALIDO:
	.asciiz "Tamanho inválido. Por favor, escolha um número inteiro maior ou igual a zero: "

VIRGULA:
	.asciiz ","					 							 								 							 						
	
	.text
	.globl main
	
main:	
# -------------------------------------------- Data Initialization ----------------------------------------------	
	la	$t0,FP_END_INICIAL
	lw	$fp,0($t0)			# Initialize $fp to 0x10040000
	addi	$sp,$sp,-8			# Allocates eight bytes on the stack
	sw	$ra,0($sp)			# Stores the return address to the SO in the first position of the stack
	
# ---------------------------------------------- Welcome Message ------------------------------------------------	
	la	$t0,MENSAGEM_INICIAL		# Loads the address of the welcome message in $t0
	sw	$t0,4($sp)			# Saves the address of the welcome message in the second position of the stack
	jal	imprime_texto 			# Jumps to the leaf subroutine that allows text printing on the screen 
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack

le_tamanho:		
# ----------------------------------------------- Input reading -------------------------------------------------	
	addi	$sp,$sp,-8			# Allocates 4 bytes on the stack
	sw	$ra,0($sp)			# Stores the return address to the SO in the first position of the stack
	jal	le_inteiro			# Jump to subroutine that allows integer input reading
	lw	$ra,0($sp)			# Recovers the return address to the OS from the stack
	lw	$t0,4($sp)			# Recovers the user input from register $v0
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack
	slt	$t2,$t0,$zero			# Tests if the input is a negative number
	bne	$t2,$zero,trata_tm_inv  	# If it is, present an error message to the user

criacao:		
# ----------------------------------------------- Create tree ---------------------------------------------------		
	addi	$sp,$sp,-12			# Allocates 8 bytes on the stack
	sw	$ra,0($sp)			# Stores the return address to the OS in the first position of the stack
	sw	$t0,4($sp)			# Stores the integer input (size of the tree) in the second position of the stack
	jal	cria_arvore			# Jumps to subroutine that creates a new tree of the given size
	lw	$ra,0($sp)			# Recovers the return address to the OS from the stack
	lw	$t0,8($sp)			# Recovers the pointer to the newly generated tree from the stack
	addi	$sp,$sp,12			# 'Destroys' the allocated space on the stack

loop:		
# ---------------------------------------------- Present options ------------------------------------------------
	addi	$sp,$sp,-8			# Allocates 8 bytes in the stack
	la	$t1,MENSAGEM_OPCOES		# Loads the address of the string to present options to the user
	sw	$ra,0($sp)			# Stores the return address to the OS in the first position of the stack
	sw	$t1,4($sp)			# Stores the address of the text to be printed in the stack's second position
	jal	imprime_texto			# Jumps to subroutine that allows string printing
	lw	$ra,0($sp)			# Recovers the return address to the OS from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack

# ------------------------------------------------ Read option --------------------------------------------------		
	addi	$sp,$sp,-8			# Allocates 8 bytes in the stack
	sw	$ra,0($sp)			# Stores the return address to the OS on the first position of the stack
	jal	le_inteiro			# Jumps to subroutine that allows integer input reading
	lw	$ra,0($sp)			# Recovers the returrn address to the OS from the stack
	lw	$t1,4($sp)			# Recovers the users option from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack
	
# --------------------------------------------- Handle user option ----------------------------------------------	
	addi	$t2,$zero,3			# Sets the content of $t2 equals to 3
	beq	$t1,$t2,fim			# If option is equals to three, exits program
	addi	$t2,$zero,1			# Sets the content of $t2 equals to 1
	bne	$t2,$t1,loop			# If option is not equals to one, continue
						# Else, print the three
	addi	$sp,$sp,-8			# Allocates 8 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack	
	sw	$t0,4($sp)			# Stores the pointer to the three in the second position of the stack
	jal	imprime_arvore			# Jumps to the subroutine that prints the tree
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space in the stack	
	
	j	loop				# Go to the beggining of the loop
	
fim:			
	li	$v0,10
	syscall

# This subroutine takes in the size of a tree, creates it, and then returns a pointer to the root		
# @param numero_vertcies - 4($sp)
# @returns pointer_to_tree - 8($sp)
# @side generates a tree with random elements in memory address pointed by $fp	
cria_arvore:
	lw	$a2, 4($sp)			# Loads the size of the tree to be created in $a0
	beq	$a2,$zero,arvore_pronta		# If the size is zero, no need to create nodes
	addu	$t3,$zero,$zero			# Initializes the counter of created elements to zero
	li	$a0, 0				# i.d of the pseudo-random number generator
	li	$a1, 0x44ff11aa			# sets the seed of the pseudo-random number generator
	li	$v0, 40				# Loads 40 in $v0 (system call identifier for setting the seed of pseudo-random number generator)
	syscall 				# Executes the system call		
	add	$t0,$zero,$fp			# Saves the value of the heap pointer in $t0
	
cria_vertices:
	beq	$t3,$a2,arvore_pronta		# If the counter $t3 is equals to number of vertices, stop creating nodes
	li	$a0, 0				# Loads the identifier of the pseudo-random number generator in $a0
	li	$a1, 100			# Loads the upper bound of random values in $a1
	li	$v0, 42 			# Loads the immediate 42 in register $v0 (system call identifier for pseudo-random number generator in a given range
	syscall					# Executes the system call
	
	addi	$sp,$sp,-12			# Allocates 12 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$t0,4($sp)			# Stores the pointer to the tree in the second position of the stack
	sw	$a0,8($sp)			# Stores the value of the new node in the third position of the stack
	jal	insere_vertice			# Jumps to subroutine responsible for inserting a new node
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,12			# 'Destroys' the allocated space on the stack	
	addiu	$t3,$t3,1			# Increments the counter of the loop
	j	cria_vertices			# Jumps to the beggining of the loop						
	
arvore_pronta:
	sw	$t0,8($sp)			# Stores the pointer to the tree in the third position of the stack
	jr	$ra

# This subroutine takes in a pointer to a tree root and and inserts a new node on the appropriate 
# position to keep the tree organized.		
# @param ponteiro_matriz - 4($sp)
# @param {Number} - 8($sp) value of the node (Each node is 96 bits long. the first 32 are the 
# left pointer and the last the right pointer. The middle 32 bits are the value of the node) 
# @returns void
# @side inserts a vertice in the tree pointed by the routine entry parameter	
insere_vertice:
	lw	$a0,4($sp)			# Loads the pointer to the tree from the stack
	lw	$a1,8($sp)			# Loads the value of the new node
	lw	$t5,4($a0)			# Loads the content of the middle 32 bits of the root node
	beq	$a1,$t5,finish_recursion	# If new node equals the root node, exit
	slt	$t6,$a1,$t5			# Set $t6 if the value of the new node is smaller than the root node
	bne	$t6,$zero,eh_menor		# If $t6 is set, the number is smaller than the root			
	sgt	$t6,$a1,$t5			# Set $t6 if the new node is greater than the root
	bne	$t6,$zero,eh_maior		# If $t6 is set, the number is greater than the root
	
eh_menor:
	lw	$t5,0($a0)			# Loads the content of the left pointer in $t5
	beq	$t5,$zero,sem_filho_esq		# If doesnt have a left child yet, create it
	addi	$sp,$sp,-12			# Allocates 12 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$t5,4($sp)			# Stores the address of the next node to be compared in the second position of the stack
	sw	$a1,8($sp)			# Stores the value of the node yet to be created in the third position of the stack
	jal	insere_vertice			# Call insere_vertice recursively
	lw	$ra,0($sp)
	addi	$sp,$sp,12
	jr	$ra

sem_filho_esq:
	sw	$fp,0($a0)			# Writes the address of the new node in the current left pointer
	sw	$zero,0($fp)			# Make the newly created node's left pointer null
	sw	$zero,8($fp)			# Make the newly create node's right pointer null
	sw	$a1,4($fp)			# Write the value of the new node
	addi	$fp,$fp,12			# Makes the heap pointer point to the next available position in memory
	jr	$ra		

sem_filho_dir:
	sw	$fp,8($a0)			# Writes the address of the new node in the current right pointer
	sw	$zero,0($fp)			# Make the newly created node's left pointer null
	sw	$zero,8($fp)			# Make the newly create node's right pointer null
	sw	$a1,4($fp)			# Write the value of the new node
	addi	$fp,$fp,12			# Makes the heap pointer point to the next available position in memory
	jr	$ra	
		
eh_maior:
	lw	$t5,8($a0)			# Loads the content of the right pointer in $t5
	beq	$t5,$zero,sem_filho_dir		# If doesnt have a right child yet, create it
	addi	$sp,$sp,-12			# Allocates 12 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$t5,4($sp)			# Stores the address of the next node to be compared in the second position of the stack
	sw	$a1,8($sp)			# Stores the value of the node yet to be created in the third position of the stack
	jal	insere_vertice			# Call insere_vertice recursively
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,12	
																																																																																																																																																																																																																																	
finish_recursion:
	jr	$ra				# Returns from recursion
	 

# This subroutine takes a pointer to a tree as a paremeter and prints it in the right order		
# @param ponteiro_matriz - 4($sp)
# @returrns void		
imprime_arvore:
	lw	$a1,4($sp)			# Loads the pointer to the node from the stack
	lw	$t5,0($a1)			# Loads the content at memory address ($a1) in $t5
	seq	$t6,$t5,$zero			# Set $t6 if the content of the left pointer is null
	bne	$t6,$zero,imprime_noh		# If the left pointer is null, print the current node
		
	addi	$sp,$sp,-12			# Allocates 12 bytes in the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$t5,4($sp)			# Stores the pointer of the left node in the second position of the stack
	sw	$a1,8($sp)			# Stores the current node in the stack
	jal	imprime_arvore			# Call imprime_arvore recursively
	lw	$ra,0($sp)			# Recovers the return address from the stack
	lw	$a1,8($sp)			# Recovers the start address of the node from the stack
	lw	$a0,4($a1)			# Loads the value of the current node in $a0 for printing
	addi	$sp,$sp,12			# 'Destroys' the allocated space on the stack
	
	li	$v0,1				# Loadsa 1 in $v0 (system call identifier for integer printing)
	syscall					# Execute the system call
	la	$a0,VIRGULA			# Loads the address of the text VIRGULA from the stack
	addi	$sp,$sp,-8			# Allocates 8 bytes in the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$a0,4($sp)			# Stores the address of the text to be printed in the second position of the stack
	jal	imprime_texto			# Jump to subroutine that allows string printing to the screen
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack

check_right:
		
	lw	$t5,8($a1)			# Loads the content of the right pointer in $t5
	seq	$t6,$t5,$zero			# Set $t6 if the content of the right pointer is null
	bne	$t6,$zero,finish_recursion	# If the right pointer is null, return to caller
	
	addi	$sp,$sp,-12			# Allocates 12 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$t5,4($sp)			# Stores the right pointer in the second position of the stack
	sw	$a1,8($sp)			# Stores the address of the node in the third position of the stack
	jal	imprime_arvore			# Call imprime_arvore recursively
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,12			# 'Destroys' the allocated space on the stack
	jr	$ra				# Return to caller
	
imprime_noh:
	lw	$a0, 4($a1)			# Loads the value of the node in $a0 for printing
	li	$v0, 1				# Loads immediate 1 in $v0 (system call identifier for integer printing
	syscall
	la	$a0, VIRGULA			# Loads the address of the string 'TRACO' in $a0 for printing
	addi	$sp,$sp,-8			# Allocates 8 bytes on the stack
	sw	$ra,0($sp)			# Stores the current return address in the first position of the stack
	sw	$a0,4($sp)			# Stores the address of the text to be printed in the first position of the stack
	jal	imprime_texto			# Jumps to subroutine that allows string printing to the screen
	lw	$ra,0($sp)			# Recovers the return address from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack	
	j	check_right			# Continue the tests and printing	
																													

# This suborutine receives the address to a string and prints it to the screen 
# @param {Address} text - 4($sp) Address of the text to be printed
# @returns {void}		
imprime_texto:
	lw	$a0, 4($sp)			# Recovers the text address from the stack
	li	$v0,4				# System call for string printing
	syscall					# Executes the system call
	jr	$ra				# Jump back to caller

# This subroutine takes no paremeters, receives an integer input from the user
# and returns it.
# @param {void}
# @returns {Integer} user_input - 4($sp) The number entered by the user
le_inteiro:
	li	$v0,5				# System call identifier for integer input
	syscall					# Execute the system call
	sw	$v0,4($sp)			# Stores the user input in the second position of the stack
	jr	$ra				# Returns to caller

# This code_block treats the occurence of a tree size smaller than zero, such as -1
# In that occurence, the user is presented with an error message 
trata_tm_inv:
	addi	$sp,$sp,-8			# Allocates 8 bytes in the stack
	sw	$ra,0($sp)			# Saves the current return address in the first position of the stack
	la	$t2,TAMANHO_INVALIDO		# Loads the address of the invalid size message in $t2
	sw	$t2,4($sp)			# Puts the address of the error message in the second position of the stack
	jal	imprime_texto			# Jumps to the subroutine that allows string printing
	lw	$ra,0($sp)			# Recovers the return address to the OS from the stack
	addi	$sp,$sp,8			# 'Destroys' the allocated space on the stack
	j	le_tamanho			# Jumps back to the section responsible for reading the tree size																																																																																																																																																					
