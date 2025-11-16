
    .globl  init_parser
    .globl  execute_parser


    .section .text







      ; align_mem 2


S_CMD_UNKNOWN      dc.b 'Unknown command ',0
S_CMD_UNKNOWN_HELP dc.b 'Use HELP to get a list of commands',CR,LF,0
S_CMD_NOTIMPLEMENT dc.b 'Command not implemnted',CR,LF,0

s_cmd_need_min    dc.b 'Command requires at least ',0
s_cmd_need_args   dc.b ' arguments',CR,LF,0




      ORG   (*+1)&-2





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
