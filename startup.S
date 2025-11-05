
    .globl __start

	.extern monitor_start

    .section .text
__start:

	move.w	#0x2700, sr 			    /* Disable interrupts */

    /* Set up initial vector table */
.copy_vectors:
    move.l  #vectors_end,a0             /* Start into A0 (source) */
    move.l  #0x400,a1                   /* 0x400 into A1 (destination) */

.isr_copy_loop:
    move.l  a1,d0                       /* Have we reached destination zero? */
    beq.s   .isr_copy_done

    move.l  -(a0),-(a1)                 /* Copy long source to dest, with predecrement */
    bra.s   .isr_copy_loop
.isr_copy_done:

	move.l	#__stack_end, a0

	cmp.l	#0, a0
	beq    1f
	move.l	a0, sp

1:
	/* Clear BSS */
 	lea.l   __e_bss, a0
 	move.l  a0, d2
 	lea.l   __s_bss, a1
 	sub.l   a1, a0
 	move.l  a0, d0
 	bra   3f
2:	clr.b   (a1)+
3:	sub.l 	#1, d0
	cmp.l 	#-1, d0
	bne   	2b

	jmp		monitor_start

   .section .rodata

vectors_start:
    dc.l    _stack_end
    dc.l    __start

    dc.l    isr_bus_error               | 02: Bus Error
    dc.l    isr_address_error           | 03: Address Error
    dc.l    isr_illegal_instruction     | 04: Illegal Instruction
    dc.l    isr_generic                 | 05: Divide by Zero
    dc.l    isr_generic                 | 06: CHK Instruction
    dc.l    isr_generic                 | 07: TRAPV Instruction
    dc.l    isr_generic                 | 08: Privilege Violation
    dc.l    isr_generic                 | 09: Trace
    dc.l    isr_generic                 | 0A: Line 1010 Emulator
    dc.l    isr_generic                 | 0B: Line 1111 Emulator
    dc.l    isr_generic                 | 0C: Reserved
    dc.l    isr_generic                 | 0D: Reserved
    dc.l    isr_generic                 | 0E: Format error (MC68010 Only)
    dc.l    isr_generic                 | 0F: Uninitialized Vector

    dc.l    isr_generic                 | 10: Reserved
    dc.l    isr_generic                 | 11: Reserved
    dc.l    isr_generic                 | 12: Reserved
    dc.l    isr_generic                 | 13: Reserved
    dc.l    isr_generic                 | 14: Reserved
    dc.l    isr_generic                 | 15: Reserved
    dc.l    isr_generic                 | 16: Reserved
    dc.l    isr_generic                 | 17: Reserved

    dc.l    isr_generic                 | 18: Spurious Interrupt

    dc.l    isr_generic                 | 19: Level 1 Autovector
    dc.l    isr_generic                 | 1A: Level 2 Autovector
    dc.l    isr_generic                 | 1B: Level 3 Autovector
    dc.l    isr_generic                 | 1C: Level 4 Autovector
    dc.l    isr_generic                 | 1D: Level 5 Autovector
    dc.l    isr_generic                 | 1E: Level 6 Autovector
    dc.l    isr_generic                 | 1F: Level 7 Autovector

    dc.l    isr_generic                 | 20: TRAP Handler (unused)
    dc.l    isr_generic                 | 21: TRAP Handler (unused)
    dc.l    isr_generic                 | 22: TRAP Handler (unused)
    dc.l    isr_generic                 | 23: TRAP Handler (unused)
    dc.l    isr_generic                 | 24: TRAP Handler (unused)
    dc.l    isr_generic                 | 25: TRAP Handler (unused)
    dc.l    isr_generic                 | 26: TRAP Handler (unused)
    dc.l    isr_generic                 | 27: TRAP Handler (unused)
    dc.l    isr_generic                 | 28: TRAP Handler (unused)
    dc.l    isr_generic                 | 29: TRAP Handler (unused)
    dc.l    isr_generic                 | 2A: TRAP Handler (unused)
    dc.l    isr_generic                 | 2B: TRAP Handler (unused)
    dc.l    isr_generic                 | 2C: TRAP Handler (unused)
    dc.l    isr_generic                 | 20: TRAP Handler (unused)
    dc.l    isr_generic            		| 2D: TRAP#13 handler
    dc.l    isr_generic            		| 2E: TRAP#14 handler
    dc.l    isr_generic            		| 2F: TRAP#15 handler
    dc.l    isr_generic                 | 30-3F: Remaining Reserved vectors
    dc.l    isr_generic                 | 31: Reserved
    dc.l    isr_generic                 | 32: Reserved
    dc.l    isr_generic                 | 33: Reserved
    dc.l    isr_generic                 | 34: Reserved
    dc.l    isr_generic                 | 35: Reserved
    dc.l    isr_generic                 | 36: Reserved
    dc.l    isr_generic                 | 37: Reserved
    dc.l    isr_generic                 | 38: Reserved
    dc.l    isr_generic                 | 39: Reserved
    dc.l    isr_generic                 | 3A: Reserved
    dc.l    isr_generic                 | 3B: Reserved
    dc.l    isr_generic                 | 3C: Reserved
    dc.l    isr_generic                 | 3D: Reserved
    dc.l    isr_generic                 | 3E: Reserved
    dc.l    isr_generic                 | 3F: Reserved
vectors_end:

