s/^; HXA assembler$/; dev65 assembler/
s/^\( *\) \.cpu "6502"/\1 .6502/
s/^\( *\) \.cpu "65C02"/\1 .65C02/
s/^\( *\) \.cpu "W65C816S"/\1 .65816\n\1 .longa on\n\1 .longi on/
s/^\( *\) \.string /\1 .byte /
s/^\( *\) PEI /\1 PEI #/
s/^\([A-Z_a-z][0-9A-Z_a-z]* *\) \.string /\1 .byte /
s/^\([A-Z_a-z][0-9A-Z_a-z]* *\) PEI /\1 PEI #/
/^ * \.assume/d
/^ * \.cpu/d
/^ * \.hexfile/d
/^ * \.include/d
/^ * \.listfile/d
/^ * \.srecfile/d
/^ * \.objfile/d
