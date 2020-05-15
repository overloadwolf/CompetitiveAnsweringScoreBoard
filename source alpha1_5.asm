;****** 中断源矢量表设置 **************************************************
	ORG	0000H		;复位入口
	LJMP	MAIN	;转到主程序

	ORG	0003H		;INT0矢量地址
	LJMP	RACE	;由开始抢答按钮引起的开始抢答阶段中断处理
	
	ORG 0013H 		;INT1矢量地址
	LJMP 	ADJ1	;由打开计分板按钮引起的查看计分板处理
	
	ORG	000BH		;T0中断入口
	LJMP	TT0		;转到T0中断服务程序

	ORG	001BH		;T1中断入口
	LJMP	TT1		;转到T1中断服务程序
;****** 主程序开始 **************************************************
	ORGH 0040h 		;主程序入口
MAIN:
	MOV SP,#0A0H	;设置堆栈指针
	MOV	20H,#0AH	;设置中断次数
	MOV	R7,#03H		;设置半秒标志
	
	MOV	30H,#00H	;分单元清0
	MOV	31H,#00H	;秒单元清0
	MOV	32H,#00H	;毫秒单元清0
	MOV	33H,#00H	;目标选手单元清0
	MOV	34H,#00H	;1号选手计分单元清0
	MOV	35H,#00H	;2号选手计分单元清0
	MOV	36H,#00H	;3号选手计分单元清0
	MOV	37H,#00H	;4号选手计分单元清0
	
	MOV	DPTR,#SEGTAB	;DPTR指向LED段码表首地址SEGTAB

	MOV	TMOD,#11H	;设置T0、T1工作方式都为1
	SETB	EX0		;允许INT0中断
	CLR	IT0		;设INT0用负边沿触发
	CLR	IT1		;设INT1用负边沿触发
	SETB	ET0		;允许T0中断
	SETB	ET1		;允许T1中断
	SETB	EA		;中断总控开启
	CLR P1

LOP: SJMP LOP
;****** 计时判定阶段开始 **************************************************
ADJ1:
	PUSH	PSW		;保护中断现场(PSW数据进栈)
	PUSH	ACC		;保护中断现场(ACC数据进栈)
	MOV R0,#34H		;将R0指针赋初值为1号选手
DIS1:
	MOV R1,@R0		;将目标位得分存入R1
	;显示选手x编号及分数-------------------
PREV1:
	JB	P3.4,NEXT1	;上一位键未按下,则转跳到判下一位键
	JNB	P3.4,$		;上一位键按下,则等待放开上一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	DEC A			;上一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	CJNE	A,#033H,DIS1	;防止R0指针溢出
	MOV R0,#37H
	SJMP	DIS1		;返回主程序
NEXT1:
	JB	P3.5,INC1	;下一位未按下,则转跳到判增量键
	JNB	P3.5,$		;下一位按下,则等待放开下一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	INC A			;下一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	CJNE	A,#038H,DIS1	;防止R0指针溢出
	MOV R0,#34H
	SJMP	DIS1		;返回主程序
INC1:
	JB	P3.6,DES1	;增量键未按下,则转跳到减量键
	JNB	P3.6,$		;增量键按下,则等待放开增量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	INC A			;分数加一
	DA	A			;十进制调整
	MOV @R0,A 		;存回分数
	CJNE	A,#064H,DIS1	;防止分数溢出
	MOV R0,#63H
	SJMP	DIS1		;返回主程序
DES1:
	JB	P3.7,BKTM	;减量键未按下,则转跳到返回键判定
	JNB	P3.7,$		;减量键按下,则等待放开减量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE	A,#00H,DIS1	;为0不处理直接跳转
	DEC A			;分数减一
	DA	A			;十进制调整
	MOV @R0,A 		;存回分数
	SJMP	DIS1		;返回主程序
BKTM:
	JB	P3.1,DIS1	;返回键未按下,则转跳到DIS1等待按键
	JNB	P3.1,$		;返回键按下，则等待放开返回键
	SJMP RETI1		;直接返回主程序
RETI1:
	POP	ACC		;恢复中断入口时现场ACC
	POP	PSW		;恢复中断入口时现场PSW
	RETI
;****** 计时抢答阶段开始 **************************************************
RACE:
	PUSH	PSW		;保护中断现场(PSW数据进栈)
	PUSH	ACC		;保护中断现场(ACC数据进栈)
	SETB TR0	;T0开始计时
LOP2:
	;显示时间
C1:	
	JB	P1.0,C2		;1号未按下,则转跳判2号
	MOV 33H,#01H	;选中1号选手
	MOV R0,#34H
	MOV P1,#02H 		;点亮1号灯
	LJMP ADJ2
C2:	
	JB	P1.2,C3		;2号未按下,则转跳判3号
	MOV 33H,#02H;	选中2号选手
	MOV R0,#35H
	MOV P1,#080H 	;点亮2号灯
	LJMP ADJ2
C3:	
	JB	P1.4,C4		;3号未按下,则转跳判4号
	MOV 33H,#03H	;选中3号选手
	MOV R0,#36H
	MOV P1,#020H 	;点亮3号灯
	LJMP ADJ2
C4:	
	JB	P1.6,LOP2	;4号未按下,跳回循环
	MOV 33H,#04H	;选中4号选手
	MOV R0,#37H
	MOV P1,#080H 	;点亮4号灯
	LJMP ADJ2
;****** 计时判定阶段开始 **************************************************
ADJ2:
	CLR TR0			;暂停T0计时
	;蜂鸣器响若干秒------------
DIS2:
	MOV R1,@R0		;将目标位得分存入R1
	;显示选手x编号及分数-------------------
PREV2:
	JB	P3.4,NEXT2	;上一位键未按下,则转跳到判下一位键
	JNB	P3.4,$		;上一位键按下,则等待放开上一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	DEC A			;上一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	CJNE	A,#033H,DIS2	;防止R0指针溢出
	MOV R0,#37H
	SJMP	DIS2		;返回DIS2等待按键
NEXT2:
	JB	P3.5,INC2	;下一位未按下,则转跳到判增量键
	JNB	P3.5,$		;下一位按下,则等待放开下一位键
	MOV	A,R0		;将当前选手编号,送到A寄存器
	INC A			;下一位
	DA	A			;十进制调整
	MOV R0,A 		;存回选手指针
	CJNE	A,#038H,DIS2	;防止R0指针溢出
	MOV R0,#34H
	SJMP	DIS2		;返回DIS2等待按键
INC2:
	JB	P3.6,DECC2	;增量键未按下,则转跳到减量键
	JNB	P3.6,$		;增量键按下,则等待放开增量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	INC A			;分数加一
	DA	A			;十进制调整
	MOV @R0,A 		;存回分数
	CJNE	A,#064H,RETI2	;防止分数溢出
	MOV R0,#63H
	SJMP	RETI2		;返回主程序
DES2:
	JB	P3.7,COTN	;减量键未按下,则转跳到继续计时判定
	JNB	P3.7,$		;减量键按下,则等待放开减量键
	MOV	A,@R0		;将当前选手分数,送到A寄存器
	CJNE A,#00H,RETI2 	;为0不处理直接跳转
	DEC A			;分数减一
	DA	A			;十进制调整
	MOV @R0,A 		;存回分数
	SJMP	RETI2		;返回主程序
COTN:
	JB	P3.0,BKTM	;继续计时键未按下,则转跳到返回键判定
	JNB	P3.0,$		;继续计时键按下，则等待放开继续计时键
	SETB TR0		;开启T0
	CLR P1			;重置P0输入
	LJMP LOP2		;继续进入等待回答阶段
BKTM:
	JB	P3.1,ADJ2	;返回键未按下,则转跳到ADJ2等待按键
	JNB	P3.1,$		;返回键按下，则等待放开返回键
	SJMP RETI2		;直接返回主程序
RETI2:
	;显示屏内容不变 亮若干秒--------------------
	MOV	30H,#00H	;分单元清0
	MOV	31H,#00H	;秒单元清0
	MOV	32H,#00H	;毫秒单元清0
	CLR P1		;灭灯
	POP	ACC		;恢复中断入口时现场ACC
	POP	PSW		;恢复中断入口时现场PSW
	RETI
;****** LED数码管段码表 **************************************************
	ORG 2000H		;段码表定位在2000H开始的内存处
SEGTAB1:	DB 00H,00H,00H,00H,050H,04CH,041H,059H,045H,052H,00H,00H,,00H,00H,00H,00H	;第一行段码表    player
	