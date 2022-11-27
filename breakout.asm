################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    512
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp) (FOR SOME REASON IT ONLY WORKS WHEN I WRITE THIS BUT SET IT TO THE OTHER
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    jal draw_first_round_red
    jal draw_walls
    li $a0, 65
    li $a1, 55
    jal draw_ball
    li $a0, 54
    jal draw_paddle
    
    j end
    
    
    

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    #b game_loop
    
draw_paddle:
	la $t0, ADDR_DSPL #put display address into t0
	li $a1, 60 #set y position
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	li $t1 0xffff55 #get the ball color
	sw $t1, 0($t0) #paint
	sw $t1, 4($t0) #paint
	sw $t1, 8($t0) #paint
	sw $t1, 12($t0) #paint
	sw $t1, 16($t0) #paint
	sw $t1, 20($t0) #paint
	sw $t1, 24($t0) #paint
	sw $t1, 28($t0) #paint
	sw $t1, 32($t0) #paint
   	jr $ra
    
draw_first_round_red:
	li $a2, 0xff0000
	li $t0, 10 #how many blocks wide
	li $t1, 6 #how many blocks high
	li $a0, 5 #first block x
	li $a1, 5 #first block y
	li $t2, 0 
	addi $t6, $ra, 0
first_round_loop_vert:
	beq $t2, $t1, end_first_round_loop_vert
	li $t3, 0
first_round_loop_horiz:
	beq $t3, $t0, end_first_round_loop_horiz
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	sw $t3, 20($sp)
	jal draw_block
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	lw $t3, 20($sp)
	addi $t3, $t3, 1
	addi $a0, $a0, 12
	j first_round_loop_horiz
end_first_round_loop_horiz:
 	addi $t2, $t2, 1
	addi $a1, $a1, 8
	li $a0, 5
 	j first_round_loop_vert
 end_first_round_loop_vert:
 	jr $t6


draw_block:
	#TODO or should ball position be in .data
	
	la $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	addi $t1, $t0, 0
	addi $t2, $t1, 0
	addi $t4, $t2, 2048
block_loop_y:
	beq $t2, $t4, end_block_loop_y
	addi $t3, $t2, 32
	addi $t1, $t2, 0
block_loop_x:
	beq $t1, $t3, end_block_loop_x
	sw $a2, 0($t1) #paint
	addi $t1, $t1, 4
	j block_loop_x
end_block_loop_x:
	addi $t2, $t2, 512
	j block_loop_y
end_block_loop_y:
	jr $ra
	
	        
draw_ball:
	#TODO or should ball position be in .data
	la $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	li $t1 0x33ff33 #get the ball color
	sw $t1, 0($t0) #paint
	jr $ra
	
draw_walls:
	la $t0, ADDR_DSPL
	li $t2 0xffffff
	addi $t1, $t0, 512
top_loop:
	beq $t0, $t1, end_top_loop
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j top_loop
end_top_loop:
	la $t0, ADDR_DSPL
	la $t1, ADDR_DSPL
	li $t1, 0x10018000
	li $t4, 0
side_loop:
	slt $t5, $t0, $t1
	beq $t5, $zero, end_side_loop
	sw $t2, 0($t0)
	addi $t0, $t0, 512
	sw $t2, 508($t0)
	addi $t4, $t4, 1
	j side_loop
end_side_loop:
	la $t0, ADDR_DSPL
	jr $ra
	
erase_ball:
	#TODO or should ball position be in .data
	la $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	li $t1 0x000000 #get the color black
	sw $t1, 0($t0) #paint
	jr $ra
	

end:




	
	
