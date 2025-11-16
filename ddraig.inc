
| Ddraig hardware addresses

    .equ SRAM_START , 0x00000000       | Start of Static RAM
    .equ SRAM_END   , 0x000FFFFF       | End of Static RAM
    .equ DRAM_START , 0x00100000       | Start of Dynamic RAM
    .equ DRAM_END   , 0x008FFFFF       | End of Dynamic RAM

    .equ DUART_BASE , 0x00F7F000       | Base address of the Dual Asynchronous Receiver Transmitter
    .equ PIT_BASE   , 0x00F7F100       | Base address of the Peripheral Interface Timer
    .equ PS2_BASE   , 0x00F7F200       | Base address of the VT82C42 Keyboard/Mouse controller
    .equ IDE_BASE   , 0x00F7F300       | Base address of the IDE controller
    .equ RTC_BASE   , 0x00F7F400       | Base address of the RTC72421 clock controller

    .equ EXP1_BASE  , 0x00F7F500       | Base address of the Expansion slot ID
    .equ EXP2_BASE  , 0x00F7F600       | Base address of the Expansion slot ID
    .equ EXP3_BASE  , 0x00F7F700       | Base address of the Expansion slot ID
    .equ EXP4_BASE  , 0x00F7F800       | Base address of the Expansion slot ID

    .equ EXP1_DATA  , 0x00A00000       | Base address of the Expansion slot data
    .equ EXP2_DATA  , 0x00B00000       | Base address of the Expansion slot data
    .equ EXP3_DATA  , 0x00C00000       | Base address of the Expansion slot data
    .equ EXP4_DATA  , 0x00D00000       | Base address of the Expansion slot data

    .equ ROM_START  , 0x00F80000       | Start of ROM
    .equ ROM_END    , 0x00FFFFFF       | End of ROM

