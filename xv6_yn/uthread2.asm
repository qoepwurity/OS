
_uthread2:     file format elf32-i386


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
   6:	b8 51 00 00 00       	mov    $0x51,%eax
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	50                   	push   %eax
   f:	e8 71 07 00 00       	call   785 <uthread_init>
  14:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  17:	c7 05 00 10 00 00 20 	movl   $0x1020,0x1000
  1e:	10 00 00 
  current_thread->state = RUNNING;
  21:	a1 00 10 00 00       	mov    0x1000,%eax
  26:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  2d:	00 00 00 
  current_thread->tid=0;
  30:	a1 00 10 00 00       	mov    0x1000,%eax
  35:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
  3c:	00 00 00 
  current_thread->ptid=0;
  3f:	a1 00 10 00 00       	mov    0x1000,%eax
  44:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
  4b:	00 00 00 
}
  4e:	90                   	nop
  4f:	c9                   	leave  
  50:	c3                   	ret    

00000051 <thread_schedule>:

void 
thread_schedule(void)
{ 
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  57:	c7 05 04 10 00 00 00 	movl   $0x0,0x1004
  5e:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  61:	c7 45 f4 20 10 00 00 	movl   $0x1020,-0xc(%ebp)
  68:	eb 29                	jmp    93 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6d:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  73:	83 f8 02             	cmp    $0x2,%eax
  76:	75 14                	jne    8c <thread_schedule+0x3b>
  78:	a1 00 10 00 00       	mov    0x1000,%eax
  7d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  80:	74 0a                	je     8c <thread_schedule+0x3b>
      next_thread = t;
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	a3 04 10 00 00       	mov    %eax,0x1004
      break;
  8a:	eb 11                	jmp    9d <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  8c:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  93:	b8 c0 50 01 00       	mov    $0x150c0,%eax
  98:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9b:	72 cd                	jb     6a <thread_schedule+0x19>
    }
  }
  
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  9d:	b8 c0 50 01 00       	mov    $0x150c0,%eax
  a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a5:	72 1a                	jb     c1 <thread_schedule+0x70>
  a7:	a1 00 10 00 00       	mov    0x1000,%eax
  ac:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  b2:	83 f8 02             	cmp    $0x2,%eax
  b5:	75 0a                	jne    c1 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  b7:	a1 00 10 00 00       	mov    0x1000,%eax
  bc:	a3 04 10 00 00       	mov    %eax,0x1004
  }

  if (next_thread == 0) {
  c1:	a1 04 10 00 00       	mov    0x1004,%eax
  c6:	85 c0                	test   %eax,%eax
  c8:	75 33                	jne    fd <thread_schedule+0xac>
    if(current_thread->state==RUNNING){         // child가 하나만 남았을 때
  ca:	a1 00 10 00 00       	mov    0x1000,%eax
  cf:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  d5:	83 f8 01             	cmp    $0x1,%eax
  d8:	75 0c                	jne    e6 <thread_schedule+0x95>
      next_thread = current_thread;
  da:	a1 00 10 00 00       	mov    0x1000,%eax
  df:	a3 04 10 00 00       	mov    %eax,0x1004
  e4:	eb 17                	jmp    fd <thread_schedule+0xac>
    } else {  
    printf(2, "thread_schedule: no runnable threads\n");
  e6:	83 ec 08             	sub    $0x8,%esp
  e9:	68 28 0c 00 00       	push   $0xc28
  ee:	6a 02                	push   $0x2
  f0:	e8 7c 07 00 00       	call   871 <printf>
  f5:	83 c4 10             	add    $0x10,%esp
    exit();
  f8:	e8 e8 05 00 00       	call   6e5 <exit>
    }
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  fd:	8b 15 00 10 00 00    	mov    0x1000,%edx
 103:	a1 04 10 00 00       	mov    0x1004,%eax
 108:	39 c2                	cmp    %eax,%edx
 10a:	74 41                	je     14d <thread_schedule+0xfc>
    next_thread->state = RUNNING;
 10c:	a1 04 10 00 00       	mov    0x1004,%eax
 111:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 118:	00 00 00 
    if(current_thread != &all_thread[0]&&current_thread->state==RUNNING){ 
 11b:	a1 00 10 00 00       	mov    0x1000,%eax
 120:	3d 20 10 00 00       	cmp    $0x1020,%eax
 125:	74 1f                	je     146 <thread_schedule+0xf5>
 127:	a1 00 10 00 00       	mov    0x1000,%eax
 12c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 132:	83 f8 01             	cmp    $0x1,%eax
 135:	75 0f                	jne    146 <thread_schedule+0xf5>
      current_thread->state=RUNNABLE;          // main이 다시 스케줄링 되지 않고
 137:	a1 00 10 00 00       	mov    0x1000,%eax
 13c:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 143:	00 00 00 
    }                                          // current_thread가 다시 스케줄링 되도록
    thread_switch();
 146:	e8 17 03 00 00       	call   462 <thread_switch>
  } else
    next_thread = 0;
}
 14b:	eb 0a                	jmp    157 <thread_schedule+0x106>
    next_thread = 0;
 14d:	c7 05 04 10 00 00 00 	movl   $0x0,0x1004
 154:	00 00 00 
}
 157:	90                   	nop
 158:	c9                   	leave  
 159:	c3                   	ret    

0000015a <thread_create>:

void 
thread_create(void (*func)())
{
 15a:	55                   	push   %ebp
 15b:	89 e5                	mov    %esp,%ebp
 15d:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 160:	c7 45 f4 20 10 00 00 	movl   $0x1020,-0xc(%ebp)
 167:	eb 14                	jmp    17d <thread_create+0x23>
    if (t->state == FREE) break;
 169:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 172:	85 c0                	test   %eax,%eax
 174:	74 13                	je     189 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 176:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 17d:	b8 c0 50 01 00       	mov    $0x150c0,%eax
 182:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 185:	72 e2                	jb     169 <thread_create+0xf>
 187:	eb 01                	jmp    18a <thread_create+0x30>
    if (t->state == FREE) break;
 189:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	83 c0 04             	add    $0x4,%eax
 190:	05 00 20 00 00       	add    $0x2000,%eax
 195:	89 c2                	mov    %eax,%edx
 197:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19a:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 19c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19f:	8b 00                	mov    (%eax),%eax
 1a1:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a7:	89 10                	mov    %edx,(%eax)
  
  t->tid = t - all_thread;                 // child id = 배열 인덱스
 1a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ac:	2d 20 10 00 00       	sub    $0x1020,%eax
 1b1:	c1 f8 04             	sar    $0x4,%eax
 1b4:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1ba:	89 c2                	mov    %eax,%edx
 1bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bf:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;           // parent id = 현재 실행 중인 스레드의 tid
 1c5:	a1 00 10 00 00       	mov    0x1000,%eax
 1ca:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 1d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d3:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)
  
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	8b 00                	mov    (%eax),%eax
 1de:	89 c2                	mov    %eax,%edx
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
 1e3:	89 02                	mov    %eax,(%edx)
  t->sp -= 28;                             // space for registers that thread_switch expects
 1e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e8:	8b 00                	mov    (%eax),%eax
 1ea:	8d 50 e4             	lea    -0x1c(%eax),%edx
 1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f0:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f5:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1fc:	00 00 00 
  thread_inc();                            //thread_count++
 1ff:	e8 89 05 00 00       	call   78d <thread_inc>
}
 204:	90                   	nop
 205:	c9                   	leave  
 206:	c3                   	ret    

00000207 <thread_join_all>:

static void 
thread_join_all(void)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	83 ec 18             	sub    $0x18,%esp
  while(1){
    int has_child = 0;
 20d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (int i = 0; i < MAX_THREAD; i++){
 214:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 21b:	eb 40                	jmp    25d <thread_join_all+0x56>
      if(all_thread[i].ptid==current_thread->tid&&all_thread[i].state!=FREE){ // RUNNABLE or RUNNING 중인 child 찾기
 21d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 220:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 226:	05 2c 30 00 00       	add    $0x302c,%eax
 22b:	8b 10                	mov    (%eax),%edx
 22d:	a1 00 10 00 00       	mov    0x1000,%eax
 232:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 238:	39 c2                	cmp    %eax,%edx
 23a:	75 1d                	jne    259 <thread_join_all+0x52>
 23c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 23f:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 245:	05 24 30 00 00       	add    $0x3024,%eax
 24a:	8b 00                	mov    (%eax),%eax
 24c:	85 c0                	test   %eax,%eax
 24e:	74 09                	je     259 <thread_join_all+0x52>
        has_child = 1;
 250:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 257:	eb 0a                	jmp    263 <thread_join_all+0x5c>
    for (int i = 0; i < MAX_THREAD; i++){
 259:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 25d:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 261:	7e ba                	jle    21d <thread_join_all+0x16>
      }  
    }
    if (!has_child){                   // child 없다면 mythread RUNNABLE
 263:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 267:	75 0c                	jne    275 <thread_join_all+0x6e>
      all_thread[1].state = RUNNABLE;
 269:	c7 05 34 50 00 00 02 	movl   $0x2,0x5034
 270:	00 00 00 
      return ;
 273:	eb 16                	jmp    28b <thread_join_all+0x84>
    }  
  
    current_thread->state = WAIT;      // child 있으면 WAIT
 275:	a1 00 10 00 00       	mov    0x1000,%eax
 27a:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 281:	00 00 00 
    thread_schedule();
 284:	e8 c8 fd ff ff       	call   51 <thread_schedule>
  while(1){
 289:	eb 82                	jmp    20d <thread_join_all+0x6>
  }  
}
 28b:	c9                   	leave  
 28c:	c3                   	ret    

0000028d <wake_parent>:

static void 
wake_parent(void)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 10             	sub    $0x10,%esp
  int last_child = 0;
 293:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i = 0; i < MAX_THREAD; i++){
 29a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
 2a1:	eb 36                	jmp    2d9 <wake_parent+0x4c>
    if(all_thread[i].state !=FREE && all_thread[i].state !=WAIT){ //RUNNING or RUNNABLE이면 
 2a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2a6:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2ac:	05 24 30 00 00       	add    $0x3024,%eax
 2b1:	8b 00                	mov    (%eax),%eax
 2b3:	85 c0                	test   %eax,%eax
 2b5:	74 1e                	je     2d5 <wake_parent+0x48>
 2b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2ba:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2c0:	05 24 30 00 00       	add    $0x3024,%eax
 2c5:	8b 00                	mov    (%eax),%eax
 2c7:	83 f8 03             	cmp    $0x3,%eax
 2ca:	74 09                	je     2d5 <wake_parent+0x48>
      last_child = 1;                                             //child 남아있음
 2cc:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
      break;
 2d3:	eb 0a                	jmp    2df <wake_parent+0x52>
  for(int i = 0; i < MAX_THREAD; i++){
 2d5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 2d9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
 2dd:	7e c4                	jle    2a3 <wake_parent+0x16>
    }

  }
  if(!last_child){
 2df:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
 2e3:	75 5e                	jne    343 <wake_parent+0xb6>
    for(int i = 0; i<MAX_THREAD; i++){
 2e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ec:	eb 4f                	jmp    33d <wake_parent+0xb0>
      if(all_thread[i].tid == current_thread->ptid && all_thread[i].state==WAIT){  // mythread 찾기
 2ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f1:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 2f7:	05 28 30 00 00       	add    $0x3028,%eax
 2fc:	8b 10                	mov    (%eax),%edx
 2fe:	a1 00 10 00 00       	mov    0x1000,%eax
 303:	8b 80 0c 20 00 00    	mov    0x200c(%eax),%eax
 309:	39 c2                	cmp    %eax,%edx
 30b:	75 2c                	jne    339 <wake_parent+0xac>
 30d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 310:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 316:	05 24 30 00 00       	add    $0x3024,%eax
 31b:	8b 00                	mov    (%eax),%eax
 31d:	83 f8 03             	cmp    $0x3,%eax
 320:	75 17                	jne    339 <wake_parent+0xac>
        all_thread[i].state = RUNNABLE;                                            // WAKE->RUNNABLE
 322:	8b 45 f4             	mov    -0xc(%ebp),%eax
 325:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 32b:	05 24 30 00 00       	add    $0x3024,%eax
 330:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
        break;
 336:	90                   	nop
      }
    }
  }
} 
 337:	eb 0a                	jmp    343 <wake_parent+0xb6>
    for(int i = 0; i<MAX_THREAD; i++){
 339:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 33d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 341:	7e ab                	jle    2ee <wake_parent+0x61>
} 
 343:	90                   	nop
 344:	c9                   	leave  
 345:	c3                   	ret    

00000346 <child_thread>:

static void 
child_thread(void)
{
 346:	55                   	push   %ebp
 347:	89 e5                	mov    %esp,%ebp
 349:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "child thread running\n");
 34c:	83 ec 08             	sub    $0x8,%esp
 34f:	68 4e 0c 00 00       	push   $0xc4e
 354:	6a 01                	push   $0x1
 356:	e8 16 05 00 00       	call   871 <printf>
 35b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 35e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 365:	eb 1c                	jmp    383 <child_thread+0x3d>
    printf(1, "child thread 0x%x\n", (int) current_thread);
 367:	a1 00 10 00 00       	mov    0x1000,%eax
 36c:	83 ec 04             	sub    $0x4,%esp
 36f:	50                   	push   %eax
 370:	68 64 0c 00 00       	push   $0xc64
 375:	6a 01                	push   $0x1
 377:	e8 f5 04 00 00       	call   871 <printf>
 37c:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 37f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 383:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 387:	7e de                	jle    367 <child_thread+0x21>
  }
  printf(1, "child thread: exit\n");
 389:	83 ec 08             	sub    $0x8,%esp
 38c:	68 77 0c 00 00       	push   $0xc77
 391:	6a 01                	push   $0x1
 393:	e8 d9 04 00 00       	call   871 <printf>
 398:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 39b:	a1 00 10 00 00       	mov    0x1000,%eax
 3a0:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 3a7:	00 00 00 
  thread_dec();            // thread_count--
 3aa:	e8 e6 03 00 00       	call   795 <thread_dec>
  wake_parent();           // mythread WAKE->RUNNABLE
 3af:	e8 d9 fe ff ff       	call   28d <wake_parent>
  thread_schedule();
 3b4:	e8 98 fc ff ff       	call   51 <thread_schedule>
}
 3b9:	90                   	nop
 3ba:	c9                   	leave  
 3bb:	c3                   	ret    

000003bc <mythread>:

void 
mythread(void)
{
 3bc:	55                   	push   %ebp
 3bd:	89 e5                	mov    %esp,%ebp
 3bf:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 3c2:	83 ec 08             	sub    $0x8,%esp
 3c5:	68 8b 0c 00 00       	push   $0xc8b
 3ca:	6a 01                	push   $0x1
 3cc:	e8 a0 04 00 00       	call   871 <printf>
 3d1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 3d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3db:	eb 14                	jmp    3f1 <mythread+0x35>
    thread_create(child_thread);
 3dd:	83 ec 0c             	sub    $0xc,%esp
 3e0:	68 46 03 00 00       	push   $0x346
 3e5:	e8 70 fd ff ff       	call   15a <thread_create>
 3ea:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 3ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3f1:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 3f5:	7e e6                	jle    3dd <mythread+0x21>
  }
  thread_join_all();
 3f7:	e8 0b fe ff ff       	call   207 <thread_join_all>
  printf(1, "my thread: exit\n");
 3fc:	83 ec 08             	sub    $0x8,%esp
 3ff:	68 9e 0c 00 00       	push   $0xc9e
 404:	6a 01                	push   $0x1
 406:	e8 66 04 00 00       	call   871 <printf>
 40b:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 40e:	a1 00 10 00 00       	mov    0x1000,%eax
 413:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 41a:	00 00 00 
  thread_dec();            // thread_count--;
 41d:	e8 73 03 00 00       	call   795 <thread_dec>
  thread_schedule();
 422:	e8 2a fc ff ff       	call   51 <thread_schedule>
}
 427:	90                   	nop
 428:	c9                   	leave  
 429:	c3                   	ret    

0000042a <main>:

int 
main(int argc, char *argv[]) 
{
 42a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 42e:	83 e4 f0             	and    $0xfffffff0,%esp
 431:	ff 71 fc             	push   -0x4(%ecx)
 434:	55                   	push   %ebp
 435:	89 e5                	mov    %esp,%ebp
 437:	51                   	push   %ecx
 438:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 43b:	e8 c0 fb ff ff       	call   0 <thread_init>
  thread_create(mythread);
 440:	83 ec 0c             	sub    $0xc,%esp
 443:	68 bc 03 00 00       	push   $0x3bc
 448:	e8 0d fd ff ff       	call   15a <thread_create>
 44d:	83 c4 10             	add    $0x10,%esp
  thread_join_all();
 450:	e8 b2 fd ff ff       	call   207 <thread_join_all>
  return 0;
 455:	b8 00 00 00 00       	mov    $0x0,%eax
}
 45a:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 45d:	c9                   	leave  
 45e:	8d 61 fc             	lea    -0x4(%ecx),%esp
 461:	c3                   	ret    

00000462 <thread_switch>:
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	push %eax		#current_thread 레지스터 값들을 스택에 저장
 462:	50                   	push   %eax
	push %ebx
 463:	53                   	push   %ebx
	push %ecx
 464:	51                   	push   %ecx
	push %edx
 465:	52                   	push   %edx
	push %ebp
 466:	55                   	push   %ebp
    push %esi
 467:	56                   	push   %esi
    push %edi
 468:	57                   	push   %edi

	movl current_thread, %eax
 469:	a1 00 10 00 00       	mov    0x1000,%eax
	movl %esp, (%eax)
 46e:	89 20                	mov    %esp,(%eax)

	movl next_thread, %eax      # eax = next_thread  
 470:	a1 04 10 00 00       	mov    0x1004,%eax
    movl (%eax), %esp           # esp = next_thread->sp 
 475:	8b 20                	mov    (%eax),%esp

    
    movl %eax, current_thread   # current_thread = next_thread
 477:	a3 00 10 00 00       	mov    %eax,0x1000

    pop %edi
 47c:	5f                   	pop    %edi
    pop %esi
 47d:	5e                   	pop    %esi
    pop %ebp 
 47e:	5d                   	pop    %ebp
    pop %ebx
 47f:	5b                   	pop    %ebx
    pop %edx
 480:	5a                   	pop    %edx
    pop %ecx
 481:	59                   	pop    %ecx
    pop %eax
 482:	58                   	pop    %eax

	movl $0, next_thread 
 483:	c7 05 04 10 00 00 00 	movl   $0x0,0x1004
 48a:	00 00 00 
	
	ret    /* return to ra */
 48d:	c3                   	ret    

0000048e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 48e:	55                   	push   %ebp
 48f:	89 e5                	mov    %esp,%ebp
 491:	57                   	push   %edi
 492:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 493:	8b 4d 08             	mov    0x8(%ebp),%ecx
 496:	8b 55 10             	mov    0x10(%ebp),%edx
 499:	8b 45 0c             	mov    0xc(%ebp),%eax
 49c:	89 cb                	mov    %ecx,%ebx
 49e:	89 df                	mov    %ebx,%edi
 4a0:	89 d1                	mov    %edx,%ecx
 4a2:	fc                   	cld    
 4a3:	f3 aa                	rep stos %al,%es:(%edi)
 4a5:	89 ca                	mov    %ecx,%edx
 4a7:	89 fb                	mov    %edi,%ebx
 4a9:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4ac:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4af:	90                   	nop
 4b0:	5b                   	pop    %ebx
 4b1:	5f                   	pop    %edi
 4b2:	5d                   	pop    %ebp
 4b3:	c3                   	ret    

000004b4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4b4:	55                   	push   %ebp
 4b5:	89 e5                	mov    %esp,%ebp
 4b7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4c0:	90                   	nop
 4c1:	8b 55 0c             	mov    0xc(%ebp),%edx
 4c4:	8d 42 01             	lea    0x1(%edx),%eax
 4c7:	89 45 0c             	mov    %eax,0xc(%ebp)
 4ca:	8b 45 08             	mov    0x8(%ebp),%eax
 4cd:	8d 48 01             	lea    0x1(%eax),%ecx
 4d0:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4d3:	0f b6 12             	movzbl (%edx),%edx
 4d6:	88 10                	mov    %dl,(%eax)
 4d8:	0f b6 00             	movzbl (%eax),%eax
 4db:	84 c0                	test   %al,%al
 4dd:	75 e2                	jne    4c1 <strcpy+0xd>
    ;
  return os;
 4df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e2:	c9                   	leave  
 4e3:	c3                   	ret    

000004e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4e4:	55                   	push   %ebp
 4e5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4e7:	eb 08                	jmp    4f1 <strcmp+0xd>
    p++, q++;
 4e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ed:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	0f b6 00             	movzbl (%eax),%eax
 4f7:	84 c0                	test   %al,%al
 4f9:	74 10                	je     50b <strcmp+0x27>
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	0f b6 10             	movzbl (%eax),%edx
 501:	8b 45 0c             	mov    0xc(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	38 c2                	cmp    %al,%dl
 509:	74 de                	je     4e9 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	0f b6 00             	movzbl (%eax),%eax
 511:	0f b6 d0             	movzbl %al,%edx
 514:	8b 45 0c             	mov    0xc(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	0f b6 c8             	movzbl %al,%ecx
 51d:	89 d0                	mov    %edx,%eax
 51f:	29 c8                	sub    %ecx,%eax
}
 521:	5d                   	pop    %ebp
 522:	c3                   	ret    

00000523 <strlen>:

uint
strlen(char *s)
{
 523:	55                   	push   %ebp
 524:	89 e5                	mov    %esp,%ebp
 526:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 529:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 530:	eb 04                	jmp    536 <strlen+0x13>
 532:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 536:	8b 55 fc             	mov    -0x4(%ebp),%edx
 539:	8b 45 08             	mov    0x8(%ebp),%eax
 53c:	01 d0                	add    %edx,%eax
 53e:	0f b6 00             	movzbl (%eax),%eax
 541:	84 c0                	test   %al,%al
 543:	75 ed                	jne    532 <strlen+0xf>
    ;
  return n;
 545:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 548:	c9                   	leave  
 549:	c3                   	ret    

0000054a <memset>:

void*
memset(void *dst, int c, uint n)
{
 54a:	55                   	push   %ebp
 54b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 54d:	8b 45 10             	mov    0x10(%ebp),%eax
 550:	50                   	push   %eax
 551:	ff 75 0c             	push   0xc(%ebp)
 554:	ff 75 08             	push   0x8(%ebp)
 557:	e8 32 ff ff ff       	call   48e <stosb>
 55c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 562:	c9                   	leave  
 563:	c3                   	ret    

00000564 <strchr>:

char*
strchr(const char *s, char c)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	83 ec 04             	sub    $0x4,%esp
 56a:	8b 45 0c             	mov    0xc(%ebp),%eax
 56d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 570:	eb 14                	jmp    586 <strchr+0x22>
    if(*s == c)
 572:	8b 45 08             	mov    0x8(%ebp),%eax
 575:	0f b6 00             	movzbl (%eax),%eax
 578:	38 45 fc             	cmp    %al,-0x4(%ebp)
 57b:	75 05                	jne    582 <strchr+0x1e>
      return (char*)s;
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	eb 13                	jmp    595 <strchr+0x31>
  for(; *s; s++)
 582:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	0f b6 00             	movzbl (%eax),%eax
 58c:	84 c0                	test   %al,%al
 58e:	75 e2                	jne    572 <strchr+0xe>
  return 0;
 590:	b8 00 00 00 00       	mov    $0x0,%eax
}
 595:	c9                   	leave  
 596:	c3                   	ret    

00000597 <gets>:

char*
gets(char *buf, int max)
{
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 59d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5a4:	eb 42                	jmp    5e8 <gets+0x51>
    cc = read(0, &c, 1);
 5a6:	83 ec 04             	sub    $0x4,%esp
 5a9:	6a 01                	push   $0x1
 5ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5ae:	50                   	push   %eax
 5af:	6a 00                	push   $0x0
 5b1:	e8 47 01 00 00       	call   6fd <read>
 5b6:	83 c4 10             	add    $0x10,%esp
 5b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c0:	7e 33                	jle    5f5 <gets+0x5e>
      break;
    buf[i++] = c;
 5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c5:	8d 50 01             	lea    0x1(%eax),%edx
 5c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5cb:	89 c2                	mov    %eax,%edx
 5cd:	8b 45 08             	mov    0x8(%ebp),%eax
 5d0:	01 c2                	add    %eax,%edx
 5d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5d6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 5d8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5dc:	3c 0a                	cmp    $0xa,%al
 5de:	74 16                	je     5f6 <gets+0x5f>
 5e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5e4:	3c 0d                	cmp    $0xd,%al
 5e6:	74 0e                	je     5f6 <gets+0x5f>
  for(i=0; i+1 < max; ){
 5e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5eb:	83 c0 01             	add    $0x1,%eax
 5ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
 5f1:	7f b3                	jg     5a6 <gets+0xf>
 5f3:	eb 01                	jmp    5f6 <gets+0x5f>
      break;
 5f5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 5f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	01 d0                	add    %edx,%eax
 5fe:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 601:	8b 45 08             	mov    0x8(%ebp),%eax
}
 604:	c9                   	leave  
 605:	c3                   	ret    

00000606 <stat>:

int
stat(char *n, struct stat *st)
{
 606:	55                   	push   %ebp
 607:	89 e5                	mov    %esp,%ebp
 609:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 60c:	83 ec 08             	sub    $0x8,%esp
 60f:	6a 00                	push   $0x0
 611:	ff 75 08             	push   0x8(%ebp)
 614:	e8 0c 01 00 00       	call   725 <open>
 619:	83 c4 10             	add    $0x10,%esp
 61c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 61f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 623:	79 07                	jns    62c <stat+0x26>
    return -1;
 625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 62a:	eb 25                	jmp    651 <stat+0x4b>
  r = fstat(fd, st);
 62c:	83 ec 08             	sub    $0x8,%esp
 62f:	ff 75 0c             	push   0xc(%ebp)
 632:	ff 75 f4             	push   -0xc(%ebp)
 635:	e8 03 01 00 00       	call   73d <fstat>
 63a:	83 c4 10             	add    $0x10,%esp
 63d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 640:	83 ec 0c             	sub    $0xc,%esp
 643:	ff 75 f4             	push   -0xc(%ebp)
 646:	e8 c2 00 00 00       	call   70d <close>
 64b:	83 c4 10             	add    $0x10,%esp
  return r;
 64e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 651:	c9                   	leave  
 652:	c3                   	ret    

00000653 <atoi>:

int
atoi(const char *s)
{
 653:	55                   	push   %ebp
 654:	89 e5                	mov    %esp,%ebp
 656:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 659:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 660:	eb 25                	jmp    687 <atoi+0x34>
    n = n*10 + *s++ - '0';
 662:	8b 55 fc             	mov    -0x4(%ebp),%edx
 665:	89 d0                	mov    %edx,%eax
 667:	c1 e0 02             	shl    $0x2,%eax
 66a:	01 d0                	add    %edx,%eax
 66c:	01 c0                	add    %eax,%eax
 66e:	89 c1                	mov    %eax,%ecx
 670:	8b 45 08             	mov    0x8(%ebp),%eax
 673:	8d 50 01             	lea    0x1(%eax),%edx
 676:	89 55 08             	mov    %edx,0x8(%ebp)
 679:	0f b6 00             	movzbl (%eax),%eax
 67c:	0f be c0             	movsbl %al,%eax
 67f:	01 c8                	add    %ecx,%eax
 681:	83 e8 30             	sub    $0x30,%eax
 684:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 687:	8b 45 08             	mov    0x8(%ebp),%eax
 68a:	0f b6 00             	movzbl (%eax),%eax
 68d:	3c 2f                	cmp    $0x2f,%al
 68f:	7e 0a                	jle    69b <atoi+0x48>
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	0f b6 00             	movzbl (%eax),%eax
 697:	3c 39                	cmp    $0x39,%al
 699:	7e c7                	jle    662 <atoi+0xf>
  return n;
 69b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 69e:	c9                   	leave  
 69f:	c3                   	ret    

000006a0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6a6:	8b 45 08             	mov    0x8(%ebp),%eax
 6a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 6af:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6b2:	eb 17                	jmp    6cb <memmove+0x2b>
    *dst++ = *src++;
 6b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6b7:	8d 42 01             	lea    0x1(%edx),%eax
 6ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8d 48 01             	lea    0x1(%eax),%ecx
 6c3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6c6:	0f b6 12             	movzbl (%edx),%edx
 6c9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6cb:	8b 45 10             	mov    0x10(%ebp),%eax
 6ce:	8d 50 ff             	lea    -0x1(%eax),%edx
 6d1:	89 55 10             	mov    %edx,0x10(%ebp)
 6d4:	85 c0                	test   %eax,%eax
 6d6:	7f dc                	jg     6b4 <memmove+0x14>
  return vdst;
 6d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6db:	c9                   	leave  
 6dc:	c3                   	ret    

000006dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 6dd:	b8 01 00 00 00       	mov    $0x1,%eax
 6e2:	cd 40                	int    $0x40
 6e4:	c3                   	ret    

000006e5 <exit>:
SYSCALL(exit)
 6e5:	b8 02 00 00 00       	mov    $0x2,%eax
 6ea:	cd 40                	int    $0x40
 6ec:	c3                   	ret    

000006ed <wait>:
SYSCALL(wait)
 6ed:	b8 03 00 00 00       	mov    $0x3,%eax
 6f2:	cd 40                	int    $0x40
 6f4:	c3                   	ret    

000006f5 <pipe>:
SYSCALL(pipe)
 6f5:	b8 04 00 00 00       	mov    $0x4,%eax
 6fa:	cd 40                	int    $0x40
 6fc:	c3                   	ret    

000006fd <read>:
SYSCALL(read)
 6fd:	b8 05 00 00 00       	mov    $0x5,%eax
 702:	cd 40                	int    $0x40
 704:	c3                   	ret    

00000705 <write>:
SYSCALL(write)
 705:	b8 10 00 00 00       	mov    $0x10,%eax
 70a:	cd 40                	int    $0x40
 70c:	c3                   	ret    

0000070d <close>:
SYSCALL(close)
 70d:	b8 15 00 00 00       	mov    $0x15,%eax
 712:	cd 40                	int    $0x40
 714:	c3                   	ret    

00000715 <kill>:
SYSCALL(kill)
 715:	b8 06 00 00 00       	mov    $0x6,%eax
 71a:	cd 40                	int    $0x40
 71c:	c3                   	ret    

0000071d <exec>:
SYSCALL(exec)
 71d:	b8 07 00 00 00       	mov    $0x7,%eax
 722:	cd 40                	int    $0x40
 724:	c3                   	ret    

00000725 <open>:
SYSCALL(open)
 725:	b8 0f 00 00 00       	mov    $0xf,%eax
 72a:	cd 40                	int    $0x40
 72c:	c3                   	ret    

0000072d <mknod>:
SYSCALL(mknod)
 72d:	b8 11 00 00 00       	mov    $0x11,%eax
 732:	cd 40                	int    $0x40
 734:	c3                   	ret    

00000735 <unlink>:
SYSCALL(unlink)
 735:	b8 12 00 00 00       	mov    $0x12,%eax
 73a:	cd 40                	int    $0x40
 73c:	c3                   	ret    

0000073d <fstat>:
SYSCALL(fstat)
 73d:	b8 08 00 00 00       	mov    $0x8,%eax
 742:	cd 40                	int    $0x40
 744:	c3                   	ret    

00000745 <link>:
SYSCALL(link)
 745:	b8 13 00 00 00       	mov    $0x13,%eax
 74a:	cd 40                	int    $0x40
 74c:	c3                   	ret    

0000074d <mkdir>:
SYSCALL(mkdir)
 74d:	b8 14 00 00 00       	mov    $0x14,%eax
 752:	cd 40                	int    $0x40
 754:	c3                   	ret    

00000755 <chdir>:
SYSCALL(chdir)
 755:	b8 09 00 00 00       	mov    $0x9,%eax
 75a:	cd 40                	int    $0x40
 75c:	c3                   	ret    

0000075d <dup>:
SYSCALL(dup)
 75d:	b8 0a 00 00 00       	mov    $0xa,%eax
 762:	cd 40                	int    $0x40
 764:	c3                   	ret    

00000765 <getpid>:
SYSCALL(getpid)
 765:	b8 0b 00 00 00       	mov    $0xb,%eax
 76a:	cd 40                	int    $0x40
 76c:	c3                   	ret    

0000076d <sbrk>:
SYSCALL(sbrk)
 76d:	b8 0c 00 00 00       	mov    $0xc,%eax
 772:	cd 40                	int    $0x40
 774:	c3                   	ret    

00000775 <sleep>:
SYSCALL(sleep)
 775:	b8 0d 00 00 00       	mov    $0xd,%eax
 77a:	cd 40                	int    $0x40
 77c:	c3                   	ret    

0000077d <uptime>:
SYSCALL(uptime)
 77d:	b8 0e 00 00 00       	mov    $0xe,%eax
 782:	cd 40                	int    $0x40
 784:	c3                   	ret    

00000785 <uthread_init>:
SYSCALL(uthread_init)
 785:	b8 16 00 00 00       	mov    $0x16,%eax
 78a:	cd 40                	int    $0x40
 78c:	c3                   	ret    

0000078d <thread_inc>:
SYSCALL(thread_inc)
 78d:	b8 17 00 00 00       	mov    $0x17,%eax
 792:	cd 40                	int    $0x40
 794:	c3                   	ret    

00000795 <thread_dec>:
SYSCALL(thread_dec)
 795:	b8 18 00 00 00       	mov    $0x18,%eax
 79a:	cd 40                	int    $0x40
 79c:	c3                   	ret    

0000079d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 79d:	55                   	push   %ebp
 79e:	89 e5                	mov    %esp,%ebp
 7a0:	83 ec 18             	sub    $0x18,%esp
 7a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 7a6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7a9:	83 ec 04             	sub    $0x4,%esp
 7ac:	6a 01                	push   $0x1
 7ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7b1:	50                   	push   %eax
 7b2:	ff 75 08             	push   0x8(%ebp)
 7b5:	e8 4b ff ff ff       	call   705 <write>
 7ba:	83 c4 10             	add    $0x10,%esp
}
 7bd:	90                   	nop
 7be:	c9                   	leave  
 7bf:	c3                   	ret    

000007c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7c0:	55                   	push   %ebp
 7c1:	89 e5                	mov    %esp,%ebp
 7c3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7cd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7d1:	74 17                	je     7ea <printint+0x2a>
 7d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7d7:	79 11                	jns    7ea <printint+0x2a>
    neg = 1;
 7d9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 7e3:	f7 d8                	neg    %eax
 7e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7e8:	eb 06                	jmp    7f0 <printint+0x30>
  } else {
    x = xx;
 7ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 7ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 7f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 7f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7fd:	ba 00 00 00 00       	mov    $0x0,%edx
 802:	f7 f1                	div    %ecx
 804:	89 d1                	mov    %edx,%ecx
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	8d 50 01             	lea    0x1(%eax),%edx
 80c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 80f:	0f b6 91 e4 0f 00 00 	movzbl 0xfe4(%ecx),%edx
 816:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 81a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 81d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 820:	ba 00 00 00 00       	mov    $0x0,%edx
 825:	f7 f1                	div    %ecx
 827:	89 45 ec             	mov    %eax,-0x14(%ebp)
 82a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 82e:	75 c7                	jne    7f7 <printint+0x37>
  if(neg)
 830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 834:	74 2d                	je     863 <printint+0xa3>
    buf[i++] = '-';
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	8d 50 01             	lea    0x1(%eax),%edx
 83c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 83f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 844:	eb 1d                	jmp    863 <printint+0xa3>
    putc(fd, buf[i]);
 846:	8d 55 dc             	lea    -0x24(%ebp),%edx
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	01 d0                	add    %edx,%eax
 84e:	0f b6 00             	movzbl (%eax),%eax
 851:	0f be c0             	movsbl %al,%eax
 854:	83 ec 08             	sub    $0x8,%esp
 857:	50                   	push   %eax
 858:	ff 75 08             	push   0x8(%ebp)
 85b:	e8 3d ff ff ff       	call   79d <putc>
 860:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 863:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 867:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 86b:	79 d9                	jns    846 <printint+0x86>
}
 86d:	90                   	nop
 86e:	90                   	nop
 86f:	c9                   	leave  
 870:	c3                   	ret    

00000871 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 871:	55                   	push   %ebp
 872:	89 e5                	mov    %esp,%ebp
 874:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 877:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 87e:	8d 45 0c             	lea    0xc(%ebp),%eax
 881:	83 c0 04             	add    $0x4,%eax
 884:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 887:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 88e:	e9 59 01 00 00       	jmp    9ec <printf+0x17b>
    c = fmt[i] & 0xff;
 893:	8b 55 0c             	mov    0xc(%ebp),%edx
 896:	8b 45 f0             	mov    -0x10(%ebp),%eax
 899:	01 d0                	add    %edx,%eax
 89b:	0f b6 00             	movzbl (%eax),%eax
 89e:	0f be c0             	movsbl %al,%eax
 8a1:	25 ff 00 00 00       	and    $0xff,%eax
 8a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8ad:	75 2c                	jne    8db <printf+0x6a>
      if(c == '%'){
 8af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8b3:	75 0c                	jne    8c1 <printf+0x50>
        state = '%';
 8b5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8bc:	e9 27 01 00 00       	jmp    9e8 <printf+0x177>
      } else {
        putc(fd, c);
 8c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c4:	0f be c0             	movsbl %al,%eax
 8c7:	83 ec 08             	sub    $0x8,%esp
 8ca:	50                   	push   %eax
 8cb:	ff 75 08             	push   0x8(%ebp)
 8ce:	e8 ca fe ff ff       	call   79d <putc>
 8d3:	83 c4 10             	add    $0x10,%esp
 8d6:	e9 0d 01 00 00       	jmp    9e8 <printf+0x177>
      }
    } else if(state == '%'){
 8db:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8df:	0f 85 03 01 00 00    	jne    9e8 <printf+0x177>
      if(c == 'd'){
 8e5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 8e9:	75 1e                	jne    909 <printf+0x98>
        printint(fd, *ap, 10, 1);
 8eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8ee:	8b 00                	mov    (%eax),%eax
 8f0:	6a 01                	push   $0x1
 8f2:	6a 0a                	push   $0xa
 8f4:	50                   	push   %eax
 8f5:	ff 75 08             	push   0x8(%ebp)
 8f8:	e8 c3 fe ff ff       	call   7c0 <printint>
 8fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 900:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 904:	e9 d8 00 00 00       	jmp    9e1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 909:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 90d:	74 06                	je     915 <printf+0xa4>
 90f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 913:	75 1e                	jne    933 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 915:	8b 45 e8             	mov    -0x18(%ebp),%eax
 918:	8b 00                	mov    (%eax),%eax
 91a:	6a 00                	push   $0x0
 91c:	6a 10                	push   $0x10
 91e:	50                   	push   %eax
 91f:	ff 75 08             	push   0x8(%ebp)
 922:	e8 99 fe ff ff       	call   7c0 <printint>
 927:	83 c4 10             	add    $0x10,%esp
        ap++;
 92a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 92e:	e9 ae 00 00 00       	jmp    9e1 <printf+0x170>
      } else if(c == 's'){
 933:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 937:	75 43                	jne    97c <printf+0x10b>
        s = (char*)*ap;
 939:	8b 45 e8             	mov    -0x18(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 941:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 949:	75 25                	jne    970 <printf+0xff>
          s = "(null)";
 94b:	c7 45 f4 af 0c 00 00 	movl   $0xcaf,-0xc(%ebp)
        while(*s != 0){
 952:	eb 1c                	jmp    970 <printf+0xff>
          putc(fd, *s);
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	0f b6 00             	movzbl (%eax),%eax
 95a:	0f be c0             	movsbl %al,%eax
 95d:	83 ec 08             	sub    $0x8,%esp
 960:	50                   	push   %eax
 961:	ff 75 08             	push   0x8(%ebp)
 964:	e8 34 fe ff ff       	call   79d <putc>
 969:	83 c4 10             	add    $0x10,%esp
          s++;
 96c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	0f b6 00             	movzbl (%eax),%eax
 976:	84 c0                	test   %al,%al
 978:	75 da                	jne    954 <printf+0xe3>
 97a:	eb 65                	jmp    9e1 <printf+0x170>
        }
      } else if(c == 'c'){
 97c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 980:	75 1d                	jne    99f <printf+0x12e>
        putc(fd, *ap);
 982:	8b 45 e8             	mov    -0x18(%ebp),%eax
 985:	8b 00                	mov    (%eax),%eax
 987:	0f be c0             	movsbl %al,%eax
 98a:	83 ec 08             	sub    $0x8,%esp
 98d:	50                   	push   %eax
 98e:	ff 75 08             	push   0x8(%ebp)
 991:	e8 07 fe ff ff       	call   79d <putc>
 996:	83 c4 10             	add    $0x10,%esp
        ap++;
 999:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 99d:	eb 42                	jmp    9e1 <printf+0x170>
      } else if(c == '%'){
 99f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9a3:	75 17                	jne    9bc <printf+0x14b>
        putc(fd, c);
 9a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9a8:	0f be c0             	movsbl %al,%eax
 9ab:	83 ec 08             	sub    $0x8,%esp
 9ae:	50                   	push   %eax
 9af:	ff 75 08             	push   0x8(%ebp)
 9b2:	e8 e6 fd ff ff       	call   79d <putc>
 9b7:	83 c4 10             	add    $0x10,%esp
 9ba:	eb 25                	jmp    9e1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9bc:	83 ec 08             	sub    $0x8,%esp
 9bf:	6a 25                	push   $0x25
 9c1:	ff 75 08             	push   0x8(%ebp)
 9c4:	e8 d4 fd ff ff       	call   79d <putc>
 9c9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9cf:	0f be c0             	movsbl %al,%eax
 9d2:	83 ec 08             	sub    $0x8,%esp
 9d5:	50                   	push   %eax
 9d6:	ff 75 08             	push   0x8(%ebp)
 9d9:	e8 bf fd ff ff       	call   79d <putc>
 9de:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 9e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 9ec:	8b 55 0c             	mov    0xc(%ebp),%edx
 9ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f2:	01 d0                	add    %edx,%eax
 9f4:	0f b6 00             	movzbl (%eax),%eax
 9f7:	84 c0                	test   %al,%al
 9f9:	0f 85 94 fe ff ff    	jne    893 <printf+0x22>
    }
  }
}
 9ff:	90                   	nop
 a00:	90                   	nop
 a01:	c9                   	leave  
 a02:	c3                   	ret    

00000a03 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a03:	55                   	push   %ebp
 a04:	89 e5                	mov    %esp,%ebp
 a06:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a09:	8b 45 08             	mov    0x8(%ebp),%eax
 a0c:	83 e8 08             	sub    $0x8,%eax
 a0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a12:	a1 c8 50 01 00       	mov    0x150c8,%eax
 a17:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a1a:	eb 24                	jmp    a40 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1f:	8b 00                	mov    (%eax),%eax
 a21:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a24:	72 12                	jb     a38 <free+0x35>
 a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a29:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a2c:	77 24                	ja     a52 <free+0x4f>
 a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a31:	8b 00                	mov    (%eax),%eax
 a33:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a36:	72 1a                	jb     a52 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3b:	8b 00                	mov    (%eax),%eax
 a3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a40:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a43:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 a46:	76 d4                	jbe    a1c <free+0x19>
 a48:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4b:	8b 00                	mov    (%eax),%eax
 a4d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a50:	73 ca                	jae    a1c <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a52:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a55:	8b 40 04             	mov    0x4(%eax),%eax
 a58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a5f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a62:	01 c2                	add    %eax,%edx
 a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	39 c2                	cmp    %eax,%edx
 a6b:	75 24                	jne    a91 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a70:	8b 50 04             	mov    0x4(%eax),%edx
 a73:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a76:	8b 00                	mov    (%eax),%eax
 a78:	8b 40 04             	mov    0x4(%eax),%eax
 a7b:	01 c2                	add    %eax,%edx
 a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a80:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a83:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a86:	8b 00                	mov    (%eax),%eax
 a88:	8b 10                	mov    (%eax),%edx
 a8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a8d:	89 10                	mov    %edx,(%eax)
 a8f:	eb 0a                	jmp    a9b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a91:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a94:	8b 10                	mov    (%eax),%edx
 a96:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a99:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9e:	8b 40 04             	mov    0x4(%eax),%eax
 aa1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 aa8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aab:	01 d0                	add    %edx,%eax
 aad:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ab0:	75 20                	jne    ad2 <free+0xcf>
    p->s.size += bp->s.size;
 ab2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab5:	8b 50 04             	mov    0x4(%eax),%edx
 ab8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 abb:	8b 40 04             	mov    0x4(%eax),%eax
 abe:	01 c2                	add    %eax,%edx
 ac0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ac6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ac9:	8b 10                	mov    (%eax),%edx
 acb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ace:	89 10                	mov    %edx,(%eax)
 ad0:	eb 08                	jmp    ada <free+0xd7>
  } else
    p->s.ptr = bp;
 ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ad8:	89 10                	mov    %edx,(%eax)
  freep = p;
 ada:	8b 45 fc             	mov    -0x4(%ebp),%eax
 add:	a3 c8 50 01 00       	mov    %eax,0x150c8
}
 ae2:	90                   	nop
 ae3:	c9                   	leave  
 ae4:	c3                   	ret    

00000ae5 <morecore>:

static Header*
morecore(uint nu)
{
 ae5:	55                   	push   %ebp
 ae6:	89 e5                	mov    %esp,%ebp
 ae8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 aeb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 af2:	77 07                	ja     afb <morecore+0x16>
    nu = 4096;
 af4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 afb:	8b 45 08             	mov    0x8(%ebp),%eax
 afe:	c1 e0 03             	shl    $0x3,%eax
 b01:	83 ec 0c             	sub    $0xc,%esp
 b04:	50                   	push   %eax
 b05:	e8 63 fc ff ff       	call   76d <sbrk>
 b0a:	83 c4 10             	add    $0x10,%esp
 b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b10:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b14:	75 07                	jne    b1d <morecore+0x38>
    return 0;
 b16:	b8 00 00 00 00       	mov    $0x0,%eax
 b1b:	eb 26                	jmp    b43 <morecore+0x5e>
  hp = (Header*)p;
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b26:	8b 55 08             	mov    0x8(%ebp),%edx
 b29:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b2f:	83 c0 08             	add    $0x8,%eax
 b32:	83 ec 0c             	sub    $0xc,%esp
 b35:	50                   	push   %eax
 b36:	e8 c8 fe ff ff       	call   a03 <free>
 b3b:	83 c4 10             	add    $0x10,%esp
  return freep;
 b3e:	a1 c8 50 01 00       	mov    0x150c8,%eax
}
 b43:	c9                   	leave  
 b44:	c3                   	ret    

00000b45 <malloc>:

void*
malloc(uint nbytes)
{
 b45:	55                   	push   %ebp
 b46:	89 e5                	mov    %esp,%ebp
 b48:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b4b:	8b 45 08             	mov    0x8(%ebp),%eax
 b4e:	83 c0 07             	add    $0x7,%eax
 b51:	c1 e8 03             	shr    $0x3,%eax
 b54:	83 c0 01             	add    $0x1,%eax
 b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b5a:	a1 c8 50 01 00       	mov    0x150c8,%eax
 b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b62:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b66:	75 23                	jne    b8b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b68:	c7 45 f0 c0 50 01 00 	movl   $0x150c0,-0x10(%ebp)
 b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b72:	a3 c8 50 01 00       	mov    %eax,0x150c8
 b77:	a1 c8 50 01 00       	mov    0x150c8,%eax
 b7c:	a3 c0 50 01 00       	mov    %eax,0x150c0
    base.s.size = 0;
 b81:	c7 05 c4 50 01 00 00 	movl   $0x0,0x150c4
 b88:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b8e:	8b 00                	mov    (%eax),%eax
 b90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b96:	8b 40 04             	mov    0x4(%eax),%eax
 b99:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b9c:	77 4d                	ja     beb <malloc+0xa6>
      if(p->s.size == nunits)
 b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba1:	8b 40 04             	mov    0x4(%eax),%eax
 ba4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ba7:	75 0c                	jne    bb5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bac:	8b 10                	mov    (%eax),%edx
 bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb1:	89 10                	mov    %edx,(%eax)
 bb3:	eb 26                	jmp    bdb <malloc+0x96>
      else {
        p->s.size -= nunits;
 bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb8:	8b 40 04             	mov    0x4(%eax),%eax
 bbb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 bbe:	89 c2                	mov    %eax,%edx
 bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc9:	8b 40 04             	mov    0x4(%eax),%eax
 bcc:	c1 e0 03             	shl    $0x3,%eax
 bcf:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bd8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bde:	a3 c8 50 01 00       	mov    %eax,0x150c8
      return (void*)(p + 1);
 be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be6:	83 c0 08             	add    $0x8,%eax
 be9:	eb 3b                	jmp    c26 <malloc+0xe1>
    }
    if(p == freep)
 beb:	a1 c8 50 01 00       	mov    0x150c8,%eax
 bf0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 bf3:	75 1e                	jne    c13 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 bf5:	83 ec 0c             	sub    $0xc,%esp
 bf8:	ff 75 ec             	push   -0x14(%ebp)
 bfb:	e8 e5 fe ff ff       	call   ae5 <morecore>
 c00:	83 c4 10             	add    $0x10,%esp
 c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c0a:	75 07                	jne    c13 <malloc+0xce>
        return 0;
 c0c:	b8 00 00 00 00       	mov    $0x0,%eax
 c11:	eb 13                	jmp    c26 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c16:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1c:	8b 00                	mov    (%eax),%eax
 c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c21:	e9 6d ff ff ff       	jmp    b93 <malloc+0x4e>
  }
}
 c26:	c9                   	leave  
 c27:	c3                   	ret    
