#include "duart.h"

    .globl start_monitor

    .equ    PARSE_MAX_ARGS, 32          | Maximun number of arguments
    .equ    MAX_INPUT_BUF, 512          | Maximum character for input buffer

    .section .text
start_monitor:

    | Initialise the default interrupt vectors
    lea moninit_str,a0
    bsr prints                          | Display monitor start string

    bsr init_parser

.main_loop:
    bsr read_input                      | Get the command from serial
    bsr execute_parser                  | Execute the command

    bra .main_loop

init_parser:
    movem.l a0-a1/d0-d1,-(sp)           | Push used registers
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

read_input:
      movem.l a0-a1/d0-d1,-(sp)
      lea.l parser_buf,a1
      clr.l d1                          | Character count
      move.l a1,a0
      move.l #MAX_INPUT_BUF,d0          | Max size of input buffer
.ri_clear:
      move.b d1,(a0)+			        | Clear the command buffer
      dbra d0,.ri_clear

.ri_getchar:
      bsr char_in

      cmp.b #LF,d0
      beq .ri_getchar                   | Ignore linefeed
      cmp.b #CR,d0
      beq .ib_got_buf                   | Got a CR so data received
      cmp.b #BS,d0
      beq .ib_handle_del                | Process a delete character
      cmp.b #$20,d0                     | Check the character is in valid ascii range
      blt .ri_getchar
      cmp.b #$7E,d0
      bgt .ri_getchar

      move.b D0,(A1)+                     ; Store the character in the buffer
      addq #1,D1                          ; Increment character count
      cmp.w #1023,D1                      ; At buffer limit?
      beq .ib_got_buf                     ; Finish receiving
      bra .ri_getchar                     ; Get next character

.ib_handle_del
      bsr char_out                        ; Write the backspace
;      move.b #' ',D0
;      bsr char_out                        ; Clear the eisting character
;      move.b #BS,D0
;      bsr char_out                        ; Write the backspace again
      subq #1,A1			            ; decrement the pointer and count
      subq #1,D1
      bra .ri_getchar                     ; Get next character
.ib_got_buf
      move.b #0,(A1)                      ; Null terminate the buffer
      move.l D1,parser_cmdlen             ; Store the command length
      bsr print_newline
      movem.l (SP)+,A0-A1/D0-D1
      rts

execute_parser:
    movem.l a2-a3/d0-d1,-(sp)

    lea parser_buf,A3                   | Write the command string
    jsr parse_input_buf                 | Parser the command line data

    jsr lookup_command                  | Decode the command

    lea parser_cmdfunc,A3               | Load the command function pointer
    move.l (A3),A2
    move.l A2,D0
    beq .exit_parser                    | Empty, no command

    move.l parser_minargs,D0            | Check the minimum number of arguments
    beq .run_command                    | No min parameters? Run command

    move.l parser_argc,D1               | Get the required number of arguments
    beq .needs_min
    cmp.l D0,D1
    bra .run_command

.needs_min:
    lea s_cmd_need_min,A3
    bsr prints
    move.l parser_minargs,D0
    bsr print_2hex
    lea s_cmd_need_args,A3
    bsr prints
    bra .exit_parser

.run_command
    jsr (A2)                            | Execute the command

.exit_parser
    movem.l (SP)+,A2-A3/D0-D1
    rts


    .section .bss

    .section .rodata
moninit_str:
    .asciz  "\n\rDragonMon V0.1 for Y Ddraig\n\r"
