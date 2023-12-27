.thumb
.equ BibliophileID, SkillTester+4
.equ ItemTable, BibliophileID+4

.macro blh to, reg
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm

push {r4-r7, lr}
mov r4, r0 @atkr
mov r5, r1 @dfdr

@has BibliophileID
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, BibliophileID
.short 0xf800
cmp r0, #0
beq End

@Check inventory
mov		r1, #0x1E @Slot 1
mov 	r2, #0x26 @Slot 5
mov		r3, #0x0  @No. of Books

CheckLoopStart:
ldrb	r0, [r4, r1]	@Slot weapon type
cmp		r0, #0
beq		End
mov		r5, #0x24
mul		r5, r0
ldr		r6, ItemTable
add		r6, r5
ldrb 	r0, [r6, #0x07]
cmp		r0, #5			@If anima +1
beq		IsBook
cmp		r0, #6			@If light +1
beq		IsBook
cmp		r0, #7			@If dark +1
beq		IsBook
b		NoBook

IsBook:
add		r3, #0x01
cmp		r3, #0x03
bge		AddBonus

NoBook:
add		r1,#0x02
cmp		r1,r2
bgt		End
b		CheckLoopStart

AddBonus:
mov r1, #0x66
ldrh r0, [r4, r1] @AS
add r0, #10
strh r0, [r4,r1]

End:
pop {r4-r7, r15}
.align
.ltorg
SkillTester:
@Poin SkillTester
@WORD BibliophileID
@POIN ItemTable
