    .globl __start

    .equ DELAY_COUNT, 1000000           | Number of loops before timeout
    .equ ESC, 0x1B

    .section .text
__start:

	move.w #0x2700, sr 			        | Disable interrupts
	movea.l	#__stack_end, sp

    | clear BSS
    lea.l __s_bss,a0
    move.l #__e_bss,d0
    sub.l a0,d0                         | Get the bss section length
    addq.l #1,d0                        | Adjust in case of odd number
    lsr.l  #1,d0                        | Divide by 2 (word length)
    beq .copy_data                      | No BSS data

.clear_bss:
    clr.w (a0)+
    subq.l #1,d0
    bne .clear_bss

    | Copy initialised data from ROM into RAM
    lea.l __e_text,a0                   | Move data to RAM
    lea.l __s_data,a1
    move.l #__e_data,d0
    sub.l a1,d0                         | Get the data section length
    addq.l #1,d0
    lsr.l #1,d0                         | Divide by 2 (word length)
    beq boot_check                      | No DATA section

.copy_data:
    move.w (a0)+,(a1)+
    subq.l #1,d0
    bne .copy_data

boot_check:
    bsr init_duart                      | Initialise Serial

    lea intro_msg,a0                    | Display bootloader startup
    jsr print_string

    | For initial testing, start monitor
    jmp start_monitor

    | After startup, Wait for a signal over the serial port to
    | initialise the download or flash routines before booting from the flash
    | Pressing escape, or no valid flash image will boot into monitor mode
    bsr bootload_wait
    cmp.b #0,d0                         | Timeout, boot from flash
    beq .boot_flash
.check_blmode:
    cmp.b #1,d0                         | Enter bootloader mode?
    bne .check_monitor
    jmp start_bootloader
.check_monitor:
    cmp.b #2,d0                         | Esc pressed for monitor
    bne .boot_flash
    jmp start_monitor
    | Any other response, boot from flash
.boot_flash:
    bsr valid_flash             | Check flash has a valid image
    bne .invalid_flash
    jmp boot_flash              | Run the flash code

.invalid_flash:
    lea.l invalid_image,a0
    bsr print_string            | No vlaid flash image

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
    move.l #DELAY_COUNT,d3          | Number of counts before entering the bootloader
    movea.l #DUART_BASE,a1          | DUART address

.bl_check_char:
    bsr has_char                    | Test the Rx status
    beq .bl_dec_count

    bsr char_in                     | Read the character
    cmp.b #'@',d0                   | Bootloader start char?
    bne .bl_chk_esc                 | Check for Escape pressed
    move.b #'#',d0                  | Expecting '@' so reply with a '#'
    bsr char_out                    | Send response
    moveq.l #1,d0                   | Enter bootloader
    jmp .bl_exit

.bl_chk_esc:
    cmp.b #ESC,d0                   | Escape key pressed?
    bne .bl_dec_count
    moveq.l #2,d0                   | Enter monitor mode
    jmp .bl_exit

.bl_dec_count:
    subq.l #1,d3                    | decrement loop counter
    bne .bl_check_char
    moveq.l #0,d0                   | No character received, boot as normal

.bl_exit:
    rts

    .section .bss

    .section .rodata
intro_msg:
    .asciz "Y Ddraig bootloader, waiting for command\n\r"

