
| PIT Registers
    .equ PIT_PGCR       , 0x00      | Port General Control Register
    .equ PIT_PSRR 	    , 0x02      | Port Service Request Register
    .equ PIT_PADDR	    , 0x04      | Port A Data Direction Register
    .equ PIT_PBDDR	    , 0x06      | Port B Data Direction Register
    .equ PIT_PCDDR	    , 0x08      | Port C Data Direction Register
    .equ PIT_PIVR	    , 0x0A      | Port Interrupt Vector Register
    .equ PIT_PACR	    , 0x0C      | Port A Control Register
    .equ PIT_PBCR	    , 0x0E      | Port B Control Register
    .equ PIT_PADR	    , 0x10      | Port A Data Register
    .equ PIT_PBDR	    , 0x12      | Port B Data Register
    .equ PIT_PAAR	    , 0x14      | Port A Alternative Register
    .equ PIT_PBAR	    , 0x16      | Port B Alternative Register
    .equ PIT_PCDR	    , 0x18      | Port C Data Register
    .equ PIT_PSR	    , 0x1A      | Port Status Register
    .equ PIT_TCR 	    , 0x20      | Timer Control Register
    .equ PIT_TIVR	    , 0x22      | Timer Interrupt Vector Register
    .equ PIT_CPRH	    , 0x26      | Counter Preload Register (High)
    .equ PIT_CPRM	    , 0x28      | Counter Preload Register (Mid)
    .equ PIT_CPRL	    , 0x2A      | Counter Preload Register (Low)
    .equ PIT_CNTRH	    , 0x2E      | Count Register (High)
    .equ PIT_CNTRM	    , 0x30      | Count Register (Mid)
    .equ PIT_CNTRL	    , 0x32      | Count Register (Low)
    .equ PIT_TSR        , 0x34      | Timer Status Register

| General Control Register
    .equ PIT_GCR_MODE0       , 0x00     | Mode 0 - Unidirectional 8-bit mode
    .equ PIT_GCR_MODE1       , 0x40     | Mode 1 - Unidirectional 16-bit mode
    .equ PIT_GCR_MODE2       , 0x80     | Mode 2 - Bidirectional 8-bit mode
    .equ PIT_GCR_MODE3       , 0xC0     | Mode 3 - Bidirectional 18-bit mode
    .equ PIT_GCR_H34_EN      , 0x20     | H34 Enable
    .equ PIT_GCR_H12_EN      , 0x10     | H12 Enable
    .equ PIT_GCR_SENSE_H4    , 0x08     | Handshake sense H4
    .equ PIT_GCR_SENSE_H3    , 0x04     | Handshake sense H3
    .equ PIT_GCR_SENSE_H2    , 0x02     | Handshake sense H2
    .equ PIT_GCR_SENSE_H1    , 0x01     | Handshake sense H1
