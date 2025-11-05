#ifndef DUART_H
#define DUART_H

#include "ddraig.h"

#define DUART_ADDR(x) ((x) << 1)

#define	DUART_MR1A      DUART_ADDR(0x00) 	// Mode Register A
#define DUART_MR2A      DUART_ADDR(0x00) 	// Mode Register A
#define DUART_SRA       DUART_ADDR(0x01) 	// Status Register A
#define DUART_CSRA      DUART_ADDR(0x01) 	// Clock-Select Register A
#define DUART_CRA       DUART_ADDR(0x02) 	// Command Register A
#define DUART_RBA       DUART_ADDR(0x03) 	// Receive Buffer A
#define DUART_TBA       DUART_ADDR(0x03) 	// Transmit Buffer A
#define DUART_IPCR      DUART_ADDR(0x04) 	// Input Port Change Register
#define DUART_ACR       DUART_ADDR(0x04) 	// Auxiliary Control Register
#define DUART_ISR       DUART_ADDR(0x05) 	// Interrupt Status Register
#define DUART_IMR       DUART_ADDR(0x05) 	// Interrupt Mask Register
#define DUART_CUR       DUART_ADDR(0x06) 	// Counter Mode: current MSB
#define DUART_CTUR      DUART_ADDR(0x06) 	// Counter/Timer upper reg
#define DUART_CLR       DUART_ADDR(0x07) 	// Counter Mode: current LSB
#define DUART_CTLR      DUART_ADDR(0x07) 	// Counter/Timer lower reg
#define DUART_MR1B      DUART_ADDR(0x08) 	// Mode Register B
#define DUART_MR2B      DUART_ADDR(0x08) 	// Mode Register B
#define DUART_SRB       DUART_ADDR(0x09) 	// Status Register B
#define DUART_CSRB      DUART_ADDR(0x09) 	// Clock-Select Register B
#define DUART_CRB       DUART_ADDR(0x0A) 	// Command Register B
#define DUART_RBB       DUART_ADDR(0x0B) 	// Receive Buffer B
#define DUART_TBB       DUART_ADDR(0x0B) 	// Transmit Buffer A
#define DUART_IVR       DUART_ADDR(0x0C) 	// Interrupt Vector Register
#define DUART_IP        DUART_ADDR(0x0D) 	// Input Port
#define DUART_OPCR      DUART_ADDR(0x0D) 	// Output Port Configuration Reg.
#define DUART_STRTCC    DUART_ADDR(0x0E) 	// Start-Counter command
#define DUART_OPRSET    DUART_ADDR(0x0E) 	// Output Port Reg,SET bits
#define DUART_STOPCC    DUART_ADDR(0x0F) 	// Stop-Counter command
#define DUART_OPRRST    DUART_ADDR(0x0F) 	// Output Port Reg,ReSeT bits

// Status Register Bits (SRA/SRB)
#define BIT_RxRDY		        0
#define BIT_RxFULL		        1
#define BIT_TxRDY		        2
#define BIT_TxEMPTY		        3
#define BIT_ERR_OVER	        4
#define BIT_ERR_PAR		        5
#define BIT_ERR_FRAME	        6
#define BIT_BREAK 		        7

#define SR_RECEIVED_BREAK       (1 << BIT_BREAK)
#define SR_FRAMING_ERROR	    (1 << BIT_ERR_FRAME)
#define SR_PARITY_ERROR		    (1 << BIT_ERR_PAR)
#define SR_OVERRUN_ERROR	    (1 << BIT_ERR_OVER)
#define SR_TX_EMPTY			    (1 << BIT_TxEMPTY)
#define SR_TX_READY			    (1 << BIT_TxRDY)
#define SR_RX_FULL			    (1 << BIT_RxFULL)
#define SR_RX_READY			    (1 << BIT_RxRDY)

#define BIT_ISR_A_TXRDY			0
#define BIT_ISR_A_RXRDY			1
#define BIT_ISR_A_BREAK			2
#define BIT_ISR_TIMER			3
#define BIT_ISR_B_TXRDY			4
#define BIT_ISR_B_RXRDY			5
#define BIT_ISR_B_BREAK			6
#define BIT_ISR_INP_CHG		 	7

// Interrupt Status/Mask Bits (ISR/IVR)
#define ISR_INPUT_CHANGE		(1 << BIT_ISR_INP_CHG)
#define ISR_CH_B_BREAK_CHANGE	(1 << BIT_ISR_B_BREAK)
#define ISR_CH_B_RX_READY_FULL	(1 << BIT_ISR_B_RXRDY)
#define ISR_CH_B_TX_READY		(1 << BIT_ISR_B_TXRDY)
#define ISR_TIMER_CHANGE		(1 << BIT_ISR_TIMER)
#define ISR_CH_A_BREAK_CHANGE	(1 << BIT_ISR_A_BREAK)
#define ISR_CH_A_RX_READY_FULL	(1 << BIT_ISR_A_RXRDY)
#define ISR_CH_A_TX_READY		(1 << BIT_ISR_A_TXRDY)


#endif
