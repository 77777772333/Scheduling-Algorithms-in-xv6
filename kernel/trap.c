#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// ===== MLFQ config (keep in sync with proc.c) =====
#define Q0_SLICE 3
#define Q1_SLICE 6
#define Q2_SLICE 12

static inline int slice_of_level(int lv){
  return (lv == 0) ? Q0_SLICE : (lv == 1) ? Q1_SLICE : Q2_SLICE;
}

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from, and returns to, trampoline.S
// return value is user satp for trampoline.S to switch to.
//
uint64
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);  //DOC: kernelvec

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      kexit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else if((r_scause() == 15 || r_scause() == 13) &&
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    // page fault on lazily-allocated page
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    kexit(-1);

  // give up the CPU if this is a timer interrupt.
  // MLFQ: on timer interrupt, consume time slice and preempt only if expired.

  /*assingemnt3 modified
──────────────────────────────────────────────────────────────────────────────
Timer interrupt (which_dev == 2): time-slice accounting and level demotion
──────────────────────────────────────────────────────────────────────────────

Purpose
-------
This block runs on each timer interrupt. For the *currently running* process
(myproc()), it:
  1) Decrements the remaining time slice at its current MLFQ level.
  2) If the slice is exhausted (== 0), demotes the process to a lower-priority
     queue (unless already at the lowest level), reloads the appropriate time
     slice for that new level, releases the lock, and forces a reschedule via
     yield().

Step-by-step
------------
- which_dev == 2
  Means a timer interrupt fired.

- struct proc *p = myproc();
  We only manage time accounting for the process that is currently running on
  this CPU. If there is no current process, nothing to do.

- acquire(&p->lock);
  We serialize updates to p->state / p->queue_level / p->remaining_ticks so that
  no other CPU or wakeup path races with us while we are changing these fields.

- if (p->state == RUNNING) { ... }
  We only decrement time if the process is actually RUNNING. (A RUNNABLE or
  SLEEPING process should not be spending its quantum.)

- if (p->remaining_ticks > 0) p->remaining_ticks--;
  Consume one tick from the current level's time slice.

- if (p->remaining_ticks == 0) {
      if (p->queue_level < 2) p->queue_level++;
      p->remaining_ticks = slice_of_level(p->queue_level);
      release(&p->lock);
      yield();
  } else {
      release(&p->lock);
  }
  When the time slice is exhausted:
    • Demote one level (Q0→Q1→Q2) if not already at the lowest (Q2).
    • Reload the time slice according to the new level via slice_of_level().
    • Release the lock *before* calling yield(), because yield() will
      switch context and may try to acquire the same lock elsewhere.
    • Call yield() to immediately hand the CPU back to the scheduler so a
      (possibly different) process can run next. This is what enforces
      preemption and RR/MLFQ behavior at tick boundaries.

Locking discipline
------------------
- We hold p->lock only while checking/modifying RUNNING state, queue_level,
  and remaining_ticks. We must release it before yield() to avoid deadlocks
  and to let the scheduler safely pick the next process.

MLFQ semantics enforced here
----------------------------
- CPU-bound tasks that continuously consume their quantum are gradually pushed
  down to lower-priority queues (longer quanta but less frequent selection).
- I/O-bound or interactive tasks typically sleep/wakeup and therefore often
  reenter the scheduler with a fresh slice at a higher level (handled in
  wakeup()), keeping good responsiveness.

Edge cases / notes
------------------
- If the process is already at Q2, we do not demote further; we only reload
  the Q2 slice and yield.
- If p->state changed away from RUNNING by the time we reach here (rare but
  possible under heavy concurrency), we simply drop the lock and do nothing.

Correctness cues in logs
------------------------
- You should observe in logs that RUNNING processes see their remaining_ticks
  decrease each tick, and once it hits zero, you see a demotion (unless at Q2),
  a slice reload, and an immediate yield to the scheduler. This matches classic
  MLFQ time-slicing behavior.
*/

  if(which_dev == 2){
    struct proc *p = myproc();  
    if(p){
      acquire(&p->lock);
      if(p->state == RUNNING){
        if(p->remaining_ticks > 0)
          p->remaining_ticks--;
        if(p->remaining_ticks == 0){
          if(p->queue_level < 2)
          {
            p->queue_level++;
            printf("[TICK] PID %d time slice expired, demoted to Q%d\n", p->pid, p->queue_level);
          }
          p->remaining_ticks = slice_of_level(p->queue_level);
          release(&p->lock);
          yield();   
        }else{
          release(&p->lock);
        }
      }else{
        release(&p->lock);
      }
    }
  }


  prepare_return();

  // the user page table to switch to, for trampoline.S
  uint64 satp = MAKE_SATP(p->pagetable);

  // return to trampoline.S; satp value in a0.
  return satp;
}

//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    // interrupt or trap from an unknown source
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  // MLFQ: in kernel mode, same time-slice accounting.
  // same as previously explained block in usertrap()
  if(which_dev == 2){
    struct proc *p = myproc();
    if(p){
      acquire(&p->lock);
      if(p->state == RUNNING){
        if(p->remaining_ticks > 0)
          p->remaining_ticks--;
        if(p->remaining_ticks == 0){
          if(p->queue_level < 2)
            p->queue_level++;
          p->remaining_ticks = slice_of_level(p->queue_level);
          release(&p->lock);
          yield();
        }else{
          release(&p->lock);
        }
      }else{
        release(&p->lock);
      }
    }
  }


  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}

