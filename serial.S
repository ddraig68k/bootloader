#include "duart.h"

    .globl  init_duart
    .globl  serial_out


init_duart:
    move.l a0,-(sp)                     | save registers
    lea DUART_BASE,a0
    move.b #$30,DUART_CRA(a0)           | reset transmitter
    move.b #$20,DUART_CRA(a0)           | reset receiver
    move.b #$10,DUART_CRA(a0)           | reset MR pointer to MRx1

    move.b #$00,DUART_ACR(a0)           | select BAUD rate set 1
    move.b #$CC,DUART_CSRA(a0)          | set TX & RX to 38400 BAUD
    move.b #$93,DUART_MR1A(a0)          | set 8bits,no parity,character mode,RxRDY IRQ,RxRTS enabled
    move.b #$27,DUART_MR2A(a0)          | $37 Normal Mode,enable TxRTS & TxCTS,one Stop bit
    move.b #$05,DUART_CRA(a0)           | enable Receiver & Transmitter
    move.b #$05,DUART_OPRSET(a0)        | $01 assert rts
    move.l (sp)+,a0                     | restore registers
    rts

/*
 * Write character in D0 to the serial port
 */
serial_out:
    movem.l a0/d1,-(sp)                 | save A0/D1
    lea DUART_BASE,a0
.soutpoll
    move.b DUART_SRA(a0),d1             | wait for OK to transmit
    btst #BIT_TxRDY,d1
    beq .soutpoll

    move.b d0,DUART_TBA(a0)             | send Char
    movem.l (sp)+,a0/d1                 | restore A0/D1
    rts

/*
 * Read a character from the serial port
 * Character returned in D0
 */
serial_in:
      movem.l A0/D1,-(SP)                 ; save registers
      lea DUART_BASE,A0
.cinspoll
      move.b DUART_SRA(A0),D1
      btst #RxRDY,D1
      beq .cinspoll
      move.b DUART_RBA(A0),D0
      movem.l (SP)+,A0/D1                 ; restore registers
      rts

char_in
      bsr char_ins
      bsr char_out
      rts

char_in_ready
      btst #RxRDY,(DUART_BASE+DUART_SRA)
      rts

	ENDC

  	IFNE	EASY68K_SIM

init_duart
      IFNE EASY68K_SERIAL
      ; initialize serial port
      move.l  #1<<16+40,d0  ; PID 1, task 40
      lea     com_port,A1       ; name of port
      trap   #15
      ;move.l  #1<<16+41,d0  ; PID 1, task 40
      ;move.l  #10,D1        ; 38400 Baud
      ;trap #15
      rts
      ENDC
      IFEQ EASY68K_SERIAL
      ; Keyboard Echo.
      ; D1.B = 0 to turn off keyboard echo.
      ; D1.B = non zero to enable it (default).
      ; Echo is restored on 'Reset' or when a new file is loaded.
      move.b #0,D1
      move.b #12,D0
      trap #15
      rts
      ENDC

char_out
      IFNE EASY68K_SERIAL
      movem.l D0-D1/A1,-(SP)
      lea ser_send_buf,A1	    ; Send buffer address
      move.b D0,(A1)
      move.l  #1<<16+43,d0  ; PID 1, task 40
      move.b #1,D1	    ; Send 1 character
      trap #15
      movem.l (SP)+,D0-D1/A1
      rts
      ENDC
      IFEQ EASY68K_SERIAL
      movem.l D0-D1,-(SP)  ; SAVE D1
      move.b D0,D1
      move.b #6,D0
      trap #15
      movem.l (SP)+,D0-D1 ; RESTORE D1
      rts
      ENDC

char_ins
      IFNE EASY68K_SERIAL
      movem.l D1/A1,-(SP)
      lea ser_rec_buf,A1	    ; Receive buffer address
      move.b D0,(A1)
.cins_wait
      move.l  #1<<16+42,d0  ; PID 1, task 40
      move.b #1,D1	    ; Get 1 character
      trap #15
      cmp.b #4,D0
      beq .cins_wait	    ; On timeout wait until get char
      lea ser_rec_buf,A1	    ; Receive buffer address
      move.b (A1),D0
      movem.l (SP)+,D1/A1
      rts
      ENDC
      IFEQ EASY68K_SERIAL
      move.l D1,-(SP)  ; SAVE D1
      move.b #5,D0
      trap #15
      move.b D1,D0  ;ACIAD.L,D0
      move.l (SP)+,D1 ; RESTORE D1
      rts
      ENDC

char_in
      bsr char_ins
      bsr char_out
      rts

char_in_ready
      move.l D1,-(SP)  ; SAVE D1
      move.b #7,D0
      trap #15
      move.b D1,D0  ;ACIAD.L,D0
      move.l (SP)+,D1 ; RESTORE D1
      btst #0,D0
      rts

      ENDC


; A3 POINTED TO FIRST BYTE
; END WITH 0
print_string
      move.b (A3)+,D0
      cmp.b  #0,D0
      beq.s .pstr_end
      bsr char_out
      bra.s print_string
.pstr_end
      rts

; NEW LINE
print_newline
      move.l D0,-(SP)
      move.b #CR,D0
      bsr char_out
      move.b #LF,D0
      bsr char_out
      move.l (SP)+,D0
      rts

print_space
      move.b #SP,D0
      bsr char_out
      rts

scroll_output
      move.w #2,D1
.so_next
      bsr print_newline
      dbf d1,.so_next
      rts

display_prompt
      move.l #RAMBASE,A6
      bsr print_newline
      move.l POINTER_NOW(A6),D0
      bsr print_6hex
      lea.l PROMPT.L,A3
      bsr print_string
      rts
