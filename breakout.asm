################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: David Basil 1006900285
# Student 2: Haolin Fan, 1003364316
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    512
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp) 
##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!

# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
ADDR_DSPL:
	.word 0x10008000
PADDLE_CLR:
	.word 0x2222ff
	
BRICKS_CLR:
	.word 0xff0000
	
WALL_CLR:
	.word 0xffffff
	
BALL_CLR:
	.word 0x55ff55
	
##############################################################################
# Mutable Data
BALL_POS_X:
	.word 65
	
BALL_POS_Y:
	.word 55
	
BALL_VEL_X:
	.word 0
	
BALL_VEL_Y:
	.word -1
	
PADDLE_POS:
	.word 16
##############################################################################

##############################################################################
# Code
##############################################################################
.text
.globl main

# Run the Brick Breaker game.
main:
    # Draw initial bricks
	jal draw_first_round_red
	# Draw walls
    jal draw_walls
    
	# Draw initial paddle position
  	la $t0, PADDLE_POS # Need to store current position of paddle somewhere in memory
	la $t1, PADDLE_CLR
	lw $a0, 0($t0)
	lw $a1, 0($t1)
	jal draw_paddle

	# Draw initial ball position
	lw $a0, BALL_POS_X
	lw $a1, BALL_POS_Y
	lw $a2, BALL_CLR
	jal draw_ball
    
	# Set initial velocity of the ball
	# TODO

	# Game loop
	jal game_loop

    j end


game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
	jal get_keystroke
    
	# 2a. Check for collisions
	# 2b. Update locations (paddle, ball)

	# Calculate ball new_loc
		# Using curr_loc and velocity

	# Check for collisions
		# Check color of new_loc pixel
			# Based on color you know what you're about to hit
				# Wall
				# Ceiling
				# Brick
				# Paddle
				# Bottom (y pos, not a color)
			# If hitting brick, determine what edge is hit
				# Check if color of left, right if same as hit pixel
			# If hitting paddle, determine what area of paddle is hit
				# Using paddle_loc, calculate if new_loc is in left, middle, or right third of paddle
			# If hitting bottom
				# End game (terminate program)
	
		# Destroy brick if one is hit
			# Find path to top left of corner of brick
				# Go left until left pixel is not the same color
				# Go up until top pixel is not the same color
			# Redraw as black

		# Update ball velocity
			# If ball hits paddle on:
				# center pixel
					# vel_x = 0
					# vel_y = vel_y * -1
				# left of center pixel;
					# vel_x = -1
					# vel_y = vel_y * -1
				# right of center pixel;
					# vel_x = 1
					# vel_y = vel_y * -1
			# If ball hits wall:
				# vel_x = vel_x * -1
				# vel_y = vel_y
			# If ball hits ceiling:
				# vel_x = vel_x
				# vel_y = vel_y * -1
			# If ball hits brick on:
				# bottom/top
					# vel_x = vel_x
					# vel_y = vel_y * -1
				# side
					# vel_x = vel_x * -1
					# vel_y = vel_y
	
	# Update ball location
		# if collision, new_loc = curr_loc + vel
		
	# 3. Draw the screen
	# Redraw ball
	# Need to store current ball position and trajectory somewhere in memory
	lw $a0, BALL_POS_X
	lw $a1, BALL_POS_Y
	jal draw_ball
	
	
	# Redraw paddel
	beq $v1, 0x61, move_left
	beq $v1, 0x61, move_right
	move_left:
		li $t0, -1
	move_right:
		li $t0, 1	
	lw $a0, PADDLE_POS # Need to store current position of paddle somewhere in memory
	lw $a1, PADDLE_CLR
	jal draw_paddle
	
	# 4. Sleep
	li 		$v0, 32
	li 		$a0, 1
	syscall
    
	#5. Go back to 1
    b game_loop
    
draw_paddle:
	lw $t0, ADDR_DSPL #put display address into t0
	li $a2, 60 #set y position
	sll $a0, $a0, 2 #mutliply the x
	sll $a2, $a2, 9 # multiply the y
	add $a0, $a0, $a2 #combine them
	add $t0, $t0, $a0 #add that to t0
	sw $a1, 0($t0) #paint
	sw $a1, 4($t0) #paint
	sw $a1, 8($t0) #paint
	sw $a1, 12($t0) #paint
	sw $a1, 16($t0) #paint
	sw $a1, 20($t0) #paint
	sw $a1, 24($t0) #paint
	sw $a1, 28($t0) #paint
	sw $a1, 32($t0) #paint
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
	lw $t0, ADDR_DSPL #put display address into t0
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
	lw $t0, ADDR_DSPL #put display address into t0
	sll $a0, $a0, 2 #mutliply the x
	sll $a1, $a1, 9 # multiply the y
	add $a0, $a0, $a1 #combine them
	add $t0, $t0, $a0 #add that to t0
	sw $a2, 0($t0) #paint
	jr $ra #return
	
draw_walls:
	lw $t0, ADDR_DSPL #display address
	li $t2 0xffffff #color white
	addi $t1, $t0, 512 #this is the location at the end of the top border
top_loop:
	beq $t0, $t1, end_top_loop #check if we're at the end of the top border
	sw $t2, 0($t0) #paint
	addi $t0, $t0, 4 #move our coordinate
	j top_loop #loop
end_top_loop:
	lw $t0, ADDR_DSPL # go back to the start of the display
	li $t1, 0x10018000 #endpoint of where we're drawing
side_loop:
	slt $t5, $t0, $t1
	beq $t5, $zero, end_side_loop
	sw $t2, 0($t0) #draw a pixel
	addi $t0, $t0, 512  #iterate down
	sw $t2, 508($t0) #draw a pixel on the other edge of the screen (right wall)
	j side_loop #loop
end_side_loop:
	lw $t0, ADDR_DSPL # i think this is unnecessary
	jr $ra #return
	

	
get_keystroke:
	li $v0, 32 # sleep syscall
	li $a0, 1 # 1ms
	syscall

   	lw $t0, ADDR_KBRD               	# $t0 = base address for keyboard
   	lw $t8, 0($t0)                  # Load first word from keyboard
   	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
   	
   	j get_keystroke

	keyboard_input:                     # A key is pressed
    	lw $a0, 4($t0)                  # Load second word from keyboard
		
		beq $a0, 0x61, respond_to_A		# Check if the key a was pressed
		beq $a0, 0x64, respond_to_D		# Check if the key d was pressed
		beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
		
    	print: # print pressed key as ascii
			li $v0, 11					
			syscall

    jr $ra # return

	respond_to_A:
		li $v1, 0x61
		j print
		
	respond_to_D:
		li $v1, 0x64
		j print

	respond_to_Q:
		li $v0, 10                      # Quit gracefully
		syscall

	
	

end:




	
	
