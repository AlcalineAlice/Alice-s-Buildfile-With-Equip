.thumb
.equ HunterID, SkillTester+4
.equ gBattleData, 0x203A4D4

.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has HunterID
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, HunterID
.short 0xf800
cmp r0, #0
beq End

ldrb r3, =gBattleData
ldrb r3, [r3]
cmp r3, #4
beq End

ldr		r0,[r5]
ldr		r0,[r0,#0x28]
ldr		r1,[r5,#0x4]
ldr		r1,[r1,#0x28]
orr		r0,r1
mov		r1,#0x1			@is defender mounted
tst		r0,r1
beq		End

add		r4,#0x5A
ldrh	r0,[r4]
add		r0,#5
strh	r0,[r4]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD HunterID
