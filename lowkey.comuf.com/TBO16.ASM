; HXA assembler

      .cpu T_32_M16
      .assume BIT32=1032, BIT32R=3210
      .include "i6502.a"

      .hexfile
      .objfile
      .srecfile
      .listfile

Z20   .equ $20 ;$0020-$0021 Start of user program space
Z22   .equ $22 ;*userend $0022-$0023 End of user program space
Z24   .equ $24 ;*srcend $0024-$0025 End of BASIC program, SPARE added
Z26   .equ $26 ;$0026-$0027 Top of GOSUB stack
Z28   .equ $28 ;*lino $0028-$0029 Current BASIC line number
Z2A   .equ $2A ;*ilpc $002A-$002B IL Program Counter
Z2C   .equ $2C ;*bp $002C-$002D BASIC Pointer
Z2E   .equ $2E ;*svpt $002E-$002F Saved BASIC Pointer
Z30   .equ $30 ;$0030-$007F Input line & Expression stack
Z80   .equ $80 ;$0080-$0081 Random Number seed
Z82   .equ $82 ;$0082-$00B5 Variables
ZB6   .equ $B6 ;$00B6-$00C3 Interpreter temporaries
ZB7   .equ $B7
ZB8   .equ $B8
ZB9   .equ $B9
ZBB   .equ $BB ;OP_DV sign
ZBC   .equ $BC
ZBD   .equ $BD
ZBE   .equ $BE ;run flag
ZBF   .equ $BF ;tape mode, tab counter, pad counter
ZC0   .equ $C0 ;expression stack end
ZC1   .equ $C1 ;*expntop expression stack pointer
ZC2   .equ $C2 ;$00C2-$00C3 memory read store pointer
ZC4   .equ $C4 ;$00C4-$00C5 saved IL program counter
ZC6   .equ $C6 ;*substk $00C6-$00C7 IL subroutine stack pointer
G2900 .equ $2900
      .org $2000
      JMP G2085 ;cold start
      JMP OP_WS ;warm start
G2006 JMP G2006 ;input
G2009 JMP G2009 ;output
G200C NOP       ;break check
      CLC
      RTS
G200F .byte $005F ;backspace
G2010 .byte $0018 ;cancel
G2011 .byte $8002 ;pad character
G2012 .byte $8000 ;tape mode
G2013 .byte $0004 ;reserve stack size
      STX ZC2+1   ;read byte
      BCC G201D
      STX ZC2+1   ;store byte
      STA (ZC2),Y
      RTS
G201D LDA (ZC2),Y
      LDY #$00
      RTS
                      ;SX n 00-07     Stack Exchange
                      ;JS a 3000-37FF IL Subroutine Call
                      ;J  a 3800-3FFF Jump
G2022 .word OP_BR_NEG ;40-5F Relative Branch
      .word OP_BR_POS ;60-7F Relative Branch
      .word OP_BC     ;80-9F xx..xx String Match Branch
      .word OP_BV     ;A0-BF Branch if Not Variable
      .word OP_BN     ;C0-DF Branch if Not a Number
      .word OP_BE     ;E0-FF Branch if Not Endline
      .word OP_NO ;08 No Operation
      .word OP_LB ;09nn   Push Literal Byte onto Stack
      .word OP_LN ;0Annnn Push Literal Number
      .word OP_DS ;0B Duplicate Top Number (two bytes) on Stack
      .word OP_SP ;0C Stack Pop
      .word OP_0D ;   pop byte
      .word OP_NO
      .word OP_NO
      .word OP_SB ;10 Save BASIC Pointer
      .word OP_RB ;11 Restore BASIC Pointer
      .word OP_FV ;12 Fetch Variable
      .word OP_SV ;13 Store Variable
      .word OP_GS ;14 GOSUB Save
      .word OP_RS ;15 Restore Saved Line
      .word OP_GO ;16 GOTO
      .word OP_NE ;17 Negate (two's complement)
      .word OP_AD ;18 Add
      .word OP_SU ;19 Subtract
      .word OP_MP ;1A Multiply
      .word OP_DV ;1B Divide
      .word OP_CP ;1C Compare
      .word OP_NX ;1D Next BASIC Statement
      .word OP_NO
      .word OP_LS ;1F List The Program
      .word OP_PN ;20 Print Number
      .word OP_PQ ;21 Print BASIC String
      .word OP_PT ;22 Print Tab
      .word OP_NL ;23 New Line
      .word OP_PC ;24xx..xx Print Literal String
      .word OP_NO
      .word OP_NO
      .word OP_GL ;27 Get Input Line
      .word OP_28 ;unused
      .word OP_29 ;unused
      .word OP_IL ;2A Insert BASIC Line
      .word OP_MT ;2B Mark the BASIC program space Empty
      .word OP_XQ ;2C Execute
      .word OP_WS ;2D Stop
      .word OP_US ;2E Machine Language Subroutine Call
      .word OP_RT ;2F IL Subroutine Return
G207E .byte ' ','A','T',' ',0+$8000
G2083 .word STRT
G2085 LDA #G2900
      STA Z20
      STA Z22
      LDA #G2900/$10000
      STA Z20+1
      STA Z22+1
      LDY #$01
La0   LDA (Z22),Y
      TAX
      EOR #$FF
      STA (Z22),Y
      CMP (Z22),Y
      PHP
      TXA
      STA (Z22),Y
      INC Z22
      BNE Lb0
      INC Z22+1
Lb0   PLP
      BEQ La0
      DEY
OP_MT CLD
      LDA Z20
      ADC G2013
      STA Z24
      TYA
      ADC Z20+1
      STA Z24+1
      TYA
      STA (Z20),Y
      INY
      STA (Z20),Y
OP_WS LDA Z22
      STA ZC6
      STA Z26
      LDA Z22+1
      STA ZC6+1
      STA Z26+1
      JSR OUT_LN
G20CC LDA G2083
      STA Z2A
      LDA G2083+1
      STA Z2A+1
      LDA #Z30+$50
      STA ZC1
      LDA #Z30
      STA ZC0
      LDX #$00
      STX ZBE
      STX ZC2
      LDX #$1FF
      TXS
La1   CLD
      JSR GET_IL
      JSR Lb1
      JMP La1
      .byte $83,$65 ;unused
Lb1   CMP #$30
      BCS G2171
      CMP #$08
      BCC OP_SX
      ASL
      TAX
G20FC LDA G2022-3,X
      PHA
      LDA G2022-4,X
      PHA
      PHP
      RTI
OP_SX ADC ZC1
      TAX
      LDA (ZC1),Y
      PHA
      LDA 0,X
      STA (ZC1),Y
      PLA
      STA 0,X
      RTS
TB_ERROR:
      JSR OUT_LN
      LDA #$21
      JSR G2009
      LDA Z2A
      SEC
      SBC G2083
      TAX
      LDA Z2A+1
      SBC G2083+1
      JSR G23A0
      LDA ZBE
      BEQ La2
      LDA #G207E
      STA Z2A
      LDA #G207E/$10000
      STA Z2A+1
      JSR OP_PC
      LDX Z28
      LDA Z28+1
      JSR G23A0
La2   LDA #$07
      JSR G2009
      JSR OUT_LN
G2149 LDA Z26
      STA ZC6
      LDA Z26+1
      STA ZC6+1
      JMP G20CC
G2154 LDX #Z30+$4C
G2156 CPX ZC1
G2158 BCC TB_ERROR
      LDX ZC1
      INC ZC1
      INC ZC1
      CLC
      RTS
OP_BR_NEG
      DEC ZBD
OP_BR_POS
      LDA ZBD
      ORA ZBC
      BEQ TB_ERROR
G2168 LDA ZBC
      STA Z2A
      LDA ZBD
      STA Z2A+1
      RTS
G2171 CMP #$40
      BCS G21B8
      PHA
      JSR GET_IL
      ADC G2083
      STA ZBC
      PLA
      PHA
      AND #$07
      ADC G2083+1
      STA ZBD
      PLA
      AND #$08
      BNE G2168
      LDA ZBC
      LDX Z2A
      STA Z2A
      STX ZBC
      LDA ZBD
      LDX Z2A+1
      STA Z2A+1
      STX ZBD
PUSH_SUB:
      LDA ZC6
      SBC #$01
      STA ZC6
      BCS La3
      DEC ZC6+1
La3   CMP Z24
      LDA ZC6+1
      SBC Z24+1
      BCC G2158
      LDA ZBC
      STA (ZC6),Y
      INY
      LDA ZBD
      STA (ZC6),Y
      RTS
G21B8 PHA
      LSR
      LSR
      LSR
      LSR
      AND #$0E
      TAX
      PLA
      CMP #$60
      AND #$1F
      BCS La4
      ORA #$FFE0
La4   CLC
      STA ZBC
      BEQ Lb4
      ADC Z2A
      STA ZBC
      TYA
      ADC Z2A+1
Lb4   STA ZBD
      JMP G20FC
OP_BC LDA Z2C
      STA ZB8
      LDA Z2C+1
      STA ZB9
La5   JSR GET_BAS_DIG
      JSR GET_BAS
      EOR (Z2A),Y
      TAX
      JSR GET_IL
      TXA
      BEQ La5
      ASL
      BEQ G2204
      LDA ZB8
      STA Z2C
      LDA ZB9
      STA Z2C+1
G21FA JMP OP_BR_POS
OP_BE JSR GET_BAS_DIG
      CMP #$0D
      BNE G21FA
G2204 RTS
OP_BV JSR GET_BAS_DIG
      CMP #$5B
      BCS G21FA
      CMP #$41
      BCC G21FA
      ASL
      JSR PUSH_EX_BY
GET_BAS:
      LDY #$00
      LDA (Z2C),Y
      INC Z2C
      BNE La6
      INC Z2C+1
La6   CMP #$0D
      CLC
      RTS
G2222 JSR GET_BAS
GET_BAS_DIG:
      LDA (Z2C),Y
      CMP #$20
      BEQ G2222
      CMP #$3A
      CLC
      BPL La7
      CMP #$30
La7   RTS
OP_BN JSR GET_BAS_DIG
      BCC G21FA
      STY ZBC
      STY ZBD
La8   LDA ZBC
      LDX ZBD
      ASL ZBC
      ROL ZBD
      ASL ZBC
      ROL ZBD
      CLC
      ADC ZBC
      STA ZBC
      TXA
      ADC ZBD
      ASL ZBC
      ROL
      STA ZBD
      JSR GET_BAS
      AND #$0F
      ADC ZBC
      STA ZBC
      TYA
      ADC ZBD
      STA ZBD
      JSR GET_BAS_DIG
      BCS La8
      JMP PUSH_EX_INT
FIND_LINE:
      JSR OP_SP
      LDA ZBC
      ORA ZBD
      BEQ G22BC
G2274 LDA Z20
      STA Z2C
      LDA Z20+1
      STA Z2C+1
La9   JSR G236D
      BEQ Lc9
      LDA Z28
      CMP ZBC
      LDA Z28+1
      SBC ZBD
      BCS Lc9
Lb9   JSR GET_BAS
      BNE Lb9
      JMP La9
Lc9   LDA Z28
      EOR ZBC
      BNE Ld9
      LDA Z28+1
      EOR ZBD
Ld9   RTS
G229E JSR G22A6
OP_PC JSR GET_IL
      BPL G229E
G22A6 INC ZBF
      BMI La10
      JMP G2009
La10  DEC ZBF
G22AF RTS
G22B0 CMP #$22
      BEQ G22AF
      JSR G22A6
OP_PQ JSR GET_BAS
      BNE G22B0
G22BC JMP TB_ERROR
OP_PT LDA #$20
      JSR G22A6
      LDA ZBF
      AND #$8007
      BMI G22AF
      BNE OP_PT
      RTS
OP_CP LDX #Z30+$4B
      JSR G2156
      INC ZC1
      INC ZC1
      INC ZC1
      SEC
      LDA 3,X
      SBC 0,X
      STA 0,X
      LDA 4,X
      SBC 1,X
      BVC La11
      EOR #$8000
      ORA #$01
La11  BMI Ld11
      BNE Lb11
      ORA 0,X
      BEQ Lc11
Lb11  LSR 2,X
Lc11  LSR 2,X
Ld11  LSR 2,X
      BCC G2305
GET_IL:
      LDY #$00
      LDA (Z2A),Y
      INC Z2A
      BNE La12
      INC Z2A+1
La12  ORA #$00
G2305 RTS
OP_NX LDA ZBE
      BEQ G2332
La13  JSR GET_BAS
      BNE La13
      JSR G236D
      BEQ G232F
G2314 JSR G234C
      JSR G200C
      BCS La14
      LDA ZC4
      STA Z2A
      LDA ZC4+1
      STA Z2A+1
      RTS
La14  LDA G2083
      STA Z2A
      LDA G2083+1
      STA Z2A+1
G232F JMP TB_ERROR
G2332 STA ZBF
      JMP G2149
OP_XQ LDA Z20
      STA Z2C
      LDA Z20+1
      STA Z2C+1
      JSR G236D
      BEQ G232F
      LDA Z2A
      STA ZC4
      LDA Z2A+1
      STA ZC4+1
G234C LDA #$01
      STA ZBE
      RTS
OP_GO JSR FIND_LINE
      BEQ G2314
G2356 LDA ZBC
      STA Z28
      LDA ZBD
      STA Z28+1
      JMP TB_ERROR
OP_RS JSR POP_SUB
      JSR G26F4
      JSR G2274
      BNE G2356
      RTS
G236D JSR GET_BAS
      STA Z28
      JSR GET_BAS
      STA Z28+1
      ORA Z28
      RTS
OP_DS JSR OP_SP
      JSR PUSH_EX_INT
PUSH_EX_INT:
      LDA ZBD
PUSH_EX_INT_A
      JSR PUSH_EX_BY
      LDA ZBC
PUSH_EX_BY:
      LDX ZC1
      DEX
      STA 0,X
      STX ZC1
      CPX ZC0
      BNE OP_NO
G2392 JMP TB_ERROR
OP_0D LDX ZC1
      CPX #Z30+$50
      BPL G2392
      LDA 0,X
      INC ZC1
OP_NO RTS
G23A0 STA ZBD
      STX ZBC
      JMP OUT_INT_POS
P10L  .byte $0001,$000A,$0064,$03E8,$2710,$86A0,$4240,$9680,$E100,$CA00
P10H  .byte $0000,$0000,$0000,$0000,$0000,$0001,$000F,$0098,$05F5,$3B9A
OP_PN LDX ZC1
      LDA 1,X
      BPL La15
      JSR OP_NE
      LDA #$2D
      JSR G22A6
La15  JSR OP_SP
OUT_INT_POS:
      LDA #$00
      STA ZB8
      LDX #$09
La16  STX ZC2+1
      LDA #$00
      STA ZB9
      SEC
      BCS Lc16
Lb16  STY ZBC
      STA ZBD
      INC ZB9
Lc16  LDA ZBC
      SBC P10L,X
      TAY
      LDA ZBD
      SBC P10H,X
      BCS Lb16
      LDA ZB8
      AND #$30
      ORA ZB9
      BEQ Ld16
      ORA #$30
      STA ZB8
      JSR G22A6
Ld16  LDX ZC2+1
      DEX
      BPL La16
      RTS
OP_LS LDA Z2C+1
      PHA
      LDA Z2C
      PHA
      LDA Z20
      STA Z2C
      LDA Z20+1
      STA Z2C+1
      LDA Z24
      LDX Z24+1
      JSR G245B
      BEQ La17
      JSR G245B
La17  LDA Z2C
      SEC
      SBC ZB6
      LDA Z2C+1
      SBC ZB7
      BCS G247C
      JSR G236D
      BEQ G247C
      LDX Z28
      LDA Z28+1
      JSR G23A0
      LDA #$20
Lb17  JSR G22A6
      JSR G200C
      BCS G247C
      JSR GET_BAS
      BNE Lb17
      JSR OP_NL
      JMP La17
G245B STA ZB6
      INC ZB6
      BNE La18
      INX
La18  STX ZB7
      LDY ZC1
      CPY #Z30+$50
      BEQ G2482
      JSR FIND_LINE
G246D LDA Z2C
      LDX Z2C+1
      SEC
      SBC #$02
      BCS La19
      DEX
La19  STA Z2C
      JMP G2748
G247C PLA
      STA Z2C
      PLA
      STA Z2C+1
G2482 RTS
OP_NL LDA ZBF
      BMI G2482
OUT_LN:
      LDA #$0D
      JSR G2009
      LDA G2011
      AND #$7F
      STA ZBF
      BEQ Lb20
La20  JSR G2764
      DEC ZBF
      BNE La20
Lb20  LDA #$0A
      JMP G2761
G24A1 LDY G2012
G24A4 STY ZBF
      BCS G24B3
OP_GL LDA #Z30
      STA Z2C
      STA ZC0
      STY Z2C+1
      JSR PUSH_EX_INT
G24B3 EOR Z80
      STA Z80
      JSR G2006
      LDY #$00
      LDX ZC0
      AND #$7F
      BEQ G24B3
      CMP #$7F
      BEQ G24B3
      CMP #$13
      BEQ G24A4
      CMP #$0A
      BEQ G24A1
      CMP G2010
      BEQ La21
      CMP G200F
      BNE Lb21
      CPX #Z30
      BNE Ld21
La21  LDX Z2C
      STY ZBF
      LDA #$0D
Lb21  CPX ZC1
      BMI Lc21
      LDA #$07
      JSR G22A6
      JMP G24B3
Lc21  STA 0,X
      INX
      INX
Ld21  DEX
      STX ZC0
      CMP #$0D
      BNE G24B3
      JSR OP_NL
OP_SP JSR OP_0D
      STA ZBC
      JSR OP_0D
      STA ZBD
      RTS
OP_IL JSR G26D6
      JSR FIND_LINE
      PHP
      JSR G246D
      STA ZB8
      STX ZB9
      LDA ZBC
      STA ZB6
      LDA ZBD
      STA ZB7
      LDX #$00
      PLP
      BNE Lb22
      JSR G236D
      DEX
      DEX
La22  DEX
      JSR GET_BAS
      BNE La22
Lb22  STY Z28
      STY Z28+1
      JSR G26D6
      LDA #$0D
      CMP (Z2C),Y
      BEQ Ld22
      INX
      INX
      INX
Lc22  INX
      INY
      CMP (Z2C),Y
      BNE Lc22
      LDA ZB6
      STA Z28
      LDA ZB7
      STA Z28+1
Ld22  LDA ZB8
      STA ZBC
      LDA ZB9
      STA ZBD
      CLC
      LDY #$00
      TXA
      BEQ Lm22
      BPL Lh22
      ADC Z2E
      STA ZB8
      LDA Z2E+1
      SBC #$00
      STA ZB9
Le22  LDA (Z2E),Y
      STA (ZB8),Y
      LDX Z2E
      CPX Z24
      BNE Lf22
      LDA Z2E+1
      CMP Z24+1
      BEQ Ll22
Lf22  INX
      STX Z2E
      BNE Lg22
      INC Z2E+1
Lg22  INC ZB8
      BNE Le22
      INC ZB9
      BNE Le22
Lh22  ADC Z24
      STA ZB8
      STA Z2E
      TYA
      ADC Z24+1
      STA ZB9
      STA Z2E+1
      LDA Z2E
      SBC ZC6
      LDA Z2E+1
      SBC ZC6+1
      BCC Li22
      DEC Z2A
      JMP TB_ERROR
Li22  LDA (Z24),Y
      STA (Z2E),Y
      LDX Z24
      BNE Lj22
      DEC Z24+1
Lj22  DEC Z24
      LDX Z2E
      BNE Lk22
      DEC Z2E+1
Lk22  DEX
      STX Z2E
      CPX ZBC
      BNE Li22
      LDX Z2E+1
      CPX ZBD
      BNE Li22
Ll22  LDA ZB8
      STA Z24
      LDA ZB9
      STA Z24+1
Lm22  LDA Z28
      ORA Z28+1
      BEQ Lo22
      LDA Z28
      STA (ZBC),Y
      INY
      LDA Z28+1
      STA (ZBC),Y
Ln22  INY
      STY ZB6
      JSR GET_BAS
      PHP
      LDY ZB6
      STA (ZBC),Y
      PLP
      BNE Ln22
Lo22  JMP G20CC
OP_DV JSR G2154
      LDA 3,X
      AND #$8000
      BEQ La23
      LDA #$FFFF
La23  STA ZBC
      STA ZBD
      PHA
      ADC 2,X
      STA 2,X
      PLA
      PHA
      ADC 3,X
      STA 3,X
      PLA
      EOR 1,X
      STA ZBB
      BPL Lb23
      JSR G2643
Lb23  LDY #$21
      LDA 0,X
      ORA 1,X
      BNE Lc23
      JMP TB_ERROR
Lc23  SEC
      LDA ZBC
      SBC 0,X
      PHA
      LDA ZBD
      SBC 1,X
      PHA
      EOR ZBD
      BMI Ld23
      PLA
      STA ZBD
      PLA
      STA ZBC
      SEC
      JMP Le23
Ld23  PLA
      PLA
      CLC
Le23  ROL 2,X
      ROL 3,X
      ROL ZBC
      ROL ZBD
      DEY
      BNE Lc23
      LDA ZBB
      BPL G264E
OP_NE LDX ZC1
G2643 SEC
      TYA
      SBC 0,X
      STA 0,X
      TYA
      SBC 1,X
      STA 1,X
G264E RTS
OP_SU JSR OP_NE
OP_AD JSR G2154
      LDA 0,X
      ADC 2,X
      STA 2,X
      LDA 1,X
      ADC 3,X
      STA 3,X
      RTS
OP_MP JSR G2154
      LDY #$20
      LDA 2,X
      STA ZBC
      LDA 3,X
      STA ZBD
La24  ASL 2,X
      ROL 3,X
      ROL ZBC
      ROL ZBD
      BCC Lb24
      CLC
      LDA 2,X
      ADC 0,X
      STA 2,X
      LDA 3,X
      ADC 1,X
      STA 3,X
Lb24  DEY
      BNE La24
      RTS
OP_FV JSR OP_0D
      TAX
      LDA Z82-$82,X
      LDY Z82+1-$82,X
      DEC ZC1
      LDX ZC1
      STY 0,X
      JMP PUSH_EX_BY
OP_SV LDX #Z30+$4D
      JSR G2156
      LDA 1,X
      PHA
      LDA 0,X
      PHA
      JSR OP_0D
      TAX
      PLA
      STA Z82-$82,X
      PLA
      STA Z82+1-$82,X
      RTS
OP_RT JSR POP_SUB
      LDA ZBC
      STA Z2A
      LDA ZBD
      STA Z2A+1
      RTS
OP_SB LDX #Z2C
      BNE G26C3
OP_RB LDX #Z2E
G26C3 LDA 0,X
      CMP #Z80
      BCS G26D6
      LDA 1,X
      BNE G26D6
      LDA Z2C
      STA Z2E
      LDA Z2C+1
      STA Z2E+1
      RTS
G26D6 LDA Z2C
      LDY Z2E
      STY Z2C
      STA Z2E
      LDA Z2C+1
      LDY Z2E+1
      STY Z2C+1
      STA Z2E+1
      LDY #$00
      RTS
OP_GS LDA Z28
      STA ZBC
      LDA Z28+1
      STA ZBD
      JSR PUSH_SUB
G26F4 LDA ZC6
      STA Z26
      LDA ZC6+1
      STA Z26+1
G26FC RTS
POP_SUB:
      LDA (ZC6),Y
      STA ZBC
      JSR La25
      LDA (ZC6),Y
      STA ZBD
La25  INC ZC6
      BNE Lb25
      INC ZC6+1
Lb25  LDA Z22
      CMP ZC6
      LDA Z22+1
      SBC ZC6+1
      BCS G26FC
      JMP TB_ERROR
OP_US JSR G2724
      STA ZBC
      TYA
      JMP PUSH_EX_INT_A
G2724 JSR OP_SP
      LDA ZBC
      STA ZB6
      JSR OP_SP
      LDA ZBD
      STA ZB7
      LDY ZBC
      JSR OP_SP
      LDX ZB7
      LDA ZB6
      CLC
      JMP (ZBC)
OP_LN JSR OP_LB
OP_LB JSR GET_IL
      JMP PUSH_EX_BY
G2748 STX Z2C+1
      CPX #$00
      RTS
OP_29 LDY #G2900+2
OP_28 STY ZBC
      LDY #(G2900+2)/$10000
      STY ZBD
      LDY #$00
      LDA (ZBC),Y
      CMP #$08
      BNE La26
      JMP G2168
La26  RTS
G2761 JSR G2009
G2764 LDA #$FF
      BIT G2011
      BMI La27
      LDA #$00
La27  JMP G2009

SX    .equ $00
NO    .equ $08
LB    .equ $09
LN    .equ $0A
DS:   .equ $0B
SP    .equ $0C
SB    .equ $10
RB    .equ $11
FV    .equ $12
SV    .equ $13
GS    .equ $14
RS    .equ $15
GO    .equ $16
NE_   .equ $17
AD    .equ $18
SU    .equ $19
MP    .equ $1A
DV    .equ $1B
CP    .equ $1C
NX    .equ $1D
LS    .equ $1F
PN    .equ $20
PQ    .equ $21
PT    .equ $22
NL    .equ $23
PC    .equ $24
GL    .equ $27
IL    .equ $2A
MT    .equ $2B
XQ    .equ $2C
WS    .equ $2D
US    .equ $2E
RT    .equ $2F
JS    .equ $30
J     .equ $38
BR    .equ $60
BC    .equ $80
BV    .equ $A0
BN    .equ $C0
BE    .equ $E0

;  ORIGINAL TINY BASIC INTERMEDIATE INTERPRETER
;
;  EXECUTIVE INITIALIZATION
;
STRT .byte PC,':',$11+$8000 ;COLON, X-ON
     .byte GL
     .byte SB
     .byte BE+L0-*-1       ;BRANCH IF NOT EMPTY
     .byte BR+STRT-*-1     ;TRY AGAIN IF NULL LINE
L0   .byte BN+STMT-*-1     ;TEST FOR LINE NUMBER
     .byte IL              ;IF SO, INSERT INTO PROGRAM
     .byte BR+STRT-*-1     ;GO GET NEXT
XEC  .byte SB              ;SAVE POINTERS FOR RUN WITH
     .byte RB              ;  CONCATENATED INPUT
     .byte XQ
;
;  STATEMENT EXECUTOR
;
STMT .byte BC+GOTO-*-1,'L','E','T'+$8000
     .byte BV+0            ;MUST BE A VARIABLE NAME
     .byte BC+0,'='+$8000
LET  .byte JS,EXPR-STRT    ;GO GET EXPRESSION
     .byte BE+0            ;IF STATEMENT END,
     .byte SV              ;  STORE RESULT
     .byte NX
;
GOTO .byte BC+PRNT-*-1,'G','O'+$8000
     .byte BC+GOSB-*-1,'T','O'+$8000
     .byte JS,EXPR-STRT    ;GET LINE NUMBER
     .byte BE+0
     .byte SB              ;(DO THIS FOR STARTING)
     .byte RB
     .byte GO              ;GO THERE
;
GOSB .byte BC+0,'S','U','B'+$8000 ;NO OTHER WORD BEGINS "GO..."
     .byte JS,EXPR-STRT
     .byte BE+0
     .byte GS
     .byte GO
;
PRNT .byte BC+SKIP-*-1,'P','R'+$8000
     .byte BC+P0-*-1,'I','N','T'+$8000 ;OPTIONALLY OMIT "INT"
P0   .byte BE+P3-*-1
     .byte BR+P6-*-1       ;IF DONE, GO TO END
P1   .byte BC+P4-*-1,';'+$8000
P2   .byte BE+P3-*-1
     .byte NX              ;NO CRLF IF ENDED BY ; OR ,
P3   .byte BC+P7-*-1,'"'+$8000
     .byte PQ              ;QUOTE MARKS STRING
     .byte BR+P1-*-1       ;GO CHECK DELIMITER
SKIP .byte BR+IF_-*-1      ;(ON THE WAY THRU)
P4   .byte BC+P5-*-1,','+$8000
     .byte PT              ;COMMA SPACING
     .byte BR+P2-*-1
P5   .byte BC+P6-*-1,':'+$8000
     .byte PC,$13+$8000    ;OUTPUT X-OFF
P6   .byte BE+0
     .byte NL              ;THEN CRLF
     .byte NX
P7   .byte JS,EXPR-STRT    ;TRY FOR AN EXPRESSION
     .byte PN
     .byte BR+P1-*-1
;
IF_  .byte BC+INPT-*-1,'I','F'+$8000
     .byte JS,EXPR-STRT
     .byte JS,RELO-STRT
     .byte JS,EXPR-STRT
     .byte BC+I1-*-1,'T','H','E','N'+$8000 ;OPTIONAL NOISEWORD
I1   .byte CP              ;COMPARE SKIPS NEXT IF TRUE
     .byte NX              ;FALSE.
     .byte J,STMT-STRT     ;TRUE. GO PROCESS STATEMENT
;
INPT .byte BC+RETN-*-1,'I','N','P','U','T'+$8000
I2   .byte BV+0            ;GET VARIABLE
     .byte SB              ;SWAP POINTERS
     .byte BE+I4-*-1
I3   .byte PC,'?',' ',$11+$8000 ;LINE IS EMPTY; TYPE PROMPT
     .byte GL              ;READ INPUT LINE
     .byte BE+I4-*-1       ;DID ANYTHING COME?
     .byte BR+I3-*-1       ;NO, TRY AGAIN
I4   .byte BC+I5-*-1,','+$8000 ;OPTIONAL COMMA
I5   .byte JS,EXPR-STRT    ;READ A NUMBER
     .byte SV              ;STORE INTO VARIABLE
     .byte RB              ;SWAP BACK
     .byte BC+I6-*-1,','+$8000 ;ANOTHER?
     .byte BR+I2-*-1       ;YES IF COMMA
I6   .byte BE+0            ;OTHERWISE QUIT
     .byte NX
;
RETN .byte BC+END-*-1,'R','E','T','U','R','N'+$8000
     .byte BE+0
     .byte RS              ;RECOVER SAVED LINE
     .byte NX
;
END: .byte BC+LIST-*-1,'E','N','D'+$8000
     .byte BE+0
     .byte WS
;
LIST .byte BC+RUN-*-1,'L','I','S','T'+$8000
     .byte BE+L2-*-1
L1   .byte PC,$00,$00,$00,$00,$0A,$00+$8000 ;PUNCH LEADER
     .byte LS              ;LIST
     .byte PC,$13+$8000    ;PUNCH X-OFF
     .byte NL
     .byte NX
L2   .byte JS,EXPR-STRT    ;GET A LINE NUMBER
     .byte BE+L3-*-1
     .byte BR+L1-*-1
L3   .byte BC+0,','+$8000  ;SEPARATED BY COMMAS
     .byte BR+L2-*-1
;
RUN  .byte BC+CLER-*-1,'R','U','N'+$8000
     .byte J,XEC-STRT
;
CLER .byte BC+REM-*-1,'C','L','E','A','R'+$8000
     .byte MT
;
REM  .byte BC+DFLT-*-1,'R','E','M'+$8000
     .byte NX
;
DFLT .byte BV+0            ;NO KEYWORD...
     .byte BC+0,'='+$8000  ;TRY FOR LET
     .byte J,LET-STRT      ;IT'S A GOOD BET.
;
;  SUBROUTINES
;
EXPR .byte BC+E0-*-1,'-'+$8000 ;TRY FOR UNARY MINUS
     .byte JS,TERM-STRT      ;AHA
     .byte NE_
     .byte BR+E1-*-1
E0   .byte BC+E4-*-1,'+'+$8000 ;IGNORE UNARY PLUS
E4   .byte JS,TERM-STRT
E1   .byte BC+E2-*-1,'+'+$8000 ;TERMS SEPARATED BY PLUS
     .byte JS,TERM-STRT
     .byte AD
     .byte BR+E1-*-1
E2   .byte BC+E3-*-1,'-'+$8000 ;TERMS SEPARATED BY MINUS
     .byte JS,TERM-STRT
     .byte SU
     .byte BR+E1-*-1
E3   .byte RT
;
TERM .byte JS,FACT-STRT
T0   .byte BC+T1-*-1,'*'+$8000 ;FACTORS SEPARATED BY TIMES
     .byte JS,FACT-STRT
     .byte MP
     .byte BR+T0-*-1
T1   .byte BC+T2-*-1,'/'+$8000 ;FACTORS SEPARATED BY DIVIDE
     .byte JS,FACT-STRT
     .byte DV
     .byte BR+T0-*-1
T2   .byte RT
;
FACT .byte BC+F0-*-1,'R','N','D'+$8000 ;*RND FUNCTION*
     .byte LN,Z80,Z80      ;STACK POINTER FOR STORE
     .byte FV              ;THEN GET RNDM
     .byte LN,2345,0       ;R:=R*2345+6789
     .byte MP
     .byte LN,6789,0
     .byte AD
     .byte SV
     .byte LB,Z80          ;GET IT AGAIN
     .byte FV
     .byte SX+1
     .byte DS
     .byte JS,FUNC-STRT    ;GET ARGUMENT
     .byte BR+F1-*-1
F0   .byte BR+F2-*-1       ;(SKIPPING)
F1   .byte DS
;     .byte SX+2            ;PUSH TOP INTO STACK
     .byte SX+4
     .byte SX+2
     .byte SX+3
     .byte SX+5
     .byte SX+3
     .byte DV              ;PERFORM MOD FUNCTION
     .byte MP
     .byte SU
     .byte DS              ;PERFORM ABS FUNCTION
     .byte LB,6
     .byte LN,0,0
     .byte CP              ;(SKIP IF + OR 0)
     .byte NE_
     .byte RT
F2   .byte BC+F3-*-1,'U','S','R'+$8000 ;*USR FUNCTION*
     .byte BC+0,'('+$8000  ;3 ARGUMENTS POSSIBLE
     .byte JS,EXPR-STRT    ;ONE REQUIRED
     .byte JS,ARG-STRT
     .byte JS,ARG-STRT
     .byte BC+0,')'+$8000
     .byte US              ;GO DO IT
     .byte RT
F3   .byte BV+F4-*-1       ;VARIABLE?
     .byte FV              ;YES.  GET IT
     .byte RT
F4   .byte BN+F5-*-1       ;NUMBER?
     .byte RT              ;GOT IT.
F5   .byte BC+0,'('+$8000  ;OTHERWISE MUST BE (EXPR)
F6   .byte JS,EXPR-STRT
     .byte BC+0,')'+$8000
     .byte RT
;
ARG  .byte BC+A0-*-1,','+$8000 ; COMMA?
     .byte J,EXPR-STRT     ; YES, GET EXPRESSION
A0   .byte DS              ; NO, DUPLICATE STACK TOP
     .byte RT
;
FUNC .byte BC+0,'('+$8000
     .byte BR+F6-*-1
     .byte RT
;
RELO .byte BC+R0-*-1,'='+$8000 ; CONVERT RELATION OPERATORS
     .byte LB,2            ; TO CODE BYTE ON STACK
     .byte RT              ; =
R0   .byte BC+R4-*-1,'<'+$8000
     .byte BC+R1-*-1,'='+$8000
     .byte LB,$93          ; <=
     .byte RT
R1   .byte BC+R3-*-1,'>'+$8000
     .byte LB,5            ; <>
     .byte RT
R3   .byte LB,$91          ; <
     .byte RT
R4   .byte BC+0,'>'+$8000
     .byte BC+R5-*-1,'='+$8000
     .byte LB,6            ; >=
     .byte RT
R5   .byte BC+R6-*-1,'<'+$8000
     .byte LB,$95          ; ><
     .byte RT
R6   .byte LB,4            ; >
     .byte RT

      .byte 0,0,0 ;unused
