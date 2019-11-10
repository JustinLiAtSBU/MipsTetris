# CSE 220 Programming Project #3
# Justin Li
# JUSTILI
# 111737523

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	addi $sp, $sp, -28
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	move $s0, $a0								# $s0 = Struct address
	move $s1, $a1								# $s1 = num_rows
	move $s2, $a2								# $s2 = num_cols
	move $s3, $a3								# $s3 = character
	blez $s1, initialize_error					
	blez $s2, initialize_error
	sb $s1, ($s0)
	addi $s0, $s0, 1
	sb $s2, ($s0)
	addi $s0, $s0, 1
	li $s4, 0 									# Loop counter for num_rows
	initialize_outer_loop:
		beq $s4, $s1, initialize_successful		# If $s4 == num_rows, branch out
		addi $s4, $s4, 1
		li $s5, 0 								# Loop counter for num_col
		initialize_inner_loop:
			beq $s5, $s2, initialize_outer_loop	# If $s5 == num_cols, branch out
			move $s6, $s3
			sb $s6, ($s0)
			addi $s0, $s0, 1					# Increment pointer
			addi $s5, $s5, 1					# Increment loop counter
			j initialize_inner_loop
	initialize_successful:
		move $v0, $a1
		move $v1, $a2
		j initialize_done
	initialize_error:
		li $v0, -1
		li $v1, -1
		j initialize_done
	initialize_done:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 28
		jr $ra

load_game:
	addi $sp, $sp, -40
	sw $s0, ($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
	sw $s5, 32($sp)
	sw $s6, 36($sp)
	
	move $s0, $a0						# s0 = state
	move $s1, $a1						# s1 = filename
	# Open file for reading
	li $v0, 13							# Syscall for opening file
	move $a0, $s1						# Store file address into $a0
	li $a1, 0
	li $a2, 0
	syscall
	bltz $v0, load_game_error			# Check for file doesn't exist
	move $s2, $v0						# $s2 = file descriptor
	
							
	
	load_game_error:
		li $v0, -1
		li $v1, -1
		j load_game_done
	load_game_done:
	lw $s0, ($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $s4, 28($sp)
	lw $s5, 32($sp)
	lw $s6, 36($sp)
	addi $sp, $sp, 40
    jr $ra

get_slot:
	addi $sp, $sp, -28
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)

	move $s0, $a0 					# $s0 = struct
	move $s1, $a1					# $s1 = needed row
	move $s2, $a2 					# $s2 = needed column
	lb $s3, ($s0)					# $s3 = rows in struct
	addi $s0, $s0, 1
	lb $s4, ($s0)					# $s4 = cols in struct
	addi $s0, $s0, 1

	# Error messages
	bge $s1, $s3, get_slot_error
	bge $s2, $s4, get_slot_error
	bltz $s1, get_slot_error
	bltz $s2, get_slot_error
	
	li $s5, 0 									# Loop counter for rows
	get_slot_outer_loop:
		beq $s5, $s1, get_slot_done_continue
		addi $s5, $s5, 1
		li $s6, 0 								# Loop counter for num_col
		get_slot_inner_loop:
			beq $s6, $s4, get_slot_outer_loop	
			addi $s0, $s0, 1					# Increment pointer of struct to get the value at [row][col]
			addi $s6, $s6, 1
			j get_slot_inner_loop
	
	get_slot_error:
		li $v0, -1
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 28
	    jr $ra
	
	get_slot_done_continue:
		li $s6, 0
		get_slot_done_loop:
			beq $s6, $s2, get_slot_done
			addi $s0, $s0, 1
			addi $s6, $s6, 1
			j get_slot_done_loop
	
	get_slot_done:
		lb $s7, ($s0)
		move $v0, $s7
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 28
	    jr $ra

set_slot:
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	
	move $s0, $a0							# $a0 = struct
	move $s1, $a1							# $a1 = row to be placed into
	move $s2, $a2							# $s2 = col to be placed into
	move $s3, $a3							# $s3 = character to place into struct
	
	lb $s4, ($s0)							# Load row from struct into $s4
	bge $s1, $s4, set_slot_error			
	addi $s0, $s0, 1
	lb $s5, ($s0)							# Load col from struct into $s5
	bge $s2, $s5, set_slot_error
	addi $s0, $s0, 1
	bltz $s1, set_slot_error
	bltz $s2, set_slot_error

	li $s6, 0 									# Loop counter for rows
	set_slot_outer_loop:
		beq $s6, $s1, set_slot_continue
		addi $s6, $s6, 1
		li $s7, 0 								# Loop counter for num_col
		set_slot_inner_loop:
			beq $s7, $s5, set_slot_outer_loop	
			addi $s0, $s0, 1					# Increment pointer of struct to get the value at [row][col]
			addi $s7, $s7, 1
			j set_slot_inner_loop
	
	set_slot_continue:
		li $s7, 0
		set_slot_continue_loop:
			beq $s7, $s2, set_slot_insert_character
			addi $s7, $s7, 1
			addi $s0, $s0, 1
			j set_slot_continue_loop
	
	set_slot_insert_character:
		sb $s3, ($s0)
		move $v0, $s3
		j set_slot_done
	
	set_slot_error:
		li $v0, -1
		j set_slot_done
	
	set_slot_done:
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32	
    jr $ra

rotate:
	addi $sp, $sp, -56
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $t0, 32($sp)
	sw $t1, 36($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	
	move $s0, $a0							# $s0 = piece
	move $s1, $a1							# $s1 = # of rotations
	move $s2, $a2							# $s2 = struct to write to 
	lb $s3, ($s0)							# $s3 = num rows in piece	
	addi $s0, $s0, 1						# Increment pointer to column number byte
	lb $s4, ($s0)							# $s4 = num cols in piece
	addi $s0, $s0, 1						# Increment pointer to start of char []
	
	bltz $s1, rotate_error					# If rotation < 0, error
	# ========= Initalize $s2 ========= #
	li $s5, '.'
	li $s6, 2
	li $s7, 3
	addi $sp, $sp, -20
	sw $a0, 56($sp)
	sw $a1, 60($sp)
	sw $a2, 64($sp)
	sw $a3, 68($sp)
	sw $ra, 72($sp)
	move $a0, $s2
	move $a1, $s6
	move $a2, $s7
	move $a3, $s5
	jal initialize
	lw $a0, 56($sp)
	lw $a1, 60($sp)
	lw $a2, 64($sp)
	lw $a3, 68($sp)
	lw $ra, 72($sp)
	addi $sp, $sp, 20
	# ========== Fill in the Buffer ========== #
	sb $s3, ($s2)
	addi $s2, $s2, 1
	sb $s4, ($s2)
	addi $s2, $s2, 1
	li $s5, 0
	li $s6, 6
	fill_buffer_loop:
		beq $s5, $s6, fill_buffer_loop_done
		addi $s5, $s5, 1
		lb $s7, ($s0)								# Load the byte from piece
		sb $s7, ($s2)								# Store the byte from piece into buffer
		addi $s0, $s0, 1							# Increment piece pointer
		addi $s2, $s2, 1							# Increment buffer pointer
		j fill_buffer_loop
	fill_buffer_loop_done:
	# ========= Checker for "O-piece" ========== #
	li $s5, 2										
	bne $s3, $s5, rotate_not_o_piece			# If $s3 does not equal 2, continue
	bne $s4, $s5, rotate_not_o_piece			# If $s4 does not equal 2, continue
	move $v0, $s1
	j rotate_done
	
	rotate_not_o_piece:
		# ========= Checker for "I-piece" ========= #
		li $s5, 4
		mult $s3, $s4							# Multiply row and column numbers 
		mflo $s6								# Move result of multiplication to $s6
		beq $s6, $s5, rotate_i_piece			# If result == 4, jump to rotate_i_piece
		bne $s6, $s5, rotate_other_piece		# else, jump to rotate_other_piece
		
	rotate_i_piece:	
		# ========= Move pointers back ========= #
		li $s7, 8
		li $s5, 0
		rotate_i_piece_move_pointer_back:
			beq $s5, $s7, rotate_i_piece_continue
			addi $s0, $s0, -1
			addi $s2, $s2, -1
			addi $s5, $s5, 1
			j rotate_i_piece_move_pointer_back
	rotate_i_piece_continue:
		li $s5, 0
		# ========= Swap the row and columns of the i-piece struct  ========= #
		rotate_i_piece_loop:
			beq $s5, $s1, rotate_i_piece_loop_done
			lb $s6, ($s2)							# $s6 contains the current row			
			addi $s2, $s2, 1
			lb $s7, ($s2)							# $s7 contains the current column
			addi $s2, $s2, -1						# Move pointer back to beginning
			sb $s7, ($s2)							# Store the row and columns swapped
			addi $s2, $s2, 1
			sb $s6, ($s2)
			addi $s2, $s2, -1
			addi $s5, $s5, 1
			j rotate_i_piece_loop
	rotate_i_piece_loop_done:
		move $v0, $s1
		j rotate_done

	rotate_other_piece:
		li $s7, 8
		li $s5, 0
		rotate_other_piece_move_pointer_back:
			beq $s5, $s7, rotate_other_piece_continue
			addi $s0, $s0, -1
			addi $s2, $s2, -1
			addi $s5, $s5, 1
			j rotate_other_piece_move_pointer_back
		rotate_other_piece_continue:
		li $s5, 0									# Loop counter
		li $t0, 2									# Hard coded 2
		rotate_other_piece_loop:
			beq $s5, $s1, rotate_other_piece_loop_done
			addi $s5, $s5, 1
			# ======= Get rows and columns ======= #
			lb $s6, ($s2)							# $s6 = rows
			addi $s2, $s2, 1						
			lb $s7, ($s2)							# $s7 = columns
			# ======= Swap rows and columns ======= #
			addi $s2, $s2, -1
			sb $s7, ($s2)
			addi $s2, $s2, 1
			sb $s6, ($s2)
			# ======= Change the char array ======= #
			addi $s2, $s2, 1						# Pointer now at struct[2]
			beq $s6, $t0, rotate_other_piece_2by3
			bne $s6, $t0, rotate_other_piece_3by2
			rotate_other_piece_2by3:
				lb $t0, ($s2)
				addi $s2, $s2, 1
				lb $t1, ($s2)
				addi $s2, $s2, 1
				lb $t2, ($s2)
				addi $s2, $s2, 1
				lb $t3, ($s2)
				addi $s2, $s2, 1
				lb $t4, ($s2)
				addi $s2, $s2, 1
				lb $t5, ($s2)
				addi $s2, $s2, -5
				sb $t3, ($s2)
				addi $s2, $s2, 1
				sb $t0, ($s2)
				addi $s2, $s2, 1
				sb $t4, ($s2)
				addi $s2, $s2, 1
				sb $t1, ($s2)
				addi $s2, $s2, 1
				sb $t5, ($s2)
				addi $s2, $s2, 1
				sb $t2, ($s2)
				addi $s2, $s2, -7
				j rotate_other_piece_loop
			rotate_other_piece_3by2:
				lb $t0, ($s2)
				addi $s2, $s2, 1
				lb $t1, ($s2)
				addi $s2, $s2, 1
				lb $t2, ($s2)
				addi $s2, $s2, 1
				lb $t3, ($s2)
				addi $s2, $s2, 1
				lb $t4, ($s2)
				addi $s2, $s2, 1
				lb $t5, ($s2)
				addi $s2, $s2, -5
				sb $t4, ($s2)
				addi $s2, $s2, 1
				sb $t2, ($s2)
				addi $s2, $s2, 1
				sb $t0, ($s2)
				addi $s2, $s2, 1
				sb $t5, ($s2)
				addi $s2, $s2, 1
				sb $t3, ($s2)
				addi $s2, $s2, 1
				sb $t1, ($s2)
				addi $s2, $s2, -7
				j rotate_other_piece_loop
	rotate_other_piece_loop_done:
		move $v0, $s1
		j rotate_done	
	
	rotate_error:
		li $v0, -1
		j rotate_done
	
	rotate_done:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		lw $t2, 40($sp)
		lw $t3, 44($sp)
		lw $t5, 48($sp)
		addi $sp, $sp, 52
	    jr $ra

count_overlaps:
	addi $sp, $sp, -56
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $t0, 32($sp)
	sw $t1, 36($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	# ====== Check for Errors ====== #
	lb $s4, ($s0)							# $s4 = gamestate row
	addi $s0, $s0, 1						
	lb $s5, ($s0)							# $s5 = gamestate column
	addi $s0, $s0, -1						# Pointer is back at the beginning
	blt $s1, $s4, count_overlaps_error
	blt $s2, $s5, count_overlaps_error
	bltz $s1, count_overlaps_error
	bltz $s2, count_overlaps_error
	
	
	count_overlaps_error:
		li $v0, -1
		j count_overlaps_done
	count_overlaps_done:
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		lw $t2, 40($sp)
		lw $t3, 44($sp)
		lw $t4, 48($sp)
		lw $t5, 52($sp)
		addi $sp, $sp, 56
		jr $ra

drop_piece:
	jr $ra

check_row_clear:
	jr $ra

simulate_game:
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
