/******************************************************************************            
************                 LABCENTER ELECTRONICS                  ************            
************           Proteus VSM Sample Design Code               ************            
************                   IAR ARM Calculator                  ************            
*******************************************************************************/       

#include "NXP/iolpc2104.h"
#include <intrinsics.h>

#include "calc.h"
#include "stddef.h"
#include "math.h"
#include "stdlib.h"
#include "string.h"

//Variables
static FLOAT lvalue = 0;
static FLOAT rvalue = 0;
static CHAR lastop;
static CHAR list[6]={'l','i','b','a','n'};
int main(void)
// Initialise our variables and call the 
// Assembly routine to initialise the LCD display. 
 { //Init
   init_system();
   
   lcd_init();
   calc_evaluate();
 }   
 
void init_system()
//Perform system and IO initialization
 { MEMMAP = 1;
   //__disable_interrupt();
   SCS_bit.GPIO0M = 0; // Set legacy IO
   PINSEL0 = 0; //Enable GPIO
   PINSEL1 = 0; //Enable GPIO
   IODIR =  0xFF07FF; //set bits 0-10 and 16-23 as output, the rest are input
   IOCLR = 0xFFFFFFFF; //Clear  IO bits
 }



/************************************************************************
***** I/O Routines *****
************************/

CHAR calc_getkey (void)
// Use the input routine from the *Keypad_Read* assembly file to 
// Scan for a key and return ASCII value of the Key pressed.
{ CHAR mykey;
  while ((mykey = keypadread()) == 0x00)
     /* Poll again */;
  return mykey;
 }

void calc_display (CHAR *buf)
// Use the Output and Clearscreen routines from the 
// *LCD_Write* assembly file to output ASCII values to the LCD.
 { INT8 i;
   clearscreen();
   for (i=0 ; buf[i] != 0; i++)
//    { if (buf[calc_testkey(buf[i]) || buf[i] == 0x2D)
       {
	 wrdata(list[buf[i]]);  
	}
//    }   
 }
