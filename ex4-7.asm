	ORG 0000H          ;��λ��ַ   
    	LJMP MAIN          ;��ת��������
	ORG 0030H          ;��������ڵ�ַ   
MAIN:	MOV  TMOD,#05H     ;д��T0������, 16λ�ⲿ������ʽ
      	MOV  TH0, #0       ;д��T0������ֵ
      	MOV  TL0, #0
      	SETB    TR0        ;��ʼ����
LOOP:  MOV    A, TL0
	CJNE A,#0,S1
	LJMP PRT1
S1:		MOV R0,A
	MOV B,#0AH
	DIV AB
	MOV A,R0
	MOV 30H,B
	JNB 30H,dec1
	MOV R0,A
	MOV B,#03CH
	DIV AB
	MOV A,R0
	MOV 31H,B
	JNB 31H,dec2
PRT1:	MOV P1,A
	MOV    A, TH0 
	CJNE A,#0,S2
	LJMP PRT2
S2:		MOV R0,A
	MOV B,#0AH
	DIV AB
	MOV A,R0
	MOV 32H,B
	JNB 32H,dec3
	MOV R0,A
	MOV B,#03CH
	DIV AB
	MOV A,R0
	MOV 33H,B
	JNB 33H,dec4
PRT2:	MOV P2,A
	CLR A
    LJMP    LOOP
dec1:	ADD A,#09FH
	LJMP PRT1
dec2:	ADD A,#06H
	LJMP PRT1
dec3:	ADD A,#06H
	LJMP PRT2
dec4:MOV  TH0, #0       ;����ʱ��
     MOV  TL0, #0
	 LJMP PRT2
    END