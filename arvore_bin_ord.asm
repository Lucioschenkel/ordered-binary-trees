	.data
	
FP_END_INICIAL: 
	.word	0x10040000			

MENSAGEM_INICIAL:
	.asciiz "Olá! \n Por favor, digite o tamanho da arvore a ser criada: "

MENSAGEM_OPCOES:
	.asciiz "Escolha uma das opções abaixo: \n1 - Imprimir arvore iinteira\n2 - Inserir vértice\n3 - Sair do programa\n"  

TAMANHO_INVALIDO:
	.asciiz "Tamanho inválido. Por favor, escolha um número inteiro maior ou igual a zero: "		 							 								 							 						
	
	.text
	.globl main
	
main:
	# Escreva o programa principal (2 pontos) que inicializa os ponteiros para a pilha 
	# (o registrador $sp, usem o valor original sugerido pelo Mars) e para o heap 
	# (o registrador $fp, usem o valor 0x100400000, que é uma região de memória na qual o Mars permite acesso). 
	# Além disto, o programa principal deve chamar a função cria_arvore e deve permitir ao usuário escolher 
	# operações de inserção de novos vértices na árvore (chamado a função insere_vertice) e imprimir a árvore inteira
	#  (chamamdo a função imprime_arvore).
	
	# TODO
	# Alow user to insert new vertice or print the current tree
	
# -------------------------------------------- Data Initialization ----------------------------------------------	
	la	$t0,FP_END_INICIAL
	lw	$fp,0($t0)		# Initialize $fp to 0x10040000
	addi	$sp,$sp,-8		# Allocates eight bytes on the stack
	sw	$ra,0($sp)		# Stores the return address to the SO in the first position of the stack
	
# ---------------------------------------------- Welcome Message ------------------------------------------------	
	la	$t0,MENSAGEM_INICIAL	# Loads the address of the welcome message in $t0
	sw	$t0,4($sp)		# Saves the address of the welcome message in the second position of the stack
	jal	imprime_texto 		# Jumps to the leaf subroutine that allows text printing on the screen 
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack

le_tamanho:		
# ----------------------------------------------- Input reading -------------------------------------------------	
	addi	$sp,$sp,-8		# Allocates 4 bytes on the stack
	sw	$ra,0($sp)		# Stores the return address to the SO in the first position of the stack
	jal	le_inteiro		# Jump to subroutine that allows integer input reading
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	lw	$t0,4($sp)		# Recovers the user input from register $v0
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack
	slt	$t2,$t0,$zero		# Tests if the input is a negative number
	bne	$t2,$zero,trata_tm_inv  # If it is, present an error message to the user

criacao:		
# ----------------------------------------------- Create tree ---------------------------------------------------		
	addi	$sp,$sp,-12		# Allocates 8 bytes on the stack
	sw	$ra,0($sp)		# Stores the return address to the OS in the first position of the stack
	sw	$t0,4($sp)		# Stores the integer input (size of the tree) in the second position of the stack
	jal	cria_arvore		# Jumps to subroutine that creates a new tree of the given size
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	lw	$t0,8($sp)		# Recovers the pointer to the newly generated tree from the stack
	addi	$sp,$sp,12		# 'Destroys' the allocated space on the stack

loop:		
# ---------------------------------------------- Present options ------------------------------------------------
	addi	$sp,$sp,-8		# Allocates 8 bytes in the stack
	la	$t1,MENSAGEM_OPCOES	# Loads the address of the string to present options to the user
	sw	$ra,0($sp)		# Stores the return address to the OS in the first position of the stack
	sw	$t1,4($sp)		# Stores the address of the text to be printed in the stack's second position
	jal	imprime_texto		# Jumps to subroutine that allows string printing
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack

# ------------------------------------------------ Read option --------------------------------------------------		
	addi	$sp,$sp,-8		# Allocates 8 bytes in the stack
	sw	$ra,0($sp)		# Stores the return address to the OS on the first position of the stack
	jal	le_inteiro		# Jumps to subroutine that allows integer input reading
	lw	$ra,0($sp)		# Recovers the returrn address to the OS from the stack
	lw	$t1,4($sp)		# Recovers the users option from the stack
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack
	
# --------------------------------------------- Handle user option ----------------------------------------------	
	addi	$t2,$zero,3		# Sets the content of $t2 equals to 3
	beq	$t1,$t2,fim		# If option is equals to three, exits program
	
	j	loop			# Go to the beggining of the loop
	
fim:			
	li	$v0,10
	syscall

# This subroutine takes in the size of a tree, creates it, and then returns a pointer to the root		
# @param numero_vertcies - 4($sp)
# @returns pointer_to_tree - 8($sp)
# @side generates a tree with random elements in memory address pointed by $fp	
cria_arvore:
	lw	$a2, 4($sp)		# Loads the size of the tree to be created in $a0
	beq	$a2,$zero,arvore_pronta	# If the size is zero, no need to create nodes
	addu	$t3,$zero,$zero		# Initializes the counter of created elements to zero
	li	$a0, 0			# i.d of the pseudo-random number generator
	li	$a1, 0x44ff11aa		# sets the seed of the pseudo-random number generator
	li	$v0, 40			# Loads 40 in $vo (system call identifier for setting 
					# the seed of pseudo-random number generator
	syscall 			# Executes the system call		
	
cria_vertices:
	beq	$t3,$a2,arvore_pronta	# If the counter $t3 is equals to number of vertices, stop creating nodes
	li	$a0, 0			# Loads the identifier of the pseudo-random number generator in $a0
	li	$a1, 100		# Loads the upper bound of random values in $a1
	li	$v0, 42 		# Loads the immediate 42 in register $v0 (system call identifier for
					# pseudo-random number generator in a given range
	syscall				# Executes the system call
	addi	$sp,$sp,-12		# Allocates 12 bytes on the stack
	sw	$ra,0($sp)		# Stores the current return address in the first position of the stack
	sw	$fp,4($sp)		# Stores the pointer to the tree in the second position of the stack
	sw	$a0,8($sp)		# Stores the value of the new node in the third position of the stack
	jal	insere_vertice		# Jumps to subroutine responsible for inserting a new node
	lw	$ra,0($sp)		# Recovers the return address from the stack
	addi	$sp,$sp,12		# 'Destroys' the allocated space on the stack
	addiu	$t3,$t3,1		# Increments the counter of the loop
	j	cria_vertices		# Jumps to the beggining of the loop						
	
arvore_pronta:
	sw	$fp,8($sp)		# Stores the pointer to the tree in the third position of the stack	
	jr	$ra

# This subroutine takes in a pointer to a tree root and and inserts a new node on the appropriate 
# position to keep the three organized.		
# @param ponteiro_matriz - 4($sp)
# @param {Number} - 8($sp) value of the node (Each node is 96 bits long. the first 32 are the 
# left pointer and the last the right pointer. The middle 32 bits are the value of the node) 
# @returns void
# @side inserts a vertice in the tree pointed by the routine entry parameter	
insere_vertice:
	lw	$a0,4($sp)		# Loads the pointer to the tree from the stack
	lw	$a1,8($sp)		# Loads the value of the new node
	lw	$t5,4($a0)		# Loads the content of the middle 32 bits of the current node
	seq	$t6,$t5,$zero		# Set $t6 if the content of the current node is 'NULL'
	bne	$t6,$zero,escreve_noh	# If $t6 is set, jump to write the element in the node
	slt	$t6,$a1,$t5		# Set $t6 if the new node value is smaller than the value of the current node
	bne	$t6,$zero,insere_esq	# If $t6 is set, recurr through the left
	sgt	$t6,$a1,$t5		# Set $t6 if the value of the new node is greater than the value of the current node
	bne	$t6,$zero,insere_dir	# If $t6 is set, recurr through the right
	j	finish_recursion	# Else, the value is equals and therefore ignored

escreve_noh:	
	sw	$a1,4($a0)		# Writes the value in the current node
	j	finish_recursion	# Finish recurring and returns				

insere_esq:
	lw	$t5, 0($a0)		# Loads the left pointer of the current node
	seq	$t6,$t5,$zero		# If the content of the current left pointer is zero, set $t6
	beq	$t6,$zero,recurr	# If $t6 is set, will recurr
	addi	$t6,$a0,12		# Make $t6 point to a new node after the current one
	sw	$t6,0($a0)		# Saves the address of the new node in the current left pointer
	sw	$a1,4($t6)		# Saves the value of the new node in address $t6 + 4 bytes
	j	finish_recursion	# Finish recurring	 

insere_dir:
	lw	$t5, 8($a0)		# Loads the right pointer of the current node
	seq	$t6,$t5,$zero		# If the content of the current left pointer is zero, set $t6
	beq	$t6,$zero,recurr	# If $t6 is set, will recurr
	addi	$t6,$a0,12		# Make $t6 point to a new node after the current one
	sw	$t6,8($a0)		# Saves the address of the new node in the current left pointer
	sw	$a1,4($t6)		# Saves the value of the new node in address $t6 + 4 bytes
	j	finish_recursion	# Finish recurring					
					
recurr:
	addi	$sp,$sp,-12		# Allocates 12 bytes in the stack
	sw	$ra,0($sp)		# Saves the current return address in the first position of the stack
	sw	$t5,4($sp)		# Saves the pointer to the next node in the second position of the stack
	sw	$a1,8($sp)		# Saves the value of the new node in the third position of the stack
	jal	insere_vertice		# Call insere_vertice recursively
	lw	$ra,0($sp)		# Recovers the return address from the stack
	addi	$sp,$sp,12		# 'Destroys' the allocated space on the stack
							
finish_recursion:
	jr	$ra			# Returns from recursion
	 

# This subroutine takes a pointer to a tree as a paremeter and prints it in the right order		
# @param ponteiro_matriz - 4($sp)
# @returrns void		
imprime_arvore:
	# A terceira função também deve ser recursiva (de nome imprime_arvore). 
	# Ela recebe um ponteiro para a raiz da árvore binária e imprime todos os seus campos
	# de conteúdo em alguma ordem (2 pontos).			

# This suborutine receives the address to a string and prints it to the screen 
# @param {Address} text - 4($sp) Address of the text to be printed
# @returns {void}		
imprime_texto:
	lw	$a0, 4($sp)	# Recovers the text address from the stack
	li	$v0,4		# System call for string printing
	syscall			# Executes the system call
	jr	$ra		# Jump back to caller

# This subroutine takes no paremeters, receives an integer input from the user
# and returns it.
# @param {void}
# @returns {Integer} user_input - 4($sp) The number entered by the user
le_inteiro:
	li	$v0,5		# System call identifier for integer input
	syscall			# Execute the system call
	sw	$v0,4($sp)	# Stores the user input in the second position of the stack
	jr	$ra		# Returns to caller

# This code_block treats the occurence of a tree size smaller than zero, such as -1
# In that occurence, the user is presented with an error message 
trata_tm_inv:
	addi	$sp,$sp,-8		# Allocates 8 bytes in the stack
	sw	$ra,0($sp)		# Saves the current return address in the first position of the stack
	la	$t2,TAMANHO_INVALIDO	# Loads the address of the invalid size message in $t2
	sw	$t2,4($sp)		# Puts the address of the error message in the second position of the stack
	jal	imprime_texto		# Jumps to the subroutine that allows string printing
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack
	j	le_tamanho		# Jumps back to the section responsible for reading the tree size																																																																																																																																																					
