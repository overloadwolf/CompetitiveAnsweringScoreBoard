	COM EQU 50H ; LCDָ��Ĵ���
DAT EQU 51H ; LCD���ݼĴ���

RS EQU P2.0 ; LCD�Ĵ���ѡ���ź�
RW EQU P2.1 ; LCD��/дѡ���ź�
E EQU P2.2  ; LCDʹ���ź�
;****** �ж�Դʸ�������� **************************************************
	ORG	0000H		;��λ���
	LJMP	MAIN	;ת��������
	ORG	0003H		;INT0ʸ����ַ
	LJMP 	ADJ1	;�ɴ򿪼Ʒְ尴ť����Ĳ鿴�Ʒְ崦��
	ORG	000BH		;T0�ж����
	LJMP	TT0		;ת��T0�жϷ������
	ORG 0013H 		;INT1ʸ����ַ
	LJMP	RACE	;�ɿ�ʼ����ť����Ŀ�ʼ����׶��жϴ���
	ORG 0040h 		;���������
MAIN:	
	MOV SP,#60H	;���ö�ջָ��
	MOV	20H,#0AH	;�����жϴ���
	MOV	30H,#00H	;�ֵ�Ԫ��0
	MOV	31H,#00H	;�뵥Ԫ��0
	MOV	32H,#00H	;���뵥Ԫ��0
	MOV	33H,#00H	;Ŀ��ѡ�ֵ�Ԫ��0
	MOV	34H,#00H	;1��ѡ�ּƷֵ�Ԫ��0
	MOV	35H,#00H	;2��ѡ�ּƷֵ�Ԫ��0
	MOV	36H,#00H	;3��ѡ�ּƷֵ�Ԫ��0
	MOV	37H,#00H	;4��ѡ�ּƷֵ�Ԫ��0
	MOV 38H,#00H	;ѭ�����Ʊ���
	SETB	EX0		;����INT0�ж�
	SETB	EX1		;����INT0�ж�
	SETB 	ET0		;����T0�ж�
	SETB	PT0
	CLR	IT0		;��INT0�ø����ش���
	CLR	IT1		;��INT1�ø����ش���
	MOV P0,#00H
	MOV P2,#00H
	MOV P1,#055H	;P1����ֵ
	SETB	EA		;�ж��ܿؿ���
	LCALL INT       ;��LCD��ӿ��Ʒ�ʽ�µĳ�ʼ���ӳ���
	ACALL WRIN0
LOP:
	SJMP $
;****** �Ʒְ�׶ο�ʼ **************************************************
ADJ1:
	PUSH	PSW		;�����ж��ֳ�(PSW���ݽ�ջ)
	PUSH	ACC		;�����ж��ֳ�(ACC���ݽ�ջ)
	MOV R0,#34H
	MOV 33H,#031H
DIS1:
	MOV A,@R0		
	MOV R1,A
	LCALL DIS_PLAYER
LOP1:
PREV1:
	JB	P3.4,NEXT1	;��һλ��δ����,��ת��������һλ��
	JNB	P3.4,$		;��һλ������,��ȴ��ſ���һλ��
	MOV	A,R0		;����ǰѡ�ֱ��,�͵�A�Ĵ���
	DEC A			;��һλ
	DA	A			;ʮ���Ƶ���
	MOV R0,A 		;���ѡ��ָ��
	DEC 33H
	CJNE	A,#033H,DIS1	;��ֹR0ָ�����
	MOV 33H,#034H
	MOV R0,#037H
	SJMP	DIS1		;����������
NEXT1:
	JB	P3.5,INC1	;��һλδ����,��ת������������
	JNB	P3.5,$		;��һλ����,��ȴ��ſ���һλ��
	MOV	A,R0		;����ǰѡ�ֱ��,�͵�A�Ĵ���
	INC A			;��һλ
	DA	A			;ʮ���Ƶ���
	MOV R0,A 		;���ѡ��ָ��
	INC 33H
	CJNE	A,#038H,DIS1	;��ֹR0ָ�����
	MOV R0,#034H
	MOV 33H,#031H
	SJMP	DIS1		;����������
INC1:
	JB	P3.6,DES1	;������δ����,��ת����������
	JNB	P3.6,$		;����������,��ȴ��ſ�������
	MOV	A,@R0		;����ǰѡ�ַ���,�͵�A�Ĵ���
	CJNE A,#063H,TEMP0	;Ϊ0������ֱ����ת
	SJMP	DIS1		;����������
TEMP0:
	INC A			;������һ
	MOV @R0,A 		;��ط���
	SJMP	DIS1		;����������
DES1:
	JB	P3.7,BKTM	;������δ����,��ת�������ؼ��ж�
	JNB	P3.7,$		;����������,��ȴ��ſ�������
	MOV	A,@R0		;����ǰѡ�ַ���,�͵�A�Ĵ���
	CJNE A,#00H,TEMP1	;Ϊ0������ֱ����ת
	SJMP	DIS1		;����������
TEMP1:
	DEC A			;������һ
	MOV @R0,A 		;��ط���
	SJMP	DIS1		;����������
BKTM:
	JB	P3.1,LOP1	;���ؼ�δ����,��ת����LOP1�ȴ�����
	JNB	P3.1,$		;���ؼ����£���ȴ��ſ����ؼ�
	SJMP RETI1		;ֱ�ӷ���������
RETI1:
	POP	ACC		;�ָ��ж����ʱ�ֳ�ACC
	POP	PSW		;�ָ��ж����ʱ�ֳ�PSW
	MOV P1,#055H
	ACALL WRIN0		;����
	RETI
;****** ��ʱ����׶ο�ʼ **************************************************
RACE:
	PUSH	PSW		;�����ж��ֳ�(PSW���ݽ�ջ)
	PUSH	ACC		;�����ж��ֳ�(ACC���ݽ�ջ)
	MOV	30H,#00H	;�ֵ�Ԫ��0
	MOV	31H,#00H	;�뵥Ԫ��0
	MOV	32H,#00H	;���뵥Ԫ��0
CONTINUE:
	MOV TMOD,#01H		;���ö�ʱ��ģʽ
	MOV TL0,#0AEH		;���ö�ʱ��ֵ
	MOV TH0,#0FBH		;���ö�ʱ��ֵ
	SETB TR0	;T0��ʼ��ʱ
	MOV P1,#055H	;P1����ֵ
	LCALL DIS_TIME_1
LOP2:
	LCALL DIS_TIME_2
C1:	
	JB	P1.0,C2		;1��δ����,��ת����2��
	MOV 33H,#031H	;ѡ��1��ѡ��
	MOV R0,#34H
	LJMP ADJ2
C2:	
	JB	P1.2,C3		;2��δ����,��ת����3��
	MOV 33H,#032H;	ѡ��2��ѡ��
	MOV R0,#35H
	LJMP ADJ2
C3:	
	JB	P1.4,C4		;3��δ����,��ת����4��
	MOV 33H,#033H	;ѡ��3��ѡ��
	MOV R0,#36H
	LJMP ADJ2
C4:	
	JB	P1.6,LOP2	;4��δ����
	MOV 33H,#034H	;ѡ��4��ѡ��
	MOV R0,#37H
	LJMP ADJ2
;****** ��ʱ�ж��׶ο�ʼ **************************************************
ADJ2:
	CLR TR0			;��ͣT0��ʱ
	ACALL DIS_PLAYER
;****** �������� **************************************************
	SETB P2.3                          
	ACALL DELAY1000MS
;****** �������� **************************************************
	CLR P2.3
DIS2:
	ACALL DIS_PLAYER
PREV2:
	JB	P3.4,NEXT2	;��һλ��δ����,��ת��������һλ��
	JNB	P3.4,$		;��һλ������,��ȴ��ſ���һλ��
	MOV	A,R0		;����ǰѡ�ֱ��,�͵�A�Ĵ���
	DEC A			;��һλ
	DA	A			;ʮ���Ƶ���
	MOV R0,A 		;���ѡ��ָ��
	DEC 33H
	CJNE A,#033H,DIS2	;��ֹR0ָ�����
	MOV R0,#37H
	MOV 33H,#034H
	SJMP DIS2		;����DIS2�ȴ�����
NEXT2:
	JB	P3.5,INC2	;��һλδ����,��ת������������
	JNB	P3.5,$		;��һλ����,��ȴ��ſ���һλ��
	MOV	A,R0		;����ǰѡ�ֱ��,�͵�A�Ĵ���
	INC A			;��һλ
	DA	A			;ʮ���Ƶ���
	MOV R0,A 		;���ѡ��ָ��
	INC 33H
	CJNE	A,#038H,DIS2	;��ֹR0ָ�����
	MOV R0,#34H
	MOV 33H,#031H
	SJMP DIS2		;����DIS2�ȴ�����
INC2:
	JB	P3.6,DES2	;������δ����,��ת����������
	JNB	P3.6,$		;����������,��ȴ��ſ�������
	MOV	A,@R0		;����ǰѡ�ַ���,�͵�A�Ĵ���
	CJNE A,#063H,TEMP3 	;Ϊ0������ֱ����ת
	SJMP RETI2
TEMP3:
	INC A			;������һ
	MOV @R0,A 		;��ط���
	SJMP RETI2		;����������
DES2:
	JB	P3.7,COTN	;������δ����,��ת����������ʱ�ж�
	JNB	P3.7,$		;����������,��ȴ��ſ�������
	MOV	A,@R0		;����ǰѡ�ַ���,�͵�A�Ĵ���
	CJNE A,#00H,TEMP2 	;Ϊ0������ֱ����ת
	SJMP RETI2
TEMP2:
	DEC A			;������һ
	MOV @R0,A 		;��ط���
	SJMP RETI2		;����������
COTN:
	JB	P3.0,BK		;������ʱ��δ����,��ת�������ؼ��ж�
	JNB	P3.0,$		;������ʱ�����£���ȴ��ſ�������ʱ��
	SETB TR0		;����T0
	MOV P1,#055H		;����P0����
	LJMP CONTINUE	;��������ȴ��ش�׶�
BK:
	JB	P3.1,PREV2	;���ؼ�δ����,��ת����ADJ2�ȴ�����
	JNB	P3.1,$		;���ؼ����£���ȴ��ſ����ؼ�
	SJMP RETI2		;ֱ�ӷ���������
RETI2:
	POP ACC
	POP PSW
	ACALL DIS_PLAYER
	ACALL DELAY1000MS
	ACALL WRIN0		;����
	MOV P1,#055H
	RETI

TT0:
	PUSH	PSW		;�����ж��ֳ�(PSW���ݽ�ջ)
	PUSH	ACC		;�����ж��ֳ�(ACC���ݽ�ջ)
	MOV	 TH0,#0FBH	;����װ��T0��ֵ��λ
	MOV	 TL0,#0AEH	;����װ��T0��ֵ��λ
	DJNZ 20H,TT0_RT ;10ms��ʱδ��������   
	MOV 20H,#0AH	;��װ�жϴ���
	MOV A,#01H
	ADD A,32H   ;����ֵ��1	
	;DA	 A		    ;ʮ���Ƶ���
   	MOV  32H,A		;����ֵ���32H��Ԫ
	CJNE A,#064H,TT0_RT	;����ֵδ��1000,�������жϳ���
	MOV  32H,#00H	;����ֵ�ѵ�1000,�����ֵ��Ԫ��0

	MOV  A,31H		;ȡ31H��Ԫ����ֵ
	INC  A			;�뵥Ԫ��1
	MOV	 31H,A		;��ֵ���31H��Ԫ
   	CJNE A,#03CH,TT0_RT	;��ֵδ��60,�������жϳ���
	MOV  31H,#00H	;��ֵ�ѵ�60,����ֵ��Ԫ��0

	MOV  A,30H		;ȡ30H��Ԫ�ķ�ֵ
	INC  A			;�ֵ�Ԫ��1
	MOV	 30H,A		;��ֵ���30H��Ԫ
	CJNE A,#03CH,TT0_RT	;��ֵδ��60,�������жϳ���
	MOV	 30H,#00H	;��ֵ�ѵ�60,���ֵ��Ԫ��0
TT0_RT:
	POP	ACC		;�ָ��ж����ʱ�ֳ�ACC
    POP	PSW		;�ָ��ж����ʱ�ֳ�PSW
	RETI
;*****LCD1206 **************************************************
;æ��־�ж��ӳ���
INT: 	LCALL DELAY ; ����ʱ�ӳ���
		MOV P0,#38H ; ������ʽ����ָ�����
		CLR RS      ; RS=0
		CLR RW      ; R/W=0
		MOV R2,#03  ; ѭ����=3
INTT1: 	SETB E ; E=1
		CLR E         ; E=0
		DJNZ R2,INTT1
		MOV P0,#38H ; ���ù�����ʽ*
		SETB E      ; E=1
		CLR E       ; E=0
		MOV COM,#38H ; ���ù�����ʽ 
		LCALL PR1
		MOV COM,#01H ; ����
		LCALL PR1
		MOV COM,#06H ; �������뷽ʽ
		LCALL PR1
		MOV COM,#0EH ; ������ʾ��ʽ
		LCALL PR1
		RET

DELAY:	MOV R6,#0FH ; ��ʱ�ӳ���
DELAY2:	MOV R7,#10H
DELAY1: NOP
		DJNZ R7,DELAY1
		DJNZ R6,DELAY2
		RET
 
;LCD ��ӿ��Ʒ�ʽ�������ӳ�������

;1 ��BF��ACֵ
PR0: 	PUSH ACC
	    MOV P0,#0FFH ; P0��λ, ׼����
	    CLR RS       ; RS=0
	    SETB RW      ; R/W=1
	    SETB E       ; E=1
	    LCALL DELAY
	    MOV COM,P0   ; ��BF��AC6-4ֵ
	    CLR E        ; E=0
	    POP ACC
	    RET

;2 дָ������ӳ���
PR1: 	PUSH ACC
	    CLR RS    ; RS=0
	    SETB RW   ; R/W=1
PR11:	MOV P0,#0FFH; P0��λ, ׼����
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

;3 д��ʾ�����ӳ���
PR2:	PUSH ACC
    	CLR RS    ; RS=0
    	SETB RW   ; R/W=1
PR21:	MOV P0,#0FFH
    	SETB E    ; E=1
    	LCALL DELAY
    	MOV A,P0  ; ��BF��AC6-4ֵ
    	CLR E     ; E=0
    	JB ACC.7,PR21
    	SETB RS
    	CLR RW
    	MOV P0,DAT; д�����ݸ�4λ
    	SETB E    ; RS=1  
    	CLR E     ; R/W=0
    	POP ACC
    	RET
;****** ���� **************************************************
WRIN0:
	MOV COM,#01H  ;LCd��0����
   	LCALL PR1     ;��дָ������ӳ���
   	MOV COM,#06H  ;���뷽ʽ����������
   	LCALL PR1     ;��дָ������ӳ���
	MOV COM,#08H  ;����ʾ��
	LCALL PR1  	  ;��дָ������ӳ���
	RET
;****** ��ʱ���� **************************************************	
DIS_TIME_1:
	MOV COM,#01H  ;LCd��0����
   	LCALL PR1     ;��дָ������ӳ���
   	MOV COM,#06H  ;���뷽ʽ����������
   	LCALL PR1     ;��дָ������ӳ���
	MOV COM,#0CH  ;�رչ��
	LCALL PR1	  ;��дָ������ӳ���
   	MOV COM,#080H ;����DDRAM��ַ
   	LCALL PR1     ;��дָ������ӳ���
    MOV DPTR,#TAB1 ;DPTRָ����ʾ�ַ����׵�ַ
   	MOV R2,#10H	  ;����ʾ16�ַ�
	MOV R3,#00H
WRIN1:
	MOV A,R3
	MOVC A,@A+DPTR ;ȡ����ʾ�ַ�
	MOV DAT,A
   	LCALL PR2     ;��д��ʾ�����ӳ���
	INC R3
   	DJNZ R2,WRIN1
	RET

DIS_TIME_2:
	MOV COM,#0C4H ;����DDRAM��ַ
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
;****** ѡ����Ļ **************************************************	
DIS_PLAYER:
CK1:
	CJNE R0,#034H,CK2
	MOV P1,#057H 		;����1�ŵ�
	MOV R5,34H
CK2:
	CJNE R0,#035H,CK3
	MOV P1,#05DH 	;����2�ŵ�
	MOV R5,35H
CK3:

	CJNE R0,#036H,CK4
	MOV P1,#075H 	;����3�ŵ�
	MOV R5,36H
CK4:
	CJNE R0,#037H,CK5
	MOV P1,#0D5H 	;����4�ŵ�
	MOV R5,37H
CK5:
	MOV COM,#01H  ;LCd��0����
   	LCALL PR1     ;��дָ������ӳ���
   	MOV COM,#06H  ;���뷽ʽ����������
   	LCALL PR1     ;��дָ������ӳ���
	MOV COM,#0CH  ;�رչ��
	LCALL PR1	  ;��дָ������ӳ���
   	MOV COM,#080H ;����DDRAM��ַ
   	LCALL PR1     ;��дָ������ӳ���
    MOV DPTR,#TAB2 ;DPTRָ����ʾ�ַ����׵�ַ
   	MOV R2,#10H	  ;����ʾ16�ַ�
   	MOV R3,#00H
WRIN2:	
	MOV A,R3
	CJNE R3,#0BH,WORKON2
	MOV A,33H
	MOV DAT,A
   	LCALL PR2     ;��д��ʾ�����ӳ���
   	INC R3
   	DJNZ R2,WRIN2
WORKON2: 
	MOVC A,@A+DPTR ;ȡ����ʾ�ַ�
   	MOV DAT,A
   	LCALL PR2     ;��д��ʾ�����ӳ���
   	INC R3
   	DJNZ R2,WRIN2 
WRIN_SCORE:
	MOV DPTR,#SEGTAB ;DPTRָ����ʾ�ַ����׵�ַ
	MOV COM,#0C7H ;����DDRAM��ַ
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
;****** LED����ܶ���� **************************************************
TAB1:	DB "  PRESS BUTTON  "
TAB2: 	DB "    PLAYER      "
SEGTAB: DB "0123456789"
	END	;�����������