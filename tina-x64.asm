%define ARG0 rdi
%define ARG1 rsi
%define ARG2 rdx
%define RET rax

global tina_init_stack
tina_init_stack: ; (void* buffer, size_t size, tina_func *wrap) -> void* rsp
%push
	push rbp
	mov rbp, rsp
	
	; Calculate and align the stack top.
	add ARG0, ARG1
	and ARG0, ~0xF
	mov rsp, ARG0
	
	; Push tina_wrap() that tina_init() will yield to.
	push ARG2
	
	; Save space for the registers that tina_swap() will pop when starting the coroutine.
	; They are unitialized and unused, but this is simpler than adding a special case.
	sub rsp, 6*8
	
	; Return the updated stack pointer.
	mov RET, rsp
	leave
	ret
%pop

global tina_swap
tina_swap: ; (tina* coro, uintptr_t value, void** sp)
%push
	; Preserve calling coroutine's registers.
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	; Swap stacks.
	mov rax, rsp
	mov rsp, [ARG2]
	mov [ARG2], rax
	
	; Restore callee coroutine's registers.
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	
	; 'value' passed to the caller's tina_swap() should be returned from the callee's tina_swap() call.
	mov RET, ARG1
	; Because we swapped stacks, we will return from the callee's tina_swap() call, not the caller's.
	; Special case: 'coro' and 'value' are still in ARG0 and ARG1 to simplify calling tina_wrap() initially.
	ret
%pop