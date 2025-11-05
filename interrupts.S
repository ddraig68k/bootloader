
    .globl isr_bus_error
    .globl isr_address_error
    .globl isr_illegal_instruction
    .globl isr_generic

    .section .text

isr_bus_error:
    movem.l d0/a0,-(sp)
    lea.l   bus_error_str,a0
    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_address_error:
    movem.l d0/a0,-(sp)
    lea.l   addr_error_str,a0
    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_illegal_instruction:
    movem.l d0/a0,-(sp)
    lea.l   inst_error_str,a0
    jsr     print_string
    movem.l (sp)+,d0/a0
    rte

isr_generic:
    rte

    .section .rodata
bus_error_str:
    .asciz  "\n\rBus exception error\n\r"
addr_error_str:
    .asciz  "\n\rAddress exception error\n\r"
inst_error_str:
    .asciz  "\n\rIllegal instruction error\n\r"
