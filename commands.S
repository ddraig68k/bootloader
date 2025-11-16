command_notimplemented:
    movem.l a2-a3/d0,-(sp)
    lea.l s_cmd_notimplement,a0
    bsr prints
    movem.l (sp)+,a2-a3/d0
    rts

command_unknown:
    movem.l a2-a3/d0,-(sp)
    lea.l s_cmd_unknown,a0
    bsr prints
    lea.l parser_cmd,A2
    move.l (a2),a3
    bsr prints
    bsr print_newline
    lea.l s_cmd_unknown_help,a0
    bsr prints
    bsr print_newline
    movem.l (sp)+,a2-a3/d0
    rts

    .section .rodata

