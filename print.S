    .globl  prints
    .globl  print_newline


    .equ    CR      0x0d
    .equ    LF      0x0a

/*
 * Prints a null terminated string
 * Pointer to string in A0
 */
prints:
      move.b (A0)+,D0
      cmp.b  #0,D0
      beq.s .print_ends
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
