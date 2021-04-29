.global lab1

.syntax unified

// The character # can be used for immediates (numbers) 
// or if it stands at the first position of a line 
// the whole line is counted as a comment.
#define X1 #18
#define X2 #-9
#define X3 #23
#define X4 #11

#define Zalikova_Knizhka #0b1111111000010
#define Zalikova_Starshi #0x7f080000

//So, push{lr} is putting the return address, in the link register, 
//onto the stack when the subroutine is called.
//pop{pc} is fetching that return address off the stack and putting 
//it into the program counter, thus returning control back to the place the subroutine was called from.

lab1:
	// lr - link register
	// used to hold the return address for a func call
	push {lr}
	// bl - move to calc and save return address to LR
	bl calc
	
	bl second_task
	// pc - program counter or r15
	pop {pc}
	
calc:
	push {lr}
	mov r0, X1
	mov r1, #0
	
	mov r2, X2
	mov r3, #0xFFFFFFFF
	
	mov r4, X3
	mov r5, #0
	
	mov r6, X4
	mov r7, #0
	// 16 * ((X1 - 1) & X2) - (X3 + X4) / 4
	
	// X1 - 1
	sub r0, #1
	sbc r1, #1
	
	// (X1 - 1) & X2
	and r0, r2
	and r1, r3
	
	// 16 * ((X1 - 1) & X2)
	lsl r0, #4
	lsl r1, #4

	// X3 + X4
	add r4, r6
	adc r5, r7
	
	// (X3 + X4) / 4
	asr r4, #2
	lsr r5, #2
	
	// 16 * ((X1 - 1) & X2) - (X3 + X4) / 4
	sub r0, r4
	sbc r1, r5
	
	bl step1
	pop {pc}
	
// Перевірити ознаку результату (F) переповнення за межі розрядної сітки, 
// якщо було переповнення виконати корекцію результату шляхом зсуву результату 
// праворуч і запису значення переповнення в старший розряд, якщо ні, перейти на крок 2
step1:
	push {lr}
	//jump if no carry
	bvc step2
	lsr r0, #1
	lsrs r1, #1
	
	adc r8, #0
	lsl r8, #31
	orr r0, r8
	
step2:
	orr r0, #0
	bne step4

step3:
	ldr r0, =Zalikova_Starshi
	
step4:
	ldr r7, =Zalikova_Knizhka
	add r1, r7

step5: 
	and r5, r1, #0xc0000000
	beq step7
	eor r5, #0xc0000000
	beq step7

step6:
	lsr r0, #1
	lsr r1, #1
	
step7:
	bvs end_correction
	push {r0}
	push {r1}
	pop {r1}
	pop {r0}
	
end_correction:
	pop {pc}

second_task:
	push {lr}
	
	mov r1, #20
	mov r2, #2
first_scheme:
	// 1: r0 = r1 * r2
	mul r0, r1, r2
	
	bl second_scheme
	
	// 2: r0 = r1 + r1
	add r0, r1, r1

jump8_false:
	// 3: r2 = r2 * 2
	lsl r2, #2
	
	// 4: jump1
	beq jump4_false
	
	// 6: r0 = r1 + #0xFFFFFFFF
	adds r0, r1, #0xFFFFFFFF
	b jump8
	
jump4_false:
	// 5: r0 = r0 + 20
	add r0, #20
	// 7: r1 = r2 - 2
	sub r1, #2
	
jump8:
	// 8: jump8_false
	bls jump8_false
	// 9: r0 = r1 | r2
	orr r0, r1, r2
	
	//finishing
	pop {pc}
	
second_scheme:
	push {lr}

jump13_false:
	// 10: r1 = r1 + 1
	adds r1, #1
	// 11: jump11
	bpl jump11
	
	// XI
	bl third_scheme

	// 12: r1 = r1 + r2
	add r1, r2
	
jump11:
	// 13: jump13_false
	beq jump13_false
	// 14: r0 = r2 * r2
	mul r0, r2, r2
	// 15: r0 = r0 - r1
	sub r0, r1
	pop {pc}
	
third_scheme:
	push {lr}
	// 17: r2 = 0
	mov r2, #5
	
	// 18: r0 = r2 / r1
	udiv r0, r2, r1
	pop {pc}
	
//n last operation returns negative 
//z result operation returns 0 
//c carry
//v overflow
