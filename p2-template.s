###########################################################################
# CLEAN COMMENTED VERSION - no debug output
# Expected final output with provided input a/boy/eats: food
###########################################################################

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
VOCABULARY_FILENAME:     .string "/home/martim/ASS_Proj/Projeto-IAC-26/vocab.txt"
EMBEDDINGS_FILENAME:     .string "/home/martim/ASS_Proj/Projeto-IAC-26/embeddings.txt"
INPUT_FILENAME:          .string "/home/martim/ASS_Proj/Projeto-IAC-26/input.txt"

W_Q_FILENAME:            .string "/home/martim/ASS_Proj/Projeto-IAC-26/W_Q.txt"
W_K_FILENAME:            .string "/home/martim/ASS_Proj/Projeto-IAC-26/W_K.txt"
W_V_FILENAME:            .string "/home/martim/ASS_Proj/Projeto-IAC-26/W_V.txt"

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
main:                                               # program entry point
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME                     # a0 = address of the vocabulary filename string
    la a1, VOCAB_BUFFER                            # a1 = address of the vocabulary destination buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read vocab.txt into VOCAB_BUFFER

    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME                          # a0 = address of the input filename string
    la a1, INPUT_BUFFER                            # a1 = address of the input destination buffer
    li a2, CONST_BUFFER_SIZE                       # a2 = maximum number of bytes to read
    jal read_file                                  # read input.txt into INPUT_BUFFER

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
tokens_to_indices:                                  # label for tokens to indices
    mv t0, a0                                      # t0 = current output position in the indices vector
    mv t1, a2                                      # t1 = current input token position
    mv t2, a3                                      # t2 = base address of the vocabulary buffer
    li t3, 0                                       # t3 = number of input tokens converted

tokens_outer_loop:                                  # label for tokens outer loop
    # Skip separators before the next input token.
tokens_skip_input_separators:                       # label for tokens skip input separators
    lb t4, 0(t1)                                    # load one byte from memory
    beqz t4, tokens_done                            # branch if the register is zero
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_input_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_input_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_input_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_input_separator     # branch if the two registers are equal
    j tokens_start_vocab_search                     # jump unconditionally to the target label

tokens_skip_one_input_separator:                    # label for tokens skip one input separator
    addi t1, t1, 1                                  # add an immediate constant to a register
    j tokens_skip_input_separators                  # jump unconditionally to the target label

tokens_start_vocab_search:                          # label for tokens start vocab search
    mv t5, t2                                      # t5 = current vocabulary token position
    li t6, 0                                       # t6 = current vocabulary token index

tokens_vocab_loop:                                  # label for tokens vocab loop
    # Skip separators between vocabulary tokens.
tokens_skip_vocab_separators:                       # label for tokens skip vocab separators
    lb t4, 0(t5)                                    # load one byte from memory
    beqz t4, tokens_done                           # not expected: input word not found
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_vocab_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_vocab_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_vocab_separator     # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq t4, a0, tokens_skip_one_vocab_separator     # branch if the two registers are equal
    j tokens_begin_compare                          # jump unconditionally to the target label

tokens_skip_one_vocab_separator:                    # label for tokens skip one vocab separator
    addi t5, t5, 1                                  # add an immediate constant to a register
    j tokens_skip_vocab_separators                  # jump unconditionally to the target label

tokens_begin_compare:                               # label for tokens begin compare
    mv a6, t1                                      # a6 = input comparison pointer
    mv a7, t5                                      # a7 = vocabulary comparison pointer

tokens_compare_loop:                                # label for tokens compare loop
    lb a4, 0(a6)                                   # a4 = current input character
    lb a5, 0(a7)                                   # a5 = current vocabulary character

    # If the input token ended, the vocabulary token must also end.
    beqz a4, tokens_input_ended                     # branch if the register is zero
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq a4, a0, tokens_input_ended                  # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq a4, a0, tokens_input_ended                  # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq a4, a0, tokens_input_ended                  # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq a4, a0, tokens_input_ended                  # branch if the two registers are equal

    # If the vocabulary token ended first, the words are different.
    beqz a5, tokens_not_equal                       # branch if the register is zero
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq a5, a0, tokens_not_equal                    # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq a5, a0, tokens_not_equal                    # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq a5, a0, tokens_not_equal                    # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq a5, a0, tokens_not_equal                    # branch if the two registers are equal

    bne a4, a5, tokens_not_equal                   # different characters => not the same token
    addi a6, a6, 1                                  # add an immediate constant to a register
    addi a7, a7, 1                                  # add an immediate constant to a register
    j tokens_compare_loop                           # jump unconditionally to the target label

tokens_input_ended:                                 # label for tokens input ended
    # Check if vocabulary token also ended.
    beqz a5, tokens_equal                           # branch if the register is zero
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq a5, a0, tokens_equal                        # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq a5, a0, tokens_equal                        # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq a5, a0, tokens_equal                        # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq a5, a0, tokens_equal                        # branch if the two registers are equal
    j tokens_not_equal                              # jump unconditionally to the target label

tokens_equal:                                       # label for tokens equal
    sw t6, 0(t0)                                   # store the vocabulary index for this input token
    addi t0, t0, 4                                  # add an immediate constant to a register
    addi t3, t3, 1                                  # add an immediate constant to a register

    # Advance input pointer to the end of the current token; the outer loop skips separators.
tokens_advance_input:                               # label for tokens advance input
    lb a4, 0(t1)                                    # load one byte from memory
    beqz a4, tokens_outer_loop                      # branch if the register is zero
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq a4, a0, tokens_outer_loop                   # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq a4, a0, tokens_outer_loop                   # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq a4, a0, tokens_outer_loop                   # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq a4, a0, tokens_outer_loop                   # branch if the two registers are equal
    addi t1, t1, 1                                  # add an immediate constant to a register
    j tokens_advance_input                          # jump unconditionally to the target label

tokens_not_equal:                                   # label for tokens not equal
    # Move t5 to the end of the current vocabulary token.
tokens_advance_vocab:                               # label for tokens advance vocab
    lb a4, 0(t5)                                    # load one byte from memory
    beqz a4, tokens_done                           # not expected: input word not found
    li a0, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq a4, a0, tokens_vocab_next                   # branch if the two registers are equal
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq a4, a0, tokens_vocab_next                   # branch if the two registers are equal
    li a0, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq a4, a0, tokens_vocab_next                   # branch if the two registers are equal
    li a0, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq a4, a0, tokens_vocab_next                   # branch if the two registers are equal
    addi t5, t5, 1                                  # add an immediate constant to a register
    j tokens_advance_vocab                          # jump unconditionally to the target label

tokens_vocab_next:                                  # label for tokens vocab next
    addi t5, t5, 1                                 # move past the separator
    addi t6, t6, 1                                 # next vocabulary index
    j tokens_vocab_loop                             # jump unconditionally to the target label

tokens_done:                                        # label for tokens done
    mv a1, t3                                      # a1 = number of converted input tokens
    ret                                            # return to the caller

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:                      # label for build input embeddings matrix
    mv t0, a0                                      # t0 = current output position in the input embeddings matrix
    mv t1, a1                                      # t1 = base address of the vocabulary embeddings matrix
    mv t2, a2                                      # t2 = current position in the input indices array
    mv t3, a3                                      # t3 = number of input tokens
    li t4, 0                                       # t4 = current input token counter
build_embeddings_token_loop:                        # label for build embeddings token loop
    beq t4, t3, build_embeddings_done              # if all input tokens were copied, finish
    lw t5, 0(t2)                                   # t5 = vocabulary index of the current input token
    slli t6, t5, 4                                 # t6 = byte offset of the vocabulary row, because 4 ints * 4 bytes = 16
    add a4, t1, t6                                 # a4 = address of the selected vocabulary embedding row
    li a5, 0                                       # a5 = current column counter
build_embeddings_col_loop:                          # label for build embeddings col loop
    li a6, CONST_DIMENSION                         # a6 = embedding dimension
    beq a5, a6, build_embeddings_next_token        # if all columns were copied, move to next token
    lw a7, 0(a4)                                   # a7 = current embedding value from vocabulary matrix
    sw a7, 0(t0)                                   # store the embedding value into the input matrix
    addi a4, a4, 4                                 # move to the next source integer
    addi t0, t0, 4                                 # move to the next destination integer
    addi a5, a5, 1                                 # increment the column counter
    j build_embeddings_col_loop                    # continue copying the current embedding row
build_embeddings_next_token:                        # label for build embeddings next token
    addi t2, t2, 4                                 # move to the next input index
    addi t4, t4, 1                                 # increment the input token counter
    j build_embeddings_token_loop                  # process the next input token
build_embeddings_done:                              # label for build embeddings done
    ret                                            # return to the caller

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
matrix_multiply:                                    # label for matrix multiply
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
matrix_row_loop:                                    # label for matrix row loop
    beq s7, s2, matrix_done                        # if i == rowsA, multiplication is done
    li s8, 0                                       # s8 = column index j
matrix_col_loop:                                    # label for matrix col loop
    beq s8, s6, matrix_next_row                    # if j == colsB, move to next row
    li s9, 0                                       # s9 = inner index k
    li s10, 0                                      # s10 = accumulated sum for C[i][j]
matrix_inner_loop:                                  # label for matrix inner loop
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
matrix_store_cell:                                  # label for matrix store cell
    mul t0, s7, s6                                 # t0 = i * colsB
    add t0, t0, s8                                 # t0 = i * colsB + j
    slli t0, t0, 2                                 # t0 = byte offset of C[i][j]
    add t0, s0, t0                                 # t0 = address of C[i][j]
    sw s10, 0(t0)                                  # store C[i][j]
    addi s8, s8, 1                                 # j++
    j matrix_col_loop                              # compute the next column
matrix_next_row:                                    # label for matrix next row
    addi s7, s7, 1                                 # i++
    j matrix_row_loop                              # compute the next row
matrix_done:                                        # label for matrix done
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
compute_scores:                                     # label for compute scores
    addi sp, sp, -36                               # allocate stack space for ra and saved registers
    sw ra, 0(sp)                                   # save the return address
    sw s0, 4(sp)                                   # save s0
    sw s1, 8(sp)                                   # save s1
    sw s2, 12(sp)                                  # save s2
    sw s3, 16(sp)                                  # save s3
    sw s4, 20(sp)                                  # save s4
    sw s5, 24(sp)                                  # save s5
    sw s6, 28(sp)                                  # save s6
    sw s7, 32(sp)                                  # save s7
    mv s0, a0                                      # s0 = scores vector base address
    mv s1, a1                                      # s1 = Q matrix base address
    mv s2, a2                                      # s2 = K matrix base address
    mv s3, a3                                      # s3 = number of rows
    mv s4, a4                                      # s4 = number of columns
    mv s5, a5                                      # s5 = target token index
    mul t0, s5, s4                                 # t0 = target index * number of columns
    slli t0, t0, 2                                 # t0 = byte offset of Q[target]
    add s7, s1, t0                                 # s7 = address of Q[target]
    li s6, 0                                       # s6 = current row index j
compute_scores_loop:                                # label for compute scores loop
    beq s6, s3, compute_scores_done                # if j == number of rows, all scores are computed
    mul t0, s6, s4                                 # t0 = j * number of columns
    slli t0, t0, 2                                 # t0 = byte offset of K[j]
    add t1, s2, t0                                 # t1 = address of K[j]
    mv a1, s7                                      # a1 = address of Q[target]
    mv a2, t1                                      # a2 = address of K[j]
    mv a3, s4                                      # a3 = vector length
    jal dot                                        # compute dot(Q[target], K[j])
    slli t0, s6, 2                                 # t0 = byte offset of scores[j]
    add t1, s0, t0                                 # t1 = address of scores[j]
    sw a1, 0(t1)                                   # store the dot product result in scores[j]
    addi s6, s6, 1                                 # j++
    j compute_scores_loop                          # compute the next score
compute_scores_done:                                # label for compute scores done
    lw ra, 0(sp)                                   # restore the return address
    lw s0, 4(sp)                                   # restore s0
    lw s1, 8(sp)                                   # restore s1
    lw s2, 12(sp)                                  # restore s2
    lw s3, 16(sp)                                  # restore s3
    lw s4, 20(sp)                                  # restore s4
    lw s5, 24(sp)                                  # restore s5
    lw s6, 28(sp)                                  # restore s6
    lw s7, 32(sp)                                  # restore s7
    addi sp, sp, 36                                # free stack space
    ret                                            # return to the caller

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:                            # label for select vector in matrix
    mul t0, a4, a3                                 # t0 = target row * number of columns
    slli t0, t0, 2                                 # t0 = byte offset of the selected row
    add a0, a1, t0                                 # a0 = address of the selected row
    ret                                            # return to the caller

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:                                  # label for decide next token
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

decide_loop:                                        # label for decide loop
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

decide_update_best:                                 # label for decide update best
    mv s4, a1                                      # s4 = new best score
    mv s5, s3                                      # s5 = new best token index
    li s6, 0                                       # clear first-iteration flag

decide_next:                                        # label for decide next
    addi s3, s3, 1                                 # move to the next vocabulary token
    j decide_loop                                  # continue checking vocabulary embeddings

decide_done:                                        # label for decide done
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
advance_to_next_token:                              # label for advance to next token
advance_to_next_token_loop:                         # label for advance to next token loop
    lb t0, 0(a0)                                   # t0 = current character
    beqz t0, advance_to_next_token_done            # EOF/null: no next token
    li t1, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_found         # branch if the two registers are equal
    li t1, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_found         # branch if the two registers are equal
    li t1, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_found         # branch if the two registers are equal
    li t1, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_found         # branch if the two registers are equal
    addi a0, a0, 1                                  # add an immediate constant to a register
    j advance_to_next_token_loop                    # jump unconditionally to the target label

advance_to_next_token_found:                        # label for advance to next token found
    addi a0, a0, 1                                 # move past the separator

advance_to_next_token_skip_separators:              # label for advance to next token skip separators
    lb t0, 0(a0)                                    # load one byte from memory
    beqz t0, advance_to_next_token_done             # branch if the register is zero
    li t1, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_skip_one      # branch if the two registers are equal
    li t1, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_skip_one      # branch if the two registers are equal
    li t1, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_skip_one      # branch if the two registers are equal
    li t1, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq t0, t1, advance_to_next_token_skip_one      # branch if the two registers are equal
    j advance_to_next_token_done                    # jump unconditionally to the target label

advance_to_next_token_skip_one:                     # label for advance to next token skip one
    addi a0, a0, 1                                  # add an immediate constant to a register
    j advance_to_next_token_skip_separators         # jump unconditionally to the target label

advance_to_next_token_done:                         # label for advance to next token done
    ret                                            # return to the caller

#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:                                                # label for dot
    addi sp, sp, -4                                 # add an immediate constant to a register
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:                                           # label for dot loop
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
    j dot_continue_loop                             # jump unconditionally to the target label
check_positive_overflow:                            # label for check positive overflow
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop                             # jump unconditionally to the target label
check_negative_overflow:                            # label for check negative overflow
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bge t0, zero, overflow                          # If t0 >= 0 after adding a negative number, we have an overflow
    j dot_continue_loop                             # jump unconditionally to the target label
dot_continue_loop:                                  # label for dot continue loop
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:                                       # label for dot end loop
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:                                           # label for overflow
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:                                            # label for dot end
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:                                             # label for argmax
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4                                 # add an immediate constant to a register
    sw ra, 0(sp)                                    # Save return address on the stack
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_init                       # if SIZE >= 1, initialize normally
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_init:                                        # label for argmax init
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    j argmax_loop                                   # jump unconditionally to the target label
argmax_loop:                                        # label for argmax loop
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:                                        # label for argmax next
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:                                    # label for argmax end loop
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:                                         # label for argmax end
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:                                     # label for exit with code
    li a7, CONST_SYSCALL_EXIT2                      # load an immediate constant into the destination register
    ecall                                           # execute the requested Ripes/system call

#############################################################################################################
# Helper function for final output.
#############################################################################################################

# (in) a0: index of the predicted token in the vocabulary (int)
# (in) a1: address of vocabulary buffer (char*)
print_predicted_token:                              # label for print predicted token
    addi sp, sp, -12                                # add an immediate constant to a register
    sw ra, 0(sp)                                    # store one 32-bit word into memory
    sw s0, 4(sp)                                    # store one 32-bit word into memory
    sw s1, 8(sp)                                    # store one 32-bit word into memory
    mv s0, a0                                       # s0 = countdown to target index
    mv s1, a1                                       # s1 = current position in vocab buffer
print_predicted_token_skip:                         # label for print predicted token skip
    beq s0, zero, print_predicted_token_read        # branch if the two registers are equal
    mv a0, s1                                       # a0 = current position in vocab buffer
    jal advance_to_next_token                       # a0 = next token start
    mv s1, a0                                       # update current position
    addi s0, s0, -1                                 # add an immediate constant to a register
    j print_predicted_token_skip                    # jump unconditionally to the target label
print_predicted_token_read:                         # label for print predicted token read
    # s1 = start of target token, print it char by char until newline or null
print_predicted_token_char:                         # label for print predicted token char
    lb t0, 0(s1)                                    # load one byte from memory
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_SPACE                         # load an immediate constant into the destination register
    beq t0, t1, print_predicted_token_nl            # space terminator
    li t1, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    beq t0, t1, print_predicted_token_nl            # newline terminator
    li t1, CONST_CHAR_TAB                           # load an immediate constant into the destination register
    beq t0, t1, print_predicted_token_nl            # tab terminator
    li t1, CONST_CHAR_CR                            # load an immediate constant into the destination register
    beq t0, t1, print_predicted_token_nl            # carriage-return terminator
    mv a0, t0                                       # copy the value of one register into another register
    li a7, CONST_SYSCALL_PRINT_CHAR                 # load an immediate constant into the destination register
    ecall                                           # execute the requested Ripes/system call
    addi s1, s1, 1                                  # add an immediate constant to a register
    j print_predicted_token_char                    # jump unconditionally to the target label
print_predicted_token_nl:                           # label for print predicted token nl
    li a0, CONST_CHAR_NEWLINE                       # load an immediate constant into the destination register
    li a7, CONST_SYSCALL_PRINT_CHAR                 # load an immediate constant into the destination register
    ecall                                           # execute the requested Ripes/system call
    lw ra, 0(sp)                                    # load one 32-bit word from memory
    lw s0, 4(sp)                                    # load one 32-bit word from memory
    lw s1, 8(sp)                                    # load one 32-bit word from memory
    addi sp, sp, 12                                 # add an immediate constant to a register
    ret                                             # return to the caller
