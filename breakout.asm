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
ADDR_DSPL:
	.word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

PADDLE_CLR:
	.word 0x2222ff
	
BRICKS_CLR:
	.word 0xff0000

BRICKS_CLR_2:
	.word 0x00ff00
	
BRICKS_CLR_UNBREAKABLE:
	.word 0x808080
	
WALL_CLR:
	.word 0xffffff
	
BALL_CLR:
	.word 0x55ff55

BG_CLR:
	.word 0x000000
	

	
##############################################################################
# Mutable Data
##############################################################################
BALL_POS_X:
	.word 67
	
BALL_POS_Y:
	.word 55
	
BALL_VEL_X:
	.word 0
	
BALL_VEL_Y:
	.word -1
	
PADDLE_POS:
	.word 67
	
LIFE_COUNT:
	.word 3
	
BRICKS_LEFT:
	.word 34


##############################################################################
# Code
##############################################################################
.text
.globl main

# Run the Brick Breaker game.
main:
    # Draw initial bricks
    	jal erase_background
	jal draw_first_round
	
	# Draw walls
    jal draw_walls
    
    # Draw initial ball position
	la $a0, BALL_POS_X
	lw $a0, 0($a0)
	la $a1, BALL_POS_Y
	lw $a1, 0($a1)
	la $a2, BALL_CLR
	lw $a2, 0($a2)
	jal draw_ball

	# Draw initial paddle position
  	la $t0, PADDLE_POS
	la $t1, PADDLE_CLR
	lw $a0, 0($t0)
	lw $a1, 0($t1)
	jal draw_paddle

	# Game loop
	jal game_loop


game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
	jal get_keystroke # v1 = pressed key
	add $s7, $v1, $zero # s7 = pressed key
    
	# 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	
	# Load the current ball position and velocity
	lw $s0, BALL_POS_X # s0 = current ball x position
	lw $s1, BALL_POS_Y # s1 = current ball y position
	lw $s2, BALL_VEL_X # s2 = current ball x velocity
	lw $s3, BALL_VEL_Y # s3 = current ball y velocity
	
	# Calculate ball's new position using curr position and curr velocity
	add $s4, $s0, $s2 # $s4 = new_pos_x
	add $s5, $s1, $s3 # $s5 = new_pos_y

	# Check for collisions by checking color of unit at new position
	add $a0, $s4, $zero 
	add $a1, $s5, $zero
	jal get_unit_color # $a0: x_pos, $a1: y_pos, $v0: unit_color
	# add $a0, $s4, $zero
	# add $a1, $s5, $zero
	
	# Based on what object was hit, update ball's velocity
	beq $a1, $zero, ceiling_collision # ball y pos = 0
	
	beq $a1, 64, bottom_collision # ball y pos = 64

	lw $t0, WALL_CLR
	beq $v0, $t0, wall_collision # unit at new position is a wall

	lw $t0, BRICKS_CLR
	beq $v0, $t0, brick_collision # unit at new position is a brick

	lw $t0, BRICKS_CLR_2
	beq $v0, $t0, brick_collision # unit at new position is a 2nd hit brick
	
	lw $t0, BRICKS_CLR_UNBREAKABLE
	beq $v0, $t0, brick_collision # unit at new position is an unbreakable brick

	lw $t0, PADDLE_CLR
	beq $v0, $t0, paddle_collision # unit at new position is a paddle

	# 3. Draw the screen
	# Undraw current ball position
	erase_curr_ball:
		add $a0, $s0, $zero # a0 = curr ball x pos
		add $a1, $s1, $zero # a1 = curr ball y pos
		lw $a2, BG_CLR # a2 = background color
		jal draw_ball # erase current ball

	# Calculate ball's new position using curr position and (potentially) new velocity
	lw $t0, BALL_VEL_X # t0 = new_vel_x
	lw $t1, BALL_VEL_Y # t1 = new_vel_y
	add $a0, $s0, $t0
	add $a1, $s1, $t1
	
	# Update ball's position and redraw
	sw $a0, BALL_POS_X
	sw $a1, BALL_POS_Y
	lw $a2, BALL_CLR
	jal draw_ball # a0 = BALL_POS_X, a1 = BALL_POS_Y, a2 = BALL_CLR
	
	paddle_time:
	
	# Redraw paddel
	beq $s7, 0x61, move_left # a key pressed
	beq $s7, 0x64, move_right # d key pressed
	
	done_drawing:
	# 4. Sleep    
	li 		$v0, 32
	li 		$a0, 100
	syscall

	#5. Go back to 1
	b game_loop
	
	ceiling_collision:
		# Reverse y velocity
		lw $t0, BALL_VEL_Y
		sub $t0, $zero, $t0
		sw $t0, BALL_VEL_Y
		b erase_curr_ball

	bottom_collision:
		lw $t0, LIFE_COUNT 
		addi $t0, $t0, -1
		beq $t0, $zero, lives_depleted #branch if we're out of lives
		sw $t0, LIFE_COUNT #put life count back in memory after we decremented it earlier
		lw $a0, BALL_POS_X
		lw $a1, BALL_POS_Y
		lw $a2, BG_CLR
		jal draw_ball #erase the ball
		lw $a0, PADDLE_POS
		addi $a1, $zero, 55 #set the ball's new position to above the paddle
		addi $t2, $zero, 0
		addi $t3, $zero, -1
		sw $t2, BALL_VEL_X
		sw $t3, BALL_VEL_Y #make the ball's velocity be straght up
		sw $a0, BALL_POS_X
		sw $a1, BALL_POS_Y
		lw $a2, BALL_CLR
		jal draw_ball #draw the ball in the new position, 
		j paddle_time # go back to the game loop so we don't miss a turn to  move the paddles
		
	lives_depleted:
		j end


	wall_collision:
		# Reverse x velocity
		lw $t0, BALL_VEL_X
		sub $t0, $zero, $t0
		sw $t0, BALL_VEL_X
		b erase_curr_ball
	
	brick_collision:
		# Determine edge hit by checking color of adjacent units
		# Left
		addi $a0, $s4, -1 # a0 = left_unit
		add $a1, $s5, $zero # a1 = new_pos_y
		jal get_unit_color # a0 = x_pos, a1 = y_pos, v0 = unit_color
		lw $t0, BRICKS_CLR
		bne $v0, $t0, left_or_right_hit
		lw $t0, BRICKS_CLR_2
		bne $v0, $t0, left_or_right_hit
		lw $t0, BRICKS_CLR_UNBREAKABLE
		bne $v0, $t0, left_or_right_hit

		# Right
		addi $a0, $s4, 1 # a0 = right_unit
		add $a1, $s5, $zero # a1 = new_pos_y
		jal get_unit_color # a0 = x_pos, a1 = y_pos, v0 = unit_color
		lw $t0, BRICKS_CLR
		bne $v0, $t0, left_or_right_hit
		lw $t0, BRICKS_CLR_2
		bne $v0, $t0, left_or_right_hit
		lw $t0, BRICKS_CLR_UNBREAKABLE
		bne $v0, $t0, left_or_right_hit

		# Bottom
		add $a0, $s4, $zero # a0 = new_pos_x
		addi $a1, $s5, 1 # a1 = bottom_unit
		jal get_unit_color # a0 = x_pos, a1 = y_pos, v0 = unit_color
		lw $t0, BRICKS_CLR
		bne $v0, $t0, top_or_bottom_hit
		lw $t0, BRICKS_CLR_2
		bne $v0, $t0, top_or_bottom_hit
		lw $t0, BRICKS_CLR_UNBREAKABLE
		bne $v0, $t0, top_or_bottom_hit

		# Top
		add $a0, $s4, $zero # a0 = new_pos_x
		addi $a1, $s5, -1 # a1 = top unit
		jal get_unit_color # a0 = x_pos, a1 = y_pos, v0 = unit_color
		lw $t0, BRICKS_CLR
		bne $v0, $t0, top_or_bottom_hit
		lw $t0, BRICKS_CLR_2
		bne $v0, $t0, top_or_bottom_hit
		lw $t0, BRICKS_CLR_UNBREAKABLE
		bne $v0, $t0, top_or_bottom_hit

		left_or_right_hit:
			# Reverse x velocity
			lw $t0, BALL_VEL_X
			sub $t0, $zero, $t0
			sw $t0, BALL_VEL_X

			add $a0, $s4, $zero # a0 = new_pos_x
			add $a1, $s5, $zero # a1 = new_pos_y

			j destroy_brick

		top_or_bottom_hit:
			# Reverse y velocity
			lw $t0, BALL_VEL_Y
			sub $t0, $zero, $t0
			sw $t0, BALL_VEL_Y

			add $a0, $s4, $zero # a0 = new_pos_x
			add $a1, $s5, $zero # a1 = new_pos_y

			j destroy_brick

		destroy_brick:
			# Check if brick color is unbreakable again
			# add $a0, $s4, $zero 
			# add $a1, $s5, $zero
			# jal get_unit_color # $a0: x_pos, $a1: y_pos, $v0: unit_color
			lw $t0, BRICKS_CLR_UNBREAKABLE
			beq $v0, $t0, erase_curr_ball

			# Destroy brick by finding it's position 
			# Go left until unit is not BRICKS_CLR
			while_not_leftmost:
				jal get_unit_color
				lw $t0, BG_CLR
				lw $t1, BALL_CLR
				beq $v0, $t0, not_topmost
				beq $v0, $t1, not_topmost
				addi $a0, $a0, -1
				j while_not_leftmost
			
			not_topmost: # increments x position (back into left edge of brick)
				addi $a0, $a0, 1
				j while_not_topmost

			# Go up until unit is not BRICKS_CLRbo
			while_not_topmost:
				jal get_unit_color
				lw $t0, BG_CLR
				lw $t1, BALL_CLR
				beq $v0, $t0, done
				beq $v0, $t1, done
				addi $a1, $a1, -1
				j while_not_topmost

			done:
				addi $a1, $a1, 1 # increments y position (back into top edge of brick)
				
				jal get_unit_color # check color of brick
				
				lw $t0, BRICKS_CLR
				beq $v0, $t0, draw_brick_2

				lw $t0, BRICKS_CLR_2
				beq $v0, $t0, erase_brick

				draw_brick_2:
					lw $a2, BRICKS_CLR_2
					jal draw_block
					b erase_curr_ball
				
				erase_brick:
					lw $a2, BG_CLR
					jal draw_block

					lw $t0, BRICKS_LEFT #decrement the number of bricks left
					addi $t0, $t0, -1
					sw $t0, BRICKS_LEFT #store that
					
					b erase_curr_ball
	
	start_second_level:
		jal draw_second_round
		b rest_of_paddle_collision
		
	paddle_collision:
		#if we're done level 1, start level 2
		lw $t0, BRICKS_LEFT 
		beq $t0, $zero, start_second_level
		rest_of_paddle_collision:
		# Determine area hit by ball
		# Get paddle center center pos
		lw $t0, PADDLE_POS # t0 = leftmost unit of paddle
		addi $t1, $t0, 4 # t1 = center unit of paddle # TODO use variable for paddle width
		
		# Center
		seq $t2, $s0, $t1 # t2 = 1 if ball current pos is above paddle center
		bne $t2, $zero, center_hit
		
		# Left
		slt $t2, $s0, $t1 # t2 = 1 if ball current pos is left of paddle center
		bne $t2, $zero, left_hit
		
		# Right
		sgt $t2, $s0, $t1 # t2 = 1 if ball current pos is right of paddle center
		bne $t2, $zero, right_hit

		center_hit:
			# Nullify x velocity
			sw $zero, BALL_VEL_X
			
			# reverse y velocity
			lw $t0, BALL_VEL_Y
			sub $t0, $zero, $t0
			sw $t0, BALL_VEL_Y
			
			b erase_curr_ball

		left_hit:
			# Set x velocity to -1
			li $t0, -1 # TODO D2: use magnitude of x*-1 to support different x velocities
			sw $t0, BALL_VEL_X 
			
			# reverse y velocity
			lw $t0, BALL_VEL_Y
			sub $t0, $zero, $t0
			sw $t0, BALL_VEL_Y
			
			b erase_curr_ball

		right_hit:
			# Set x velocity to 1
			li $t0, 1 # TODO D2: use magnitude of x to support different x velocities
			sw $t0, BALL_VEL_X 
			
			# reverse y velocity
			lw $t0, BALL_VEL_Y
			sub $t0, $zero, $t0
			sw $t0, BALL_VEL_Y

			b erase_curr_ball
	
	
	move_left: 
		# Undraw current paddle position
		lw $t0, PADDLE_POS
		addi $a0, $t0, 0
		lw $a1, BG_CLR
		jal draw_paddle # a0 = leftmost unit of paddle, a1 = color

		# Calculate new paddle position and redraw
		lw $t0, PADDLE_POS
		ble  $t0, 1, no_farther_left
		addi $a0, $a0, -1
		sw $a0, PADDLE_POS
		lw $a1, PADDLE_CLR
		no_farther_left:
		lw $a1, PADDLE_CLR
		jal draw_paddle # a0 = leftmost unit of paddle, a1 = color
		j done_drawing 

	move_right: 
		# Undraw current paddle position
		lw $t0, PADDLE_POS
		addi $a0, $t0, 0
		lw $a1, BG_CLR
		jal draw_paddle
		lw $t0, PADDLE_POS
		# Calculate new paddle position and redraw
		bge $t0, 118, no_farther_right
		addi $a0, $a0, 1
		sw $a0, PADDLE_POS
		lw $a1, PADDLE_CLR
		no_farther_right:
		lw $a1, PADDLE_CLR
		jal draw_paddle
		j done_drawing
	
	
erase_background:
	lw $t0, ADDR_DSPL
	lw $t1, BG_CLR
	add $t2, $zero, $t0
	addi $t2, $t2, 32768
	background_loop:
	bge $t0, $t2, end_background_loop
	sw, $t1, 0($t0)
	addi $t0, $t0, 4
	j background_loop
	end_background_loop:
	jr $ra
	
draw_paddle:
	# a0: PADDLE_POS
	# a1: PADDLE_CLR
	
	la $t0, ADDR_DSPL #put display address into t0
	lw $t0, 0($t0)
	li $a2, 60 #set y position
	sll $t3, $a0, 2 #mutliply the x
	sll $t4, $a2, 9 # multiply the y
	add $t3, $t3, $t4 #combine them
	add $t0, $t0, $t3 #add that to t0
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
    
draw_second_round:
	li $a2, 0xff0000
	li $t0, 10 #how many blocks wide
	li $t1, 4 #how many blocks high
	li $a0, 5 #first block x
	li $a1, 5 #first block y
	li $t2, 0 #number of rows of blocks drawn so far
	sw $ra, 40($sp) #save the address that we'll be returning to bc we will use ra
second_round_loop_vert:
	beq $t2, $t1, end_second_round_loop_vert
	li $t3, 0 #number of blocks drawn so far
second_round_loop_horiz:
	beq $t3, $t0, end_second_round_loop_horiz
	
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
	j second_round_loop_horiz
end_second_round_loop_horiz:
 	addi $t2, $t2, 1 # number of rows drawn += 1
	addi $a1, $a1, 8 # move down
	li $a0, 5 #move to the position x=5
 	j second_round_loop_vert #loop
 end_second_round_loop_vert:
 	lw $t6, 40($sp)
 	li $a0, 5 #unbreak block x
	li $a1, 5 #unbreak block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 113 #unbreak block x
	li $a1, 5 #unbreak block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 113 #unbreak block x
	li $a1, 37 # block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 5 #unbreak block x
	li $a1, 37 # block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
 	jr $t6 #return

draw_first_round:
	li $a2, 0xff0000
	li $t0, 10 #how many blocks wide on odd rows
	li $t7, 4 #how many blocks wide on even rows
	li $t1, 5 #how many blocks high
	li $a0, 5 #first block x
	li $a1, 5 #first block y
	li $t2, 0 #number of rows of blocks drawn so far
	sw $ra, 40($sp) #save the address that we'll be returning to bc we will use ra
first_round_loop_vert:
	beq $t2, $t1, end_first_round_loop_vert
	li $t3, 0 #number of blocks drawn so far
	
first_round_loop_horiz:
	
	beq $t3, $t0, end_first_round_loop_horiz
	addi $t5, $zero, 2
	divu $t2, $t5
	mfhi $t6
	beq $t6, $zero, even
	bge $t3, $t7, end_first_round_loop_horiz
even:
	sw $a0, 0($sp) #save stuff to the stack
	sw $a1, 4($sp)#save stuff to the stack
	sw $t0, 8($sp)#save stuff to the stack
	sw $t1, 12($sp)#save stuff to the stack
	sw $t2, 16($sp)#save stuff to the stack
	sw $t3, 20($sp)#save stuff to the stack
	sw $t4, 24($sp)#save stuff to the stack
	sw $t5, 28($sp)#save stuff to the stack
	sw $t6, 32($sp)#save stuff to the stack
	sw $t7, 36($sp)#save stuff to the stack
	jal draw_block #Call helper to draw a block at the coord a0 a1
	lw $a0, 0($sp)#return stuff from the stack
	lw $a1, 4($sp)#return stuff from the stack
	lw $t0, 8($sp)#return stuff from the stack
	lw $t1, 12($sp)#return stuff from the stack
	lw $t2, 16($sp)#return stuff from the stack
	lw $t3, 20($sp)#return stuff from the stack
	lw $t4, 24($sp)#save stuff to the stack
	lw $t5, 28($sp)#save stuff to the stack
	lw $t6, 32($sp)#save stuff to the stack
	lw $t7, 36($sp)#save stuff to the stack
	addi $t3, $t3, 1 #iterate the number of blocks drawn
	beq $t6, $zero, even_two
	addi $a0, $a0, 24
	even_two:
	addi $a0, $a0, 12 #move the pointer right
	j first_round_loop_horiz
	
end_first_round_loop_horiz:
 	addi $t2, $t2, 1 # number of rows drawn += 1
	addi $a1, $a1, 8 # move down
	li $a0, 5 #move to the position x=5
 	j first_round_loop_vert #loop
 end_first_round_loop_vert:
 	lw $t6, 40($sp)
 	li $a0, 5 #unbreak block x
	li $a1, 5 #unbreak block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 113 #unbreak block x
	li $a1, 5 #unbreak block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 113 #unbreak block x
	li $a1, 37 # block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
	li $a0, 5 #unbreak block x
	li $a1, 37 # block y
	lw $a2, BRICKS_CLR_UNBREAKABLE
	sw $t6, 0($sp)#save stuff to the stack
	jal draw_block
	lw $t6, 0($sp)#save stuff to the stack
 	jr $t6 #return


draw_block:
	#t2 will be the start of the current row
	#t1 is the current posiiton at a given time
	#a2 is the color
	#t0 is the start of the bitmap display
	#t3 is the location where we stop drawing the row if we get there
	#t4 is the location where we stop drawing the whole thing if we get there
	la $t0, ADDR_DSPL #put display address into t0
	lw $t0, 0($t0)
	sll $t5, $a0, 2 #mutliply the x
	sll $t7, $a1, 9 # multiply the y
	add $t5, $t5, $t7 #combine them
	add $t0, $t0, $t5 #add that to t0
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
	lw $t0, 0($t0)
	sll $t5, $a0, 2 #mutliply the x
	sll $t7, $a1, 9 # multiply the y
	add $t5, $t5, $t7 #combine them
	add $t0, $t0, $t5 #add that to t0
	sw $a2, 0($t0) #paint
	jr $ra #return
	

draw_walls:
	la $t0, ADDR_DSPL #put display address into t0
	lw $t0, 0($t0)
	li $t2 0xffffff #color white
	addi $t1, $t0, 512 #this is the location at the end of the top border
top_loop:
	beq $t0, $t1, end_top_loop #check if we're at the end of the top border
	sw $t2, 0($t0) #paint
	addi $t0, $t0, 4 #move our coordinate
	j top_loop #loop
end_top_loop:
	la $t0, ADDR_DSPL #put display address into t0
	lw $t0, 0($t0)
	addi $t1, $t0, 32768#endpoint of where we're drawing
side_loop:
	slt $t5, $t0, $t1
	beq $t5, $zero, end_side_loop
	sw $t2, 0($t0) #draw a pixel
	addi $t0, $t0, 512  #iterate down
	sw $t2, 508($t0) #draw a pixel on the other edge of the screen (right wall)
	j side_loop #loop
end_side_loop:
	jr $ra #return
	

get_unit_color:
	#a0: x pos
	#a1: y pos
	la $t0, ADDR_DSPL #put display address into t0
	lw $t0, 0($t0)
	sll $t5, $a0, 2 #mutliply the x
	sll $t7, $a1, 9 # multiply the y
	add $t5, $t5, $t7 #combine them
	add $t0, $t0, $t5 #add that to t0
	lw $v0, 0($t0) 
	jr $ra
	

get_keystroke:
	# li $v0, 32 # sleep syscall
	# li $a0, 1 # 1ms
	# syscall

   	lw $t0, ADDR_KBRD               	# $t0 = base address for keyboard
   	lw $t8, 0($t0)                  # Load first word from keyboard
   	beq $t8, 1, keyboard_input      # If first word 1, key is pressed

   	li $v1, 0 # no key pressed
	jr $ra # return

	keyboard_input:                     # A key is pressed
    	lw $a0, 4($t0)                  # Load second word from keyboard
		
		beq $a0, 0x61, respond_to_A		# Check if the key a was pressed
		beq $a0, 0x64, respond_to_D		# Check if the key d was pressed
		beq $a0, 0x70, respond_to_P		# Check if the key p was pressed
		beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
		
    	# print: # print pressed key as ascii
		# 	li $v0, 11					
		# 	syscall

	respond_to_A: # move paddle left
		li $v1, 0x61
		jr $ra # return
		
	respond_to_D: # move paddle right
		li $v1, 0x64
		jr $ra # return

	respond_to_P: # pause
		jal get_keystroke
		bne $v1, 0x70, respond_to_P # if the key pressed is not p, keep waiting
		jr $ra # return

	respond_to_Q: # quit
		li $v0, 10
		syscall


end:
	li $v0, 10                      
	syscall
