	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	push %eax		#current_thread 레지스터 값들을 스택에 저장
	push %ebx
	push %ecx
	push %edx
	push %ebp
    push %esi
    push %edi

	movl current_thread, %eax
	movl %esp, (%eax)

	movl next_thread, %eax      # eax = next_thread  
    movl (%eax), %esp           # esp = next_thread->sp 

    
    movl %eax, current_thread   # current_thread = next_thread

    pop %edi
    pop %esi
    pop %ebp 
    pop %ebx
    pop %edx
    pop %ecx
    pop %eax

	movl $0, next_thread 
	
	ret    /* return to ra */
