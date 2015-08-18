;***************************************************************
; Simple Test for the MON88
;
; - Set the RTC clock      
; - Must be run from Mon88
; - Assembled using A86
;
; version 0.1 HT-LAB 2005
;***************************************************************    
                              
LF      EQU     0Ah
CR      EQU     0Dh

        org  0100h                              ; result in .com 

        MOV     AX,CS
        MOV     DS,AX
        MOV     ES,AX
    
        MOV     DX,OFFSET WELCOME_MESS          ; OFFSET -> DX
        MOV     AH,09
        INT     21h                             ; Write String to Uart

        ; Int 1Ah function 02h - Get RTC time
        ; CH = hour (BCD)
        ; CL = minutes (BCD)
        ; DH = seconds (BCD)
        MOV     AH,2
        INT     1Ah                             ; Get the time

        MOV     AL,CH                           ; Write to UART
        CALL    CONHEX2
        MOV     AL,':'
        CALL    PUTCH
        
        MOV     AL,CL
        CALL    CONHEX2
        MOV     AL,':'
        CALL    PUTCH
        
        MOV     AL,DH                           ; seconds
        CALL    CONHEX2


        MOV     DX,OFFSET TIME_MESS             ; Enter the current time               
        MOV     AH,09                           ; Write '0' terminated string
        INT     21h
        
        CALL    GETBCD2                         ; Ask user to enter the time
        MOV     CH,AL
        MOV     AL,':'
        CALL    PUTCH
        CALL    GETBCD2
        MOV     CL,AL
        MOV     AL,':'
        CALL    PUTCH
        CALL    GETBCD2
        MOV     DH,AL
             
        ; Set time to xx:59:55
        ; Int 1Ah function 03h - Set RTC time
        ; CH = hour (BCD)
        ; CL = minutes (BCD)
        ; DH = seconds (BCD)
        MOV     AH,3
        INT     01Ah                            ; Set the RTC
    
        MOV     AX,04C00h
        INT     21h                             ; Exit back to monitor              
        
;------------------------------------------------------------------------------------
; Transmit character in AL
;------------------------------------------------------------------------------------
PUTCH:  MOV     DL,AL
        MOV     AH,02
        INT     21h 
        RET

;------------------------------------------------------------------------------------
; Receive character in AL, blocking
;------------------------------------------------------------------------------------
GETCH:  MOV     AH,01
        INT     21h
        RET
                    
;------------------------------------------------------------------------------------
; Transmit character in AL as HEX
;------------------------------------------------------------------------------------
CONHEX1:PUSHF                                   ; Push regs used (USES..)
        PUSH   AX                               ; Save the working register

        AND    AL, 0FH                          ; Mask off any unused bits
        CMP    AL, 0AH                          ; Test for alpha or numeric
        JL     NUMERIC                          ; Take the branch if numeric

        ADD    AL, 7                            ; Add the adjustment for hex alpha
NUMERIC:ADD    AL, '0'                          ; Add the numeric bias
        CALL   PUTCH                            ; Send to the console

        POP    AX
        POPF
        RET

CONHEX2:PUSHF                                   ; Push regs used (USES..)
        PUSH   AX                               ; Save the working register

        SHR    AL,1
        SHR    AL,1
        SHR    AL,1
        SHR    AL,1
        CALL   CONHEX1                          ; Output it
        POP    AX                               ; Get the LSD
        CALL   CONHEX1                          ; Output

        POPF
        RET

;------------------------------------------------------------------------------------
; Read character in AL as BCD
;------------------------------------------------------------------------------------
GETBCD2:PUSH    BX
        PUSH    CX
        CALL    GETHEX1                         ; Get Hex character in AL
        MOV     CL,10
        MUL     CL
        MOV     BL,AL                           ; Store         
        CALL    GETHEX1
        ADD     BL,AL
        XCHG    BL,AL
        POP     CX
        POP     BX
        RET

GETHEX1:CALL    GETCH                           ; Get Hex character in AL
        CALL    TO_UPPER
        CMP     AL,39h                          ; 0-9?
        JLE     CONVDEC                         ; yes, subtract 30
        SUB     AL,07h                          ; A-F subtract 39
CONVDEC:SUB     AL,30h
        RET

;----------------------------------------------------------------------
; Convert to Upper Case
; if (c >= 'a' && c <= 'z') c -= 32;
;----------------------------------------------------------------------
TO_UPPER:CMP     AL,'a'
        JGE     CHECKZ
        RET
CHECKZ: CMP     AL,'z'
        JLE     SUB32
        RET
SUB32:  SUB     AL,32
        RET


WELCOME_MESS    DB    0dh,0ah,"The current time is:",0,'$'
TIME_MESS       DB    0dh,0ah,"Enter the new time :",0,'$'
