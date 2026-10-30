#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// ===== MLFQ config (assignment3) Modified ===== 
#define Q0_SLICE 3
#define Q1_SLICE 6
#define Q2_SLICE 12
#define BOOST_PERIOD 100  // every 100 ticks promote all to Q0

// rr: queue start point for each level
static int rr_idx[3] = {0, 0, 0};

// level up tick
extern uint ticks;            // trap.c
static uint last_global_boost = 0;

static inline int slice_of_level(int lv){
  if(lv == 0) return Q0_SLICE;
  if(lv == 1) return Q1_SLICE;
  return Q2_SLICE;
}


struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
   //Modified: init Q0: enter Q0 directly
  p->queue_level = 0;        
  p->remaining_ticks = Q0_SLICE;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  //Modified: enter Q0 directly
  p->queue_level = 0;
  p->remaining_ticks = Q0_SLICE;

  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if(sz + n > TRAPFRAME) {
      return -1;
    }
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
kfork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;
    //Modified: enter Q0 directly
  np->queue_level = 0;
  np->remaining_ticks = Q0_SLICE;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
kexit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
kwait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.

/*assignment 3 Modified:
──────────────────────────────────────────────────────────────────────────────
Scheduler overview (MLFQ with periodic global boost and per-level round-robin)
──────────────────────────────────────────────────────────────────────────────

High-level intent
-----------------
- Each CPU runs this infinite scheduler loop.
- We implement a 3-level MLFQ (Q0 > Q1 > Q2). Within the same level we do
  round-robin using a per-level cursor rr_idx[level].
- A periodic "global boost" promotes all non-UNUSED processes back to Q0 and
  restores their time slice to Q0_SLICE, preventing starvation of interactive
  or previously CPU-bound tasks.

Key data/assumptions
--------------------
- 'ticks' is a global tick counter advanced by the timer interrupt.
- 'last_global_boost' records when we last boosted; we boost again after
  BOOST_PERIOD ticks have elapsed.
- 'proc[]' is the global process table; each 'struct proc' has:
    state          : UNUSED / USED / SLEEPING / RUNNABLE / RUNNING / ZOMBIE
    queue_level    : 0, 1, or 2 (0 is highest priority)
    remaining_ticks: time slice left at the current queue level
- 'rr_idx[level]' remembers the next index to probe within 'proc[]' for RR.

Interrupt discipline
--------------------
- intr_on(); intr_off(); sequence ensures pending interrupts (e.g., timer)
  are serviced at least once per loop, but the actual scheduling decision
  and context switch run with interrupts disabled to avoid races while
  examining and selecting a RUNNABLE process.

Periodic global boost
---------------------
- If (ticks - last_global_boost) >= BOOST_PERIOD:
    For every process p:
      If p->state != UNUSED and p->queue_level > 0:
        Promote it to Q0 and reset its time slice to Q0_SLICE.
    Update last_global_boost = ticks.

  Effect:
  - Prevents starvation of tasks that have sunk into lower queues (e.g., CPU-bound).
  - Gives all processes a fresh chance at the highest priority level.
  - Runnable tasks at Q0 will preempt lower-level tasks sooner.

Priority scan + per-level round-robin
-------------------------------------
- We scan levels in priority order: level = 0, 1, 2.
- For each level:
    start = rr_idx[level];                      // RR starting cursor
    For step in [0 .. NPROC-1]:
      i = (start + step) % NPROC;
      p = &proc[i];
      acquire(&p->lock);
      If (p->state == RUNNABLE && p->queue_level == level):
        rr_idx[level] = (i + 1) % NPROC;        // advance RR cursor
        printf("[SCHED] PID %d running in Q%d (remaining ticks: %d)\n",
               p->pid, p->queue_level, p->remaining_ticks);
        p->state = RUNNING;                     // mark chosen
        c->proc  = p;                           // bind to this CPU
        swtch(&c->context, &p->context);        // context switch to p
        c->proc  = 0;                           // upon return, process yielded/preempted/blocked
        found = 1;
        release(&p->lock);
        break (out of inner loop)
      release(&p->lock);

  Notes:
  - The time-slice accounting and possible demotion (Q0→Q1→Q2) typically happen
    in the timer interrupt handler (not shown here): it decrements remaining_ticks
    on RUNNING processes and, when it reaches zero, resets remaining_ticks for
    the next level and causes a yield.
  - Because we always scan levels 0→1→2 and pick the first runnable match,
    higher priorities preempt lower ones.
  - rr_idx[level] ensures fairness among processes *within the same level*.

Idle path
---------
- If no RUNNABLE process was found at any level, execute 'wfi' (wait-for-interrupt),
  putting the CPU into a low-power/idle state until the next interrupt (e.g., timer
  tick or I/O completion) makes more work available.

Locking & safety
----------------
- We hold p->lock whenever we read or modify per-process fields such as 'state',
  'queue_level', and 'remaining_ticks'. This prevents a process from being
  concurrently scheduled on two CPUs and avoids races with wakeups or exits.
- Global variables used for boosting (ticks / last_global_boost) are read
  without grabbing 'tickslock' here; the timer interrupt is the writer and this
  read-only check tolerates slight skew (boost will still happen soon).

Complexity & properties
-----------------------
- In the worst case we examine up to 3 * NPROC slots per scheduling iteration.
- The design enforces:
    * Priority over lower levels (MLFQ).
    * Fairness within each level (RR via rr_idx[level]).
    * Starvation avoidance via periodic global boost.
    * Immediate handoff to the chosen process via swtch().
*/

void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;){
    intr_on();
    intr_off();

    // ===== 1) lift every period：every BOOST_PERIOD tick lift Q1/Q2 to Q0 =====
    if(ticks - last_global_boost >= BOOST_PERIOD){
      for(p = proc; p < &proc[NPROC]; p++){
        acquire(&p->lock);
        if(p->state != UNUSED && p->queue_level > 0){
          p->queue_level = 0;
          p->remaining_ticks = Q0_SLICE;
          // runnable process will be sheduled first
        }
        release(&p->lock);
      }
      last_global_boost = ticks;
    }

    // ===== 2) Q0->Q1->Q2, same level RR
    int found = 0;
    for(int level = 0; level < 3 && !found; level++){
      int start = rr_idx[level];
      for(int step = 0; step < NPROC; step++){
        int i = (start + step) % NPROC;
        p = &proc[i];

        acquire(&p->lock);
        if(p->state == RUNNABLE && p->queue_level == level){
          // hit
          rr_idx[level] = (i + 1) % NPROC;
          printf("[SCHED]  PID %d running in Q%d (remaining ticks: %d), at tick %d\n", p->pid, p->queue_level, p->remaining_ticks, ticks);
          // shift to that process
          p->state = RUNNING;
          c->proc = p;
          swtch(&c->context, &p->context);

          
          c->proc = 0;
          found = 1;
          release(&p->lock);
          break;
        }
        release(&p->lock);
      }
    }

    if(found == 0){
      // no runnable process
      asm volatile("wfi");
    }
  }
}


// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched RUNNING");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();

  // Still holding p->lock from scheduler.
  release(&p->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    if (p->trapframe->a0 == -1) {
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
  uint64 satp = MAKE_SATP(p->pagetable);
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
        //Modified: IO wake up to previous queue
        p->remaining_ticks = slice_of_level(p->queue_level);
        printf("[WAKEUP] PID %d returns to Q%d (I/O completed)\n", p->pid, p->queue_level);
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
