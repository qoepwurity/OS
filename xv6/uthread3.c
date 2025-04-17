#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2
#define WAIT        0x3     //스레드 대기중

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int        tid;    /* thread id */
  int        sp;                /* saved stack pointer */ //스레드의 실행 상태 추적
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE, WAIT */
};

static thread_t all_thread[MAX_THREAD];
thread_p  current_thread;   //현재 실행중인 스레드
thread_p  next_thread;      //다음으로 실행할 스레드
extern void thread_switch(void);

static void 
thread_schedule(void)
{
  thread_p t;   //thread_t 구조체의 포인터

  /* Find another runnable thread. */
  next_thread = 0;  // null로 초기화
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    //모든 스레드 배열을 돌아다니면서
    //실행대기중이고 현재 스레드가 아닌 스레드를 찾아 next_thread에 할당
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;  
      break;
    }
  }

  // 스레드 배열 안에는 실행 가능한게 없고 현재 스레드가 runnable 상태면 
  // 현재 스레드를 계속 실행
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  }

  //그냥 실행가능한 스레드가 없는 경우. next_thread가 초기화 그대로인 상태.
  if (next_thread == 0) {
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }
  /*end of finding another runnable thread */

  //다른 스레드로 전환해야 하는 경우.
  if (current_thread != next_thread) {         /* switch threads?  */
    next_thread->state = RUNNING;
    current_thread->state = RUNNABLE;
    thread_switch();
  } else
    next_thread = 0;
}

void 
thread_init(void)
{
  uthread_init((int)thread_schedule);

  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid=0;
}

int
thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {  //모든 스레드를 돌면서~
    if (t->state == FREE) break;    //상태가 free면. 즉 스레드 만들 수 있는 게 있다.
  }

  //added from thread1
  if (t == all_thread + MAX_THREAD) {
    printf(1, "thread_create: no available slot\n");
    return -1;
  }

  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
  t->sp -= 4;                              // 리턴 주소를 위한 공간
  
  /* set tid */
  t->tid = t - all_thread; // 배열에서 인덱스로 tid 설정  


  //
  *((int *)(t->sp)) = (int)func;           // push return address on stack
  t->sp -= 32;                             // space for registers that thread_switch expects
  t->state = RUNNABLE;
  check_counter(+1);  //added from thread1

  return t->tid;
}


static void 
thread_suspend(int tid)
{
  thread_p t;
  // 주어진 tid에 해당하는 스레드를 찾기.
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->tid == tid) {
      break;
    }
  }
  
  // 만약 tid에 해당하는 스레드가 존재하지 않으면 종료
  if (t >= all_thread + MAX_THREAD) {
    printf(2, "thread_suspend: thread with tid %d not found\n", tid);
    return;
  }

  // 이미 멈춰있는 스레드는 다시 멈출 수 없도록 처리
  if (t->state == WAIT) {
    printf(2, "thread_suspend: thread with tid %d is already suspended\n", tid);
    return;
  }

  // 스레드 상태를 WAIT로 설정하여 멈추기
  t->state = WAIT;

  // 현재 스레드가 멈추는 경우, 스케줄러에 의해 다른 스레드가 실행되도록 한다.
  if (t == current_thread) {
    thread_schedule();
  }

  printf(1, "thread %d suspended\n", tid);
}

static void 
thread_resume(int tid)
{
  thread_p t;

  // 주어진 tid에 해당하는 스레드를 찾습니다.
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->tid == tid) {
      break;
    }
  }

  // 만약 tid에 해당하는 스레드가 존재하지 않으면 에러 처리
  if (t >= all_thread + MAX_THREAD) {
    printf(2, "thread_resume: thread with tid %d not found\n", tid);
    return;
  }

  // 이미 실행 중인 스레드는 재개할 필요 없음
  if (t->state == RUNNING) {
    printf(2, "thread_resume: thread with tid %d is already running\n", tid);
    return;
  }

  // 스레드 상태를 RUNNABLE로 설정하여 재개 가능하도록 설정
  t->state = RUNNABLE;

  printf(1, "thread %d resumed\n", tid);
}

/*스레드가 실행할 코드*/
static void 
mythread(void)
{
  int i;
  printf(1, "my thread running\n");
  for (i = 0; i < 100; i++) {
    printf(1, "my thread %d\n", current_thread->tid);   //현재 스레드의 id
  }
  printf(1, "my thread: exit\n");
  current_thread->state = FREE;

  //uthread1에 있던 거 추가
  check_counter(-1);
  thread_schedule();
}


int 
main(int argc, char *argv[]) 
{
  int tid1, tid2,tid3;
  printf(1, "main start~~!!\n");
  thread_init();
  tid1=thread_create((void (*)())mythread);
  tid2=thread_create((void (*)())mythread);
  tid3=thread_create((void (*)())mythread);
  sleep(100); /* you can adjust the sleep time */
  thread_suspend(tid1);
  sleep(100);
  thread_suspend(tid2);
  sleep(100);
  thread_suspend(tid3);
  sleep(100);
  thread_suspend(tid1);
  thread_resume(tid1);
  sleep(100);
  thread_resume(tid2);
  sleep(100);
  thread_resume(tid3);
  sleep(100);
  exit();
}