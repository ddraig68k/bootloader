    .globl  command_about
    .globl  command_help
    .globl  command_peek
    .globl  command_peekw
    .globl  command_peekl
    .globl  command_poke
    .globl  command_pokew
    .globl  command_pokel
    .globl  command_notimplemented
    .globl  command_unknown


    .section .text

command_about:
    move.l a0,-(sp)
    lea.l s_aboutmsg,a0
    bsr prints
    move.l (sp)+,a0
    rts

command_help:
    move.l a0,-(sp)
    lea.l s_commandlist,a0
    bsr prints
    move.l (sp)+,A0
    rts

command_peek:
    movem.l a0-a2/d0,-(sp)
    lea.l s_print_peek,a0
    bsr prints
    lea parser_args,a2
    move.l (a2)+,a0
    bsr string_to_hex
    move.l d0,a1                    | Address to look at
    move.b (a1),d0                  | Get the data
    jsr print_2hex                  | Print the data
    jsr print_newline
    movem.l (sp)+,a0-a2/d0
    rts

command_peekw:
    movem.l a0-a2/d0,-(sp)
    lea.l s_print_peekw,a0
    bsr prints
    lea parser_args,a2
    move.l (a1)+,a0
    jsr string_to_hex
    move.l d0,a1                    | Address to look at
    move.w (a1),d0                  | Get the data
    jsr print_4hex                  | Print the data
    jsr print_newline
    movem.l (sp)+,a0-a2/d0
    rts

command_peekl:
    movem.l a0-a2/d0,-(sp)
    lea.l s_print_peekl,a0
    bsr prints
    lea parser_args,a2
    move.l (a2)+,a0
    jsr string_to_hex
    move.l D0,a1                    | Address to look at
    move.l (a1),d0                  | Get the data
    jsr print_8hex                  | Print the data
    jsr print_newline
    movem.l (sp)+,a0-a2/d0
    rts

command_poke:
    movem.l a0-a2/d0-d1,-(sp)
    lea.l s_print_poke,a0
    bsr prints
    lea parser_args,a2
    move.l (a2)+,a0
    jsr string_to_hex
    move.l d0,a1                    | Address to look at
    move.l parser_argc,d1           | Get the argument count
    subq.l #1,d1                    | Skip the address
.poke_data:
    cmp.l #0,d1                     | End or arguments
    beq .poke_done                  | No more parameters

    move.l (a2)+,d0                 | Get the data pointer
    jsr string_to_hex               | Convert from string
    move.b d0,(a1)+                 | Store the data
    subq.l #1,d1
    bne .poke_data
.poke_done:
    movem.l (sp)+,a0-a2/d0-d1
    rts

command_pokew:
    movem.l a0-a2/d0,-(sp)
    lea.l s_print_pokew,a0
    bsr prints
    movem.l (sp)+,a0-a2/d0
    rts

command_pokel:
    movem.l a0-a2/d0,-(sp)
    lea.l s_print_pokel,a0
    bsr prints
    movem.l (sp)+,a0-a2/d0
    rts

command_notimplemented:
    movem.l a2-a3/d0,-(sp)
    lea.l s_cmd_notimplemnt,a0
    bsr prints
    movem.l (sp)+,a2-a3/d0
    rts

command_unknown:
    movem.l a2-a3/d0,-(sp)
    lea.l s_cmd_unknown,a0
    bsr prints
    lea.l parser_cmd,A2
    move.l (a2),a0
    bsr prints
    bsr print_newline
    lea.l s_cmd_unknown_help,a0
    bsr prints
    bsr print_newline
    movem.l (sp)+,a2-a3/d0
    rts

    .section .rodata
    .align 2
s_print_peek:       .asciz "Function PEEK called\n\r"
s_print_peekw:      .asciz "Function PEEKW called\n\r"
s_print_peekl:      .asciz "Function PEEKL called\n\r"
s_print_poke:       .asciz "Function POKE called\n\r"
s_print_pokew:      .asciz "Function POKEW called\n\r"
s_print_pokel:      .asciz "Function POKEW called\n\r"

s_cmd_unknown:      .asciz "Unknown command: "
s_cmd_unknown_help: .asciz "\n\rUse HELP to get a list of commands\n\r"
s_cmd_notimplemnt:  .asciz "Command not implemnted\n\r"

s_aboutmsg:         .asciz "Y Dddraig bootloader/monitor.\n\r"

/*
 * List of available commands
 */
s_commandlist:
    .ascii "about      - About DragonMon\n\r"
    .ascii "help       - Display list of commands\n\r"
    .ascii "dump       - <addr> Dump block of memory at address\n\r"
    .ascii "peek       - <addr> Read a byte of data\n\r"
    .ascii "peekw      - <addr> Read a word of data\n\r"
    .ascii "peekl      - <addr> Read a long word of data\n\r"
    .ascii "poke       - <addr> <data> ... Write byte(s) of data\n\r"
    .ascii "pokew      - <addr> <data> ... Write word(s of data\n\r"
    .ascii "pokel      - <addr> <data> ... Write long word(s) of data\n\r"
    dc.b 0


