.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ TransmuteID, SkillTester+4
.equ TransmuteEvent, TransmuteID+4
.equ DebuffTable, TransmuteEvent+4
.equ TransmuteBit, DebuffTable+4
.equ EntrySize, TransmuteBit+4
.thumb
push	{lr}

@check if attacked this turn
ldrb 	r0, [r6,#0x11]	@action taken this turn
cmp	r0, #0x2 @attack
bne	End
ldrb 	r0, [r6,#0x0C]	@allegiance byte of the current character taking action
ldrb	r1, [r4,#0x0B]	@allegiance byte of the character we are checking
cmp	r0, r1		@check if same character
bne	End

@make sure attacker has magic weapon
ldrb  r4, =0x203A4EC
mov   r0, #0x4C    @Move to the attacker's weapon ability
ldr   r1, [r4,r0]
mov   r2, #0x42
tst   r1, r2
beq   End @do nothing if magic bit not set
mov   r0, #0x7C    @Did the attacker deal damage this round?
ldr   r1, [r4,r0]
mov   r0, #0x1
and   r1, r0
cmp   r1, #0x0
beq   End @do nothing if no damage dealt

@check if enemy has skill
mov	r0, r5
ldr	r1, TransmuteID
ldr	r3, SkillTester
mov	lr, r3
.short	0xf800
cmp	r0,#0x00
beq	End

Set:
@set the bit for this skill in the debuff table entry for the unit
ldr	r0,DebuffTable
ldrb r1,[r5,#0xB]
ldr	r2,EntrySize
mul	r1,r2
add	r0,r1		@debuff table entry for this unit
push	{r0}
ldr	r0,TransmuteBit
mov	r1,#8
swi	6		@get the byte
pop	{r2}
add	r0,r2		@byte we are modifying
mov	r2,#1
lsl	r2,r1		@bit to set
ldrb	r1,[r0]
orr	r1,r2
strb	r1,[r0]		@set the bit
b Event

Event:
ldr	r0,=0x800D07C		@event engine thingy
mov	lr, r0
ldr	r0, TransmuteEvent	@this event is just "play sound effect on current character"
mov	r1, #0x01		@0x01 = wait for events
.short	0xF800

End:
pop	{r0}
bx	r0
.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD TransmuteID
@POIN TransmuteEvent
@POIN DebuffTable
@WORD TransmuteBit
@WORD EntrySize
