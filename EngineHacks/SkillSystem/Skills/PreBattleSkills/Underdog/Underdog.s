.thumb
.equ UnderdogID, SkillTester+4
.equ gBattleData, 0x203A4D4

push	{r4-r7, lr}
mov	r4, r0 @attacker
mov	r5, r1 @defender

@make sure we are in combat (or combat prep)
ldrb	r3, =gBattleData
ldrb	r3, [r3]
cmp		r3, #4
beq		End

@has skill
ldr	r0, SkillTester
mov	lr, r0
mov	r0, r4
ldr	r1, UnderdogID
.short	0xf800
cmp	r0, #0
beq	End

ldrb r0, [r4, #0x08]
ldr r1, [r4,#4] @class
mov r2,#41
ldrb r1,[r1,r2] @loads Class Ability 2
mov r2,#0x1
and r1,r2
cmp r1,r2
bne Next1 @skip if Non Promoted
add r0, #0x14 @r0 Has Unit Level
Next1:

ldrb r1, [r5, #0x08]
ldr r2, [r5,#4] @class
mov r3,#41
ldrb r2,[r2,r3] @loads Class Ability 2
mov r3,#0x1
and r2,r3
cmp r2,r3
bne Next2 @skip if Non Promoted
add r1, #0x14 @r0 Has Unit Level
Next2:

cmp r0, r1
bge End

mov	r0, #0x60
ldrh	r1, [r4,r0]	@hit
add	r1, #15		@add 15 to hit
strh	r1, [r4,r0]

mov	r0, #0x62
ldrh	r1, [r4,r0]	@load avoid
add	r1, #15		@add 15 to avoid
strh	r1, [r4,r0]

End:
pop	{r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD UnderdogID
