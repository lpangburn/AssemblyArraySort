.data

# CONSOLE PROMPT DECLARATIONS  
prompt1:    .asciiz "Enter 0 to sort in descending order.\nEnter any other number to sort in ascending order.\n"
prompt2:    .asciiz "Enter a number:"	
array: 		.word 7, 9, 4, 3, 8, 1, 6, 2, 5
string1: 	.asciiz "Before Sort: \n"
string2: 	.asciiz "\nAfter Sort: \n"
newLine:	.asciiz "\n"

# REGISTER NOTES:
# $s0 = address of the array
# $s1 = number of elements in the array	
# $s2 = input from user for ascending or descending (0 for descending, else for ascending)
# $s3 = flag for sorted vs. unsorted. 0 if unsorted, 1 if sorted

	
	.globl main 
	.text 		

# The label 'main' represents the starting point
main:

	addi $s1, $zero, 9		# set $s1 to 9 permenantly to represent the number of elements in the array

# display startup message
	li	$v0, 4				# syscall code for print_string
	la	$a0, prompt1		# point $a0 to enter number string
	syscall					# print the string
	
# display prompt message
	li	$v0, 4				# syscall code for print_string
	la	$a0, prompt2		# point $a0 to prompt string
	syscall					# print the prompt
	
# get an integer from the user
	li	$v0, 5				# code for read_int
	syscall					# get an int from user --> returned in $v0
	move $s2, $v0			# move the resulting int to $s0

# Display the "before sort" text
	la	$a0, string1		# point $a0 to string1
	li	$v0, 4				# syscall code for print_string	
	syscall					# display string1

#######PRINT LOOP FUNCTION#######
#########ASCENDING ORDER#########

printArray:	
	
	la, $s0, array			# load array into &s0
	add $t0, $zero, $zero	# set $t0 to zero to act as index counter
	
	
printloop:

	lw 	$a0, ($s0)			# set pointer to beginning of array in register $a0
	
	addi $v0, $zero, 1		# set $v0 to 1 (print integer)
	syscall					# print integer located at $a0
	
	addi $a0, $zero, 32		# set $a0 to 32 (an ASCII space)
	addi $v0, $zero, 11		# set $v0 to 11 to print char
	syscall
	
	addi $t0, $t0, 1		# increment index counter by 1
	addi $s0, $s0, 4		# increment $s0 by 4, indicating the next int to be read
	
	blt $t0, $s1, printloop
	
	li	$v0, 4				# syscall code for print_string
	la	$a0, newLine		# point $a0 to print a new line
	syscall	
	
	beq $s3, 1, exitSys		# if sorted flag is set to 1, call system exit

#################################
#################################


#########SORT THE ARRAY##########
# $t0 used as current outer loop counter
# $t1 used as the current value at the outer loop index
# $t2 used as current inner loop counter
# $t3 used as the current value at the inner loop index
# $t4 used in swap as the outer loop value to swap
# $t5 used in swap as the inner loop value to swap
# $t6 used as the inner minimum value
# $t7 used as the index of the inner minimum value
# $t8 used in memoryLogic as the offset value
# $t9 used in memoryLogic as the temporary location of the start of the array

# Set up initial registers
	la $s0, array			# load array into $a0
	addi $t0, $zero, 0		# set outer loop counter to 0
	addi $t2, $zero, 0		# set inner loop counter to 0
	
	
# Begin sort:

outerLoop:

	move $a0, $t0			# move outer loop counter to $a0 (argument register)
	jal memoryLogic			# get the item at the outer loop index and return it in $v0
	lw $t1, 0($v0)			# load the value at the current outer loop index into $t1
	
	addi $t2, $t0, 1		# add 1 to the outer loop counter
	move $a0, $t2			# move inner loop counter to $a0 (argument register)
	jal memoryLogic			# get the value at the inner loop index and return it in $v0
	lw $t6, 0($v0)			# load the value at the next index position to $t6. $t6 holds the inner minimum value
	
	add $t7, $t2, $zero		# copy the inner loop counter to $t7 to represent the index position of the minimum value
	
innerLoop:
	
	move $a0, $t2			# move inner loop counter to $a0 (argument register) 
	jal memoryLogic			# get the value at the inner loop index and return it in $v0
	lw $t3, 0($v0)			# load the value at the current inner loop index into $t3
	
	bge $t3, $t6, skipLT	# if the element at $t3 is greater than $t6 (minimum value), do not change the minimum value
	add $t6, $t3, $zero		# if the element at $t3 is less than the current minimum at $t6, save that value into $t6 as the new minimum
	add $t7, $t2, $zero		# if the element at $t3 is less than the current minimum at $t6, save the index into $t7 as the new minimum index
	
skipLT:						# skip if the current value is not less than the minimum value
	addi $t2, $t2, 1		# increment inner loop index counter
	
	blt $t2, $s1, innerLoop	# if the inner loop counter is less than the number of elements in the array, repeat the innerLoop 
	
	add $t4, $zero, $t0		# put the index of the outer loop in $t4
	add $t5, $zero, $t7		# put the index of the minimum value of this loop in $t5
	blt $t6, $t1, swap		# after the inner loop completes, swap the lowest element with the current outer loop
	
completeSwap:
	addi $t0, $t0, 1		# increment outer loop counter
	
	blt $t0, $s1, outerLoop # if outer loop counter is less than number of elements in the array, repeat outer loop
	j cont					# after outer loop completes, jump to cont (continue)
	
# swap logic to swap two elements in the array
swap:
	move $a0, $t4			# move the value at register $t4 to $a0 in order to get the memory value of $t4 from memoryLogic
	jal memoryLogic			# run memoryLogic on the value in $t4 and return it into $v0
	lw $s6, 0($v0)			# load the element at memory address $v0 returned from memoryLogic
	add $s7, $zero, $v0		# put the memory address at $v0 into $s7 
	
	move $a0, $t5			# repeat this process, with the second element to be swapped
	jal memoryLogic			# run memoryLogic on the value in $t5 and return it into $v0
	lw $s4, 0($v0)			# load the element at memory address $v0 returned from memoryLogic
	
	sw $s4, ($s7)			# store the value of $s4 in memory address $s7
	sw $s6, ($v0)			# store the value of $s6 in memory address at $v0
	
	j completeSwap
	
# memory logic (find the element at a certain position in memory given the offset in $a0, return that value in $v0)
memoryLogic:	
	move $v0, $zero			# make sure $v0 is clear
	la $t9, array			# load the array into $t9
	mul $t8, $a0, 4			# multiply the index (given in $a0) by 4 to find the location offset in memory, save it to $t8
	add $t8, $t8, $t9		# offset from the address in $t9 by the factor being stored in $t8, save this new location to $t8
	add $v0, $t8, $zero		# move the new address to $v0 (return register)
	move $t8, $zero			# clear register $t8
	
	jr $ra					# return to wherever this function is called from
	
	
cont:
	addi $s3, $zero, 1		# set $s3 to 1 to represented 'sorted'
	
#################################
#################################


######DISPLAY SORTED ARRAY#######

# Display the "after sort" text
	la $a0, string2			# point $a0 to string2
	li $v0, 4				# code for string2		
	syscall					# display string2
	
# If user entered 0 - display the list in descending order
	beq $s2, 0, printDesc	# If the user entered 0, branch to display descending order, else continue to printAsc

printAsc:

# jump to printArray loop to print ascending sorted array
	j	printArray			# jump to beginning of printArray 

printDesc:
	
	add $t0, $zero, $zero	# set $t0 to zero to act as index counter
	la $s0, array			# load array into &s0 
	
printDescLoop:
	lw $a0, 32($s0)			# set pointer to end of array in register $a0
	
	addi $v0, $zero, 1		# set $v0 to 1 (print integer)
	syscall					# print integer located at $a0
	
	addi $a0, $zero, 32		# set $a0 to 32 (an ASCII space)
	addi $v0, $zero, 11		# set $v0 to 11 to print char
	syscall
	
	addi $t0, $t0, 1		# increment index counter by 1
	addi $s0, $s0, -4		# increment $s0 by 4, indicating the next byte to be read
	
	blt $t0, $s1, printDescLoop
	
	li	$v0, 4				# syscall code for print_string
	la	$a0, newLine		# point $a0 to print a new line
	syscall	

#################################	
#################################


exitSys:
	addi $v0, $zero, 10		# set $v0 to 10 (exit)
	syscall