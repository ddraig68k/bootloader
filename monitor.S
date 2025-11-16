#include "duart.h"

    .globl start_monitor

    .equ    PARSE_MAX_ARGS, 32          | Maximun number of arguments
    .equ    MAX_INPUT_BUF, 512          | Maximum character for input buffer

    .section .text
/*
 * start_monitor is the entry and main processing loop for the
 * monitor code
 */
start_monitor:
    bsr init_vectors                    | Set up default vector table

    lea s_moninit,a0
    bsr prints                          | Display monitor start string
    bsr init_parser                     | Initialise the command parser

.main_loop:
    bsr read_input                      | Get the command from serial
    bsr execute_parser                  | Execute the command

    bra .main_loop

/*
 * init_parse clears the command processing variables
 * ready for the main command excecution process
 */
init_parser:
    movem.l a0-a1/d0-d1,-(sp)           | Push used registers

    move.b #1,echo_serial               | Enable echo charater to serial
    lea parser_vars_start,a0            | Parser command parameters
    lea  parser_vars_end,a1
    move.l a1,d0

.clear_word:
    clr.w d1                            | Clear parameter data
    cmp.l a0,d0
    bge .init_done
    move.w d1,(a0)+
    bra  .clear_word
.init_done:
    movem.l (sp)+,a0-a1/d0-d1           | Restore registers and return
    rts

/*
 * read_input reads the input from the serial terminal and processes
 * some basic handling for character like delete.
 * When a CR is received or the buffer is full, then the fucntion will return
 */
read_input:
    movem.l a0-a1/d0-d1,-(sp)
    lea.l parser_buffer,a1
    clr.l d1                            | Character count
    move.l a1,a0
    move.l #MAX_INPUT_BUF,d0            | Max size of input buffer
.rb_clear:
    move.b d1,(a0)+			            | Clear the command buffer
    dbra d0,.rb_clear

.rb_getchar:
    bsr char_in                         | Read the next character

    cmp.b #LF,d0
    beq .rb_getchar                     | Ignore linefeed
    cmp.b #CR,d0
    beq .rb_got_buf                     | Got a CR so data received
    cmp.b #BS,d0
    beq .rb_handle_del                  | Process a delete character
    cmp.b #$20,d0                       | Check the character is in valid ascii range
    blt .rb_getchar
    cmp.b #$7E,d0
    bgt .rb_getchar

    move.b d0,(a1)+                     | Store the character in the buffer
    addq #1,d1                          | Increment character count
    tst.b serial_echo                   | Should be echo the character back to the terminal?
    beq .rb_noecho
    bsr char_out                        | Write the character
.rb_noecho:
    cmp.w #MAX_INPUT_BUF,d1             | Reached buffer limit?
    bne .rb_getchar                     | Get next character
    subq.l #1,d1                        | Decrement counter, buffer null terminated
    bra .rb_got_buf                     | Finish receiving

.rb_handle_del
    bsr char_out                        | Write the backspace
    tst.b serial_echo                   | Echo back to terminal?
    beq .rb_nodelecho
    move.b #' ',d0                      | Clear the existing character by overwriting with a space
    bsr char_out
    move.b #BS,d0
    bsr char_out                        | Resent the backspace
.rb_nodelecho:
    subq #1,a1			                | decrement the pointer and count
    subq #1,d1
    bra .rb_getchar                     | Get next character
.rb_got_buf
    move.b #0,(a1)                      | Null terminate the buffer
    move.l d1,parser_cmdlen             | Store the command length
    bsr print_newline
    movem.l (sp)+,a0-a1/d0-d1
    rts


/*
 * execute parser percesses the input line and scans for any command and paramters
 * If a valid command is found, it will execute the command
 */
execute_parser:
    movem.l a2-a3/d0-d3,-(sp)

    lea parser_buf,a3                   | Write the command string
    jsr parse_input_buf                 | Parser the command line data

    jsr lookup_command                  | Decode the command

    lea parser_cmdfunc,a3               | Load the command function pointer
    move.l (a3),a2
    move.l a2,d0
    beq .exit_parser                    | Empty, no command

    move.l parser_minargs,d0            | Check the minimum number of arguments
    beq .run_command                    | No min parameters? Run command

    move.l parser_argc,d1               | Get the required number of arguments
    beq .needs_min
    cmp.l d0,d1
    TODO: Check if minimum number of commands rec
    bra .run_command

.needs_min:
    lea s_cmd_need_min,a0               | Print message for minimum arguments
    bsr prints
    move.l parser_minargs,d0            | Get the minimum value
    bsr print_decimal
    lea s_cmd_need_args,a0
    bsr prints
    bra .exit_parser

.run_command
    jsr (a2)                            | Execute the command

.exit_parser
    movem.l (sp)+,a2-a3/d0-d3
    rts

/*
 * Move to the end of current data indicated by whitespace or end
 * Assume the following registers are used
 * A2 - Current buffer pointer
 * D2 - Curent buffer position
 */
parse_rb_find_end:
    move.b (a2)+,d0                     | Get the next character
    addq #1,d2                          | Increment buffer pointer
    cmp.w #MAX_INPUT_BUF,d2             | End of buffer
    beq .prb_end_found
    cmp.b #0,d0                         | Null terminator?
    beq .prb_end_found
    cmp.b #' ',d0                       | Space
    beq .prb_end_found
    bra parse_rb_find_end               | Check next charater in buffer

.prb_end_found
    subq #1,a2                          | Pointer to end character
    rts


/*
 * Data and constants
 */
    .section .bss
    .align 2
parser_buffer:
    dc.b    MAX_INPUT_BUF
    .align 2
serial_echo:
    dc.b    1

    .section .rodata
s_moninit:          .asciz "\n\rDragonMon V0.1 for Y Ddraig\n\r"
s_cmd_need_min:     .asciz "Command requires at least "
s_cmd_need_args:    .asciz " arguments\n\r"
s_cmd_unknown:      .asciz "Unknown command "
s_cmd_unknown_help  .asciz "Use HELP to get a list of commands\n\r"
s_cmd_notimplemnt   .asciz "Command not implemnted\n\r"


