    .globl  string_to_hex

    .section text
/*
 * Converts a ascii character to a number
 * Value passed in D0
 */
hex_to_byte:
    cmp.b #0x40,d0                  | Check if lowercase
    blt .nochange
    and.b #0xdf,d0                  | Make uppercase
.nochange:
    subi.b #0x30,d0                 | Convert to number
    cmpi.b #0xa,d0                  | Check if A-F
    blt .is_number
    subi.b #7,d0                    | Get the value
.is_number:
    rts

/*
 * Converts a string hex representation to a number
 * Pointer to the data is passed in A0
 * return returned in D0
 */
string_to_hex:
    move.l d2,-(sp)                 | Save contents of D2
    clr.l d2                        | Resulting value

.next_value:
    move.b (a0)+,d0                 | Get the next value
    beq .exit_sth                   | End of string found?

    rol.l #4,d2                     | Shift the result by 4 bits
    bsr hex_to_byte                 | Convert the value
    or.b d0,d2                      | Add to the result
    bra .next_value

.exit_sth:
    move.l d2,d0                    | Return result in D0
    move.l (sp)+,d2                 | Restore D2
    rts
