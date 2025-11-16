OUTPUT_ARCH(m68k)
SEARCH_DIR(.)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00002000, LENGTH = 1024K-0x2000
    ROM (rx) : ORIGIN = 0x00100000, LENGTH = 512K
}

stack_size = 0x8000;    /* 32K stack */

_ram_start = ORIGIN(RAM);
_ram_end = ORIGIN(RAM) + LENGTH(RAM);

_stack_start = _ram_end - stack_size;
__stack_end = _ram_end;

SECTIONS
{
	.text :
	{
	    LONG (__stack_end) 	    /* System Stack Pointer */
	    LONG (__start)		    /* Program start code */

        . = ALIGN(0x4);
		__s_text = . ;
        *(.text)                /* Code sections */
        *(.text*)

		__e_text = . ;
		__data_rom = . ;
	} > ROM

	.rodata :
	{
        . = ALIGN(0x4);
        *(.rodata)              /* Read only data */
        *(.rodata.*)
		__data_rom = . ;
	} > ROM

    .data : AT(__data_rom)
    {
        . = ALIGN(0x4);
		__s_data = . ;          /* Start of initialised data  */
        *(.data)
        *(.data.*)
		__e_data = . ;
        . = ALIGN(0x4);
    } > RAM

    .bss :
	{
        . = ALIGN(0x4);
		__s_bss = . ;           /* Zero initialised data section */
		*(.bss)
		*(COMMON)
        . = ALIGN(0x4);
		__e_bss = . ;
	} > RAM
}
