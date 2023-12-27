.thumb
.equ WingedRiderID, SkillTester+4
.equ FlierType, WingedRiderID+4
.equ gBattleData, 0x203A4D4

.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has WingedRiderID
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, WingedRiderID
.short 0xf800
cmp r0, #0
beq End

ldrb r3, =gBattleData
ldrb r3, [r3]
cmp r3, #4
beq End

ldr		r0, [r5, #0x04]
mov		r1, #0x50
ldrb	r0, [r0, r1]
ldr		r1, FlierType
tst		r0, r1
bne		End

mov r1, #0x62
ldrh r0, [r4, r1] 
add r0, #15
strh r0, [r4,r1]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD WingedRiderID
