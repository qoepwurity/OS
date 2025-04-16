#include "types.h"
#include "stat.h"
#include "user.h"

#define FREE     0x0
#define RUNNING  0x1
#define RUNNABLE 0x2
#define WAIT     0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread {
  int sp;
  char stack[STACK_SIZE];
  int state;
  int tid;
  int ptid;
} thread_t, *thread_p;

static thread_t all_thread[MAX_THREAD];
thread_p current_thread;
thread_p next_thread;

extern void thread_switch(void);
extern int thread_inc(void);
extern int thread_dec(void);

static void thread_schedule(void);

void
thread_init(void)
{
  uthread_init((int)thread_schedule);

  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid = 0;
  current_thread->ptid = 0;
}

static void
thread_schedule(void)
{
  thread_p t;
  next_thread = 0;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    if (current_thread->state == RUNNING) {
      next_thread = current_thread;
    } else {
      printf(2, "thread_schedule: no runnable threads\n");
      exit();
    }
  }

  if (current_thread != next_thread) {
    next_thread->state = RUNNING;
    if (current_thread->state == RUNNING && current_thread != &all_thread[0])
      current_thread->state = RUNNABLE;
    thread_switch();
  } else {
    next_thread = 0;
  }
}

int thread_create(void (*func)())
{
  thread_p t = 0;

  int start = current_thread - all_thread;
  for (int i = 1; i <= MAX_THREAD; i++) {
    int idx = (start + i) % MAX_THREAD;
    if (all_thread[idx].state == FREE) {
      t = &all_thread[idx];
      break;
    }
  }

  if (t == 0)
    return -1;

  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;
  *(int *)(t->sp) = (int)func;
  t->sp -= 32;

  t->state = RUNNABLE;
  t->tid = t - all_thread;
  t->ptid = current_thread->tid;

  thread_inc();
  return t->tid;
}

static void
thread_join(int tid)
{
  thread_p t = &all_thread[tid];

  while (t->state != FREE) {
    current_thread->state = WAIT;
    thread_schedule();
  }
}

static void
wake_parent(void)
{
  for (int i = 0; i < MAX_THREAD; i++) {
    if (all_thread[i].tid == current_thread->ptid &&
        all_thread[i].state == WAIT) {
      all_thread[i].state = RUNNABLE;
      break;
    }
  }
}

static void
child_thread(void)
{
  int i;
  printf(1, "child thread running\n");
  for (i = 0; i < 100; i++) {
    printf(1, "child thread 0x%x\n", (int)current_thread);
  }
  printf(1, "child thread: exit\n");
  current_thread->state = FREE;
  thread_dec();
  wake_parent();
  thread_schedule();
}

static void
mythread(void)
{
  int i;
  int tid[5];

  printf(1, "my thread running\n");

  for (i = 0; i < 5; i++) {
    tid[i] = thread_create(child_thread);
  }

  for (i = 0; i < 5; i++) {
    thread_join(tid[i]);
  }

  printf(1, "my thread: exit\n");
  current_thread->state = FREE;
  thread_dec();
  thread_schedule();
}

int
main(int argc, char *argv[])
{
  int tid;
  thread_init();
  tid = thread_create(mythread);
  thread_join(tid);
  return 0;
}
