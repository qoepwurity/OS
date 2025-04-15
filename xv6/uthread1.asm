
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
extern void thread_schedule(void);
//extern int check_counter(int op);

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
   f:	e8 bc 05 00 00       	call   5d0 <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  17:	c7 05 20 0e 00 00 40 	movl   $0xe40,0xe20
  1e:	0e 00 00 
  current_thread->state = RUNNING;
  21:	a1 20 0e 00 00       	mov    0xe20,%eax
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
  39:	c7 05 24 0e 00 00 00 	movl   $0x0,0xe24
  40:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  43:	c7 45 f4 40 0e 00 00 	movl   $0xe40,-0xc(%ebp)
  4a:	eb 29                	jmp    75 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  55:	83 f8 02             	cmp    $0x2,%eax
  58:	75 14                	jne    6e <thread_schedule+0x3b>
  5a:	a1 20 0e 00 00       	mov    0xe20,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	74 0a                	je     6e <thread_schedule+0x3b>
      next_thread = t;
  64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  67:	a3 24 0e 00 00       	mov    %eax,0xe24
      break;
  6c:	eb 11                	jmp    7f <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  6e:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  75:	b8 60 8e 00 00       	mov    $0x8e60,%eax
  7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7d:	72 cd                	jb     4c <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  7f:	b8 60 8e 00 00       	mov    $0x8e60,%eax
  84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  87:	72 1a                	jb     a3 <thread_schedule+0x70>
  89:	a1 20 0e 00 00       	mov    0xe20,%eax
  8e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  94:	83 f8 02             	cmp    $0x2,%eax
  97:	75 0a                	jne    a3 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  99:	a1 20 0e 00 00       	mov    0xe20,%eax
  9e:	a3 24 0e 00 00       	mov    %eax,0xe24
  }

  if (next_thread == 0) {
  a3:	a1 24 0e 00 00       	mov    0xe24,%eax
  a8:	85 c0                	test   %eax,%eax
  aa:	75 17                	jne    c3 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  ac:	83 ec 08             	sub    $0x8,%esp
  af:	68 6c 0a 00 00       	push   $0xa6c
  b4:	6a 02                	push   $0x2
  b6:	e8 f9 05 00 00       	call   6b4 <printf>
  bb:	83 c4 10             	add    $0x10,%esp
    exit();
  be:	e8 6d 04 00 00       	call   530 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  c3:	8b 15 20 0e 00 00    	mov    0xe20,%edx
  c9:	a1 24 0e 00 00       	mov    0xe24,%eax
  ce:	39 c2                	cmp    %eax,%edx
  d0:	74 41                	je     113 <thread_schedule+0xe0>
    next_thread->state = RUNNING;
  d2:	a1 24 0e 00 00       	mov    0xe24,%eax
  d7:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  de:	00 00 00 
    if (current_thread != &all_thread[0]) {
  e1:	a1 20 0e 00 00       	mov    0xe20,%eax
  e6:	3d 40 0e 00 00       	cmp    $0xe40,%eax
  eb:	74 1f                	je     10c <thread_schedule+0xd9>
      if (current_thread->state == RUNNING) {
  ed:	a1 20 0e 00 00       	mov    0xe20,%eax
  f2:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f8:	83 f8 01             	cmp    $0x1,%eax
  fb:	75 0f                	jne    10c <thread_schedule+0xd9>
        current_thread->state = RUNNABLE;
  fd:	a1 20 0e 00 00       	mov    0xe20,%eax
 102:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 109:	00 00 00 
      }
    }
    thread_switch();
 10c:	e8 a3 01 00 00       	call   2b4 <thread_switch>
  } else
    next_thread = 0;
}
 111:	eb 0a                	jmp    11d <thread_schedule+0xea>
    next_thread = 0;
 113:	c7 05 24 0e 00 00 00 	movl   $0x0,0xe24
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
 126:	c7 45 f4 40 0e 00 00 	movl   $0xe40,-0xc(%ebp)
 12d:	eb 14                	jmp    143 <thread_create+0x23>
    if (t->state == FREE) break;
 12f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 132:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 138:	85 c0                	test   %eax,%eax
 13a:	74 13                	je     14f <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13c:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 143:	b8 60 8e 00 00       	mov    $0x8e60,%eax
 148:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 14b:	72 e2                	jb     12f <thread_create+0xf>
 14d:	eb 01                	jmp    150 <thread_create+0x30>
    if (t->state == FREE) break;
 14f:	90                   	nop
  }

  if (t == all_thread + MAX_THREAD) {
 150:	b8 60 8e 00 00       	mov    $0x8e60,%eax
 155:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 158:	75 14                	jne    16e <thread_create+0x4e>
    printf(1, "thread_create: no available slot\n");
 15a:	83 ec 08             	sub    $0x8,%esp
 15d:	68 94 0a 00 00       	push   $0xa94
 162:	6a 01                	push   $0x1
 164:	e8 4b 05 00 00       	call   6b4 <printf>
 169:	83 c4 10             	add    $0x10,%esp
    return;
 16c:	eb 71                	jmp    1df <thread_create+0xbf>
  }
    t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 16e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 171:	83 c0 04             	add    $0x4,%eax
 174:	05 00 20 00 00       	add    $0x2000,%eax
 179:	89 c2                	mov    %eax,%edx
 17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17e:	89 10                	mov    %edx,(%eax)
    t->sp -= 4;                              // space for return address
 180:	8b 45 f4             	mov    -0xc(%ebp),%eax
 183:	8b 00                	mov    (%eax),%eax
 185:	8d 50 fc             	lea    -0x4(%eax),%edx
 188:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18b:	89 10                	mov    %edx,(%eax)
    *(void **)(t->sp) = func;
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	8b 00                	mov    (%eax),%eax
 192:	89 c2                	mov    %eax,%edx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	89 02                	mov    %eax,(%edx)
    t->sp -= 32;                             // space for registers that thread_switch expects
 199:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19c:	8b 00                	mov    (%eax),%eax
 19e:	8d 50 e0             	lea    -0x20(%eax),%edx
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	89 10                	mov    %edx,(%eax)
    t->state = RUNNABLE;  
 1a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a9:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1b0:	00 00 00 
    check_counter(+1);
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	6a 01                	push   $0x1
 1b8:	e8 1b 04 00 00       	call   5d8 <check_counter>
 1bd:	83 c4 10             	add    $0x10,%esp

  printf(1, "thread_create: t=0x%x sp=0x%x func=0x%x\n", t, t->sp, (int)func);
 1c0:	8b 55 08             	mov    0x8(%ebp),%edx
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	8b 00                	mov    (%eax),%eax
 1c8:	83 ec 0c             	sub    $0xc,%esp
 1cb:	52                   	push   %edx
 1cc:	50                   	push   %eax
 1cd:	ff 75 f4             	push   -0xc(%ebp)
 1d0:	68 b8 0a 00 00       	push   $0xab8
 1d5:	6a 01                	push   $0x1
 1d7:	e8 d8 04 00 00       	call   6b4 <printf>
 1dc:	83 c4 20             	add    $0x20,%esp
}
 1df:	c9                   	leave  
 1e0:	c3                   	ret    

000001e1 <mythread>:

void 
mythread(void)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1e7:	83 ec 08             	sub    $0x8,%esp
 1ea:	68 e1 0a 00 00       	push   $0xae1
 1ef:	6a 01                	push   $0x1
 1f1:	e8 be 04 00 00       	call   6b4 <printf>
 1f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 200:	eb 1c                	jmp    21e <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 202:	a1 20 0e 00 00       	mov    0xe20,%eax
 207:	83 ec 04             	sub    $0x4,%esp
 20a:	50                   	push   %eax
 20b:	68 f4 0a 00 00       	push   $0xaf4
 210:	6a 01                	push   $0x1
 212:	e8 9d 04 00 00       	call   6b4 <printf>
 217:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 21a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 21e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 222:	7e de                	jle    202 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 224:	83 ec 08             	sub    $0x8,%esp
 227:	68 04 0b 00 00       	push   $0xb04
 22c:	6a 01                	push   $0x1
 22e:	e8 81 04 00 00       	call   6b4 <printf>
 233:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 236:	a1 20 0e 00 00       	mov    0xe20,%eax
 23b:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 242:	00 00 00 

  check_counter(-1);
 245:	83 ec 0c             	sub    $0xc,%esp
 248:	6a ff                	push   $0xffffffff
 24a:	e8 89 03 00 00       	call   5d8 <check_counter>
 24f:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 252:	e8 dc fd ff ff       	call   33 <thread_schedule>
}
 257:	90                   	nop
 258:	c9                   	leave  
 259:	c3                   	ret    

0000025a <main>:

int 
main(int argc, char *argv[]) 
{
 25a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 25e:	83 e4 f0             	and    $0xfffffff0,%esp
 261:	ff 71 fc             	push   -0x4(%ecx)
 264:	55                   	push   %ebp
 265:	89 e5                	mov    %esp,%ebp
 267:	51                   	push   %ecx
 268:	83 ec 04             	sub    $0x4,%esp
  printf(1, "main start\n");
 26b:	83 ec 08             	sub    $0x8,%esp
 26e:	68 15 0b 00 00       	push   $0xb15
 273:	6a 01                	push   $0x1
 275:	e8 3a 04 00 00       	call   6b4 <printf>
 27a:	83 c4 10             	add    $0x10,%esp
  thread_init();
 27d:	e8 7e fd ff ff       	call   0 <thread_init>
  thread_create((void (*)())mythread);
 282:	83 ec 0c             	sub    $0xc,%esp
 285:	68 e1 01 00 00       	push   $0x1e1
 28a:	e8 91 fe ff ff       	call   120 <thread_create>
 28f:	83 c4 10             	add    $0x10,%esp
  thread_create((void (*)())mythread);
 292:	83 ec 0c             	sub    $0xc,%esp
 295:	68 e1 01 00 00       	push   $0x1e1
 29a:	e8 81 fe ff ff       	call   120 <thread_create>
 29f:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 2a2:	e8 8c fd ff ff       	call   33 <thread_schedule>
  return 0;
 2a7:	b8 00 00 00 00       	mov    $0x0,%eax
 2ac:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2af:	c9                   	leave  
 2b0:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2b3:	c3                   	ret    

000002b4 <thread_switch>:
 2b4:	60                   	pusha  
 2b5:	a1 20 0e 00 00       	mov    0xe20,%eax
 2ba:	89 20                	mov    %esp,(%eax)
 2bc:	a1 24 0e 00 00       	mov    0xe24,%eax
 2c1:	8b 20                	mov    (%eax),%esp
 2c3:	a1 24 0e 00 00       	mov    0xe24,%eax
 2c8:	a3 20 0e 00 00       	mov    %eax,0xe20
 2cd:	61                   	popa   
 2ce:	c7 05 24 0e 00 00 00 	movl   $0x0,0xe24
 2d5:	00 00 00 
 2d8:	c3                   	ret    

000002d9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2d9:	55                   	push   %ebp
 2da:	89 e5                	mov    %esp,%ebp
 2dc:	57                   	push   %edi
 2dd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2de:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2e1:	8b 55 10             	mov    0x10(%ebp),%edx
 2e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e7:	89 cb                	mov    %ecx,%ebx
 2e9:	89 df                	mov    %ebx,%edi
 2eb:	89 d1                	mov    %edx,%ecx
 2ed:	fc                   	cld    
 2ee:	f3 aa                	rep stos %al,%es:(%edi)
 2f0:	89 ca                	mov    %ecx,%edx
 2f2:	89 fb                	mov    %edi,%ebx
 2f4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2f7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2fa:	90                   	nop
 2fb:	5b                   	pop    %ebx
 2fc:	5f                   	pop    %edi
 2fd:	5d                   	pop    %ebp
 2fe:	c3                   	ret    

000002ff <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2ff:	55                   	push   %ebp
 300:	89 e5                	mov    %esp,%ebp
 302:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 30b:	90                   	nop
 30c:	8b 55 0c             	mov    0xc(%ebp),%edx
 30f:	8d 42 01             	lea    0x1(%edx),%eax
 312:	89 45 0c             	mov    %eax,0xc(%ebp)
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	8d 48 01             	lea    0x1(%eax),%ecx
 31b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 31e:	0f b6 12             	movzbl (%edx),%edx
 321:	88 10                	mov    %dl,(%eax)
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	84 c0                	test   %al,%al
 328:	75 e2                	jne    30c <strcpy+0xd>
    ;
  return os;
 32a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32d:	c9                   	leave  
 32e:	c3                   	ret    

0000032f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 32f:	55                   	push   %ebp
 330:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 332:	eb 08                	jmp    33c <strcmp+0xd>
    p++, q++;
 334:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 338:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	84 c0                	test   %al,%al
 344:	74 10                	je     356 <strcmp+0x27>
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	0f b6 10             	movzbl (%eax),%edx
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	38 c2                	cmp    %al,%dl
 354:	74 de                	je     334 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 356:	8b 45 08             	mov    0x8(%ebp),%eax
 359:	0f b6 00             	movzbl (%eax),%eax
 35c:	0f b6 d0             	movzbl %al,%edx
 35f:	8b 45 0c             	mov    0xc(%ebp),%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	0f b6 c8             	movzbl %al,%ecx
 368:	89 d0                	mov    %edx,%eax
 36a:	29 c8                	sub    %ecx,%eax
}
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    

0000036e <strlen>:

uint
strlen(char *s)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
 371:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 374:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 37b:	eb 04                	jmp    381 <strlen+0x13>
 37d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 381:	8b 55 fc             	mov    -0x4(%ebp),%edx
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	01 d0                	add    %edx,%eax
 389:	0f b6 00             	movzbl (%eax),%eax
 38c:	84 c0                	test   %al,%al
 38e:	75 ed                	jne    37d <strlen+0xf>
    ;
  return n;
 390:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 393:	c9                   	leave  
 394:	c3                   	ret    

00000395 <memset>:

void*
memset(void *dst, int c, uint n)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 398:	8b 45 10             	mov    0x10(%ebp),%eax
 39b:	50                   	push   %eax
 39c:	ff 75 0c             	push   0xc(%ebp)
 39f:	ff 75 08             	push   0x8(%ebp)
 3a2:	e8 32 ff ff ff       	call   2d9 <stosb>
 3a7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ad:	c9                   	leave  
 3ae:	c3                   	ret    

000003af <strchr>:

char*
strchr(const char *s, char c)
{
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 04             	sub    $0x4,%esp
 3b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3bb:	eb 14                	jmp    3d1 <strchr+0x22>
    if(*s == c)
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
 3c0:	0f b6 00             	movzbl (%eax),%eax
 3c3:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3c6:	75 05                	jne    3cd <strchr+0x1e>
      return (char*)s;
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	eb 13                	jmp    3e0 <strchr+0x31>
  for(; *s; s++)
 3cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	0f b6 00             	movzbl (%eax),%eax
 3d7:	84 c0                	test   %al,%al
 3d9:	75 e2                	jne    3bd <strchr+0xe>
  return 0;
 3db:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <gets>:

char*
gets(char *buf, int max)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3ef:	eb 42                	jmp    433 <gets+0x51>
    cc = read(0, &c, 1);
 3f1:	83 ec 04             	sub    $0x4,%esp
 3f4:	6a 01                	push   $0x1
 3f6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3f9:	50                   	push   %eax
 3fa:	6a 00                	push   $0x0
 3fc:	e8 47 01 00 00       	call   548 <read>
 401:	83 c4 10             	add    $0x10,%esp
 404:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40b:	7e 33                	jle    440 <gets+0x5e>
      break;
    buf[i++] = c;
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	8d 50 01             	lea    0x1(%eax),%edx
 413:	89 55 f4             	mov    %edx,-0xc(%ebp)
 416:	89 c2                	mov    %eax,%edx
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	01 c2                	add    %eax,%edx
 41d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 421:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 423:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 427:	3c 0a                	cmp    $0xa,%al
 429:	74 16                	je     441 <gets+0x5f>
 42b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 42f:	3c 0d                	cmp    $0xd,%al
 431:	74 0e                	je     441 <gets+0x5f>
  for(i=0; i+1 < max; ){
 433:	8b 45 f4             	mov    -0xc(%ebp),%eax
 436:	83 c0 01             	add    $0x1,%eax
 439:	39 45 0c             	cmp    %eax,0xc(%ebp)
 43c:	7f b3                	jg     3f1 <gets+0xf>
 43e:	eb 01                	jmp    441 <gets+0x5f>
      break;
 440:	90                   	nop
      break;
  }
  buf[i] = '\0';
 441:	8b 55 f4             	mov    -0xc(%ebp),%edx
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	01 d0                	add    %edx,%eax
 449:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 44f:	c9                   	leave  
 450:	c3                   	ret    

00000451 <stat>:

int
stat(char *n, struct stat *st)
{
 451:	55                   	push   %ebp
 452:	89 e5                	mov    %esp,%ebp
 454:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 457:	83 ec 08             	sub    $0x8,%esp
 45a:	6a 00                	push   $0x0
 45c:	ff 75 08             	push   0x8(%ebp)
 45f:	e8 0c 01 00 00       	call   570 <open>
 464:	83 c4 10             	add    $0x10,%esp
 467:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 46a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 46e:	79 07                	jns    477 <stat+0x26>
    return -1;
 470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 475:	eb 25                	jmp    49c <stat+0x4b>
  r = fstat(fd, st);
 477:	83 ec 08             	sub    $0x8,%esp
 47a:	ff 75 0c             	push   0xc(%ebp)
 47d:	ff 75 f4             	push   -0xc(%ebp)
 480:	e8 03 01 00 00       	call   588 <fstat>
 485:	83 c4 10             	add    $0x10,%esp
 488:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 48b:	83 ec 0c             	sub    $0xc,%esp
 48e:	ff 75 f4             	push   -0xc(%ebp)
 491:	e8 c2 00 00 00       	call   558 <close>
 496:	83 c4 10             	add    $0x10,%esp
  return r;
 499:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 49c:	c9                   	leave  
 49d:	c3                   	ret    

0000049e <atoi>:

int
atoi(const char *s)
{
 49e:	55                   	push   %ebp
 49f:	89 e5                	mov    %esp,%ebp
 4a1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4a4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ab:	eb 25                	jmp    4d2 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4b0:	89 d0                	mov    %edx,%eax
 4b2:	c1 e0 02             	shl    $0x2,%eax
 4b5:	01 d0                	add    %edx,%eax
 4b7:	01 c0                	add    %eax,%eax
 4b9:	89 c1                	mov    %eax,%ecx
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	8d 50 01             	lea    0x1(%eax),%edx
 4c1:	89 55 08             	mov    %edx,0x8(%ebp)
 4c4:	0f b6 00             	movzbl (%eax),%eax
 4c7:	0f be c0             	movsbl %al,%eax
 4ca:	01 c8                	add    %ecx,%eax
 4cc:	83 e8 30             	sub    $0x30,%eax
 4cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	0f b6 00             	movzbl (%eax),%eax
 4d8:	3c 2f                	cmp    $0x2f,%al
 4da:	7e 0a                	jle    4e6 <atoi+0x48>
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	0f b6 00             	movzbl (%eax),%eax
 4e2:	3c 39                	cmp    $0x39,%al
 4e4:	7e c7                	jle    4ad <atoi+0xf>
  return n;
 4e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e9:	c9                   	leave  
 4ea:	c3                   	ret    

000004eb <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4eb:	55                   	push   %ebp
 4ec:	89 e5                	mov    %esp,%ebp
 4ee:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4fd:	eb 17                	jmp    516 <memmove+0x2b>
    *dst++ = *src++;
 4ff:	8b 55 f8             	mov    -0x8(%ebp),%edx
 502:	8d 42 01             	lea    0x1(%edx),%eax
 505:	89 45 f8             	mov    %eax,-0x8(%ebp)
 508:	8b 45 fc             	mov    -0x4(%ebp),%eax
 50b:	8d 48 01             	lea    0x1(%eax),%ecx
 50e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 511:	0f b6 12             	movzbl (%edx),%edx
 514:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 516:	8b 45 10             	mov    0x10(%ebp),%eax
 519:	8d 50 ff             	lea    -0x1(%eax),%edx
 51c:	89 55 10             	mov    %edx,0x10(%ebp)
 51f:	85 c0                	test   %eax,%eax
 521:	7f dc                	jg     4ff <memmove+0x14>
  return vdst;
 523:	8b 45 08             	mov    0x8(%ebp),%eax
}
 526:	c9                   	leave  
 527:	c3                   	ret    

00000528 <fork>:
 528:	b8 01 00 00 00       	mov    $0x1,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <exit>:
 530:	b8 02 00 00 00       	mov    $0x2,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <wait>:
 538:	b8 03 00 00 00       	mov    $0x3,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <pipe>:
 540:	b8 04 00 00 00       	mov    $0x4,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <read>:
 548:	b8 05 00 00 00       	mov    $0x5,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <write>:
 550:	b8 10 00 00 00       	mov    $0x10,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <close>:
 558:	b8 15 00 00 00       	mov    $0x15,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <kill>:
 560:	b8 06 00 00 00       	mov    $0x6,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <exec>:
 568:	b8 07 00 00 00       	mov    $0x7,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <open>:
 570:	b8 0f 00 00 00       	mov    $0xf,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <mknod>:
 578:	b8 11 00 00 00       	mov    $0x11,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <unlink>:
 580:	b8 12 00 00 00       	mov    $0x12,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <fstat>:
 588:	b8 08 00 00 00       	mov    $0x8,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <link>:
 590:	b8 13 00 00 00       	mov    $0x13,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <mkdir>:
 598:	b8 14 00 00 00       	mov    $0x14,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <chdir>:
 5a0:	b8 09 00 00 00       	mov    $0x9,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <dup>:
 5a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <getpid>:
 5b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <sbrk>:
 5b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <sleep>:
 5c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <uptime>:
 5c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <uthread_init>:
 5d0:	b8 16 00 00 00       	mov    $0x16,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <check_counter>:
 5d8:	b8 17 00 00 00       	mov    $0x17,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	83 ec 18             	sub    $0x18,%esp
 5e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ec:	83 ec 04             	sub    $0x4,%esp
 5ef:	6a 01                	push   $0x1
 5f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	push   0x8(%ebp)
 5f8:	e8 53 ff ff ff       	call   550 <write>
 5fd:	83 c4 10             	add    $0x10,%esp
}
 600:	90                   	nop
 601:	c9                   	leave  
 602:	c3                   	ret    

00000603 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 603:	55                   	push   %ebp
 604:	89 e5                	mov    %esp,%ebp
 606:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 609:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 610:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 614:	74 17                	je     62d <printint+0x2a>
 616:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 61a:	79 11                	jns    62d <printint+0x2a>
    neg = 1;
 61c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 623:	8b 45 0c             	mov    0xc(%ebp),%eax
 626:	f7 d8                	neg    %eax
 628:	89 45 ec             	mov    %eax,-0x14(%ebp)
 62b:	eb 06                	jmp    633 <printint+0x30>
  } else {
    x = xx;
 62d:	8b 45 0c             	mov    0xc(%ebp),%eax
 630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 633:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 63a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 640:	ba 00 00 00 00       	mov    $0x0,%edx
 645:	f7 f1                	div    %ecx
 647:	89 d1                	mov    %edx,%ecx
 649:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64c:	8d 50 01             	lea    0x1(%eax),%edx
 64f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 652:	0f b6 91 f4 0d 00 00 	movzbl 0xdf4(%ecx),%edx
 659:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 65d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 660:	8b 45 ec             	mov    -0x14(%ebp),%eax
 663:	ba 00 00 00 00       	mov    $0x0,%edx
 668:	f7 f1                	div    %ecx
 66a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 66d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 671:	75 c7                	jne    63a <printint+0x37>
  if(neg)
 673:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 677:	74 2d                	je     6a6 <printint+0xa3>
    buf[i++] = '-';
 679:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67c:	8d 50 01             	lea    0x1(%eax),%edx
 67f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 682:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 687:	eb 1d                	jmp    6a6 <printint+0xa3>
    putc(fd, buf[i]);
 689:	8d 55 dc             	lea    -0x24(%ebp),%edx
 68c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68f:	01 d0                	add    %edx,%eax
 691:	0f b6 00             	movzbl (%eax),%eax
 694:	0f be c0             	movsbl %al,%eax
 697:	83 ec 08             	sub    $0x8,%esp
 69a:	50                   	push   %eax
 69b:	ff 75 08             	push   0x8(%ebp)
 69e:	e8 3d ff ff ff       	call   5e0 <putc>
 6a3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6a6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ae:	79 d9                	jns    689 <printint+0x86>
}
 6b0:	90                   	nop
 6b1:	90                   	nop
 6b2:	c9                   	leave  
 6b3:	c3                   	ret    

000006b4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c1:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c4:	83 c0 04             	add    $0x4,%eax
 6c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d1:	e9 59 01 00 00       	jmp    82f <printf+0x17b>
    c = fmt[i] & 0xff;
 6d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6dc:	01 d0                	add    %edx,%eax
 6de:	0f b6 00             	movzbl (%eax),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	25 ff 00 00 00       	and    $0xff,%eax
 6e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f0:	75 2c                	jne    71e <printf+0x6a>
      if(c == '%'){
 6f2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f6:	75 0c                	jne    704 <printf+0x50>
        state = '%';
 6f8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6ff:	e9 27 01 00 00       	jmp    82b <printf+0x177>
      } else {
        putc(fd, c);
 704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 707:	0f be c0             	movsbl %al,%eax
 70a:	83 ec 08             	sub    $0x8,%esp
 70d:	50                   	push   %eax
 70e:	ff 75 08             	push   0x8(%ebp)
 711:	e8 ca fe ff ff       	call   5e0 <putc>
 716:	83 c4 10             	add    $0x10,%esp
 719:	e9 0d 01 00 00       	jmp    82b <printf+0x177>
      }
    } else if(state == '%'){
 71e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 722:	0f 85 03 01 00 00    	jne    82b <printf+0x177>
      if(c == 'd'){
 728:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 72c:	75 1e                	jne    74c <printf+0x98>
        printint(fd, *ap, 10, 1);
 72e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 731:	8b 00                	mov    (%eax),%eax
 733:	6a 01                	push   $0x1
 735:	6a 0a                	push   $0xa
 737:	50                   	push   %eax
 738:	ff 75 08             	push   0x8(%ebp)
 73b:	e8 c3 fe ff ff       	call   603 <printint>
 740:	83 c4 10             	add    $0x10,%esp
        ap++;
 743:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 747:	e9 d8 00 00 00       	jmp    824 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 74c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 750:	74 06                	je     758 <printf+0xa4>
 752:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 756:	75 1e                	jne    776 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 758:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	6a 00                	push   $0x0
 75f:	6a 10                	push   $0x10
 761:	50                   	push   %eax
 762:	ff 75 08             	push   0x8(%ebp)
 765:	e8 99 fe ff ff       	call   603 <printint>
 76a:	83 c4 10             	add    $0x10,%esp
        ap++;
 76d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 771:	e9 ae 00 00 00       	jmp    824 <printf+0x170>
      } else if(c == 's'){
 776:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 77a:	75 43                	jne    7bf <printf+0x10b>
        s = (char*)*ap;
 77c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 77f:	8b 00                	mov    (%eax),%eax
 781:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 784:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 788:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 78c:	75 25                	jne    7b3 <printf+0xff>
          s = "(null)";
 78e:	c7 45 f4 21 0b 00 00 	movl   $0xb21,-0xc(%ebp)
        while(*s != 0){
 795:	eb 1c                	jmp    7b3 <printf+0xff>
          putc(fd, *s);
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	0f b6 00             	movzbl (%eax),%eax
 79d:	0f be c0             	movsbl %al,%eax
 7a0:	83 ec 08             	sub    $0x8,%esp
 7a3:	50                   	push   %eax
 7a4:	ff 75 08             	push   0x8(%ebp)
 7a7:	e8 34 fe ff ff       	call   5e0 <putc>
 7ac:	83 c4 10             	add    $0x10,%esp
          s++;
 7af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b6:	0f b6 00             	movzbl (%eax),%eax
 7b9:	84 c0                	test   %al,%al
 7bb:	75 da                	jne    797 <printf+0xe3>
 7bd:	eb 65                	jmp    824 <printf+0x170>
        }
      } else if(c == 'c'){
 7bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c3:	75 1d                	jne    7e2 <printf+0x12e>
        putc(fd, *ap);
 7c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	0f be c0             	movsbl %al,%eax
 7cd:	83 ec 08             	sub    $0x8,%esp
 7d0:	50                   	push   %eax
 7d1:	ff 75 08             	push   0x8(%ebp)
 7d4:	e8 07 fe ff ff       	call   5e0 <putc>
 7d9:	83 c4 10             	add    $0x10,%esp
        ap++;
 7dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e0:	eb 42                	jmp    824 <printf+0x170>
      } else if(c == '%'){
 7e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7e6:	75 17                	jne    7ff <printf+0x14b>
        putc(fd, c);
 7e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	83 ec 08             	sub    $0x8,%esp
 7f1:	50                   	push   %eax
 7f2:	ff 75 08             	push   0x8(%ebp)
 7f5:	e8 e6 fd ff ff       	call   5e0 <putc>
 7fa:	83 c4 10             	add    $0x10,%esp
 7fd:	eb 25                	jmp    824 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7ff:	83 ec 08             	sub    $0x8,%esp
 802:	6a 25                	push   $0x25
 804:	ff 75 08             	push   0x8(%ebp)
 807:	e8 d4 fd ff ff       	call   5e0 <putc>
 80c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 80f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 812:	0f be c0             	movsbl %al,%eax
 815:	83 ec 08             	sub    $0x8,%esp
 818:	50                   	push   %eax
 819:	ff 75 08             	push   0x8(%ebp)
 81c:	e8 bf fd ff ff       	call   5e0 <putc>
 821:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 824:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 82b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 82f:	8b 55 0c             	mov    0xc(%ebp),%edx
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	01 d0                	add    %edx,%eax
 837:	0f b6 00             	movzbl (%eax),%eax
 83a:	84 c0                	test   %al,%al
 83c:	0f 85 94 fe ff ff    	jne    6d6 <printf+0x22>
    }
  }
}
 842:	90                   	nop
 843:	90                   	nop
 844:	c9                   	leave  
 845:	c3                   	ret    

00000846 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 846:	55                   	push   %ebp
 847:	89 e5                	mov    %esp,%ebp
 849:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84c:	8b 45 08             	mov    0x8(%ebp),%eax
 84f:	83 e8 08             	sub    $0x8,%eax
 852:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 855:	a1 68 8e 00 00       	mov    0x8e68,%eax
 85a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85d:	eb 24                	jmp    883 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	8b 00                	mov    (%eax),%eax
 864:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 867:	72 12                	jb     87b <free+0x35>
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86f:	77 24                	ja     895 <free+0x4f>
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 879:	72 1a                	jb     895 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87e:	8b 00                	mov    (%eax),%eax
 880:	89 45 fc             	mov    %eax,-0x4(%ebp)
 883:	8b 45 f8             	mov    -0x8(%ebp),%eax
 886:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 889:	76 d4                	jbe    85f <free+0x19>
 88b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 893:	73 ca                	jae    85f <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 895:	8b 45 f8             	mov    -0x8(%ebp),%eax
 898:	8b 40 04             	mov    0x4(%eax),%eax
 89b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a5:	01 c2                	add    %eax,%edx
 8a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8aa:	8b 00                	mov    (%eax),%eax
 8ac:	39 c2                	cmp    %eax,%edx
 8ae:	75 24                	jne    8d4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b3:	8b 50 04             	mov    0x4(%eax),%edx
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	8b 00                	mov    (%eax),%eax
 8bb:	8b 40 04             	mov    0x4(%eax),%eax
 8be:	01 c2                	add    %eax,%edx
 8c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c9:	8b 00                	mov    (%eax),%eax
 8cb:	8b 10                	mov    (%eax),%edx
 8cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d0:	89 10                	mov    %edx,(%eax)
 8d2:	eb 0a                	jmp    8de <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	8b 10                	mov    (%eax),%edx
 8d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e1:	8b 40 04             	mov    0x4(%eax),%eax
 8e4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ee:	01 d0                	add    %edx,%eax
 8f0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8f3:	75 20                	jne    915 <free+0xcf>
    p->s.size += bp->s.size;
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	8b 50 04             	mov    0x4(%eax),%edx
 8fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fe:	8b 40 04             	mov    0x4(%eax),%eax
 901:	01 c2                	add    %eax,%edx
 903:	8b 45 fc             	mov    -0x4(%ebp),%eax
 906:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 909:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90c:	8b 10                	mov    (%eax),%edx
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	89 10                	mov    %edx,(%eax)
 913:	eb 08                	jmp    91d <free+0xd7>
  } else
    p->s.ptr = bp;
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 55 f8             	mov    -0x8(%ebp),%edx
 91b:	89 10                	mov    %edx,(%eax)
  freep = p;
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	a3 68 8e 00 00       	mov    %eax,0x8e68
}
 925:	90                   	nop
 926:	c9                   	leave  
 927:	c3                   	ret    

00000928 <morecore>:

static Header*
morecore(uint nu)
{
 928:	55                   	push   %ebp
 929:	89 e5                	mov    %esp,%ebp
 92b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 92e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 935:	77 07                	ja     93e <morecore+0x16>
    nu = 4096;
 937:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 93e:	8b 45 08             	mov    0x8(%ebp),%eax
 941:	c1 e0 03             	shl    $0x3,%eax
 944:	83 ec 0c             	sub    $0xc,%esp
 947:	50                   	push   %eax
 948:	e8 6b fc ff ff       	call   5b8 <sbrk>
 94d:	83 c4 10             	add    $0x10,%esp
 950:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 953:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 957:	75 07                	jne    960 <morecore+0x38>
    return 0;
 959:	b8 00 00 00 00       	mov    $0x0,%eax
 95e:	eb 26                	jmp    986 <morecore+0x5e>
  hp = (Header*)p;
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 966:	8b 45 f0             	mov    -0x10(%ebp),%eax
 969:	8b 55 08             	mov    0x8(%ebp),%edx
 96c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 96f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 972:	83 c0 08             	add    $0x8,%eax
 975:	83 ec 0c             	sub    $0xc,%esp
 978:	50                   	push   %eax
 979:	e8 c8 fe ff ff       	call   846 <free>
 97e:	83 c4 10             	add    $0x10,%esp
  return freep;
 981:	a1 68 8e 00 00       	mov    0x8e68,%eax
}
 986:	c9                   	leave  
 987:	c3                   	ret    

00000988 <malloc>:

void*
malloc(uint nbytes)
{
 988:	55                   	push   %ebp
 989:	89 e5                	mov    %esp,%ebp
 98b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	8b 45 08             	mov    0x8(%ebp),%eax
 991:	83 c0 07             	add    $0x7,%eax
 994:	c1 e8 03             	shr    $0x3,%eax
 997:	83 c0 01             	add    $0x1,%eax
 99a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 99d:	a1 68 8e 00 00       	mov    0x8e68,%eax
 9a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9a9:	75 23                	jne    9ce <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ab:	c7 45 f0 60 8e 00 00 	movl   $0x8e60,-0x10(%ebp)
 9b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b5:	a3 68 8e 00 00       	mov    %eax,0x8e68
 9ba:	a1 68 8e 00 00       	mov    0x8e68,%eax
 9bf:	a3 60 8e 00 00       	mov    %eax,0x8e60
    base.s.size = 0;
 9c4:	c7 05 64 8e 00 00 00 	movl   $0x0,0x8e64
 9cb:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d1:	8b 00                	mov    (%eax),%eax
 9d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d9:	8b 40 04             	mov    0x4(%eax),%eax
 9dc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9df:	77 4d                	ja     a2e <malloc+0xa6>
      if(p->s.size == nunits)
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	8b 40 04             	mov    0x4(%eax),%eax
 9e7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ea:	75 0c                	jne    9f8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 10                	mov    (%eax),%edx
 9f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f4:	89 10                	mov    %edx,(%eax)
 9f6:	eb 26                	jmp    a1e <malloc+0x96>
      else {
        p->s.size -= nunits;
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 40 04             	mov    0x4(%eax),%eax
 9fe:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a01:	89 c2                	mov    %eax,%edx
 a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a06:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	8b 40 04             	mov    0x4(%eax),%eax
 a0f:	c1 e0 03             	shl    $0x3,%eax
 a12:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a1b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a21:	a3 68 8e 00 00       	mov    %eax,0x8e68
      return (void*)(p + 1);
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	83 c0 08             	add    $0x8,%eax
 a2c:	eb 3b                	jmp    a69 <malloc+0xe1>
    }
    if(p == freep)
 a2e:	a1 68 8e 00 00       	mov    0x8e68,%eax
 a33:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a36:	75 1e                	jne    a56 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a38:	83 ec 0c             	sub    $0xc,%esp
 a3b:	ff 75 ec             	push   -0x14(%ebp)
 a3e:	e8 e5 fe ff ff       	call   928 <morecore>
 a43:	83 c4 10             	add    $0x10,%esp
 a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a4d:	75 07                	jne    a56 <malloc+0xce>
        return 0;
 a4f:	b8 00 00 00 00       	mov    $0x0,%eax
 a54:	eb 13                	jmp    a69 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 00                	mov    (%eax),%eax
 a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a64:	e9 6d ff ff ff       	jmp    9d6 <malloc+0x4e>
  }
}
 a69:	c9                   	leave  
 a6a:	c3                   	ret    
