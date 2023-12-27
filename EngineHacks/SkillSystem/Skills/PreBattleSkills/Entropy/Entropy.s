.thumb
.equ EntropyID, SkillTester+4
.equ gBattleData, 0x203A4D4

.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has EntropyID
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, EntropyID
.short 0xf800
cmp r0, #0
beq End

ldrb r3, =gBattleData
ldrb r3, [r3]
cmp r3, #4
beq End

mov		r1, #0x50
ldrb	r0, [r5, r1]
cmp		r0, #0x03 @ 0, 1, 2, and 3 are physical weapons.
ble		IsWeapon
b		End

IsWeapon:
mov r1, #0x62
ldrh r0, [r4, r1] 
add r0, #25
strh r0, [r4,r1]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD EntropyID
