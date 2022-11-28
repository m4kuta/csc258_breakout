################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: David Basil 1006900285
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
    li $a0, 65 #set x of the ball
    li $a1, 55 #set y of the ball
    jal draw_ball
    li $a0, 54 #set x of the paddle
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
	li $t2, 0 #number of rows of blocks drawn so far
	addi $t6, $ra, 0 #save the address that we'll be returning to bc we will use ra
first_round_loop_vert:
	beq $t2, $t1, end_first_round_loop_vert
	li $t3, 0 #number of blocks drawn so far
first_round_loop_horiz:
	beq $t3, $t0, end_first_round_loop_horiz
	sw $a0, 0($sp) #save stuff to the stack
	sw $a1, 4($sp)#save stuff to the stack
	sw $t0, 8($sp)#save stuff to the stack
	sw $t1, 12($sp)#save stuff to the stack
	sw $t2, 16($sp)#save stuff to the stack
	sw $t3, 20($sp)#save stuff to the stack
	jal draw_block #Call helper to draw a block at the coord a0 a1
	lw $a0, 0($sp)#return stuff from the stack
	lw $a1, 4($sp)#return stuff from the stack
	lw $t0, 8($sp)#return stuff from the stack
	lw $t1, 12($sp)#return stuff from the stack
	lw $t2, 16($sp)#return stuff from the stack
	lw $t3, 20($sp)#return stuff from the stack
	addi $t3, $t3, 1 #iterate the number of blocks drawn
	addi $a0, $a0, 12 #move the pointer right
	j first_round_loop_horiz
end_first_round_loop_horiz:
 	addi $t2, $t2, 1 # number of rows drawn += 1
	addi $a1, $a1, 8 # move down
	li $a0, 5 #move to the position x=5
 	j first_round_loop_vert #loop
 end_first_round_loop_vert:
 	jr $t6 #return


draw_block:
	#t2 will be the start of the current row
	#t1 is the current posiiton at a given time
	#a2 is the color
	#t0 is the start of the bitmap display
	#t3 is the location where we stop drawing the row if we get there
	#t4 is the location where we stop drawing the whole thing if we get there
	la $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	addi $t1, $t0, 0 # set t1 to display address
	addi $t2, $t1, 0 # set t2 to display address
	addi $t4, $t2, 2048 # t4 = coordinate to stop whole thing when we reach it
block_loop_y:
	beq $t2, $t4, end_block_loop_y #if we have reached the last coordinate go to end
	addi $t3, $t2, 32 #t3 = location to stop drawing row at
	addi $t1, $t2, 0 # set t1 to equal t2, that is, start t1 at the beginning of this row
block_loop_x:
	beq $t1, $t3, end_block_loop_x #if we've reached t3, end
	sw $a2, 0($t1) #paint
	addi $t1, $t1, 4 #iterate t1 by 4 (a pixel)
	j block_loop_x #loop
end_block_loop_x:
	addi $t2, $t2, 512 #iterate the y position by a whole row
	j block_loop_y
end_block_loop_y:
	jr $ra #return
	
	        
draw_ball:
	#TODO or should ball position be in .data
	la $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	li $t1 0x33ff33 #get the ball color
	sw $t1, 0($t0) #paint
	jr $ra #return
	
draw_walls:
	la $t0, ADDR_DSPL #display address
	li $t2 0xffffff #color white
	addi $t1, $t0, 512 #this is the location at the end of the top border
top_loop:
	beq $t0, $t1, end_top_loop #check if we're at the end of the top border
	sw $t2, 0($t0) #paint
	addi $t0, $t0, 4 #move our coordinate
	j top_loop #loop
end_top_loop:
	la $t0, ADDR_DSPL # go back to the start of the display
	li $t1, 0x10018000 #endpoint of where we're drawing
side_loop:
	slt $t5, $t0, $t1
	beq $t5, $zero, end_side_loop
	sw $t2, 0($t0) #draw a pixel
	addi $t0, $t0, 512  #iterate down
	sw $t2, 508($t0) #draw a pixel on the other edge of the screen (right wall)
	j side_loop #loop
end_side_loop:
	la $t0, ADDR_DSPL # i think this is unnecessary
	jr $ra #return
	
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




	
	
