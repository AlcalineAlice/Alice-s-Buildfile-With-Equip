.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ WitchsBrewID, SkillTester+4
.equ WitchsBrewEvent, WitchsBrewID+4
.thumb
push	{lr}

@check if dead
ldrb	r0, [r4,#0x13]
cmp	r0, #0x00
beq	End

ldr	r2,=#0x202BCF0
ldrh	r2, [r2,#0x10]
mov r0, #0x07
cmp r2, r0
bgt End

@check if wait was used
ldrb 	r0, [r6,#0x11]	@action taken this turn
cmp	r0, #0x01 @wait
bne	End
ldrb 	r0, [r6,#0x0C]	@allegiance byte of the current character taking action
ldrb	r1, [r4,#0x0B]	@allegiance byte of the character we are checking
cmp	r0, r1		@check if same character
bne	End

@check for inventory space, but only if not a player unit
cmp	r1, #0x40
blo	SkipInventoryCheck

ldr	r0,=#0x80179D8	@inventory space check routine
mov	lr, r0
mov	r0, r4		@attacker
.short	0xF800
cmp	r0, #0x04
bhi	End
SkipInventoryCheck:

@check for skill
mov	r0, r4
ldr	r1, WitchsBrewID
ldr	r3, SkillTester
mov	lr, r3
.short	0xf800
cmp	r0, #0x00
beq	End

@roll luck
ldr	r0,=#0x8019298	@luck getter
mov	lr, r0
mov	r0, r4		@attacker
.short	0xF800
ldr	r2,=#0x802a52c	@1rn routine
mov	r1, r4		@attacker
mov	lr, r2
.short	0xF800
cmp	r0, #0x01
bne	End

@successful roll, give item
Event:
ldr	r0,=#0x800D07C		@event engine thingy
mov	lr, r0
ldr	r0, WitchsBrewEvent
mov	r1, #0x01		@0x01 = wait for events
.short	0xF800

End:
pop	{r0}
bx	r0
.ltorg
.align
SkillTester:
@POIN SkillTester
@WORD WitchsBrewID
@POIN WitchsBrewEvent
