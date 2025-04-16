
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
extern int thread_inc(void);
extern int thread_dec(void);

void 
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_schedule);
   6:	b8 33 00 00 00       	mov    $0x33,%eax
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	50                   	push   %eax
   f:	e8 65 05 00 00       	call   579 <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  17:	c7 05 60 0d 00 00 80 	movl   $0xd80,0xd60
  1e:	0d 00 00 
  current_thread->state = RUNNING;
  21:	a1 60 0d 00 00       	mov    0xd60,%eax
  26:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  2d:	00 00 00 
}
  30:	90                   	nop
  31:	c9                   	leave  
  32:	c3                   	ret    

00000033 <thread_schedule>:

void 
thread_schedule(void)
{ 
  33:	55                   	push   %ebp
  34:	89 e5                	mov    %esp,%ebp
  36:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  39:	c7 05 64 0d 00 00 00 	movl   $0x0,0xd64
  40:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  43:	c7 45 f4 80 0d 00 00 	movl   $0xd80,-0xc(%ebp)
  4a:	eb 29                	jmp    75 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  55:	83 f8 02             	cmp    $0x2,%eax
  58:	75 14                	jne    6e <thread_schedule+0x3b>
  5a:	a1 60 0d 00 00       	mov    0xd60,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	74 0a                	je     6e <thread_schedule+0x3b>
      next_thread = t;
  64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  67:	a3 64 0d 00 00       	mov    %eax,0xd64
      break;
  6c:	eb 11                	jmp    7f <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  6e:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  75:	b8 a0 8d 00 00       	mov    $0x8da0,%eax
  7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7d:	72 cd                	jb     4c <thread_schedule+0x19>
    }
  }
  
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  7f:	b8 a0 8d 00 00       	mov    $0x8da0,%eax
  84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  87:	72 1a                	jb     a3 <thread_schedule+0x70>
  89:	a1 60 0d 00 00       	mov    0xd60,%eax
  8e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  94:	83 f8 02             	cmp    $0x2,%eax
  97:	75 0a                	jne    a3 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  99:	a1 60 0d 00 00       	mov    0xd60,%eax
  9e:	a3 64 0d 00 00       	mov    %eax,0xd64
  }

  if (next_thread == 0) {
  a3:	a1 64 0d 00 00       	mov    0xd64,%eax
  a8:	85 c0                	test   %eax,%eax
  aa:	75 17                	jne    c3 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 1c 0a 00 00       	push   $0xa1c
  b4:	6a 02                	push   $0x2
  b6:	e8 aa 05 00 00       	call   665 <printf>
  bb:	83 c4 10             	add    $0x10,%esp
    exit();
  be:	e8 16 04 00 00       	call   4d9 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  c3:	8b 15 60 0d 00 00    	mov    0xd60,%edx
  c9:	a1 64 0d 00 00       	mov    0xd64,%eax
  ce:	39 c2                	cmp    %eax,%edx
  d0:	74 41                	je     113 <thread_schedule+0xe0>
    next_thread->state = RUNNING;
  d2:	a1 64 0d 00 00       	mov    0xd64,%eax
  d7:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  de:	00 00 00 
    if(current_thread != &all_thread[0]&&current_thread->state==RUNNING){
  e1:	a1 60 0d 00 00       	mov    0xd60,%eax
  e6:	3d 80 0d 00 00       	cmp    $0xd80,%eax
  eb:	74 1f                	je     10c <thread_schedule+0xd9>
  ed:	a1 60 0d 00 00       	mov    0xd60,%eax
  f2:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f8:	83 f8 01             	cmp    $0x1,%eax
  fb:	75 0f                	jne    10c <thread_schedule+0xd9>
      current_thread->state=RUNNABLE;
  fd:	a1 60 0d 00 00       	mov    0xd60,%eax
 102:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 109:	00 00 00 
    } 
    
    thread_switch();
 10c:	e8 45 01 00 00       	call   256 <thread_switch>
  } else
    next_thread = 0;
}
 111:	eb 0a                	jmp    11d <thread_schedule+0xea>
    next_thread = 0;
 113:	c7 05 64 0d 00 00 00 	movl   $0x0,0xd64
 11a:	00 00 00 
}
 11d:	90                   	nop
 11e:	c9                   	leave  
 11f:	c3                   	ret    

00000120 <thread_create>:

void 
thread_create(void (*func)())
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 126:	c7 45 f4 80 0d 00 00 	movl   $0xd80,-0xc(%ebp)
 12d:	eb 14                	jmp    143 <thread_create+0x23>
    if (t->state == FREE) break;
 12f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 132:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 138:	85 c0                	test   %eax,%eax
 13a:	74 13                	je     14f <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13c:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 143:	b8 a0 8d 00 00       	mov    $0x8da0,%eax
 148:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 14b:	72 e2                	jb     12f <thread_create+0xf>
 14d:	eb 01                	jmp    150 <thread_create+0x30>
    if (t->state == FREE) break;
 14f:	90                   	nop
  }

  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 150:	8b 45 f4             	mov    -0xc(%ebp),%eax
 153:	83 c0 04             	add    $0x4,%eax
 156:	05 00 20 00 00       	add    $0x2000,%eax
 15b:	89 c2                	mov    %eax,%edx
 15d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 160:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 162:	8b 45 f4             	mov    -0xc(%ebp),%eax
 165:	8b 00                	mov    (%eax),%eax
 167:	8d 50 fc             	lea    -0x4(%eax),%edx
 16a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16d:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 16f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 172:	8b 00                	mov    (%eax),%eax
 174:	89 c2                	mov    %eax,%edx
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	89 02                	mov    %eax,(%edx)
  t->sp -= 28;                             // space for registers that thread_switch expects
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	8b 00                	mov    (%eax),%eax
 180:	8d 50 e4             	lea    -0x1c(%eax),%edx
 183:	8b 45 f4             	mov    -0xc(%ebp),%eax
 186:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;  
 188:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 192:	00 00 00 
  thread_inc();
 195:	e8 e7 03 00 00       	call   581 <thread_inc>
}
 19a:	90                   	nop
 19b:	c9                   	leave  
 19c:	c3                   	ret    

0000019d <mythread>:

static void 
mythread(void)
{
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	68 42 0a 00 00       	push   $0xa42
 1ab:	6a 01                	push   $0x1
 1ad:	e8 b3 04 00 00       	call   665 <printf>
 1b2:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {  
 1b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bc:	eb 1c                	jmp    1da <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1be:	a1 60 0d 00 00       	mov    0xd60,%eax
 1c3:	83 ec 04             	sub    $0x4,%esp
 1c6:	50                   	push   %eax
 1c7:	68 55 0a 00 00       	push   $0xa55
 1cc:	6a 01                	push   $0x1
 1ce:	e8 92 04 00 00       	call   665 <printf>
 1d3:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {  
 1d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1da:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1de:	7e de                	jle    1be <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1e0:	83 ec 08             	sub    $0x8,%esp
 1e3:	68 65 0a 00 00       	push   $0xa65
 1e8:	6a 01                	push   $0x1
 1ea:	e8 76 04 00 00       	call   665 <printf>
 1ef:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1f2:	a1 60 0d 00 00       	mov    0xd60,%eax
 1f7:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1fe:	00 00 00 
  thread_dec();
 201:	e8 83 03 00 00       	call   589 <thread_dec>
  thread_schedule();
 206:	e8 28 fe ff ff       	call   33 <thread_schedule>
  
}
 20b:	90                   	nop
 20c:	c9                   	leave  
 20d:	c3                   	ret    

0000020e <main>:


int 
main(int argc, char *argv[]) 
{
 20e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 212:	83 e4 f0             	and    $0xfffffff0,%esp
 215:	ff 71 fc             	push   -0x4(%ecx)
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	51                   	push   %ecx
 21c:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 21f:	e8 dc fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	68 9d 01 00 00       	push   $0x19d
 22c:	e8 ef fe ff ff       	call   120 <thread_create>
 231:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 234:	83 ec 0c             	sub    $0xc,%esp
 237:	68 9d 01 00 00       	push   $0x19d
 23c:	e8 df fe ff ff       	call   120 <thread_create>
 241:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 244:	e8 ea fd ff ff       	call   33 <thread_schedule>
  return 0;
 249:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24e:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 251:	c9                   	leave  
 252:	8d 61 fc             	lea    -0x4(%ecx),%esp
 255:	c3                   	ret    

00000256 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	push %eax		#current_thread 레지스터 값들을 스택에 저장
 256:	50                   	push   %eax
	push %ebx
 257:	53                   	push   %ebx
	push %ecx
 258:	51                   	push   %ecx
	push %edx
 259:	52                   	push   %edx
	push %ebp
 25a:	55                   	push   %ebp
    push %esi
 25b:	56                   	push   %esi
    push %edi
 25c:	57                   	push   %edi

	movl current_thread, %eax
 25d:	a1 60 0d 00 00       	mov    0xd60,%eax
	movl %esp, (%eax)
 262:	89 20                	mov    %esp,(%eax)

	movl next_thread, %eax      # eax = next_thread  
 264:	a1 64 0d 00 00       	mov    0xd64,%eax
    movl (%eax), %esp           # esp = next_thread->sp 
 269:	8b 20                	mov    (%eax),%esp

    
    movl %eax, current_thread   # current_thread = next_thread
 26b:	a3 60 0d 00 00       	mov    %eax,0xd60

    pop %edi
 270:	5f                   	pop    %edi
    pop %esi
 271:	5e                   	pop    %esi
    pop %ebp 
 272:	5d                   	pop    %ebp
    pop %ebx
 273:	5b                   	pop    %ebx
    pop %edx
 274:	5a                   	pop    %edx
    pop %ecx
 275:	59                   	pop    %ecx
    pop %eax
 276:	58                   	pop    %eax

	movl $0, next_thread 
 277:	c7 05 64 0d 00 00 00 	movl   $0x0,0xd64
 27e:	00 00 00 
	
	ret    /* return to ra */
 281:	c3                   	ret    

00000282 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	57                   	push   %edi
 286:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 287:	8b 4d 08             	mov    0x8(%ebp),%ecx
 28a:	8b 55 10             	mov    0x10(%ebp),%edx
 28d:	8b 45 0c             	mov    0xc(%ebp),%eax
 290:	89 cb                	mov    %ecx,%ebx
 292:	89 df                	mov    %ebx,%edi
 294:	89 d1                	mov    %edx,%ecx
 296:	fc                   	cld    
 297:	f3 aa                	rep stos %al,%es:(%edi)
 299:	89 ca                	mov    %ecx,%edx
 29b:	89 fb                	mov    %edi,%ebx
 29d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2a0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2a3:	90                   	nop
 2a4:	5b                   	pop    %ebx
 2a5:	5f                   	pop    %edi
 2a6:	5d                   	pop    %ebp
 2a7:	c3                   	ret    

000002a8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2ae:	8b 45 08             	mov    0x8(%ebp),%eax
 2b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2b4:	90                   	nop
 2b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 2b8:	8d 42 01             	lea    0x1(%edx),%eax
 2bb:	89 45 0c             	mov    %eax,0xc(%ebp)
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
 2c1:	8d 48 01             	lea    0x1(%eax),%ecx
 2c4:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2c7:	0f b6 12             	movzbl (%edx),%edx
 2ca:	88 10                	mov    %dl,(%eax)
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	84 c0                	test   %al,%al
 2d1:	75 e2                	jne    2b5 <strcpy+0xd>
    ;
  return os;
 2d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d6:	c9                   	leave  
 2d7:	c3                   	ret    

000002d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2db:	eb 08                	jmp    2e5 <strcmp+0xd>
    p++, q++;
 2dd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	84 c0                	test   %al,%al
 2ed:	74 10                	je     2ff <strcmp+0x27>
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	0f b6 10             	movzbl (%eax),%edx
 2f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f8:	0f b6 00             	movzbl (%eax),%eax
 2fb:	38 c2                	cmp    %al,%dl
 2fd:	74 de                	je     2dd <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	0f b6 d0             	movzbl %al,%edx
 308:	8b 45 0c             	mov    0xc(%ebp),%eax
 30b:	0f b6 00             	movzbl (%eax),%eax
 30e:	0f b6 c8             	movzbl %al,%ecx
 311:	89 d0                	mov    %edx,%eax
 313:	29 c8                	sub    %ecx,%eax
}
 315:	5d                   	pop    %ebp
 316:	c3                   	ret    

00000317 <strlen>:

uint
strlen(char *s)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 31d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 324:	eb 04                	jmp    32a <strlen+0x13>
 326:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 32a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	01 d0                	add    %edx,%eax
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	84 c0                	test   %al,%al
 337:	75 ed                	jne    326 <strlen+0xf>
    ;
  return n;
 339:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33c:	c9                   	leave  
 33d:	c3                   	ret    

0000033e <memset>:

void*
memset(void *dst, int c, uint n)
{
 33e:	55                   	push   %ebp
 33f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 341:	8b 45 10             	mov    0x10(%ebp),%eax
 344:	50                   	push   %eax
 345:	ff 75 0c             	push   0xc(%ebp)
 348:	ff 75 08             	push   0x8(%ebp)
 34b:	e8 32 ff ff ff       	call   282 <stosb>
 350:	83 c4 0c             	add    $0xc,%esp
  return dst;
 353:	8b 45 08             	mov    0x8(%ebp),%eax
}
 356:	c9                   	leave  
 357:	c3                   	ret    

00000358 <strchr>:

char*
strchr(const char *s, char c)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 04             	sub    $0x4,%esp
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 364:	eb 14                	jmp    37a <strchr+0x22>
    if(*s == c)
 366:	8b 45 08             	mov    0x8(%ebp),%eax
 369:	0f b6 00             	movzbl (%eax),%eax
 36c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 36f:	75 05                	jne    376 <strchr+0x1e>
      return (char*)s;
 371:	8b 45 08             	mov    0x8(%ebp),%eax
 374:	eb 13                	jmp    389 <strchr+0x31>
  for(; *s; s++)
 376:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
 37d:	0f b6 00             	movzbl (%eax),%eax
 380:	84 c0                	test   %al,%al
 382:	75 e2                	jne    366 <strchr+0xe>
  return 0;
 384:	b8 00 00 00 00       	mov    $0x0,%eax
}
 389:	c9                   	leave  
 38a:	c3                   	ret    

0000038b <gets>:

char*
gets(char *buf, int max)
{
 38b:	55                   	push   %ebp
 38c:	89 e5                	mov    %esp,%ebp
 38e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 391:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 398:	eb 42                	jmp    3dc <gets+0x51>
    cc = read(0, &c, 1);
 39a:	83 ec 04             	sub    $0x4,%esp
 39d:	6a 01                	push   $0x1
 39f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3a2:	50                   	push   %eax
 3a3:	6a 00                	push   $0x0
 3a5:	e8 47 01 00 00       	call   4f1 <read>
 3aa:	83 c4 10             	add    $0x10,%esp
 3ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3b4:	7e 33                	jle    3e9 <gets+0x5e>
      break;
    buf[i++] = c;
 3b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b9:	8d 50 01             	lea    0x1(%eax),%edx
 3bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3bf:	89 c2                	mov    %eax,%edx
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	01 c2                	add    %eax,%edx
 3c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ca:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d0:	3c 0a                	cmp    $0xa,%al
 3d2:	74 16                	je     3ea <gets+0x5f>
 3d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d8:	3c 0d                	cmp    $0xd,%al
 3da:	74 0e                	je     3ea <gets+0x5f>
  for(i=0; i+1 < max; ){
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	83 c0 01             	add    $0x1,%eax
 3e2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3e5:	7f b3                	jg     39a <gets+0xf>
 3e7:	eb 01                	jmp    3ea <gets+0x5f>
      break;
 3e9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	01 d0                	add    %edx,%eax
 3f2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3f8:	c9                   	leave  
 3f9:	c3                   	ret    

000003fa <stat>:

int
stat(char *n, struct stat *st)
{
 3fa:	55                   	push   %ebp
 3fb:	89 e5                	mov    %esp,%ebp
 3fd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 400:	83 ec 08             	sub    $0x8,%esp
 403:	6a 00                	push   $0x0
 405:	ff 75 08             	push   0x8(%ebp)
 408:	e8 0c 01 00 00       	call   519 <open>
 40d:	83 c4 10             	add    $0x10,%esp
 410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 413:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 417:	79 07                	jns    420 <stat+0x26>
    return -1;
 419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 41e:	eb 25                	jmp    445 <stat+0x4b>
  r = fstat(fd, st);
 420:	83 ec 08             	sub    $0x8,%esp
 423:	ff 75 0c             	push   0xc(%ebp)
 426:	ff 75 f4             	push   -0xc(%ebp)
 429:	e8 03 01 00 00       	call   531 <fstat>
 42e:	83 c4 10             	add    $0x10,%esp
 431:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 434:	83 ec 0c             	sub    $0xc,%esp
 437:	ff 75 f4             	push   -0xc(%ebp)
 43a:	e8 c2 00 00 00       	call   501 <close>
 43f:	83 c4 10             	add    $0x10,%esp
  return r;
 442:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 445:	c9                   	leave  
 446:	c3                   	ret    

00000447 <atoi>:

int
atoi(const char *s)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 44d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 454:	eb 25                	jmp    47b <atoi+0x34>
    n = n*10 + *s++ - '0';
 456:	8b 55 fc             	mov    -0x4(%ebp),%edx
 459:	89 d0                	mov    %edx,%eax
 45b:	c1 e0 02             	shl    $0x2,%eax
 45e:	01 d0                	add    %edx,%eax
 460:	01 c0                	add    %eax,%eax
 462:	89 c1                	mov    %eax,%ecx
 464:	8b 45 08             	mov    0x8(%ebp),%eax
 467:	8d 50 01             	lea    0x1(%eax),%edx
 46a:	89 55 08             	mov    %edx,0x8(%ebp)
 46d:	0f b6 00             	movzbl (%eax),%eax
 470:	0f be c0             	movsbl %al,%eax
 473:	01 c8                	add    %ecx,%eax
 475:	83 e8 30             	sub    $0x30,%eax
 478:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	0f b6 00             	movzbl (%eax),%eax
 481:	3c 2f                	cmp    $0x2f,%al
 483:	7e 0a                	jle    48f <atoi+0x48>
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	0f b6 00             	movzbl (%eax),%eax
 48b:	3c 39                	cmp    $0x39,%al
 48d:	7e c7                	jle    456 <atoi+0xf>
  return n;
 48f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 492:	c9                   	leave  
 493:	c3                   	ret    

00000494 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 494:	55                   	push   %ebp
 495:	89 e5                	mov    %esp,%ebp
 497:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 49a:	8b 45 08             	mov    0x8(%ebp),%eax
 49d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4a6:	eb 17                	jmp    4bf <memmove+0x2b>
    *dst++ = *src++;
 4a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ab:	8d 42 01             	lea    0x1(%edx),%eax
 4ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b4:	8d 48 01             	lea    0x1(%eax),%ecx
 4b7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4ba:	0f b6 12             	movzbl (%edx),%edx
 4bd:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4bf:	8b 45 10             	mov    0x10(%ebp),%eax
 4c2:	8d 50 ff             	lea    -0x1(%eax),%edx
 4c5:	89 55 10             	mov    %edx,0x10(%ebp)
 4c8:	85 c0                	test   %eax,%eax
 4ca:	7f dc                	jg     4a8 <memmove+0x14>
  return vdst;
 4cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4cf:	c9                   	leave  
 4d0:	c3                   	ret    

000004d1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4d1:	b8 01 00 00 00       	mov    $0x1,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <exit>:
SYSCALL(exit)
 4d9:	b8 02 00 00 00       	mov    $0x2,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <wait>:
SYSCALL(wait)
 4e1:	b8 03 00 00 00       	mov    $0x3,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <pipe>:
SYSCALL(pipe)
 4e9:	b8 04 00 00 00       	mov    $0x4,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <read>:
SYSCALL(read)
 4f1:	b8 05 00 00 00       	mov    $0x5,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <write>:
SYSCALL(write)
 4f9:	b8 10 00 00 00       	mov    $0x10,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <close>:
SYSCALL(close)
 501:	b8 15 00 00 00       	mov    $0x15,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <kill>:
SYSCALL(kill)
 509:	b8 06 00 00 00       	mov    $0x6,%eax
 50e:	cd 40                	int    $0x40
 510:	c3                   	ret    

00000511 <exec>:
SYSCALL(exec)
 511:	b8 07 00 00 00       	mov    $0x7,%eax
 516:	cd 40                	int    $0x40
 518:	c3                   	ret    

00000519 <open>:
SYSCALL(open)
 519:	b8 0f 00 00 00       	mov    $0xf,%eax
 51e:	cd 40                	int    $0x40
 520:	c3                   	ret    

00000521 <mknod>:
SYSCALL(mknod)
 521:	b8 11 00 00 00       	mov    $0x11,%eax
 526:	cd 40                	int    $0x40
 528:	c3                   	ret    

00000529 <unlink>:
SYSCALL(unlink)
 529:	b8 12 00 00 00       	mov    $0x12,%eax
 52e:	cd 40                	int    $0x40
 530:	c3                   	ret    

00000531 <fstat>:
SYSCALL(fstat)
 531:	b8 08 00 00 00       	mov    $0x8,%eax
 536:	cd 40                	int    $0x40
 538:	c3                   	ret    

00000539 <link>:
SYSCALL(link)
 539:	b8 13 00 00 00       	mov    $0x13,%eax
 53e:	cd 40                	int    $0x40
 540:	c3                   	ret    

00000541 <mkdir>:
SYSCALL(mkdir)
 541:	b8 14 00 00 00       	mov    $0x14,%eax
 546:	cd 40                	int    $0x40
 548:	c3                   	ret    

00000549 <chdir>:
SYSCALL(chdir)
 549:	b8 09 00 00 00       	mov    $0x9,%eax
 54e:	cd 40                	int    $0x40
 550:	c3                   	ret    

00000551 <dup>:
SYSCALL(dup)
 551:	b8 0a 00 00 00       	mov    $0xa,%eax
 556:	cd 40                	int    $0x40
 558:	c3                   	ret    

00000559 <getpid>:
SYSCALL(getpid)
 559:	b8 0b 00 00 00       	mov    $0xb,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret    

00000561 <sbrk>:
SYSCALL(sbrk)
 561:	b8 0c 00 00 00       	mov    $0xc,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret    

00000569 <sleep>:
SYSCALL(sleep)
 569:	b8 0d 00 00 00       	mov    $0xd,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret    

00000571 <uptime>:
SYSCALL(uptime)
 571:	b8 0e 00 00 00       	mov    $0xe,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret    

00000579 <uthread_init>:
SYSCALL(uthread_init)
 579:	b8 16 00 00 00       	mov    $0x16,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret    

00000581 <thread_inc>:
SYSCALL(thread_inc)
 581:	b8 17 00 00 00       	mov    $0x17,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret    

00000589 <thread_dec>:
SYSCALL(thread_dec)
 589:	b8 18 00 00 00       	mov    $0x18,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 591:	55                   	push   %ebp
 592:	89 e5                	mov    %esp,%ebp
 594:	83 ec 18             	sub    $0x18,%esp
 597:	8b 45 0c             	mov    0xc(%ebp),%eax
 59a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 59d:	83 ec 04             	sub    $0x4,%esp
 5a0:	6a 01                	push   $0x1
 5a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5a5:	50                   	push   %eax
 5a6:	ff 75 08             	push   0x8(%ebp)
 5a9:	e8 4b ff ff ff       	call   4f9 <write>
 5ae:	83 c4 10             	add    $0x10,%esp
}
 5b1:	90                   	nop
 5b2:	c9                   	leave  
 5b3:	c3                   	ret    

000005b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5c5:	74 17                	je     5de <printint+0x2a>
 5c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5cb:	79 11                	jns    5de <printint+0x2a>
    neg = 1;
 5cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d7:	f7 d8                	neg    %eax
 5d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5dc:	eb 06                	jmp    5e4 <printint+0x30>
  } else {
    x = xx;
 5de:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5f1:	ba 00 00 00 00       	mov    $0x0,%edx
 5f6:	f7 f1                	div    %ecx
 5f8:	89 d1                	mov    %edx,%ecx
 5fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fd:	8d 50 01             	lea    0x1(%eax),%edx
 600:	89 55 f4             	mov    %edx,-0xc(%ebp)
 603:	0f b6 91 4c 0d 00 00 	movzbl 0xd4c(%ecx),%edx
 60a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 60e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 611:	8b 45 ec             	mov    -0x14(%ebp),%eax
 614:	ba 00 00 00 00       	mov    $0x0,%edx
 619:	f7 f1                	div    %ecx
 61b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 622:	75 c7                	jne    5eb <printint+0x37>
  if(neg)
 624:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 628:	74 2d                	je     657 <printint+0xa3>
    buf[i++] = '-';
 62a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62d:	8d 50 01             	lea    0x1(%eax),%edx
 630:	89 55 f4             	mov    %edx,-0xc(%ebp)
 633:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 638:	eb 1d                	jmp    657 <printint+0xa3>
    putc(fd, buf[i]);
 63a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 63d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 640:	01 d0                	add    %edx,%eax
 642:	0f b6 00             	movzbl (%eax),%eax
 645:	0f be c0             	movsbl %al,%eax
 648:	83 ec 08             	sub    $0x8,%esp
 64b:	50                   	push   %eax
 64c:	ff 75 08             	push   0x8(%ebp)
 64f:	e8 3d ff ff ff       	call   591 <putc>
 654:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 657:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 65b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 65f:	79 d9                	jns    63a <printint+0x86>
}
 661:	90                   	nop
 662:	90                   	nop
 663:	c9                   	leave  
 664:	c3                   	ret    

00000665 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 66b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 672:	8d 45 0c             	lea    0xc(%ebp),%eax
 675:	83 c0 04             	add    $0x4,%eax
 678:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 67b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 682:	e9 59 01 00 00       	jmp    7e0 <printf+0x17b>
    c = fmt[i] & 0xff;
 687:	8b 55 0c             	mov    0xc(%ebp),%edx
 68a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 68d:	01 d0                	add    %edx,%eax
 68f:	0f b6 00             	movzbl (%eax),%eax
 692:	0f be c0             	movsbl %al,%eax
 695:	25 ff 00 00 00       	and    $0xff,%eax
 69a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 69d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a1:	75 2c                	jne    6cf <printf+0x6a>
      if(c == '%'){
 6a3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a7:	75 0c                	jne    6b5 <printf+0x50>
        state = '%';
 6a9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6b0:	e9 27 01 00 00       	jmp    7dc <printf+0x177>
      } else {
        putc(fd, c);
 6b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b8:	0f be c0             	movsbl %al,%eax
 6bb:	83 ec 08             	sub    $0x8,%esp
 6be:	50                   	push   %eax
 6bf:	ff 75 08             	push   0x8(%ebp)
 6c2:	e8 ca fe ff ff       	call   591 <putc>
 6c7:	83 c4 10             	add    $0x10,%esp
 6ca:	e9 0d 01 00 00       	jmp    7dc <printf+0x177>
      }
    } else if(state == '%'){
 6cf:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6d3:	0f 85 03 01 00 00    	jne    7dc <printf+0x177>
      if(c == 'd'){
 6d9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6dd:	75 1e                	jne    6fd <printf+0x98>
        printint(fd, *ap, 10, 1);
 6df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	6a 01                	push   $0x1
 6e6:	6a 0a                	push   $0xa
 6e8:	50                   	push   %eax
 6e9:	ff 75 08             	push   0x8(%ebp)
 6ec:	e8 c3 fe ff ff       	call   5b4 <printint>
 6f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 6f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f8:	e9 d8 00 00 00       	jmp    7d5 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6fd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 701:	74 06                	je     709 <printf+0xa4>
 703:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 707:	75 1e                	jne    727 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 709:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70c:	8b 00                	mov    (%eax),%eax
 70e:	6a 00                	push   $0x0
 710:	6a 10                	push   $0x10
 712:	50                   	push   %eax
 713:	ff 75 08             	push   0x8(%ebp)
 716:	e8 99 fe ff ff       	call   5b4 <printint>
 71b:	83 c4 10             	add    $0x10,%esp
        ap++;
 71e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 722:	e9 ae 00 00 00       	jmp    7d5 <printf+0x170>
      } else if(c == 's'){
 727:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 72b:	75 43                	jne    770 <printf+0x10b>
        s = (char*)*ap;
 72d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 735:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 739:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 73d:	75 25                	jne    764 <printf+0xff>
          s = "(null)";
 73f:	c7 45 f4 76 0a 00 00 	movl   $0xa76,-0xc(%ebp)
        while(*s != 0){
 746:	eb 1c                	jmp    764 <printf+0xff>
          putc(fd, *s);
 748:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74b:	0f b6 00             	movzbl (%eax),%eax
 74e:	0f be c0             	movsbl %al,%eax
 751:	83 ec 08             	sub    $0x8,%esp
 754:	50                   	push   %eax
 755:	ff 75 08             	push   0x8(%ebp)
 758:	e8 34 fe ff ff       	call   591 <putc>
 75d:	83 c4 10             	add    $0x10,%esp
          s++;
 760:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 764:	8b 45 f4             	mov    -0xc(%ebp),%eax
 767:	0f b6 00             	movzbl (%eax),%eax
 76a:	84 c0                	test   %al,%al
 76c:	75 da                	jne    748 <printf+0xe3>
 76e:	eb 65                	jmp    7d5 <printf+0x170>
        }
      } else if(c == 'c'){
 770:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 774:	75 1d                	jne    793 <printf+0x12e>
        putc(fd, *ap);
 776:	8b 45 e8             	mov    -0x18(%ebp),%eax
 779:	8b 00                	mov    (%eax),%eax
 77b:	0f be c0             	movsbl %al,%eax
 77e:	83 ec 08             	sub    $0x8,%esp
 781:	50                   	push   %eax
 782:	ff 75 08             	push   0x8(%ebp)
 785:	e8 07 fe ff ff       	call   591 <putc>
 78a:	83 c4 10             	add    $0x10,%esp
        ap++;
 78d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 791:	eb 42                	jmp    7d5 <printf+0x170>
      } else if(c == '%'){
 793:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 797:	75 17                	jne    7b0 <printf+0x14b>
        putc(fd, c);
 799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79c:	0f be c0             	movsbl %al,%eax
 79f:	83 ec 08             	sub    $0x8,%esp
 7a2:	50                   	push   %eax
 7a3:	ff 75 08             	push   0x8(%ebp)
 7a6:	e8 e6 fd ff ff       	call   591 <putc>
 7ab:	83 c4 10             	add    $0x10,%esp
 7ae:	eb 25                	jmp    7d5 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7b0:	83 ec 08             	sub    $0x8,%esp
 7b3:	6a 25                	push   $0x25
 7b5:	ff 75 08             	push   0x8(%ebp)
 7b8:	e8 d4 fd ff ff       	call   591 <putc>
 7bd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c3:	0f be c0             	movsbl %al,%eax
 7c6:	83 ec 08             	sub    $0x8,%esp
 7c9:	50                   	push   %eax
 7ca:	ff 75 08             	push   0x8(%ebp)
 7cd:	e8 bf fd ff ff       	call   591 <putc>
 7d2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7e0:	8b 55 0c             	mov    0xc(%ebp),%edx
 7e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e6:	01 d0                	add    %edx,%eax
 7e8:	0f b6 00             	movzbl (%eax),%eax
 7eb:	84 c0                	test   %al,%al
 7ed:	0f 85 94 fe ff ff    	jne    687 <printf+0x22>
    }
  }
}
 7f3:	90                   	nop
 7f4:	90                   	nop
 7f5:	c9                   	leave  
 7f6:	c3                   	ret    

000007f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f7:	55                   	push   %ebp
 7f8:	89 e5                	mov    %esp,%ebp
 7fa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fd:	8b 45 08             	mov    0x8(%ebp),%eax
 800:	83 e8 08             	sub    $0x8,%eax
 803:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	a1 a8 8d 00 00       	mov    0x8da8,%eax
 80b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 80e:	eb 24                	jmp    834 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 818:	72 12                	jb     82c <free+0x35>
 81a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 820:	77 24                	ja     846 <free+0x4f>
 822:	8b 45 fc             	mov    -0x4(%ebp),%eax
 825:	8b 00                	mov    (%eax),%eax
 827:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 82a:	72 1a                	jb     846 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	89 45 fc             	mov    %eax,-0x4(%ebp)
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83a:	76 d4                	jbe    810 <free+0x19>
 83c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 844:	73 ca                	jae    810 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 846:	8b 45 f8             	mov    -0x8(%ebp),%eax
 849:	8b 40 04             	mov    0x4(%eax),%eax
 84c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 853:	8b 45 f8             	mov    -0x8(%ebp),%eax
 856:	01 c2                	add    %eax,%edx
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	39 c2                	cmp    %eax,%edx
 85f:	75 24                	jne    885 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 861:	8b 45 f8             	mov    -0x8(%ebp),%eax
 864:	8b 50 04             	mov    0x4(%eax),%edx
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	8b 00                	mov    (%eax),%eax
 86c:	8b 40 04             	mov    0x4(%eax),%eax
 86f:	01 c2                	add    %eax,%edx
 871:	8b 45 f8             	mov    -0x8(%ebp),%eax
 874:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 877:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87a:	8b 00                	mov    (%eax),%eax
 87c:	8b 10                	mov    (%eax),%edx
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	89 10                	mov    %edx,(%eax)
 883:	eb 0a                	jmp    88f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 10                	mov    (%eax),%edx
 88a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 40 04             	mov    0x4(%eax),%eax
 895:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 89c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89f:	01 d0                	add    %edx,%eax
 8a1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a4:	75 20                	jne    8c6 <free+0xcf>
    p->s.size += bp->s.size;
 8a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a9:	8b 50 04             	mov    0x4(%eax),%edx
 8ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8af:	8b 40 04             	mov    0x4(%eax),%eax
 8b2:	01 c2                	add    %eax,%edx
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bd:	8b 10                	mov    (%eax),%edx
 8bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c2:	89 10                	mov    %edx,(%eax)
 8c4:	eb 08                	jmp    8ce <free+0xd7>
  } else
    p->s.ptr = bp;
 8c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8cc:	89 10                	mov    %edx,(%eax)
  freep = p;
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	a3 a8 8d 00 00       	mov    %eax,0x8da8
}
 8d6:	90                   	nop
 8d7:	c9                   	leave  
 8d8:	c3                   	ret    

000008d9 <morecore>:

static Header*
morecore(uint nu)
{
 8d9:	55                   	push   %ebp
 8da:	89 e5                	mov    %esp,%ebp
 8dc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8df:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8e6:	77 07                	ja     8ef <morecore+0x16>
    nu = 4096;
 8e8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8ef:	8b 45 08             	mov    0x8(%ebp),%eax
 8f2:	c1 e0 03             	shl    $0x3,%eax
 8f5:	83 ec 0c             	sub    $0xc,%esp
 8f8:	50                   	push   %eax
 8f9:	e8 63 fc ff ff       	call   561 <sbrk>
 8fe:	83 c4 10             	add    $0x10,%esp
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 904:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 908:	75 07                	jne    911 <morecore+0x38>
    return 0;
 90a:	b8 00 00 00 00       	mov    $0x0,%eax
 90f:	eb 26                	jmp    937 <morecore+0x5e>
  hp = (Header*)p;
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 917:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91a:	8b 55 08             	mov    0x8(%ebp),%edx
 91d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 920:	8b 45 f0             	mov    -0x10(%ebp),%eax
 923:	83 c0 08             	add    $0x8,%eax
 926:	83 ec 0c             	sub    $0xc,%esp
 929:	50                   	push   %eax
 92a:	e8 c8 fe ff ff       	call   7f7 <free>
 92f:	83 c4 10             	add    $0x10,%esp
  return freep;
 932:	a1 a8 8d 00 00       	mov    0x8da8,%eax
}
 937:	c9                   	leave  
 938:	c3                   	ret    

00000939 <malloc>:

void*
malloc(uint nbytes)
{
 939:	55                   	push   %ebp
 93a:	89 e5                	mov    %esp,%ebp
 93c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93f:	8b 45 08             	mov    0x8(%ebp),%eax
 942:	83 c0 07             	add    $0x7,%eax
 945:	c1 e8 03             	shr    $0x3,%eax
 948:	83 c0 01             	add    $0x1,%eax
 94b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 94e:	a1 a8 8d 00 00       	mov    0x8da8,%eax
 953:	89 45 f0             	mov    %eax,-0x10(%ebp)
 956:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 95a:	75 23                	jne    97f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 95c:	c7 45 f0 a0 8d 00 00 	movl   $0x8da0,-0x10(%ebp)
 963:	8b 45 f0             	mov    -0x10(%ebp),%eax
 966:	a3 a8 8d 00 00       	mov    %eax,0x8da8
 96b:	a1 a8 8d 00 00       	mov    0x8da8,%eax
 970:	a3 a0 8d 00 00       	mov    %eax,0x8da0
    base.s.size = 0;
 975:	c7 05 a4 8d 00 00 00 	movl   $0x0,0x8da4
 97c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 982:	8b 00                	mov    (%eax),%eax
 984:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 987:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98a:	8b 40 04             	mov    0x4(%eax),%eax
 98d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 990:	77 4d                	ja     9df <malloc+0xa6>
      if(p->s.size == nunits)
 992:	8b 45 f4             	mov    -0xc(%ebp),%eax
 995:	8b 40 04             	mov    0x4(%eax),%eax
 998:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 99b:	75 0c                	jne    9a9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	8b 10                	mov    (%eax),%edx
 9a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a5:	89 10                	mov    %edx,(%eax)
 9a7:	eb 26                	jmp    9cf <malloc+0x96>
      else {
        p->s.size -= nunits;
 9a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ac:	8b 40 04             	mov    0x4(%eax),%eax
 9af:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9b2:	89 c2                	mov    %eax,%edx
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	8b 40 04             	mov    0x4(%eax),%eax
 9c0:	c1 e0 03             	shl    $0x3,%eax
 9c3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9cc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d2:	a3 a8 8d 00 00       	mov    %eax,0x8da8
      return (void*)(p + 1);
 9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9da:	83 c0 08             	add    $0x8,%eax
 9dd:	eb 3b                	jmp    a1a <malloc+0xe1>
    }
    if(p == freep)
 9df:	a1 a8 8d 00 00       	mov    0x8da8,%eax
 9e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9e7:	75 1e                	jne    a07 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9e9:	83 ec 0c             	sub    $0xc,%esp
 9ec:	ff 75 ec             	push   -0x14(%ebp)
 9ef:	e8 e5 fe ff ff       	call   8d9 <morecore>
 9f4:	83 c4 10             	add    $0x10,%esp
 9f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9fe:	75 07                	jne    a07 <malloc+0xce>
        return 0;
 a00:	b8 00 00 00 00       	mov    $0x0,%eax
 a05:	eb 13                	jmp    a1a <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	8b 00                	mov    (%eax),%eax
 a12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a15:	e9 6d ff ff ff       	jmp    987 <malloc+0x4e>
  }
}
 a1a:	c9                   	leave  
 a1b:	c3                   	ret    
