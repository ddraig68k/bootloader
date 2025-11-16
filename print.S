    .include "constants.inc"

    .globl  prints
    .globl  print_newline
    .globl  print_1hex
    .globl  print_2hex
    .globl  print_4hex
    .globl  print_6hex
    .globl  print_8hex
    .globl  print_decimal


/*
 * Prints a null terminated string
 * Pointer to string in A0
 */
prints:
      move.b (A0)+,D0
      cmp.b  #0,D0
      beq.s .prints_end
      bsr char_out
      bra.s prints
.prints_end:
      rts

print_newline:
      move.l D0,-(SP)
      move.b #CR,D0
      bsr char_out
      move.b #LF,D0
      bsr char_out
      move.l (SP)+,D0
      rts

/*
 * Print hex values, 1, 2, 4, 6 or 8 bytes
 * Value to print is stored in D0
 */
print_1hex:                             | Print single digit hex number
    move.b d0,-(sp)                     | Store current value in D0
    and.b #0xF,d0                       | Mask off upper nibble
    add.b #'0',d0                       | Convert to ASCII
    cmp.b #'9',d0
    bls.s   .prnt1hex
    add.b #7,d0                         | Convert to A-F
.prnt1hex:
    bsr char_out
    move.b (sp)+,d0                     | Restore original value
    rts

print_2hex:                             | Print 8-bit hex number
    ror.b #4,d0
    bsr.s print_1hex
    rol.b #4,d0
    bra print_1hex

print_4hex:                             | Print 16-bit hex number
    ror.w #8,d0
    bsr.s print_2hex
    rol.w #8,d0
    bra.s print_2hex

print_6hex:
    swap.w d0                           | Print 24-bit hex number
    bsr.s print_2hex
    swap.w d0
    bra.s print_4hex

print_8hex:
    swap.w d0                           | Print 32-bit hex number
    bsr.s  print_4hex
    swap.w d0
    bra.s  print_4hex


/*
 * print_decimal prints a number in decimal format
 * D0 - 32-BIT number value to print
 */
print_decimal:
    movem.l a0-a1/d0,-(sp)
    move.l #pdec_buffer,a1
    bsr .bin_to_decimal                     | Convert the number
    move.l #pdec_buffer,a0
    bsr prints                              | Print the number
    movem.l (sp)+,a0-a1/d0
    rts

.bin_to_decimal:
    movem.l d1-d7,-(sp)                     | Save registers
    move.l d0,d7                            | Original value in D7
    bpl.s .b2d_positive
    neg.l d7                                | Change number to positive
    bmi.s .b2d_minzero                      | Special case (-0)
    move.b #'-',(a1)+                       | Write the '-' sign
.b2d_positive:
    clr.w d4                                | For zero suppress
    moveq.l #10,d6                          | Counter
.b2d_nextpower:
    moveq.l #1,d2                           | Value to subtract
    move.l d6,d1                            | Counter
    subq.l #1,d1                            | Adjust from power of ten
    beq.s .b2d_powerzero                    | If power is zero
.b2d_calcpower:
    move.w d2,d3                            | D3 = lower word
    mulu.w #10,d3
    swap.w d2                               | D2 =Upper word
    mulu.w #10,d2
    swap.w d3                               | Add upper to upper
    add.w d3,d2
    swap.w d2                               | Put upper in lower
    swap.w d3                               | Put lower in lower
    move.w d3,d2                            | D2 = Upper & Lower
    subq.l #1,d1
    bne .b2d_calcpower
.b2d_powerzero:
    clr.l d0                                | Holds subtract amount
.b2d_dosubs:
    cmp.l d2,d7
    blt.s .b2d_nosubs                       | If no more subtractions possible
    addq.l #1,d0                            | Increment subtraction count
    sub.l d2,d7                             | Count down by powers of ten
    bra.s .b2d_dosubs                       | Do more?
.b2d_nosubs:
    tst.b d0                                | Has a value?
    bne.s .b2d_novalue
    tst.w d4                                | Check if leading zero is suppressed
    beq.s .b2d_skipzero
.b2d_novalue:
    addi.b #0x30,d0                         | Convert binary value to ASCII
    move.b d0,(a1)+                         | Store in the buffer
    move.b d0,d4                            | Set flag to not zero suppress value
.b2d_skipzero:
    subq.l #1,d6                            | Do next power
    bne .b2d_nextpower
    tst.w d4                                | Was a value printed?
    bne.s .b2d_exit
.b2d_minzero:
    move.b  #'0',(a1)+                      | Print at least a zero
.b2d_exit:
    move.b #0,(a1)                          | Terminate String
    movem.l (sp)+,d1-d7                     | Restore registers
    rts



    .section .bss
pdec_buffer:
    ds.b    16              | Buffer for the print_decimal function
