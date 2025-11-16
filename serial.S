    .include "duart.inc"
    .include "constants.inc"

    .globl  init_duart
    .globl  char_out
    .globl  char_in
    .globl  has_char

init_duart:
    move.l a0,-(sp)                     | save registers
    lea DUART_BASE,a0
    move.b #0x30,DUART_CRA(a0)          | reset transmitter
    move.b #0x20,DUART_CRA(a0)          | reset receiver
    move.b #0x10,DUART_CRA(a0)          | reset MR pointer to MRx1

    move.b #0x00,DUART_ACR(a0)          | select BAUD rate set 1
    move.b #0xCC,DUART_CSRA(a0)         | set TX & RX to 38400 BAUD
    move.b #0x93,DUART_MR1A(a0)         | set 8bits,no parity,character mode,RxRDY IRQ,RxRTS enabled
    move.b #0x27,DUART_MR2A(a0)         | $37 Normal Mode,enable TxRTS & TxCTS,one Stop bit
    move.b #0x05,DUART_CRA(a0)          | enable Receiver & Transmitter
    move.b #0x05,DUART_OPRSET(a0)       | $01 assert rts
    move.l (sp)+,a0                     | restore registers
    rts

/*
 * Write character in D0 to the serial port
 */
char_out:
    movem.l a0/d1,-(sp)                 | save A0/D1
    lea DUART_BASE,a0
.soutpoll:
    move.b DUART_SRA(a0),d1             | wait for OK to transmit
    btst #TxRDY,d1
    beq .soutpoll

    move.b d0,DUART_TBA(a0)             | send Char
    movem.l (sp)+,a0/d1                 | restore A0/D1
    rts

/*
 * Read a character from the serial port
 * Character returned in D0
 */
char_in:
    movem.l a0/d1,-(sp)                 | save registers
    lea DUART_BASE,a0
.cinspoll:
    move.b DUART_SRA(a0),d1
    btst #RxRDY,d1
    beq .cinspoll
    move.b DUART_RBA(a0),d0
    movem.l (sp)+,a0/d1                 | restore registers
    rts


/*
 * Checks if there is a character waiting on the serial port
 */
has_char:
    btst #RxRDY,(DUART_BASE+DUART_SRA)
    rts
