

    .globl monitor_start


    .section .text
monitor_start:
    bsr     init_duart              | Initialise the DUART

    lea.l   intro_msg,10
    jsr     print_string            | Display bootloader message

    | After startup, Wait for a signal over the serial port to
    | initialise the download or flash routines before booting from the flash
    | Pressing escape, or no valid flash image will boot into monitor mode
    bsr     bootload_wait
    tst.b   #1,d0                   | Enter upload ROM mode?
    bne     .check_flash
    jmp     upload_rom
.check_flash:
    tst.b   #2,d0                   | Enter flash ROM mode?
    bne     .check_monitor
    jmp     flash_rom
.check_monitor:
    tst.b   #3,d0                   | Esc pressed for monitor
    bne     .boot_flash
    jmp     .run_monitor

.boot_flash
    bsr     valid_flash             | Check flash has a valid image
    bne     .invalid_flash
    jmp     boot_flash              | Run the flash code

.invalid_flash
    lea.l   invalid_image,10
    jsr     print_string            | No vlaid flash image

.run_monitor
    jmp .run_monitor

    .section .bss

    .section .rodata
intro_msg:
    .asciz "Y Ddraig bootloader, waiting for command\n\r"

invalid_image:
    .asciz "No valid bootable image found in flash, booting into monitor\n\r"

bootload_message:
    .asciz "Starting monitor, 'help' for commands\n\r"

