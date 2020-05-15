/******************************************************************************            
************             LABCENTER ELECTRONICS                      ***********            
************	       Proteus VSM Sample Design Code                ***********		 	     
************	           IAR ARM 'C' Calculator                    ***********            
******************************************************************************/           
                                                                                            
typedef int  INT;                                                                           
typedef signed char INT8;
typedef signed int  INT16;
typedef signed long INT32;
typedef unsigned short WORD;                                                                
typedef char CHAR;                                                                          
typedef unsigned char BYTE;                                                                 
typedef double FLOAT;                                                                                                                                              
typedef long LONG;                                                                          
typedef INT8 BOOL;
                                                                                            
//Display Config.
#define MAX_DISPLAY_CHAR 10    

// Keypad Config.
#define KEYP_NUM_ROWS 4
#define KEYP_NUM_COLS 4

//LCD Registers addresses (PORT D)
#define LCD_CMD_WR	   0x0000
#define LCD_DATA_WR	   0x0100
#define LCD_BUSY_RD	   0x0200
#define LCD_DATA_RD	   0x0300

#define E_PIN_MASK     0x0400
                     
//LCD Commands        
#define LCD_CLS		   0x01
#define LCD_HOME	   0x02
#define LCD_SETMODE	   0x04
#define LCD_SETVISIBLE 0x08
#define LCD_SHIFT	   0x10
#define LCD_SETFUNCTION	   0x20
#define LCD_SETCGADDR	   0x40
#define LCD_SETDDADDR	   0x80


#define G_MASK  0x78000000
#define G_SHIFT 27
#define nop() {__asm("nop");}

#define FALSE 0
#define TRUE  1                                                       
                                                                                            
//Error handling status.                                                                    
enum ERROR { OK = 0, SLEEP = 1, ERROR = 2};                                                 
                                                                                               
/************************************************************************                   
***** FUNCTION PROTOTYPES *****                                                             
******************************/                                                             
void init_system(void);
void calc_evaluate(void);                                                                       
CHAR calc_getkey (void);                                                                    
void calc_format (FLOAT f);
void calc_display (CHAR *buf);                                             
                                                                                            
//Operator Indirect function.                                                               
void calc_opfunctions (CHAR token);                                                         
                                                                                            
//Utility functions.                                                                        
BOOL  calc_testkey  (CHAR ch);                                                              
void  calc_output   (INT status);                                                           

// Keypad Functions.
CHAR keypadread(void); 
CHAR scankeypad(void);

void lcd_init(void);
void lcd_wait(void);
void wrcmd (BYTE data);
void wrdata(BYTE data);
void clearscreen(void);
                                                                                            
