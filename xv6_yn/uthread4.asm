
_uthread4:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:

static void thread_schedule(void);

void
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  uthread_init((int)thread_schedule);
   6:	b8 51 00 00 00       	mov    $0x51,%eax
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	50                   	push   %eax
   f:	e8 84 07 00 00       	call   798 <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp

  current_thread = &all_thread[0];
  17:	c7 05 20 10 00 00 40 	movl   $0x1040,0x1020
  1e:	10 00 00 
  current_thread->state = RUNNING;
  21:	a1 20 10 00 00       	mov    0x1020,%eax
  26:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  2d:	00 00 00 
  current_thread->tid = 0;
  30:	a1 20 10 00 00       	mov    0x1020,%eax
  35:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
  3c:	00 00 00 
  current_thread->ptid = 0;
  3f:	a1 20 10 00 00       	mov    0x1020,%eax
  44:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
  4b:	00 00 00 
}
  4e:	90                   	nop
  4f:	c9                   	leave  
  50:	c3                   	ret    

00000051 <thread_schedule>:

static void
thread_schedule(void)
{
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  next_thread = 0;
  57:	c7 05 24 10 00 00 00 	movl   $0x0,0x1024
  5e:	00 00 00 

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  61:	c7 45 f4 40 10 00 00 	movl   $0x1040,-0xc(%ebp)
  68:	eb 29                	jmp    93 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  73:	83 f8 02             	cmp    $0x2,%eax
  76:	75 14                	jne    8c <thread_schedule+0x3b>
  78:	a1 20 10 00 00       	mov    0x1020,%eax
  7d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  80:	74 0a                	je     8c <thread_schedule+0x3b>
      next_thread = t;
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	a3 24 10 00 00       	mov    %eax,0x1024
      break;
  8a:	eb 11                	jmp    9d <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  8c:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  93:	b8 e0 50 01 00       	mov    $0x150e0,%eax
  98:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9b:	72 cd                	jb     6a <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  9d:	b8 e0 50 01 00       	mov    $0x150e0,%eax
  a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a5:	72 1a                	jb     c1 <thread_schedule+0x70>
  a7:	a1 20 10 00 00       	mov    0x1020,%eax
  ac:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  b2:	83 f8 02             	cmp    $0x2,%eax
  b5:	75 0a                	jne    c1 <thread_schedule+0x70>
    next_thread = current_thread;
  b7:	a1 20 10 00 00       	mov    0x1020,%eax
  bc:	a3 24 10 00 00       	mov    %eax,0x1024
  }

  if (next_thread == 0) {
  c1:	a1 24 10 00 00       	mov    0x1024,%eax
  c6:	85 c0                	test   %eax,%eax
  c8:	75 33                	jne    fd <thread_schedule+0xac>
    if (current_thread->state == RUNNING) {
  ca:	a1 20 10 00 00       	mov    0x1020,%eax
  cf:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  d5:	83 f8 01             	cmp    $0x1,%eax
  d8:	75 0c                	jne    e6 <thread_schedule+0x95>
      next_thread = current_thread;
  da:	a1 20 10 00 00       	mov    0x1020,%eax
  df:	a3 24 10 00 00       	mov    %eax,0x1024
  e4:	eb 17                	jmp    fd <thread_schedule+0xac>
    } else {
      printf(2, "thread_schedule: no runnable threads\n");
  e6:	83 ec 08             	sub    $0x8,%esp
  e9:	68 3c 0c 00 00       	push   $0xc3c
  ee:	6a 02                	push   $0x2
  f0:	e8 8f 07 00 00       	call   884 <printf>
  f5:	83 c4 10             	add    $0x10,%esp
      exit();
  f8:	e8 fb 05 00 00       	call   6f8 <exit>
    }
  }

  if (current_thread != next_thread) {
  fd:	8b 15 20 10 00 00    	mov    0x1020,%edx
 103:	a1 24 10 00 00       	mov    0x1024,%eax
 108:	39 c2                	cmp    %eax,%edx
 10a:	74 41                	je     14d <thread_schedule+0xfc>
    next_thread->state = RUNNING;
 10c:	a1 24 10 00 00       	mov    0x1024,%eax
 111:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 118:	00 00 00 
    if (current_thread->state == RUNNING && current_thread != &all_thread[0])
 11b:	a1 20 10 00 00       	mov    0x1020,%eax
 120:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 126:	83 f8 01             	cmp    $0x1,%eax
 129:	75 1b                	jne    146 <thread_schedule+0xf5>
 12b:	a1 20 10 00 00       	mov    0x1020,%eax
 130:	3d 40 10 00 00       	cmp    $0x1040,%eax
 135:	74 0f                	je     146 <thread_schedule+0xf5>
      current_thread->state = RUNNABLE;
 137:	a1 20 10 00 00       	mov    0x1020,%eax
 13c:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 143:	00 00 00 
    thread_switch();
 146:	e8 2a 03 00 00       	call   475 <thread_switch>
  } else {
    next_thread = 0;
  }
}
 14b:	eb 0a                	jmp    157 <thread_schedule+0x106>
    next_thread = 0;
 14d:	c7 05 24 10 00 00 00 	movl   $0x0,0x1024
 154:	00 00 00 
}
 157:	90                   	nop
 158:	c9                   	leave  
 159:	c3                   	ret    

0000015a <thread_create>:

int thread_create(void (*func)())
{
 15a:	55                   	push   %ebp
 15b:	89 e5                	mov    %esp,%ebp
 15d:	83 ec 18             	sub    $0x18,%esp
  thread_p t = 0;
 160:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  int start = current_thread - all_thread;
 167:	a1 20 10 00 00       	mov    0x1020,%eax
 16c:	2d 40 10 00 00       	sub    $0x1040,%eax
 171:	c1 f8 04             	sar    $0x4,%eax
 174:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 17a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for (int i = 1; i <= MAX_THREAD; i++) {
 17d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
 184:	eb 5f                	jmp    1e5 <thread_create+0x8b>
    int idx = (start + i) % MAX_THREAD;
 186:	8b 55 ec             	mov    -0x14(%ebp),%edx
 189:	8b 45 f0             	mov    -0x10(%ebp),%eax
 18c:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 18f:	ba 67 66 66 66       	mov    $0x66666667,%edx
 194:	89 c8                	mov    %ecx,%eax
 196:	f7 ea                	imul   %edx
 198:	89 d0                	mov    %edx,%eax
 19a:	c1 f8 02             	sar    $0x2,%eax
 19d:	89 ca                	mov    %ecx,%edx
 19f:	c1 fa 1f             	sar    $0x1f,%edx
 1a2:	29 d0                	sub    %edx,%eax
 1a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
 1a7:	8b 55 e8             	mov    -0x18(%ebp),%edx
 1aa:	89 d0                	mov    %edx,%eax
 1ac:	c1 e0 02             	shl    $0x2,%eax
 1af:	01 d0                	add    %edx,%eax
 1b1:	01 c0                	add    %eax,%eax
 1b3:	29 c1                	sub    %eax,%ecx
 1b5:	89 ca                	mov    %ecx,%edx
 1b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
    if (all_thread[idx].state == FREE) {
 1ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1bd:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 1c3:	05 44 30 00 00       	add    $0x3044,%eax
 1c8:	8b 00                	mov    (%eax),%eax
 1ca:	85 c0                	test   %eax,%eax
 1cc:	75 13                	jne    1e1 <thread_create+0x87>
      t = &all_thread[idx];
 1ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 1d1:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 1d7:	05 40 10 00 00       	add    $0x1040,%eax
 1dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      break;
 1df:	eb 0a                	jmp    1eb <thread_create+0x91>
  for (int i = 1; i <= MAX_THREAD; i++) {
 1e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 1e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
 1e9:	7e 9b                	jle    186 <thread_create+0x2c>
    }
  }

  if (t == 0)
 1eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1ef:	75 0a                	jne    1fb <thread_create+0xa1>
    return -1;
 1f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f6:	e9 83 00 00 00       	jmp    27e <thread_create+0x124>

  t->sp = (int)(t->stack + STACK_SIZE);
 1fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fe:	83 c0 04             	add    $0x4,%eax
 201:	05 00 20 00 00       	add    $0x2000,%eax
 206:	89 c2                	mov    %eax,%edx
 208:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20b:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;
 20d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 210:	8b 00                	mov    (%eax),%eax
 212:	8d 50 fc             	lea    -0x4(%eax),%edx
 215:	8b 45 f4             	mov    -0xc(%ebp),%eax
 218:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;
 21a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21d:	8b 00                	mov    (%eax),%eax
 21f:	89 c2                	mov    %eax,%edx
 221:	8b 45 08             	mov    0x8(%ebp),%eax
 224:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;
 226:	8b 45 f4             	mov    -0xc(%ebp),%eax
 229:	8b 00                	mov    (%eax),%eax
 22b:	8d 50 e0             	lea    -0x20(%eax),%edx
 22e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 231:	89 10                	mov    %edx,(%eax)

  t->state = RUNNABLE;
 233:	8b 45 f4             	mov    -0xc(%ebp),%eax
 236:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 23d:	00 00 00 
  t->tid = t - all_thread;
 240:	8b 45 f4             	mov    -0xc(%ebp),%eax
 243:	2d 40 10 00 00       	sub    $0x1040,%eax
 248:	c1 f8 04             	sar    $0x4,%eax
 24b:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 251:	89 c2                	mov    %eax,%edx
 253:	8b 45 f4             	mov    -0xc(%ebp),%eax
 256:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 25c:	a1 20 10 00 00       	mov    0x1020,%eax
 261:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 267:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26a:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)

  thread_inc();
 270:	e8 2b 05 00 00       	call   7a0 <thread_inc>
  return t->tid;
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
}
 27e:	c9                   	leave  
 27f:	c3                   	ret    

00000280 <thread_join>:

static void
thread_join(int tid)
{
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	83 ec 18             	sub    $0x18,%esp
  thread_p t = &all_thread[tid];
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 28f:	05 40 10 00 00       	add    $0x1040,%eax
 294:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while (t->state != FREE) {
 297:	eb 14                	jmp    2ad <thread_join+0x2d>
    current_thread->state = WAIT;
 299:	a1 20 10 00 00       	mov    0x1020,%eax
 29e:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 2a5:	00 00 00 
    thread_schedule();
 2a8:	e8 a4 fd ff ff       	call   51 <thread_schedule>
  while (t->state != FREE) {
 2ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b0:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 2b6:	85 c0                	test   %eax,%eax
 2b8:	75 df                	jne    299 <thread_join+0x19>
  }
}
 2ba:	90                   	nop
 2bb:	90                   	nop
 2bc:	c9                   	leave  
 2bd:	c3                   	ret    

000002be <wake_parent>:

static void
wake_parent(void)
{
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < MAX_THREAD; i++) {
 2c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2cb:	eb 4e                	jmp    31b <wake_parent+0x5d>
    if (all_thread[i].tid == current_thread->ptid &&
 2cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d0:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2d6:	05 48 30 00 00       	add    $0x3048,%eax
 2db:	8b 10                	mov    (%eax),%edx
 2dd:	a1 20 10 00 00       	mov    0x1020,%eax
 2e2:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 2e8:	39 c2                	cmp    %eax,%edx
 2ea:	75 2b                	jne    317 <wake_parent+0x59>
        all_thread[i].state == WAIT) {
 2ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ef:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2f5:	05 44 30 00 00       	add    $0x3044,%eax
 2fa:	8b 00                	mov    (%eax),%eax
    if (all_thread[i].tid == current_thread->ptid &&
 2fc:	83 f8 03             	cmp    $0x3,%eax
 2ff:	75 16                	jne    317 <wake_parent+0x59>
      all_thread[i].state = RUNNABLE;
 301:	8b 45 fc             	mov    -0x4(%ebp),%eax
 304:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 30a:	05 44 30 00 00       	add    $0x3044,%eax
 30f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
      break;
 315:	eb 0b                	jmp    322 <wake_parent+0x64>
  for (int i = 0; i < MAX_THREAD; i++) {
 317:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 31b:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
 31f:	7e ac                	jle    2cd <wake_parent+0xf>
    }
  }
}
 321:	90                   	nop
 322:	90                   	nop
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <child_thread>:

static void
child_thread(void)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 32b:	83 ec 08             	sub    $0x8,%esp
 32e:	68 62 0c 00 00       	push   $0xc62
 333:	6a 01                	push   $0x1
 335:	e8 4a 05 00 00       	call   884 <printf>
 33a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 33d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 344:	eb 1c                	jmp    362 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int)current_thread);
 346:	a1 20 10 00 00       	mov    0x1020,%eax
 34b:	83 ec 04             	sub    $0x4,%esp
 34e:	50                   	push   %eax
 34f:	68 78 0c 00 00       	push   $0xc78
 354:	6a 01                	push   $0x1
 356:	e8 29 05 00 00       	call   884 <printf>
 35b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 35e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 362:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 366:	7e de                	jle    346 <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 368:	83 ec 08             	sub    $0x8,%esp
 36b:	68 8b 0c 00 00       	push   $0xc8b
 370:	6a 01                	push   $0x1
 372:	e8 0d 05 00 00       	call   884 <printf>
 377:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 37a:	a1 20 10 00 00       	mov    0x1020,%eax
 37f:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 386:	00 00 00 
  thread_dec();
 389:	e8 1a 04 00 00       	call   7a8 <thread_dec>
  wake_parent();
 38e:	e8 2b ff ff ff       	call   2be <wake_parent>
  thread_schedule();
 393:	e8 b9 fc ff ff       	call   51 <thread_schedule>
}
 398:	90                   	nop
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <mythread>:

static void
mythread(void)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 28             	sub    $0x28,%esp
  int i;
  int tid[5];

  printf(1, "my thread running\n");
 3a1:	83 ec 08             	sub    $0x8,%esp
 3a4:	68 9f 0c 00 00       	push   $0xc9f
 3a9:	6a 01                	push   $0x1
 3ab:	e8 d4 04 00 00       	call   884 <printf>
 3b0:	83 c4 10             	add    $0x10,%esp

  for (i = 0; i < 5; i++) {
 3b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3ba:	eb 1b                	jmp    3d7 <mythread+0x3c>
    tid[i] = thread_create(child_thread);
 3bc:	83 ec 0c             	sub    $0xc,%esp
 3bf:	68 25 03 00 00       	push   $0x325
 3c4:	e8 91 fd ff ff       	call   15a <thread_create>
 3c9:	83 c4 10             	add    $0x10,%esp
 3cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3cf:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
  for (i = 0; i < 5; i++) {
 3d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3d7:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 3db:	7e df                	jle    3bc <mythread+0x21>
  }

  for (i = 0; i < 5; i++) {
 3dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e4:	eb 17                	jmp    3fd <mythread+0x62>
    thread_join(tid[i]);
 3e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e9:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 3ed:	83 ec 0c             	sub    $0xc,%esp
 3f0:	50                   	push   %eax
 3f1:	e8 8a fe ff ff       	call   280 <thread_join>
 3f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 3f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3fd:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 401:	7e e3                	jle    3e6 <mythread+0x4b>
  }

  printf(1, "my thread: exit\n");
 403:	83 ec 08             	sub    $0x8,%esp
 406:	68 b2 0c 00 00       	push   $0xcb2
 40b:	6a 01                	push   $0x1
 40d:	e8 72 04 00 00       	call   884 <printf>
 412:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 415:	a1 20 10 00 00       	mov    0x1020,%eax
 41a:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 421:	00 00 00 
  thread_dec();
 424:	e8 7f 03 00 00       	call   7a8 <thread_dec>
  thread_schedule();
 429:	e8 23 fc ff ff       	call   51 <thread_schedule>
}
 42e:	90                   	nop
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <main>:

int
main(int argc, char *argv[])
{
 431:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 435:	83 e4 f0             	and    $0xfffffff0,%esp
 438:	ff 71 fc             	push   -0x4(%ecx)
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	51                   	push   %ecx
 43f:	83 ec 14             	sub    $0x14,%esp
  int tid;
  thread_init();
 442:	e8 b9 fb ff ff       	call   0 <thread_init>
  tid = thread_create(mythread);
 447:	83 ec 0c             	sub    $0xc,%esp
 44a:	68 9b 03 00 00       	push   $0x39b
 44f:	e8 06 fd ff ff       	call   15a <thread_create>
 454:	83 c4 10             	add    $0x10,%esp
 457:	89 45 f4             	mov    %eax,-0xc(%ebp)
  thread_join(tid);
 45a:	83 ec 0c             	sub    $0xc,%esp
 45d:	ff 75 f4             	push   -0xc(%ebp)
 460:	e8 1b fe ff ff       	call   280 <thread_join>
 465:	83 c4 10             	add    $0x10,%esp
  return 0;
 468:	b8 00 00 00 00       	mov    $0x0,%eax
}
 46d:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 470:	c9                   	leave  
 471:	8d 61 fc             	lea    -0x4(%ecx),%esp
 474:	c3                   	ret    

00000475 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	push %eax		#current_thread 레지스터 값들을 스택에 저장
 475:	50                   	push   %eax
	push %ebx
 476:	53                   	push   %ebx
	push %ecx
 477:	51                   	push   %ecx
	push %edx
 478:	52                   	push   %edx
	push %ebp
 479:	55                   	push   %ebp
    push %esi
 47a:	56                   	push   %esi
    push %edi
 47b:	57                   	push   %edi

	movl current_thread, %eax
 47c:	a1 20 10 00 00       	mov    0x1020,%eax
	movl %esp, (%eax)
 481:	89 20                	mov    %esp,(%eax)

	movl next_thread, %eax      # eax = next_thread  
 483:	a1 24 10 00 00       	mov    0x1024,%eax
    movl (%eax), %esp           # esp = next_thread->sp 
 488:	8b 20                	mov    (%eax),%esp

    
    movl %eax, current_thread   # current_thread = next_thread
 48a:	a3 20 10 00 00       	mov    %eax,0x1020

    pop %edi
 48f:	5f                   	pop    %edi
    pop %esi
 490:	5e                   	pop    %esi
    pop %ebp 
 491:	5d                   	pop    %ebp
    pop %ebx
 492:	5b                   	pop    %ebx
    pop %edx
 493:	5a                   	pop    %edx
    pop %ecx
 494:	59                   	pop    %ecx
    pop %eax
 495:	58                   	pop    %eax

	movl $0, next_thread 
 496:	c7 05 24 10 00 00 00 	movl   $0x0,0x1024
 49d:	00 00 00 
	
	ret    /* return to ra */
 4a0:	c3                   	ret    

000004a1 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	57                   	push   %edi
 4a5:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4a9:	8b 55 10             	mov    0x10(%ebp),%edx
 4ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 4af:	89 cb                	mov    %ecx,%ebx
 4b1:	89 df                	mov    %ebx,%edi
 4b3:	89 d1                	mov    %edx,%ecx
 4b5:	fc                   	cld    
 4b6:	f3 aa                	rep stos %al,%es:(%edi)
 4b8:	89 ca                	mov    %ecx,%edx
 4ba:	89 fb                	mov    %edi,%ebx
 4bc:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4bf:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4c2:	90                   	nop
 4c3:	5b                   	pop    %ebx
 4c4:	5f                   	pop    %edi
 4c5:	5d                   	pop    %ebp
 4c6:	c3                   	ret    

000004c7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4c7:	55                   	push   %ebp
 4c8:	89 e5                	mov    %esp,%ebp
 4ca:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4d3:	90                   	nop
 4d4:	8b 55 0c             	mov    0xc(%ebp),%edx
 4d7:	8d 42 01             	lea    0x1(%edx),%eax
 4da:	89 45 0c             	mov    %eax,0xc(%ebp)
 4dd:	8b 45 08             	mov    0x8(%ebp),%eax
 4e0:	8d 48 01             	lea    0x1(%eax),%ecx
 4e3:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4e6:	0f b6 12             	movzbl (%edx),%edx
 4e9:	88 10                	mov    %dl,(%eax)
 4eb:	0f b6 00             	movzbl (%eax),%eax
 4ee:	84 c0                	test   %al,%al
 4f0:	75 e2                	jne    4d4 <strcpy+0xd>
    ;
  return os;
 4f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4f5:	c9                   	leave  
 4f6:	c3                   	ret    

000004f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4f7:	55                   	push   %ebp
 4f8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4fa:	eb 08                	jmp    504 <strcmp+0xd>
    p++, q++;
 4fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 500:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 504:	8b 45 08             	mov    0x8(%ebp),%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	84 c0                	test   %al,%al
 50c:	74 10                	je     51e <strcmp+0x27>
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	0f b6 10             	movzbl (%eax),%edx
 514:	8b 45 0c             	mov    0xc(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	38 c2                	cmp    %al,%dl
 51c:	74 de                	je     4fc <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
 521:	0f b6 00             	movzbl (%eax),%eax
 524:	0f b6 d0             	movzbl %al,%edx
 527:	8b 45 0c             	mov    0xc(%ebp),%eax
 52a:	0f b6 00             	movzbl (%eax),%eax
 52d:	0f b6 c8             	movzbl %al,%ecx
 530:	89 d0                	mov    %edx,%eax
 532:	29 c8                	sub    %ecx,%eax
}
 534:	5d                   	pop    %ebp
 535:	c3                   	ret    

00000536 <strlen>:

uint
strlen(char *s)
{
 536:	55                   	push   %ebp
 537:	89 e5                	mov    %esp,%ebp
 539:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 53c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 543:	eb 04                	jmp    549 <strlen+0x13>
 545:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 549:	8b 55 fc             	mov    -0x4(%ebp),%edx
 54c:	8b 45 08             	mov    0x8(%ebp),%eax
 54f:	01 d0                	add    %edx,%eax
 551:	0f b6 00             	movzbl (%eax),%eax
 554:	84 c0                	test   %al,%al
 556:	75 ed                	jne    545 <strlen+0xf>
    ;
  return n;
 558:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 55b:	c9                   	leave  
 55c:	c3                   	ret    

0000055d <memset>:

void*
memset(void *dst, int c, uint n)
{
 55d:	55                   	push   %ebp
 55e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 560:	8b 45 10             	mov    0x10(%ebp),%eax
 563:	50                   	push   %eax
 564:	ff 75 0c             	push   0xc(%ebp)
 567:	ff 75 08             	push   0x8(%ebp)
 56a:	e8 32 ff ff ff       	call   4a1 <stosb>
 56f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 572:	8b 45 08             	mov    0x8(%ebp),%eax
}
 575:	c9                   	leave  
 576:	c3                   	ret    

00000577 <strchr>:

char*
strchr(const char *s, char c)
{
 577:	55                   	push   %ebp
 578:	89 e5                	mov    %esp,%ebp
 57a:	83 ec 04             	sub    $0x4,%esp
 57d:	8b 45 0c             	mov    0xc(%ebp),%eax
 580:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 583:	eb 14                	jmp    599 <strchr+0x22>
    if(*s == c)
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	0f b6 00             	movzbl (%eax),%eax
 58b:	38 45 fc             	cmp    %al,-0x4(%ebp)
 58e:	75 05                	jne    595 <strchr+0x1e>
      return (char*)s;
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	eb 13                	jmp    5a8 <strchr+0x31>
  for(; *s; s++)
 595:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	0f b6 00             	movzbl (%eax),%eax
 59f:	84 c0                	test   %al,%al
 5a1:	75 e2                	jne    585 <strchr+0xe>
  return 0;
 5a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5a8:	c9                   	leave  
 5a9:	c3                   	ret    

000005aa <gets>:

char*
gets(char *buf, int max)
{
 5aa:	55                   	push   %ebp
 5ab:	89 e5                	mov    %esp,%ebp
 5ad:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5b7:	eb 42                	jmp    5fb <gets+0x51>
    cc = read(0, &c, 1);
 5b9:	83 ec 04             	sub    $0x4,%esp
 5bc:	6a 01                	push   $0x1
 5be:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5c1:	50                   	push   %eax
 5c2:	6a 00                	push   $0x0
 5c4:	e8 47 01 00 00       	call   710 <read>
 5c9:	83 c4 10             	add    $0x10,%esp
 5cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d3:	7e 33                	jle    608 <gets+0x5e>
      break;
    buf[i++] = c;
 5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d8:	8d 50 01             	lea    0x1(%eax),%edx
 5db:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5de:	89 c2                	mov    %eax,%edx
 5e0:	8b 45 08             	mov    0x8(%ebp),%eax
 5e3:	01 c2                	add    %eax,%edx
 5e5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5e9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5eb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5ef:	3c 0a                	cmp    $0xa,%al
 5f1:	74 16                	je     609 <gets+0x5f>
 5f3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5f7:	3c 0d                	cmp    $0xd,%al
 5f9:	74 0e                	je     609 <gets+0x5f>
  for(i=0; i+1 < max; ){
 5fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fe:	83 c0 01             	add    $0x1,%eax
 601:	39 45 0c             	cmp    %eax,0xc(%ebp)
 604:	7f b3                	jg     5b9 <gets+0xf>
 606:	eb 01                	jmp    609 <gets+0x5f>
      break;
 608:	90                   	nop
      break;
  }
  buf[i] = '\0';
 609:	8b 55 f4             	mov    -0xc(%ebp),%edx
 60c:	8b 45 08             	mov    0x8(%ebp),%eax
 60f:	01 d0                	add    %edx,%eax
 611:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 614:	8b 45 08             	mov    0x8(%ebp),%eax
}
 617:	c9                   	leave  
 618:	c3                   	ret    

00000619 <stat>:

int
stat(char *n, struct stat *st)
{
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 61f:	83 ec 08             	sub    $0x8,%esp
 622:	6a 00                	push   $0x0
 624:	ff 75 08             	push   0x8(%ebp)
 627:	e8 0c 01 00 00       	call   738 <open>
 62c:	83 c4 10             	add    $0x10,%esp
 62f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 632:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 636:	79 07                	jns    63f <stat+0x26>
    return -1;
 638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 63d:	eb 25                	jmp    664 <stat+0x4b>
  r = fstat(fd, st);
 63f:	83 ec 08             	sub    $0x8,%esp
 642:	ff 75 0c             	push   0xc(%ebp)
 645:	ff 75 f4             	push   -0xc(%ebp)
 648:	e8 03 01 00 00       	call   750 <fstat>
 64d:	83 c4 10             	add    $0x10,%esp
 650:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 653:	83 ec 0c             	sub    $0xc,%esp
 656:	ff 75 f4             	push   -0xc(%ebp)
 659:	e8 c2 00 00 00       	call   720 <close>
 65e:	83 c4 10             	add    $0x10,%esp
  return r;
 661:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 664:	c9                   	leave  
 665:	c3                   	ret    

00000666 <atoi>:

int
atoi(const char *s)
{
 666:	55                   	push   %ebp
 667:	89 e5                	mov    %esp,%ebp
 669:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 66c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 673:	eb 25                	jmp    69a <atoi+0x34>
    n = n*10 + *s++ - '0';
 675:	8b 55 fc             	mov    -0x4(%ebp),%edx
 678:	89 d0                	mov    %edx,%eax
 67a:	c1 e0 02             	shl    $0x2,%eax
 67d:	01 d0                	add    %edx,%eax
 67f:	01 c0                	add    %eax,%eax
 681:	89 c1                	mov    %eax,%ecx
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	8d 50 01             	lea    0x1(%eax),%edx
 689:	89 55 08             	mov    %edx,0x8(%ebp)
 68c:	0f b6 00             	movzbl (%eax),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	01 c8                	add    %ecx,%eax
 694:	83 e8 30             	sub    $0x30,%eax
 697:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	0f b6 00             	movzbl (%eax),%eax
 6a0:	3c 2f                	cmp    $0x2f,%al
 6a2:	7e 0a                	jle    6ae <atoi+0x48>
 6a4:	8b 45 08             	mov    0x8(%ebp),%eax
 6a7:	0f b6 00             	movzbl (%eax),%eax
 6aa:	3c 39                	cmp    $0x39,%al
 6ac:	7e c7                	jle    675 <atoi+0xf>
  return n;
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6b1:	c9                   	leave  
 6b2:	c3                   	ret    

000006b3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
 6bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6c5:	eb 17                	jmp    6de <memmove+0x2b>
    *dst++ = *src++;
 6c7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ca:	8d 42 01             	lea    0x1(%edx),%eax
 6cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	8d 48 01             	lea    0x1(%eax),%ecx
 6d6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6d9:	0f b6 12             	movzbl (%edx),%edx
 6dc:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6de:	8b 45 10             	mov    0x10(%ebp),%eax
 6e1:	8d 50 ff             	lea    -0x1(%eax),%edx
 6e4:	89 55 10             	mov    %edx,0x10(%ebp)
 6e7:	85 c0                	test   %eax,%eax
 6e9:	7f dc                	jg     6c7 <memmove+0x14>
  return vdst;
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ee:	c9                   	leave  
 6ef:	c3                   	ret    

000006f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6f0:	b8 01 00 00 00       	mov    $0x1,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <exit>:
SYSCALL(exit)
 6f8:	b8 02 00 00 00       	mov    $0x2,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <wait>:
SYSCALL(wait)
 700:	b8 03 00 00 00       	mov    $0x3,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <pipe>:
SYSCALL(pipe)
 708:	b8 04 00 00 00       	mov    $0x4,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <read>:
SYSCALL(read)
 710:	b8 05 00 00 00       	mov    $0x5,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <write>:
SYSCALL(write)
 718:	b8 10 00 00 00       	mov    $0x10,%eax
 71d:	cd 40                	int    $0x40
 71f:	c3                   	ret    

00000720 <close>:
SYSCALL(close)
 720:	b8 15 00 00 00       	mov    $0x15,%eax
 725:	cd 40                	int    $0x40
 727:	c3                   	ret    

00000728 <kill>:
SYSCALL(kill)
 728:	b8 06 00 00 00       	mov    $0x6,%eax
 72d:	cd 40                	int    $0x40
 72f:	c3                   	ret    

00000730 <exec>:
SYSCALL(exec)
 730:	b8 07 00 00 00       	mov    $0x7,%eax
 735:	cd 40                	int    $0x40
 737:	c3                   	ret    

00000738 <open>:
SYSCALL(open)
 738:	b8 0f 00 00 00       	mov    $0xf,%eax
 73d:	cd 40                	int    $0x40
 73f:	c3                   	ret    

00000740 <mknod>:
SYSCALL(mknod)
 740:	b8 11 00 00 00       	mov    $0x11,%eax
 745:	cd 40                	int    $0x40
 747:	c3                   	ret    

00000748 <unlink>:
SYSCALL(unlink)
 748:	b8 12 00 00 00       	mov    $0x12,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <fstat>:
SYSCALL(fstat)
 750:	b8 08 00 00 00       	mov    $0x8,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <link>:
SYSCALL(link)
 758:	b8 13 00 00 00       	mov    $0x13,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <mkdir>:
SYSCALL(mkdir)
 760:	b8 14 00 00 00       	mov    $0x14,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <chdir>:
SYSCALL(chdir)
 768:	b8 09 00 00 00       	mov    $0x9,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <dup>:
SYSCALL(dup)
 770:	b8 0a 00 00 00       	mov    $0xa,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <getpid>:
SYSCALL(getpid)
 778:	b8 0b 00 00 00       	mov    $0xb,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <sbrk>:
SYSCALL(sbrk)
 780:	b8 0c 00 00 00       	mov    $0xc,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <sleep>:
SYSCALL(sleep)
 788:	b8 0d 00 00 00       	mov    $0xd,%eax
 78d:	cd 40                	int    $0x40
 78f:	c3                   	ret    

00000790 <uptime>:
SYSCALL(uptime)
 790:	b8 0e 00 00 00       	mov    $0xe,%eax
 795:	cd 40                	int    $0x40
 797:	c3                   	ret    

00000798 <uthread_init>:
SYSCALL(uthread_init)
 798:	b8 16 00 00 00       	mov    $0x16,%eax
 79d:	cd 40                	int    $0x40
 79f:	c3                   	ret    

000007a0 <thread_inc>:
SYSCALL(thread_inc)
 7a0:	b8 17 00 00 00       	mov    $0x17,%eax
 7a5:	cd 40                	int    $0x40
 7a7:	c3                   	ret    

000007a8 <thread_dec>:
SYSCALL(thread_dec)
 7a8:	b8 18 00 00 00       	mov    $0x18,%eax
 7ad:	cd 40                	int    $0x40
 7af:	c3                   	ret    

000007b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	83 ec 18             	sub    $0x18,%esp
 7b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7bc:	83 ec 04             	sub    $0x4,%esp
 7bf:	6a 01                	push   $0x1
 7c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7c4:	50                   	push   %eax
 7c5:	ff 75 08             	push   0x8(%ebp)
 7c8:	e8 4b ff ff ff       	call   718 <write>
 7cd:	83 c4 10             	add    $0x10,%esp
}
 7d0:	90                   	nop
 7d1:	c9                   	leave  
 7d2:	c3                   	ret    

000007d3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7d3:	55                   	push   %ebp
 7d4:	89 e5                	mov    %esp,%ebp
 7d6:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7e0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7e4:	74 17                	je     7fd <printint+0x2a>
 7e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7ea:	79 11                	jns    7fd <printint+0x2a>
    neg = 1;
 7ec:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 7f6:	f7 d8                	neg    %eax
 7f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7fb:	eb 06                	jmp    803 <printint+0x30>
  } else {
    x = xx;
 7fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 800:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 80a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 80d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 810:	ba 00 00 00 00       	mov    $0x0,%edx
 815:	f7 f1                	div    %ecx
 817:	89 d1                	mov    %edx,%ecx
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8d 50 01             	lea    0x1(%eax),%edx
 81f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 822:	0f b6 91 f8 0f 00 00 	movzbl 0xff8(%ecx),%edx
 829:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 82d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 830:	8b 45 ec             	mov    -0x14(%ebp),%eax
 833:	ba 00 00 00 00       	mov    $0x0,%edx
 838:	f7 f1                	div    %ecx
 83a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 83d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 841:	75 c7                	jne    80a <printint+0x37>
  if(neg)
 843:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 847:	74 2d                	je     876 <printint+0xa3>
    buf[i++] = '-';
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8d 50 01             	lea    0x1(%eax),%edx
 84f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 852:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 857:	eb 1d                	jmp    876 <printint+0xa3>
    putc(fd, buf[i]);
 859:	8d 55 dc             	lea    -0x24(%ebp),%edx
 85c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85f:	01 d0                	add    %edx,%eax
 861:	0f b6 00             	movzbl (%eax),%eax
 864:	0f be c0             	movsbl %al,%eax
 867:	83 ec 08             	sub    $0x8,%esp
 86a:	50                   	push   %eax
 86b:	ff 75 08             	push   0x8(%ebp)
 86e:	e8 3d ff ff ff       	call   7b0 <putc>
 873:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 876:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 87a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 87e:	79 d9                	jns    859 <printint+0x86>
}
 880:	90                   	nop
 881:	90                   	nop
 882:	c9                   	leave  
 883:	c3                   	ret    

00000884 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 884:	55                   	push   %ebp
 885:	89 e5                	mov    %esp,%ebp
 887:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 88a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 891:	8d 45 0c             	lea    0xc(%ebp),%eax
 894:	83 c0 04             	add    $0x4,%eax
 897:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 89a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8a1:	e9 59 01 00 00       	jmp    9ff <printf+0x17b>
    c = fmt[i] & 0xff;
 8a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ac:	01 d0                	add    %edx,%eax
 8ae:	0f b6 00             	movzbl (%eax),%eax
 8b1:	0f be c0             	movsbl %al,%eax
 8b4:	25 ff 00 00 00       	and    $0xff,%eax
 8b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8c0:	75 2c                	jne    8ee <printf+0x6a>
      if(c == '%'){
 8c2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8c6:	75 0c                	jne    8d4 <printf+0x50>
        state = '%';
 8c8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8cf:	e9 27 01 00 00       	jmp    9fb <printf+0x177>
      } else {
        putc(fd, c);
 8d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d7:	0f be c0             	movsbl %al,%eax
 8da:	83 ec 08             	sub    $0x8,%esp
 8dd:	50                   	push   %eax
 8de:	ff 75 08             	push   0x8(%ebp)
 8e1:	e8 ca fe ff ff       	call   7b0 <putc>
 8e6:	83 c4 10             	add    $0x10,%esp
 8e9:	e9 0d 01 00 00       	jmp    9fb <printf+0x177>
      }
    } else if(state == '%'){
 8ee:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8f2:	0f 85 03 01 00 00    	jne    9fb <printf+0x177>
      if(c == 'd'){
 8f8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8fc:	75 1e                	jne    91c <printf+0x98>
        printint(fd, *ap, 10, 1);
 8fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 901:	8b 00                	mov    (%eax),%eax
 903:	6a 01                	push   $0x1
 905:	6a 0a                	push   $0xa
 907:	50                   	push   %eax
 908:	ff 75 08             	push   0x8(%ebp)
 90b:	e8 c3 fe ff ff       	call   7d3 <printint>
 910:	83 c4 10             	add    $0x10,%esp
        ap++;
 913:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 917:	e9 d8 00 00 00       	jmp    9f4 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 91c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 920:	74 06                	je     928 <printf+0xa4>
 922:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 926:	75 1e                	jne    946 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 928:	8b 45 e8             	mov    -0x18(%ebp),%eax
 92b:	8b 00                	mov    (%eax),%eax
 92d:	6a 00                	push   $0x0
 92f:	6a 10                	push   $0x10
 931:	50                   	push   %eax
 932:	ff 75 08             	push   0x8(%ebp)
 935:	e8 99 fe ff ff       	call   7d3 <printint>
 93a:	83 c4 10             	add    $0x10,%esp
        ap++;
 93d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 941:	e9 ae 00 00 00       	jmp    9f4 <printf+0x170>
      } else if(c == 's'){
 946:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 94a:	75 43                	jne    98f <printf+0x10b>
        s = (char*)*ap;
 94c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 954:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 958:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 95c:	75 25                	jne    983 <printf+0xff>
          s = "(null)";
 95e:	c7 45 f4 c3 0c 00 00 	movl   $0xcc3,-0xc(%ebp)
        while(*s != 0){
 965:	eb 1c                	jmp    983 <printf+0xff>
          putc(fd, *s);
 967:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96a:	0f b6 00             	movzbl (%eax),%eax
 96d:	0f be c0             	movsbl %al,%eax
 970:	83 ec 08             	sub    $0x8,%esp
 973:	50                   	push   %eax
 974:	ff 75 08             	push   0x8(%ebp)
 977:	e8 34 fe ff ff       	call   7b0 <putc>
 97c:	83 c4 10             	add    $0x10,%esp
          s++;
 97f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 983:	8b 45 f4             	mov    -0xc(%ebp),%eax
 986:	0f b6 00             	movzbl (%eax),%eax
 989:	84 c0                	test   %al,%al
 98b:	75 da                	jne    967 <printf+0xe3>
 98d:	eb 65                	jmp    9f4 <printf+0x170>
        }
      } else if(c == 'c'){
 98f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 993:	75 1d                	jne    9b2 <printf+0x12e>
        putc(fd, *ap);
 995:	8b 45 e8             	mov    -0x18(%ebp),%eax
 998:	8b 00                	mov    (%eax),%eax
 99a:	0f be c0             	movsbl %al,%eax
 99d:	83 ec 08             	sub    $0x8,%esp
 9a0:	50                   	push   %eax
 9a1:	ff 75 08             	push   0x8(%ebp)
 9a4:	e8 07 fe ff ff       	call   7b0 <putc>
 9a9:	83 c4 10             	add    $0x10,%esp
        ap++;
 9ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b0:	eb 42                	jmp    9f4 <printf+0x170>
      } else if(c == '%'){
 9b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9b6:	75 17                	jne    9cf <printf+0x14b>
        putc(fd, c);
 9b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9bb:	0f be c0             	movsbl %al,%eax
 9be:	83 ec 08             	sub    $0x8,%esp
 9c1:	50                   	push   %eax
 9c2:	ff 75 08             	push   0x8(%ebp)
 9c5:	e8 e6 fd ff ff       	call   7b0 <putc>
 9ca:	83 c4 10             	add    $0x10,%esp
 9cd:	eb 25                	jmp    9f4 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9cf:	83 ec 08             	sub    $0x8,%esp
 9d2:	6a 25                	push   $0x25
 9d4:	ff 75 08             	push   0x8(%ebp)
 9d7:	e8 d4 fd ff ff       	call   7b0 <putc>
 9dc:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9e2:	0f be c0             	movsbl %al,%eax
 9e5:	83 ec 08             	sub    $0x8,%esp
 9e8:	50                   	push   %eax
 9e9:	ff 75 08             	push   0x8(%ebp)
 9ec:	e8 bf fd ff ff       	call   7b0 <putc>
 9f1:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 9fb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	01 d0                	add    %edx,%eax
 a07:	0f b6 00             	movzbl (%eax),%eax
 a0a:	84 c0                	test   %al,%al
 a0c:	0f 85 94 fe ff ff    	jne    8a6 <printf+0x22>
    }
  }
}
 a12:	90                   	nop
 a13:	90                   	nop
 a14:	c9                   	leave  
 a15:	c3                   	ret    

00000a16 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a16:	55                   	push   %ebp
 a17:	89 e5                	mov    %esp,%ebp
 a19:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a1c:	8b 45 08             	mov    0x8(%ebp),%eax
 a1f:	83 e8 08             	sub    $0x8,%eax
 a22:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a25:	a1 e8 50 01 00       	mov    0x150e8,%eax
 a2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a2d:	eb 24                	jmp    a53 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a32:	8b 00                	mov    (%eax),%eax
 a34:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a37:	72 12                	jb     a4b <free+0x35>
 a39:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a3c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a3f:	77 24                	ja     a65 <free+0x4f>
 a41:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a44:	8b 00                	mov    (%eax),%eax
 a46:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a49:	72 1a                	jb     a65 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4e:	8b 00                	mov    (%eax),%eax
 a50:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a53:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a56:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a59:	76 d4                	jbe    a2f <free+0x19>
 a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5e:	8b 00                	mov    (%eax),%eax
 a60:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a63:	73 ca                	jae    a2f <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a65:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a68:	8b 40 04             	mov    0x4(%eax),%eax
 a6b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a72:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a75:	01 c2                	add    %eax,%edx
 a77:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7a:	8b 00                	mov    (%eax),%eax
 a7c:	39 c2                	cmp    %eax,%edx
 a7e:	75 24                	jne    aa4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a80:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a83:	8b 50 04             	mov    0x4(%eax),%edx
 a86:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a89:	8b 00                	mov    (%eax),%eax
 a8b:	8b 40 04             	mov    0x4(%eax),%eax
 a8e:	01 c2                	add    %eax,%edx
 a90:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a93:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a96:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a99:	8b 00                	mov    (%eax),%eax
 a9b:	8b 10                	mov    (%eax),%edx
 a9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa0:	89 10                	mov    %edx,(%eax)
 aa2:	eb 0a                	jmp    aae <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 aa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa7:	8b 10                	mov    (%eax),%edx
 aa9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aac:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 aae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab1:	8b 40 04             	mov    0x4(%eax),%eax
 ab4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 abb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 abe:	01 d0                	add    %edx,%eax
 ac0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ac3:	75 20                	jne    ae5 <free+0xcf>
    p->s.size += bp->s.size;
 ac5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac8:	8b 50 04             	mov    0x4(%eax),%edx
 acb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ace:	8b 40 04             	mov    0x4(%eax),%eax
 ad1:	01 c2                	add    %eax,%edx
 ad3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ad9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 adc:	8b 10                	mov    (%eax),%edx
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	89 10                	mov    %edx,(%eax)
 ae3:	eb 08                	jmp    aed <free+0xd7>
  } else
    p->s.ptr = bp;
 ae5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 aeb:	89 10                	mov    %edx,(%eax)
  freep = p;
 aed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af0:	a3 e8 50 01 00       	mov    %eax,0x150e8
}
 af5:	90                   	nop
 af6:	c9                   	leave  
 af7:	c3                   	ret    

00000af8 <morecore>:

static Header*
morecore(uint nu)
{
 af8:	55                   	push   %ebp
 af9:	89 e5                	mov    %esp,%ebp
 afb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 afe:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b05:	77 07                	ja     b0e <morecore+0x16>
    nu = 4096;
 b07:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b0e:	8b 45 08             	mov    0x8(%ebp),%eax
 b11:	c1 e0 03             	shl    $0x3,%eax
 b14:	83 ec 0c             	sub    $0xc,%esp
 b17:	50                   	push   %eax
 b18:	e8 63 fc ff ff       	call   780 <sbrk>
 b1d:	83 c4 10             	add    $0x10,%esp
 b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b23:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b27:	75 07                	jne    b30 <morecore+0x38>
    return 0;
 b29:	b8 00 00 00 00       	mov    $0x0,%eax
 b2e:	eb 26                	jmp    b56 <morecore+0x5e>
  hp = (Header*)p;
 b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b39:	8b 55 08             	mov    0x8(%ebp),%edx
 b3c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b42:	83 c0 08             	add    $0x8,%eax
 b45:	83 ec 0c             	sub    $0xc,%esp
 b48:	50                   	push   %eax
 b49:	e8 c8 fe ff ff       	call   a16 <free>
 b4e:	83 c4 10             	add    $0x10,%esp
  return freep;
 b51:	a1 e8 50 01 00       	mov    0x150e8,%eax
}
 b56:	c9                   	leave  
 b57:	c3                   	ret    

00000b58 <malloc>:

void*
malloc(uint nbytes)
{
 b58:	55                   	push   %ebp
 b59:	89 e5                	mov    %esp,%ebp
 b5b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b5e:	8b 45 08             	mov    0x8(%ebp),%eax
 b61:	83 c0 07             	add    $0x7,%eax
 b64:	c1 e8 03             	shr    $0x3,%eax
 b67:	83 c0 01             	add    $0x1,%eax
 b6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b6d:	a1 e8 50 01 00       	mov    0x150e8,%eax
 b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b79:	75 23                	jne    b9e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b7b:	c7 45 f0 e0 50 01 00 	movl   $0x150e0,-0x10(%ebp)
 b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b85:	a3 e8 50 01 00       	mov    %eax,0x150e8
 b8a:	a1 e8 50 01 00       	mov    0x150e8,%eax
 b8f:	a3 e0 50 01 00       	mov    %eax,0x150e0
    base.s.size = 0;
 b94:	c7 05 e4 50 01 00 00 	movl   $0x0,0x150e4
 b9b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba1:	8b 00                	mov    (%eax),%eax
 ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba9:	8b 40 04             	mov    0x4(%eax),%eax
 bac:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 baf:	77 4d                	ja     bfe <malloc+0xa6>
      if(p->s.size == nunits)
 bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb4:	8b 40 04             	mov    0x4(%eax),%eax
 bb7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bba:	75 0c                	jne    bc8 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bbf:	8b 10                	mov    (%eax),%edx
 bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc4:	89 10                	mov    %edx,(%eax)
 bc6:	eb 26                	jmp    bee <malloc+0x96>
      else {
        p->s.size -= nunits;
 bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bcb:	8b 40 04             	mov    0x4(%eax),%eax
 bce:	2b 45 ec             	sub    -0x14(%ebp),%eax
 bd1:	89 c2                	mov    %eax,%edx
 bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bdc:	8b 40 04             	mov    0x4(%eax),%eax
 bdf:	c1 e0 03             	shl    $0x3,%eax
 be2:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be8:	8b 55 ec             	mov    -0x14(%ebp),%edx
 beb:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf1:	a3 e8 50 01 00       	mov    %eax,0x150e8
      return (void*)(p + 1);
 bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf9:	83 c0 08             	add    $0x8,%eax
 bfc:	eb 3b                	jmp    c39 <malloc+0xe1>
    }
    if(p == freep)
 bfe:	a1 e8 50 01 00       	mov    0x150e8,%eax
 c03:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c06:	75 1e                	jne    c26 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 c08:	83 ec 0c             	sub    $0xc,%esp
 c0b:	ff 75 ec             	push   -0x14(%ebp)
 c0e:	e8 e5 fe ff ff       	call   af8 <morecore>
 c13:	83 c4 10             	add    $0x10,%esp
 c16:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c1d:	75 07                	jne    c26 <malloc+0xce>
        return 0;
 c1f:	b8 00 00 00 00       	mov    $0x0,%eax
 c24:	eb 13                	jmp    c39 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2f:	8b 00                	mov    (%eax),%eax
 c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c34:	e9 6d ff ff ff       	jmp    ba6 <malloc+0x4e>
  }
}
 c39:	c9                   	leave  
 c3a:	c3                   	ret    
