#Program that will count the number of words in a file
	
	.data
fd:		.word						#file descriptor
fileBuffer:	.space	64					#block of text we will read

zeroMemory:	.byte	0:1
wordBuffer:	.space	26					#allocated space for word - 25 letters max+null terminator room
welcMessage:	.asciiz	"Enter the file name: "			#text message to welcome user to a nice experience
bytesRead:	.asciiz	"\nBytes read:	"
wordCount:	.asciiz	"\nTotal words in file: "
errMessage:	.asciiz	"File open failed, try again.\n"	#file open error :(
inMakeWord:	.asciiz	"\nIn make  word method"
inPrintWords:	.asciiz	"\n \t"
newLine:	.ascii	"\n"					#useful characters
nullTerm:	.ascii	"\0"
space:		.ascii	" "
tab:		.asciiz	":\t"
userInput:	.space	256
FirstWord:	.byte	1:1					#boolean flag that will let us know if we've saved a word or not - set to 0 in beginning only
notLastBuffer:	.byte	1:1					#another boolean flag we will use to avoid infinite loop


	.text
								#	$t1 	newline char
								
								#	$t1	also space char
								
								#	$t4	null terminator
								#	$s6	FILE DESCRIPTOR
main:
	
	la	$a0    welcMessage    				#prints prompt message
 	li	$v0,    4
 	syscall	
 	
 	li	$v0	8    					#takes string and stores it in userInput
	la	$a0,	userInput
	li	$a1,	256
 	syscall
 	
 	lb	$s0,	userInput				#Checks if there is user Input
 	lb	$t0,	newLine					#t1 holds newline
 	beq 	$s0,	$t1,	endProgram			#if user inputted nothing, closer the program
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
 	
 	la	$s0,	userInput
 	lb	$t4,	nullTerm
 	
 	jal	inputFormat					#sub-method for validating input
 	
 	li	$v0,	13
 	la	$a0,	userInput				#hopefully opens a file
 	li	$a1,	0
 	li	$a2,	0
 	syscall
 	
 	move	$s6,	$v0					#s6 now has the file descriptor
 	blt	$s6,	0,	fileError			#if file descriptor negative = file open error
 	
 	b	word_count
 	
fileError:
 	la	$a0    errMessage    				#file failed to open
 	li	$v0,    4
 	syscall	
 	b	main						#back to accepting input
 
 
inputFormat:							#USER INPUT TRAVERSAL
 	
 	add	$t3,	$s0,	$t5				#t3 will be the address of char+counter offset
 	lb	$t2, 	0($t3)					#t2 holds character
 	addi	$t5,	$t5,	1				#inrement char
 	
 	lb	$t1,	newLine
	beq	$t1,	$t2,	inputValidator			#once at end of word, move on to validating
	j	inputFormat					#if not at end (\n), loop again
 	
inputValidator:							#replaces newline with null terminator to be able to open file
 	sb	$t4	0($t3)
 	jr	$ra						#back up to main to continue file handling
word_count:
 	
 	li	$v0, 	14					# read from file
 	move	$a0,	$s6					#file descriptor used for reading
 	la	$a1,	fileBuffer				#where we will read the text
 	li	$a2,	64					#try to read 64 bytes
 	syscall
 	
 	move	$s2, $v0					#  bytes we actually read in s2

 	la	$s0,	fileBuffer				#address of what we just read into s0 to traverse
 	
 	li	$t3,	0					#clear t3 - 
 	li	$t5,	0					#t5 will be read buffer incrimentor (resdet to 0 every itteration)

 	
 	lb	$t1,	space					#clear newline register to put space char
 	beqz 	$s2,	lastWord				#end of file - stop reading
 	b	makeWord
 
 
makeWord:	
 	
 	lb	$t2,	notLastBuffer				#if we are no longer reading anything, go to print our results
 	beqz	$t2,	clearRegisters
								#FILE BUFFER TRAVERSAL
	
								
	add	$t3,	$s0,	$t5				#t3 will be the address of char+counter offset for the file buffer l
	lb	$t2, 	0($t3)					#t2 holds character
	addi	$t5,	$t5,	1				#inrement char

 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#		
	

	la	$s1,	wordBuffer				#s1 is address of buffer where word will be made
	
	add	$t7,	$s1,	$t6
	sb	$t2,	0($t7)					#save byte t2 at offsetted address in t7
	addi	$t6,	$t6,	1				#index incrimentor of word we are concatinating from file

	
	lb	$t1,	space
	beq	$t2,	$t1,	add_word			#word has been found, need to add to our list
	
	bgt	$t5,	$s2,	word_count			#if done reading memory from buffer, jump
	
	j	makeWord					#exit condition to keep reading bufffers
	
add_word:	
	
	
	addi	$s3,	$s3,	1				#incriment word count by 1 when we found a word
	
	lb	$t3,	space
	lb	$t4,	wordBuffer
	beq	$t4,	$t3,	word_space
	lb	$t3,	nullTerm
	beq	$t4,	$t3,	word_space
	
	lb	$t4,	nullTerm				#appends null term to the end of buffer, so if the previous word wass longer, ignores the trail
	sb	$t4,	0($t7)
	
	addi	$t6,	$t6,	1
	
	
	li	$t4,	0					#clear t4 which will be used when adding/comparing chars in word
	li	$t7,	0					#clear t7 - will also have
	li	$t3,	0
	
	lb	$t2,	FirstWord				#flag
	beq	$t2,	1,	alloc				#if first word we encountered, need to allocate first word in the heap
	
	jal	checkDups					
	
	b	alloc
	
	#jump to check if its a duplicate
	
	
	li	$t6,	0					#for now, reset the buffer so when loading next word, will start from beginning of buffer

	j	makeWord					#after current word was added, go back to buffer to continue reading

word_space:
	li	$t3,	0
	li	$t4,	0
	addi	$s3,	$s3,	-1
	
	j	indexReset


checkDups:


	jr	$ra


alloc:

	
	sb	$zero,	FirstWord				#after we allocate for the first time, turn flag off (repeatedly but it achieves the same thing)

	li	$a0, 36						#how big each node will be
	li	$v0, 9						#sberks our memory	v0 now has the address of the memory we just allocated
	syscall
	
	addi	$s4,	$v0,	8				#s4 now holds the address of node+offset where to write the word
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	li	$t2,	1
	sw	$t2,	0($v0)					#stores count of word as 1 inside of node
	
	#lw	$a0,	0($v0)
	#li	$v0,    1
 	#syscall	
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	
	j	newWord						#after space was allicated, need to add the actual word there


newWord:

	la	$s1,	wordBuffer				#s1 holds the current word in buffer
								#s4 already has address of Node buffer for our word
	
	#WORD BUFFER TRAVERSAL
	add	$t3,	$s1,	$t4				#t4 = incrimentor	t3= address of word buffer
	lb	$t2,	0($t3)
	
	
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
  
  	#NODE Loading in + traversing
  								#s4 is address of buffer that already exists. no need to load it again
  	add	$t7,	$s4,	$t4
  	sb	$t2,	0($t7)
  	
  	addi	$t4,	$t4,	1
  	
  	
  	beq	$t4,	$t6,	indexReset			#once we loaded x number of letters (t6 has word length), go back to finding words
	
	j	newWord						#loop again

indexReset:
	
	li	$t6,	0					#reset word buffer index for next word to be loaded in
	j	makeWord					#go back to loading in words into fresh un-incrimented word buffer

lastWord:


	
	sb	$zero,	notLastBuffer				#now falsz
	
	j	add_word


clearRegisters:

	lb	$t3,	nullTerm
	li	$t5,	8
	
	addi	$sp, $sp, -8					#allocate stack to put $s0 and $s1 on stack
	sw	$s0,	0($sp)
	sw	$s1,	4($sp)
	
	li	$s0,	0					#clear registers to use in printing traversal
	li	$s1,	0

	b	print_word_counts

print_word_counts:

	la	$a0    newLine    				#prints prompt message
 	li	$v0,    4
 	syscall	
	
	la	$s5,	0x10040000				#heap top address
	
	add	$s1,	$s5,	$s0				#running address for word count
	
	add	$s5,	$s5,	$t5				#running address for words
	
	
	
	lw	$t2,	0($s5)					#checks first byte of memory where we're at
	beq	$t2,	$t3,	loadRegisters
	
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	lb	$a0,	($s1)
	li	$v0,	1
	syscall
	
	la	$a0    tab    				#prints prompt message
 	li	$v0,    4
 	syscall	
	
	la	$a0,	($s5)					#print string at node index				
 	li	$v0,    4
 	syscall	
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
   
 	addi	$t5,	$t5,	36				#WHY IS IT 2 EXTRA BYTES
 	addi	$s0,	$s0,	36
 	b	print_word_counts


loadRegisters:

	lw	$s0,	0($sp)					#loads file buffer and word buffer back into registers
	lw	$s1,	4($sp)
	
	j	endProgram
	
endProgram:

	la	$a0    wordCount    				#prints prompt message
 	li	$v0,    4
 	syscall	
 	
	move	$a0,	$s3
 	li	$v0,    1
 	syscall	
 	
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#	
	li	$v0,	16					#closes the file
 	move	$a0,	$s6
 	syscall
 	
	li	$v0,	10
 	syscall                					#exits the program
	
