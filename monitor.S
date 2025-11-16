    .include "duart.inc"
    .include "constants.inc"

    .globl start_monitor

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
    lea s_prompt,a0                     | Display prompt
    bsr prints
    bsr read_input                      | Get the command from serial
    bsr execute_parser                  | Execute the command

    bra .main_loop

/*
 * init_parse clears the command processing variables
 * ready for the main command excecution process
 */
init_parser:
    movem.l a0-a1/d0-d1,-(sp)           | Push used registers

    move.b #1,serial_echo               | Enable echo charater to serial
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
    cmp.b #BACKSP,d0
    beq .rb_handle_del                  | Process a delete character
    cmp.b #0x20,d0                      | Check the character is in valid ascii range
    blt .rb_getchar
    cmp.b #0x7E,d0
    bgt .rb_getchar

    move.b d0,(a1)+                     | Store the character in the buffer
    addq #1,d1                          | Increment character count
    |tst.b serial_echo                   | Should be echo the character back to the terminal?
    |beq .rb_noecho
    bsr char_out                        | Write the character
.rb_noecho:
    cmp.w #MAX_INPUT_BUF,d1             | Reached buffer limit?
    bne .rb_getchar                     | Get next character
    subq.l #1,d1                        | Decrement counter, buffer null terminated
    bra .rb_got_buf                     | Finish receiving

.rb_handle_del:
    bsr char_out                        | Write the backspace
    |tst.b serial_echo                   | Echo back to terminal?
    |beq .rb_nodelecho
    move.b #' ',d0                      | Clear the existing character by overwriting with a space
    bsr char_out
    move.b #BACKSP,d0
    bsr char_out                        | Resent the backspace
.rb_nodelecho:
    subq #1,a1			                | decrement the pointer and count
    subq #1,d1
    bra .rb_getchar                     | Get next character
.rb_got_buf:
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

    lea parser_buffer,a3                | Write the command string
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
    |TODO: Check if minimum number of commands rec
    bra .run_command

.needs_min:
    lea s_cmd_need_min,a0               | Print message for minimum arguments
    bsr prints
    move.l parser_minargs,d0            | Get the minimum value
    bsr print_decimal
    lea s_cmd_need_args,a0
    bsr prints
    bra .exit_parser

.run_command:
    jsr (a2)                            | Execute the command

.exit_parser:
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

.prb_end_found:
    subq #1,a2                          | Pointer to end character
    rts

/*
 * Parse the input buffer data and create pointers to the command
 * and any parameters. If there's no command the pointer will be 0.
 * If any parameters pointers will be stored and a parameter count saved
 */
parse_input_buf:
    movem.l a0-a3/d0-d3,-(sp)
    lea parser_buffer,a2
    clr.l d2                            | Character count
    move.l #0,parser_argc               | Zero arg count
    move.l #0,parser_cmd                | Zero command pointer

.pi_skipwspace:
    move.b (a2)+,d0
    addq #1,d2
    cmp.w #MAX_INPUT_BUF,d2             | End of buffer
    beq .pi_nodata
    cmp.b #0,d0                         | Null terminator?
    beq .pi_nodata
    cmp.b #' ',d0
    beq .pi_skipwspace                  | Get the next character

    | Have data so save pointer to that data
    move.l a2,d0
    subq #1,d0                          | Point to start of data
    move.l d0,parser_cmd                | Save pointer to command

    jsr parse_rb_find_end		        | Move to end of command
    move.b #0,(a2)+                     | Null terminate the command

    clr.l d3                            | Paramater count
    lea parser_args,a3                  | Paramater pointers
.pi_get_params:
    move.b (a2)+,d0                     | Get the current character
    cmp.b #' ',d0
    beq .pi_get_params                  | Skip space

    addq #1,d2
    cmp.w #MAX_INPUT_BUF,d2             | End of buffer
    beq .pi_params_done                 | No more params
    cmp.b #0,d0                         | Null terminator?
    beq .pi_params_done

    move.l A2,d0                        | Save parameter start pointer
    subq #1,d0
    move.l d0,(a3)+
    bsr parse_rb_find_end               | Skip to end of data
    move.b #0,(a2)+                     | Null terminate parameter
    addq #1,d3                          | Increment param count
    cmp #PARSE_MAX_ARGS,d3              | Have we reached the maximum arguments?
    beq .pi_params_done                 | Finish if reached max parameters
    bra .pi_get_params                  | Get next parameter

.pi_params_done:
    move.l d3,parser_argc               | Save argument count
    bra .print_stats
    rts

.pi_nodata:
    lea parser_argc,a3                  | Arg counter
    move.l #0,(a3)+                     | Zero arg count
    move.l #0,(a3)                      | Zero command pointer

.print_stats:
    lea parser_cmd,a2                   | Command pointer
    move.l (a2),d0
    bne .ps_cmd                         | Check that there's acutally a command
    lea s_parse_nocmd,a0                | No command message
    bsr prints
    bsr print_newline
    bra .pi_exit

.ps_cmd:
    lea s_parse_cmd,a0
    bsr prints                          | Print command prompt
    move.l (a2),a0
    bsr prints                          | Print the command
    bsr print_newline

    lea s_parse_parcnt,a0
    bsr prints                          | Print parameter count prompt
    move.l parser_argc,d0
    bsr print_decimal                   | Print parameter count
    bsr print_newline

    cmp.b #0,d0
    beq .pi_exit                        | No parameters

    move.l d0,d1
    lea parser_args,a2                  | Argument pointers
    subq #1,d1

.print_param:
    lea s_parse_param,a0
    bsr prints                          | Print paramters prompt
    move.l (a2)+,a0                     | Get pointer to next parameter
    bsr prints                          | Print parameter string
    bsr print_newline
    dbra d1,.print_param

.pi_exit:
    movem.l (sp)+, a0-a3/d0-d3
    rts

/*
 * Look up command in the command table
 * returns the command code in D0
 */
lookup_command:
    movem.l a0-a3/d1,-(sp)

    move.l #0,parser_cmdfunc            | Clear the command function pointer
    lea parser_cmd,a2
    move.l (a2),d0                      | Commmand pointer empty, no command
    beq  .lc_exit

    lea command_table,a3                | Address of the command table
.lc_test_cmd:
    move.l (a2),a0        		        | Pointer to passed command
    move.l (a3)+,a1                     | Pointer to command name
    move.l a1,d1                        | Check if end of list
    beq .lc_unknown

.lc_check_cmd:
    move.b (a0)+,d0                     | Get passed char
    cmp.b #0x40,d0
    blt.s .ic_nochange
    and.b #0xDF,d0                      | Make uppercase
.ic_nochange:
    move.b (a1)+,d1                     | Get command char
    cmp.b d0,d1
    bne .lc_no_match                    | Not same so check next

    cmp.b #0,d0                         | Check for end of passed command
    beq .lc_check_cmd_end
    cmp.b #0,d1                         | Passed not ended, check cmd
    beq .lc_no_match
    bra .lc_check_cmd                   | Check next data

.lc_check_cmd_end:
    cmp.b #0,d1                         | passed has ended, check command
    beq .lc_command_found               | matched so process
    bra .lc_check_cmd

.lc_command_found:
    move.l (a3)+,d0                     | Load the command function pointer
    move.l d0,parser_cmdfunc            | Save the function pointer
    move.l (a3)+,d0
    move.l d0,parser_minargs            | Save the minimum number of arguments
    bra .lc_exit

.lc_no_match:
    add.l #8,a3                         | Skip function address, min and max
    bra .lc_test_cmd

.lc_unknown:
    lea.l command_unknown,A3
    move.l A3,parser_cmdfunc            | Set the unknown command function pointer
    bra .lc_exit

.lc_exit:
    movem.l (sp)+,a0-a3/d1
    rts

/*
 * Execute the specified command
 */
command_execute:
    movem.l a2-a3/d0,-(sp)
    lea.l s_exec_cmd,a0
    bsr prints
    lea.l parser_cmd,a2
    move.l (a2),a3
    bsr prints
    bsr print_newline
    movem.l (sp)+,a2-a3/d0
    rts


init_vectors:
    rts

/*
 * Data and constants
 */
    .section .bss
    .align 2
parser_vars_start:
parser_cmdlen:      ds.l 1                  | Length of the entered command
parser_argc:        ds.l 1                  | Nomber of arguments in the command
parser_cmd:         ds.l 1                  | Pointer to the command str
parser_cmdfunc:     ds.l 1                  | Pointer to the command function
parser_minargs:     ds.l 1                  | Minimum number of arguments for command
parser_args:        ds.l PARSE_MAX_ARGS     | Pointers to arguments
parser_buffer:      ds.b MAX_INPUT_BUF      | Space for command line buffer
parser_vars_end:

    .globl parser_cmd
    .globl parser_argc
    .globl parser_args


    .align 2
serial_echo:
    ds.b    1

    .section .rodata
s_moninit:          .asciz "\n\rDragonMon V0.1 for Y Ddraig\n\r"
s_cmd_need_min:     .asciz "Command requires at least "
s_cmd_need_args:    .asciz " arguments\n\r"
s_prompt:           .asciz ">"

s_parse_cmd:        .asciz "Command = "
s_parse_nocmd:      .asciz "No command entered."
s_parse_parcnt:     .asciz "Paramater Count = "
s_parse_param:      .asciz "Parameter = "

s_exec_cmd:         .asciz "Execute command: "


| Monitor command strings
s_cmd_help:         .asciz "HELP"
s_cmd_about:        .asciz "ABOUT"
s_cmd_dump:         .asciz "DUMP"
s_cmd_peek:         .asciz "PEEK"
s_cmd_peekw:        .asciz "PEEKW"
s_cmd_peekl:        .asciz "PEEKL"
s_cmd_poke:         .asciz "POKE"
s_cmd_pokew:        .asciz "POKEW"
s_cmd_pokel:        .asciz "POKEL"

/*
 * Monitor command lookup table
 */
    .align 2
command_table:
    | Command table format
    | Command string, function to execute, min_args
    dc.l s_cmd_about, command_about, 0
    dc.l s_cmd_help,  command_help, 0
    dc.l s_cmd_dump,  command_notimplemented, 1
    dc.l s_cmd_peek,  command_peek, 1
    dc.l s_cmd_peekw, command_peekw, 1
    dc.l s_cmd_peekl, command_peekl, 1
    dc.l s_cmd_poke,  command_poke, 2
    dc.l s_cmd_pokew, command_pokew, 2
    dc.l s_cmd_pokel, command_pokel, 2
    | End of command table
    dc.l 0,0,0

