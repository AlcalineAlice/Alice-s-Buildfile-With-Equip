.equ ArmorMarchID, AuraSkillCheck+4
.equ DebuffTable, ArmorMarchID+4
.equ ArmorMarchBit, DebuffTable+4
.equ TransmuteBit, ArmorMarchBit+4
.equ EntrySize, TransmuteBit+4
.equ SkillTester, EntrySize+4
.equ ArmorMarchList, SkillTester+4
.thumb

@my really ugly hook
push	{lr}
ldr	r1,=0x8015395
mov	lr,r1
ldr	r2,=0x202BCF0
ldrb	r0,[r2,#0xF]
mov	r1,pc
add	r1,#7
push	{r1}
cmp	r0,#0x40
bx	lr
Back:

push	{r4-r6}

@unset everyone
mov	r4,#1
unsetLoop:

@unset the bit for this skill in the debuff table entry for the unit
ldr	r0,DebuffTable
mov	r1,r4
ldr	r2,EntrySize
mul	r1,r2
add	r0,r1		@debuff table entry for this unit
push	{r0}
ldr	r0,ArmorMarchBit
mov	r1,#8
swi	6		@get the byte
pop	{r2}
add	r0,r2		@byte we are modifying
mov	r2,#1
lsl	r2,r1		@bit to set
ldrb	r1,[r0]
mvn	r2,r2
and	r1,r2
strb	r1,[r0]		@unset the bit

add	r4,#1
cmp	r4,#0xB3
beq	allUnset
b	unsetLoop

allUnset:
@unset everyone (Transmute)/status effects
mov	r4,#1
ldr	 r5,=0x202BCF0
ldrb r5,[r5,#0xF]	@phase
unsetLoop2:

@unset the bit for this skill in the debuff table entry for the unit
ldr	r0,DebuffTable
mov	r1,r4
mov r6, #0x0B
ldr	r6, [r1,r6]	@allegiance bitfield
mov r3, #0x80
tst r6, r3
beq Green
cmp r5, #0x0
beq unsetBit
b NextUnit
Green:
mov r3, #0x40
tst r6, r3
beq Blue
cmp r5, #0x00
beq unsetBit
b NextUnit
Blue:
cmp r5, #0x80
bne NextUnit

unsetBit:
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
mvn	r2,r2
and	r1,r2
strb	r1,[r0]		@unset the bit

NextUnit:
add	r4,#1
cmp	r4,#0xB3
beq	allUnset2
b	unsetLoop2

allUnset2:
ldr	r2,=0x202BCF0
ldrb	r4,[r2,#0xF]	@phase
add	r4,#1

Loop:
mov	r0,r4
ldr	r1,=0x8019430	@get char data
mov	lr,r1
.short	0xf800
mov	r5,r0		@r5 = pointer to unit in ram

@check if there is a unit
cmp	r5,#0
beq	Next
ldr	r0,[r5]
cmp	r0,#0
beq	Next
ldrb	r0,[r5,#0x0C]
mov	r1,#4
and	r0,r1
cmp	r0,#0
bne	Next

@check if this unit is an armor
ldr	r0,ArmorMarchList
ldr	r1,[r5,#0x4]
ldrb	r1,[r1,#0x4]	@class id
armorLoop:
ldrb	r2,[r0]
cmp	r2,#0
beq	notArmor
cmp	r2,r1
beq	Armor
add	r0,#1
b	armorLoop

Armor:
@check for the skill from nearby units
ldr	r0,AuraSkillCheck
mov	lr,r0
mov	r0,r5		@unit to check
ldr	r1,ArmorMarchID
mov	r2,#0		@can_trade
mov	r3,#1		@range
.short	0xf800
mov	r6,r0
cmp	r6,#1
beq	Set

notArmor:
@check if the unit has the skill
ldr	r0,SkillTester
mov	lr,r0
mov	r0,r5		@unit to check
ldr	r1,ArmorMarchID
.short	0xf800
mov	r6,r0
cmp	r6,#0
beq	Set

@get nearby units
ldr	r0,AuraSkillCheck
mov	lr,r0
mov	r0,r5		@unit to check
mov	r1,#0
mov	r2,#0		@can_trade
mov	r3,#1		@range
.short	0xf800

@check if any nearby unit is an armor
ldr	r6,=0x202B256	@bugger for the nearby units
checkArmorsLoop:
ldrb	r0,[r6]
cmp	r0,#0
beq	noArmors
ldr	r1,=0x8019430	@get char data
mov	lr,r1
.short	0xf800		@r0 = pointer to unit in ram
mov	r3,r0
ldr	r0,ArmorMarchList
ldr	r1,[r3,#0x4]
ldrb	r1,[r1,#0x4]	@class id
armorLoop2:
ldrb	r2,[r0]
cmp	r2,#0
beq	checkArmorsLoopNext
cmp	r2,r1
beq	armorFound
add	r0,#1
b	armorLoop2
checkArmorsLoopNext:
add	r6,#1
b	checkArmorsLoop

noArmors:
mov	r6,#0
b	Set

armorFound:
mov	r6,#1


Set:
@set or unest the bit for this skill in the debuff table entry for the unit
ldr	r0,DebuffTable
mov	r1,r4
ldr	r2,EntrySize
mul	r1,r2
add	r0,r1		@debuff table entry for this unit
push	{r0}
ldr	r0,ArmorMarchBit
mov	r1,#8
swi	6		@get the byte
pop	{r2}
add	r0,r2		@byte we are modifying
mov	r2,#1
lsl	r2,r1		@bit to set
ldrb	r1,[r0]
cmp	r6,#0		@check if the skill check was successful or not
beq	Unset
orr	r1,r2
strb	r1,[r0]		@set the bit
b	Next

Unset:
mvn	r2,r2
and	r1,r2
strb	r1,[r0]		@unset the bit

Next:
add	r4,#1
cmp	r4,#0x3F
beq	End
cmp	r4,#0x55
beq	End
cmp	r4,#0xB3
beq	End
b	Loop


End:
pop	{r4-r6}
pop	{r0}
bx	r0

.align
.ltorg
AuraSkillCheck:
@POIN AuraSkillCheck
@WORD ArmorMarchID
@POIN DebuffTable
@WORD ArmorMarchBit
@WORD EntrySize
@POIN SkillTester
@POIN ArmorMarchList
