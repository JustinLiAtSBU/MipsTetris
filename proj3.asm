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
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	move $s0, $a0				# $s0 = gamestate struct
	move $s1, $a1				# $s1 = filename
	li $s4, '\n'				# New line constant
	# ======= Open file ======= #
	move $a0, $s1
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	# ======= Error check ======= #
	bltz $v0, load_game_error
	# ======= Get 1st digit of rows ======= #
	move $a0, $v0
	addi $sp, $sp, -4
	move $a1, $sp				# Use stack as buffer
	li $a2, 1
	li $v0, 14
	syscall
	lbu $s2, ($sp)				# First digit
	addi $sp, $sp, 4
	# ====== Get 2nd digit of rows ======== #
	li $v0, 14
	addi $sp, $sp, -4
	syscall
	lbu $s3, ($sp)				# Second digit
	addi $sp, $sp, 4
	# ====== Check if single or double digit ====== #
	beq $s3, $s4 load_game_row_single_digit
	bne $s3, $s4 load_game_row_double_digit
	load_game_row_single_digit:
		addi $s2, $s2, -48		# Change from ascii to numeric
		sb $s2, ($s0)
		addi $s0, $s0, 1		# Move state pointer to column byte
		j load_game_columns
	load_game_row_double_digit:
		addi $s2, $s2, -48
		addi $s3, $s3, -48
		li $s5, 10
		mult $s2, $s5
		mflo $s2
		add $s2, $s2, $s3
		sb $s2, ($s0)
		addi $s0, $s0, 1		# Move state pointer to column byte
		j load_game_columns
	load_game_columns:	
		# ====== Get first digit of columns ====== #
		li $v0, 14
		addi $sp, $sp, -4
		syscall
		lb $s2, ($sp)					# $s2 = first digit of columns
		addi $sp, $sp, 4
		bne $s2, $s4, load_game_check_columns_skip		# If next char is new line, skip
		addi $sp, $sp, -4
		li $v0, 14
		syscall
		lb $s2, ($sp)					# $s2 = first digit of columns
		addi $sp, $sp, 4
		load_game_check_columns_skip:
		# ====== Get second digit of columns ====== #
		li $v0, 14
		addi $sp, $sp, -4
		syscall
		lb $s3, ($sp)
		addi $sp, $sp, 4
		beq $s3, $s4, load_game_columns_single_digit
		bne $s3, $s4, load_game_columns_double_digit
		load_game_columns_single_digit:
			addi $s2, $s2, -48
			sb $s2, ($s0)
			addi $s0, $s0, 1				# Move pointer to char[] section
			j load_game_fill_state
		load_game_columns_double_digit:
			addi $s2, $s2, -48
			addi $s3, $s3, -48
			li $s5, 10
			mult $s2, $s5
			mflo $s2
			add $s2, $s2, $s3
			sb $s2, ($s0)
			addi $s0, $s0, 1		# Move state pointer to char[] section
			j load_game_fill_state
	load_game_fill_state:
		li $s4, '\n'
		li $s6, '.'
		li $s7, 'O'
		li $s3, 0					# O's
		li $s5, 0					# Invalid chars
		li $s2, 0					# Where to store byte
		# ====== Get number of chars in char[] ====== #
		addi $s0, $s0, -2			# Move state pointer to beginning
		lb $t0, ($s0)
		addi $s0, $s0, 1
		lb $t1, ($s0)
		addi $s0, $s0, 1			# State pointer now at char[] section
		mult $t0, $t1
		mflo $t0					# $t0 contains number of chars in char[] section
		li $t1, 0					# Loop counter
		load_game_fill_state_loop:
			beq $t1, $t0, load_game_fill_state_loop_exit 
			# ====== Get byte ====== #
			addi $sp, $sp, -4
			li $v0, 14
			syscall
			lb $s2, ($sp)			# Load char into $s2
			addi $sp, $sp, 4
			# ====== Check if byte is new line character ====== #
			beq $s2, $s4, load_game_fill_state_loop
			# ====== Check if byte is an O ====== #
			beq $s2, $s7, load_game_fill_state_o
			# ====== Check if byte is a period ====== #
			beq $s2, $s6, load_game_fill_state_period
			# ====== Else ====== #
			sb $s6, ($s0)
			addi $s0, $s0, 1
			addi $t1, $t1, 1
			addi $s5, $s5, 1
			j load_game_fill_state_loop
			load_game_fill_state_o:
				sb $s2, ($s0)
				addi $s0, $s0, 1	# Increment state pointer
				addi $t1, $t1, 1	# Increment loop counter
				addi $s3, $s3, 1	# Increment O counter
				j load_game_fill_state_loop
			load_game_fill_state_period:
				sb $s2, ($s0)
				addi $s0, $s0, 1	# Increment state pointer
				addi $t1, $t1, 1	# Increment loop counter
				j load_game_fill_state_loop
	load_game_fill_state_loop_exit:
		li $v0, 16
		syscall
		move $v0, $s3
		move $v1, $s5
		j load_game_done
	load_game_error:
		li $v0, -1
		j load_game_done
	load_game_done:
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

get_slot:
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
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
		lw $s7, 28($sp)
		addi $sp, $sp, 32
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
		lw $s7, 28($sp)
		addi $sp, $sp, 32
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
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	
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
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a0, $s2
	move $a1, $s6
	move $a2, $s7
	move $a3, $s5
	jal initialize
	lw $ra, 0($sp)
	addi $sp, $sp, 4
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
		li $t6, 2									# Hard coded 2
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
			beq $s6, $t6, rotate_other_piece_2by3
			bne $s6, $t6, rotate_other_piece_3by2
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
		addi $sp, $sp, 32
	    	jr $ra

count_overlaps:
	addi $sp, $sp, -32
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	
	move $s0, $a0							# $s0 = state
	move $s1, $a1							# $s1 = row
	move $s2, $a2							# $s2 = column
	move $s3, $a3							# $s3 = piece
	# ====== Check for Errors ====== #
	lb $s4, ($s0)							# $s4 = gamestate row
	addi $s0, $s0, 1						
	lb $s5, ($s0)							# $s5 = gamestate column
	addi $s0, $s0, -1						# Pointer is back at the beginning
	lb $s6, ($s3)							# Piece row	
	addi $s6, $s6, -1	
	addi $s3, $s3, 1						# Move Pointer up
	lb $s7, ($s3)							# Piece column
	addi $s7, $s7, -1
	addi $s3, $s3, -1						# Move pointer back
	add $t0, $s1, $s6						# Row + 1 to see if OOB
	add $t1, $s2, $s7						# Col + 2 to see if OOB
	bge $t0, $s4, count_overlaps_error
	bge $t1, $s5, count_overlaps_error
	bltz $s1, count_overlaps_error
	bltz $s2, count_overlaps_error
	li $t0, 0
	li $t1, 1
	li $t4, 0							# $v0 counter
	li $t7, 79
	lb $s6, ($s3)							# Piece row
	addi $s3, $s3, 1
	lb $s7, ($s3)							# Piece column
	addi $s3, $s3, 1	
	move $t0, $s1
	move $t1, $s2
	add $t2, $t0, $s6						# Checker for $t0
	add $t3, $t1, $s7						# Checker for $t1
	count_overlaps_outer_loop:
		beq $t0, $t2, count_overlaps_continue
		move $t1, $s2
		count_overlaps_inner_loop:
			bne $t1, $t3, count_overlaps_inner_loop_continue
			addi $t0, $t0, 1
			j count_overlaps_outer_loop
			count_overlaps_inner_loop_continue:
			# ===== USE GET SLOT FOR GAME STATE ===== #
				addi $sp, $sp, -4
				sw $ra, 0($sp) 
				move $a0, $s0
				move $a1, $t0
				move $a2, $t1
				jal get_slot
				move $t5, $v0			# Get char from state
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				lb $t6, ($s3)			# Load from piece
				bne $t5, $t7, count_overlaps_inner_loop_not_o
				bne $t5, $t6, count_overlaps_inner_loop_not_o
				addi $t4, $t4, 1
			count_overlaps_inner_loop_not_o:
			addi $t1, $t1, 1
			addi $s3, $s3, 1
			j count_overlaps_inner_loop								
	count_overlaps_continue:
		move $v0, $t4
		j count_overlaps_done
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
		addi $sp, $sp, 32
		jr $ra
drop_piece:
	lw $t0, 0($sp)			
	addi $sp, $sp, -32
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	sw $s3, 8($sp)
	sw $s4, 12($sp)
	sw $s5, 16($sp)
	sw $s6, 20($sp)
	sw $s7, 24($sp)
	sw $s0, 28($sp)
		
	move $s0, $a0			# Gamestate struct
	move $s1, $a1			# Column to drop into
	move $s2, $a2			# Piece struct
	move $s3, $a3			# Num rotations
	move $s4, $t0			# Store rot piece buffer
	
	addi $s0, $s0, 1
	lb $s5, ($s0)
	addi $s0, $s0, -1					# Pointer for the state is back to beginning
	# ====== Error Checking ====== #
	bltz $s3, drop_piece_error				# Check if rotation is negative
	bltz $s1, drop_piece_error				# Check if column is negative
	bge $s1, $s5, drop_piece_error				# Check if column >= state.col
	# ===== Rotate the piece into piece buffer ====== #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a0, $s2
	move $a1, $s3
	move $a2, $s4
	jal rotate
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# ===== Check if rotated piece can fit ===== #
	addi $s4, $s4, 1			# Move rotated piece struct to column byte
	lb $t0, ($s4) 				# $t0 = rotatedpiece.columns
	addi $s4, $s4, -1			# Rotated piece struct POINTER moved back
	li $t1, 0				# Reset $t1 to 0
	add $t1, $t0, $s1			# $t1 = rotated pieces columns + col
	bgt $t1, $s5, drop_piece_overlap_error
	lb $t8, ($s0)				# $t8 = state.row
	li $t0, 0
	drop_piece_check_overlap_loop:
		# ====== Check if the piece overlaps ====== #
		addi $sp, $sp, -8	
		sw $t0, ($sp)	# I'M USING $t0 AS AN s REGISTER SO I NEED TO PRESERVE IT ON THE STACK
		sw $ra, 4($sp)
		move $a0, $s0
		move $a1, $t0
		move $a2, $s1
		move $a3, $s4
		jal count_overlaps
		move $t1, $v0			# $t1 = count overlaps result
		lw $t0, ($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8	
		# ====== If countoverlaps > 0, break out ====== #
		bgtz $t1, drop_piece_check_overlap_continue
		blt $t0, $t8, drop_piece_check_overlap_loop_increment
		
		# ====== If row > state.row ====== #
		bge $t0, $t8, drop_piece_we_gotta_problem
		drop_piece_we_gotta_problem:
			li $t0, 0 
			lb $t9, 0($s4)		# $t9 = piece.rows
			addi $t9, $t9, -1
			sub $t0, $t8, $t9
			j drop_piece_check_overlap_continue
			
		drop_piece_check_overlap_loop_increment:
		addi $t0, $t0, 1		# Increment row counter
		j drop_piece_check_overlap_loop
	
	drop_piece_check_overlap_continue:
		beqz $t0, drop_piece_collision_error	# If block collides at row 0, collison error
		# ====== Get rows and columns of rotated piece ====== #
		lb $t1, ($s4)			# Rotatedpiece.rows
		addi $s4, $s4, 1	
		lb $t2, ($s4)			# Rotatedpiece.columns
		addi $s4, $s4, 1		# Rotated piece POINTER is now at char[]
		addi $s4, $s4, -2
		# ====== Must place the piece one row above ====== #
		addi $t0, $t0, -1		
		li $t8, '.'			# Hard coded period
		move $t7, $t0			# This will be for $v0 later
		li $t4, 0			# Piece row counter	
		drop_piece_drop_outer_loop:
			beq $t4, $t1, drop_piece_continue	# If current row = piece.rows
			li $t5, 0				# Piece column counter
			move $t3, $s1			# $t3 = column to be dropped into
			drop_piece_drop_inner_loop:
				beq $t5, $t2, drop_piece_loop_increment
				bne $t5, $t2, drop_piece_drop_inner_loop_continue
				drop_piece_loop_increment:
					addi $t0, $t0, 1
					addi $t4, $t4, 1
					j drop_piece_drop_outer_loop
				drop_piece_drop_inner_loop_continue:
					# ====== Get character from piece ====== #
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					move $a0, $s4
					move $a1, $t4
					move $a2, $t5
					jal get_slot
					move $t9, $v0			# $t9 contains the character
					lw $ra, 0($sp)
					addi $sp, $sp, 4
					# ====== Branch if character is a period ====== #
					beq $t9, $t8, drop_piece_inner_loop_increment
					# ====== Set character into gamestate ====== #
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					move $a0, $s0
					move $a1, $t0
					move $a2, $t3
					move $a3, $t9
					jal set_slot
					lw $ra, 0($sp)
					addi $sp, $sp, 4
					drop_piece_inner_loop_increment:
					addi $t5, $t5, 1
					addi $t3, $t3, 1
					j drop_piece_drop_inner_loop
		drop_piece_continue:
			move $v0, $t7
			j drop_piece_done
	drop_piece_collision_error:
		li $v0, -1
		j drop_piece_done
	drop_piece_overlap_error:
		li $v0, -3
		j drop_piece_done
	drop_piece_error:
		li $v0, -2
		j drop_piece_done
	drop_piece_done:
		lw $s1, 0($sp)
		lw $s2, 4($sp)
		lw $s3, 8($sp)
		lw $s4, 12($sp)
		lw $s5, 16($sp)
		lw $s6, 20($sp)
		lw $s7, 24($sp)
		lw $s0, 28($sp)
		addi $sp, $sp, 32
		jr $ra

check_row_clear:
	addi $sp, $sp, -32
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	sw $s3, 8($sp)
	sw $s4, 12($sp)
	sw $s5, 16($sp)
	sw $s6, 20($sp)
	sw $s7, 24($sp)
	sw $s0, 28($sp)
	move $s0, $a0							# State
	move $s1, $a1							# Row requested
	lb $s2, ($s0)							# Num of rows in state
	addi $s0, $s0, 1
	lb $s3, ($s0)							# Num of columns in state
	addi $s0, $s0, -1						# Pointer is now back at beginning of state
	# ====== Check for errors ====== #
	bge $s1, $s2, check_row_clear_error 
	# ====== Check if row can be cleared ====== #
	li $s4, 0 								# Counter for columns
	li $s6, 79								# Checker for "O"
	check_row_clear_loop:
		beq $s4, $s3, check_row_clear_loop_continue_filled
		# ====== Get character in state[row][column] ====== #
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		move $a0, $s0
		move $a1, $s1
		move $a2, $s4
		jal get_slot
		move $s5, $v0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		# ====== Check if character is an "O" ====== #
		bne $s5, $s6, check_row_clear_loop_continue_not_filled
		addi $s4, $s4, 1
		j check_row_clear_loop
	check_row_clear_loop_continue_filled:	
		li $s5, 0
		li $s7, -1
		add $s5, $s1, $s7
		check_row_swap_rows_outer_loop:
			beqz $s1, check_row_clear_loop_continue_filled_continue # If $s1 == 0, break
			# ===== MUST SUBTRACT 1 FROM $s1 and $s5 AFTER ===== #
			li $s4, 0								# Column counter
			check_row_swap_rows_inner_loop:
				beq $s4, $s3, check_row_swap_rows_jump_outer
				bne $s4, $s3, check_row_swap_rows_inner_loop_skip
				check_row_swap_rows_jump_outer:
					addi $s5, $s5, -1
					addi $s1, $s1, -1
					j check_row_swap_rows_outer_loop
				check_row_swap_rows_inner_loop_skip:
					# Get slot of row on top #
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					move $a0, $s0
					move $a1, $s5
					move $a2, $s4
					jal get_slot
					move $s6, $v0					# $s6 contains char at row on top
					lw $ra, 0($sp)
					addi $sp, $sp, 4
					# Swap slot of row on top with row on bottom
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					move $a0, $s0
					move $a1, $s1
					move $a2, $s4
					move $a3, $s6
					jal set_slot
					lw $ra, 0($sp)
					addi $sp, $sp, 4 
					addi $s4, $s4, 1
					j check_row_swap_rows_inner_loop
		check_row_clear_loop_continue_filled_continue:
			li $v0, 1
			# ======= Set topmost row to periods ======= #
			li $s4, 0
			li $s6, '.'
			check_row_set_top_row_loop:
				beq $s4, $s3, check_row_set_top_done
				addi $sp, $sp, -4
				sw $ra, 0($sp)
				move $a0, $s0
				move $a1, $s1
				move $a2, $s4
				move $a3, $s6
				jal set_slot
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				addi $s4, $s4, 1
				j check_row_set_top_row_loop
	check_row_set_top_done:
		li $v0, 1
		j check_row_clear_done
	# ====== Jump for when the row isn't filled ====== #
	check_row_clear_loop_continue_not_filled:
		li $v0, 0
		j check_row_clear_done
	check_row_clear_error:
		li $v0, -1
		j check_row_clear_done
	check_row_clear_done:
		lw $s1, 0($sp)
		lw $s2, 4($sp)
		lw $s3, 8($sp)
		lw $s4, 12($sp)
		lw $s5, 16($sp)
		lw $s6, 20($sp)
		lw $s7, 24($sp)
		lw $s0, 28($sp)
		addi $sp, $sp, 32
		jr $ra

simulate_game:
	lw $t0, 0($sp)			
	lw $t1, 4($sp)			
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	
	move $s0, $a0			# $s0 = state
	move $s1, $a1			# $s1 = filename
	move $s2, $a2			# $s2 = moves
	move $s3, $a3			# $s3 = rotated piece buffer
	move $s4, $t0 			# $s4 = number of pieces to drop
	move $s5, $t1			# $s5 = pieces array
	
	# ====== Get the length of the moves string ====== #
	li $t8, '\0'
	li $t7, 0					# Length counter
	li $t5, 0					# Counter for regressing pointer
	simulate_game_moves_length_loop: 
		lb $t5, ($s2)			# Load first byte of moves into $t5
		beqz $t5, simulate_game_moves_length_regress_pointer		# If byte = '\n'
		addi $s2, $s2, 1
		addi $t7, $t7, 1
		j simulate_game_moves_length_loop
	simulate_game_moves_length_regress_pointer:	# Move the pointer back
		beq $t5, $t7, simulate_game_moves_length_continue
		addi $t5, $t5, 1
		addi $s2, $s2, -1
		j simulate_game_moves_length_regress_pointer
	simulate_game_moves_length_continue:
		li $t5, 4		# Divide length by 4
		div $t7, $t5
		mflo $s6
	# ====== Test moves length ====== #
	#move $v0, $s6
	#j simulate_game_done
	# ====== Test moves length ====== #
	# ====== Begin loading the game ====== #
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a0, $s0
	move $a1, $s1
	jal load_game
	move $t4, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bltz $t4, simulate_game_filename_error		# Error checker
	# ====== Test the state ====== #
	#lb $t6, ($s0)
	#lb $t7, 1($s0)
	#move $v0, $t6
	#move $v1, $t7
	#j simulate_game_done
	# ====== Test the state ====== #
	# ====== After loading game ====== #
	li $t0, 0				# # of pieces successfully dropped. Move into $v0
	li $t1, 0				# move_number = 0
	move $t2, $s6			# moves_length = len(moves)/4
	li $t3, 0				# game_over = false
	li $t4, 0				# score = 0	
	
	
	simulate_game_loop:
		bgtz $t3, simulate_game_loop_exit
		bge $t0, $s4, simulate_game_loop_exit
		bge $t1, $t2, simulate_game_loop_exit
		lb $s6, ($s2)			# $s6 = piece_type
		addi $s2, $s2, 1		
		lb $s7, ($s2)			
		addi $s7, $s7, -48		# $s7 = rotation
		addi $s2, $s2, 1
		lb $t5, ($s2)			# $t5 = column digit 1
		addi $t5, $t5, -48
		addi $s2, $s2, 1
		lb $t6, ($s2)
		addi $t6, $t6, -48		# $t6 = column digit 2
		addi $s2, $s2, 1
		li $t7, 10
		mul $t5, $t5, $t7
		add $t5, $t6, $t5		# $t5 = 10(column digit 1) + column digit 2
		# ===== Check ===== #
		#lb $t5, ($s2)
		#move $v0, $t5
		#move $v1, $s6
		#j simulate_game_done
		li $t6, 0 				# Invalid = false
		# ====== 'T' ====== #
		li $t7, 'T'
		beq $s6, $t7, simulate_game_t_type_encountered
		# ====== 'J' ====== #
		li $t7, 'J'
		beq $t7, $s6, simulate_game_j_type_encountered
		# ====== 'Z' ====== #
		li $t7, 'Z'
		beq $t7, $s6, simulate_game_z_type_encountered
		# ====== 'O' ====== #
		li $t7, 'O'
		beq $t7, $s6, simulate_game_o_type_encountered
		# ====== 'S' ====== #
		li $t7, 'S'
		beq $t7, $s6, simulate_game_s_type_encountered
		# ====== 'L' ====== #
		li $t7, 'L'
		beq $t7, $s6, simulate_game_l_type_encountered
		# ====== 'I' ====== #
		li $t7, 'I'
		beq $t7, $s6, simulate_game_i_type_encountered
		simulate_game_t_type_encountered:
			li $t9, 0
			li $t7, 0
			sll $t9, $t7, 3		# $t9 = i * 8
			add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
			move $s6, $t9		# $s6 contains the word at array[i]
			j simulate_game_type_encountered_continue
		simulate_game_j_type_encountered:
			li $t7, 0		# Counter
			li $t8, 2		# Checker		
			simulate_game_j_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9		# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_j_type_encountered_loop
		simulate_game_z_type_encountered:
			li $t7, 0		# Counter
			li $t8, 3		# Checker		
			simulate_game_z_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9		# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_z_type_encountered_loop
		simulate_game_o_type_encountered:
			li $t7, 0		# Counter
			li $t8, 4		# Checker		
			simulate_game_o_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9		# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_o_type_encountered_loop
		simulate_game_s_type_encountered:
			li $t7, 0		# Counter
			li $t8, 5		# Checker		
			simulate_game_s_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9			# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_s_type_encountered_loop
		simulate_game_l_type_encountered:
			li $t7, 0		# Counter
			li $t8, 6		# Checker		
			simulate_game_l_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9			# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_l_type_encountered_loop
		simulate_game_i_type_encountered:
			li $t7, 0		# Counter
			li $t8, 7		# Checker		
			simulate_game_i_type_encountered_loop:
				li $t9, 0
				beq $t7, $t8, simulate_game_type_encountered_continue
				sll $t9, $t7, 3		# $t9 = i * 8
				add $t9, $t9, $s5	# $t9 = addr of pieces_array[i]
				move $s6, $t9		# $s6 contains the word at array[i]
				addi $t7, $t7, 1
				j simulate_game_i_type_encountered_loop	
		simulate_game_type_encountered_continue:
			# ====== Checker for piece ====== #
			#lb $t8, ($s6)
			#lb $t9, 1($s6)	
			#move $v0, $t8
			#move $v1, $t9
			#j simulate_game_done
			# ====== Checker for piece ====== #
			# ====== Attempt to drop piece ====== #
			addi $sp, $sp, -32
			sw $ra, ($sp)
			sw $t0, 4($sp)
			sw $t1, 8($sp)
			sw $t2, 12($sp)
			sw $t3, 16($sp)
			sw $t4, 20($sp)
			sw $t5, 24($sp)
			sw $t6, 28($sp)
			move $a0, $s0		# state
			move $a1, $t5		# column
			move $a2, $s6		# piece
			move $a3, $s7		# rotation
			addi $sp, $sp, -4
			sw $s3, 0($sp)		# store rotated buffer
			jal drop_piece
			addi $sp, $sp, 4
			move $t7, $v0		# result = drop_piece
			lw $ra, ($sp)
			lw $t0, 4($sp)
			lw $t1, 8($sp)
			lw $t2, 12($sp)
			lw $t3, 16($sp)
			lw $t4, 20($sp)
			lw $t5, 24($sp)
			lw $t6, 28($sp)
			addi $sp, $sp, 32
			# ====== Checker for rotated piece ====== #
			lb $t8, ($s3)
			lb $t9, 1($s3)	
			move $v0, $t8
			move $v1, $t9
			#j simulate_game_done
			# ====== Checker for piece ====== #
			# ====== Checker for result ====== #
			#move $v0, $t7
			#j simulate_game_done
			li $t8, -1
			beq $t7, $t8, simulate_game_game_over
			blt $t7, $t8, simulate_game_invalid_drop
			bgt $t7, $t8, simulate_game_valid_drop
			simulate_game_game_over:
				addi $t3, $t3, 1		# game_over = true
				addi $t6, $t6, 1		# invalid = true
				addi $t1, $t1, 1		# move_number++
				j simulate_game_loop
			simulate_game_invalid_drop:
				addi $t6, $t6, 1		# invlid = true
				addi $t1, $t1, 1		# move_number++
				j simulate_game_loop
			
			simulate_game_valid_drop:
				li $t6, 0				# count = 0
				lb $t7, ($s0)
				addi $t7, $t7, -1		# $t7 = state.row - 1
				simulate_game_check_row_clear_loop:
					bltz $t7, simulate_game_check_row_clear_loop_continue
					# ====== Check row clear ====== #
					addi $sp, $sp, -36
					sw $ra, ($sp)
					sw $t0, 4($sp)
					sw $t1, 8($sp)
					sw $t2, 12($sp)
					sw $t3, 16($sp)
					sw $t4, 20($sp)
					sw $t5, 24($sp)
					sw $t6, 28($sp)
					sw $t7, 32($sp)
					move $a0, $s0
					move $a1, $t7
					jal check_row_clear
					move $t8, $v0
					lw $ra, ($sp)
					lw $t0, 4($sp)
					lw $t1, 8($sp)
					lw $t2, 12($sp)
					lw $t3, 16($sp)
					lw $t4, 20($sp)
					lw $t5, 24($sp)
					lw $t6, 28($sp)
					lw $t7, 32($sp)
					addi $sp, $sp, 36
					li $t9, 1
					beq $t8, $t9, simulate_game_increment_the_count
					bne $t8, $t9, simulate_game_skip_incrementing_count
					simulate_game_increment_the_count:
						addi $t6, $t6, 1
						j simulate_game_check_row_clear_loop
					simulate_game_skip_incrementing_count:
						addi $t7, $t7, -1
						j simulate_game_check_row_clear_loop
			
			simulate_game_check_row_clear_loop_continue:
				# update the score
				# If count == 0
				beqz $t6, simulate_game_increment_counters
				# If count == 1
				li $t7, 1
				beq $t6, $t7, simulate_game_count_is_one
				# If count == 2
				li $t7, 2
				beq $t6, $t7, simulate_game_count_is_two
				# If count == 3
				li $t7, 3
				beq $t6, $t7, simulate_game_count_is_three
				# If count == 4
				li $t7, 4
				beq $t6, $t7, simulate_game_count_is_four
				
				simulate_game_count_is_one:
					addi $t4, $t4, 40
					j simulate_game_increment_counters
				simulate_game_count_is_two:
					addi $t4, $t4, 100
					j simulate_game_increment_counters
				simulate_game_count_is_three:
					addi $t4, $t4, 300
					j simulate_game_increment_counters
				simulate_game_count_is_four:
					addi $t4, $t4, 1200
					j simulate_game_increment_counters
				
			simulate_game_increment_counters:
				addi $t1, $t1, 1
				addi $t0, $t0, 1
				j simulate_game_loop
		
		
		
		
	simulate_game_loop_exit:
		move $v0, $t0
		move $v1, $t4
		j simulate_game_done
	
	
	# ====== Break to error ====== #
	simulate_game_filename_error:
		li $v0, 0
		li $v1, 0
		j simulate_game_done
	simulate_game_done:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 32
		jr $ra
