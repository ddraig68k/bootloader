    .include "ddraig.inc"
    .include "duart.inc"
    .include "constants.inc"

    .globl      load_srecord

    .section .text
serial_read:
      movem.l a0/d1,-(sp)           // save A0/D1
      lea DUART_BASE,a0
.readpoll:
      move.b DUART_SRA(a0),d1
      btst #RxRDY,d1
      beq .readpoll
      move.b DUART_RBA(a0),d0
      movem.l (sp)+,a0/d1           // restore registers
      rts

serial_write:
      movem.l a0/d1,-(sp)           // save A0/D1
      lea DUART_BASE,a0
.writepoll:
      move.b DUART_SRA(a0),d1       // wait for OK to transmit
      btst #TxRDY,d1
      beq .writepoll

      move.b d0,DUART_TBA(a0)       // send Char

      movem.l (sp)+,a0/d1           // restore A0/D1
      rts


// Read the S-Record data over the serial port

// S-Record example:
// S214000400227C00400001143C00006100002C128297
// S804000000FB
// READ S-RECORD
// D7 = Number of bytes in record
// D6 = Temporary address value
// D5 = Checksum for the record line
// D4 = Number of bytes received
// A6 = Write address
load_srecord:
    movem.l d4-d7/a6,-(sp)         // Saved any registers used
    clr.l   d4                  // Clear number of bytes received
    clr.l   d5                  // Clear the checksum

    // Print the start message
    lea     srec_begin_str,a0
    bsr     print_string

    // Wait for the s-record file transfer to begin or cancelled
.wait_start:
    bsr     serial_read
    cmp.b   #'S',d0             // Start of s-record data?
    bne.s   .check_cancel
    bra.s   .get_type

.check_cancel:
    cmp.b   #ESCAPE,d0      // Has the escape key been pressed?
    bne     .wait_start
    move.l  #1,d0               // Return 1 for escape pressed
    bra     .exit_srec          // Jump to exit

.get_type:
    // Check if the record type is S7 or S8 or S9 for end of file
    bsr     serial_read
    cmp.b   #'7',d0
    beq     .end_found
    cmp.b   #'8',d0
    beq     .end_found
    cmp.b   #'9',d0
    bne     .check_start

.end_found:
    // Wait until the end of the last line
    bsr     serial_read
    cmp.b   #CR,d0
    beq     .end_crlf_found
    cmp.b   #LF,d0          // No CR so check for a LF character instead
    bne     .end_found

.end_crlf_found:
    bsr     print_newline
    bsr     print_newline
    move.l  d4,d0               // Get the number of bytes received
    bsr     print_decimal       // Print the number
    lea     srec_size_str,a0
    bsr     print_string        // Print the number of bytes received

    swap.w  d5                  // Get the number of checksum errors
    clr.l   d0
    move.w  d5,d0
    bsr     print_decimal
    lea     srec_error_str,a0   // Pointer to checksum error string
    bsr     print_string
    move.w  d5,d0
    cmp.w   #0,d0
    beq     .exit_success
    move.l  #2,d0               // Report checksum error
    bra     .exit_srec

.check_start:
    cmp.b   #'3',d0             // Is this a S3 (32-bit address) record?
    beq     .read_type_s3
    cmp.b   #'2',d0             // Is this a S2 (24-bit address) record?
    beq     .read_type_s2
    cmp.b   #'1',d0             // Is this a S1 (16-bit address) record?
    beq     .read_type_s1
    //cmp.b   #'0',d0             // Is this a header record?
    //beq     .read_type_head
    bra     .wait_start         // Wait for next record

// local subroutine to prepare start of line
.start_line:
    clr.w   d5                  // Clear the byte checksum
    bsr     read_hex2           // Read 2 bytes from the serial port
    clr.l   d7
    move.b  d1,d7               // Number of bytes stored in D7
    add.b   d1,d5               // Add checksum
    rts

// 16-bit address record
.read_type_s1:
    bsr     .start_line
    subq.b  #4,d7               // Subtract 4 bytes from total byte count
// Get the address and save to D6
    clr.l   d6
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    move.l  d6,a6               // Save the address pointer
    bra     .read_srec_data

// 24-bit address record
.read_type_s2:
    bsr     .start_line
    subq.b  #5,d7
// Get the address and save to D6
    clr.l   d6
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    move.l  d6,a6               // Save the address pointer
    bra     .read_srec_data

// 32-bit address record
.read_type_s3:
    bsr     .start_line
    subq.b  #6,d7
// Get the address and save to D6
    clr.l   d6
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    rol.l   #8,d6               // Get next byte
    bsr     read_hex2
    move.b  d1,d6
    add.b   d1,d5               // Add checksum

    move.l  d6,a6               // Save the address pointer
    bra     .read_srec_data

.read_srec_data:
    bsr     read_hex2           // Get the data byte
    add.b   d1,d5               // Add the checksum
    move.b  d1,(a6)+            // Save the data

    addq.l  #1,d4               // Increment bytes received
    dbf     d7,.read_srec_data

    not.b   d5                  // One's complement of byte checksum
    bsr     read_hex2           // Get the checksum byte
    cmp.b   d1,d5               // Compare the checksums
    beq.s   .no_error

    add.l   #0x10000,d5          // Add 1 to upper word
    move.b  #'*',d0             // Send checksum error character
    bra.s   .send_rec_status

.read_type_head:
    lea     srec_head_str,a0    // Print the header string
    bsr     print_string

    bsr     .start_line
.read_header:
    bsr     read_hex2           // Get the data byte
    add.b   d1,d5               // Add the checksum

    move.b  d1,d0
    bsr     serial_write        // Write the character

    addq.l  #1,d4               // Increment bytes received
    dbf     d7,.read_srec_data

    bsr     print_newline
    bra     .wait_start         // Wait for next line

.no_error:
    move.b  #'.',d0             // Checksum OK character
.send_rec_status:
    bsr serial_write
    bra .wait_start             // Wait for the next line

.exit_success:
    move.l  #0,d0               // 0 - S-Record loaded successfully
.exit_srec:

    move.l  d0,d4               // Copy return code
    move.l  #0x2000,d1           // Count
    lea     DUART_BASE,a0
// Check for any extra characters on the serial port
.exit_getchar:
    move.b  DUART_SRA(a0),d1
    btst    #RxRDY,d1
    beq     .exit_nochar
    move.b  DUART_RBA(a0),d0
.exit_nochar:
    dbra.w  d1,.exit_getchar
    move.l  d4,d0
    movem.l (SP)+,d4-d7/a6      // Restore the saved registers
    rts


// //Print a null terminated string pointed to by A0
print_string:
    move.b  (a0)+,d0
    cmp.b   #0,d0
    beq.s   .pstr_end
    bsr     serial_write
    bra.s   print_string
.pstr_end:
    rts

// Print a CR/LF to the serial port
print_newline:
    move.l  d0,-(sp)
    move.b  #CR,d0
    bsr     serial_write
    move.b  #LF,d0
    bsr     serial_write
    move.l  (sp)+,d0
    rts

// Convert ASCII hex to binary value
convert_to_hex:
    subi.b  #0x30,d0             // ASCII to binary
    cmpi.b  #0xA,d0              // Greater than 9?
    bmi     .zero_to_nine
    and.b   #0xDF,d0            // Mask case bits
    subi.b  #7,d0

.zero_to_nine:
    move.b d0,d1                // Save result in d1
    rts

read_hex2:
      bsr serial_read
      bsr convert_to_hex
      rol.b #4,d1
      move.b d1,d2
      bsr serial_read
      bsr convert_to_hex
      add.b d2,d1
      rts


// Prints a decimal value
// D0 = Value to print
print_decimal:
    move.l  d0,-(sp)            // Save current value of d0
    bsr     convert_decimal     // Result is pointer in a0
    lea     decimal_buffer,a0    // buffer pointer
    bsr     print_string        // Print the result value
    move.l  (sp)+,d0            // Restore d0
    rts

convert_decimal:
    movem.l d1-d7,-(sp)         // Save registers

    lea     decimal_buffer,a0
    move.l  d0,d7               // Save the original value
    bpl.s   .is_positive
    neg.l   d7                  // Change the number to a positive value
    bmi.s   .add_zero           // Special case? (-0)
    move.b  #'-',(a0)+          // Add the negative sign to the buffer

.is_positive:
    clr.w   d4                  // Don't print any leading zeros
    moveq.l #10,d6              // Set counter to 10
.convert_loop:
    moveq.l #1,d2               // Value to subtract
    move.l  d6,d1               // Copy the counter
    subq.l  #1,d1               // Adjust - form power of 10
    beq.s   .power_zero         // if power is zero
.mutiply_value:
    move.w  d2,d3               // d3 = lower word
    mulu.w  #10,d3              // Multiply by 10
    swap.w  d2                  // d2 = upper word
    mulu.w  #10,d2
    swap.w  d3                  // Add upper to upper
    add.w   d3,d2
    swap.w  d2                  // Upper part of the result
    swap.w  d3                  // Lower part of the result
    move.w  d3,d2               // d2 = Combined upper and lower values
    subq.l  #1,d1
    bne     .mutiply_value
.power_zero:
    clr.l   d0                  // Holds subtract amount
.next_power:
    cmp.l   d2,d7
    blt.s   .no_subtract        // No more subtracts possible
    addq.l  #1,d0               // Increment number of subtractions
    sub.l   d2,d7               // Count down by powers of 10
    bra.s   .next_power         // Check for more
.no_subtract:
    tst.b   d0                  // Value greater than zero?
    bne.s   .add_digit
    tst.w   d4                  // Print leading zeros?
    beq.s   .no_lead_zero
.add_digit:
    addi.b  #'0',d0             // Convert to ASCII value
    move.b  d0,(a0)+            // Add to buffer
    move.b  d0,d4               // Don't ignore any more zeros
.no_lead_zero:
    subq.l  #1,d6               // Process next power
    bne     .convert_loop
    tst.w  d4                   // Any non zero values added to buffer?
    bne.s  .add_terminator
.add_zero:
    move.b  #'0',(a0)+          // Add at least a zero
.add_terminator:
    move.b  #0,(a0)                     // PUT TERMINATOR
    movem.l (sp)+,d1-d7                 // restore registers
    rts


    .section .rodata
srec_begin_str:
    .ascii  "Waiting for S-Record transfer, press ESC to exit",
    dc.b    13,10,0
srec_size_str:
    .ascii  " bytes transferred"
    dc.b    13,10,0
srec_error_str:
    .ascii  " records with checksum errors"
    dc.b    13,10,0
srec_head_str:
    .asciz  "Header: "

    .section .bss
decimal_buffer:
        ds.b   12       // Allocate max 12-byte for decimal number

