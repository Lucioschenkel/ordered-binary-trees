	.data
	
FP_END_INICIAL: 
	.word	0x10040000			

MENSAGEM_INICIAL:
	.asciiz "Olá! \n Por favor, digite o tamanho da arvore a ser criada: "

MENSAGEM_OPCOES:
	.asciiz "Escolha uma das opções abaixo: \n1 - Imprimir arvore iinteira\n2 - Inserir vértice\n3 - Sair do programa\n"   						
	
	.text
	.globl main
	
main:
	# Escreva o programa principal (2 pontos) que inicializa os ponteiros para a pilha 
	# (o registrador $sp, usem o valor original sugerido pelo Mars) e para o heap 
	# (o registrador $fp, usem o valor 0x100400000, que é uma região de memória na qual o Mars permite acesso). 
	# Além disto, o programa principal deve chamar a função cria_arvore e deve permitir ao usuário escolher 
	# operações de inserção de novos vértices na árvore (chamado a função insere_vertice) e imprimir a árvore inteira
	#  (chamamdo a função imprime_arvore).
	
	# TODO:
	# initialize $fp with 0x100400000
	# Ask the user about the size of the tree
	# Call cria_arvore with that size
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
	
# ----------------------------------------------- Input reading -------------------------------------------------	
	addi	$sp,$sp,-8		# Allocates 4 bytes on the stack
	sw	$ra,0($sp)		# Stores the return address to the SO in the first position of the stack
	jal	le_inteiro		# Jump to subroutine that allows integer input reading
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	lw	$t0,4($sp)		# Recovers the user input from register $v0
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack

# ----------------------------------------------- Create tree ---------------------------------------------------		
	addi	$sp,$sp,-12		# Allocates 8 bytes on the stack
	sw	$ra,0($sp)		# Stores the return address to the OS in the first position of the stack
	sw	$t0,4($sp)		# Stores the integer input (size of the tree) in the second position of the stack
	jal	cria_arvore		# Jumps to subroutine that creates a new tree of the given size
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	lw	$t0,8($sp)		# Recovers the pointer to the newly generated tree from the stack
	addi	$sp,$sp,12		# 'Destroys' the allocated space on the stack
	
# ---------------------------------------------- Present options ------------------------------------------------
	addi	$sp,$sp,-8		# Allocates 8 bytes in the stack
	la	$t1,MENSAGEM_OPCOES	# Loads the address of the string to present options to the user
	sw	$ra,0($sp)		# Stores the return address to the OS in the first position of the stack
	sw	$t1,4($sp)		# Stores the address of the text to be printed in the stack's second position
	jal	imprime_texto		# Jumps to subroutine that allows string printing
	lw	$ra,0($sp)		# Recovers the return address to the OS from the stack
	addi	$sp,$sp,8		# 'Destroys' the allocated space on the stack

# ------------------------------------------------ Read option --------------------------------------------------		
	
	li	$v0,10
	syscall
	
# @param numero_vertcies - 4($sp)
# @returns pointer_to_tree - 4($sp)
# @side generates a tree with random elements in memory address pointed by $fp	
cria_arvore:
	# recebe como parâmetro apenas o número de vértices de uma árvore binária 
	# a ser criada. A partir destes parâmetros, a função produz os elementos desta 
	# árvore (usando chamadas do sistema para geração de dados aleatórios, ver item 4 abaixo) 
	# e retorna um ponteiro para a árvore, que deve ter sido criada em memória e alocada na 
	# região de heap do processador (a escolha desta região é tarefa do programa principal)
	jr	$ra
	
# @param ponteiro_matriz - 4($sp)
# @returns void
# @side inserts a vertice in the tree pointed by the routine entry parameter	
insere_vertice:
	# A segunda função deve ser recursiva (de nome insere_vertice). 
	# Ela recebe um ponteiro para a raiz da árvore e um novo vértice a inserir nesta, 
	# na posição adequada, de forma a manter a árvore binária ordenada. 
	# Cuidado com os casos especiais, tal como não haver nenhum vértice ainda na árvore. 
	# Decidam o que fazer quando os valores de conteúdo de dois campos são idênticos 
	# (manter na subárvore direita, manter na subárvore esquerda ou descartar) 
	
# @param ponteiro_matriz - 4($sp)
# @returrns void		
imprime_arvore:
	# A terceira função também deve ser recursiva (de nome imprime_arvore). 
	# Ela recebe um ponteiro para a raiz da árvore binária e imprime todos os seus campos
	# de conteúdo em alguma ordem (2 pontos).			
	
imprime_texto:
	lw	$a0, 4($sp)	# Recovers the text address from the stack
	li	$v0,4		# System call for string printing
	syscall			# Executes the system call
	jr	$ra		# Jump back to caller

le_inteiro:
	li	$v0,5		# System call identifier for integer input
	syscall			# Execute the system call
	sw	$v0,4($sp)	# Stores the user input in the second position of the stack
	jr	$ra		# Returns to caller
																																																																											