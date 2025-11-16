    .include "ddraig.inc"

    .equ DUART_MR1A      , 0x00             | Mode Register A
    .equ DUART_MR2A      , 0x00             | Mode Register A
    .equ DUART_SRA       , 0x02             | Status Register A
    .equ DUART_CSRA      , 0x02             | Clock-Select Register A
    .equ DUART_CRA       , 0x04             | Command Register A
    .equ DUART_RBA       , 0x06             | Receive Buffer A
    .equ DUART_TBA       , 0x06             | Transmit Buffer A
    .equ DUART_IPCR      , 0x08             | Input Port Change Register
    .equ DUART_ACR       , 0x08             | Auxiliary Control Register
    .equ DUART_ISR       , 0x0A             | Interrupt Status Register
    .equ DUART_IMR       , 0x0A             | Interrupt Mask Register
    .equ DUART_CUR       , 0x0C             | Counter Mode: current MSB
    .equ DUART_CTUR      , 0x0C             | Counter/Timer upper reg
    .equ DUART_CLR       , 0x0E             | Counter Mode: current LSB
    .equ DUART_CTLR      , 0x0E             | Counter/Timer lower reg
    .equ DUART_MR1B      , 0x10             | Mode Register B
    .equ DUART_MR2B      , 0x10             | Mode Register B
    .equ DUART_SRB       , 0x12             | Status Register B
    .equ DUART_CSRB      , 0x12             | Clock-Select Register B
    .equ DUART_CRB       , 0x14             | Command Register B
    .equ DUART_RBB       , 0x16             | Receive Buffer B
    .equ DUART_TBB       , 0x16             | Transmit Buffer A
    .equ DUART_IVR       , 0x18             | Interrupt Vector Register
    .equ DUART_IP        , 0x1A             | Input Port
    .equ DUART_OPCR      , 0x1A             | Output Port Configuration Reg.
    .equ DUART_STRTCC    , 0x1C             | Start-Counter command
    .equ DUART_OPRSET    , 0x1C             | Output Port Reg,SET bits
    .equ DUART_STOPCC    , 0x1E             | Stop-Counter command
    .equ DUART_OPRRST    , 0x1E             | Output Port Reg,ReSeT bits


| Status Register Bits (SRA/SRB)
    .equ RxRDY		    , 0
    .equ RxFULL		    , 1
    .equ TxRDY		    , 2
    .equ TxEMPTY	    , 3
    .equ ERR_OVER	    , 4
    .equ ERR_PAR	    , 5
    .equ ERR_FRAME	    , 6
    .equ BREAK 		    , 7

    .equ ISR_A_TXRDY	, 0
    .equ ISR_A_RXRDY	, 1
    .equ ISR_A_BREAK	, 2
    .equ ISR_TIMER	    , 3
    .equ ISR_B_TXRDY	, 4
    .equ ISR_B_RXRDY	, 5
    .equ ISR_B_BREAK	, 6
    .equ ISR_INP_CHG	, 7

