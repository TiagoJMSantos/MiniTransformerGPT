###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_TAB 9
.equ CONST_CHAR_CR 13
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME                     # a0 = address of the vocabulary filename string
    la a1, VOCAB_BUFFER                            # a1 = address of the vocabulary destination buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read vocab.txt into VOCAB_BUFFER

    ###########################################################################
    # DEBUG disabled for final output
    ###########################################################################
    # la a0, VOCAB_BUFFER
    # jal print_vocabulary
    
    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME                          # a0 = address of the input filename string
    la a1, INPUT_BUFFER                            # a1 = address of the input destination buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read input.txt into INPUT_BUFFER

    ###########################################################################
    # DEBUG disabled for final output
    ###########################################################################
    # la a0, INPUT_BUFFER
    # jal print_input

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME                            # a0 = address of the W_Q filename string
    la a1, MATRIX_BUFFER                           # a1 = address of the reusable matrix text buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read W_Q.txt into MATRIX_BUFFER

    ###########################################################################
    # Parse W_Q matrix from buffer
    ###########################################################################
    la a0, W_Q_MATRIX                              # a0 = address of the destination integer matrix
    la a1, MATRIX_BUFFER                           # a1 = address of the text buffer with W_Q contents
    jal parse_matrix_buffer                        # convert W_Q text into W_Q_MATRIX

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME                            # a0 = address of the W_K filename string
    la a1, MATRIX_BUFFER                           # a1 = address of the reusable matrix text buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read W_K.txt into MATRIX_BUFFER

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX                              # a0 = address of the destination integer matrix
    la a1, MATRIX_BUFFER                           # a1 = address of the text buffer with W_K contents
    jal parse_matrix_buffer                        # convert W_K text into W_K_MATRIX

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME                            # a0 = address of the W_V filename string
    la a1, MATRIX_BUFFER                           # a1 = address of the reusable matrix text buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read W_V.txt into MATRIX_BUFFER

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX                              # a0 = address of the destination integer matrix
    la a1, MATRIX_BUFFER                           # a1 = address of the text buffer with W_V contents
    jal parse_matrix_buffer                        # convert W_V text into W_V_MATRIX

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    la a0, EMBEDDINGS_FILENAME                     # a0 = address of the embeddings filename string
    la a1, MATRIX_BUFFER                           # a1 = address of the reusable matrix text buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read embeddings.txt into MATRIX_BUFFER

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX                 # a0 = address of the destination embeddings matrix
    la a1, MATRIX_BUFFER                           # a1 = address of the text buffer with embeddings contents
    jal parse_matrix_buffer                        # convert embeddings text into VOCAB_EMBEDDINGS_MATRIX
    la t0, VOCAB_TOTAL_TOKENS                      # t0 = address where the vocabulary size is stored
    sw a1, 0(t0)                                   # store the number of parsed embedding rows

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR                    # a0 = address of the output input-index vector
    la a2, INPUT_BUFFER                            # a2 = address of the input tokens buffer
    la a3, VOCAB_BUFFER                            # a3 = address of the vocabulary tokens buffer
    jal tokens_to_indices                          # convert input words into vocabulary indices
    la t0, INPUT_TOTAL_TOKENS                      # t0 = address where the input size is stored
    sw a1, 0(t0)                                   # store the number of input tokens

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX                 # a0 = address of the output input embeddings matrix
    la a1, VOCAB_EMBEDDINGS_MATRIX                 # a1 = address of the vocabulary embeddings matrix
    la a2, INPUT_INDICES_VECTOR                    # a2 = address of the input-index vector
    lw a3, INPUT_TOTAL_TOKENS                      # a3 = number of input tokens
    jal build_input_embeddings_matrix              # build E from the selected vocabulary embeddings

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX                                # a0 = address of the Q output matrix
    la a1, INPUT_EMBEDDINGS_MATRIX                 # a1 = address of the E matrix
    lw a2, INPUT_TOTAL_TOKENS                      # a2 = number of rows of E
    li a3, CONST_DIMENSION                         # a3 = number of columns of E
    la a4, W_Q_MATRIX                              # a4 = address of W_Q
    li a5, CONST_DIMENSION                         # a5 = number of rows of W_Q
    li a6, CONST_DIMENSION                         # a6 = number of columns of W_Q
    jal matrix_multiply                            # compute Q = E x W_Q

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX                                # a0 = address of the K output matrix
    la a1, INPUT_EMBEDDINGS_MATRIX                 # a1 = address of the E matrix
    lw a2, INPUT_TOTAL_TOKENS                      # a2 = number of rows of E
    li a3, CONST_DIMENSION                         # a3 = number of columns of E
    la a4, W_K_MATRIX                              # a4 = address of W_K
    li a5, CONST_DIMENSION                         # a5 = number of rows of W_K
    li a6, CONST_DIMENSION                         # a6 = number of columns of W_K
    jal matrix_multiply                            # compute K = E x W_K

    ###########################################################################
    # Build matrix V
    ###########################################################################
    la a0, V_MATRIX                                # a0 = address of the V output matrix
    la a1, INPUT_EMBEDDINGS_MATRIX                 # a1 = address of the E matrix
    lw a2, INPUT_TOTAL_TOKENS                      # a2 = number of rows of E
    li a3, CONST_DIMENSION                         # a3 = number of columns of E
    la a4, W_V_MATRIX                              # a4 = address of W_V
    li a5, CONST_DIMENSION                         # a5 = number of rows of W_V
    li a6, CONST_DIMENSION                         # a6 = number of columns of W_V
    jal matrix_multiply                            # compute V = E x W_V

    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR                           # a0 = address of the output scores vector
    la a1, Q_MATRIX                                # a1 = address of Q
    la a2, K_MATRIX                                # a2 = address of K
    lw a3, INPUT_TOTAL_TOKENS                      # a3 = number of rows in Q and K
    li a4, CONST_DIMENSION                         # a4 = number of columns in Q and K
    addi a5, a3, -1                                # a5 = target token index, which is the last input index
    jal compute_scores                             # compute score(j) = Q[last] dot K[j]

    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    la a1, SCORES_VECTOR                           # a1 = address of the scores vector
    lw a2, INPUT_TOTAL_TOKENS                      # a2 = number of scores
    jal argmax                                     # a1 = index of the highest score

    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    mv a4, a1                                      # a4 = target row selected by argmax
    la a1, V_MATRIX                                # a1 = address of V
    lw a2, INPUT_TOTAL_TOKENS                      # a2 = number of rows in V
    li a3, CONST_DIMENSION                         # a3 = number of columns in V
    jal select_vector_in_matrix                    # a0 = address of the selected V row

    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    la a1, VOCAB_EMBEDDINGS_MATRIX                 # a1 = address of vocabulary embeddings
    lw a2, VOCAB_TOTAL_TOKENS                      # a2 = number of vocabulary tokens
    jal decide_next_token                          # a0 = predicted token index

    ###########################################################################
    # Print predicted token
    ###########################################################################
    la a1, VOCAB_BUFFER                            # a1 = address of vocabulary text buffer
    jal print_predicted_token                      # print the predicted token

    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    li a0, 0                                       # a0 = success exit code
    j exit_with_code                               # exit with code 0

# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
read_file:                                          # label for read file
    addi sp, sp, -12                               # allocate stack space for s0, s1, and s2
    sw s0, 0(sp)                                   # save s0 because this function uses it
    sw s1, 4(sp)                                   # save s1 because this function uses it
    sw s2, 8(sp)                                  # save s2 because this function uses it

    mv s0, a1                                      # s0 = destination buffer address
    mv s1, a2                                      # s1 = maximum number of bytes to read

    li a1, 0                                       # a1 = flags, where 0 means read-only mode
    li a7, CONST_SYSCALL_OPEN                      # a7 = open syscall number
    ecall                                          # open the file whose name is in a0

    mv s2, a0                                      # s2 = file descriptor returned by open
    mv a0, s2                                      # a0 = file descriptor for read

    mv a1, s0                                      # a1 = destination buffer for read
    mv a2, s1                                      # a2 = maximum number of bytes for read
    li a7, CONST_SYSCALL_READ                      # a7 = read syscall number
    ecall                                          # read the file into the destination buffer

    j read_file_close
read_file_close:                                    # label for read file close
    mv a0, s2                                      # a0 = file descriptor for close
    li a7, CONST_SYSCALL_CLOSE                     # a7 = close syscall number
    ecall                                          # close the file
    
    lw s0, 0(sp)                                   # restore s0
    lw s1, 4(sp)                                   # restore s1
    lw s2, 8(sp)                                  # restore s2
    addi sp, sp, 12                                # free stack space
    jr ra                                            # return to the caller

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    # 1. Copy arguments to work registers
    mv t0, a0                                      # t0 = current output position in the integer matrix
    mv t1, a1                                      # t1 = current input position in the text buffer
    
    # 2. Initialize state variables
    li t2, 0                                       # t2 = number of parsed rows
    li t3, 0                                       # t3 = current integer value being parsed
    li t4, 0                                       # t4 = current sign flag (0 = positive, 1 = negative)
    li t5, 0                                       # t5 = in-number flag (0 = false, 1 = true)
    
    # 3. Load defined global constants ONLY ONCE outside the loop
    li a2, CONST_CHAR_HYPHEN                       # a2 = ASCII code for '-'
    li a3, CONST_CHAR_SPACE                        # a3 = ASCII code for space
    li a4, CONST_CHAR_NEWLINE                      # a4 = ASCII code for newline
    li a5, 10                                      # a5 = decimal base 10

parse_matrix_loop:
    lb t6, 0(t1)                                   # t6 = current character from the text buffer
    beqz t6, parse_matrix_end                      # If character is EOF/null, finish parsing

    beq t6, a2, parse_matrix_minus                 # If character is '-', handle negative sign
    beq t6, a3, parse_matrix_separator             # If character is space, finish current number
    beq t6, a4, parse_matrix_newline               # If character is newline, finish current row

    
    addi t6, t6, -48                               # Convert ASCII to numeric value
    mul t3, t3, a5                                 # current value = current value * 10
    add t3, t3, t6                                 # current value = current value + digit
    li t5, 1                                       # Mark that we are currently parsing a number

parse_matrix_next_char:
    addi t1, t1, 1                                 # Move to the next character in the buffer
    j parse_matrix_loop                            # Continue parsing

parse_matrix_minus:
    li t4, 1                                       # Set negative sign flag to true
    li t5, 1                                       # Mark that a number has started
    j parse_matrix_next_char                       # Move to next character

parse_matrix_separator:
    beqz t5, parse_matrix_next_char                # If no number is active, skip the separator
    li t6, 0                                       # FLAG: 0 means we came from a space separator
    j parse_matrix_prepare_store

parse_matrix_newline:
    beqz t5, parse_matrix_count_row                # If no number is active, just count the row
    li t6, 1                                       # FLAG: 1 means we came from a newline

parse_matrix_prepare_store:
    # Apply sign using fast 'neg' instruction
    beqz t4, parse_matrix_store
    neg t3, t3                                     # Invert sign if negative flag is active

parse_matrix_store:
    sw t3, 0(t0)                                   # Store the parsed integer in the output matrix
    addi t0, t0, 4                                 # Move to the next output integer slot (4 bytes)
    
    # Reset number parsing state for the next integer
    li t3, 0                                       
    li t4, 0                                       
    li t5, 0   

    # Check the flag we set in t6 to decide where to go
    bnez t6, parse_matrix_count_row                # If t6 == 1, it was a newline -> go count the row
    j parse_matrix_next_char                       # If t6 == 0, it was a space -> just go to next char

parse_matrix_count_row:
    addi t2, t2, 1                                 # Count one completed matrix row
    addi t1, t1, 1                                 # Move past the newline character
    j parse_matrix_loop                            # Continue parsing

parse_matrix_end:
    mv a1, t2                                      # a1 = total number of parsed rows (output)
    jr ra                                          # Return to the caller using jr ra
# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer
tokens_to_indices:
    mv t0, a0                  # t0 = current output position in the indices vector
    mv t1, a2                  # t1 = current input token pointer
    li t3, 0                   # t3 = number of input tokens converted
    li t4, 10                  # t4 = '\n' (newline ASCII). The only separator we care about!

tokens_outer_loop:
    lb a4, 0(t1)               # Load current character from input
    beqz a4, tokens_done       # If we reached the end of the input (\0), finish
    beq a4, t4, tokens_skip_input_separators # Ignore repeating or leading newlines
    
tokens_start_vocab_search:
    # Prepare vocabulary search from the beginning for this input word
    mv t5, a3                  # t5 = current vocabulary token pointer
    li t6, 0                   # t6 = current vocabulary token index
    
tokens_vocab_loop:
    lb a5, 0(t5)               # Load current character from vocabulary
    beqz a5, tokens_ignore_input # Failsafe: end of vocab reached
    beq a5, t4, tokens_skip_vocab_separators
    
tokens_begin_compare:
    # Set up temporary pointers to compare character by character
    mv a6, t1                  # a6 = input comparison pointer
    mv a7, t5                  # a7 = vocabulary comparison pointer
    
tokens_compare_loop:
    lb a4, 0(a6)               # Input character
    lb a5, 0(a7)               # Vocabulary character
    
    # Did the input word end? (hit a '\n' or '\0')
    beq a4, t4, tokens_input_ended
    beqz a4, tokens_input_ended
    
    # Normal letters: if they are different, the words don't match
    bne a4, a5, tokens_not_equal
    
    # Letters match: move to the next character
    addi a6, a6, 1
    addi a7, a7, 1
    j tokens_compare_loop

tokens_input_ended:
    # The input word ended. For a match, the vocabulary word must also end here.
    beq a5, t4, tokens_equal
    beqz a5, tokens_equal
    j tokens_not_equal         # Vocab word was longer than the input word

tokens_equal:
    sw t6, 0(t0)               # Store the vocabulary index in the output array
    addi t0, t0, 4             # Advance the output array pointer (1 int = 4 bytes)
    addi t3, t3, 1             # Increment the converted tokens counter
    mv t1, a6                  # Advance the main input pointer to the end of the matched word
    j tokens_outer_loop

tokens_not_equal:
    # Advance the vocabulary pointer (t5) until we find the next '\n'
    lb a5, 0(t5)
    beqz a5, tokens_done       # Failsafe: end of vocab buffer
    beq a5, t4, tokens_vocab_next
    addi t5, t5, 1
    j tokens_not_equal
    
tokens_vocab_next:
    addi t5, t5, 1             # Skip the '\n' separator
    addi t6, t6, 1             # Increment the vocabulary index counter
    j tokens_vocab_loop

tokens_skip_input_separators:
    addi t1, t1, 1             # Consume the extra '\n' from the input
    j tokens_outer_loop
    
tokens_skip_vocab_separators:
    addi t5, t5, 1             # Consume the extra '\n' from the vocabulary
    j tokens_vocab_loop

tokens_ignore_input:
    # If the word isn't in the vocabulary (failsafe), skip it and move to the next input word
    lb a4, 0(t1)
    beqz a4, tokens_done
    beq a4, t4, tokens_advance_input_ignored
    addi t1, t1, 1
    j tokens_ignore_input

tokens_advance_input_ignored:
    addi t1, t1, 1
    j tokens_outer_loop

tokens_done:
    mv a1, t3                  # Return the total number of converted tokens in a1
    jr ra
# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    mv t0, a0                                      # t0 = current output position in the input embeddings matrix
    mv t1, a1                                      # t1 = base address of the vocabulary embeddings matrix
    mv t2, a2                                                                            # t2 = current position in the input indices array
    li t3, 0                                       # t3 = current input token counter

build_embeddings_token_loop:
    beq t3, a3, build_embeddings_done              # if all input tokens were copied, finish
    lw t4, 0(t2)                                   # t5 = vocabulary index of the current input token
    slli t5, t4, 4                                 # t6 = byte offset of the vocabulary row, because 4 ints * 4 bytes = 16
    add a4, t1, t5                                 # a4 = address of the selected vocabulary embedding row
    li a5, 0                                       # a5 = current column counter
    li t6, CONST_DIMENSION                         # a6 = embedding dimension

build_embeddings_col_loop:
    beq a5, t6, build_embeddings_next_token        # if all columns were copied, move to next token
    lw a6, 0(a4)                                   # a7 = current embedding value from vocabulary matrix
    sw a6, 0(t0)                                   # store the embedding value into the input matrix
    addi a4, a4, 4                                 # move to the next source integer
    addi t0, t0, 4                                 # move to the next destination integer
    addi a5, a5, 1                                 # increment the column counter
    j build_embeddings_col_loop                    # continue copying the current embedding row

build_embeddings_next_token:
    addi t2, t2, 4                                 # move to the next input index
    addi t3, t3, 1                                 # increment the input token counter
    j build_embeddings_token_loop                  # process the next input token

build_embeddings_done:
    ret                                            # return to the caller

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
matrix_multiply:
    addi sp, sp, -48                               # allocate stack space for saved registers
    sw ra, 0(sp)                                   # save the return address
    sw s0, 4(sp)                                   # save s0
    sw s1, 8(sp)                                   # save s1
    sw s2, 12(sp)                                  # save s2
    sw s3, 16(sp)                                  # save s3
    sw s4, 20(sp)                                  # save s4
    sw s5, 24(sp)                                  # save s5
    sw s6, 28(sp)                                  # save s6
    sw s7, 32(sp)                                  # save s7
    sw s8, 36(sp)                                  # save s8
    sw s9, 40(sp)                                  # save s9
    sw s10, 44(sp)                                 # save s10
    mv s0, a0                                      # s0 = output matrix base address
    mv s1, a1                                      # s1 = first matrix base address
    mv s2, a2                                      # s2 = number of rows of the first matrix
    mv s3, a3                                      # s3 = number of columns of the first matrix
    mv s4, a4                                      # s4 = second matrix base address
    mv s6, a6                                      # s6 = number of columns of the second matrix
    li s7, 0                                       # s7 = row index i
matrix_row_loop:
    beq s7, s2, matrix_done                        # if i == rowsA, multiplication is done
    li s8, 0                                       # s8 = column index j
matrix_col_loop:
    beq s8, s6, matrix_next_row                    # if j == colsB, move to next row
    li s9, 0                                       # s9 = inner index k
    li s10, 0                                      # s10 = accumulated sum for C[i][j]
matrix_inner_loop:
    beq s9, s3, matrix_store_cell                  # if k == colsA, store the accumulated sum
    mul t0, s7, s3                                 # t0 = i * colsA
    add t0, t0, s9                                 # t0 = i * colsA + k
    slli t0, t0, 2                                 # t0 = byte offset of A[i][k]
    add t0, s1, t0                                 # t0 = address of A[i][k]
    lw t1, 0(t0)                                   # t1 = A[i][k]
    mul t2, s9, s6                                 # t2 = k * colsB
    add t2, t2, s8                                 # t2 = k * colsB + j
    slli t2, t2, 2                                 # t2 = byte offset of B[k][j]
    add t2, s4, t2                                 # t2 = address of B[k][j]
    lw t3, 0(t2)                                   # t3 = B[k][j]
    mul t4, t1, t3                                 # t4 = A[i][k] * B[k][j]
    add s10, s10, t4                               # sum += A[i][k] * B[k][j]
    addi s9, s9, 1                                 # k++
    j matrix_inner_loop                            # continue the inner loop
matrix_store_cell:
    mul t0, s7, s6                                 # t0 = i * colsB
    add t0, t0, s8                                 # t0 = i * colsB + j
    slli t0, t0, 2                                 # t0 = byte offset of C[i][j]
    add t0, s0, t0                                 # t0 = address of C[i][j]
    sw s10, 0(t0)                                  # store C[i][j]
    addi s8, s8, 1                                 # j++
    j matrix_col_loop                              # compute the next column
matrix_next_row:
    addi s7, s7, 1                                 # i++
    j matrix_row_loop                              # compute the next row
matrix_done:
    lw ra, 0(sp)                                   # restore the return address
    lw s0, 4(sp)                                   # restore s0
    lw s1, 8(sp)                                   # restore s1
    lw s2, 12(sp)                                  # restore s2
    lw s3, 16(sp)                                  # restore s3
    lw s4, 20(sp)                                  # restore s4
    lw s5, 24(sp)                                  # restore s5
    lw s6, 28(sp)                                  # restore s6
    lw s7, 32(sp)                                  # restore s7
    lw s8, 36(sp)                                  # restore s8
    lw s9, 40(sp)                                  # restore s9
    lw s10, 44(sp)                                 # restore s10
    addi sp, sp, 48                                # free stack space
    ret                                            # return to the caller

# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)
compute_scores:
    # 1. Allocate stack space (need to save ra and 7 's' registers)
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    # 2. Save arguments in preserved registers
    mv s6, a0                  # s6 = original scores base address (to return at the end)
    mv s0, a0                  # s0 = moving pointer for the scores vector
    mv s3, a3                  # s3 = row counter
    mv s4, a4                  # s4 = number of columns (vector length to pass to dot)

    # 3. Calculate the size of a row in bytes (stride = columns * 4)
    slli s5, s4, 2             # s5 = bytes to skip to reach the next row

    # 4. Calculate the static address of Q[target]
    # offset = target_index * stride
    mul t0, a5, s5
    add s1, a1, t0             # s1 = address of row Q[target] (remains constant)

    # 5. K pointer starts at the initial base address
    mv s2, a2                  # s2 = moving pointer for K[j]

    # Failsafe: if the number of rows is 0, exit immediately
    beqz s3, compute_scores_done

compute_scores_loop:
    # 6. Prepare arguments for the dot function
    mv a1, s1                  # arg a1 = address of Q[target]
    mv a2, s2                  # arg a2 = current address of K[j]
    mv a3, s4                  # arg a3 = vector length (number of columns)

    jal dot                    # Compute the dot product: score = Q[target] · K[j]

    # 7. The dot function returns the result in a1 (a0 brings the error code, which we ignore)
    sw a1, 0(s0)               # Store the result at the current address of scores

    # 8. Advance the moving pointers for the next iteration
    addi s0, s0, 4             # Advance output pointer by 1 position (4 bytes)
    add s2, s2, s5             # Advance K pointer by 1 full row (stride bytes)

    # 9. Decrement the counter and repeat if it hasn't reached 0
    addi s3, s3, -1
    bnez s3, compute_scores_loop

compute_scores_done:
    # 10. Restore a0 with the original in/out address
    mv a0, s6                  

    # 11. Clean up the stack and restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    
    jr ra

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    mul t0, a4, a3                                 # t0 = target row * number of columns
    slli t0, t0, 2                                 # t0 = byte offset of the selected row
    add a0, a1, t0                                 # a0 = address of the selected row
    jr ra                                            # return to the caller

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    addi sp, sp, -32                               # allocate stack space for ra and saved registers
    sw ra, 0(sp)                                   # save the return address
    sw s0, 4(sp)                                   # save s0
    sw s1, 8(sp)                                   # save s1
    sw s2, 12(sp)                                  # save s2
    sw s3, 16(sp)                                  # save s3
    sw s4, 20(sp)                                  # save s4
    sw s5, 24(sp)                                  # save s5
    sw s6, 28(sp)                                  # save s6
    mv s0, a0                                      # s0 = target vector address
    mv s1, a1                                      # s1 = vocabulary embeddings base address
    mv s2, a2                                      # s2 = number of vocabulary tokens
    li s3, 0                                       # s3 = current vocabulary index
    li s4, 0                                       # s4 = best score found so far
    li s5, 0                                       # s5 = best token index found so far
    li s6, 1                                       # s6 = first-iteration flag

decide_loop:
    beq s3, s2, decide_done                        # if all vocabulary tokens were checked, finish
    slli t0, s3, 4                                 # t0 = byte offset of vocab row, because 4 ints * 4 bytes = 16
    add t1, s1, t0                                 # t1 = address of the current vocabulary embedding
    mv a1, s0                                      # a1 = address of the target vector
    mv a2, t1                                      # a2 = address of the current vocabulary embedding
    li a3, CONST_DIMENSION                         # a3 = vector length
    jal dot                                        # compute similarity score using dot product
    bnez s6, decide_update_best                    # if this is the first score, store it as the best score
    bgt a1, s4, decide_update_best                 # if current score > best score, update the best token
    j decide_next                                  # otherwise keep the previous best token

decide_update_best:
    mv s4, a1                                      # s4 = new best score
    mv s5, s3                                      # s5 = new best token index
    li s6, 0                                       # clear first-iteration flag

decide_next:
    addi s3, s3, 1                                 # move to the next vocabulary token
    j decide_loop                                  # continue checking vocabulary embeddings

decide_done:
    mv a0, s5                                      # a0 = predicted token index
    lw ra, 0(sp)                                   # restore the return address
    lw s0, 4(sp)                                   # restore s0
    lw s1, 8(sp)                                   # restore s1
    lw s2, 12(sp)                                  # restore s2
    lw s3, 16(sp)                                  # restore s3
    lw s4, 20(sp)                                  # restore s4
    lw s5, 24(sp)                                  # restore s5
    lw s6, 28(sp)                                  # restore s6
    addi sp, sp, 32                                # free stack space
    ret                                            # return to the caller

# Advances a vocabulary-buffer pointer to the beginning of the next token.
# This label is required because the provided print_predicted_token helper calls it.
# (in)  a0: address of the current token
# (out) a0: address of the next token
advance_to_next_token:
advance_to_next_token_loop:
    lb t0, 0(a0)                                   # t0 = current character
    beqz t0, advance_to_next_token_done            # EOF/null: no next token
    li t1, CONST_CHAR_SPACE
    beq t0, t1, advance_to_next_token_found
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, advance_to_next_token_found
    li t1, CONST_CHAR_TAB
    beq t0, t1, advance_to_next_token_found
    li t1, CONST_CHAR_CR
    beq t0, t1, advance_to_next_token_found
    addi a0, a0, 1
    j advance_to_next_token_loop

advance_to_next_token_found:
    addi a0, a0, 1                                 # move past the separator

advance_to_next_token_skip_separators:
    lb t0, 0(a0)
    beqz t0, advance_to_next_token_done
    li t1, CONST_CHAR_SPACE
    beq t0, t1, advance_to_next_token_skip_one
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, advance_to_next_token_skip_one
    li t1, CONST_CHAR_TAB
    beq t0, t1, advance_to_next_token_skip_one
    li t1, CONST_CHAR_CR
    beq t0, t1, advance_to_next_token_skip_one
    j advance_to_next_token_done

advance_to_next_token_skip_one:
    addi a0, a0, 1
    j advance_to_next_token_skip_separators

advance_to_next_token_done:
    ret                                            # return to the caller

#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bge t0, zero, overflow                          # If t0 >= 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_init                       # if SIZE >= 1, initialize normally
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_init:
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    j argmax_loop
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: index of the predicted token in the vocabulary (int)
# (in) a1: address of vocabulary buffer (char*)
print_predicted_token:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0                                       # s0 = countdown to target index
    mv s1, a1                                       # s1 = current position in vocab buffer
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
print_predicted_token_skip:
    beq s0, zero, print_predicted_token_read
    mv a0, s1                                       # a0 = current position in vocab buffer
    jal advance_to_next_token                       # a0 = next token start
    mv s1, a0                                       # update current position
    addi s0, s0, -1
    j print_predicted_token_skip
print_predicted_token_read:
    # s1 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s1)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_SPACE
    beq t0, t1, print_predicted_token_nl            # space terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    li t1, CONST_CHAR_TAB
    beq t0, t1, print_predicted_token_nl            # tab terminator
    li t1, CONST_CHAR_CR
    beq t0, t1, print_predicted_token_nl            # carriage-return terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret
