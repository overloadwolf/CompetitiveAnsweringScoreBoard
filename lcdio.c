/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                    ARM7 LCD Driver                          ****
*****                                                             ****
**********************************************************************
*********************************************************************/

#include "NXP/iolpc2104.h"
#include "calc.h"

void lcd_init ()
// Initialise the LCD Display. 
 { IODIR =  0xFF07FF; //set bits 0-10  and 16-23 as output, the rest are input
   wrcmd(0x30);                  // 8-bit mode - 1 line.
   wrcmd(LCD_SETVISIBLE+0x04);   // Display only - no cursors.
   wrcmd(LCD_SETMODE+0x03);      // Automatic Increment - Display shift left.
   wrcmd(LCD_SETDDADDR+0x0F);    // Initial Position far right.
 }

void clearscreen ()
// Clear the LCD Screen and reset
// initial position.
 { wrcmd(LCD_CLS);
   wrcmd(LCD_SETDDADDR+0x0F);
 }

void wrcmd (BYTE cmdcode)
// Write a command to the LCD display.
 { IODIR =  0xFF07FF;
   IOCLR = (~(LCD_CMD_WR | cmdcode)) & 0x7FF;
   IOSET = LCD_CMD_WR | cmdcode;

   // Toggle Pin 'E' to send the command.
   IOSET = E_PIN_MASK;
   nop();
   nop();
   nop();
   nop();
   IOCLR = E_PIN_MASK;
   
   lcd_wait();
 }
     
void wrdata (BYTE data)
// Write a Character to the LCD Display. 
 { IODIR =  0xFF07FF;
   IOCLR = (~(LCD_DATA_WR | data)) & 0x7FF;
   IOSET = LCD_DATA_WR | data;
    
   // Toggle Pin 'E' to send the command.
   IOSET = E_PIN_MASK;
   nop(); 
   nop();
   nop();
   nop();
   IOCLR = E_PIN_MASK;
   
   lcd_wait();
 }

void lcd_wait ()
// Wait for the LCD busy flag to clear. 
 { BYTE status;
   IODIR = 0x700;
   IOSET = LCD_BUSY_RD;
   IOCLR = ~LCD_BUSY_RD;
   do
    { IOSET = E_PIN_MASK;
	   nop(); 
	   nop();
	   nop();
	   nop();
      status = IOPIN;
      IOCLR = E_PIN_MASK;
    } while (status & 0x80);
 }


