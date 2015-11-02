; C'mon, the Compact MONitor

; HXA assembler

       .cpu T_32_M16
       .assume BIT32=1032, BIT32R=3210
       .include "i6502.a"

       .hexfile
       .objfile
       .srecfile
       .listfile

       .org $1000

WIDTH  .equ 8         ;must be a power of 2
HEIGHT .equ 16

INPUT  .equ $7F86
OUTPUT .equ $7F83

ADRESS .equ 0
NUMBER .equ 2

MON    CLD
M1     JSR OUTCR
       LDA #$2D       ;output dash prompt
       JSR OUTPUT
M2     LDA #0
       STA NUMBER+1
       STA NUMBER
M3     AND #$0F
M4     LDY #4         ;accumulate digit
M5     ASL NUMBER
       ROL NUMBER+1
       DEY
       BNE M5
       ORA NUMBER
       STA NUMBER
M6     JSR INPUT
       CMP #$0D
       BEQ M1         ;branch if cr
;
; Insert additional commands for characters (e.g. control characters)
; outside the range $20 (space) to $7E (tilde) here
;
       CMP #$20       ;don't output if outside $20-$7E
       BCC M6
       CMP #$7F
       BCS M6
       JSR OUTPUT
       CMP #$2C
       BEQ COMMA
       CMP #$40
       BEQ AT
;
; Insert additional commands for non-letter characters (or case-sensitive
; letters) here
;
       EOR #$30
       CMP #$0A
       BCC M4         ;branch if digit
       ORA #$20       ;convert to upper case
       SBC #$77
;
; mapping:
;   A-F -> $FFFA-$FFFF
;   G-O -> $0000-$0008
;   P-Z -> $FFE9-$FFF3
;
       BEQ GO
       CMP #$FFFA
       BCS M3
;
; Insert additional commands for (case-insensitive) letters here
;
       CMP #$FFF1
       BNE M6
DUMP   JSR OUTCR
       TYA
       PHA
       CLC            ;output address
       ADC NUMBER
       PHA
       LDA #0
       ADC NUMBER+1
       JSR OUTHEX
       PLA
       JSR OUTHSP
D1     LDA (NUMBER),Y ;output hex bytes
       JSR OUTHSP
       INY
       TYA
       AND #WIDTH-1
       BNE D1
       PLA
       TAY
D2     LDA (NUMBER),Y ;output characters
       AND #$7F
       CMP #$20
       BCC D3
       CMP #$7F
       BCC D4
D3     EOR #$40
D4     JSR OUTPUT
       INY
       TYA
       AND #WIDTH-1
       BNE D2
       CPY #WIDTH*HEIGHT
       BCC DUMP
       BCS M2         ;always
COMMA  LDA NUMBER
       STA (ADRESS),Y
       INC ADRESS
       BNE M2
       INC ADRESS+1
       BCS M2         ;always
AT     LDA NUMBER
       STA ADRESS
       LDA NUMBER+1
       STA ADRESS+1
       BCS M2         ;always
GO     JSR G1
       JMP M2
G1     JMP (NUMBER)
OUTHEX JSR OH1
OH1    JSR OH2
OH2    ASL
       ADC #0
       ASL
       ADC #0
       ASL
       ADC #0
       ASL
       ADC #0
       PHA
       AND #$0F
       CMP #$0A
       BCC OH3
       ADC #$66
OH3    EOR #$30
       JSR OUTPUT
       PLA
       RTS
OUTHSP JSR OUTHEX
       LDA #$20
OA1    JMP OUTPUT
OUTCR  LDA #$0D
       JSR OUTPUT
       LDA #$0A
       BNE OA1        ;always
