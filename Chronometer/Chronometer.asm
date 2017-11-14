/*
 * Chronometer.asm
 *
 *  Created: 1/13/2017 2:44:22 PM
 *   Author: forsakenMystery
 */ 
 ;Chronometer by hamed khashechi 9318953
 .INCLUDE "M32DEF.INC"
 .ORG 0x0000
 JMP main
 .ORG 0x0002
 JMP start
 .ORG 0x0004
 JMP reset
 .ORG 0x0012
  JMP delay
  ;Pind is interrupt external
 .ORG 0x0100
 main:
 LDI R16,0x00 ;flag means counter isn't working
 LDI R20,HIGH(RAMEND) ;initialize stack pointer
 OUT SPH,R20
 LDI R20,LOW(RAMEND)
 OUT SPL,R20
 LDI R20,0xFF ;output mode for porta and portb
 OUT DDRA,R20
 OUT DDRB,R20
 LDI R20,0x00 ;initialize time 00:00
 OUT PORTA,R20
 OUT PORTB,R20
 LDI R20,HIGH(-31250) ;higher part of clock needed  8MHZ :256 scale
 OUT TCNT1H,R20
 LDI R20,LOW(-31250) ;lower part of clock needed 8MHZ :256 scale
 OUT TCNT1L,R20
 LDI R20,(1<<INT0|1<<INT1) ;initialize general interrupt controller register
 OUT GICR,R20
 LDI R20,0x0f ;every changes in keys should detected
 OUT MCUCR,R20
 LDI R20,(1<<TOIE1) ;timer 1 overflow interrupt enable
 OUT TIMSK,R20
 SEI ;enable all interrupts
 LOOP:
 ;IN R18,TCNT1L
 JMP LOOP

.ORG 0X0200
 reset:
 CPI R16,0x00
 BRNE itIsWorking
 LDI R20,0x00 ;time is 00:00
 OUT PORTA,R20
 OUT PORTB,R20
 itIsWorking:
 RETI

 .ORG 0X0300
 start:
 CPI R16,0x00
 BRNE working
 LDI R16,0x01 ;set flag that chronometer is working
 LDI R20,0x00
 OUT TCCR1A,R20
 LDI R20,0x04 ;256
 OUT TCCR1B,R20
 JMP end
 working:
 LDI R16,0x00 ;set flag that chronometer isn't working
 LDI R20,0x00
 OUT TCCR1B,R20
 end:
 RETI

.ORG 0X0400
 delay:
 IN R20,PORTA ; is second
 CPI R20,59
 BRNE notAMin ;second equal to 59
 LDI R20,0x00
 OUT PORTA,R20
 IN R20,PORTB ; is minute
 CPI R20,59
 BRNE notAnHour;minutes equal to 59
 LDI R20,0x00
 OUT PORTB,R20
 JMP finish
 notAnHour: ;minutes less than 59
 IN R20,PORTB ; is minute
 INC R20
 OUT PORTB,R20
 JMP finish
 notAMin:;second less than 59
 IN R20,PORTA ; is minute
 INC R20
 OUT PORTA,R20
 finish:
 LDI R20,HIGH(-31250) ;higher part of clock needed
 OUT TCNT1H,R20
 LDI R20,LOW(-31250) ;lower part of clock needed
 OUT TCNT1L,R20
 RETI