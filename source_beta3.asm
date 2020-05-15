	COM EQU 50H ; LCD指令寄存器
DAT EQU 51H ; LCD数据寄存器

RS EQU P2.0 ; LCD寄存器选择信号
RW EQU P2.1 ; LCD读/写选择信号
E EQU P2.2  ; LCD使能信号
;****** 中断源矢量表设置 **************************************************
	ORG	0000H		;复位入口
	LJMP	MAIN	;转到主程序
	ORG	0003H		;INT0矢量地址
	LJMP 	ADJ1	;由打开计分板按钮引起的查看计分板处理
	ORG	000BH		;T0中断入口
	LJMP	TT0		;转到T0中断服务程序
	ORG 0013H 		;INT1矢量地址
	LJMP	RACE	;由开始抢答按钮引起的开始抢答阶段中断处理
	ORG 0040h 		;主程序入口
MAIN:	
	MOV SP,#60H	;设置堆栈指针
	MOV	20H,#0AH	;设置中断次数
	MOV	30H,#00H	;分单元清0
	MOV	31H,#00H	;秒单元清0
	MOV	32H,#00H	;毫秒单元清0
	MOV	33H,#00H	;目标选手单元清0
	MOV	34H,#00H	;1号选手计分单元清0
	MOV	35H,#00H	;2号选手计分单元清0
	MOV	36H,#00H	;3号选手计分单元清0
	MOV	37H,#00H	;4号选手计分单元清0
	MOV 38H,#00H	;循环控制变量
	SETB	EX0		;允许INT0中断
	SETB	EX1		;允许INT0中断
	SETB 	ET0		;允许T0中断
	SETB	PT0
	CLR	IT0		;设INT0用负边沿触发
	CLR	IT1		;设INT1用负边沿触发
	MOV P0,#00H
	MOV P2,#00H
	MOV P1,#055H	;P1赋初值
	SETB	EA		;中断总控开启
	LCALL INT       ;调LCD间接控制方式下的初始化子程序
	ACALL WRIN0
LOP:
	SJMP $
;****** 计分板阶段开始 **************************************************
ADJ1:
	PUSH	PSW		;保护中断现场(PSW数据进栈)
	PUSH	ACC		;保护中断现场(ACC数据进栈)
	MOV R0,#34H
	MOV 33H,#031H
DIS1:
	MOV A,@R0		
	MOV R1,A
	LCALL DIS_PLAYER
LOP1:
PREV1:
	JB	P3.4,NEXT1	;上一位键未按下,则转跳到判下一位键
	JNB	P3.4,$		;上一位键按下,则等待放开上一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	DEC A			;上一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	DEC 33H
	CJNE	A,#033H,DIS1	;防止R0指针溢出
	MOV 33H,#034H
	MOV R0,#037H
	SJMP	DIS1		;返回主程序
NEXT1:
	JB	P3.5,INC1	;下一位未按下,则转跳到判增量键
	JNB	P3.5,$		;下一位按下,则等待放开下一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	INC A			;下一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	INC 33H
	CJNE	A,#038H,DIS1	;防止R0指针溢出
	MOV R0,#034H
	MOV 33H,#031H
	SJMP	DIS1		;返回主程序
INC1:
	JB	P3.6,DES1	;增量键未按下,则转跳到减量键
	JNB	P3.6,$		;增量键按下,则等待放开增量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE A,#063H,TEMP0	;为0不处理直接跳转
	SJMP	DIS1		;返回主程序
TEMP0:
	INC A			;分数减一
	MOV @R0,A 		;存回分数
	SJMP	DIS1		;返回主程序
DES1:
	JB	P3.7,BKTM	;减量键未按下,则转跳到返回键判定
	JNB	P3.7,$		;减量键按下,则等待放开减量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE A,#00H,TEMP1	;为0不处理直接跳转
	SJMP	DIS1		;返回主程序
TEMP1:
	DEC A			;分数减一
	MOV @R0,A 		;存回分数
	SJMP	DIS1		;返回主程序
BKTM:
	JB	P3.1,LOP1	;返回键未按下,则转跳到LOP1等待按键
	JNB	P3.1,$		;返回键按下，则等待放开返回键
	SJMP RETI1		;直接返回主程序
RETI1:
	POP	ACC		;恢复中断入口时现场ACC
	POP	PSW		;恢复中断入口时现场PSW
	MOV P1,#055H
	ACALL WRIN0		;清屏
	RETI
;****** 计时抢答阶段开始 **************************************************
RACE:
	PUSH	PSW		;保护中断现场(PSW数据进栈)
	PUSH	ACC		;保护中断现场(ACC数据进栈)
	MOV	30H,#00H	;分单元清0
	MOV	31H,#00H	;秒单元清0
	MOV	32H,#00H	;毫秒单元清0
CONTINUE:
	MOV TMOD,#01H		;设置定时器模式
	MOV TL0,#0AEH		;设置定时初值
	MOV TH0,#0FBH		;设置定时初值
	SETB TR0	;T0开始计时
	MOV P1,#055H	;P1赋初值
	LCALL DIS_TIME_1
LOP2:
	LCALL DIS_TIME_2
C1:	
	JB	P1.0,C2		;1号未按下,则转跳判2号
	MOV 33H,#031H	;选中1号选手
	MOV R0,#34H
	LJMP ADJ2
C2:	
	JB	P1.2,C3		;2号未按下,则转跳判3号
	MOV 33H,#032H;	选中2号选手
	MOV R0,#35H
	LJMP ADJ2
C3:	
	JB	P1.4,C4		;3号未按下,则转跳判4号
	MOV 33H,#033H	;选中3号选手
	MOV R0,#36H
	LJMP ADJ2
C4:	
	JB	P1.6,LOP2	;4号未按下
	MOV 33H,#034H	;选中4号选手
	MOV R0,#37H
	LJMP ADJ2
;****** 计时判定阶段开始 **************************************************
ADJ2:
	CLR TR0			;暂停T0计时
	ACALL DIS_PLAYER
;****** 蜂鸣器响 **************************************************
	SETB P2.3                          
	ACALL DELAY1000MS
;****** 蜂鸣器响 **************************************************
	CLR P2.3
DIS2:
	ACALL DIS_PLAYER
PREV2:
	JB	P3.4,NEXT2	;上一位键未按下,则转跳到判下一位键
	JNB	P3.4,$		;上一位键按下,则等待放开上一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	DEC A			;上一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	DEC 33H
	CJNE A,#033H,DIS2	;防止R0指针溢出
	MOV R0,#37H
	MOV 33H,#034H
	SJMP DIS2		;返回DIS2等待按键
NEXT2:
	JB	P3.5,INC2	;下一位未按下,则转跳到判增量键
	JNB	P3.5,$		;下一位按下,则等待放开下一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	INC A			;下一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	INC 33H
	CJNE	A,#038H,DIS2	;防止R0指针溢出
	MOV R0,#34H
	MOV 33H,#031H
	SJMP DIS2		;返回DIS2等待按键
INC2:
	JB	P3.6,DES2	;增量键未按下,则转跳到减量键
	JNB	P3.6,$		;增量键按下,则等待放开增量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE A,#063H,TEMP3 	;为0不处理直接跳转
	SJMP RETI2
TEMP3:
	INC A			;分数减一
	MOV @R0,A 		;存回分数
	SJMP RETI2		;返回主程序
DES2:
	JB	P3.7,COTN	;减量键未按下,则转跳到继续计时判定
	JNB	P3.7,$		;减量键按下,则等待放开减量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE A,#00H,TEMP2 	;为0不处理直接跳转
	SJMP RETI2
TEMP2:
	DEC A			;分数减一
	MOV @R0,A 		;存回分数
	SJMP RETI2		;返回主程序
COTN:
	JB	P3.0,BK		;继续计时键未按下,则转跳到返回键判定
	JNB	P3.0,$		;继续计时键按下，则等待放开继续计时键
	SETB TR0		;开启T0
	MOV P1,#055H		;重置P0输入
	LJMP CONTINUE	;继续进入等待回答阶段
BK:
	JB	P3.1,PREV2	;返回键未按下,则转跳到ADJ2等待按键
	JNB	P3.1,$		;返回键按下，则等待放开返回键
	SJMP RETI2		;直接返回主程序
RETI2:
	POP ACC
	POP PSW
	ACALL DIS_PLAYER
	ACALL DELAY1000MS
	ACALL WRIN0		;清屏
	MOV P1,#055H
	RETI

TT0:
	PUSH	PSW		;保护中断现场(PSW数据进栈)
	PUSH	ACC		;保护中断现场(ACC数据进栈)
	MOV	 TH0,#0FBH	;重新装入T0初值高位
	MOV	 TL0,#0AEH	;重新装入T0初值低位
	DJNZ 20H,TT0_RT ;10ms定时未到，返回   
	MOV 20H,#0AH	;重装中断次数
	MOV A,#01H
	ADD A,32H   ;毫秒值加1	
	;DA	 A		    ;十进制调整
   	MOV  32H,A		;毫秒值存回32H单元
	CJNE A,#064H,TT0_RT	;毫秒值未到1000,则跳至中断出口
	MOV  32H,#00H	;毫秒值已到1000,则毫秒值单元清0

	MOV  A,31H		;取31H单元的秒值
	INC  A			;秒单元加1
	MOV	 31H,A		;秒值存回31H单元
   	CJNE A,#03CH,TT0_RT	;秒值未到60,则跳至中断出口
	MOV  31H,#00H	;秒值已到60,则秒值单元清0

	MOV  A,30H		;取30H单元的分值
	INC  A			;分单元加1
	MOV	 30H,A		;分值存回30H单元
	CJNE A,#03CH,TT0_RT	;分值未到60,则跳至中断出口
	MOV	 30H,#00H	;分值已到60,则分值单元清0
TT0_RT:
	POP	ACC		;恢复中断入口时现场ACC
    POP	PSW		;恢复中断入口时现场PSW
	RETI
;*****LCD1206 **************************************************
;忙标志判断子程序
INT: 	LCALL DELAY ; 调延时子程序
		MOV P0,#38H ; 工作方式设置指令代码
		CLR RS      ; RS=0
		CLR RW      ; R/W=0
		MOV R2,#03  ; 循环量=3
INTT1: 	SETB E ; E=1
		CLR E         ; E=0
		DJNZ R2,INTT1
		MOV P0,#38H ; 设置工作方式*
		SETB E      ; E=1
		CLR E       ; E=0
		MOV COM,#38H ; 设置工作方式 
		LCALL PR1
		MOV COM,#01H ; 清屏
		LCALL PR1
		MOV COM,#06H ; 设置输入方式
		LCALL PR1
		MOV COM,#0EH ; 设置显示方式
		LCALL PR1
		RET

DELAY:	MOV R6,#0FH ; 延时子程序
DELAY2:	MOV R7,#10H
DELAY1: NOP
		DJNZ R7,DELAY1
		DJNZ R6,DELAY2
		RET
 
;LCD 间接控制方式的驱动子程序如下

;1 读BF和AC值
PR0: 	PUSH ACC
	    MOV P0,#0FFH ; P0置位, 准备读
	    CLR RS       ; RS=0
	    SETB RW      ; R/W=1
	    SETB E       ; E=1
	    LCALL DELAY
	    MOV COM,P0   ; 读BF和AC6-4值
	    CLR E        ; E=0
	    POP ACC
	    RET

;2 写指令代码子程序
PR1: 	PUSH ACC
	    CLR RS    ; RS=0
	    SETB RW   ; R/W=1
PR11:	MOV P0,#0FFH; P0置位, 准备读
	    SETB E    ; E=1
	    LCALL DELAY
	    NOP
	    MOV A,P0
	    CLR E
	    JB ACC.7,PR11;BF=1?
	    CLR RW    ; R/W=0
	    MOV P0,COM
	    SETB E    ; E=1
	    CLR E     ; E=0; E=0
	    POP ACC
	    RET

;3 写显示数据子程序
PR2:	PUSH ACC
    	CLR RS    ; RS=0
    	SETB RW   ; R/W=1
PR21:	MOV P0,#0FFH
    	SETB E    ; E=1
    	LCALL DELAY
    	MOV A,P0  ; 读BF和AC6-4值
    	CLR E     ; E=0
    	JB ACC.7,PR21
    	SETB RS
    	CLR RW
    	MOV P0,DAT; 写入数据高4位
    	SETB E    ; RS=1  
    	CLR E     ; R/W=0
    	POP ACC
    	RET
;****** 清屏 **************************************************
WRIN0:
	MOV COM,#01H  ;LCd清0命令
   	LCALL PR1     ;调写指令代码子程序
   	MOV COM,#06H  ;输入方式命令，光标右移
   	LCALL PR1     ;调写指令代码子程序
	MOV COM,#08H  ;关显示屏
	LCALL PR1  	  ;调写指令代码子程序
	RET
;****** 计时抢答 **************************************************	
DIS_TIME_1:
	MOV COM,#01H  ;LCd清0命令
   	LCALL PR1     ;调写指令代码子程序
   	MOV COM,#06H  ;输入方式命令，光标右移
   	LCALL PR1     ;调写指令代码子程序
	MOV COM,#0CH  ;关闭光标
	LCALL PR1	  ;调写指令代码子程序
   	MOV COM,#080H ;设置DDRAM地址
   	LCALL PR1     ;调写指令代码子程序
    MOV DPTR,#TAB1 ;DPTR指向显示字符表首地址
   	MOV R2,#10H	  ;共显示16字符
	MOV R3,#00H
WRIN1:
	MOV A,R3
	MOVC A,@A+DPTR ;取出显示字符
	MOV DAT,A
   	LCALL PR2     ;调写显示数据子程序
	INC R3
   	DJNZ R2,WRIN1
	RET

DIS_TIME_2:
	MOV COM,#0C4H ;设置DDRAM地址
	LCALL PR1
	MOV DPTR,#SEGTAB
	MOV A,30H
	ACALL DIS_BIO
	MOV DAT,#03AH
	LCALL PR2
	MOV A,31H
	ACALL DIS_BIO
	MOV DAT,#03AH
	LCALL PR2
	MOV A,32H
	ACALL DIS_BIO
	RET
;****** 选手屏幕 **************************************************	
DIS_PLAYER:
CK1:
	CJNE R0,#034H,CK2
	MOV P1,#057H 		;点亮1号灯
	MOV R5,34H
CK2:
	CJNE R0,#035H,CK3
	MOV P1,#05DH 	;点亮2号灯
	MOV R5,35H
CK3:

	CJNE R0,#036H,CK4
	MOV P1,#075H 	;点亮3号灯
	MOV R5,36H
CK4:
	CJNE R0,#037H,CK5
	MOV P1,#0D5H 	;点亮4号灯
	MOV R5,37H
CK5:
	MOV COM,#01H  ;LCd清0命令
   	LCALL PR1     ;调写指令代码子程序
   	MOV COM,#06H  ;输入方式命令，光标右移
   	LCALL PR1     ;调写指令代码子程序
	MOV COM,#0CH  ;关闭光标
	LCALL PR1	  ;调写指令代码子程序
   	MOV COM,#080H ;设置DDRAM地址
   	LCALL PR1     ;调写指令代码子程序
    MOV DPTR,#TAB2 ;DPTR指向显示字符表首地址
   	MOV R2,#10H	  ;共显示16字符
   	MOV R3,#00H
WRIN2:	
	MOV A,R3
	CJNE R3,#0BH,WORKON2
	MOV A,33H
	MOV DAT,A
   	LCALL PR2     ;调写显示数据子程序
   	INC R3
   	DJNZ R2,WRIN2
WORKON2: 
	MOVC A,@A+DPTR ;取出显示字符
   	MOV DAT,A
   	LCALL PR2     ;调写显示数据子程序
   	INC R3
   	DJNZ R2,WRIN2 
WRIN_SCORE:
	MOV DPTR,#SEGTAB ;DPTR指向显示字符表首地址
	MOV COM,#0C7H ;设置DDRAM地址
	LCALL PR1
	MOV A,R5
	ACALL DIS_BIO
	RET
	
DELAY500MS:
	PUSH 40H
	PUSH 41H
	PUSH 42H
	MOV 40H,#17
	MOV 41H,#208
	MOV 42H,#23
BEEP_DELAY:
	DJNZ 42H,BEEP_DELAY
	DJNZ 41H,BEEP_DELAY
	DJNZ 40H,BEEP_DELAY
	POP 40H
	POP 41H
	POP 42H
	RET
DELAY1000MS:			;@12.000MHz
	PUSH 30H
	PUSH 31H	
	PUSH 32H
	MOV 30H,#34
	MOV 31H,#159
	MOV 32H,#55
DIS_DELAY:
	DJNZ 32H,DIS_DELAY
	DJNZ 31H,DIS_DELAY
	DJNZ 30H,DIS_DELAY
	POP 32H
	POP 31H
	POP 30H
	RET
DIS_BIO:
	MOV B,#0AH
	DIV AB
	DA A
	MOVC A,@A+DPTR
	MOV DAT,A
	LCALL PR2
	MOV A,B
	MOVC A,@A+DPTR
	MOV DAT,A
	LCALL PR2
	RET
;****** LED数码管段码表 **************************************************
TAB1:	DB "  PRESS BUTTON  "
TAB2: 	DB "    PLAYER      "
SEGTAB: DB "0123456789"
	END	;整个程序结束