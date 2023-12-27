.thumb
.equ WiseTurtleID, SkillTester+4
.equ gBattleData, 0x203A4D4

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has BoldTurtle
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, WiseTurtleID
.short 0xf800
cmp r0, #0
beq End

@make sure we''re in combat (or combat prep)
ldrb r3, =gBattleData
ldrb r3, [r3]
cmp r3, #4
beq End

@ldr r0, [r4, #0x04]
@ldrb r0, [r0, #0x12] @class Mov
ldrb r0, [r4, #0x1D] @Mov bonus
@add r0, r1 @r0 contains attacker Mov

@ldr r1, [r5, #0x04]
@ldrb r1, [r1, #0x12]
ldrb r1, [r5, #0x1D] @Mov bonus
@add r1, r2 @r1 contains defender Mov

cmp r0, r1
bge End @skip if con is less or equal

mov r1, #0x5C
ldrh r0, [r4, r1] @def
add r0, #4
strh r0, [r4,r1]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD WiseTurtleID
