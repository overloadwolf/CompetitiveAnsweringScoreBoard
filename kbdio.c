/*********************************************************************
**********************************************************************
*****                                                             ****
*****         L A B C E N T E R    E L E C T R O N I C S          ****
*****                                                             ****
*****                       ARM7 Keypad Scanner                   ****
*****                                                             ****
**********************************************************************
*********************************************************************/


#include "NXP/iolpc2104.h"
#include "calc.h"

CHAR keycodes[16] = {'7','8','9','/','4','5','6','*','1','2','3','-','.','0','=','+'};

CHAR keypadread()
// Find a key, wait for it to be released and return.
 { CHAR key = scankeypad();
   if (key)
      while (scankeypad() != 0)
         /* Nothing */  ;  
   return key;
 } 

CHAR scankeypad()
// Scan the keypad for a keypress.
// Return 0 for no press or the char pressed.
 { INT8 row,col,tmp;
   CHAR key=0;
   INT wait;
   INT idx;

   // Initialise Port 0 
   IOCLR = 0xFF;
   IODIR =  0xFF00FF; //set bits 0-7 and 16-23 as output, the rest are input

   for (row=0; row < KEYP_NUM_ROWS; row++)
    { // Drive appropriate row low and read columns:
      IOSET = (~(1 << row)) & 0xFF;
      IOCLR = (1 << row) & 0xFF;
      for (wait=0; wait<10; ++wait)
         nop();
      tmp = (IOPIN & G_MASK) >> G_SHIFT;
    
      // See if any column is active (low):
      for (col=0; col<KEYP_NUM_COLS; ++col)
         if ((tmp & (1<<col)) == 0)
          { idx = (row*KEYP_NUM_COLS) + col;
            key = keycodes[idx]; 
            IOSET = idx << 16;
            IOCLR = (~(idx <<16)) & 0xFF0000;
            goto DONE;
          }
    }
   DONE:

   // Disable Port Drive and return.
   IODIR =  0xFF0700;
   return key;
 }



