
    .globl  init_parser
    .globl  execute_parser


    .section .text




; Parse the input buffer data and create pointers to the command
; and any parameters. If there's no command the pointer will be 0.
; If any parameters pointers will be stored and a parameter count saved
parse_input_buf:
      movem.l A0-A3/D0-D3,-(SP)
      lea parser_buf,A2
      clr.l D2                            ; character count
      move.l #0,parser_argc               ; Zero arg count
      move.l #0,parser_cmd                ; Zero command pointer

.pi_skipwspace
      move.b (A2)+,D0
      addq #1,D2
      cmp.w #1024,D2                      ; End of buffer
      beq .pi_nodata
      cmp.b #0,D0                         ; Null terminator?
      beq .pi_nodata
      cmp.b #' ',D0
      beq .pi_skipwspace                  ; get the next character

      ; Have data so save pointer to that data
      move.l A2,D0
      subq #1,D0                          ; Point to start of data
      move.l D0,parser_cmd                ; Save pointer to command

      jsr parse_ib_find_end		      ; Move to end of command
      move.b #0,(A2)+                     ; Null terminate the command

      clr.l D3                            ; Paramater count
      lea parser_args,A3                  ; Paramater pointers
.pi_get_params
      move.b (A2)+,D0                     ; Get the current character
      cmp.b #' ',D0
      beq .pi_get_params                  ; Skip space

      addq #1,D2
      cmp.w #1024,D2                      ; End of buffer
      beq .pi_params_done                 ; No more params
      cmp.b #0,D0                         ; Null terminator?
      beq .pi_params_done

      move.l A2,D0                        ; Save parameter start pointer
      subq #1,D0
      move.l D0,(A3)+
      bsr parse_ib_find_end               ; Skip to end of data
      move.b #0,(A2)+                     ; Null terminate parameter
      addq #1,D3                          ; Increment param count
      cmp #PARSE_MAX_ARGS,D3              ; Have we reached the maximum arguments?
      beq .pi_params_done                 ; Finish if reached max parameters
      bra .pi_get_params                  ; Get next parameter

.pi_params_done
      move.l D3,parser_argc               ; Save argument count
      bra .print_stats
      rts

.pi_nodata
      lea parser_argc,A3                  ; Arg counter
      move.l #0,(A3)+                     ; Zero arg count
      move.l #0,(A3)                      ; Zero command pointer

.print_stats
      lea parser_cmd,A2                   ; Command pointer
      move.l (A2),D0
      bne .ps_cmd                         ; Check that there's acutally a command
      lea S_PARSE_NOCMD,A3                ; No command message
      bsr prints
      bsr print_newline
      bra .pi_exit

.ps_cmd
      lea S_PARSE_CMD,A3
      bsr prints                    ; Print command prompt
      move.l (A2),A3
      bsr prints                    ; Print the command
      bsr print_newline

      lea S_PARSE_PARCNT,A3
      bsr prints                    ; Print parameter count prompt
      move.l parser_argc,D0
      bsr print_2hex                      ; Print parameter count int hex
      bsr print_newline

      cmp.b #0,D0
      beq .pi_exit                        ; no parameters

      move.l D0,D1
      lea parser_args,A2                  ; Argument pointers
      subq #1,D1

.print_param
      lea S_PARSE_PARAM,A3
      bsr prints                    ; Print paramters prompt
      move.l (A2)+,A3                     ; Get pointer to next parameter
      bsr prints                    ; Print parameter string
      bsr print_newline
      dbra D1,.print_param

.pi_exit
      movem.l (SP)+, A0-A3/D0-D3
      rts


; look up command
; returns the command code in D0
lookup_command:
      movem.l A0-A3/D1,-(SP)

      move.l #0,parser_cmdfunc            ; Clear the command function pointer
      lea parser_cmd,A2
      move.l (A2),D0                      ; Commmand pointer empty, no command
      beq  .lc_exit

      lea command_table,A3                ; Address of the command table
.lc_test_cmd
      move.l (A2),A0        		      ; Pointer to passed command
      move.l (A3)+,A1                     ; Pointer to command name
      move.l A1,D1                        ; Check if end of list
      beq .lc_unknown

.lc_check_cmd
      move.b (A0)+,D0                     ; Get passed char
      cmp.b #$40,D0
      blt.S	.ic_nochange
      and.b #%11011111,D0                 ; Make uppercase
.ic_nochange
      move.b (A1)+,D1                     ; Get command char
      cmp.b D0,D1
      bne .lc_no_match                    ; Not same so check next

      cmp.b #0,D0                         ; Check for end of passed command
      beq .lc_check_cmd_end
      cmp.b #0,D1                         ; Passed not ended, check cmd
      beq .lc_no_match
      bra .lc_check_cmd                   ; Check next data

.lc_check_cmd_end
      cmp.b #0,D1                         ; passed has ended, check command
      beq .lc_command_found               ; matched so process
      bra .lc_check_cmd

.lc_command_found
      move.l (A3)+,D0                     ; Load the command function pointer
      move.l D0,parser_cmdfunc            ; Save the function pointer
      move.l (A3)+,D0
      move.l D0,parser_minargs            ; Save the minimum number of arguments
      bra .lc_exit

.lc_no_match
      add.l #8,A3                         ; Skip function address, min and max
      bra .lc_test_cmd

.lc_unknown
      lea.l command_unknown,A3
      move.l A3,parser_cmdfunc            ; Set the unknown command function pointer
      bra .lc_exit

.lc_exit
      movem.l (SP)+,A0-A3/D1
      rts

command_execute:
      movem.l A2-A3/D0,-(SP)
      lea.l S_EXEC_CMD,A3
      bsr prints
      lea.l parser_cmd,A2
      move.l (A2),A3
      bsr prints
      bsr print_newline
      movem.l (SP)+,A2-A3/D0
      rts

command_notimplemented:
      movem.l A2-A3/D0,-(SP)
      lea.l S_CMD_NOTIMPLEMENT,A3
      bsr prints
      movem.l (SP)+,A2-A3/D0
      rts

command_unknown:
      movem.l A2-A3/D0,-(SP)
      lea.l S_CMD_UNKNOWN,A3
      bsr prints
      lea.l parser_cmd,A2
      move.l (A2),A3
      bsr prints
      bsr print_newline
      lea.l S_CMD_UNKNOWN_HELP,A3
      bsr prints
      bsr print_newline
      movem.l (SP)+,A2-A3/D0
      rts

      ; align_mem 2

S_PARSE_CMD   dc.b 'Command = ',0
S_PARSE_NOCMD dc.b 'No command entered.',0
S_PARSE_PARCNT dc.b 'Paramater Count = ',0
S_PARSE_PARAM dc.b 'Parameter = ',0

S_EXEC_CMD   dc.b 'EXECUTE COMMAND: ',0

S_CMD_UNKNOWN      dc.b 'Unknown command ',0
S_CMD_UNKNOWN_HELP dc.b 'Use HELP to get a list of commands',CR,LF,0
S_CMD_NOTIMPLEMENT dc.b 'Command not implemnted',CR,LF,0

s_cmd_need_min    dc.b 'Command requires at least ',0
s_cmd_need_args   dc.b ' arguments',CR,LF,0


; Monitor command strings
s_cmd_help        dc.b 'HELP',0
s_cmd_about       dc.b 'ABOUT',0
s_cmd_dump        dc.b 'DUMP',0
s_cmd_peek        dc.b 'PEEK',0
s_cmd_peekw       dc.b 'PEEKW',0
s_cmd_peekl       dc.b 'PEEKL',0
s_cmd_poke        dc.b 'POKE',0
s_cmd_pokew       dc.b 'POKEW',0
s_cmd_pokel       dc.b 'POKEL',0


; Monitor command lookup table
; Stored as 3 long words <command string> <command descr> <command_code>
      ORG   (*+1)&-2

command_table
      ; Command table format
      ; Command string, function to execute, min_args, max_args
      dc.l s_cmd_about,command_about,0
      dc.l s_cmd_help,command_help,0
      dc.l s_cmd_dump,command_notimplemented,1
      dc.l s_cmd_peek,command_peek,1
      dc.l s_cmd_peekw,command_peekw,1
      dc.l s_cmd_peekl,command_peekl,1
      dc.l s_cmd_poke,command_poke,2
      dc.l s_cmd_pokew,command_pokew,2
      dc.l s_cmd_pokel,command_pokel,2
      ; End of command table
      dc.l 0,0,0,0




; list of commands
str_commandlist
      dc.b 'ABOUT      - About DragonMon',CR,LF
      dc.b 'HELP       - Display list of commands',CR,LF
      dc.b 'DUMP       - <addr> Dump block of memory at address',CR,LF
      dc.b 'PEEK       - <addr> Read a byte of data',CR,LF
      dc.b 'PEEKW      - <addr> Read a word of data',CR,LF
      dc.b 'PEEKL      - <addr> Read a long word of data',CR,LF
      dc.b 'POKE       - <addr> <data> ... Write byte(s) of data',CR,LF
      dc.b 'POKEW      - <addr> <data> ... Write word(s of data',CR,LF
      dc.b 'POKEL      - <addr> <data> ... Write long word(s) of data',CR,LF
      dc.b 0

NEWHELP_LIST
      dc.b 'Commands',13,10,10
      dc.b 13,10,13,10,'Note: all address and data values are in hex',13,10,0

      ORG   (*+1)&-2

parser_vars_start
parser_cmdlen     ds.l 1                  ; Length of the entered command
parser_argc       ds.l 1                  ; Nomber of arguments in the command
parser_cmd        ds.l 1                  ; Pointer to the command str
parser_cmdfunc    ds.l 1                  ; Pointer to the command function
parser_minargs    ds.l 1                  ; Minimum number of arguments for command
parser_args       ds.l PARSE_MAX_ARGS     ; Pointers to arguments
parser_buf        ds.b $400               ; 1K of space for command line buffer
parser_vars_end:
