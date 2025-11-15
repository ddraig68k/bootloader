#include "duart.h"

    .globl __start

    .equ DELAY_COUNT, 1000000           | Number of loops before timeout
    .equ ESC, 0x1B

    .section .text
__start:

	move.w	#0x2700, sr 			    | Disable interrupts
	movea.l	#__stack_end, sp

    | clear BSS
    lea.l   __s_bss,A0
    move.l  #__e_bss,D0
    sub.l   A0,D0                       | Get the bss section length
    addq.l  #1,D0                       | Adjust in case of odd number
    lsr.l   #1,D0                       | Divide by 2 (word length)
    beq     .copy_data                  | No BSS data

.clear_bss:
    clr.w   (A0)+
    subq.l  #1,D0
    bne     .clear_bss

    | Copy initialised data from ROM into RAM
    lea.l   __e_text,A0                 | Move data to RAM
    lea.l   __s_data,A1
    move.l  #__e_data,D0
    sub.l   A1,D0                       | Get the data section length
    addq.l  #1,D0
    lsr.l   #1,D0                       | Divide by 2 (word length)
    beq     boot_check                  | No DATA section

.copy_data:
    move.w  (A0)+,(A1)+
    subq.l  #1,D0
    bne     .copy_data

boot_check:
    bsr     init_duart                  | Initialise Serial

    lea     intro_msg,a0                | Display bootloader startup
    jsr     print_string

    | For initial testing, start monitor
    jmp     start_monitor

    | After startup, Wait for a signal over the serial port to
    | initialise the download or flash routines before booting from the flash
    | Pressing escape, or no valid flash image will boot into monitor mode
    bsr     bootload_wait
    cmp.b   #0,d0                   | Enter upload ROM mode?
    beq     .run_monitor
.check_blmode:
    cmp.b   #1,d0                   | Enter bootloader mode?
    bne     .check_monitor
    jmp     flash_rom
.check_monitor:
    cmp.b   #2,d0                   | Esc pressed for monitor
    bne     .boot_flash
    jmp     .run_monitor
    | Any other response, boot from flash
.boot_flash:
    bsr     valid_flash             | Check flash has a valid image
    bne     .invalid_flash
    jmp     boot_flash              | Run the flash code

.invalid_flash:
    lea.l   invalid_image,a0
    jsr     print_string            | No vlaid flash image

.run_monitor:
    jmp     start_monitor


/*
 * Waits and checks the serial port to see if it has received the '@' character and
 * respond with '&'. If the character is not seen after a time, the bootloader will
 * continue to booting from Flash. If ESC has been sent, then the bootloader enters
 * the monitor mode.
 *
 * Returns 0 for timeout/boot from flash
 * Returns 1 for bootloader mode
 * Returns 2 for run monitor
 */
bootload_wait:
    move.l  #DELAY_COUNT,d3         | Number of counts before entering the bootloader
    movea.l #DUART_BASE,a1          | DUART address

.bl_check_char:
    btst.b  #BIT_RxRDY,DUART_SRA(a1)    | Test the Rx status
    bne     .bl_dec_count

    move.b  DUART_RBA(a1),d0        | Read the character
    cmp.b   #'@',d0                 | Bootloader start char?
    bne     .bl_chk_esc
    moveq.l #1,d0                   | Enter bootloader
    jmp     .bl_exit

.bl_chk_esc:
    cmp.b   #ESC,d0
    bne     .bl_dec_count
    moveq.l #2,d0                   | Enter monitor
    jmp     .bl_exit

.bl_dec_count:
    subq.l  #1,d3                   | decrement loop counter
    bne     .bl_check_char
    moveq.l #0,d0                   | No character received, boot as normal

.bl_exit:
    rts

    .section .bss

    .section .rodata
intro_msg:
    .asciz "Y Ddraig bootloader, waiting for command\n\r"

