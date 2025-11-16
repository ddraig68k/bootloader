
    .globl isr_bus_error
    .globl isr_address_error
    .globl isr_illegal_instruction
    .globl isr_generic

    .section .text

isr_bus_error:
    movem.l d0/a0,-(sp)
|    lea.l   bus_error_str,a0
|    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_address_error:
    movem.l d0/a0,-(sp)
|    lea.l   addr_error_str,a0
|    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_illegal_instruction:
    movem.l d0/a0,-(sp)
|    lea.l   inst_error_str,a0
|    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_generic:
    rte

    .section .rodata
s_bus_error:        .asciz  "\n\rBus exception error\n\r"
s_addr_error:       .asciz  "\n\rAddress exception error\n\r"
s_inst_error:       .asciz  "\n\rIllegal instruction error\n\r"
