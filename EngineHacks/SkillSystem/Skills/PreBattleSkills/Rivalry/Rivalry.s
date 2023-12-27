.thumb
.equ GetUnitsInRange, SkillTester+4
.equ RivalryID, GetUnitsInRange+4

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

ldr r0, SkillTester
mov lr, r0
mov r0, r4 @Attacker data
ldr r1, RivalryID
.short 0xf800
cmp r0, #0
beq End

ldr r0, GetUnitsInRange
mov lr, r0
mov r0, r4 @attacker
mov r1, #0 @are allies
mov r2, #1 @range
.short 0xf800
cmp r0, #0
beq End

mov r2, #0

Loop:

ldrb r1, [r0,r2]
cmp r1, #0
beq End
add r2, #1

mov r3,#0x48
ldr r5,CharData
sub r1,#0x1
mul r3,r1
add r5,r3

ldr r3, [r5] @char
ldr r3, [r3, #0x28] @char abilities
ldr r1, [r5,#4] @class
ldr r1, [r1,#0x28] @class abilities
orr r3, r1
mov r1, #0x40
lsl r1, #8 @0x4000 IsFemale
tst r3, r1
beq GiveBonus
b Loop

End:
pop {r4-r7}
pop {r0}
bx r0

GiveBonus:
mov r1, #0x5A
ldrh r2, [r4, r1]
add r2, #0x2
strh r2, [r4,r1]

mov r1, #0x5C
ldrh r2, [r4, r1]
add r2, #2
strh r2, [r4,r1]
b End

.align
.ltorg

CharData:
.long 0x202be4c
SkillTester:
@POIN SkillTester
@POIN GetUnitsInRange
@WORD RivalryID
