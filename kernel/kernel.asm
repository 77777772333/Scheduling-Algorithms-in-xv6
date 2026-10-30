
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8f813103          	ld	sp,-1800(sp) # 800078f8 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd7a7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d7878793          	addi	a5,a5,-648 # 80000df8 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	20c020ef          	jal	ra,80002316 <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	724000ef          	jal	ra,8000083c <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7119                	addi	sp,sp,-128
    8000014e:	fc86                	sd	ra,120(sp)
    80000150:	f8a2                	sd	s0,112(sp)
    80000152:	f4a6                	sd	s1,104(sp)
    80000154:	f0ca                	sd	s2,96(sp)
    80000156:	ecce                	sd	s3,88(sp)
    80000158:	e8d2                	sd	s4,80(sp)
    8000015a:	e4d6                	sd	s5,72(sp)
    8000015c:	e0da                	sd	s6,64(sp)
    8000015e:	fc5e                	sd	s7,56(sp)
    80000160:	f862                	sd	s8,48(sp)
    80000162:	f466                	sd	s9,40(sp)
    80000164:	f06a                	sd	s10,32(sp)
    80000166:	ec6e                	sd	s11,24(sp)
    80000168:	0100                	addi	s0,sp,128
    8000016a:	8b2a                	mv	s6,a0
    8000016c:	8aae                	mv	s5,a1
    8000016e:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000170:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000174:	0000f517          	auipc	a0,0xf
    80000178:	7cc50513          	addi	a0,a0,1996 # 8000f940 <cons>
    8000017c:	1ff000ef          	jal	ra,80000b7a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000180:	0000f497          	auipc	s1,0xf
    80000184:	7c048493          	addi	s1,s1,1984 # 8000f940 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000188:	89a6                	mv	s3,s1
    8000018a:	00010917          	auipc	s2,0x10
    8000018e:	84e90913          	addi	s2,s2,-1970 # 8000f9d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80000192:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000194:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000196:	4da9                	li	s11,10
  while(n > 0){
    80000198:	07405363          	blez	s4,800001fe <consoleread+0xb2>
    while(cons.r == cons.w){
    8000019c:	0984a783          	lw	a5,152(s1)
    800001a0:	09c4a703          	lw	a4,156(s1)
    800001a4:	02f71163          	bne	a4,a5,800001c6 <consoleread+0x7a>
      if(killed(myproc())){
    800001a8:	672010ef          	jal	ra,8000181a <myproc>
    800001ac:	7fd010ef          	jal	ra,800021a8 <killed>
    800001b0:	e125                	bnez	a0,80000210 <consoleread+0xc4>
      sleep(&cons.r, &cons.lock);
    800001b2:	85ce                	mv	a1,s3
    800001b4:	854a                	mv	a0,s2
    800001b6:	57b010ef          	jal	ra,80001f30 <sleep>
    while(cons.r == cons.w){
    800001ba:	0984a783          	lw	a5,152(s1)
    800001be:	09c4a703          	lw	a4,156(s1)
    800001c2:	fef703e3          	beq	a4,a5,800001a8 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c6:	0017871b          	addiw	a4,a5,1
    800001ca:	08e4ac23          	sw	a4,152(s1)
    800001ce:	07f7f713          	andi	a4,a5,127
    800001d2:	9726                	add	a4,a4,s1
    800001d4:	01874703          	lbu	a4,24(a4)
    800001d8:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001dc:	079c0063          	beq	s8,s9,8000023c <consoleread+0xf0>
    cbuf = c;
    800001e0:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e4:	4685                	li	a3,1
    800001e6:	f8f40613          	addi	a2,s0,-113
    800001ea:	85d6                	mv	a1,s5
    800001ec:	855a                	mv	a0,s6
    800001ee:	0de020ef          	jal	ra,800022cc <either_copyout>
    800001f2:	01a50663          	beq	a0,s10,800001fe <consoleread+0xb2>
    dst++;
    800001f6:	0a85                	addi	s5,s5,1
    --n;
    800001f8:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800001fa:	f9bc1fe3          	bne	s8,s11,80000198 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fe:	0000f517          	auipc	a0,0xf
    80000202:	74250513          	addi	a0,a0,1858 # 8000f940 <cons>
    80000206:	20d000ef          	jal	ra,80000c12 <release>

  return target - n;
    8000020a:	414b853b          	subw	a0,s7,s4
    8000020e:	a801                	j	8000021e <consoleread+0xd2>
        release(&cons.lock);
    80000210:	0000f517          	auipc	a0,0xf
    80000214:	73050513          	addi	a0,a0,1840 # 8000f940 <cons>
    80000218:	1fb000ef          	jal	ra,80000c12 <release>
        return -1;
    8000021c:	557d                	li	a0,-1
}
    8000021e:	70e6                	ld	ra,120(sp)
    80000220:	7446                	ld	s0,112(sp)
    80000222:	74a6                	ld	s1,104(sp)
    80000224:	7906                	ld	s2,96(sp)
    80000226:	69e6                	ld	s3,88(sp)
    80000228:	6a46                	ld	s4,80(sp)
    8000022a:	6aa6                	ld	s5,72(sp)
    8000022c:	6b06                	ld	s6,64(sp)
    8000022e:	7be2                	ld	s7,56(sp)
    80000230:	7c42                	ld	s8,48(sp)
    80000232:	7ca2                	ld	s9,40(sp)
    80000234:	7d02                	ld	s10,32(sp)
    80000236:	6de2                	ld	s11,24(sp)
    80000238:	6109                	addi	sp,sp,128
    8000023a:	8082                	ret
      if(n < target){
    8000023c:	000a071b          	sext.w	a4,s4
    80000240:	fb777fe3          	bgeu	a4,s7,800001fe <consoleread+0xb2>
        cons.r--;
    80000244:	0000f717          	auipc	a4,0xf
    80000248:	78f72a23          	sw	a5,1940(a4) # 8000f9d8 <cons+0x98>
    8000024c:	bf4d                	j	800001fe <consoleread+0xb2>

000000008000024e <consputc>:
{
    8000024e:	1141                	addi	sp,sp,-16
    80000250:	e406                	sd	ra,8(sp)
    80000252:	e022                	sd	s0,0(sp)
    80000254:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000256:	10000793          	li	a5,256
    8000025a:	00f50863          	beq	a0,a5,8000026a <consputc+0x1c>
    uartputc_sync(c);
    8000025e:	67c000ef          	jal	ra,800008da <uartputc_sync>
}
    80000262:	60a2                	ld	ra,8(sp)
    80000264:	6402                	ld	s0,0(sp)
    80000266:	0141                	addi	sp,sp,16
    80000268:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000026a:	4521                	li	a0,8
    8000026c:	66e000ef          	jal	ra,800008da <uartputc_sync>
    80000270:	02000513          	li	a0,32
    80000274:	666000ef          	jal	ra,800008da <uartputc_sync>
    80000278:	4521                	li	a0,8
    8000027a:	660000ef          	jal	ra,800008da <uartputc_sync>
    8000027e:	b7d5                	j	80000262 <consputc+0x14>

0000000080000280 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000280:	1101                	addi	sp,sp,-32
    80000282:	ec06                	sd	ra,24(sp)
    80000284:	e822                	sd	s0,16(sp)
    80000286:	e426                	sd	s1,8(sp)
    80000288:	e04a                	sd	s2,0(sp)
    8000028a:	1000                	addi	s0,sp,32
    8000028c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000028e:	0000f517          	auipc	a0,0xf
    80000292:	6b250513          	addi	a0,a0,1714 # 8000f940 <cons>
    80000296:	0e5000ef          	jal	ra,80000b7a <acquire>

  switch(c){
    8000029a:	47d5                	li	a5,21
    8000029c:	0af48063          	beq	s1,a5,8000033c <consoleintr+0xbc>
    800002a0:	0297c663          	blt	a5,s1,800002cc <consoleintr+0x4c>
    800002a4:	47a1                	li	a5,8
    800002a6:	0cf48f63          	beq	s1,a5,80000384 <consoleintr+0x104>
    800002aa:	47c1                	li	a5,16
    800002ac:	10f49063          	bne	s1,a5,800003ac <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002b0:	0b0020ef          	jal	ra,80002360 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b4:	0000f517          	auipc	a0,0xf
    800002b8:	68c50513          	addi	a0,a0,1676 # 8000f940 <cons>
    800002bc:	157000ef          	jal	ra,80000c12 <release>
}
    800002c0:	60e2                	ld	ra,24(sp)
    800002c2:	6442                	ld	s0,16(sp)
    800002c4:	64a2                	ld	s1,8(sp)
    800002c6:	6902                	ld	s2,0(sp)
    800002c8:	6105                	addi	sp,sp,32
    800002ca:	8082                	ret
  switch(c){
    800002cc:	07f00793          	li	a5,127
    800002d0:	0af48a63          	beq	s1,a5,80000384 <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002d4:	0000f717          	auipc	a4,0xf
    800002d8:	66c70713          	addi	a4,a4,1644 # 8000f940 <cons>
    800002dc:	0a072783          	lw	a5,160(a4)
    800002e0:	09872703          	lw	a4,152(a4)
    800002e4:	9f99                	subw	a5,a5,a4
    800002e6:	07f00713          	li	a4,127
    800002ea:	fcf765e3          	bltu	a4,a5,800002b4 <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002ee:	47b5                	li	a5,13
    800002f0:	0cf48163          	beq	s1,a5,800003b2 <consoleintr+0x132>
      consputc(c);
    800002f4:	8526                	mv	a0,s1
    800002f6:	f59ff0ef          	jal	ra,8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002fa:	0000f797          	auipc	a5,0xf
    800002fe:	64678793          	addi	a5,a5,1606 # 8000f940 <cons>
    80000302:	0a07a683          	lw	a3,160(a5)
    80000306:	0016871b          	addiw	a4,a3,1
    8000030a:	0007061b          	sext.w	a2,a4
    8000030e:	0ae7a023          	sw	a4,160(a5)
    80000312:	07f6f693          	andi	a3,a3,127
    80000316:	97b6                	add	a5,a5,a3
    80000318:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000031c:	47a9                	li	a5,10
    8000031e:	0af48f63          	beq	s1,a5,800003dc <consoleintr+0x15c>
    80000322:	4791                	li	a5,4
    80000324:	0af48c63          	beq	s1,a5,800003dc <consoleintr+0x15c>
    80000328:	0000f797          	auipc	a5,0xf
    8000032c:	6b07a783          	lw	a5,1712(a5) # 8000f9d8 <cons+0x98>
    80000330:	9f1d                	subw	a4,a4,a5
    80000332:	08000793          	li	a5,128
    80000336:	f6f71fe3          	bne	a4,a5,800002b4 <consoleintr+0x34>
    8000033a:	a04d                	j	800003dc <consoleintr+0x15c>
    while(cons.e != cons.w &&
    8000033c:	0000f717          	auipc	a4,0xf
    80000340:	60470713          	addi	a4,a4,1540 # 8000f940 <cons>
    80000344:	0a072783          	lw	a5,160(a4)
    80000348:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034c:	0000f497          	auipc	s1,0xf
    80000350:	5f448493          	addi	s1,s1,1524 # 8000f940 <cons>
    while(cons.e != cons.w &&
    80000354:	4929                	li	s2,10
    80000356:	f4f70fe3          	beq	a4,a5,800002b4 <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000035a:	37fd                	addiw	a5,a5,-1
    8000035c:	07f7f713          	andi	a4,a5,127
    80000360:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000362:	01874703          	lbu	a4,24(a4)
    80000366:	f52707e3          	beq	a4,s2,800002b4 <consoleintr+0x34>
      cons.e--;
    8000036a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000036e:	10000513          	li	a0,256
    80000372:	eddff0ef          	jal	ra,8000024e <consputc>
    while(cons.e != cons.w &&
    80000376:	0a04a783          	lw	a5,160(s1)
    8000037a:	09c4a703          	lw	a4,156(s1)
    8000037e:	fcf71ee3          	bne	a4,a5,8000035a <consoleintr+0xda>
    80000382:	bf0d                	j	800002b4 <consoleintr+0x34>
    if(cons.e != cons.w){
    80000384:	0000f717          	auipc	a4,0xf
    80000388:	5bc70713          	addi	a4,a4,1468 # 8000f940 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
    80000394:	f2f700e3          	beq	a4,a5,800002b4 <consoleintr+0x34>
      cons.e--;
    80000398:	37fd                	addiw	a5,a5,-1
    8000039a:	0000f717          	auipc	a4,0xf
    8000039e:	64f72323          	sw	a5,1606(a4) # 8000f9e0 <cons+0xa0>
      consputc(BACKSPACE);
    800003a2:	10000513          	li	a0,256
    800003a6:	ea9ff0ef          	jal	ra,8000024e <consputc>
    800003aa:	b729                	j	800002b4 <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003ac:	f00484e3          	beqz	s1,800002b4 <consoleintr+0x34>
    800003b0:	b715                	j	800002d4 <consoleintr+0x54>
      consputc(c);
    800003b2:	4529                	li	a0,10
    800003b4:	e9bff0ef          	jal	ra,8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b8:	0000f797          	auipc	a5,0xf
    800003bc:	58878793          	addi	a5,a5,1416 # 8000f940 <cons>
    800003c0:	0a07a703          	lw	a4,160(a5)
    800003c4:	0017069b          	addiw	a3,a4,1
    800003c8:	0006861b          	sext.w	a2,a3
    800003cc:	0ad7a023          	sw	a3,160(a5)
    800003d0:	07f77713          	andi	a4,a4,127
    800003d4:	97ba                	add	a5,a5,a4
    800003d6:	4729                	li	a4,10
    800003d8:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003dc:	0000f797          	auipc	a5,0xf
    800003e0:	60c7a023          	sw	a2,1536(a5) # 8000f9dc <cons+0x9c>
        wakeup(&cons.r);
    800003e4:	0000f517          	auipc	a0,0xf
    800003e8:	5f450513          	addi	a0,a0,1524 # 8000f9d8 <cons+0x98>
    800003ec:	391010ef          	jal	ra,80001f7c <wakeup>
    800003f0:	b5d1                	j	800002b4 <consoleintr+0x34>

00000000800003f2 <consoleinit>:

void
consoleinit(void)
{
    800003f2:	1141                	addi	sp,sp,-16
    800003f4:	e406                	sd	ra,8(sp)
    800003f6:	e022                	sd	s0,0(sp)
    800003f8:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003fa:	00007597          	auipc	a1,0x7
    800003fe:	c1658593          	addi	a1,a1,-1002 # 80007010 <etext+0x10>
    80000402:	0000f517          	auipc	a0,0xf
    80000406:	53e50513          	addi	a0,a0,1342 # 8000f940 <cons>
    8000040a:	6f0000ef          	jal	ra,80000afa <initlock>

  uartinit();
    8000040e:	3e2000ef          	jal	ra,800007f0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000412:	00020797          	auipc	a5,0x20
    80000416:	aae78793          	addi	a5,a5,-1362 # 8001fec0 <devsw>
    8000041a:	00000717          	auipc	a4,0x0
    8000041e:	d3270713          	addi	a4,a4,-718 # 8000014c <consoleread>
    80000422:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000424:	00000717          	auipc	a4,0x0
    80000428:	cac70713          	addi	a4,a4,-852 # 800000d0 <consolewrite>
    8000042c:	ef98                	sd	a4,24(a5)
}
    8000042e:	60a2                	ld	ra,8(sp)
    80000430:	6402                	ld	s0,0(sp)
    80000432:	0141                	addi	sp,sp,16
    80000434:	8082                	ret

0000000080000436 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000436:	7139                	addi	sp,sp,-64
    80000438:	fc06                	sd	ra,56(sp)
    8000043a:	f822                	sd	s0,48(sp)
    8000043c:	f426                	sd	s1,40(sp)
    8000043e:	f04a                	sd	s2,32(sp)
    80000440:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000442:	c219                	beqz	a2,80000448 <printint+0x12>
    80000444:	06054f63          	bltz	a0,800004c2 <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000448:	4881                	li	a7,0
    8000044a:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000044e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000450:	00007617          	auipc	a2,0x7
    80000454:	be860613          	addi	a2,a2,-1048 # 80007038 <digits>
    80000458:	883e                	mv	a6,a5
    8000045a:	2785                	addiw	a5,a5,1
    8000045c:	02b57733          	remu	a4,a0,a1
    80000460:	9732                	add	a4,a4,a2
    80000462:	00074703          	lbu	a4,0(a4)
    80000466:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000046a:	872a                	mv	a4,a0
    8000046c:	02b55533          	divu	a0,a0,a1
    80000470:	0685                	addi	a3,a3,1
    80000472:	feb773e3          	bgeu	a4,a1,80000458 <printint+0x22>

  if(sign)
    80000476:	00088b63          	beqz	a7,8000048c <printint+0x56>
    buf[i++] = '-';
    8000047a:	fe040713          	addi	a4,s0,-32
    8000047e:	97ba                	add	a5,a5,a4
    80000480:	02d00713          	li	a4,45
    80000484:	fee78423          	sb	a4,-24(a5)
    80000488:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000048c:	02f05563          	blez	a5,800004b6 <printint+0x80>
    80000490:	fc840713          	addi	a4,s0,-56
    80000494:	00f704b3          	add	s1,a4,a5
    80000498:	fff70913          	addi	s2,a4,-1
    8000049c:	993e                	add	s2,s2,a5
    8000049e:	37fd                	addiw	a5,a5,-1
    800004a0:	1782                	slli	a5,a5,0x20
    800004a2:	9381                	srli	a5,a5,0x20
    800004a4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a8:	fff4c503          	lbu	a0,-1(s1)
    800004ac:	da3ff0ef          	jal	ra,8000024e <consputc>
  while(--i >= 0)
    800004b0:	14fd                	addi	s1,s1,-1
    800004b2:	ff249be3          	bne	s1,s2,800004a8 <printint+0x72>
}
    800004b6:	70e2                	ld	ra,56(sp)
    800004b8:	7442                	ld	s0,48(sp)
    800004ba:	74a2                	ld	s1,40(sp)
    800004bc:	7902                	ld	s2,32(sp)
    800004be:	6121                	addi	sp,sp,64
    800004c0:	8082                	ret
    x = -xx;
    800004c2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004c6:	4885                	li	a7,1
    x = -xx;
    800004c8:	b749                	j	8000044a <printint+0x14>

00000000800004ca <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004ca:	7131                	addi	sp,sp,-192
    800004cc:	fc86                	sd	ra,120(sp)
    800004ce:	f8a2                	sd	s0,112(sp)
    800004d0:	f4a6                	sd	s1,104(sp)
    800004d2:	f0ca                	sd	s2,96(sp)
    800004d4:	ecce                	sd	s3,88(sp)
    800004d6:	e8d2                	sd	s4,80(sp)
    800004d8:	e4d6                	sd	s5,72(sp)
    800004da:	e0da                	sd	s6,64(sp)
    800004dc:	fc5e                	sd	s7,56(sp)
    800004de:	f862                	sd	s8,48(sp)
    800004e0:	f466                	sd	s9,40(sp)
    800004e2:	f06a                	sd	s10,32(sp)
    800004e4:	ec6e                	sd	s11,24(sp)
    800004e6:	0100                	addi	s0,sp,128
    800004e8:	8a2a                	mv	s4,a0
    800004ea:	e40c                	sd	a1,8(s0)
    800004ec:	e810                	sd	a2,16(s0)
    800004ee:	ec14                	sd	a3,24(s0)
    800004f0:	f018                	sd	a4,32(s0)
    800004f2:	f41c                	sd	a5,40(s0)
    800004f4:	03043823          	sd	a6,48(s0)
    800004f8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004fc:	00007797          	auipc	a5,0x7
    80000500:	4187a783          	lw	a5,1048(a5) # 80007914 <panicking>
    80000504:	cb9d                	beqz	a5,8000053a <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000506:	00840793          	addi	a5,s0,8
    8000050a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000050e:	000a4503          	lbu	a0,0(s4)
    80000512:	24050363          	beqz	a0,80000758 <printf+0x28e>
    80000516:	4981                	li	s3,0
    if(cx != '%'){
    80000518:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000051c:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000520:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000524:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000528:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000052c:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000530:	00007b97          	auipc	s7,0x7
    80000534:	b08b8b93          	addi	s7,s7,-1272 # 80007038 <digits>
    80000538:	a01d                	j	8000055e <printf+0x94>
    acquire(&pr.lock);
    8000053a:	0000f517          	auipc	a0,0xf
    8000053e:	4ae50513          	addi	a0,a0,1198 # 8000f9e8 <pr>
    80000542:	638000ef          	jal	ra,80000b7a <acquire>
    80000546:	b7c1                	j	80000506 <printf+0x3c>
      consputc(cx);
    80000548:	d07ff0ef          	jal	ra,8000024e <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050f63          	beqz	a0,80000758 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x7e>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090563          	beqz	s2,80000758 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xb8>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690863          	beq	s2,s6,800005b2 <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890263          	beq	s2,s8,800005ca <printf+0x100>
    } else if(c0 == 'u'){
    8000058a:	0d990163          	beq	s2,s9,8000064c <printf+0x182>
    } else if(c0 == 'x'){
    8000058e:	11a90863          	beq	s2,s10,8000069e <printf+0x1d4>
    } else if(c0 == 'p'){
    80000592:	15b90163          	beq	s2,s11,800006d4 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    80000596:	06300793          	li	a5,99
    8000059a:	16f90963          	beq	s2,a5,8000070c <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    8000059e:	07300793          	li	a5,115
    800005a2:	16f90f63          	beq	s2,a5,80000720 <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a6:	03591c63          	bne	s2,s5,800005de <printf+0x114>
      consputc('%');
    800005aa:	8556                	mv	a0,s5
    800005ac:	ca3ff0ef          	jal	ra,8000024e <consputc>
    800005b0:	bf79                	j	8000054e <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	45a9                	li	a1,10
    800005c2:	4388                	lw	a0,0(a5)
    800005c4:	e73ff0ef          	jal	ra,80000436 <printint>
    800005c8:	b759                	j	8000054e <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ca:	03678163          	beq	a5,s6,800005ec <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005ce:	03878d63          	beq	a5,s8,80000608 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d2:	09978a63          	beq	a5,s9,80000666 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005d6:	03878b63          	beq	a5,s8,8000060c <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005da:	0da78f63          	beq	a5,s10,800006b8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005de:	8556                	mv	a0,s5
    800005e0:	c6fff0ef          	jal	ra,8000024e <consputc>
      consputc(c0);
    800005e4:	854a                	mv	a0,s2
    800005e6:	c69ff0ef          	jal	ra,8000024e <consputc>
    800005ea:	b795                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005ec:	f8843783          	ld	a5,-120(s0)
    800005f0:	00878713          	addi	a4,a5,8
    800005f4:	f8e43423          	sd	a4,-120(s0)
    800005f8:	4605                	li	a2,1
    800005fa:	45a9                	li	a1,10
    800005fc:	6388                	ld	a0,0(a5)
    800005fe:	e39ff0ef          	jal	ra,80000436 <printint>
      i += 1;
    80000602:	0029849b          	addiw	s1,s3,2
    80000606:	b7a1                	j	8000054e <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000608:	03668463          	beq	a3,s6,80000630 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    8000060c:	07968b63          	beq	a3,s9,80000682 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000610:	fda697e3          	bne	a3,s10,800005de <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    80000614:	f8843783          	ld	a5,-120(s0)
    80000618:	00878713          	addi	a4,a5,8
    8000061c:	f8e43423          	sd	a4,-120(s0)
    80000620:	4601                	li	a2,0
    80000622:	45c1                	li	a1,16
    80000624:	6388                	ld	a0,0(a5)
    80000626:	e11ff0ef          	jal	ra,80000436 <printint>
      i += 2;
    8000062a:	0039849b          	addiw	s1,s3,3
    8000062e:	b705                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    80000630:	f8843783          	ld	a5,-120(s0)
    80000634:	00878713          	addi	a4,a5,8
    80000638:	f8e43423          	sd	a4,-120(s0)
    8000063c:	4605                	li	a2,1
    8000063e:	45a9                	li	a1,10
    80000640:	6388                	ld	a0,0(a5)
    80000642:	df5ff0ef          	jal	ra,80000436 <printint>
      i += 2;
    80000646:	0039849b          	addiw	s1,s3,3
    8000064a:	b711                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    8000064c:	f8843783          	ld	a5,-120(s0)
    80000650:	00878713          	addi	a4,a5,8
    80000654:	f8e43423          	sd	a4,-120(s0)
    80000658:	4601                	li	a2,0
    8000065a:	45a9                	li	a1,10
    8000065c:	0007e503          	lwu	a0,0(a5)
    80000660:	dd7ff0ef          	jal	ra,80000436 <printint>
    80000664:	b5ed                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000666:	f8843783          	ld	a5,-120(s0)
    8000066a:	00878713          	addi	a4,a5,8
    8000066e:	f8e43423          	sd	a4,-120(s0)
    80000672:	4601                	li	a2,0
    80000674:	45a9                	li	a1,10
    80000676:	6388                	ld	a0,0(a5)
    80000678:	dbfff0ef          	jal	ra,80000436 <printint>
      i += 1;
    8000067c:	0029849b          	addiw	s1,s3,2
    80000680:	b5f9                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4601                	li	a2,0
    80000690:	45a9                	li	a1,10
    80000692:	6388                	ld	a0,0(a5)
    80000694:	da3ff0ef          	jal	ra,80000436 <printint>
      i += 2;
    80000698:	0039849b          	addiw	s1,s3,3
    8000069c:	bd4d                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	4601                	li	a2,0
    800006ac:	45c1                	li	a1,16
    800006ae:	0007e503          	lwu	a0,0(a5)
    800006b2:	d85ff0ef          	jal	ra,80000436 <printint>
    800006b6:	bd61                	j	8000054e <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b8:	f8843783          	ld	a5,-120(s0)
    800006bc:	00878713          	addi	a4,a5,8
    800006c0:	f8e43423          	sd	a4,-120(s0)
    800006c4:	4601                	li	a2,0
    800006c6:	45c1                	li	a1,16
    800006c8:	6388                	ld	a0,0(a5)
    800006ca:	d6dff0ef          	jal	ra,80000436 <printint>
      i += 1;
    800006ce:	0029849b          	addiw	s1,s3,2
    800006d2:	bdb5                	j	8000054e <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006d4:	f8843783          	ld	a5,-120(s0)
    800006d8:	00878713          	addi	a4,a5,8
    800006dc:	f8e43423          	sd	a4,-120(s0)
    800006e0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e4:	03000513          	li	a0,48
    800006e8:	b67ff0ef          	jal	ra,8000024e <consputc>
  consputc('x');
    800006ec:	856a                	mv	a0,s10
    800006ee:	b61ff0ef          	jal	ra,8000024e <consputc>
    800006f2:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b51ff0ef          	jal	ra,8000024e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x22a>
    8000070a:	b591                	j	8000054e <printf+0x84>
      consputc(va_arg(ap, uint));
    8000070c:	f8843783          	ld	a5,-120(s0)
    80000710:	00878713          	addi	a4,a5,8
    80000714:	f8e43423          	sd	a4,-120(s0)
    80000718:	4388                	lw	a0,0(a5)
    8000071a:	b35ff0ef          	jal	ra,8000024e <consputc>
    8000071e:	bd05                	j	8000054e <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    80000720:	f8843783          	ld	a5,-120(s0)
    80000724:	00878713          	addi	a4,a5,8
    80000728:	f8e43423          	sd	a4,-120(s0)
    8000072c:	0007b903          	ld	s2,0(a5)
    80000730:	00090d63          	beqz	s2,8000074a <printf+0x280>
      for(; *s; s++)
    80000734:	00094503          	lbu	a0,0(s2)
    80000738:	e0050be3          	beqz	a0,8000054e <printf+0x84>
        consputc(*s);
    8000073c:	b13ff0ef          	jal	ra,8000024e <consputc>
      for(; *s; s++)
    80000740:	0905                	addi	s2,s2,1
    80000742:	00094503          	lbu	a0,0(s2)
    80000746:	f97d                	bnez	a0,8000073c <printf+0x272>
    80000748:	b519                	j	8000054e <printf+0x84>
        s = "(null)";
    8000074a:	00007917          	auipc	s2,0x7
    8000074e:	8ce90913          	addi	s2,s2,-1842 # 80007018 <etext+0x18>
      for(; *s; s++)
    80000752:	02800513          	li	a0,40
    80000756:	b7dd                	j	8000073c <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000758:	00007797          	auipc	a5,0x7
    8000075c:	1bc7a783          	lw	a5,444(a5) # 80007914 <panicking>
    80000760:	c38d                	beqz	a5,80000782 <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    80000762:	4501                	li	a0,0
    80000764:	70e6                	ld	ra,120(sp)
    80000766:	7446                	ld	s0,112(sp)
    80000768:	74a6                	ld	s1,104(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	69e6                	ld	s3,88(sp)
    8000076e:	6a46                	ld	s4,80(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	7d02                	ld	s10,32(sp)
    8000077c:	6de2                	ld	s11,24(sp)
    8000077e:	6129                	addi	sp,sp,192
    80000780:	8082                	ret
    release(&pr.lock);
    80000782:	0000f517          	auipc	a0,0xf
    80000786:	26650513          	addi	a0,a0,614 # 8000f9e8 <pr>
    8000078a:	488000ef          	jal	ra,80000c12 <release>
  return 0;
    8000078e:	bfd1                	j	80000762 <printf+0x298>

0000000080000790 <panic>:

void
panic(char *s)
{
    80000790:	1101                	addi	sp,sp,-32
    80000792:	ec06                	sd	ra,24(sp)
    80000794:	e822                	sd	s0,16(sp)
    80000796:	e426                	sd	s1,8(sp)
    80000798:	e04a                	sd	s2,0(sp)
    8000079a:	1000                	addi	s0,sp,32
    8000079c:	892a                	mv	s2,a0
  panicking = 1;
    8000079e:	4485                	li	s1,1
    800007a0:	00007797          	auipc	a5,0x7
    800007a4:	1697aa23          	sw	s1,372(a5) # 80007914 <panicking>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87850513          	addi	a0,a0,-1928 # 80007020 <etext+0x20>
    800007b0:	d1bff0ef          	jal	ra,800004ca <printf>
  printf("%s\n", s);
    800007b4:	85ca                	mv	a1,s2
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	87250513          	addi	a0,a0,-1934 # 80007028 <etext+0x28>
    800007be:	d0dff0ef          	jal	ra,800004ca <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	00007797          	auipc	a5,0x7
    800007c6:	1497a723          	sw	s1,334(a5) # 80007910 <panicked>
  for(;;)
    800007ca:	a001                	j	800007ca <panic+0x3a>

00000000800007cc <printfinit>:
    ;
}

void
printfinit(void)
{
    800007cc:	1141                	addi	sp,sp,-16
    800007ce:	e406                	sd	ra,8(sp)
    800007d0:	e022                	sd	s0,0(sp)
    800007d2:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007d4:	00007597          	auipc	a1,0x7
    800007d8:	85c58593          	addi	a1,a1,-1956 # 80007030 <etext+0x30>
    800007dc:	0000f517          	auipc	a0,0xf
    800007e0:	20c50513          	addi	a0,a0,524 # 8000f9e8 <pr>
    800007e4:	316000ef          	jal	ra,80000afa <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007f0:	1141                	addi	sp,sp,-16
    800007f2:	e406                	sd	ra,8(sp)
    800007f4:	e022                	sd	s0,0(sp)
    800007f6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f8:	100007b7          	lui	a5,0x10000
    800007fc:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000800:	f8000713          	li	a4,-128
    80000804:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000808:	470d                	li	a4,3
    8000080a:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080e:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000812:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000816:	469d                	li	a3,7
    80000818:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    80000820:	00007597          	auipc	a1,0x7
    80000824:	83058593          	addi	a1,a1,-2000 # 80007050 <digits+0x18>
    80000828:	0000f517          	auipc	a0,0xf
    8000082c:	1d850513          	addi	a0,a0,472 # 8000fa00 <tx_lock>
    80000830:	2ca000ef          	jal	ra,80000afa <initlock>
}
    80000834:	60a2                	ld	ra,8(sp)
    80000836:	6402                	ld	s0,0(sp)
    80000838:	0141                	addi	sp,sp,16
    8000083a:	8082                	ret

000000008000083c <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    8000083c:	715d                	addi	sp,sp,-80
    8000083e:	e486                	sd	ra,72(sp)
    80000840:	e0a2                	sd	s0,64(sp)
    80000842:	fc26                	sd	s1,56(sp)
    80000844:	f84a                	sd	s2,48(sp)
    80000846:	f44e                	sd	s3,40(sp)
    80000848:	f052                	sd	s4,32(sp)
    8000084a:	ec56                	sd	s5,24(sp)
    8000084c:	e85a                	sd	s6,16(sp)
    8000084e:	e45e                	sd	s7,8(sp)
    80000850:	0880                	addi	s0,sp,80
    80000852:	84aa                	mv	s1,a0
    80000854:	8aae                	mv	s5,a1
  acquire(&tx_lock);
    80000856:	0000f517          	auipc	a0,0xf
    8000085a:	1aa50513          	addi	a0,a0,426 # 8000fa00 <tx_lock>
    8000085e:	31c000ef          	jal	ra,80000b7a <acquire>

  int i = 0;
  while(i < n){ 
    80000862:	05505b63          	blez	s5,800008b8 <uartwrite+0x7c>
    80000866:	8a26                	mv	s4,s1
    80000868:	0485                	addi	s1,s1,1
    8000086a:	3afd                	addiw	s5,s5,-1
    8000086c:	1a82                	slli	s5,s5,0x20
    8000086e:	020ada93          	srli	s5,s5,0x20
    80000872:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000874:	00007497          	auipc	s1,0x7
    80000878:	0a848493          	addi	s1,s1,168 # 8000791c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    8000087c:	0000f997          	auipc	s3,0xf
    80000880:	18498993          	addi	s3,s3,388 # 8000fa00 <tx_lock>
    80000884:	00007917          	auipc	s2,0x7
    80000888:	09490913          	addi	s2,s2,148 # 80007918 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    8000088c:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000890:	4b05                	li	s6,1
    80000892:	a005                	j	800008b2 <uartwrite+0x76>
      sleep(&tx_chan, &tx_lock);
    80000894:	85ce                	mv	a1,s3
    80000896:	854a                	mv	a0,s2
    80000898:	698010ef          	jal	ra,80001f30 <sleep>
    while(tx_busy != 0){
    8000089c:	409c                	lw	a5,0(s1)
    8000089e:	fbfd                	bnez	a5,80000894 <uartwrite+0x58>
    WriteReg(THR, buf[i]);
    800008a0:	000a4783          	lbu	a5,0(s4)
    800008a4:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a8:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008ac:	0a05                	addi	s4,s4,1
    800008ae:	015a0563          	beq	s4,s5,800008b8 <uartwrite+0x7c>
    while(tx_busy != 0){
    800008b2:	409c                	lw	a5,0(s1)
    800008b4:	f3e5                	bnez	a5,80000894 <uartwrite+0x58>
    800008b6:	b7ed                	j	800008a0 <uartwrite+0x64>
  }

  release(&tx_lock);
    800008b8:	0000f517          	auipc	a0,0xf
    800008bc:	14850513          	addi	a0,a0,328 # 8000fa00 <tx_lock>
    800008c0:	352000ef          	jal	ra,80000c12 <release>
}
    800008c4:	60a6                	ld	ra,72(sp)
    800008c6:	6406                	ld	s0,64(sp)
    800008c8:	74e2                	ld	s1,56(sp)
    800008ca:	7942                	ld	s2,48(sp)
    800008cc:	79a2                	ld	s3,40(sp)
    800008ce:	7a02                	ld	s4,32(sp)
    800008d0:	6ae2                	ld	s5,24(sp)
    800008d2:	6b42                	ld	s6,16(sp)
    800008d4:	6ba2                	ld	s7,8(sp)
    800008d6:	6161                	addi	sp,sp,80
    800008d8:	8082                	ret

00000000800008da <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008da:	1101                	addi	sp,sp,-32
    800008dc:	ec06                	sd	ra,24(sp)
    800008de:	e822                	sd	s0,16(sp)
    800008e0:	e426                	sd	s1,8(sp)
    800008e2:	1000                	addi	s0,sp,32
    800008e4:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e6:	00007797          	auipc	a5,0x7
    800008ea:	02e7a783          	lw	a5,46(a5) # 80007914 <panicking>
    800008ee:	cb89                	beqz	a5,80000900 <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008f0:	00007797          	auipc	a5,0x7
    800008f4:	0207a783          	lw	a5,32(a5) # 80007910 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f8:	10000737          	lui	a4,0x10000
  if(panicked){
    800008fc:	c789                	beqz	a5,80000906 <uartputc_sync+0x2c>
    for(;;)
    800008fe:	a001                	j	800008fe <uartputc_sync+0x24>
    push_off();
    80000900:	23a000ef          	jal	ra,80000b3a <push_off>
    80000904:	b7f5                	j	800008f0 <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000906:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000090a:	0ff7f793          	andi	a5,a5,255
    8000090e:	0207f793          	andi	a5,a5,32
    80000912:	dbf5                	beqz	a5,80000906 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    80000914:	0ff4f793          	andi	a5,s1,255
    80000918:	10000737          	lui	a4,0x10000
    8000091c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000920:	00007797          	auipc	a5,0x7
    80000924:	ff47a783          	lw	a5,-12(a5) # 80007914 <panicking>
    80000928:	c791                	beqz	a5,80000934 <uartputc_sync+0x5a>
    pop_off();
}
    8000092a:	60e2                	ld	ra,24(sp)
    8000092c:	6442                	ld	s0,16(sp)
    8000092e:	64a2                	ld	s1,8(sp)
    80000930:	6105                	addi	sp,sp,32
    80000932:	8082                	ret
    pop_off();
    80000934:	28a000ef          	jal	ra,80000bbe <pop_off>
}
    80000938:	bfcd                	j	8000092a <uartputc_sync+0x50>

000000008000093a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000093a:	1141                	addi	sp,sp,-16
    8000093c:	e422                	sd	s0,8(sp)
    8000093e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000940:	100007b7          	lui	a5,0x10000
    80000944:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000948:	8b85                	andi	a5,a5,1
    8000094a:	cb91                	beqz	a5,8000095e <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000094c:	100007b7          	lui	a5,0x10000
    80000950:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000954:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000958:	6422                	ld	s0,8(sp)
    8000095a:	0141                	addi	sp,sp,16
    8000095c:	8082                	ret
    return -1;
    8000095e:	557d                	li	a0,-1
    80000960:	bfe5                	j	80000958 <uartgetc+0x1e>

0000000080000962 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000962:	1101                	addi	sp,sp,-32
    80000964:	ec06                	sd	ra,24(sp)
    80000966:	e822                	sd	s0,16(sp)
    80000968:	e426                	sd	s1,8(sp)
    8000096a:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    8000096c:	100004b7          	lui	s1,0x10000
    80000970:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000974:	0000f517          	auipc	a0,0xf
    80000978:	08c50513          	addi	a0,a0,140 # 8000fa00 <tx_lock>
    8000097c:	1fe000ef          	jal	ra,80000b7a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000980:	0054c783          	lbu	a5,5(s1)
    80000984:	0ff7f793          	andi	a5,a5,255
    80000988:	0207f793          	andi	a5,a5,32
    8000098c:	ef99                	bnez	a5,800009aa <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    8000098e:	0000f517          	auipc	a0,0xf
    80000992:	07250513          	addi	a0,a0,114 # 8000fa00 <tx_lock>
    80000996:	27c000ef          	jal	ra,80000c12 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099a:	54fd                	li	s1,-1
    int c = uartgetc();
    8000099c:	f9fff0ef          	jal	ra,8000093a <uartgetc>
    if(c == -1)
    800009a0:	02950063          	beq	a0,s1,800009c0 <uartintr+0x5e>
      break;
    consoleintr(c);
    800009a4:	8ddff0ef          	jal	ra,80000280 <consoleintr>
  while(1){
    800009a8:	bfd5                	j	8000099c <uartintr+0x3a>
    tx_busy = 0;
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	f607a923          	sw	zero,-142(a5) # 8000791c <tx_busy>
    wakeup(&tx_chan);
    800009b2:	00007517          	auipc	a0,0x7
    800009b6:	f6650513          	addi	a0,a0,-154 # 80007918 <tx_chan>
    800009ba:	5c2010ef          	jal	ra,80001f7c <wakeup>
    800009be:	bfc1                	j	8000098e <uartintr+0x2c>
  }
}
    800009c0:	60e2                	ld	ra,24(sp)
    800009c2:	6442                	ld	s0,16(sp)
    800009c4:	64a2                	ld	s1,8(sp)
    800009c6:	6105                	addi	sp,sp,32
    800009c8:	8082                	ret

00000000800009ca <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ca:	1101                	addi	sp,sp,-32
    800009cc:	ec06                	sd	ra,24(sp)
    800009ce:	e822                	sd	s0,16(sp)
    800009d0:	e426                	sd	s1,8(sp)
    800009d2:	e04a                	sd	s2,0(sp)
    800009d4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009d6:	03451793          	slli	a5,a0,0x34
    800009da:	e7a9                	bnez	a5,80000a24 <kfree+0x5a>
    800009dc:	84aa                	mv	s1,a0
    800009de:	00020797          	auipc	a5,0x20
    800009e2:	67a78793          	addi	a5,a5,1658 # 80021058 <end>
    800009e6:	02f56f63          	bltu	a0,a5,80000a24 <kfree+0x5a>
    800009ea:	47c5                	li	a5,17
    800009ec:	07ee                	slli	a5,a5,0x1b
    800009ee:	02f57b63          	bgeu	a0,a5,80000a24 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009f2:	6605                	lui	a2,0x1
    800009f4:	4585                	li	a1,1
    800009f6:	258000ef          	jal	ra,80000c4e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009fa:	0000f917          	auipc	s2,0xf
    800009fe:	01e90913          	addi	s2,s2,30 # 8000fa18 <kmem>
    80000a02:	854a                	mv	a0,s2
    80000a04:	176000ef          	jal	ra,80000b7a <acquire>
  r->next = kmem.freelist;
    80000a08:	01893783          	ld	a5,24(s2)
    80000a0c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a0e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a12:	854a                	mv	a0,s2
    80000a14:	1fe000ef          	jal	ra,80000c12 <release>
}
    80000a18:	60e2                	ld	ra,24(sp)
    80000a1a:	6442                	ld	s0,16(sp)
    80000a1c:	64a2                	ld	s1,8(sp)
    80000a1e:	6902                	ld	s2,0(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret
    panic("kfree");
    80000a24:	00006517          	auipc	a0,0x6
    80000a28:	63450513          	addi	a0,a0,1588 # 80007058 <digits+0x20>
    80000a2c:	d65ff0ef          	jal	ra,80000790 <panic>

0000000080000a30 <freerange>:
{
    80000a30:	7179                	addi	sp,sp,-48
    80000a32:	f406                	sd	ra,40(sp)
    80000a34:	f022                	sd	s0,32(sp)
    80000a36:	ec26                	sd	s1,24(sp)
    80000a38:	e84a                	sd	s2,16(sp)
    80000a3a:	e44e                	sd	s3,8(sp)
    80000a3c:	e052                	sd	s4,0(sp)
    80000a3e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a40:	6785                	lui	a5,0x1
    80000a42:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a46:	94aa                	add	s1,s1,a0
    80000a48:	757d                	lui	a0,0xfffff
    80000a4a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a4c:	94be                	add	s1,s1,a5
    80000a4e:	0095ec63          	bltu	a1,s1,80000a66 <freerange+0x36>
    80000a52:	892e                	mv	s2,a1
    kfree(p);
    80000a54:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a56:	6985                	lui	s3,0x1
    kfree(p);
    80000a58:	01448533          	add	a0,s1,s4
    80000a5c:	f6fff0ef          	jal	ra,800009ca <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a60:	94ce                	add	s1,s1,s3
    80000a62:	fe997be3          	bgeu	s2,s1,80000a58 <freerange+0x28>
}
    80000a66:	70a2                	ld	ra,40(sp)
    80000a68:	7402                	ld	s0,32(sp)
    80000a6a:	64e2                	ld	s1,24(sp)
    80000a6c:	6942                	ld	s2,16(sp)
    80000a6e:	69a2                	ld	s3,8(sp)
    80000a70:	6a02                	ld	s4,0(sp)
    80000a72:	6145                	addi	sp,sp,48
    80000a74:	8082                	ret

0000000080000a76 <kinit>:
{
    80000a76:	1141                	addi	sp,sp,-16
    80000a78:	e406                	sd	ra,8(sp)
    80000a7a:	e022                	sd	s0,0(sp)
    80000a7c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a7e:	00006597          	auipc	a1,0x6
    80000a82:	5e258593          	addi	a1,a1,1506 # 80007060 <digits+0x28>
    80000a86:	0000f517          	auipc	a0,0xf
    80000a8a:	f9250513          	addi	a0,a0,-110 # 8000fa18 <kmem>
    80000a8e:	06c000ef          	jal	ra,80000afa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a92:	45c5                	li	a1,17
    80000a94:	05ee                	slli	a1,a1,0x1b
    80000a96:	00020517          	auipc	a0,0x20
    80000a9a:	5c250513          	addi	a0,a0,1474 # 80021058 <end>
    80000a9e:	f93ff0ef          	jal	ra,80000a30 <freerange>
}
    80000aa2:	60a2                	ld	ra,8(sp)
    80000aa4:	6402                	ld	s0,0(sp)
    80000aa6:	0141                	addi	sp,sp,16
    80000aa8:	8082                	ret

0000000080000aaa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aaa:	1101                	addi	sp,sp,-32
    80000aac:	ec06                	sd	ra,24(sp)
    80000aae:	e822                	sd	s0,16(sp)
    80000ab0:	e426                	sd	s1,8(sp)
    80000ab2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ab4:	0000f497          	auipc	s1,0xf
    80000ab8:	f6448493          	addi	s1,s1,-156 # 8000fa18 <kmem>
    80000abc:	8526                	mv	a0,s1
    80000abe:	0bc000ef          	jal	ra,80000b7a <acquire>
  r = kmem.freelist;
    80000ac2:	6c84                	ld	s1,24(s1)
  if(r)
    80000ac4:	c485                	beqz	s1,80000aec <kalloc+0x42>
    kmem.freelist = r->next;
    80000ac6:	609c                	ld	a5,0(s1)
    80000ac8:	0000f517          	auipc	a0,0xf
    80000acc:	f5050513          	addi	a0,a0,-176 # 8000fa18 <kmem>
    80000ad0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ad2:	140000ef          	jal	ra,80000c12 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ad6:	6605                	lui	a2,0x1
    80000ad8:	4595                	li	a1,5
    80000ada:	8526                	mv	a0,s1
    80000adc:	172000ef          	jal	ra,80000c4e <memset>
  return (void*)r;
}
    80000ae0:	8526                	mv	a0,s1
    80000ae2:	60e2                	ld	ra,24(sp)
    80000ae4:	6442                	ld	s0,16(sp)
    80000ae6:	64a2                	ld	s1,8(sp)
    80000ae8:	6105                	addi	sp,sp,32
    80000aea:	8082                	ret
  release(&kmem.lock);
    80000aec:	0000f517          	auipc	a0,0xf
    80000af0:	f2c50513          	addi	a0,a0,-212 # 8000fa18 <kmem>
    80000af4:	11e000ef          	jal	ra,80000c12 <release>
  if(r)
    80000af8:	b7e5                	j	80000ae0 <kalloc+0x36>

0000000080000afa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000afa:	1141                	addi	sp,sp,-16
    80000afc:	e422                	sd	s0,8(sp)
    80000afe:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b00:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b02:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b06:	00053823          	sd	zero,16(a0)
}
    80000b0a:	6422                	ld	s0,8(sp)
    80000b0c:	0141                	addi	sp,sp,16
    80000b0e:	8082                	ret

0000000080000b10 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b10:	411c                	lw	a5,0(a0)
    80000b12:	e399                	bnez	a5,80000b18 <holding+0x8>
    80000b14:	4501                	li	a0,0
  return r;
}
    80000b16:	8082                	ret
{
    80000b18:	1101                	addi	sp,sp,-32
    80000b1a:	ec06                	sd	ra,24(sp)
    80000b1c:	e822                	sd	s0,16(sp)
    80000b1e:	e426                	sd	s1,8(sp)
    80000b20:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b22:	6904                	ld	s1,16(a0)
    80000b24:	4db000ef          	jal	ra,800017fe <mycpu>
    80000b28:	40a48533          	sub	a0,s1,a0
    80000b2c:	00153513          	seqz	a0,a0
}
    80000b30:	60e2                	ld	ra,24(sp)
    80000b32:	6442                	ld	s0,16(sp)
    80000b34:	64a2                	ld	s1,8(sp)
    80000b36:	6105                	addi	sp,sp,32
    80000b38:	8082                	ret

0000000080000b3a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b3a:	1101                	addi	sp,sp,-32
    80000b3c:	ec06                	sd	ra,24(sp)
    80000b3e:	e822                	sd	s0,16(sp)
    80000b40:	e426                	sd	s1,8(sp)
    80000b42:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b44:	100024f3          	csrr	s1,sstatus
    80000b48:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b4c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b4e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b52:	4ad000ef          	jal	ra,800017fe <mycpu>
    80000b56:	5d3c                	lw	a5,120(a0)
    80000b58:	cb99                	beqz	a5,80000b6e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b5a:	4a5000ef          	jal	ra,800017fe <mycpu>
    80000b5e:	5d3c                	lw	a5,120(a0)
    80000b60:	2785                	addiw	a5,a5,1
    80000b62:	dd3c                	sw	a5,120(a0)
}
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
    mycpu()->intena = old;
    80000b6e:	491000ef          	jal	ra,800017fe <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b72:	8085                	srli	s1,s1,0x1
    80000b74:	8885                	andi	s1,s1,1
    80000b76:	dd64                	sw	s1,124(a0)
    80000b78:	b7cd                	j	80000b5a <push_off+0x20>

0000000080000b7a <acquire>:
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
    80000b84:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b86:	fb5ff0ef          	jal	ra,80000b3a <push_off>
  if(holding(lk))
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	f85ff0ef          	jal	ra,80000b10 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b90:	4705                	li	a4,1
  if(holding(lk))
    80000b92:	e105                	bnez	a0,80000bb2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b94:	87ba                	mv	a5,a4
    80000b96:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b9a:	2781                	sext.w	a5,a5
    80000b9c:	ffe5                	bnez	a5,80000b94 <acquire+0x1a>
  __sync_synchronize();
    80000b9e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ba2:	45d000ef          	jal	ra,800017fe <mycpu>
    80000ba6:	e888                	sd	a0,16(s1)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    panic("acquire");
    80000bb2:	00006517          	auipc	a0,0x6
    80000bb6:	4b650513          	addi	a0,a0,1206 # 80007068 <digits+0x30>
    80000bba:	bd7ff0ef          	jal	ra,80000790 <panic>

0000000080000bbe <pop_off>:

void
pop_off(void)
{
    80000bbe:	1141                	addi	sp,sp,-16
    80000bc0:	e406                	sd	ra,8(sp)
    80000bc2:	e022                	sd	s0,0(sp)
    80000bc4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bc6:	439000ef          	jal	ra,800017fe <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bd0:	e78d                	bnez	a5,80000bfa <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bd2:	5d3c                	lw	a5,120(a0)
    80000bd4:	02f05963          	blez	a5,80000c06 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bd8:	37fd                	addiw	a5,a5,-1
    80000bda:	0007871b          	sext.w	a4,a5
    80000bde:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000be0:	eb09                	bnez	a4,80000bf2 <pop_off+0x34>
    80000be2:	5d7c                	lw	a5,124(a0)
    80000be4:	c799                	beqz	a5,80000bf2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000be6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bee:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000bf2:	60a2                	ld	ra,8(sp)
    80000bf4:	6402                	ld	s0,0(sp)
    80000bf6:	0141                	addi	sp,sp,16
    80000bf8:	8082                	ret
    panic("pop_off - interruptible");
    80000bfa:	00006517          	auipc	a0,0x6
    80000bfe:	47650513          	addi	a0,a0,1142 # 80007070 <digits+0x38>
    80000c02:	b8fff0ef          	jal	ra,80000790 <panic>
    panic("pop_off");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	48250513          	addi	a0,a0,1154 # 80007088 <digits+0x50>
    80000c0e:	b83ff0ef          	jal	ra,80000790 <panic>

0000000080000c12 <release>:
{
    80000c12:	1101                	addi	sp,sp,-32
    80000c14:	ec06                	sd	ra,24(sp)
    80000c16:	e822                	sd	s0,16(sp)
    80000c18:	e426                	sd	s1,8(sp)
    80000c1a:	1000                	addi	s0,sp,32
    80000c1c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c1e:	ef3ff0ef          	jal	ra,80000b10 <holding>
    80000c22:	c105                	beqz	a0,80000c42 <release+0x30>
  lk->cpu = 0;
    80000c24:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c28:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c2c:	0f50000f          	fence	iorw,ow
    80000c30:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c34:	f8bff0ef          	jal	ra,80000bbe <pop_off>
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    panic("release");
    80000c42:	00006517          	auipc	a0,0x6
    80000c46:	44e50513          	addi	a0,a0,1102 # 80007090 <digits+0x58>
    80000c4a:	b47ff0ef          	jal	ra,80000790 <panic>

0000000080000c4e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c4e:	1141                	addi	sp,sp,-16
    80000c50:	e422                	sd	s0,8(sp)
    80000c52:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c54:	ce09                	beqz	a2,80000c6e <memset+0x20>
    80000c56:	87aa                	mv	a5,a0
    80000c58:	fff6071b          	addiw	a4,a2,-1
    80000c5c:	1702                	slli	a4,a4,0x20
    80000c5e:	9301                	srli	a4,a4,0x20
    80000c60:	0705                	addi	a4,a4,1
    80000c62:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000c64:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c68:	0785                	addi	a5,a5,1
    80000c6a:	fee79de3          	bne	a5,a4,80000c64 <memset+0x16>
  }
  return dst;
}
    80000c6e:	6422                	ld	s0,8(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret

0000000080000c74 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c74:	1141                	addi	sp,sp,-16
    80000c76:	e422                	sd	s0,8(sp)
    80000c78:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c7a:	ca05                	beqz	a2,80000caa <memcmp+0x36>
    80000c7c:	fff6069b          	addiw	a3,a2,-1
    80000c80:	1682                	slli	a3,a3,0x20
    80000c82:	9281                	srli	a3,a3,0x20
    80000c84:	0685                	addi	a3,a3,1
    80000c86:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c88:	00054783          	lbu	a5,0(a0)
    80000c8c:	0005c703          	lbu	a4,0(a1)
    80000c90:	00e79863          	bne	a5,a4,80000ca0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c94:	0505                	addi	a0,a0,1
    80000c96:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c98:	fed518e3          	bne	a0,a3,80000c88 <memcmp+0x14>
  }

  return 0;
    80000c9c:	4501                	li	a0,0
    80000c9e:	a019                	j	80000ca4 <memcmp+0x30>
      return *s1 - *s2;
    80000ca0:	40e7853b          	subw	a0,a5,a4
}
    80000ca4:	6422                	ld	s0,8(sp)
    80000ca6:	0141                	addi	sp,sp,16
    80000ca8:	8082                	ret
  return 0;
    80000caa:	4501                	li	a0,0
    80000cac:	bfe5                	j	80000ca4 <memcmp+0x30>

0000000080000cae <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cae:	1141                	addi	sp,sp,-16
    80000cb0:	e422                	sd	s0,8(sp)
    80000cb2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000cb4:	ca0d                	beqz	a2,80000ce6 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000cb6:	00a5f963          	bgeu	a1,a0,80000cc8 <memmove+0x1a>
    80000cba:	02061693          	slli	a3,a2,0x20
    80000cbe:	9281                	srli	a3,a3,0x20
    80000cc0:	00d58733          	add	a4,a1,a3
    80000cc4:	02e56463          	bltu	a0,a4,80000cec <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000cc8:	fff6079b          	addiw	a5,a2,-1
    80000ccc:	1782                	slli	a5,a5,0x20
    80000cce:	9381                	srli	a5,a5,0x20
    80000cd0:	0785                	addi	a5,a5,1
    80000cd2:	97ae                	add	a5,a5,a1
    80000cd4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cd6:	0585                	addi	a1,a1,1
    80000cd8:	0705                	addi	a4,a4,1
    80000cda:	fff5c683          	lbu	a3,-1(a1)
    80000cde:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000ce2:	fef59ae3          	bne	a1,a5,80000cd6 <memmove+0x28>

  return dst;
}
    80000ce6:	6422                	ld	s0,8(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret
    d += n;
    80000cec:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cee:	fff6079b          	addiw	a5,a2,-1
    80000cf2:	1782                	slli	a5,a5,0x20
    80000cf4:	9381                	srli	a5,a5,0x20
    80000cf6:	fff7c793          	not	a5,a5
    80000cfa:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cfc:	177d                	addi	a4,a4,-1
    80000cfe:	16fd                	addi	a3,a3,-1
    80000d00:	00074603          	lbu	a2,0(a4)
    80000d04:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d08:	fef71ae3          	bne	a4,a5,80000cfc <memmove+0x4e>
    80000d0c:	bfe9                	j	80000ce6 <memmove+0x38>

0000000080000d0e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d0e:	1141                	addi	sp,sp,-16
    80000d10:	e406                	sd	ra,8(sp)
    80000d12:	e022                	sd	s0,0(sp)
    80000d14:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d16:	f99ff0ef          	jal	ra,80000cae <memmove>
}
    80000d1a:	60a2                	ld	ra,8(sp)
    80000d1c:	6402                	ld	s0,0(sp)
    80000d1e:	0141                	addi	sp,sp,16
    80000d20:	8082                	ret

0000000080000d22 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d22:	1141                	addi	sp,sp,-16
    80000d24:	e422                	sd	s0,8(sp)
    80000d26:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d28:	ce11                	beqz	a2,80000d44 <strncmp+0x22>
    80000d2a:	00054783          	lbu	a5,0(a0)
    80000d2e:	cf89                	beqz	a5,80000d48 <strncmp+0x26>
    80000d30:	0005c703          	lbu	a4,0(a1)
    80000d34:	00f71a63          	bne	a4,a5,80000d48 <strncmp+0x26>
    n--, p++, q++;
    80000d38:	367d                	addiw	a2,a2,-1
    80000d3a:	0505                	addi	a0,a0,1
    80000d3c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d3e:	f675                	bnez	a2,80000d2a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d40:	4501                	li	a0,0
    80000d42:	a809                	j	80000d54 <strncmp+0x32>
    80000d44:	4501                	li	a0,0
    80000d46:	a039                	j	80000d54 <strncmp+0x32>
  if(n == 0)
    80000d48:	ca09                	beqz	a2,80000d5a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d4a:	00054503          	lbu	a0,0(a0)
    80000d4e:	0005c783          	lbu	a5,0(a1)
    80000d52:	9d1d                	subw	a0,a0,a5
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
    return 0;
    80000d5a:	4501                	li	a0,0
    80000d5c:	bfe5                	j	80000d54 <strncmp+0x32>

0000000080000d5e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e422                	sd	s0,8(sp)
    80000d62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d64:	872a                	mv	a4,a0
    80000d66:	8832                	mv	a6,a2
    80000d68:	367d                	addiw	a2,a2,-1
    80000d6a:	01005963          	blez	a6,80000d7c <strncpy+0x1e>
    80000d6e:	0705                	addi	a4,a4,1
    80000d70:	0005c783          	lbu	a5,0(a1)
    80000d74:	fef70fa3          	sb	a5,-1(a4)
    80000d78:	0585                	addi	a1,a1,1
    80000d7a:	f7f5                	bnez	a5,80000d66 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d7c:	00c05d63          	blez	a2,80000d96 <strncpy+0x38>
    80000d80:	86ba                	mv	a3,a4
    *s++ = 0;
    80000d82:	0685                	addi	a3,a3,1
    80000d84:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d88:	fff6c793          	not	a5,a3
    80000d8c:	9fb9                	addw	a5,a5,a4
    80000d8e:	010787bb          	addw	a5,a5,a6
    80000d92:	fef048e3          	bgtz	a5,80000d82 <strncpy+0x24>
  return os;
}
    80000d96:	6422                	ld	s0,8(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000da2:	02c05363          	blez	a2,80000dc8 <safestrcpy+0x2c>
    80000da6:	fff6069b          	addiw	a3,a2,-1
    80000daa:	1682                	slli	a3,a3,0x20
    80000dac:	9281                	srli	a3,a3,0x20
    80000dae:	96ae                	add	a3,a3,a1
    80000db0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000db2:	00d58963          	beq	a1,a3,80000dc4 <safestrcpy+0x28>
    80000db6:	0585                	addi	a1,a1,1
    80000db8:	0785                	addi	a5,a5,1
    80000dba:	fff5c703          	lbu	a4,-1(a1)
    80000dbe:	fee78fa3          	sb	a4,-1(a5)
    80000dc2:	fb65                	bnez	a4,80000db2 <safestrcpy+0x16>
    ;
  *s = 0;
    80000dc4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret

0000000080000dce <strlen>:

int
strlen(const char *s)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e422                	sd	s0,8(sp)
    80000dd2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dd4:	00054783          	lbu	a5,0(a0)
    80000dd8:	cf91                	beqz	a5,80000df4 <strlen+0x26>
    80000dda:	0505                	addi	a0,a0,1
    80000ddc:	87aa                	mv	a5,a0
    80000dde:	4685                	li	a3,1
    80000de0:	9e89                	subw	a3,a3,a0
    80000de2:	00f6853b          	addw	a0,a3,a5
    80000de6:	0785                	addi	a5,a5,1
    80000de8:	fff7c703          	lbu	a4,-1(a5)
    80000dec:	fb7d                	bnez	a4,80000de2 <strlen+0x14>
    ;
  return n;
}
    80000dee:	6422                	ld	s0,8(sp)
    80000df0:	0141                	addi	sp,sp,16
    80000df2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000df4:	4501                	li	a0,0
    80000df6:	bfe5                	j	80000dee <strlen+0x20>

0000000080000df8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000df8:	1141                	addi	sp,sp,-16
    80000dfa:	e406                	sd	ra,8(sp)
    80000dfc:	e022                	sd	s0,0(sp)
    80000dfe:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e00:	1ef000ef          	jal	ra,800017ee <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e04:	00007717          	auipc	a4,0x7
    80000e08:	b1c70713          	addi	a4,a4,-1252 # 80007920 <started>
  if(cpuid() == 0){
    80000e0c:	c51d                	beqz	a0,80000e3a <main+0x42>
    while(started == 0)
    80000e0e:	431c                	lw	a5,0(a4)
    80000e10:	2781                	sext.w	a5,a5
    80000e12:	dff5                	beqz	a5,80000e0e <main+0x16>
      ;
    __sync_synchronize();
    80000e14:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e18:	1d7000ef          	jal	ra,800017ee <cpuid>
    80000e1c:	85aa                	mv	a1,a0
    80000e1e:	00006517          	auipc	a0,0x6
    80000e22:	29250513          	addi	a0,a0,658 # 800070b0 <digits+0x78>
    80000e26:	ea4ff0ef          	jal	ra,800004ca <printf>
    kvminithart();    // turn on paging
    80000e2a:	080000ef          	jal	ra,80000eaa <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e2e:	662010ef          	jal	ra,80002490 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e32:	6d2040ef          	jal	ra,80005504 <plicinithart>
  }

  scheduler();        
    80000e36:	675000ef          	jal	ra,80001caa <scheduler>
    consoleinit();
    80000e3a:	db8ff0ef          	jal	ra,800003f2 <consoleinit>
    printfinit();
    80000e3e:	98fff0ef          	jal	ra,800007cc <printfinit>
    printf("\n");
    80000e42:	00006517          	auipc	a0,0x6
    80000e46:	3ae50513          	addi	a0,a0,942 # 800071f0 <digits+0x1b8>
    80000e4a:	e80ff0ef          	jal	ra,800004ca <printf>
    printf("xv6 kernel is booting\n");
    80000e4e:	00006517          	auipc	a0,0x6
    80000e52:	24a50513          	addi	a0,a0,586 # 80007098 <digits+0x60>
    80000e56:	e74ff0ef          	jal	ra,800004ca <printf>
    printf("\n");
    80000e5a:	00006517          	auipc	a0,0x6
    80000e5e:	39650513          	addi	a0,a0,918 # 800071f0 <digits+0x1b8>
    80000e62:	e68ff0ef          	jal	ra,800004ca <printf>
    kinit();         // physical page allocator
    80000e66:	c11ff0ef          	jal	ra,80000a76 <kinit>
    kvminit();       // create kernel page table
    80000e6a:	2ca000ef          	jal	ra,80001134 <kvminit>
    kvminithart();   // turn on paging
    80000e6e:	03c000ef          	jal	ra,80000eaa <kvminithart>
    procinit();      // process table
    80000e72:	0d5000ef          	jal	ra,80001746 <procinit>
    trapinit();      // trap vectors
    80000e76:	5f6010ef          	jal	ra,8000246c <trapinit>
    trapinithart();  // install kernel trap vector
    80000e7a:	616010ef          	jal	ra,80002490 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e7e:	670040ef          	jal	ra,800054ee <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e82:	682040ef          	jal	ra,80005504 <plicinithart>
    binit();         // buffer cache
    80000e86:	62f010ef          	jal	ra,80002cb4 <binit>
    iinit();         // inode table
    80000e8a:	3a2020ef          	jal	ra,8000322c <iinit>
    fileinit();      // file table
    80000e8e:	282030ef          	jal	ra,80004110 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e92:	762040ef          	jal	ra,800055f4 <virtio_disk_init>
    userinit();      // first user process
    80000e96:	455000ef          	jal	ra,80001aea <userinit>
    __sync_synchronize();
    80000e9a:	0ff0000f          	fence
    started = 1;
    80000e9e:	4785                	li	a5,1
    80000ea0:	00007717          	auipc	a4,0x7
    80000ea4:	a8f72023          	sw	a5,-1408(a4) # 80007920 <started>
    80000ea8:	b779                	j	80000e36 <main+0x3e>

0000000080000eaa <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eaa:	1141                	addi	sp,sp,-16
    80000eac:	e422                	sd	s0,8(sp)
    80000eae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000eb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eb4:	00007797          	auipc	a5,0x7
    80000eb8:	a747b783          	ld	a5,-1420(a5) # 80007928 <kernel_pagetable>
    80000ebc:	83b1                	srli	a5,a5,0xc
    80000ebe:	577d                	li	a4,-1
    80000ec0:	177e                	slli	a4,a4,0x3f
    80000ec2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ec4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000ec8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ecc:	6422                	ld	s0,8(sp)
    80000ece:	0141                	addi	sp,sp,16
    80000ed0:	8082                	ret

0000000080000ed2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ed2:	7139                	addi	sp,sp,-64
    80000ed4:	fc06                	sd	ra,56(sp)
    80000ed6:	f822                	sd	s0,48(sp)
    80000ed8:	f426                	sd	s1,40(sp)
    80000eda:	f04a                	sd	s2,32(sp)
    80000edc:	ec4e                	sd	s3,24(sp)
    80000ede:	e852                	sd	s4,16(sp)
    80000ee0:	e456                	sd	s5,8(sp)
    80000ee2:	e05a                	sd	s6,0(sp)
    80000ee4:	0080                	addi	s0,sp,64
    80000ee6:	84aa                	mv	s1,a0
    80000ee8:	89ae                	mv	s3,a1
    80000eea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000eec:	57fd                	li	a5,-1
    80000eee:	83e9                	srli	a5,a5,0x1a
    80000ef0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ef2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ef4:	02b7fc63          	bgeu	a5,a1,80000f2c <walk+0x5a>
    panic("walk");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	1d050513          	addi	a0,a0,464 # 800070c8 <digits+0x90>
    80000f00:	891ff0ef          	jal	ra,80000790 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f04:	060a8263          	beqz	s5,80000f68 <walk+0x96>
    80000f08:	ba3ff0ef          	jal	ra,80000aaa <kalloc>
    80000f0c:	84aa                	mv	s1,a0
    80000f0e:	c139                	beqz	a0,80000f54 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f10:	6605                	lui	a2,0x1
    80000f12:	4581                	li	a1,0
    80000f14:	d3bff0ef          	jal	ra,80000c4e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f18:	00c4d793          	srli	a5,s1,0xc
    80000f1c:	07aa                	slli	a5,a5,0xa
    80000f1e:	0017e793          	ori	a5,a5,1
    80000f22:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f26:	3a5d                	addiw	s4,s4,-9
    80000f28:	036a0063          	beq	s4,s6,80000f48 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f2c:	0149d933          	srl	s2,s3,s4
    80000f30:	1ff97913          	andi	s2,s2,511
    80000f34:	090e                	slli	s2,s2,0x3
    80000f36:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f38:	00093483          	ld	s1,0(s2)
    80000f3c:	0014f793          	andi	a5,s1,1
    80000f40:	d3f1                	beqz	a5,80000f04 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f42:	80a9                	srli	s1,s1,0xa
    80000f44:	04b2                	slli	s1,s1,0xc
    80000f46:	b7c5                	j	80000f26 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f48:	00c9d513          	srli	a0,s3,0xc
    80000f4c:	1ff57513          	andi	a0,a0,511
    80000f50:	050e                	slli	a0,a0,0x3
    80000f52:	9526                	add	a0,a0,s1
}
    80000f54:	70e2                	ld	ra,56(sp)
    80000f56:	7442                	ld	s0,48(sp)
    80000f58:	74a2                	ld	s1,40(sp)
    80000f5a:	7902                	ld	s2,32(sp)
    80000f5c:	69e2                	ld	s3,24(sp)
    80000f5e:	6a42                	ld	s4,16(sp)
    80000f60:	6aa2                	ld	s5,8(sp)
    80000f62:	6b02                	ld	s6,0(sp)
    80000f64:	6121                	addi	sp,sp,64
    80000f66:	8082                	ret
        return 0;
    80000f68:	4501                	li	a0,0
    80000f6a:	b7ed                	j	80000f54 <walk+0x82>

0000000080000f6c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f6c:	57fd                	li	a5,-1
    80000f6e:	83e9                	srli	a5,a5,0x1a
    80000f70:	00b7f463          	bgeu	a5,a1,80000f78 <walkaddr+0xc>
    return 0;
    80000f74:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f76:	8082                	ret
{
    80000f78:	1141                	addi	sp,sp,-16
    80000f7a:	e406                	sd	ra,8(sp)
    80000f7c:	e022                	sd	s0,0(sp)
    80000f7e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f80:	4601                	li	a2,0
    80000f82:	f51ff0ef          	jal	ra,80000ed2 <walk>
  if(pte == 0)
    80000f86:	c105                	beqz	a0,80000fa6 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f88:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f8a:	0117f693          	andi	a3,a5,17
    80000f8e:	4745                	li	a4,17
    return 0;
    80000f90:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f92:	00e68663          	beq	a3,a4,80000f9e <walkaddr+0x32>
}
    80000f96:	60a2                	ld	ra,8(sp)
    80000f98:	6402                	ld	s0,0(sp)
    80000f9a:	0141                	addi	sp,sp,16
    80000f9c:	8082                	ret
  pa = PTE2PA(*pte);
    80000f9e:	00a7d513          	srli	a0,a5,0xa
    80000fa2:	0532                	slli	a0,a0,0xc
  return pa;
    80000fa4:	bfcd                	j	80000f96 <walkaddr+0x2a>
    return 0;
    80000fa6:	4501                	li	a0,0
    80000fa8:	b7fd                	j	80000f96 <walkaddr+0x2a>

0000000080000faa <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000faa:	715d                	addi	sp,sp,-80
    80000fac:	e486                	sd	ra,72(sp)
    80000fae:	e0a2                	sd	s0,64(sp)
    80000fb0:	fc26                	sd	s1,56(sp)
    80000fb2:	f84a                	sd	s2,48(sp)
    80000fb4:	f44e                	sd	s3,40(sp)
    80000fb6:	f052                	sd	s4,32(sp)
    80000fb8:	ec56                	sd	s5,24(sp)
    80000fba:	e85a                	sd	s6,16(sp)
    80000fbc:	e45e                	sd	s7,8(sp)
    80000fbe:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fc0:	03459793          	slli	a5,a1,0x34
    80000fc4:	e385                	bnez	a5,80000fe4 <mappages+0x3a>
    80000fc6:	8aaa                	mv	s5,a0
    80000fc8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fca:	03461793          	slli	a5,a2,0x34
    80000fce:	e38d                	bnez	a5,80000ff0 <mappages+0x46>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fd0:	c615                	beqz	a2,80000ffc <mappages+0x52>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fd2:	79fd                	lui	s3,0xfffff
    80000fd4:	964e                	add	a2,a2,s3
    80000fd6:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fda:	892e                	mv	s2,a1
    80000fdc:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fe0:	6b85                	lui	s7,0x1
    80000fe2:	a815                	j	80001016 <mappages+0x6c>
    panic("mappages: va not aligned");
    80000fe4:	00006517          	auipc	a0,0x6
    80000fe8:	0ec50513          	addi	a0,a0,236 # 800070d0 <digits+0x98>
    80000fec:	fa4ff0ef          	jal	ra,80000790 <panic>
    panic("mappages: size not aligned");
    80000ff0:	00006517          	auipc	a0,0x6
    80000ff4:	10050513          	addi	a0,a0,256 # 800070f0 <digits+0xb8>
    80000ff8:	f98ff0ef          	jal	ra,80000790 <panic>
    panic("mappages: size");
    80000ffc:	00006517          	auipc	a0,0x6
    80001000:	11450513          	addi	a0,a0,276 # 80007110 <digits+0xd8>
    80001004:	f8cff0ef          	jal	ra,80000790 <panic>
      panic("mappages: remap");
    80001008:	00006517          	auipc	a0,0x6
    8000100c:	11850513          	addi	a0,a0,280 # 80007120 <digits+0xe8>
    80001010:	f80ff0ef          	jal	ra,80000790 <panic>
    a += PGSIZE;
    80001014:	995e                	add	s2,s2,s7
  for(;;){
    80001016:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000101a:	4605                	li	a2,1
    8000101c:	85ca                	mv	a1,s2
    8000101e:	8556                	mv	a0,s5
    80001020:	eb3ff0ef          	jal	ra,80000ed2 <walk>
    80001024:	cd19                	beqz	a0,80001042 <mappages+0x98>
    if(*pte & PTE_V)
    80001026:	611c                	ld	a5,0(a0)
    80001028:	8b85                	andi	a5,a5,1
    8000102a:	fff9                	bnez	a5,80001008 <mappages+0x5e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000102c:	80b1                	srli	s1,s1,0xc
    8000102e:	04aa                	slli	s1,s1,0xa
    80001030:	0164e4b3          	or	s1,s1,s6
    80001034:	0014e493          	ori	s1,s1,1
    80001038:	e104                	sd	s1,0(a0)
    if(a == last)
    8000103a:	fd391de3          	bne	s2,s3,80001014 <mappages+0x6a>
    pa += PGSIZE;
  }
  return 0;
    8000103e:	4501                	li	a0,0
    80001040:	a011                	j	80001044 <mappages+0x9a>
      return -1;
    80001042:	557d                	li	a0,-1
}
    80001044:	60a6                	ld	ra,72(sp)
    80001046:	6406                	ld	s0,64(sp)
    80001048:	74e2                	ld	s1,56(sp)
    8000104a:	7942                	ld	s2,48(sp)
    8000104c:	79a2                	ld	s3,40(sp)
    8000104e:	7a02                	ld	s4,32(sp)
    80001050:	6ae2                	ld	s5,24(sp)
    80001052:	6b42                	ld	s6,16(sp)
    80001054:	6ba2                	ld	s7,8(sp)
    80001056:	6161                	addi	sp,sp,80
    80001058:	8082                	ret

000000008000105a <kvmmap>:
{
    8000105a:	1141                	addi	sp,sp,-16
    8000105c:	e406                	sd	ra,8(sp)
    8000105e:	e022                	sd	s0,0(sp)
    80001060:	0800                	addi	s0,sp,16
    80001062:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001064:	86b2                	mv	a3,a2
    80001066:	863e                	mv	a2,a5
    80001068:	f43ff0ef          	jal	ra,80000faa <mappages>
    8000106c:	e509                	bnez	a0,80001076 <kvmmap+0x1c>
}
    8000106e:	60a2                	ld	ra,8(sp)
    80001070:	6402                	ld	s0,0(sp)
    80001072:	0141                	addi	sp,sp,16
    80001074:	8082                	ret
    panic("kvmmap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	0ba50513          	addi	a0,a0,186 # 80007130 <digits+0xf8>
    8000107e:	f12ff0ef          	jal	ra,80000790 <panic>

0000000080001082 <kvmmake>:
{
    80001082:	1101                	addi	sp,sp,-32
    80001084:	ec06                	sd	ra,24(sp)
    80001086:	e822                	sd	s0,16(sp)
    80001088:	e426                	sd	s1,8(sp)
    8000108a:	e04a                	sd	s2,0(sp)
    8000108c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000108e:	a1dff0ef          	jal	ra,80000aaa <kalloc>
    80001092:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001094:	6605                	lui	a2,0x1
    80001096:	4581                	li	a1,0
    80001098:	bb7ff0ef          	jal	ra,80000c4e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000109c:	4719                	li	a4,6
    8000109e:	6685                	lui	a3,0x1
    800010a0:	10000637          	lui	a2,0x10000
    800010a4:	100005b7          	lui	a1,0x10000
    800010a8:	8526                	mv	a0,s1
    800010aa:	fb1ff0ef          	jal	ra,8000105a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010ae:	4719                	li	a4,6
    800010b0:	6685                	lui	a3,0x1
    800010b2:	10001637          	lui	a2,0x10001
    800010b6:	100015b7          	lui	a1,0x10001
    800010ba:	8526                	mv	a0,s1
    800010bc:	f9fff0ef          	jal	ra,8000105a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010c0:	4719                	li	a4,6
    800010c2:	040006b7          	lui	a3,0x4000
    800010c6:	0c000637          	lui	a2,0xc000
    800010ca:	0c0005b7          	lui	a1,0xc000
    800010ce:	8526                	mv	a0,s1
    800010d0:	f8bff0ef          	jal	ra,8000105a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010d4:	00006917          	auipc	s2,0x6
    800010d8:	f2c90913          	addi	s2,s2,-212 # 80007000 <etext>
    800010dc:	4729                	li	a4,10
    800010de:	80006697          	auipc	a3,0x80006
    800010e2:	f2268693          	addi	a3,a3,-222 # 7000 <_entry-0x7fff9000>
    800010e6:	4605                	li	a2,1
    800010e8:	067e                	slli	a2,a2,0x1f
    800010ea:	85b2                	mv	a1,a2
    800010ec:	8526                	mv	a0,s1
    800010ee:	f6dff0ef          	jal	ra,8000105a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	46c5                	li	a3,17
    800010f6:	06ee                	slli	a3,a3,0x1b
    800010f8:	412686b3          	sub	a3,a3,s2
    800010fc:	864a                	mv	a2,s2
    800010fe:	85ca                	mv	a1,s2
    80001100:	8526                	mv	a0,s1
    80001102:	f59ff0ef          	jal	ra,8000105a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001106:	4729                	li	a4,10
    80001108:	6685                	lui	a3,0x1
    8000110a:	00005617          	auipc	a2,0x5
    8000110e:	ef660613          	addi	a2,a2,-266 # 80006000 <_trampoline>
    80001112:	040005b7          	lui	a1,0x4000
    80001116:	15fd                	addi	a1,a1,-1
    80001118:	05b2                	slli	a1,a1,0xc
    8000111a:	8526                	mv	a0,s1
    8000111c:	f3fff0ef          	jal	ra,8000105a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001120:	8526                	mv	a0,s1
    80001122:	59a000ef          	jal	ra,800016bc <proc_mapstacks>
}
    80001126:	8526                	mv	a0,s1
    80001128:	60e2                	ld	ra,24(sp)
    8000112a:	6442                	ld	s0,16(sp)
    8000112c:	64a2                	ld	s1,8(sp)
    8000112e:	6902                	ld	s2,0(sp)
    80001130:	6105                	addi	sp,sp,32
    80001132:	8082                	ret

0000000080001134 <kvminit>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000113c:	f47ff0ef          	jal	ra,80001082 <kvmmake>
    80001140:	00006797          	auipc	a5,0x6
    80001144:	7ea7b423          	sd	a0,2024(a5) # 80007928 <kernel_pagetable>
}
    80001148:	60a2                	ld	ra,8(sp)
    8000114a:	6402                	ld	s0,0(sp)
    8000114c:	0141                	addi	sp,sp,16
    8000114e:	8082                	ret

0000000080001150 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001150:	1101                	addi	sp,sp,-32
    80001152:	ec06                	sd	ra,24(sp)
    80001154:	e822                	sd	s0,16(sp)
    80001156:	e426                	sd	s1,8(sp)
    80001158:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000115a:	951ff0ef          	jal	ra,80000aaa <kalloc>
    8000115e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001160:	c509                	beqz	a0,8000116a <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	ae9ff0ef          	jal	ra,80000c4e <memset>
  return pagetable;
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6105                	addi	sp,sp,32
    80001174:	8082                	ret

0000000080001176 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001176:	7139                	addi	sp,sp,-64
    80001178:	fc06                	sd	ra,56(sp)
    8000117a:	f822                	sd	s0,48(sp)
    8000117c:	f426                	sd	s1,40(sp)
    8000117e:	f04a                	sd	s2,32(sp)
    80001180:	ec4e                	sd	s3,24(sp)
    80001182:	e852                	sd	s4,16(sp)
    80001184:	e456                	sd	s5,8(sp)
    80001186:	e05a                	sd	s6,0(sp)
    80001188:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000118a:	03459793          	slli	a5,a1,0x34
    8000118e:	e785                	bnez	a5,800011b6 <uvmunmap+0x40>
    80001190:	8a2a                	mv	s4,a0
    80001192:	892e                	mv	s2,a1
    80001194:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001196:	0632                	slli	a2,a2,0xc
    80001198:	00b609b3          	add	s3,a2,a1
    8000119c:	6b05                	lui	s6,0x1
    8000119e:	0335ec63          	bltu	a1,s3,800011d6 <uvmunmap+0x60>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800011a2:	70e2                	ld	ra,56(sp)
    800011a4:	7442                	ld	s0,48(sp)
    800011a6:	74a2                	ld	s1,40(sp)
    800011a8:	7902                	ld	s2,32(sp)
    800011aa:	69e2                	ld	s3,24(sp)
    800011ac:	6a42                	ld	s4,16(sp)
    800011ae:	6aa2                	ld	s5,8(sp)
    800011b0:	6b02                	ld	s6,0(sp)
    800011b2:	6121                	addi	sp,sp,64
    800011b4:	8082                	ret
    panic("uvmunmap: not aligned");
    800011b6:	00006517          	auipc	a0,0x6
    800011ba:	f8250513          	addi	a0,a0,-126 # 80007138 <digits+0x100>
    800011be:	dd2ff0ef          	jal	ra,80000790 <panic>
      uint64 pa = PTE2PA(*pte);
    800011c2:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011c4:	00c79513          	slli	a0,a5,0xc
    800011c8:	803ff0ef          	jal	ra,800009ca <kfree>
    *pte = 0;
    800011cc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d0:	995a                	add	s2,s2,s6
    800011d2:	fd3978e3          	bgeu	s2,s3,800011a2 <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011d6:	4601                	li	a2,0
    800011d8:	85ca                	mv	a1,s2
    800011da:	8552                	mv	a0,s4
    800011dc:	cf7ff0ef          	jal	ra,80000ed2 <walk>
    800011e0:	84aa                	mv	s1,a0
    800011e2:	d57d                	beqz	a0,800011d0 <uvmunmap+0x5a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011e4:	611c                	ld	a5,0(a0)
    800011e6:	0017f713          	andi	a4,a5,1
    800011ea:	d37d                	beqz	a4,800011d0 <uvmunmap+0x5a>
    if(do_free){
    800011ec:	fe0a80e3          	beqz	s5,800011cc <uvmunmap+0x56>
    800011f0:	bfc9                	j	800011c2 <uvmunmap+0x4c>

00000000800011f2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011f2:	1101                	addi	sp,sp,-32
    800011f4:	ec06                	sd	ra,24(sp)
    800011f6:	e822                	sd	s0,16(sp)
    800011f8:	e426                	sd	s1,8(sp)
    800011fa:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011fc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011fe:	00b67d63          	bgeu	a2,a1,80001218 <uvmdealloc+0x26>
    80001202:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001204:	6785                	lui	a5,0x1
    80001206:	17fd                	addi	a5,a5,-1
    80001208:	00f60733          	add	a4,a2,a5
    8000120c:	767d                	lui	a2,0xfffff
    8000120e:	8f71                	and	a4,a4,a2
    80001210:	97ae                	add	a5,a5,a1
    80001212:	8ff1                	and	a5,a5,a2
    80001214:	00f76863          	bltu	a4,a5,80001224 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001218:	8526                	mv	a0,s1
    8000121a:	60e2                	ld	ra,24(sp)
    8000121c:	6442                	ld	s0,16(sp)
    8000121e:	64a2                	ld	s1,8(sp)
    80001220:	6105                	addi	sp,sp,32
    80001222:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001224:	8f99                	sub	a5,a5,a4
    80001226:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001228:	4685                	li	a3,1
    8000122a:	0007861b          	sext.w	a2,a5
    8000122e:	85ba                	mv	a1,a4
    80001230:	f47ff0ef          	jal	ra,80001176 <uvmunmap>
    80001234:	b7d5                	j	80001218 <uvmdealloc+0x26>

0000000080001236 <uvmalloc>:
  if(newsz < oldsz)
    80001236:	08b66963          	bltu	a2,a1,800012c8 <uvmalloc+0x92>
{
    8000123a:	7139                	addi	sp,sp,-64
    8000123c:	fc06                	sd	ra,56(sp)
    8000123e:	f822                	sd	s0,48(sp)
    80001240:	f426                	sd	s1,40(sp)
    80001242:	f04a                	sd	s2,32(sp)
    80001244:	ec4e                	sd	s3,24(sp)
    80001246:	e852                	sd	s4,16(sp)
    80001248:	e456                	sd	s5,8(sp)
    8000124a:	e05a                	sd	s6,0(sp)
    8000124c:	0080                	addi	s0,sp,64
    8000124e:	8aaa                	mv	s5,a0
    80001250:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001252:	6985                	lui	s3,0x1
    80001254:	19fd                	addi	s3,s3,-1
    80001256:	95ce                	add	a1,a1,s3
    80001258:	79fd                	lui	s3,0xfffff
    8000125a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000125e:	06c9f763          	bgeu	s3,a2,800012cc <uvmalloc+0x96>
    80001262:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001264:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001268:	843ff0ef          	jal	ra,80000aaa <kalloc>
    8000126c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000126e:	c11d                	beqz	a0,80001294 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    80001270:	6605                	lui	a2,0x1
    80001272:	4581                	li	a1,0
    80001274:	9dbff0ef          	jal	ra,80000c4e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001278:	875a                	mv	a4,s6
    8000127a:	86a6                	mv	a3,s1
    8000127c:	6605                	lui	a2,0x1
    8000127e:	85ca                	mv	a1,s2
    80001280:	8556                	mv	a0,s5
    80001282:	d29ff0ef          	jal	ra,80000faa <mappages>
    80001286:	e51d                	bnez	a0,800012b4 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001288:	6785                	lui	a5,0x1
    8000128a:	993e                	add	s2,s2,a5
    8000128c:	fd496ee3          	bltu	s2,s4,80001268 <uvmalloc+0x32>
  return newsz;
    80001290:	8552                	mv	a0,s4
    80001292:	a039                	j	800012a0 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80001294:	864e                	mv	a2,s3
    80001296:	85ca                	mv	a1,s2
    80001298:	8556                	mv	a0,s5
    8000129a:	f59ff0ef          	jal	ra,800011f2 <uvmdealloc>
      return 0;
    8000129e:	4501                	li	a0,0
}
    800012a0:	70e2                	ld	ra,56(sp)
    800012a2:	7442                	ld	s0,48(sp)
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
    800012b0:	6121                	addi	sp,sp,64
    800012b2:	8082                	ret
      kfree(mem);
    800012b4:	8526                	mv	a0,s1
    800012b6:	f14ff0ef          	jal	ra,800009ca <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012ba:	864e                	mv	a2,s3
    800012bc:	85ca                	mv	a1,s2
    800012be:	8556                	mv	a0,s5
    800012c0:	f33ff0ef          	jal	ra,800011f2 <uvmdealloc>
      return 0;
    800012c4:	4501                	li	a0,0
    800012c6:	bfe9                	j	800012a0 <uvmalloc+0x6a>
    return oldsz;
    800012c8:	852e                	mv	a0,a1
}
    800012ca:	8082                	ret
  return newsz;
    800012cc:	8532                	mv	a0,a2
    800012ce:	bfc9                	j	800012a0 <uvmalloc+0x6a>

00000000800012d0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012d0:	7179                	addi	sp,sp,-48
    800012d2:	f406                	sd	ra,40(sp)
    800012d4:	f022                	sd	s0,32(sp)
    800012d6:	ec26                	sd	s1,24(sp)
    800012d8:	e84a                	sd	s2,16(sp)
    800012da:	e44e                	sd	s3,8(sp)
    800012dc:	e052                	sd	s4,0(sp)
    800012de:	1800                	addi	s0,sp,48
    800012e0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012e2:	84aa                	mv	s1,a0
    800012e4:	6905                	lui	s2,0x1
    800012e6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012e8:	4985                	li	s3,1
    800012ea:	a811                	j	800012fe <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012ec:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800012ee:	0532                	slli	a0,a0,0xc
    800012f0:	fe1ff0ef          	jal	ra,800012d0 <freewalk>
      pagetable[i] = 0;
    800012f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012f8:	04a1                	addi	s1,s1,8
    800012fa:	01248f63          	beq	s1,s2,80001318 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800012fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001300:	00f57793          	andi	a5,a0,15
    80001304:	ff3784e3          	beq	a5,s3,800012ec <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001308:	8905                	andi	a0,a0,1
    8000130a:	d57d                	beqz	a0,800012f8 <freewalk+0x28>
      panic("freewalk: leaf");
    8000130c:	00006517          	auipc	a0,0x6
    80001310:	e4450513          	addi	a0,a0,-444 # 80007150 <digits+0x118>
    80001314:	c7cff0ef          	jal	ra,80000790 <panic>
    }
  }
  kfree((void*)pagetable);
    80001318:	8552                	mv	a0,s4
    8000131a:	eb0ff0ef          	jal	ra,800009ca <kfree>
}
    8000131e:	70a2                	ld	ra,40(sp)
    80001320:	7402                	ld	s0,32(sp)
    80001322:	64e2                	ld	s1,24(sp)
    80001324:	6942                	ld	s2,16(sp)
    80001326:	69a2                	ld	s3,8(sp)
    80001328:	6a02                	ld	s4,0(sp)
    8000132a:	6145                	addi	sp,sp,48
    8000132c:	8082                	ret

000000008000132e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000132e:	1101                	addi	sp,sp,-32
    80001330:	ec06                	sd	ra,24(sp)
    80001332:	e822                	sd	s0,16(sp)
    80001334:	e426                	sd	s1,8(sp)
    80001336:	1000                	addi	s0,sp,32
    80001338:	84aa                	mv	s1,a0
  if(sz > 0)
    8000133a:	e989                	bnez	a1,8000134c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000133c:	8526                	mv	a0,s1
    8000133e:	f93ff0ef          	jal	ra,800012d0 <freewalk>
}
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000134c:	6605                	lui	a2,0x1
    8000134e:	167d                	addi	a2,a2,-1
    80001350:	962e                	add	a2,a2,a1
    80001352:	4685                	li	a3,1
    80001354:	8231                	srli	a2,a2,0xc
    80001356:	4581                	li	a1,0
    80001358:	e1fff0ef          	jal	ra,80001176 <uvmunmap>
    8000135c:	b7c5                	j	8000133c <uvmfree+0xe>

000000008000135e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000135e:	ce49                	beqz	a2,800013f8 <uvmcopy+0x9a>
{
    80001360:	715d                	addi	sp,sp,-80
    80001362:	e486                	sd	ra,72(sp)
    80001364:	e0a2                	sd	s0,64(sp)
    80001366:	fc26                	sd	s1,56(sp)
    80001368:	f84a                	sd	s2,48(sp)
    8000136a:	f44e                	sd	s3,40(sp)
    8000136c:	f052                	sd	s4,32(sp)
    8000136e:	ec56                	sd	s5,24(sp)
    80001370:	e85a                	sd	s6,16(sp)
    80001372:	e45e                	sd	s7,8(sp)
    80001374:	0880                	addi	s0,sp,80
    80001376:	8aaa                	mv	s5,a0
    80001378:	8b2e                	mv	s6,a1
    8000137a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000137c:	4481                	li	s1,0
    8000137e:	a029                	j	80001388 <uvmcopy+0x2a>
    80001380:	6785                	lui	a5,0x1
    80001382:	94be                	add	s1,s1,a5
    80001384:	0544fe63          	bgeu	s1,s4,800013e0 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001388:	4601                	li	a2,0
    8000138a:	85a6                	mv	a1,s1
    8000138c:	8556                	mv	a0,s5
    8000138e:	b45ff0ef          	jal	ra,80000ed2 <walk>
    80001392:	d57d                	beqz	a0,80001380 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001394:	6118                	ld	a4,0(a0)
    80001396:	00177793          	andi	a5,a4,1
    8000139a:	d3fd                	beqz	a5,80001380 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    8000139c:	00a75593          	srli	a1,a4,0xa
    800013a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013a4:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800013a8:	f02ff0ef          	jal	ra,80000aaa <kalloc>
    800013ac:	89aa                	mv	s3,a0
    800013ae:	c105                	beqz	a0,800013ce <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800013b0:	6605                	lui	a2,0x1
    800013b2:	85de                	mv	a1,s7
    800013b4:	8fbff0ef          	jal	ra,80000cae <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013b8:	874a                	mv	a4,s2
    800013ba:	86ce                	mv	a3,s3
    800013bc:	6605                	lui	a2,0x1
    800013be:	85a6                	mv	a1,s1
    800013c0:	855a                	mv	a0,s6
    800013c2:	be9ff0ef          	jal	ra,80000faa <mappages>
    800013c6:	dd4d                	beqz	a0,80001380 <uvmcopy+0x22>
      kfree(mem);
    800013c8:	854e                	mv	a0,s3
    800013ca:	e00ff0ef          	jal	ra,800009ca <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013ce:	4685                	li	a3,1
    800013d0:	00c4d613          	srli	a2,s1,0xc
    800013d4:	4581                	li	a1,0
    800013d6:	855a                	mv	a0,s6
    800013d8:	d9fff0ef          	jal	ra,80001176 <uvmunmap>
  return -1;
    800013dc:	557d                	li	a0,-1
    800013de:	a011                	j	800013e2 <uvmcopy+0x84>
  return 0;
    800013e0:	4501                	li	a0,0
}
    800013e2:	60a6                	ld	ra,72(sp)
    800013e4:	6406                	ld	s0,64(sp)
    800013e6:	74e2                	ld	s1,56(sp)
    800013e8:	7942                	ld	s2,48(sp)
    800013ea:	79a2                	ld	s3,40(sp)
    800013ec:	7a02                	ld	s4,32(sp)
    800013ee:	6ae2                	ld	s5,24(sp)
    800013f0:	6b42                	ld	s6,16(sp)
    800013f2:	6ba2                	ld	s7,8(sp)
    800013f4:	6161                	addi	sp,sp,80
    800013f6:	8082                	ret
  return 0;
    800013f8:	4501                	li	a0,0
}
    800013fa:	8082                	ret

00000000800013fc <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013fc:	1141                	addi	sp,sp,-16
    800013fe:	e406                	sd	ra,8(sp)
    80001400:	e022                	sd	s0,0(sp)
    80001402:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001404:	4601                	li	a2,0
    80001406:	acdff0ef          	jal	ra,80000ed2 <walk>
  if(pte == 0)
    8000140a:	c901                	beqz	a0,8000141a <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000140c:	611c                	ld	a5,0(a0)
    8000140e:	9bbd                	andi	a5,a5,-17
    80001410:	e11c                	sd	a5,0(a0)
}
    80001412:	60a2                	ld	ra,8(sp)
    80001414:	6402                	ld	s0,0(sp)
    80001416:	0141                	addi	sp,sp,16
    80001418:	8082                	ret
    panic("uvmclear");
    8000141a:	00006517          	auipc	a0,0x6
    8000141e:	d4650513          	addi	a0,a0,-698 # 80007160 <digits+0x128>
    80001422:	b6eff0ef          	jal	ra,80000790 <panic>

0000000080001426 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001426:	c2d5                	beqz	a3,800014ca <copyinstr+0xa4>
{
    80001428:	715d                	addi	sp,sp,-80
    8000142a:	e486                	sd	ra,72(sp)
    8000142c:	e0a2                	sd	s0,64(sp)
    8000142e:	fc26                	sd	s1,56(sp)
    80001430:	f84a                	sd	s2,48(sp)
    80001432:	f44e                	sd	s3,40(sp)
    80001434:	f052                	sd	s4,32(sp)
    80001436:	ec56                	sd	s5,24(sp)
    80001438:	e85a                	sd	s6,16(sp)
    8000143a:	e45e                	sd	s7,8(sp)
    8000143c:	0880                	addi	s0,sp,80
    8000143e:	8a2a                	mv	s4,a0
    80001440:	8b2e                	mv	s6,a1
    80001442:	8bb2                	mv	s7,a2
    80001444:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001446:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001448:	6985                	lui	s3,0x1
    8000144a:	a035                	j	80001476 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000144c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001450:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001452:	0017b793          	seqz	a5,a5
    80001456:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000145a:	60a6                	ld	ra,72(sp)
    8000145c:	6406                	ld	s0,64(sp)
    8000145e:	74e2                	ld	s1,56(sp)
    80001460:	7942                	ld	s2,48(sp)
    80001462:	79a2                	ld	s3,40(sp)
    80001464:	7a02                	ld	s4,32(sp)
    80001466:	6ae2                	ld	s5,24(sp)
    80001468:	6b42                	ld	s6,16(sp)
    8000146a:	6ba2                	ld	s7,8(sp)
    8000146c:	6161                	addi	sp,sp,80
    8000146e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001470:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001474:	c4b9                	beqz	s1,800014c2 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001476:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000147a:	85ca                	mv	a1,s2
    8000147c:	8552                	mv	a0,s4
    8000147e:	aefff0ef          	jal	ra,80000f6c <walkaddr>
    if(pa0 == 0)
    80001482:	c131                	beqz	a0,800014c6 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80001484:	41790833          	sub	a6,s2,s7
    80001488:	984e                	add	a6,a6,s3
    if(n > max)
    8000148a:	0104f363          	bgeu	s1,a6,80001490 <copyinstr+0x6a>
    8000148e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001490:	955e                	add	a0,a0,s7
    80001492:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001496:	fc080de3          	beqz	a6,80001470 <copyinstr+0x4a>
    8000149a:	985a                	add	a6,a6,s6
    8000149c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000149e:	41650633          	sub	a2,a0,s6
    800014a2:	14fd                	addi	s1,s1,-1
    800014a4:	9b26                	add	s6,s6,s1
    800014a6:	00f60733          	add	a4,a2,a5
    800014aa:	00074703          	lbu	a4,0(a4)
    800014ae:	df59                	beqz	a4,8000144c <copyinstr+0x26>
        *dst = *p;
    800014b0:	00e78023          	sb	a4,0(a5)
      --max;
    800014b4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800014b8:	0785                	addi	a5,a5,1
    while(n > 0){
    800014ba:	ff0796e3          	bne	a5,a6,800014a6 <copyinstr+0x80>
      dst++;
    800014be:	8b42                	mv	s6,a6
    800014c0:	bf45                	j	80001470 <copyinstr+0x4a>
    800014c2:	4781                	li	a5,0
    800014c4:	b779                	j	80001452 <copyinstr+0x2c>
      return -1;
    800014c6:	557d                	li	a0,-1
    800014c8:	bf49                	j	8000145a <copyinstr+0x34>
  int got_null = 0;
    800014ca:	4781                	li	a5,0
  if(got_null){
    800014cc:	0017b793          	seqz	a5,a5
    800014d0:	40f00533          	neg	a0,a5
}
    800014d4:	8082                	ret

00000000800014d6 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014d6:	1141                	addi	sp,sp,-16
    800014d8:	e406                	sd	ra,8(sp)
    800014da:	e022                	sd	s0,0(sp)
    800014dc:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014de:	4601                	li	a2,0
    800014e0:	9f3ff0ef          	jal	ra,80000ed2 <walk>
  if (pte == 0) {
    800014e4:	c519                	beqz	a0,800014f2 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014e6:	6108                	ld	a0,0(a0)
    return 0;
    800014e8:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014ea:	60a2                	ld	ra,8(sp)
    800014ec:	6402                	ld	s0,0(sp)
    800014ee:	0141                	addi	sp,sp,16
    800014f0:	8082                	ret
    return 0;
    800014f2:	4501                	li	a0,0
    800014f4:	bfdd                	j	800014ea <ismapped+0x14>

00000000800014f6 <vmfault>:
{
    800014f6:	7179                	addi	sp,sp,-48
    800014f8:	f406                	sd	ra,40(sp)
    800014fa:	f022                	sd	s0,32(sp)
    800014fc:	ec26                	sd	s1,24(sp)
    800014fe:	e84a                	sd	s2,16(sp)
    80001500:	e44e                	sd	s3,8(sp)
    80001502:	e052                	sd	s4,0(sp)
    80001504:	1800                	addi	s0,sp,48
    80001506:	89aa                	mv	s3,a0
    80001508:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000150a:	310000ef          	jal	ra,8000181a <myproc>
  if (va >= p->sz)
    8000150e:	653c                	ld	a5,72(a0)
    80001510:	00f4ec63          	bltu	s1,a5,80001528 <vmfault+0x32>
    return 0;
    80001514:	4981                	li	s3,0
}
    80001516:	854e                	mv	a0,s3
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret
    80001528:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000152a:	75fd                	lui	a1,0xfffff
    8000152c:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) {
    8000152e:	85a6                	mv	a1,s1
    80001530:	854e                	mv	a0,s3
    80001532:	fa5ff0ef          	jal	ra,800014d6 <ismapped>
    return 0;
    80001536:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001538:	fd79                	bnez	a0,80001516 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000153a:	d70ff0ef          	jal	ra,80000aaa <kalloc>
    8000153e:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001540:	d979                	beqz	a0,80001516 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001542:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001544:	6605                	lui	a2,0x1
    80001546:	4581                	li	a1,0
    80001548:	f06ff0ef          	jal	ra,80000c4e <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000154c:	4759                	li	a4,22
    8000154e:	86d2                	mv	a3,s4
    80001550:	6605                	lui	a2,0x1
    80001552:	85a6                	mv	a1,s1
    80001554:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001558:	a53ff0ef          	jal	ra,80000faa <mappages>
    8000155c:	dd4d                	beqz	a0,80001516 <vmfault+0x20>
    kfree((void *)mem);
    8000155e:	8552                	mv	a0,s4
    80001560:	c6aff0ef          	jal	ra,800009ca <kfree>
    return 0;
    80001564:	4981                	li	s3,0
    80001566:	bf45                	j	80001516 <vmfault+0x20>

0000000080001568 <copyout>:
  while(len > 0){
    80001568:	cec1                	beqz	a3,80001600 <copyout+0x98>
{
    8000156a:	711d                	addi	sp,sp,-96
    8000156c:	ec86                	sd	ra,88(sp)
    8000156e:	e8a2                	sd	s0,80(sp)
    80001570:	e4a6                	sd	s1,72(sp)
    80001572:	e0ca                	sd	s2,64(sp)
    80001574:	fc4e                	sd	s3,56(sp)
    80001576:	f852                	sd	s4,48(sp)
    80001578:	f456                	sd	s5,40(sp)
    8000157a:	f05a                	sd	s6,32(sp)
    8000157c:	ec5e                	sd	s7,24(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
    80001584:	1080                	addi	s0,sp,96
    80001586:	8c2a                	mv	s8,a0
    80001588:	8b2e                	mv	s6,a1
    8000158a:	8bb2                	mv	s7,a2
    8000158c:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    8000158e:	74fd                	lui	s1,0xfffff
    80001590:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001592:	57fd                	li	a5,-1
    80001594:	83e9                	srli	a5,a5,0x1a
    80001596:	0697e763          	bltu	a5,s1,80001604 <copyout+0x9c>
    8000159a:	6d05                	lui	s10,0x1
    8000159c:	8cbe                	mv	s9,a5
    8000159e:	a015                	j	800015c2 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015a0:	409b0533          	sub	a0,s6,s1
    800015a4:	0009861b          	sext.w	a2,s3
    800015a8:	85de                	mv	a1,s7
    800015aa:	954a                	add	a0,a0,s2
    800015ac:	f02ff0ef          	jal	ra,80000cae <memmove>
    len -= n;
    800015b0:	413a0a33          	sub	s4,s4,s3
    src += n;
    800015b4:	9bce                	add	s7,s7,s3
  while(len > 0){
    800015b6:	040a0363          	beqz	s4,800015fc <copyout+0x94>
    if(va0 >= MAXVA)
    800015ba:	055ce763          	bltu	s9,s5,80001608 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015be:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015c0:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015c2:	85a6                	mv	a1,s1
    800015c4:	8562                	mv	a0,s8
    800015c6:	9a7ff0ef          	jal	ra,80000f6c <walkaddr>
    800015ca:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015cc:	e901                	bnez	a0,800015dc <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015ce:	4601                	li	a2,0
    800015d0:	85a6                	mv	a1,s1
    800015d2:	8562                	mv	a0,s8
    800015d4:	f23ff0ef          	jal	ra,800014f6 <vmfault>
    800015d8:	892a                	mv	s2,a0
    800015da:	c90d                	beqz	a0,8000160c <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015dc:	4601                	li	a2,0
    800015de:	85a6                	mv	a1,s1
    800015e0:	8562                	mv	a0,s8
    800015e2:	8f1ff0ef          	jal	ra,80000ed2 <walk>
    if((*pte & PTE_W) == 0)
    800015e6:	611c                	ld	a5,0(a0)
    800015e8:	8b91                	andi	a5,a5,4
    800015ea:	c39d                	beqz	a5,80001610 <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015ec:	01a48ab3          	add	s5,s1,s10
    800015f0:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800015f4:	fb3a76e3          	bgeu	s4,s3,800015a0 <copyout+0x38>
    800015f8:	89d2                	mv	s3,s4
    800015fa:	b75d                	j	800015a0 <copyout+0x38>
  return 0;
    800015fc:	4501                	li	a0,0
    800015fe:	a811                	j	80001612 <copyout+0xaa>
    80001600:	4501                	li	a0,0
}
    80001602:	8082                	ret
      return -1;
    80001604:	557d                	li	a0,-1
    80001606:	a031                	j	80001612 <copyout+0xaa>
    80001608:	557d                	li	a0,-1
    8000160a:	a021                	j	80001612 <copyout+0xaa>
        return -1;
    8000160c:	557d                	li	a0,-1
    8000160e:	a011                	j	80001612 <copyout+0xaa>
      return -1;
    80001610:	557d                	li	a0,-1
}
    80001612:	60e6                	ld	ra,88(sp)
    80001614:	6446                	ld	s0,80(sp)
    80001616:	64a6                	ld	s1,72(sp)
    80001618:	6906                	ld	s2,64(sp)
    8000161a:	79e2                	ld	s3,56(sp)
    8000161c:	7a42                	ld	s4,48(sp)
    8000161e:	7aa2                	ld	s5,40(sp)
    80001620:	7b02                	ld	s6,32(sp)
    80001622:	6be2                	ld	s7,24(sp)
    80001624:	6c42                	ld	s8,16(sp)
    80001626:	6ca2                	ld	s9,8(sp)
    80001628:	6d02                	ld	s10,0(sp)
    8000162a:	6125                	addi	sp,sp,96
    8000162c:	8082                	ret

000000008000162e <copyin>:
  while(len > 0){
    8000162e:	c6c9                	beqz	a3,800016b8 <copyin+0x8a>
{
    80001630:	715d                	addi	sp,sp,-80
    80001632:	e486                	sd	ra,72(sp)
    80001634:	e0a2                	sd	s0,64(sp)
    80001636:	fc26                	sd	s1,56(sp)
    80001638:	f84a                	sd	s2,48(sp)
    8000163a:	f44e                	sd	s3,40(sp)
    8000163c:	f052                	sd	s4,32(sp)
    8000163e:	ec56                	sd	s5,24(sp)
    80001640:	e85a                	sd	s6,16(sp)
    80001642:	e45e                	sd	s7,8(sp)
    80001644:	e062                	sd	s8,0(sp)
    80001646:	0880                	addi	s0,sp,80
    80001648:	8baa                	mv	s7,a0
    8000164a:	8aae                	mv	s5,a1
    8000164c:	8932                	mv	s2,a2
    8000164e:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001650:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001652:	6b05                	lui	s6,0x1
    80001654:	a035                	j	80001680 <copyin+0x52>
    80001656:	412984b3          	sub	s1,s3,s2
    8000165a:	94da                	add	s1,s1,s6
    if(n > len)
    8000165c:	009a7363          	bgeu	s4,s1,80001662 <copyin+0x34>
    80001660:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001662:	413905b3          	sub	a1,s2,s3
    80001666:	0004861b          	sext.w	a2,s1
    8000166a:	95aa                	add	a1,a1,a0
    8000166c:	8556                	mv	a0,s5
    8000166e:	e40ff0ef          	jal	ra,80000cae <memmove>
    len -= n;
    80001672:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001676:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001678:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000167c:	020a0163          	beqz	s4,8000169e <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001680:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001684:	85ce                	mv	a1,s3
    80001686:	855e                	mv	a0,s7
    80001688:	8e5ff0ef          	jal	ra,80000f6c <walkaddr>
    if(pa0 == 0) {
    8000168c:	f569                	bnez	a0,80001656 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000168e:	4601                	li	a2,0
    80001690:	85ce                	mv	a1,s3
    80001692:	855e                	mv	a0,s7
    80001694:	e63ff0ef          	jal	ra,800014f6 <vmfault>
    80001698:	fd5d                	bnez	a0,80001656 <copyin+0x28>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	a011                	j	800016a0 <copyin+0x72>
  return 0;
    8000169e:	4501                	li	a0,0
}
    800016a0:	60a6                	ld	ra,72(sp)
    800016a2:	6406                	ld	s0,64(sp)
    800016a4:	74e2                	ld	s1,56(sp)
    800016a6:	7942                	ld	s2,48(sp)
    800016a8:	79a2                	ld	s3,40(sp)
    800016aa:	7a02                	ld	s4,32(sp)
    800016ac:	6ae2                	ld	s5,24(sp)
    800016ae:	6b42                	ld	s6,16(sp)
    800016b0:	6ba2                	ld	s7,8(sp)
    800016b2:	6c02                	ld	s8,0(sp)
    800016b4:	6161                	addi	sp,sp,80
    800016b6:	8082                	ret
  return 0;
    800016b8:	4501                	li	a0,0
}
    800016ba:	8082                	ret

00000000800016bc <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016bc:	7139                	addi	sp,sp,-64
    800016be:	fc06                	sd	ra,56(sp)
    800016c0:	f822                	sd	s0,48(sp)
    800016c2:	f426                	sd	s1,40(sp)
    800016c4:	f04a                	sd	s2,32(sp)
    800016c6:	ec4e                	sd	s3,24(sp)
    800016c8:	e852                	sd	s4,16(sp)
    800016ca:	e456                	sd	s5,8(sp)
    800016cc:	e05a                	sd	s6,0(sp)
    800016ce:	0080                	addi	s0,sp,64
    800016d0:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d2:	0000e497          	auipc	s1,0xe
    800016d6:	7a648493          	addi	s1,s1,1958 # 8000fe78 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016da:	8b26                	mv	s6,s1
    800016dc:	00006a97          	auipc	s5,0x6
    800016e0:	924a8a93          	addi	s5,s5,-1756 # 80007000 <etext>
    800016e4:	04000937          	lui	s2,0x4000
    800016e8:	197d                	addi	s2,s2,-1
    800016ea:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016ec:	00014a17          	auipc	s4,0x14
    800016f0:	58ca0a13          	addi	s4,s4,1420 # 80015c78 <tickslock>
    char *pa = kalloc();
    800016f4:	bb6ff0ef          	jal	ra,80000aaa <kalloc>
    800016f8:	862a                	mv	a2,a0
    if(pa == 0)
    800016fa:	c121                	beqz	a0,8000173a <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016fc:	416485b3          	sub	a1,s1,s6
    80001700:	858d                	srai	a1,a1,0x3
    80001702:	000ab783          	ld	a5,0(s5)
    80001706:	02f585b3          	mul	a1,a1,a5
    8000170a:	2585                	addiw	a1,a1,1
    8000170c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001710:	4719                	li	a4,6
    80001712:	6685                	lui	a3,0x1
    80001714:	40b905b3          	sub	a1,s2,a1
    80001718:	854e                	mv	a0,s3
    8000171a:	941ff0ef          	jal	ra,8000105a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000171e:	17848493          	addi	s1,s1,376
    80001722:	fd4499e3          	bne	s1,s4,800016f4 <proc_mapstacks+0x38>
  }
}
    80001726:	70e2                	ld	ra,56(sp)
    80001728:	7442                	ld	s0,48(sp)
    8000172a:	74a2                	ld	s1,40(sp)
    8000172c:	7902                	ld	s2,32(sp)
    8000172e:	69e2                	ld	s3,24(sp)
    80001730:	6a42                	ld	s4,16(sp)
    80001732:	6aa2                	ld	s5,8(sp)
    80001734:	6b02                	ld	s6,0(sp)
    80001736:	6121                	addi	sp,sp,64
    80001738:	8082                	ret
      panic("kalloc");
    8000173a:	00006517          	auipc	a0,0x6
    8000173e:	a3650513          	addi	a0,a0,-1482 # 80007170 <digits+0x138>
    80001742:	84eff0ef          	jal	ra,80000790 <panic>

0000000080001746 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001746:	7139                	addi	sp,sp,-64
    80001748:	fc06                	sd	ra,56(sp)
    8000174a:	f822                	sd	s0,48(sp)
    8000174c:	f426                	sd	s1,40(sp)
    8000174e:	f04a                	sd	s2,32(sp)
    80001750:	ec4e                	sd	s3,24(sp)
    80001752:	e852                	sd	s4,16(sp)
    80001754:	e456                	sd	s5,8(sp)
    80001756:	e05a                	sd	s6,0(sp)
    80001758:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000175a:	00006597          	auipc	a1,0x6
    8000175e:	a1e58593          	addi	a1,a1,-1506 # 80007178 <digits+0x140>
    80001762:	0000e517          	auipc	a0,0xe
    80001766:	2d650513          	addi	a0,a0,726 # 8000fa38 <pid_lock>
    8000176a:	b90ff0ef          	jal	ra,80000afa <initlock>
  initlock(&wait_lock, "wait_lock");
    8000176e:	00006597          	auipc	a1,0x6
    80001772:	a1258593          	addi	a1,a1,-1518 # 80007180 <digits+0x148>
    80001776:	0000e517          	auipc	a0,0xe
    8000177a:	2da50513          	addi	a0,a0,730 # 8000fa50 <wait_lock>
    8000177e:	b7cff0ef          	jal	ra,80000afa <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001782:	0000e497          	auipc	s1,0xe
    80001786:	6f648493          	addi	s1,s1,1782 # 8000fe78 <proc>
      initlock(&p->lock, "proc");
    8000178a:	00006b17          	auipc	s6,0x6
    8000178e:	a06b0b13          	addi	s6,s6,-1530 # 80007190 <digits+0x158>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001792:	8aa6                	mv	s5,s1
    80001794:	00006a17          	auipc	s4,0x6
    80001798:	86ca0a13          	addi	s4,s4,-1940 # 80007000 <etext>
    8000179c:	04000937          	lui	s2,0x4000
    800017a0:	197d                	addi	s2,s2,-1
    800017a2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a4:	00014997          	auipc	s3,0x14
    800017a8:	4d498993          	addi	s3,s3,1236 # 80015c78 <tickslock>
      initlock(&p->lock, "proc");
    800017ac:	85da                	mv	a1,s6
    800017ae:	8526                	mv	a0,s1
    800017b0:	b4aff0ef          	jal	ra,80000afa <initlock>
      p->state = UNUSED;
    800017b4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017b8:	415487b3          	sub	a5,s1,s5
    800017bc:	878d                	srai	a5,a5,0x3
    800017be:	000a3703          	ld	a4,0(s4)
    800017c2:	02e787b3          	mul	a5,a5,a4
    800017c6:	2785                	addiw	a5,a5,1
    800017c8:	00d7979b          	slliw	a5,a5,0xd
    800017cc:	40f907b3          	sub	a5,s2,a5
    800017d0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d2:	17848493          	addi	s1,s1,376
    800017d6:	fd349be3          	bne	s1,s3,800017ac <procinit+0x66>
  }
}
    800017da:	70e2                	ld	ra,56(sp)
    800017dc:	7442                	ld	s0,48(sp)
    800017de:	74a2                	ld	s1,40(sp)
    800017e0:	7902                	ld	s2,32(sp)
    800017e2:	69e2                	ld	s3,24(sp)
    800017e4:	6a42                	ld	s4,16(sp)
    800017e6:	6aa2                	ld	s5,8(sp)
    800017e8:	6b02                	ld	s6,0(sp)
    800017ea:	6121                	addi	sp,sp,64
    800017ec:	8082                	ret

00000000800017ee <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017ee:	1141                	addi	sp,sp,-16
    800017f0:	e422                	sd	s0,8(sp)
    800017f2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017f4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017f6:	2501                	sext.w	a0,a0
    800017f8:	6422                	ld	s0,8(sp)
    800017fa:	0141                	addi	sp,sp,16
    800017fc:	8082                	ret

00000000800017fe <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017fe:	1141                	addi	sp,sp,-16
    80001800:	e422                	sd	s0,8(sp)
    80001802:	0800                	addi	s0,sp,16
    80001804:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001806:	2781                	sext.w	a5,a5
    80001808:	079e                	slli	a5,a5,0x7
  return c;
}
    8000180a:	0000e517          	auipc	a0,0xe
    8000180e:	25e50513          	addi	a0,a0,606 # 8000fa68 <cpus>
    80001812:	953e                	add	a0,a0,a5
    80001814:	6422                	ld	s0,8(sp)
    80001816:	0141                	addi	sp,sp,16
    80001818:	8082                	ret

000000008000181a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000181a:	1101                	addi	sp,sp,-32
    8000181c:	ec06                	sd	ra,24(sp)
    8000181e:	e822                	sd	s0,16(sp)
    80001820:	e426                	sd	s1,8(sp)
    80001822:	1000                	addi	s0,sp,32
  push_off();
    80001824:	b16ff0ef          	jal	ra,80000b3a <push_off>
    80001828:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000182a:	2781                	sext.w	a5,a5
    8000182c:	079e                	slli	a5,a5,0x7
    8000182e:	0000e717          	auipc	a4,0xe
    80001832:	20a70713          	addi	a4,a4,522 # 8000fa38 <pid_lock>
    80001836:	97ba                	add	a5,a5,a4
    80001838:	7b84                	ld	s1,48(a5)
  pop_off();
    8000183a:	b84ff0ef          	jal	ra,80000bbe <pop_off>
  return p;
}
    8000183e:	8526                	mv	a0,s1
    80001840:	60e2                	ld	ra,24(sp)
    80001842:	6442                	ld	s0,16(sp)
    80001844:	64a2                	ld	s1,8(sp)
    80001846:	6105                	addi	sp,sp,32
    80001848:	8082                	ret

000000008000184a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000184a:	7179                	addi	sp,sp,-48
    8000184c:	f406                	sd	ra,40(sp)
    8000184e:	f022                	sd	s0,32(sp)
    80001850:	ec26                	sd	s1,24(sp)
    80001852:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001854:	fc7ff0ef          	jal	ra,8000181a <myproc>
    80001858:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000185a:	bb8ff0ef          	jal	ra,80000c12 <release>

  if (first) {
    8000185e:	00006797          	auipc	a5,0x6
    80001862:	0827a783          	lw	a5,130(a5) # 800078e0 <first.1710>
    80001866:	cf8d                	beqz	a5,800018a0 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001868:	4505                	li	a0,1
    8000186a:	673010ef          	jal	ra,800036dc <fsinit>

    first = 0;
    8000186e:	00006797          	auipc	a5,0x6
    80001872:	0607a923          	sw	zero,114(a5) # 800078e0 <first.1710>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001876:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000187a:	00006517          	auipc	a0,0x6
    8000187e:	91e50513          	addi	a0,a0,-1762 # 80007198 <digits+0x160>
    80001882:	fca43823          	sd	a0,-48(s0)
    80001886:	fc043c23          	sd	zero,-40(s0)
    8000188a:	fd040593          	addi	a1,s0,-48
    8000188e:	705020ef          	jal	ra,80004792 <kexec>
    80001892:	6cbc                	ld	a5,88(s1)
    80001894:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001896:	6cbc                	ld	a5,88(s1)
    80001898:	7bb8                	ld	a4,112(a5)
    8000189a:	57fd                	li	a5,-1
    8000189c:	02f70d63          	beq	a4,a5,800018d6 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800018a0:	409000ef          	jal	ra,800024a8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800018a4:	68a8                	ld	a0,80(s1)
    800018a6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800018a8:	04000737          	lui	a4,0x4000
    800018ac:	00004797          	auipc	a5,0x4
    800018b0:	7f078793          	addi	a5,a5,2032 # 8000609c <userret>
    800018b4:	00004697          	auipc	a3,0x4
    800018b8:	74c68693          	addi	a3,a3,1868 # 80006000 <_trampoline>
    800018bc:	8f95                	sub	a5,a5,a3
    800018be:	177d                	addi	a4,a4,-1
    800018c0:	0732                	slli	a4,a4,0xc
    800018c2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018c4:	577d                	li	a4,-1
    800018c6:	177e                	slli	a4,a4,0x3f
    800018c8:	8d59                	or	a0,a0,a4
    800018ca:	9782                	jalr	a5
}
    800018cc:	70a2                	ld	ra,40(sp)
    800018ce:	7402                	ld	s0,32(sp)
    800018d0:	64e2                	ld	s1,24(sp)
    800018d2:	6145                	addi	sp,sp,48
    800018d4:	8082                	ret
      panic("exec");
    800018d6:	00006517          	auipc	a0,0x6
    800018da:	8ca50513          	addi	a0,a0,-1846 # 800071a0 <digits+0x168>
    800018de:	eb3fe0ef          	jal	ra,80000790 <panic>

00000000800018e2 <allocpid>:
{
    800018e2:	1101                	addi	sp,sp,-32
    800018e4:	ec06                	sd	ra,24(sp)
    800018e6:	e822                	sd	s0,16(sp)
    800018e8:	e426                	sd	s1,8(sp)
    800018ea:	e04a                	sd	s2,0(sp)
    800018ec:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018ee:	0000e917          	auipc	s2,0xe
    800018f2:	14a90913          	addi	s2,s2,330 # 8000fa38 <pid_lock>
    800018f6:	854a                	mv	a0,s2
    800018f8:	a82ff0ef          	jal	ra,80000b7a <acquire>
  pid = nextpid;
    800018fc:	00006797          	auipc	a5,0x6
    80001900:	fe878793          	addi	a5,a5,-24 # 800078e4 <nextpid>
    80001904:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001906:	0014871b          	addiw	a4,s1,1
    8000190a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000190c:	854a                	mv	a0,s2
    8000190e:	b04ff0ef          	jal	ra,80000c12 <release>
}
    80001912:	8526                	mv	a0,s1
    80001914:	60e2                	ld	ra,24(sp)
    80001916:	6442                	ld	s0,16(sp)
    80001918:	64a2                	ld	s1,8(sp)
    8000191a:	6902                	ld	s2,0(sp)
    8000191c:	6105                	addi	sp,sp,32
    8000191e:	8082                	ret

0000000080001920 <proc_pagetable>:
{
    80001920:	1101                	addi	sp,sp,-32
    80001922:	ec06                	sd	ra,24(sp)
    80001924:	e822                	sd	s0,16(sp)
    80001926:	e426                	sd	s1,8(sp)
    80001928:	e04a                	sd	s2,0(sp)
    8000192a:	1000                	addi	s0,sp,32
    8000192c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000192e:	823ff0ef          	jal	ra,80001150 <uvmcreate>
    80001932:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001934:	cd05                	beqz	a0,8000196c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001936:	4729                	li	a4,10
    80001938:	00004697          	auipc	a3,0x4
    8000193c:	6c868693          	addi	a3,a3,1736 # 80006000 <_trampoline>
    80001940:	6605                	lui	a2,0x1
    80001942:	040005b7          	lui	a1,0x4000
    80001946:	15fd                	addi	a1,a1,-1
    80001948:	05b2                	slli	a1,a1,0xc
    8000194a:	e60ff0ef          	jal	ra,80000faa <mappages>
    8000194e:	02054663          	bltz	a0,8000197a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001952:	4719                	li	a4,6
    80001954:	05893683          	ld	a3,88(s2)
    80001958:	6605                	lui	a2,0x1
    8000195a:	020005b7          	lui	a1,0x2000
    8000195e:	15fd                	addi	a1,a1,-1
    80001960:	05b6                	slli	a1,a1,0xd
    80001962:	8526                	mv	a0,s1
    80001964:	e46ff0ef          	jal	ra,80000faa <mappages>
    80001968:	00054f63          	bltz	a0,80001986 <proc_pagetable+0x66>
}
    8000196c:	8526                	mv	a0,s1
    8000196e:	60e2                	ld	ra,24(sp)
    80001970:	6442                	ld	s0,16(sp)
    80001972:	64a2                	ld	s1,8(sp)
    80001974:	6902                	ld	s2,0(sp)
    80001976:	6105                	addi	sp,sp,32
    80001978:	8082                	ret
    uvmfree(pagetable, 0);
    8000197a:	4581                	li	a1,0
    8000197c:	8526                	mv	a0,s1
    8000197e:	9b1ff0ef          	jal	ra,8000132e <uvmfree>
    return 0;
    80001982:	4481                	li	s1,0
    80001984:	b7e5                	j	8000196c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001986:	4681                	li	a3,0
    80001988:	4605                	li	a2,1
    8000198a:	040005b7          	lui	a1,0x4000
    8000198e:	15fd                	addi	a1,a1,-1
    80001990:	05b2                	slli	a1,a1,0xc
    80001992:	8526                	mv	a0,s1
    80001994:	fe2ff0ef          	jal	ra,80001176 <uvmunmap>
    uvmfree(pagetable, 0);
    80001998:	4581                	li	a1,0
    8000199a:	8526                	mv	a0,s1
    8000199c:	993ff0ef          	jal	ra,8000132e <uvmfree>
    return 0;
    800019a0:	4481                	li	s1,0
    800019a2:	b7e9                	j	8000196c <proc_pagetable+0x4c>

00000000800019a4 <proc_freepagetable>:
{
    800019a4:	1101                	addi	sp,sp,-32
    800019a6:	ec06                	sd	ra,24(sp)
    800019a8:	e822                	sd	s0,16(sp)
    800019aa:	e426                	sd	s1,8(sp)
    800019ac:	e04a                	sd	s2,0(sp)
    800019ae:	1000                	addi	s0,sp,32
    800019b0:	84aa                	mv	s1,a0
    800019b2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019b4:	4681                	li	a3,0
    800019b6:	4605                	li	a2,1
    800019b8:	040005b7          	lui	a1,0x4000
    800019bc:	15fd                	addi	a1,a1,-1
    800019be:	05b2                	slli	a1,a1,0xc
    800019c0:	fb6ff0ef          	jal	ra,80001176 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019c4:	4681                	li	a3,0
    800019c6:	4605                	li	a2,1
    800019c8:	020005b7          	lui	a1,0x2000
    800019cc:	15fd                	addi	a1,a1,-1
    800019ce:	05b6                	slli	a1,a1,0xd
    800019d0:	8526                	mv	a0,s1
    800019d2:	fa4ff0ef          	jal	ra,80001176 <uvmunmap>
  uvmfree(pagetable, sz);
    800019d6:	85ca                	mv	a1,s2
    800019d8:	8526                	mv	a0,s1
    800019da:	955ff0ef          	jal	ra,8000132e <uvmfree>
}
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6902                	ld	s2,0(sp)
    800019e6:	6105                	addi	sp,sp,32
    800019e8:	8082                	ret

00000000800019ea <freeproc>:
{
    800019ea:	1101                	addi	sp,sp,-32
    800019ec:	ec06                	sd	ra,24(sp)
    800019ee:	e822                	sd	s0,16(sp)
    800019f0:	e426                	sd	s1,8(sp)
    800019f2:	1000                	addi	s0,sp,32
    800019f4:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019f6:	6d28                	ld	a0,88(a0)
    800019f8:	c119                	beqz	a0,800019fe <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019fa:	fd1fe0ef          	jal	ra,800009ca <kfree>
  p->trapframe = 0;
    800019fe:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a02:	68a8                	ld	a0,80(s1)
    80001a04:	c501                	beqz	a0,80001a0c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a06:	64ac                	ld	a1,72(s1)
    80001a08:	f9dff0ef          	jal	ra,800019a4 <proc_freepagetable>
  p->pagetable = 0;
    80001a0c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a10:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a14:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a18:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a1c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a20:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a24:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a28:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a2c:	0004ac23          	sw	zero,24(s1)
}
    80001a30:	60e2                	ld	ra,24(sp)
    80001a32:	6442                	ld	s0,16(sp)
    80001a34:	64a2                	ld	s1,8(sp)
    80001a36:	6105                	addi	sp,sp,32
    80001a38:	8082                	ret

0000000080001a3a <allocproc>:
{
    80001a3a:	1101                	addi	sp,sp,-32
    80001a3c:	ec06                	sd	ra,24(sp)
    80001a3e:	e822                	sd	s0,16(sp)
    80001a40:	e426                	sd	s1,8(sp)
    80001a42:	e04a                	sd	s2,0(sp)
    80001a44:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a46:	0000e497          	auipc	s1,0xe
    80001a4a:	43248493          	addi	s1,s1,1074 # 8000fe78 <proc>
    80001a4e:	00014917          	auipc	s2,0x14
    80001a52:	22a90913          	addi	s2,s2,554 # 80015c78 <tickslock>
    acquire(&p->lock);
    80001a56:	8526                	mv	a0,s1
    80001a58:	922ff0ef          	jal	ra,80000b7a <acquire>
    if(p->state == UNUSED) {
    80001a5c:	4c9c                	lw	a5,24(s1)
    80001a5e:	cb91                	beqz	a5,80001a72 <allocproc+0x38>
      release(&p->lock);
    80001a60:	8526                	mv	a0,s1
    80001a62:	9b0ff0ef          	jal	ra,80000c12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a66:	17848493          	addi	s1,s1,376
    80001a6a:	ff2496e3          	bne	s1,s2,80001a56 <allocproc+0x1c>
  return 0;
    80001a6e:	4481                	li	s1,0
    80001a70:	a0b1                	j	80001abc <allocproc+0x82>
  p->pid = allocpid();
    80001a72:	e71ff0ef          	jal	ra,800018e2 <allocpid>
    80001a76:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a78:	4785                	li	a5,1
    80001a7a:	cc9c                	sw	a5,24(s1)
  p->queue_level = 0;        
    80001a7c:	1604a423          	sw	zero,360(s1)
  p->remaining_ticks = Q0_SLICE;
    80001a80:	478d                	li	a5,3
    80001a82:	16f4a623          	sw	a5,364(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a86:	824ff0ef          	jal	ra,80000aaa <kalloc>
    80001a8a:	892a                	mv	s2,a0
    80001a8c:	eca8                	sd	a0,88(s1)
    80001a8e:	cd15                	beqz	a0,80001aca <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001a90:	8526                	mv	a0,s1
    80001a92:	e8fff0ef          	jal	ra,80001920 <proc_pagetable>
    80001a96:	892a                	mv	s2,a0
    80001a98:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a9a:	c121                	beqz	a0,80001ada <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001a9c:	07000613          	li	a2,112
    80001aa0:	4581                	li	a1,0
    80001aa2:	06048513          	addi	a0,s1,96
    80001aa6:	9a8ff0ef          	jal	ra,80000c4e <memset>
  p->context.ra = (uint64)forkret;
    80001aaa:	00000797          	auipc	a5,0x0
    80001aae:	da078793          	addi	a5,a5,-608 # 8000184a <forkret>
    80001ab2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ab4:	60bc                	ld	a5,64(s1)
    80001ab6:	6705                	lui	a4,0x1
    80001ab8:	97ba                	add	a5,a5,a4
    80001aba:	f4bc                	sd	a5,104(s1)
}
    80001abc:	8526                	mv	a0,s1
    80001abe:	60e2                	ld	ra,24(sp)
    80001ac0:	6442                	ld	s0,16(sp)
    80001ac2:	64a2                	ld	s1,8(sp)
    80001ac4:	6902                	ld	s2,0(sp)
    80001ac6:	6105                	addi	sp,sp,32
    80001ac8:	8082                	ret
    freeproc(p);
    80001aca:	8526                	mv	a0,s1
    80001acc:	f1fff0ef          	jal	ra,800019ea <freeproc>
    release(&p->lock);
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	940ff0ef          	jal	ra,80000c12 <release>
    return 0;
    80001ad6:	84ca                	mv	s1,s2
    80001ad8:	b7d5                	j	80001abc <allocproc+0x82>
    freeproc(p);
    80001ada:	8526                	mv	a0,s1
    80001adc:	f0fff0ef          	jal	ra,800019ea <freeproc>
    release(&p->lock);
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	930ff0ef          	jal	ra,80000c12 <release>
    return 0;
    80001ae6:	84ca                	mv	s1,s2
    80001ae8:	bfd1                	j	80001abc <allocproc+0x82>

0000000080001aea <userinit>:
{
    80001aea:	1101                	addi	sp,sp,-32
    80001aec:	ec06                	sd	ra,24(sp)
    80001aee:	e822                	sd	s0,16(sp)
    80001af0:	e426                	sd	s1,8(sp)
    80001af2:	e04a                	sd	s2,0(sp)
    80001af4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001af6:	f45ff0ef          	jal	ra,80001a3a <allocproc>
    80001afa:	84aa                	mv	s1,a0
  initproc = p;
    80001afc:	00006797          	auipc	a5,0x6
    80001b00:	e2a7ba23          	sd	a0,-460(a5) # 80007930 <initproc>
  p->queue_level = 0;
    80001b04:	16052423          	sw	zero,360(a0)
  p->remaining_ticks = Q0_SLICE;
    80001b08:	490d                	li	s2,3
    80001b0a:	17252623          	sw	s2,364(a0)
  p->cwd = namei("/");
    80001b0e:	00005517          	auipc	a0,0x5
    80001b12:	69a50513          	addi	a0,a0,1690 # 800071a8 <digits+0x170>
    80001b16:	0c4020ef          	jal	ra,80003bda <namei>
    80001b1a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b1e:	0124ac23          	sw	s2,24(s1)
  release(&p->lock);
    80001b22:	8526                	mv	a0,s1
    80001b24:	8eeff0ef          	jal	ra,80000c12 <release>
}
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6902                	ld	s2,0(sp)
    80001b30:	6105                	addi	sp,sp,32
    80001b32:	8082                	ret

0000000080001b34 <growproc>:
{
    80001b34:	1101                	addi	sp,sp,-32
    80001b36:	ec06                	sd	ra,24(sp)
    80001b38:	e822                	sd	s0,16(sp)
    80001b3a:	e426                	sd	s1,8(sp)
    80001b3c:	e04a                	sd	s2,0(sp)
    80001b3e:	1000                	addi	s0,sp,32
    80001b40:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b42:	cd9ff0ef          	jal	ra,8000181a <myproc>
    80001b46:	892a                	mv	s2,a0
  sz = p->sz;
    80001b48:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b4a:	02905963          	blez	s1,80001b7c <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b4e:	00b48633          	add	a2,s1,a1
    80001b52:	020007b7          	lui	a5,0x2000
    80001b56:	17fd                	addi	a5,a5,-1
    80001b58:	07b6                	slli	a5,a5,0xd
    80001b5a:	02c7ea63          	bltu	a5,a2,80001b8e <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b5e:	4691                	li	a3,4
    80001b60:	6928                	ld	a0,80(a0)
    80001b62:	ed4ff0ef          	jal	ra,80001236 <uvmalloc>
    80001b66:	85aa                	mv	a1,a0
    80001b68:	c50d                	beqz	a0,80001b92 <growproc+0x5e>
  p->sz = sz;
    80001b6a:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b6e:	4501                	li	a0,0
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret
  } else if(n < 0){
    80001b7c:	fe04d7e3          	bgez	s1,80001b6a <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b80:	00b48633          	add	a2,s1,a1
    80001b84:	6928                	ld	a0,80(a0)
    80001b86:	e6cff0ef          	jal	ra,800011f2 <uvmdealloc>
    80001b8a:	85aa                	mv	a1,a0
    80001b8c:	bff9                	j	80001b6a <growproc+0x36>
      return -1;
    80001b8e:	557d                	li	a0,-1
    80001b90:	b7c5                	j	80001b70 <growproc+0x3c>
      return -1;
    80001b92:	557d                	li	a0,-1
    80001b94:	bff1                	j	80001b70 <growproc+0x3c>

0000000080001b96 <kfork>:
{
    80001b96:	7139                	addi	sp,sp,-64
    80001b98:	fc06                	sd	ra,56(sp)
    80001b9a:	f822                	sd	s0,48(sp)
    80001b9c:	f426                	sd	s1,40(sp)
    80001b9e:	f04a                	sd	s2,32(sp)
    80001ba0:	ec4e                	sd	s3,24(sp)
    80001ba2:	e852                	sd	s4,16(sp)
    80001ba4:	e456                	sd	s5,8(sp)
    80001ba6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ba8:	c73ff0ef          	jal	ra,8000181a <myproc>
    80001bac:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001bae:	e8dff0ef          	jal	ra,80001a3a <allocproc>
    80001bb2:	0e050a63          	beqz	a0,80001ca6 <kfork+0x110>
    80001bb6:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001bb8:	0489b603          	ld	a2,72(s3)
    80001bbc:	692c                	ld	a1,80(a0)
    80001bbe:	0509b503          	ld	a0,80(s3)
    80001bc2:	f9cff0ef          	jal	ra,8000135e <uvmcopy>
    80001bc6:	04054663          	bltz	a0,80001c12 <kfork+0x7c>
  np->sz = p->sz;
    80001bca:	0489b783          	ld	a5,72(s3)
    80001bce:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    80001bd2:	0589b683          	ld	a3,88(s3)
    80001bd6:	87b6                	mv	a5,a3
    80001bd8:	05893703          	ld	a4,88(s2)
    80001bdc:	12068693          	addi	a3,a3,288
    80001be0:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    80001be4:	6788                	ld	a0,8(a5)
    80001be6:	6b8c                	ld	a1,16(a5)
    80001be8:	6f90                	ld	a2,24(a5)
    80001bea:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001bee:	e708                	sd	a0,8(a4)
    80001bf0:	eb0c                	sd	a1,16(a4)
    80001bf2:	ef10                	sd	a2,24(a4)
    80001bf4:	02078793          	addi	a5,a5,32
    80001bf8:	02070713          	addi	a4,a4,32
    80001bfc:	fed792e3          	bne	a5,a3,80001be0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c00:	05893783          	ld	a5,88(s2)
    80001c04:	0607b823          	sd	zero,112(a5)
    80001c08:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001c0c:	15000a13          	li	s4,336
    80001c10:	a00d                	j	80001c32 <kfork+0x9c>
    freeproc(np);
    80001c12:	854a                	mv	a0,s2
    80001c14:	dd7ff0ef          	jal	ra,800019ea <freeproc>
    release(&np->lock);
    80001c18:	854a                	mv	a0,s2
    80001c1a:	ff9fe0ef          	jal	ra,80000c12 <release>
    return -1;
    80001c1e:	5afd                	li	s5,-1
    80001c20:	a88d                	j	80001c92 <kfork+0xfc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c22:	570020ef          	jal	ra,80004192 <filedup>
    80001c26:	009907b3          	add	a5,s2,s1
    80001c2a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001c2c:	04a1                	addi	s1,s1,8
    80001c2e:	01448763          	beq	s1,s4,80001c3c <kfork+0xa6>
    if(p->ofile[i])
    80001c32:	009987b3          	add	a5,s3,s1
    80001c36:	6388                	ld	a0,0(a5)
    80001c38:	f56d                	bnez	a0,80001c22 <kfork+0x8c>
    80001c3a:	bfcd                	j	80001c2c <kfork+0x96>
  np->cwd = idup(p->cwd);
    80001c3c:	1509b503          	ld	a0,336(s3)
    80001c40:	776010ef          	jal	ra,800033b6 <idup>
    80001c44:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c48:	4641                	li	a2,16
    80001c4a:	15898593          	addi	a1,s3,344
    80001c4e:	15890513          	addi	a0,s2,344
    80001c52:	94aff0ef          	jal	ra,80000d9c <safestrcpy>
  pid = np->pid;
    80001c56:	03092a83          	lw	s5,48(s2)
  np->queue_level = 0;
    80001c5a:	16092423          	sw	zero,360(s2)
  np->remaining_ticks = Q0_SLICE;
    80001c5e:	448d                	li	s1,3
    80001c60:	16992623          	sw	s1,364(s2)
  release(&np->lock);
    80001c64:	854a                	mv	a0,s2
    80001c66:	fadfe0ef          	jal	ra,80000c12 <release>
  acquire(&wait_lock);
    80001c6a:	0000ea17          	auipc	s4,0xe
    80001c6e:	de6a0a13          	addi	s4,s4,-538 # 8000fa50 <wait_lock>
    80001c72:	8552                	mv	a0,s4
    80001c74:	f07fe0ef          	jal	ra,80000b7a <acquire>
  np->parent = p;
    80001c78:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80001c7c:	8552                	mv	a0,s4
    80001c7e:	f95fe0ef          	jal	ra,80000c12 <release>
  acquire(&np->lock);
    80001c82:	854a                	mv	a0,s2
    80001c84:	ef7fe0ef          	jal	ra,80000b7a <acquire>
  np->state = RUNNABLE;
    80001c88:	00992c23          	sw	s1,24(s2)
  release(&np->lock);
    80001c8c:	854a                	mv	a0,s2
    80001c8e:	f85fe0ef          	jal	ra,80000c12 <release>
}
    80001c92:	8556                	mv	a0,s5
    80001c94:	70e2                	ld	ra,56(sp)
    80001c96:	7442                	ld	s0,48(sp)
    80001c98:	74a2                	ld	s1,40(sp)
    80001c9a:	7902                	ld	s2,32(sp)
    80001c9c:	69e2                	ld	s3,24(sp)
    80001c9e:	6a42                	ld	s4,16(sp)
    80001ca0:	6aa2                	ld	s5,8(sp)
    80001ca2:	6121                	addi	sp,sp,64
    80001ca4:	8082                	ret
    return -1;
    80001ca6:	5afd                	li	s5,-1
    80001ca8:	b7ed                	j	80001c92 <kfork+0xfc>

0000000080001caa <scheduler>:
{
    80001caa:	7175                	addi	sp,sp,-144
    80001cac:	e506                	sd	ra,136(sp)
    80001cae:	e122                	sd	s0,128(sp)
    80001cb0:	fca6                	sd	s1,120(sp)
    80001cb2:	f8ca                	sd	s2,112(sp)
    80001cb4:	f4ce                	sd	s3,104(sp)
    80001cb6:	f0d2                	sd	s4,96(sp)
    80001cb8:	ecd6                	sd	s5,88(sp)
    80001cba:	e8da                	sd	s6,80(sp)
    80001cbc:	e4de                	sd	s7,72(sp)
    80001cbe:	e0e2                	sd	s8,64(sp)
    80001cc0:	fc66                	sd	s9,56(sp)
    80001cc2:	f86a                	sd	s10,48(sp)
    80001cc4:	f46e                	sd	s11,40(sp)
    80001cc6:	0900                	addi	s0,sp,144
    80001cc8:	8792                	mv	a5,tp
  int id = r_tp();
    80001cca:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ccc:	00779693          	slli	a3,a5,0x7
    80001cd0:	0000e717          	auipc	a4,0xe
    80001cd4:	d6870713          	addi	a4,a4,-664 # 8000fa38 <pid_lock>
    80001cd8:	9736                	add	a4,a4,a3
    80001cda:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001cde:	0000e717          	auipc	a4,0xe
    80001ce2:	d9270713          	addi	a4,a4,-622 # 8000fa70 <cpus+0x8>
    80001ce6:	9736                	add	a4,a4,a3
    80001ce8:	f8e43023          	sd	a4,-128(s0)
    80001cec:	17800b13          	li	s6,376
        p = &proc[i];
    80001cf0:	0000ea97          	auipc	s5,0xe
    80001cf4:	188a8a93          	addi	s5,s5,392 # 8000fe78 <proc>
          c->proc = p;
    80001cf8:	0000e717          	auipc	a4,0xe
    80001cfc:	d4070713          	addi	a4,a4,-704 # 8000fa38 <pid_lock>
    80001d00:	00d707b3          	add	a5,a4,a3
    80001d04:	f6f43c23          	sd	a5,-136(s0)
    80001d08:	aa25                	j	80001e40 <scheduler+0x196>
      for(p = proc; p < &proc[NPROC]; p++){
    80001d0a:	0000e497          	auipc	s1,0xe
    80001d0e:	16e48493          	addi	s1,s1,366 # 8000fe78 <proc>
          p->remaining_ticks = Q0_SLICE;
    80001d12:	498d                	li	s3,3
      for(p = proc; p < &proc[NPROC]; p++){
    80001d14:	00014917          	auipc	s2,0x14
    80001d18:	f6490913          	addi	s2,s2,-156 # 80015c78 <tickslock>
    80001d1c:	a801                	j	80001d2c <scheduler+0x82>
        release(&p->lock);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	ef3fe0ef          	jal	ra,80000c12 <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80001d24:	17848493          	addi	s1,s1,376
    80001d28:	03248063          	beq	s1,s2,80001d48 <scheduler+0x9e>
        acquire(&p->lock);
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	e4dfe0ef          	jal	ra,80000b7a <acquire>
        if(p->state != UNUSED && p->queue_level > 0){
    80001d32:	4c9c                	lw	a5,24(s1)
    80001d34:	d7ed                	beqz	a5,80001d1e <scheduler+0x74>
    80001d36:	1684a783          	lw	a5,360(s1)
    80001d3a:	fef052e3          	blez	a5,80001d1e <scheduler+0x74>
          p->queue_level = 0;
    80001d3e:	1604a423          	sw	zero,360(s1)
          p->remaining_ticks = Q0_SLICE;
    80001d42:	1734a623          	sw	s3,364(s1)
    80001d46:	bfe1                	j	80001d1e <scheduler+0x74>
      last_global_boost = ticks;
    80001d48:	000da783          	lw	a5,0(s11)
    80001d4c:	00006717          	auipc	a4,0x6
    80001d50:	bef72623          	sw	a5,-1044(a4) # 80007938 <last_global_boost>
    80001d54:	a0d1                	j	80001e18 <scheduler+0x16e>
        release(&p->lock);
    80001d56:	854e                	mv	a0,s3
    80001d58:	ebbfe0ef          	jal	ra,80000c12 <release>
      for(int step = 0; step < NPROC; step++){
    80001d5c:	2905                	addiw	s2,s2,1
    80001d5e:	0d890c63          	beq	s2,s8,80001e36 <scheduler+0x18c>
        int i = (start + step) % NPROC;
    80001d62:	41f9549b          	sraiw	s1,s2,0x1f
    80001d66:	01a4d79b          	srliw	a5,s1,0x1a
    80001d6a:	012784bb          	addw	s1,a5,s2
    80001d6e:	03f4f493          	andi	s1,s1,63
    80001d72:	9c9d                	subw	s1,s1,a5
        p = &proc[i];
    80001d74:	03648a33          	mul	s4,s1,s6
    80001d78:	015a09b3          	add	s3,s4,s5
        acquire(&p->lock);
    80001d7c:	854e                	mv	a0,s3
    80001d7e:	dfdfe0ef          	jal	ra,80000b7a <acquire>
        if(p->state == RUNNABLE && p->queue_level == level){
    80001d82:	0189a783          	lw	a5,24(s3)
    80001d86:	fd7798e3          	bne	a5,s7,80001d56 <scheduler+0xac>
    80001d8a:	1689a783          	lw	a5,360(s3)
    80001d8e:	fd9794e3          	bne	a5,s9,80001d56 <scheduler+0xac>
          rr_idx[level] = (i + 1) % NPROC;
    80001d92:	0014879b          	addiw	a5,s1,1
    80001d96:	41f7d71b          	sraiw	a4,a5,0x1f
    80001d9a:	01a7571b          	srliw	a4,a4,0x1a
    80001d9e:	9fb9                	addw	a5,a5,a4
    80001da0:	03f7f793          	andi	a5,a5,63
    80001da4:	9f99                	subw	a5,a5,a4
    80001da6:	f8843703          	ld	a4,-120(s0)
    80001daa:	c31c                	sw	a5,0(a4)
          printf("[SCHED]  PID %d running in Q%d (remaining ticks: %d), at tick %d\n", p->pid, p->queue_level, p->remaining_ticks, ticks);
    80001dac:	000da703          	lw	a4,0(s11)
    80001db0:	16c9a683          	lw	a3,364(s3)
    80001db4:	8666                	mv	a2,s9
    80001db6:	0309a583          	lw	a1,48(s3)
    80001dba:	00005517          	auipc	a0,0x5
    80001dbe:	3f650513          	addi	a0,a0,1014 # 800071b0 <digits+0x178>
    80001dc2:	f08fe0ef          	jal	ra,800004ca <printf>
          p->state = RUNNING;
    80001dc6:	4791                	li	a5,4
    80001dc8:	00f9ac23          	sw	a5,24(s3)
          c->proc = p;
    80001dcc:	f7843483          	ld	s1,-136(s0)
    80001dd0:	0334b823          	sd	s3,48(s1)
          swtch(&c->context, &p->context);
    80001dd4:	060a0593          	addi	a1,s4,96
    80001dd8:	95d6                	add	a1,a1,s5
    80001dda:	f8043503          	ld	a0,-128(s0)
    80001dde:	624000ef          	jal	ra,80002402 <swtch>
          c->proc = 0;
    80001de2:	0204b823          	sd	zero,48(s1)
          release(&p->lock);
    80001de6:	854e                	mv	a0,s3
    80001de8:	e2bfe0ef          	jal	ra,80000c12 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001df0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001df4:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dfc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dfe:	10079073          	csrw	sstatus,a5
    if(ticks - last_global_boost >= BOOST_PERIOD){
    80001e02:	000da783          	lw	a5,0(s11)
    80001e06:	00006717          	auipc	a4,0x6
    80001e0a:	b3272703          	lw	a4,-1230(a4) # 80007938 <last_global_boost>
    80001e0e:	9f99                	subw	a5,a5,a4
    80001e10:	06300713          	li	a4,99
    80001e14:	eef76be3          	bltu	a4,a5,80001d0a <scheduler+0x60>
    for(int level = 0; level < 3 && !found; level++){
    80001e18:	0000ed17          	auipc	s10,0xe
    80001e1c:	050d0d13          	addi	s10,s10,80 # 8000fe68 <rr_idx>
      for(p = proc; p < &proc[NPROC]; p++){
    80001e20:	4c81                	li	s9,0
        if(p->state == RUNNABLE && p->queue_level == level){
    80001e22:	4b8d                	li	s7,3
    80001e24:	a011                	j	80001e28 <scheduler+0x17e>
    80001e26:	0d11                	addi	s10,s10,4
      int start = rr_idx[level];
    80001e28:	f9a43423          	sd	s10,-120(s0)
      for(int step = 0; step < NPROC; step++){
    80001e2c:	000d2903          	lw	s2,0(s10)
    80001e30:	04090c1b          	addiw	s8,s2,64
    80001e34:	b73d                	j	80001d62 <scheduler+0xb8>
    for(int level = 0; level < 3 && !found; level++){
    80001e36:	2c85                	addiw	s9,s9,1
    80001e38:	ff7c97e3          	bne	s9,s7,80001e26 <scheduler+0x17c>
      asm volatile("wfi");
    80001e3c:	10500073          	wfi
    if(ticks - last_global_boost >= BOOST_PERIOD){
    80001e40:	00006d97          	auipc	s11,0x6
    80001e44:	afcd8d93          	addi	s11,s11,-1284 # 8000793c <ticks>
    80001e48:	b755                	j	80001dec <scheduler+0x142>

0000000080001e4a <sched>:
{
    80001e4a:	7179                	addi	sp,sp,-48
    80001e4c:	f406                	sd	ra,40(sp)
    80001e4e:	f022                	sd	s0,32(sp)
    80001e50:	ec26                	sd	s1,24(sp)
    80001e52:	e84a                	sd	s2,16(sp)
    80001e54:	e44e                	sd	s3,8(sp)
    80001e56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e58:	9c3ff0ef          	jal	ra,8000181a <myproc>
    80001e5c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e5e:	cb3fe0ef          	jal	ra,80000b10 <holding>
    80001e62:	c92d                	beqz	a0,80001ed4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e64:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e66:	2781                	sext.w	a5,a5
    80001e68:	079e                	slli	a5,a5,0x7
    80001e6a:	0000e717          	auipc	a4,0xe
    80001e6e:	bce70713          	addi	a4,a4,-1074 # 8000fa38 <pid_lock>
    80001e72:	97ba                	add	a5,a5,a4
    80001e74:	0a87a703          	lw	a4,168(a5)
    80001e78:	4785                	li	a5,1
    80001e7a:	06f71363          	bne	a4,a5,80001ee0 <sched+0x96>
  if(p->state == RUNNING)
    80001e7e:	4c98                	lw	a4,24(s1)
    80001e80:	4791                	li	a5,4
    80001e82:	06f70563          	beq	a4,a5,80001eec <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e8c:	e7b5                	bnez	a5,80001ef8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e8e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e90:	0000e917          	auipc	s2,0xe
    80001e94:	ba890913          	addi	s2,s2,-1112 # 8000fa38 <pid_lock>
    80001e98:	2781                	sext.w	a5,a5
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	97ca                	add	a5,a5,s2
    80001e9e:	0ac7a983          	lw	s3,172(a5)
    80001ea2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ea4:	2781                	sext.w	a5,a5
    80001ea6:	079e                	slli	a5,a5,0x7
    80001ea8:	0000e597          	auipc	a1,0xe
    80001eac:	bc858593          	addi	a1,a1,-1080 # 8000fa70 <cpus+0x8>
    80001eb0:	95be                	add	a1,a1,a5
    80001eb2:	06048513          	addi	a0,s1,96
    80001eb6:	54c000ef          	jal	ra,80002402 <swtch>
    80001eba:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ebc:	2781                	sext.w	a5,a5
    80001ebe:	079e                	slli	a5,a5,0x7
    80001ec0:	97ca                	add	a5,a5,s2
    80001ec2:	0b37a623          	sw	s3,172(a5)
}
    80001ec6:	70a2                	ld	ra,40(sp)
    80001ec8:	7402                	ld	s0,32(sp)
    80001eca:	64e2                	ld	s1,24(sp)
    80001ecc:	6942                	ld	s2,16(sp)
    80001ece:	69a2                	ld	s3,8(sp)
    80001ed0:	6145                	addi	sp,sp,48
    80001ed2:	8082                	ret
    panic("sched p->lock");
    80001ed4:	00005517          	auipc	a0,0x5
    80001ed8:	32450513          	addi	a0,a0,804 # 800071f8 <digits+0x1c0>
    80001edc:	8b5fe0ef          	jal	ra,80000790 <panic>
    panic("sched locks");
    80001ee0:	00005517          	auipc	a0,0x5
    80001ee4:	32850513          	addi	a0,a0,808 # 80007208 <digits+0x1d0>
    80001ee8:	8a9fe0ef          	jal	ra,80000790 <panic>
    panic("sched RUNNING");
    80001eec:	00005517          	auipc	a0,0x5
    80001ef0:	32c50513          	addi	a0,a0,812 # 80007218 <digits+0x1e0>
    80001ef4:	89dfe0ef          	jal	ra,80000790 <panic>
    panic("sched interruptible");
    80001ef8:	00005517          	auipc	a0,0x5
    80001efc:	33050513          	addi	a0,a0,816 # 80007228 <digits+0x1f0>
    80001f00:	891fe0ef          	jal	ra,80000790 <panic>

0000000080001f04 <yield>:
{
    80001f04:	1101                	addi	sp,sp,-32
    80001f06:	ec06                	sd	ra,24(sp)
    80001f08:	e822                	sd	s0,16(sp)
    80001f0a:	e426                	sd	s1,8(sp)
    80001f0c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f0e:	90dff0ef          	jal	ra,8000181a <myproc>
    80001f12:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f14:	c67fe0ef          	jal	ra,80000b7a <acquire>
  p->state = RUNNABLE;
    80001f18:	478d                	li	a5,3
    80001f1a:	cc9c                	sw	a5,24(s1)
  sched();
    80001f1c:	f2fff0ef          	jal	ra,80001e4a <sched>
  release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	cf1fe0ef          	jal	ra,80000c12 <release>
}
    80001f26:	60e2                	ld	ra,24(sp)
    80001f28:	6442                	ld	s0,16(sp)
    80001f2a:	64a2                	ld	s1,8(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret

0000000080001f30 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f30:	7179                	addi	sp,sp,-48
    80001f32:	f406                	sd	ra,40(sp)
    80001f34:	f022                	sd	s0,32(sp)
    80001f36:	ec26                	sd	s1,24(sp)
    80001f38:	e84a                	sd	s2,16(sp)
    80001f3a:	e44e                	sd	s3,8(sp)
    80001f3c:	1800                	addi	s0,sp,48
    80001f3e:	89aa                	mv	s3,a0
    80001f40:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f42:	8d9ff0ef          	jal	ra,8000181a <myproc>
    80001f46:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f48:	c33fe0ef          	jal	ra,80000b7a <acquire>
  release(lk);
    80001f4c:	854a                	mv	a0,s2
    80001f4e:	cc5fe0ef          	jal	ra,80000c12 <release>

  // Go to sleep.
  p->chan = chan;
    80001f52:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f56:	4789                	li	a5,2
    80001f58:	cc9c                	sw	a5,24(s1)

  sched();
    80001f5a:	ef1ff0ef          	jal	ra,80001e4a <sched>

  // Tidy up.
  p->chan = 0;
    80001f5e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	caffe0ef          	jal	ra,80000c12 <release>
  acquire(lk);
    80001f68:	854a                	mv	a0,s2
    80001f6a:	c11fe0ef          	jal	ra,80000b7a <acquire>
}
    80001f6e:	70a2                	ld	ra,40(sp)
    80001f70:	7402                	ld	s0,32(sp)
    80001f72:	64e2                	ld	s1,24(sp)
    80001f74:	6942                	ld	s2,16(sp)
    80001f76:	69a2                	ld	s3,8(sp)
    80001f78:	6145                	addi	sp,sp,48
    80001f7a:	8082                	ret

0000000080001f7c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f7c:	711d                	addi	sp,sp,-96
    80001f7e:	ec86                	sd	ra,88(sp)
    80001f80:	e8a2                	sd	s0,80(sp)
    80001f82:	e4a6                	sd	s1,72(sp)
    80001f84:	e0ca                	sd	s2,64(sp)
    80001f86:	fc4e                	sd	s3,56(sp)
    80001f88:	f852                	sd	s4,48(sp)
    80001f8a:	f456                	sd	s5,40(sp)
    80001f8c:	f05a                	sd	s6,32(sp)
    80001f8e:	ec5e                	sd	s7,24(sp)
    80001f90:	e862                	sd	s8,16(sp)
    80001f92:	e466                	sd	s9,8(sp)
    80001f94:	e06a                	sd	s10,0(sp)
    80001f96:	1080                	addi	s0,sp,96
    80001f98:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f9a:	0000e497          	auipc	s1,0xe
    80001f9e:	ede48493          	addi	s1,s1,-290 # 8000fe78 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fa2:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fa4:	4b8d                	li	s7,3
  if(lv == 0) return Q0_SLICE;
    80001fa6:	4b0d                	li	s6,3
        //Modified: IO wake up to previous queue
        p->remaining_ticks = slice_of_level(p->queue_level);
        printf("[WAKEUP] PID %d returns to Q%d (I/O completed)\n", p->pid, p->queue_level);
    80001fa8:	00005a97          	auipc	s5,0x5
    80001fac:	298a8a93          	addi	s5,s5,664 # 80007240 <digits+0x208>
  if(lv == 1) return Q1_SLICE;
    80001fb0:	4c85                	li	s9,1
  return Q2_SLICE;
    80001fb2:	4c31                	li	s8,12
  if(lv == 1) return Q1_SLICE;
    80001fb4:	4d19                	li	s10,6
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fb6:	00014917          	auipc	s2,0x14
    80001fba:	cc290913          	addi	s2,s2,-830 # 80015c78 <tickslock>
    80001fbe:	a831                	j	80001fda <wakeup+0x5e>
        p->remaining_ticks = slice_of_level(p->queue_level);
    80001fc0:	16f4a623          	sw	a5,364(s1)
        printf("[WAKEUP] PID %d returns to Q%d (I/O completed)\n", p->pid, p->queue_level);
    80001fc4:	588c                	lw	a1,48(s1)
    80001fc6:	8556                	mv	a0,s5
    80001fc8:	d02fe0ef          	jal	ra,800004ca <printf>
      }
      release(&p->lock);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	c45fe0ef          	jal	ra,80000c12 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	17848493          	addi	s1,s1,376
    80001fd6:	03248a63          	beq	s1,s2,8000200a <wakeup+0x8e>
    if(p != myproc()){
    80001fda:	841ff0ef          	jal	ra,8000181a <myproc>
    80001fde:	fea48ae3          	beq	s1,a0,80001fd2 <wakeup+0x56>
      acquire(&p->lock);
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	b97fe0ef          	jal	ra,80000b7a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fe8:	4c9c                	lw	a5,24(s1)
    80001fea:	ff3791e3          	bne	a5,s3,80001fcc <wakeup+0x50>
    80001fee:	709c                	ld	a5,32(s1)
    80001ff0:	fd479ee3          	bne	a5,s4,80001fcc <wakeup+0x50>
        p->state = RUNNABLE;
    80001ff4:	0174ac23          	sw	s7,24(s1)
        p->remaining_ticks = slice_of_level(p->queue_level);
    80001ff8:	1684a603          	lw	a2,360(s1)
  if(lv == 0) return Q0_SLICE;
    80001ffc:	87da                	mv	a5,s6
    80001ffe:	d269                	beqz	a2,80001fc0 <wakeup+0x44>
  return Q2_SLICE;
    80002000:	87e2                	mv	a5,s8
  if(lv == 1) return Q1_SLICE;
    80002002:	fb961fe3          	bne	a2,s9,80001fc0 <wakeup+0x44>
    80002006:	87ea                	mv	a5,s10
    80002008:	bf65                	j	80001fc0 <wakeup+0x44>
    }
  }
}
    8000200a:	60e6                	ld	ra,88(sp)
    8000200c:	6446                	ld	s0,80(sp)
    8000200e:	64a6                	ld	s1,72(sp)
    80002010:	6906                	ld	s2,64(sp)
    80002012:	79e2                	ld	s3,56(sp)
    80002014:	7a42                	ld	s4,48(sp)
    80002016:	7aa2                	ld	s5,40(sp)
    80002018:	7b02                	ld	s6,32(sp)
    8000201a:	6be2                	ld	s7,24(sp)
    8000201c:	6c42                	ld	s8,16(sp)
    8000201e:	6ca2                	ld	s9,8(sp)
    80002020:	6d02                	ld	s10,0(sp)
    80002022:	6125                	addi	sp,sp,96
    80002024:	8082                	ret

0000000080002026 <reparent>:
{
    80002026:	7179                	addi	sp,sp,-48
    80002028:	f406                	sd	ra,40(sp)
    8000202a:	f022                	sd	s0,32(sp)
    8000202c:	ec26                	sd	s1,24(sp)
    8000202e:	e84a                	sd	s2,16(sp)
    80002030:	e44e                	sd	s3,8(sp)
    80002032:	e052                	sd	s4,0(sp)
    80002034:	1800                	addi	s0,sp,48
    80002036:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002038:	0000e497          	auipc	s1,0xe
    8000203c:	e4048493          	addi	s1,s1,-448 # 8000fe78 <proc>
      pp->parent = initproc;
    80002040:	00006a17          	auipc	s4,0x6
    80002044:	8f0a0a13          	addi	s4,s4,-1808 # 80007930 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002048:	00014997          	auipc	s3,0x14
    8000204c:	c3098993          	addi	s3,s3,-976 # 80015c78 <tickslock>
    80002050:	a029                	j	8000205a <reparent+0x34>
    80002052:	17848493          	addi	s1,s1,376
    80002056:	01348b63          	beq	s1,s3,8000206c <reparent+0x46>
    if(pp->parent == p){
    8000205a:	7c9c                	ld	a5,56(s1)
    8000205c:	ff279be3          	bne	a5,s2,80002052 <reparent+0x2c>
      pp->parent = initproc;
    80002060:	000a3503          	ld	a0,0(s4)
    80002064:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002066:	f17ff0ef          	jal	ra,80001f7c <wakeup>
    8000206a:	b7e5                	j	80002052 <reparent+0x2c>
}
    8000206c:	70a2                	ld	ra,40(sp)
    8000206e:	7402                	ld	s0,32(sp)
    80002070:	64e2                	ld	s1,24(sp)
    80002072:	6942                	ld	s2,16(sp)
    80002074:	69a2                	ld	s3,8(sp)
    80002076:	6a02                	ld	s4,0(sp)
    80002078:	6145                	addi	sp,sp,48
    8000207a:	8082                	ret

000000008000207c <kexit>:
{
    8000207c:	7179                	addi	sp,sp,-48
    8000207e:	f406                	sd	ra,40(sp)
    80002080:	f022                	sd	s0,32(sp)
    80002082:	ec26                	sd	s1,24(sp)
    80002084:	e84a                	sd	s2,16(sp)
    80002086:	e44e                	sd	s3,8(sp)
    80002088:	e052                	sd	s4,0(sp)
    8000208a:	1800                	addi	s0,sp,48
    8000208c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000208e:	f8cff0ef          	jal	ra,8000181a <myproc>
    80002092:	89aa                	mv	s3,a0
  if(p == initproc)
    80002094:	00006797          	auipc	a5,0x6
    80002098:	89c7b783          	ld	a5,-1892(a5) # 80007930 <initproc>
    8000209c:	0d050493          	addi	s1,a0,208
    800020a0:	15050913          	addi	s2,a0,336
    800020a4:	00a79f63          	bne	a5,a0,800020c2 <kexit+0x46>
    panic("init exiting");
    800020a8:	00005517          	auipc	a0,0x5
    800020ac:	1c850513          	addi	a0,a0,456 # 80007270 <digits+0x238>
    800020b0:	ee0fe0ef          	jal	ra,80000790 <panic>
      fileclose(f);
    800020b4:	124020ef          	jal	ra,800041d8 <fileclose>
      p->ofile[fd] = 0;
    800020b8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020bc:	04a1                	addi	s1,s1,8
    800020be:	01248563          	beq	s1,s2,800020c8 <kexit+0x4c>
    if(p->ofile[fd]){
    800020c2:	6088                	ld	a0,0(s1)
    800020c4:	f965                	bnez	a0,800020b4 <kexit+0x38>
    800020c6:	bfdd                	j	800020bc <kexit+0x40>
  begin_op();
    800020c8:	503010ef          	jal	ra,80003dca <begin_op>
  iput(p->cwd);
    800020cc:	1509b503          	ld	a0,336(s3)
    800020d0:	49a010ef          	jal	ra,8000356a <iput>
  end_op();
    800020d4:	567010ef          	jal	ra,80003e3a <end_op>
  p->cwd = 0;
    800020d8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020dc:	0000e497          	auipc	s1,0xe
    800020e0:	97448493          	addi	s1,s1,-1676 # 8000fa50 <wait_lock>
    800020e4:	8526                	mv	a0,s1
    800020e6:	a95fe0ef          	jal	ra,80000b7a <acquire>
  reparent(p);
    800020ea:	854e                	mv	a0,s3
    800020ec:	f3bff0ef          	jal	ra,80002026 <reparent>
  wakeup(p->parent);
    800020f0:	0389b503          	ld	a0,56(s3)
    800020f4:	e89ff0ef          	jal	ra,80001f7c <wakeup>
  acquire(&p->lock);
    800020f8:	854e                	mv	a0,s3
    800020fa:	a81fe0ef          	jal	ra,80000b7a <acquire>
  p->xstate = status;
    800020fe:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002102:	4795                	li	a5,5
    80002104:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	b09fe0ef          	jal	ra,80000c12 <release>
  sched();
    8000210e:	d3dff0ef          	jal	ra,80001e4a <sched>
  panic("zombie exit");
    80002112:	00005517          	auipc	a0,0x5
    80002116:	16e50513          	addi	a0,a0,366 # 80007280 <digits+0x248>
    8000211a:	e76fe0ef          	jal	ra,80000790 <panic>

000000008000211e <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000211e:	7179                	addi	sp,sp,-48
    80002120:	f406                	sd	ra,40(sp)
    80002122:	f022                	sd	s0,32(sp)
    80002124:	ec26                	sd	s1,24(sp)
    80002126:	e84a                	sd	s2,16(sp)
    80002128:	e44e                	sd	s3,8(sp)
    8000212a:	1800                	addi	s0,sp,48
    8000212c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000212e:	0000e497          	auipc	s1,0xe
    80002132:	d4a48493          	addi	s1,s1,-694 # 8000fe78 <proc>
    80002136:	00014997          	auipc	s3,0x14
    8000213a:	b4298993          	addi	s3,s3,-1214 # 80015c78 <tickslock>
    acquire(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	a3bfe0ef          	jal	ra,80000b7a <acquire>
    if(p->pid == pid){
    80002144:	589c                	lw	a5,48(s1)
    80002146:	01278b63          	beq	a5,s2,8000215c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	ac7fe0ef          	jal	ra,80000c12 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002150:	17848493          	addi	s1,s1,376
    80002154:	ff3495e3          	bne	s1,s3,8000213e <kkill+0x20>
  }
  return -1;
    80002158:	557d                	li	a0,-1
    8000215a:	a819                	j	80002170 <kkill+0x52>
      p->killed = 1;
    8000215c:	4785                	li	a5,1
    8000215e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002160:	4c98                	lw	a4,24(s1)
    80002162:	4789                	li	a5,2
    80002164:	00f70d63          	beq	a4,a5,8000217e <kkill+0x60>
      release(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	aa9fe0ef          	jal	ra,80000c12 <release>
      return 0;
    8000216e:	4501                	li	a0,0
}
    80002170:	70a2                	ld	ra,40(sp)
    80002172:	7402                	ld	s0,32(sp)
    80002174:	64e2                	ld	s1,24(sp)
    80002176:	6942                	ld	s2,16(sp)
    80002178:	69a2                	ld	s3,8(sp)
    8000217a:	6145                	addi	sp,sp,48
    8000217c:	8082                	ret
        p->state = RUNNABLE;
    8000217e:	478d                	li	a5,3
    80002180:	cc9c                	sw	a5,24(s1)
    80002182:	b7dd                	j	80002168 <kkill+0x4a>

0000000080002184 <setkilled>:

void
setkilled(struct proc *p)
{
    80002184:	1101                	addi	sp,sp,-32
    80002186:	ec06                	sd	ra,24(sp)
    80002188:	e822                	sd	s0,16(sp)
    8000218a:	e426                	sd	s1,8(sp)
    8000218c:	1000                	addi	s0,sp,32
    8000218e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002190:	9ebfe0ef          	jal	ra,80000b7a <acquire>
  p->killed = 1;
    80002194:	4785                	li	a5,1
    80002196:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	a79fe0ef          	jal	ra,80000c12 <release>
}
    8000219e:	60e2                	ld	ra,24(sp)
    800021a0:	6442                	ld	s0,16(sp)
    800021a2:	64a2                	ld	s1,8(sp)
    800021a4:	6105                	addi	sp,sp,32
    800021a6:	8082                	ret

00000000800021a8 <killed>:

int
killed(struct proc *p)
{
    800021a8:	1101                	addi	sp,sp,-32
    800021aa:	ec06                	sd	ra,24(sp)
    800021ac:	e822                	sd	s0,16(sp)
    800021ae:	e426                	sd	s1,8(sp)
    800021b0:	e04a                	sd	s2,0(sp)
    800021b2:	1000                	addi	s0,sp,32
    800021b4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800021b6:	9c5fe0ef          	jal	ra,80000b7a <acquire>
  k = p->killed;
    800021ba:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	a53fe0ef          	jal	ra,80000c12 <release>
  return k;
}
    800021c4:	854a                	mv	a0,s2
    800021c6:	60e2                	ld	ra,24(sp)
    800021c8:	6442                	ld	s0,16(sp)
    800021ca:	64a2                	ld	s1,8(sp)
    800021cc:	6902                	ld	s2,0(sp)
    800021ce:	6105                	addi	sp,sp,32
    800021d0:	8082                	ret

00000000800021d2 <kwait>:
{
    800021d2:	715d                	addi	sp,sp,-80
    800021d4:	e486                	sd	ra,72(sp)
    800021d6:	e0a2                	sd	s0,64(sp)
    800021d8:	fc26                	sd	s1,56(sp)
    800021da:	f84a                	sd	s2,48(sp)
    800021dc:	f44e                	sd	s3,40(sp)
    800021de:	f052                	sd	s4,32(sp)
    800021e0:	ec56                	sd	s5,24(sp)
    800021e2:	e85a                	sd	s6,16(sp)
    800021e4:	e45e                	sd	s7,8(sp)
    800021e6:	e062                	sd	s8,0(sp)
    800021e8:	0880                	addi	s0,sp,80
    800021ea:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021ec:	e2eff0ef          	jal	ra,8000181a <myproc>
    800021f0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021f2:	0000e517          	auipc	a0,0xe
    800021f6:	85e50513          	addi	a0,a0,-1954 # 8000fa50 <wait_lock>
    800021fa:	981fe0ef          	jal	ra,80000b7a <acquire>
    havekids = 0;
    800021fe:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002200:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	00014997          	auipc	s3,0x14
    80002206:	a7698993          	addi	s3,s3,-1418 # 80015c78 <tickslock>
        havekids = 1;
    8000220a:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000220c:	0000ec17          	auipc	s8,0xe
    80002210:	844c0c13          	addi	s8,s8,-1980 # 8000fa50 <wait_lock>
    havekids = 0;
    80002214:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002216:	0000e497          	auipc	s1,0xe
    8000221a:	c6248493          	addi	s1,s1,-926 # 8000fe78 <proc>
    8000221e:	a899                	j	80002274 <kwait+0xa2>
          pid = pp->pid;
    80002220:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002224:	000b0c63          	beqz	s6,8000223c <kwait+0x6a>
    80002228:	4691                	li	a3,4
    8000222a:	02c48613          	addi	a2,s1,44
    8000222e:	85da                	mv	a1,s6
    80002230:	05093503          	ld	a0,80(s2)
    80002234:	b34ff0ef          	jal	ra,80001568 <copyout>
    80002238:	00054f63          	bltz	a0,80002256 <kwait+0x84>
          freeproc(pp);
    8000223c:	8526                	mv	a0,s1
    8000223e:	facff0ef          	jal	ra,800019ea <freeproc>
          release(&pp->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	9cffe0ef          	jal	ra,80000c12 <release>
          release(&wait_lock);
    80002248:	0000e517          	auipc	a0,0xe
    8000224c:	80850513          	addi	a0,a0,-2040 # 8000fa50 <wait_lock>
    80002250:	9c3fe0ef          	jal	ra,80000c12 <release>
          return pid;
    80002254:	a891                	j	800022a8 <kwait+0xd6>
            release(&pp->lock);
    80002256:	8526                	mv	a0,s1
    80002258:	9bbfe0ef          	jal	ra,80000c12 <release>
            release(&wait_lock);
    8000225c:	0000d517          	auipc	a0,0xd
    80002260:	7f450513          	addi	a0,a0,2036 # 8000fa50 <wait_lock>
    80002264:	9affe0ef          	jal	ra,80000c12 <release>
            return -1;
    80002268:	59fd                	li	s3,-1
    8000226a:	a83d                	j	800022a8 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226c:	17848493          	addi	s1,s1,376
    80002270:	03348063          	beq	s1,s3,80002290 <kwait+0xbe>
      if(pp->parent == p){
    80002274:	7c9c                	ld	a5,56(s1)
    80002276:	ff279be3          	bne	a5,s2,8000226c <kwait+0x9a>
        acquire(&pp->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	8fffe0ef          	jal	ra,80000b7a <acquire>
        if(pp->state == ZOMBIE){
    80002280:	4c9c                	lw	a5,24(s1)
    80002282:	f9478fe3          	beq	a5,s4,80002220 <kwait+0x4e>
        release(&pp->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	98bfe0ef          	jal	ra,80000c12 <release>
        havekids = 1;
    8000228c:	8756                	mv	a4,s5
    8000228e:	bff9                	j	8000226c <kwait+0x9a>
    if(!havekids || killed(p)){
    80002290:	c709                	beqz	a4,8000229a <kwait+0xc8>
    80002292:	854a                	mv	a0,s2
    80002294:	f15ff0ef          	jal	ra,800021a8 <killed>
    80002298:	c50d                	beqz	a0,800022c2 <kwait+0xf0>
      release(&wait_lock);
    8000229a:	0000d517          	auipc	a0,0xd
    8000229e:	7b650513          	addi	a0,a0,1974 # 8000fa50 <wait_lock>
    800022a2:	971fe0ef          	jal	ra,80000c12 <release>
      return -1;
    800022a6:	59fd                	li	s3,-1
}
    800022a8:	854e                	mv	a0,s3
    800022aa:	60a6                	ld	ra,72(sp)
    800022ac:	6406                	ld	s0,64(sp)
    800022ae:	74e2                	ld	s1,56(sp)
    800022b0:	7942                	ld	s2,48(sp)
    800022b2:	79a2                	ld	s3,40(sp)
    800022b4:	7a02                	ld	s4,32(sp)
    800022b6:	6ae2                	ld	s5,24(sp)
    800022b8:	6b42                	ld	s6,16(sp)
    800022ba:	6ba2                	ld	s7,8(sp)
    800022bc:	6c02                	ld	s8,0(sp)
    800022be:	6161                	addi	sp,sp,80
    800022c0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022c2:	85e2                	mv	a1,s8
    800022c4:	854a                	mv	a0,s2
    800022c6:	c6bff0ef          	jal	ra,80001f30 <sleep>
    havekids = 0;
    800022ca:	b7a9                	j	80002214 <kwait+0x42>

00000000800022cc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022cc:	7179                	addi	sp,sp,-48
    800022ce:	f406                	sd	ra,40(sp)
    800022d0:	f022                	sd	s0,32(sp)
    800022d2:	ec26                	sd	s1,24(sp)
    800022d4:	e84a                	sd	s2,16(sp)
    800022d6:	e44e                	sd	s3,8(sp)
    800022d8:	e052                	sd	s4,0(sp)
    800022da:	1800                	addi	s0,sp,48
    800022dc:	84aa                	mv	s1,a0
    800022de:	892e                	mv	s2,a1
    800022e0:	89b2                	mv	s3,a2
    800022e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022e4:	d36ff0ef          	jal	ra,8000181a <myproc>
  if(user_dst){
    800022e8:	cc99                	beqz	s1,80002306 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022ea:	86d2                	mv	a3,s4
    800022ec:	864e                	mv	a2,s3
    800022ee:	85ca                	mv	a1,s2
    800022f0:	6928                	ld	a0,80(a0)
    800022f2:	a76ff0ef          	jal	ra,80001568 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022f6:	70a2                	ld	ra,40(sp)
    800022f8:	7402                	ld	s0,32(sp)
    800022fa:	64e2                	ld	s1,24(sp)
    800022fc:	6942                	ld	s2,16(sp)
    800022fe:	69a2                	ld	s3,8(sp)
    80002300:	6a02                	ld	s4,0(sp)
    80002302:	6145                	addi	sp,sp,48
    80002304:	8082                	ret
    memmove((char *)dst, src, len);
    80002306:	000a061b          	sext.w	a2,s4
    8000230a:	85ce                	mv	a1,s3
    8000230c:	854a                	mv	a0,s2
    8000230e:	9a1fe0ef          	jal	ra,80000cae <memmove>
    return 0;
    80002312:	8526                	mv	a0,s1
    80002314:	b7cd                	j	800022f6 <either_copyout+0x2a>

0000000080002316 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	e052                	sd	s4,0(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
    80002328:	84ae                	mv	s1,a1
    8000232a:	89b2                	mv	s3,a2
    8000232c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000232e:	cecff0ef          	jal	ra,8000181a <myproc>
  if(user_src){
    80002332:	cc99                	beqz	s1,80002350 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002334:	86d2                	mv	a3,s4
    80002336:	864e                	mv	a2,s3
    80002338:	85ca                	mv	a1,s2
    8000233a:	6928                	ld	a0,80(a0)
    8000233c:	af2ff0ef          	jal	ra,8000162e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002340:	70a2                	ld	ra,40(sp)
    80002342:	7402                	ld	s0,32(sp)
    80002344:	64e2                	ld	s1,24(sp)
    80002346:	6942                	ld	s2,16(sp)
    80002348:	69a2                	ld	s3,8(sp)
    8000234a:	6a02                	ld	s4,0(sp)
    8000234c:	6145                	addi	sp,sp,48
    8000234e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002350:	000a061b          	sext.w	a2,s4
    80002354:	85ce                	mv	a1,s3
    80002356:	854a                	mv	a0,s2
    80002358:	957fe0ef          	jal	ra,80000cae <memmove>
    return 0;
    8000235c:	8526                	mv	a0,s1
    8000235e:	b7cd                	j	80002340 <either_copyin+0x2a>

0000000080002360 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002360:	715d                	addi	sp,sp,-80
    80002362:	e486                	sd	ra,72(sp)
    80002364:	e0a2                	sd	s0,64(sp)
    80002366:	fc26                	sd	s1,56(sp)
    80002368:	f84a                	sd	s2,48(sp)
    8000236a:	f44e                	sd	s3,40(sp)
    8000236c:	f052                	sd	s4,32(sp)
    8000236e:	ec56                	sd	s5,24(sp)
    80002370:	e85a                	sd	s6,16(sp)
    80002372:	e45e                	sd	s7,8(sp)
    80002374:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002376:	00005517          	auipc	a0,0x5
    8000237a:	e7a50513          	addi	a0,a0,-390 # 800071f0 <digits+0x1b8>
    8000237e:	94cfe0ef          	jal	ra,800004ca <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002382:	0000e497          	auipc	s1,0xe
    80002386:	c4e48493          	addi	s1,s1,-946 # 8000ffd0 <proc+0x158>
    8000238a:	00014917          	auipc	s2,0x14
    8000238e:	a4690913          	addi	s2,s2,-1466 # 80015dd0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002392:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002394:	00005997          	auipc	s3,0x5
    80002398:	efc98993          	addi	s3,s3,-260 # 80007290 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    8000239c:	00005a97          	auipc	s5,0x5
    800023a0:	efca8a93          	addi	s5,s5,-260 # 80007298 <digits+0x260>
    printf("\n");
    800023a4:	00005a17          	auipc	s4,0x5
    800023a8:	e4ca0a13          	addi	s4,s4,-436 # 800071f0 <digits+0x1b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ac:	00005b97          	auipc	s7,0x5
    800023b0:	f2cb8b93          	addi	s7,s7,-212 # 800072d8 <states.1760>
    800023b4:	a829                	j	800023ce <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023b6:	ed86a583          	lw	a1,-296(a3)
    800023ba:	8556                	mv	a0,s5
    800023bc:	90efe0ef          	jal	ra,800004ca <printf>
    printf("\n");
    800023c0:	8552                	mv	a0,s4
    800023c2:	908fe0ef          	jal	ra,800004ca <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c6:	17848493          	addi	s1,s1,376
    800023ca:	03248163          	beq	s1,s2,800023ec <procdump+0x8c>
    if(p->state == UNUSED)
    800023ce:	86a6                	mv	a3,s1
    800023d0:	ec04a783          	lw	a5,-320(s1)
    800023d4:	dbed                	beqz	a5,800023c6 <procdump+0x66>
      state = "???";
    800023d6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023d8:	fcfb6fe3          	bltu	s6,a5,800023b6 <procdump+0x56>
    800023dc:	1782                	slli	a5,a5,0x20
    800023de:	9381                	srli	a5,a5,0x20
    800023e0:	078e                	slli	a5,a5,0x3
    800023e2:	97de                	add	a5,a5,s7
    800023e4:	6390                	ld	a2,0(a5)
    800023e6:	fa61                	bnez	a2,800023b6 <procdump+0x56>
      state = "???";
    800023e8:	864e                	mv	a2,s3
    800023ea:	b7f1                	j	800023b6 <procdump+0x56>
  }
}
    800023ec:	60a6                	ld	ra,72(sp)
    800023ee:	6406                	ld	s0,64(sp)
    800023f0:	74e2                	ld	s1,56(sp)
    800023f2:	7942                	ld	s2,48(sp)
    800023f4:	79a2                	ld	s3,40(sp)
    800023f6:	7a02                	ld	s4,32(sp)
    800023f8:	6ae2                	ld	s5,24(sp)
    800023fa:	6b42                	ld	s6,16(sp)
    800023fc:	6ba2                	ld	s7,8(sp)
    800023fe:	6161                	addi	sp,sp,80
    80002400:	8082                	ret

0000000080002402 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002402:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002406:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000240a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000240c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000240e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002412:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002416:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000241a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000241e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002422:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002426:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000242a:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000242e:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002432:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002436:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000243a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000243e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002440:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002442:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002446:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000244a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000244e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002452:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002456:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000245a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000245e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002462:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002466:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000246a:	8082                	ret

000000008000246c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000246c:	1141                	addi	sp,sp,-16
    8000246e:	e406                	sd	ra,8(sp)
    80002470:	e022                	sd	s0,0(sp)
    80002472:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002474:	00005597          	auipc	a1,0x5
    80002478:	e9458593          	addi	a1,a1,-364 # 80007308 <states.1760+0x30>
    8000247c:	00013517          	auipc	a0,0x13
    80002480:	7fc50513          	addi	a0,a0,2044 # 80015c78 <tickslock>
    80002484:	e76fe0ef          	jal	ra,80000afa <initlock>
}
    80002488:	60a2                	ld	ra,8(sp)
    8000248a:	6402                	ld	s0,0(sp)
    8000248c:	0141                	addi	sp,sp,16
    8000248e:	8082                	ret

0000000080002490 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002490:	1141                	addi	sp,sp,-16
    80002492:	e422                	sd	s0,8(sp)
    80002494:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002496:	00003797          	auipc	a5,0x3
    8000249a:	ffa78793          	addi	a5,a5,-6 # 80005490 <kernelvec>
    8000249e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024a2:	6422                	ld	s0,8(sp)
    800024a4:	0141                	addi	sp,sp,16
    800024a6:	8082                	ret

00000000800024a8 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024a8:	1141                	addi	sp,sp,-16
    800024aa:	e406                	sd	ra,8(sp)
    800024ac:	e022                	sd	s0,0(sp)
    800024ae:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024b0:	b6aff0ef          	jal	ra,8000181a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ba:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024be:	04000737          	lui	a4,0x4000
    800024c2:	00004797          	auipc	a5,0x4
    800024c6:	b3e78793          	addi	a5,a5,-1218 # 80006000 <_trampoline>
    800024ca:	00004697          	auipc	a3,0x4
    800024ce:	b3668693          	addi	a3,a3,-1226 # 80006000 <_trampoline>
    800024d2:	8f95                	sub	a5,a5,a3
    800024d4:	177d                	addi	a4,a4,-1
    800024d6:	0732                	slli	a4,a4,0xc
    800024d8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024da:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024de:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024e0:	18002773          	csrr	a4,satp
    800024e4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024e6:	6d38                	ld	a4,88(a0)
    800024e8:	613c                	ld	a5,64(a0)
    800024ea:	6685                	lui	a3,0x1
    800024ec:	97b6                	add	a5,a5,a3
    800024ee:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024f0:	6d3c                	ld	a5,88(a0)
    800024f2:	00000717          	auipc	a4,0x0
    800024f6:	0f470713          	addi	a4,a4,244 # 800025e6 <usertrap>
    800024fa:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024fc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024fe:	8712                	mv	a4,tp
    80002500:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002502:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002506:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000250a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000250e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002512:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002514:	6f9c                	ld	a5,24(a5)
    80002516:	14179073          	csrw	sepc,a5
}
    8000251a:	60a2                	ld	ra,8(sp)
    8000251c:	6402                	ld	s0,0(sp)
    8000251e:	0141                	addi	sp,sp,16
    80002520:	8082                	ret

0000000080002522 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002522:	1101                	addi	sp,sp,-32
    80002524:	ec06                	sd	ra,24(sp)
    80002526:	e822                	sd	s0,16(sp)
    80002528:	e426                	sd	s1,8(sp)
    8000252a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000252c:	ac2ff0ef          	jal	ra,800017ee <cpuid>
    80002530:	cd19                	beqz	a0,8000254e <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002532:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002536:	000f4737          	lui	a4,0xf4
    8000253a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000253e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002540:	14d79073          	csrw	0x14d,a5
}
    80002544:	60e2                	ld	ra,24(sp)
    80002546:	6442                	ld	s0,16(sp)
    80002548:	64a2                	ld	s1,8(sp)
    8000254a:	6105                	addi	sp,sp,32
    8000254c:	8082                	ret
    acquire(&tickslock);
    8000254e:	00013497          	auipc	s1,0x13
    80002552:	72a48493          	addi	s1,s1,1834 # 80015c78 <tickslock>
    80002556:	8526                	mv	a0,s1
    80002558:	e22fe0ef          	jal	ra,80000b7a <acquire>
    ticks++;
    8000255c:	00005517          	auipc	a0,0x5
    80002560:	3e050513          	addi	a0,a0,992 # 8000793c <ticks>
    80002564:	411c                	lw	a5,0(a0)
    80002566:	2785                	addiw	a5,a5,1
    80002568:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000256a:	a13ff0ef          	jal	ra,80001f7c <wakeup>
    release(&tickslock);
    8000256e:	8526                	mv	a0,s1
    80002570:	ea2fe0ef          	jal	ra,80000c12 <release>
    80002574:	bf7d                	j	80002532 <clockintr+0x10>

0000000080002576 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002576:	1101                	addi	sp,sp,-32
    80002578:	ec06                	sd	ra,24(sp)
    8000257a:	e822                	sd	s0,16(sp)
    8000257c:	e426                	sd	s1,8(sp)
    8000257e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002580:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002584:	57fd                	li	a5,-1
    80002586:	17fe                	slli	a5,a5,0x3f
    80002588:	07a5                	addi	a5,a5,9
    8000258a:	00f70d63          	beq	a4,a5,800025a4 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000258e:	57fd                	li	a5,-1
    80002590:	17fe                	slli	a5,a5,0x3f
    80002592:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002594:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002596:	04f70463          	beq	a4,a5,800025de <devintr+0x68>
  }
}
    8000259a:	60e2                	ld	ra,24(sp)
    8000259c:	6442                	ld	s0,16(sp)
    8000259e:	64a2                	ld	s1,8(sp)
    800025a0:	6105                	addi	sp,sp,32
    800025a2:	8082                	ret
    int irq = plic_claim();
    800025a4:	795020ef          	jal	ra,80005538 <plic_claim>
    800025a8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025aa:	47a9                	li	a5,10
    800025ac:	02f50363          	beq	a0,a5,800025d2 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    800025b0:	4785                	li	a5,1
    800025b2:	02f50363          	beq	a0,a5,800025d8 <devintr+0x62>
    return 1;
    800025b6:	4505                	li	a0,1
    } else if(irq){
    800025b8:	d0ed                	beqz	s1,8000259a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    800025ba:	85a6                	mv	a1,s1
    800025bc:	00005517          	auipc	a0,0x5
    800025c0:	d5450513          	addi	a0,a0,-684 # 80007310 <states.1760+0x38>
    800025c4:	f07fd0ef          	jal	ra,800004ca <printf>
      plic_complete(irq);
    800025c8:	8526                	mv	a0,s1
    800025ca:	78f020ef          	jal	ra,80005558 <plic_complete>
    return 1;
    800025ce:	4505                	li	a0,1
    800025d0:	b7e9                	j	8000259a <devintr+0x24>
      uartintr();
    800025d2:	b90fe0ef          	jal	ra,80000962 <uartintr>
    800025d6:	bfcd                	j	800025c8 <devintr+0x52>
      virtio_disk_intr();
    800025d8:	446030ef          	jal	ra,80005a1e <virtio_disk_intr>
    800025dc:	b7f5                	j	800025c8 <devintr+0x52>
    clockintr();
    800025de:	f45ff0ef          	jal	ra,80002522 <clockintr>
    return 2;
    800025e2:	4509                	li	a0,2
    800025e4:	bf5d                	j	8000259a <devintr+0x24>

00000000800025e6 <usertrap>:
{
    800025e6:	1101                	addi	sp,sp,-32
    800025e8:	ec06                	sd	ra,24(sp)
    800025ea:	e822                	sd	s0,16(sp)
    800025ec:	e426                	sd	s1,8(sp)
    800025ee:	e04a                	sd	s2,0(sp)
    800025f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025f2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025f6:	1007f793          	andi	a5,a5,256
    800025fa:	eba5                	bnez	a5,8000266a <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025fc:	00003797          	auipc	a5,0x3
    80002600:	e9478793          	addi	a5,a5,-364 # 80005490 <kernelvec>
    80002604:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002608:	a12ff0ef          	jal	ra,8000181a <myproc>
    8000260c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000260e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002610:	14102773          	csrr	a4,sepc
    80002614:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002616:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000261a:	47a1                	li	a5,8
    8000261c:	04f70d63          	beq	a4,a5,80002676 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002620:	f57ff0ef          	jal	ra,80002576 <devintr>
    80002624:	892a                	mv	s2,a0
    80002626:	e945                	bnez	a0,800026d6 <usertrap+0xf0>
    80002628:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000262c:	47bd                	li	a5,15
    8000262e:	08f70863          	beq	a4,a5,800026be <usertrap+0xd8>
    80002632:	14202773          	csrr	a4,scause
    80002636:	47b5                	li	a5,13
    80002638:	08f70363          	beq	a4,a5,800026be <usertrap+0xd8>
    8000263c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002640:	5890                	lw	a2,48(s1)
    80002642:	00005517          	auipc	a0,0x5
    80002646:	d0e50513          	addi	a0,a0,-754 # 80007350 <states.1760+0x78>
    8000264a:	e81fd0ef          	jal	ra,800004ca <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000264e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002652:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002656:	00005517          	auipc	a0,0x5
    8000265a:	d2a50513          	addi	a0,a0,-726 # 80007380 <states.1760+0xa8>
    8000265e:	e6dfd0ef          	jal	ra,800004ca <printf>
    setkilled(p);
    80002662:	8526                	mv	a0,s1
    80002664:	b21ff0ef          	jal	ra,80002184 <setkilled>
    80002668:	a035                	j	80002694 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000266a:	00005517          	auipc	a0,0x5
    8000266e:	cc650513          	addi	a0,a0,-826 # 80007330 <states.1760+0x58>
    80002672:	91efe0ef          	jal	ra,80000790 <panic>
    if(killed(p))
    80002676:	b33ff0ef          	jal	ra,800021a8 <killed>
    8000267a:	ed15                	bnez	a0,800026b6 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000267c:	6cb8                	ld	a4,88(s1)
    8000267e:	6f1c                	ld	a5,24(a4)
    80002680:	0791                	addi	a5,a5,4
    80002682:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002684:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002688:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268c:	10079073          	csrw	sstatus,a5
    syscall();
    80002690:	324000ef          	jal	ra,800029b4 <syscall>
  if(killed(p))
    80002694:	8526                	mv	a0,s1
    80002696:	b13ff0ef          	jal	ra,800021a8 <killed>
    8000269a:	e139                	bnez	a0,800026e0 <usertrap+0xfa>
  prepare_return();
    8000269c:	e0dff0ef          	jal	ra,800024a8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026a0:	68a8                	ld	a0,80(s1)
    800026a2:	8131                	srli	a0,a0,0xc
    800026a4:	57fd                	li	a5,-1
    800026a6:	17fe                	slli	a5,a5,0x3f
    800026a8:	8d5d                	or	a0,a0,a5
}
    800026aa:	60e2                	ld	ra,24(sp)
    800026ac:	6442                	ld	s0,16(sp)
    800026ae:	64a2                	ld	s1,8(sp)
    800026b0:	6902                	ld	s2,0(sp)
    800026b2:	6105                	addi	sp,sp,32
    800026b4:	8082                	ret
      kexit(-1);
    800026b6:	557d                	li	a0,-1
    800026b8:	9c5ff0ef          	jal	ra,8000207c <kexit>
    800026bc:	b7c1                	j	8000267c <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026be:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026c2:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026c6:	164d                	addi	a2,a2,-13
    800026c8:	00163613          	seqz	a2,a2
    800026cc:	68a8                	ld	a0,80(s1)
    800026ce:	e29fe0ef          	jal	ra,800014f6 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026d2:	f169                	bnez	a0,80002694 <usertrap+0xae>
    800026d4:	b7a5                	j	8000263c <usertrap+0x56>
  if(killed(p))
    800026d6:	8526                	mv	a0,s1
    800026d8:	ad1ff0ef          	jal	ra,800021a8 <killed>
    800026dc:	c511                	beqz	a0,800026e8 <usertrap+0x102>
    800026de:	a011                	j	800026e2 <usertrap+0xfc>
    800026e0:	4901                	li	s2,0
    kexit(-1);
    800026e2:	557d                	li	a0,-1
    800026e4:	999ff0ef          	jal	ra,8000207c <kexit>
  if(which_dev == 2){
    800026e8:	4789                	li	a5,2
    800026ea:	faf919e3          	bne	s2,a5,8000269c <usertrap+0xb6>
    struct proc *p = myproc();  
    800026ee:	92cff0ef          	jal	ra,8000181a <myproc>
    800026f2:	892a                	mv	s2,a0
    if(p){
    800026f4:	d545                	beqz	a0,8000269c <usertrap+0xb6>
      acquire(&p->lock);
    800026f6:	c84fe0ef          	jal	ra,80000b7a <acquire>
      if(p->state == RUNNING){
    800026fa:	01892703          	lw	a4,24(s2)
    800026fe:	4791                	li	a5,4
    80002700:	06f71463          	bne	a4,a5,80002768 <usertrap+0x182>
        if(p->remaining_ticks > 0)
    80002704:	16c92783          	lw	a5,364(s2)
    80002708:	00f05563          	blez	a5,80002712 <usertrap+0x12c>
          p->remaining_ticks--;
    8000270c:	37fd                	addiw	a5,a5,-1
    8000270e:	16f92623          	sw	a5,364(s2)
        if(p->remaining_ticks == 0){
    80002712:	16c92783          	lw	a5,364(s2)
    80002716:	e7a9                	bnez	a5,80002760 <usertrap+0x17a>
          if(p->queue_level < 2)
    80002718:	16892783          	lw	a5,360(s2)
    8000271c:	4705                	li	a4,1
    8000271e:	02f75363          	bge	a4,a5,80002744 <usertrap+0x15e>
          p->remaining_ticks = slice_of_level(p->queue_level);
    80002722:	16892703          	lw	a4,360(s2)
  return (lv == 0) ? Q0_SLICE : (lv == 1) ? Q1_SLICE : Q2_SLICE;
    80002726:	478d                	li	a5,3
    80002728:	c711                	beqz	a4,80002734 <usertrap+0x14e>
    8000272a:	4685                	li	a3,1
    8000272c:	4799                	li	a5,6
    8000272e:	00d70363          	beq	a4,a3,80002734 <usertrap+0x14e>
    80002732:	47b1                	li	a5,12
          p->remaining_ticks = slice_of_level(p->queue_level);
    80002734:	16f92623          	sw	a5,364(s2)
          release(&p->lock);
    80002738:	854a                	mv	a0,s2
    8000273a:	cd8fe0ef          	jal	ra,80000c12 <release>
          yield();   
    8000273e:	fc6ff0ef          	jal	ra,80001f04 <yield>
    80002742:	bfa9                	j	8000269c <usertrap+0xb6>
            p->queue_level++;
    80002744:	2785                	addiw	a5,a5,1
    80002746:	16f92423          	sw	a5,360(s2)
            printf("[TICK] PID %d time slice expired, demoted to Q%d\n", p->pid, p->queue_level);
    8000274a:	0007861b          	sext.w	a2,a5
    8000274e:	03092583          	lw	a1,48(s2)
    80002752:	00005517          	auipc	a0,0x5
    80002756:	c5650513          	addi	a0,a0,-938 # 800073a8 <states.1760+0xd0>
    8000275a:	d71fd0ef          	jal	ra,800004ca <printf>
    8000275e:	b7d1                	j	80002722 <usertrap+0x13c>
          release(&p->lock);
    80002760:	854a                	mv	a0,s2
    80002762:	cb0fe0ef          	jal	ra,80000c12 <release>
    80002766:	bf1d                	j	8000269c <usertrap+0xb6>
        release(&p->lock);
    80002768:	854a                	mv	a0,s2
    8000276a:	ca8fe0ef          	jal	ra,80000c12 <release>
    8000276e:	b73d                	j	8000269c <usertrap+0xb6>

0000000080002770 <kerneltrap>:
{
    80002770:	7179                	addi	sp,sp,-48
    80002772:	f406                	sd	ra,40(sp)
    80002774:	f022                	sd	s0,32(sp)
    80002776:	ec26                	sd	s1,24(sp)
    80002778:	e84a                	sd	s2,16(sp)
    8000277a:	e44e                	sd	s3,8(sp)
    8000277c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000277e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002782:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002786:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000278a:	1004f793          	andi	a5,s1,256
    8000278e:	c795                	beqz	a5,800027ba <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002790:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002794:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002796:	eb85                	bnez	a5,800027c6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002798:	ddfff0ef          	jal	ra,80002576 <devintr>
    8000279c:	c91d                	beqz	a0,800027d2 <kerneltrap+0x62>
  if(which_dev == 2){
    8000279e:	4789                	li	a5,2
    800027a0:	04f50a63          	beq	a0,a5,800027f4 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027a4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027a8:	10049073          	csrw	sstatus,s1
}
    800027ac:	70a2                	ld	ra,40(sp)
    800027ae:	7402                	ld	s0,32(sp)
    800027b0:	64e2                	ld	s1,24(sp)
    800027b2:	6942                	ld	s2,16(sp)
    800027b4:	69a2                	ld	s3,8(sp)
    800027b6:	6145                	addi	sp,sp,48
    800027b8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027ba:	00005517          	auipc	a0,0x5
    800027be:	c2650513          	addi	a0,a0,-986 # 800073e0 <states.1760+0x108>
    800027c2:	fcffd0ef          	jal	ra,80000790 <panic>
    panic("kerneltrap: interrupts enabled");
    800027c6:	00005517          	auipc	a0,0x5
    800027ca:	c4250513          	addi	a0,a0,-958 # 80007408 <states.1760+0x130>
    800027ce:	fc3fd0ef          	jal	ra,80000790 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027d2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027d6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800027da:	85ce                	mv	a1,s3
    800027dc:	00005517          	auipc	a0,0x5
    800027e0:	c4c50513          	addi	a0,a0,-948 # 80007428 <states.1760+0x150>
    800027e4:	ce7fd0ef          	jal	ra,800004ca <printf>
    panic("kerneltrap");
    800027e8:	00005517          	auipc	a0,0x5
    800027ec:	c6850513          	addi	a0,a0,-920 # 80007450 <states.1760+0x178>
    800027f0:	fa1fd0ef          	jal	ra,80000790 <panic>
    struct proc *p = myproc();
    800027f4:	826ff0ef          	jal	ra,8000181a <myproc>
    800027f8:	89aa                	mv	s3,a0
    if(p){
    800027fa:	d54d                	beqz	a0,800027a4 <kerneltrap+0x34>
      acquire(&p->lock);
    800027fc:	b7efe0ef          	jal	ra,80000b7a <acquire>
      if(p->state == RUNNING){
    80002800:	0189a703          	lw	a4,24(s3)
    80002804:	4791                	li	a5,4
    80002806:	04f71a63          	bne	a4,a5,8000285a <kerneltrap+0xea>
        if(p->remaining_ticks > 0)
    8000280a:	16c9a783          	lw	a5,364(s3)
    8000280e:	00f05563          	blez	a5,80002818 <kerneltrap+0xa8>
          p->remaining_ticks--;
    80002812:	37fd                	addiw	a5,a5,-1
    80002814:	16f9a623          	sw	a5,364(s3)
        if(p->remaining_ticks == 0){
    80002818:	16c9a783          	lw	a5,364(s3)
    8000281c:	eb9d                	bnez	a5,80002852 <kerneltrap+0xe2>
          if(p->queue_level < 2)
    8000281e:	1689a783          	lw	a5,360(s3)
    80002822:	4705                	li	a4,1
    80002824:	02f75363          	bge	a4,a5,8000284a <kerneltrap+0xda>
          p->remaining_ticks = slice_of_level(p->queue_level);
    80002828:	1689a703          	lw	a4,360(s3)
  return (lv == 0) ? Q0_SLICE : (lv == 1) ? Q1_SLICE : Q2_SLICE;
    8000282c:	478d                	li	a5,3
    8000282e:	c711                	beqz	a4,8000283a <kerneltrap+0xca>
    80002830:	4685                	li	a3,1
    80002832:	4799                	li	a5,6
    80002834:	00d70363          	beq	a4,a3,8000283a <kerneltrap+0xca>
    80002838:	47b1                	li	a5,12
          p->remaining_ticks = slice_of_level(p->queue_level);
    8000283a:	16f9a623          	sw	a5,364(s3)
          release(&p->lock);
    8000283e:	854e                	mv	a0,s3
    80002840:	bd2fe0ef          	jal	ra,80000c12 <release>
          yield();
    80002844:	ec0ff0ef          	jal	ra,80001f04 <yield>
    80002848:	bfb1                	j	800027a4 <kerneltrap+0x34>
            p->queue_level++;
    8000284a:	2785                	addiw	a5,a5,1
    8000284c:	16f9a423          	sw	a5,360(s3)
    80002850:	bfe1                	j	80002828 <kerneltrap+0xb8>
          release(&p->lock);
    80002852:	854e                	mv	a0,s3
    80002854:	bbefe0ef          	jal	ra,80000c12 <release>
    80002858:	b7b1                	j	800027a4 <kerneltrap+0x34>
        release(&p->lock);
    8000285a:	854e                	mv	a0,s3
    8000285c:	bb6fe0ef          	jal	ra,80000c12 <release>
    80002860:	b791                	j	800027a4 <kerneltrap+0x34>

0000000080002862 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002862:	1101                	addi	sp,sp,-32
    80002864:	ec06                	sd	ra,24(sp)
    80002866:	e822                	sd	s0,16(sp)
    80002868:	e426                	sd	s1,8(sp)
    8000286a:	1000                	addi	s0,sp,32
    8000286c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000286e:	fadfe0ef          	jal	ra,8000181a <myproc>
  switch (n) {
    80002872:	4795                	li	a5,5
    80002874:	0497e163          	bltu	a5,s1,800028b6 <argraw+0x54>
    80002878:	048a                	slli	s1,s1,0x2
    8000287a:	00005717          	auipc	a4,0x5
    8000287e:	c0e70713          	addi	a4,a4,-1010 # 80007488 <states.1760+0x1b0>
    80002882:	94ba                	add	s1,s1,a4
    80002884:	409c                	lw	a5,0(s1)
    80002886:	97ba                	add	a5,a5,a4
    80002888:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000288a:	6d3c                	ld	a5,88(a0)
    8000288c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6105                	addi	sp,sp,32
    80002896:	8082                	ret
    return p->trapframe->a1;
    80002898:	6d3c                	ld	a5,88(a0)
    8000289a:	7fa8                	ld	a0,120(a5)
    8000289c:	bfcd                	j	8000288e <argraw+0x2c>
    return p->trapframe->a2;
    8000289e:	6d3c                	ld	a5,88(a0)
    800028a0:	63c8                	ld	a0,128(a5)
    800028a2:	b7f5                	j	8000288e <argraw+0x2c>
    return p->trapframe->a3;
    800028a4:	6d3c                	ld	a5,88(a0)
    800028a6:	67c8                	ld	a0,136(a5)
    800028a8:	b7dd                	j	8000288e <argraw+0x2c>
    return p->trapframe->a4;
    800028aa:	6d3c                	ld	a5,88(a0)
    800028ac:	6bc8                	ld	a0,144(a5)
    800028ae:	b7c5                	j	8000288e <argraw+0x2c>
    return p->trapframe->a5;
    800028b0:	6d3c                	ld	a5,88(a0)
    800028b2:	6fc8                	ld	a0,152(a5)
    800028b4:	bfe9                	j	8000288e <argraw+0x2c>
  panic("argraw");
    800028b6:	00005517          	auipc	a0,0x5
    800028ba:	baa50513          	addi	a0,a0,-1110 # 80007460 <states.1760+0x188>
    800028be:	ed3fd0ef          	jal	ra,80000790 <panic>

00000000800028c2 <fetchaddr>:
{
    800028c2:	1101                	addi	sp,sp,-32
    800028c4:	ec06                	sd	ra,24(sp)
    800028c6:	e822                	sd	s0,16(sp)
    800028c8:	e426                	sd	s1,8(sp)
    800028ca:	e04a                	sd	s2,0(sp)
    800028cc:	1000                	addi	s0,sp,32
    800028ce:	84aa                	mv	s1,a0
    800028d0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028d2:	f49fe0ef          	jal	ra,8000181a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028d6:	653c                	ld	a5,72(a0)
    800028d8:	02f4f663          	bgeu	s1,a5,80002904 <fetchaddr+0x42>
    800028dc:	00848713          	addi	a4,s1,8
    800028e0:	02e7e463          	bltu	a5,a4,80002908 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028e4:	46a1                	li	a3,8
    800028e6:	8626                	mv	a2,s1
    800028e8:	85ca                	mv	a1,s2
    800028ea:	6928                	ld	a0,80(a0)
    800028ec:	d43fe0ef          	jal	ra,8000162e <copyin>
    800028f0:	00a03533          	snez	a0,a0
    800028f4:	40a00533          	neg	a0,a0
}
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	64a2                	ld	s1,8(sp)
    800028fe:	6902                	ld	s2,0(sp)
    80002900:	6105                	addi	sp,sp,32
    80002902:	8082                	ret
    return -1;
    80002904:	557d                	li	a0,-1
    80002906:	bfcd                	j	800028f8 <fetchaddr+0x36>
    80002908:	557d                	li	a0,-1
    8000290a:	b7fd                	j	800028f8 <fetchaddr+0x36>

000000008000290c <fetchstr>:
{
    8000290c:	7179                	addi	sp,sp,-48
    8000290e:	f406                	sd	ra,40(sp)
    80002910:	f022                	sd	s0,32(sp)
    80002912:	ec26                	sd	s1,24(sp)
    80002914:	e84a                	sd	s2,16(sp)
    80002916:	e44e                	sd	s3,8(sp)
    80002918:	1800                	addi	s0,sp,48
    8000291a:	892a                	mv	s2,a0
    8000291c:	84ae                	mv	s1,a1
    8000291e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002920:	efbfe0ef          	jal	ra,8000181a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002924:	86ce                	mv	a3,s3
    80002926:	864a                	mv	a2,s2
    80002928:	85a6                	mv	a1,s1
    8000292a:	6928                	ld	a0,80(a0)
    8000292c:	afbfe0ef          	jal	ra,80001426 <copyinstr>
    80002930:	00054c63          	bltz	a0,80002948 <fetchstr+0x3c>
  return strlen(buf);
    80002934:	8526                	mv	a0,s1
    80002936:	c98fe0ef          	jal	ra,80000dce <strlen>
}
    8000293a:	70a2                	ld	ra,40(sp)
    8000293c:	7402                	ld	s0,32(sp)
    8000293e:	64e2                	ld	s1,24(sp)
    80002940:	6942                	ld	s2,16(sp)
    80002942:	69a2                	ld	s3,8(sp)
    80002944:	6145                	addi	sp,sp,48
    80002946:	8082                	ret
    return -1;
    80002948:	557d                	li	a0,-1
    8000294a:	bfc5                	j	8000293a <fetchstr+0x2e>

000000008000294c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	1000                	addi	s0,sp,32
    80002956:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002958:	f0bff0ef          	jal	ra,80002862 <argraw>
    8000295c:	c088                	sw	a0,0(s1)
}
    8000295e:	60e2                	ld	ra,24(sp)
    80002960:	6442                	ld	s0,16(sp)
    80002962:	64a2                	ld	s1,8(sp)
    80002964:	6105                	addi	sp,sp,32
    80002966:	8082                	ret

0000000080002968 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002968:	1101                	addi	sp,sp,-32
    8000296a:	ec06                	sd	ra,24(sp)
    8000296c:	e822                	sd	s0,16(sp)
    8000296e:	e426                	sd	s1,8(sp)
    80002970:	1000                	addi	s0,sp,32
    80002972:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002974:	eefff0ef          	jal	ra,80002862 <argraw>
    80002978:	e088                	sd	a0,0(s1)
}
    8000297a:	60e2                	ld	ra,24(sp)
    8000297c:	6442                	ld	s0,16(sp)
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret

0000000080002984 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002984:	7179                	addi	sp,sp,-48
    80002986:	f406                	sd	ra,40(sp)
    80002988:	f022                	sd	s0,32(sp)
    8000298a:	ec26                	sd	s1,24(sp)
    8000298c:	e84a                	sd	s2,16(sp)
    8000298e:	1800                	addi	s0,sp,48
    80002990:	84ae                	mv	s1,a1
    80002992:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002994:	fd840593          	addi	a1,s0,-40
    80002998:	fd1ff0ef          	jal	ra,80002968 <argaddr>
  return fetchstr(addr, buf, max);
    8000299c:	864a                	mv	a2,s2
    8000299e:	85a6                	mv	a1,s1
    800029a0:	fd843503          	ld	a0,-40(s0)
    800029a4:	f69ff0ef          	jal	ra,8000290c <fetchstr>
}
    800029a8:	70a2                	ld	ra,40(sp)
    800029aa:	7402                	ld	s0,32(sp)
    800029ac:	64e2                	ld	s1,24(sp)
    800029ae:	6942                	ld	s2,16(sp)
    800029b0:	6145                	addi	sp,sp,48
    800029b2:	8082                	ret

00000000800029b4 <syscall>:

};

void
syscall(void)
{
    800029b4:	1101                	addi	sp,sp,-32
    800029b6:	ec06                	sd	ra,24(sp)
    800029b8:	e822                	sd	s0,16(sp)
    800029ba:	e426                	sd	s1,8(sp)
    800029bc:	e04a                	sd	s2,0(sp)
    800029be:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029c0:	e5bfe0ef          	jal	ra,8000181a <myproc>
    800029c4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029c6:	05853903          	ld	s2,88(a0)
    800029ca:	0a893783          	ld	a5,168(s2)
    800029ce:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029d2:	37fd                	addiw	a5,a5,-1
    800029d4:	4759                	li	a4,22
    800029d6:	00f76f63          	bltu	a4,a5,800029f4 <syscall+0x40>
    800029da:	00369713          	slli	a4,a3,0x3
    800029de:	00005797          	auipc	a5,0x5
    800029e2:	ac278793          	addi	a5,a5,-1342 # 800074a0 <syscalls>
    800029e6:	97ba                	add	a5,a5,a4
    800029e8:	639c                	ld	a5,0(a5)
    800029ea:	c789                	beqz	a5,800029f4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029ec:	9782                	jalr	a5
    800029ee:	06a93823          	sd	a0,112(s2)
    800029f2:	a829                	j	80002a0c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029f4:	15848613          	addi	a2,s1,344
    800029f8:	588c                	lw	a1,48(s1)
    800029fa:	00005517          	auipc	a0,0x5
    800029fe:	a6e50513          	addi	a0,a0,-1426 # 80007468 <states.1760+0x190>
    80002a02:	ac9fd0ef          	jal	ra,800004ca <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a06:	6cbc                	ld	a5,88(s1)
    80002a08:	577d                	li	a4,-1
    80002a0a:	fbb8                	sd	a4,112(a5)
  }
}
    80002a0c:	60e2                	ld	ra,24(sp)
    80002a0e:	6442                	ld	s0,16(sp)
    80002a10:	64a2                	ld	s1,8(sp)
    80002a12:	6902                	ld	s2,0(sp)
    80002a14:	6105                	addi	sp,sp,32
    80002a16:	8082                	ret

0000000080002a18 <sys_exit>:

extern struct proc proc[NPROC];

uint64
sys_exit(void)
{
    80002a18:	1101                	addi	sp,sp,-32
    80002a1a:	ec06                	sd	ra,24(sp)
    80002a1c:	e822                	sd	s0,16(sp)
    80002a1e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a20:	fec40593          	addi	a1,s0,-20
    80002a24:	4501                	li	a0,0
    80002a26:	f27ff0ef          	jal	ra,8000294c <argint>
  kexit(n);
    80002a2a:	fec42503          	lw	a0,-20(s0)
    80002a2e:	e4eff0ef          	jal	ra,8000207c <kexit>
  return 0;  // not reached
}
    80002a32:	4501                	li	a0,0
    80002a34:	60e2                	ld	ra,24(sp)
    80002a36:	6442                	ld	s0,16(sp)
    80002a38:	6105                	addi	sp,sp,32
    80002a3a:	8082                	ret

0000000080002a3c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a3c:	1141                	addi	sp,sp,-16
    80002a3e:	e406                	sd	ra,8(sp)
    80002a40:	e022                	sd	s0,0(sp)
    80002a42:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a44:	dd7fe0ef          	jal	ra,8000181a <myproc>
}
    80002a48:	5908                	lw	a0,48(a0)
    80002a4a:	60a2                	ld	ra,8(sp)
    80002a4c:	6402                	ld	s0,0(sp)
    80002a4e:	0141                	addi	sp,sp,16
    80002a50:	8082                	ret

0000000080002a52 <sys_fork>:

uint64
sys_fork(void)
{
    80002a52:	1141                	addi	sp,sp,-16
    80002a54:	e406                	sd	ra,8(sp)
    80002a56:	e022                	sd	s0,0(sp)
    80002a58:	0800                	addi	s0,sp,16
  return kfork();
    80002a5a:	93cff0ef          	jal	ra,80001b96 <kfork>
}
    80002a5e:	60a2                	ld	ra,8(sp)
    80002a60:	6402                	ld	s0,0(sp)
    80002a62:	0141                	addi	sp,sp,16
    80002a64:	8082                	ret

0000000080002a66 <sys_wait>:

uint64
sys_wait(void)
{
    80002a66:	1101                	addi	sp,sp,-32
    80002a68:	ec06                	sd	ra,24(sp)
    80002a6a:	e822                	sd	s0,16(sp)
    80002a6c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a6e:	fe840593          	addi	a1,s0,-24
    80002a72:	4501                	li	a0,0
    80002a74:	ef5ff0ef          	jal	ra,80002968 <argaddr>
  return kwait(p);
    80002a78:	fe843503          	ld	a0,-24(s0)
    80002a7c:	f56ff0ef          	jal	ra,800021d2 <kwait>
}
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	6105                	addi	sp,sp,32
    80002a86:	8082                	ret

0000000080002a88 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a88:	7179                	addi	sp,sp,-48
    80002a8a:	f406                	sd	ra,40(sp)
    80002a8c:	f022                	sd	s0,32(sp)
    80002a8e:	ec26                	sd	s1,24(sp)
    80002a90:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a92:	fd840593          	addi	a1,s0,-40
    80002a96:	4501                	li	a0,0
    80002a98:	eb5ff0ef          	jal	ra,8000294c <argint>
  argint(1, &t);
    80002a9c:	fdc40593          	addi	a1,s0,-36
    80002aa0:	4505                	li	a0,1
    80002aa2:	eabff0ef          	jal	ra,8000294c <argint>
  addr = myproc()->sz;
    80002aa6:	d75fe0ef          	jal	ra,8000181a <myproc>
    80002aaa:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002aac:	fdc42703          	lw	a4,-36(s0)
    80002ab0:	4785                	li	a5,1
    80002ab2:	02f70763          	beq	a4,a5,80002ae0 <sys_sbrk+0x58>
    80002ab6:	fd842783          	lw	a5,-40(s0)
    80002aba:	0207c363          	bltz	a5,80002ae0 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002abe:	97a6                	add	a5,a5,s1
    80002ac0:	0297ee63          	bltu	a5,s1,80002afc <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002ac4:	02000737          	lui	a4,0x2000
    80002ac8:	177d                	addi	a4,a4,-1
    80002aca:	0736                	slli	a4,a4,0xd
    80002acc:	02f76a63          	bltu	a4,a5,80002b00 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002ad0:	d4bfe0ef          	jal	ra,8000181a <myproc>
    80002ad4:	fd842703          	lw	a4,-40(s0)
    80002ad8:	653c                	ld	a5,72(a0)
    80002ada:	97ba                	add	a5,a5,a4
    80002adc:	e53c                	sd	a5,72(a0)
    80002ade:	a039                	j	80002aec <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ae0:	fd842503          	lw	a0,-40(s0)
    80002ae4:	850ff0ef          	jal	ra,80001b34 <growproc>
    80002ae8:	00054863          	bltz	a0,80002af8 <sys_sbrk+0x70>
  }
  return addr;
}
    80002aec:	8526                	mv	a0,s1
    80002aee:	70a2                	ld	ra,40(sp)
    80002af0:	7402                	ld	s0,32(sp)
    80002af2:	64e2                	ld	s1,24(sp)
    80002af4:	6145                	addi	sp,sp,48
    80002af6:	8082                	ret
      return -1;
    80002af8:	54fd                	li	s1,-1
    80002afa:	bfcd                	j	80002aec <sys_sbrk+0x64>
      return -1;
    80002afc:	54fd                	li	s1,-1
    80002afe:	b7fd                	j	80002aec <sys_sbrk+0x64>
      return -1;
    80002b00:	54fd                	li	s1,-1
    80002b02:	b7ed                	j	80002aec <sys_sbrk+0x64>

0000000080002b04 <sys_pause>:

uint64
sys_pause(void)
{
    80002b04:	7139                	addi	sp,sp,-64
    80002b06:	fc06                	sd	ra,56(sp)
    80002b08:	f822                	sd	s0,48(sp)
    80002b0a:	f426                	sd	s1,40(sp)
    80002b0c:	f04a                	sd	s2,32(sp)
    80002b0e:	ec4e                	sd	s3,24(sp)
    80002b10:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b12:	fcc40593          	addi	a1,s0,-52
    80002b16:	4501                	li	a0,0
    80002b18:	e35ff0ef          	jal	ra,8000294c <argint>
  if(n < 0)
    80002b1c:	fcc42783          	lw	a5,-52(s0)
    80002b20:	0607c563          	bltz	a5,80002b8a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b24:	00013517          	auipc	a0,0x13
    80002b28:	15450513          	addi	a0,a0,340 # 80015c78 <tickslock>
    80002b2c:	84efe0ef          	jal	ra,80000b7a <acquire>
  ticks0 = ticks;
    80002b30:	00005917          	auipc	s2,0x5
    80002b34:	e0c92903          	lw	s2,-500(s2) # 8000793c <ticks>
  while(ticks - ticks0 < n){
    80002b38:	fcc42783          	lw	a5,-52(s0)
    80002b3c:	cb8d                	beqz	a5,80002b6e <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b3e:	00013997          	auipc	s3,0x13
    80002b42:	13a98993          	addi	s3,s3,314 # 80015c78 <tickslock>
    80002b46:	00005497          	auipc	s1,0x5
    80002b4a:	df648493          	addi	s1,s1,-522 # 8000793c <ticks>
    if(killed(myproc())){
    80002b4e:	ccdfe0ef          	jal	ra,8000181a <myproc>
    80002b52:	e56ff0ef          	jal	ra,800021a8 <killed>
    80002b56:	ed0d                	bnez	a0,80002b90 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b58:	85ce                	mv	a1,s3
    80002b5a:	8526                	mv	a0,s1
    80002b5c:	bd4ff0ef          	jal	ra,80001f30 <sleep>
  while(ticks - ticks0 < n){
    80002b60:	409c                	lw	a5,0(s1)
    80002b62:	412787bb          	subw	a5,a5,s2
    80002b66:	fcc42703          	lw	a4,-52(s0)
    80002b6a:	fee7e2e3          	bltu	a5,a4,80002b4e <sys_pause+0x4a>
  }
  release(&tickslock);
    80002b6e:	00013517          	auipc	a0,0x13
    80002b72:	10a50513          	addi	a0,a0,266 # 80015c78 <tickslock>
    80002b76:	89cfe0ef          	jal	ra,80000c12 <release>
  return 0;
    80002b7a:	4501                	li	a0,0
}
    80002b7c:	70e2                	ld	ra,56(sp)
    80002b7e:	7442                	ld	s0,48(sp)
    80002b80:	74a2                	ld	s1,40(sp)
    80002b82:	7902                	ld	s2,32(sp)
    80002b84:	69e2                	ld	s3,24(sp)
    80002b86:	6121                	addi	sp,sp,64
    80002b88:	8082                	ret
    n = 0;
    80002b8a:	fc042623          	sw	zero,-52(s0)
    80002b8e:	bf59                	j	80002b24 <sys_pause+0x20>
      release(&tickslock);
    80002b90:	00013517          	auipc	a0,0x13
    80002b94:	0e850513          	addi	a0,a0,232 # 80015c78 <tickslock>
    80002b98:	87afe0ef          	jal	ra,80000c12 <release>
      return -1;
    80002b9c:	557d                	li	a0,-1
    80002b9e:	bff9                	j	80002b7c <sys_pause+0x78>

0000000080002ba0 <sys_kill>:

uint64
sys_kill(void)
{
    80002ba0:	1101                	addi	sp,sp,-32
    80002ba2:	ec06                	sd	ra,24(sp)
    80002ba4:	e822                	sd	s0,16(sp)
    80002ba6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ba8:	fec40593          	addi	a1,s0,-20
    80002bac:	4501                	li	a0,0
    80002bae:	d9fff0ef          	jal	ra,8000294c <argint>
  return kkill(pid);
    80002bb2:	fec42503          	lw	a0,-20(s0)
    80002bb6:	d68ff0ef          	jal	ra,8000211e <kkill>
}
    80002bba:	60e2                	ld	ra,24(sp)
    80002bbc:	6442                	ld	s0,16(sp)
    80002bbe:	6105                	addi	sp,sp,32
    80002bc0:	8082                	ret

0000000080002bc2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bc2:	1101                	addi	sp,sp,-32
    80002bc4:	ec06                	sd	ra,24(sp)
    80002bc6:	e822                	sd	s0,16(sp)
    80002bc8:	e426                	sd	s1,8(sp)
    80002bca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bcc:	00013517          	auipc	a0,0x13
    80002bd0:	0ac50513          	addi	a0,a0,172 # 80015c78 <tickslock>
    80002bd4:	fa7fd0ef          	jal	ra,80000b7a <acquire>
  xticks = ticks;
    80002bd8:	00005497          	auipc	s1,0x5
    80002bdc:	d644a483          	lw	s1,-668(s1) # 8000793c <ticks>
  release(&tickslock);
    80002be0:	00013517          	auipc	a0,0x13
    80002be4:	09850513          	addi	a0,a0,152 # 80015c78 <tickslock>
    80002be8:	82afe0ef          	jal	ra,80000c12 <release>
  return xticks;
}
    80002bec:	02049513          	slli	a0,s1,0x20
    80002bf0:	9101                	srli	a0,a0,0x20
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	64a2                	ld	s1,8(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <sys_getpinfo>:

// the detailed desgin of sys_getpinfo sycall
uint64
sys_getpinfo(void)
{
    80002bfc:	bd010113          	addi	sp,sp,-1072
    80002c00:	42113423          	sd	ra,1064(sp)
    80002c04:	42813023          	sd	s0,1056(sp)
    80002c08:	40913c23          	sd	s1,1048(sp)
    80002c0c:	41213823          	sd	s2,1040(sp)
    80002c10:	43010413          	addi	s0,sp,1072
  uint64 addr;  //user address
  argaddr(0, &addr);
    80002c14:	fd840593          	addi	a1,s0,-40
    80002c18:	4501                	li	a0,0
    80002c1a:	d4fff0ef          	jal	ra,80002968 <argaddr>


  struct pinfo_all info;
  struct proc *p;
  info.nproc = 0;
    80002c1e:	bc042823          	sw	zero,-1072(s0)

  for (p = proc; p < &proc[NPROC]; p++) {
    80002c22:	0000d497          	auipc	s1,0xd
    80002c26:	25648493          	addi	s1,s1,598 # 8000fe78 <proc>
    80002c2a:	00013917          	auipc	s2,0x13
    80002c2e:	04e90913          	addi	s2,s2,78 # 80015c78 <tickslock>
    80002c32:	a801                	j	80002c42 <sys_getpinfo+0x46>
      info.infos[info.nproc].state = p->state;
      info.infos[info.nproc].queue_level = p->queue_level;
      info.infos[info.nproc].remaining_ticks = p->remaining_ticks;
      info.nproc++;
    }
    release(&p->lock);
    80002c34:	8526                	mv	a0,s1
    80002c36:	fddfd0ef          	jal	ra,80000c12 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002c3a:	17848493          	addi	s1,s1,376
    80002c3e:	03248f63          	beq	s1,s2,80002c7c <sys_getpinfo+0x80>
    acquire(&p->lock);
    80002c42:	8526                	mv	a0,s1
    80002c44:	f37fd0ef          	jal	ra,80000b7a <acquire>
    if (p->state != UNUSED) {
    80002c48:	4c94                	lw	a3,24(s1)
    80002c4a:	d6ed                	beqz	a3,80002c34 <sys_getpinfo+0x38>
      info.infos[info.nproc].pid = p->pid;
    80002c4c:	bd042703          	lw	a4,-1072(s0)
    80002c50:	00471793          	slli	a5,a4,0x4
    80002c54:	fe040613          	addi	a2,s0,-32
    80002c58:	97b2                	add	a5,a5,a2
    80002c5a:	5890                	lw	a2,48(s1)
    80002c5c:	bec7aa23          	sw	a2,-1036(a5)
      info.infos[info.nproc].state = p->state;
    80002c60:	bed7ac23          	sw	a3,-1032(a5)
      info.infos[info.nproc].queue_level = p->queue_level;
    80002c64:	1684a683          	lw	a3,360(s1)
    80002c68:	bed7ae23          	sw	a3,-1028(a5)
      info.infos[info.nproc].remaining_ticks = p->remaining_ticks;
    80002c6c:	16c4a683          	lw	a3,364(s1)
    80002c70:	c0d7a023          	sw	a3,-1024(a5)
      info.nproc++;
    80002c74:	2705                	addiw	a4,a4,1
    80002c76:	bce42823          	sw	a4,-1072(s0)
    80002c7a:	bf6d                	j	80002c34 <sys_getpinfo+0x38>
  }

  if (copyout(myproc()->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002c7c:	b9ffe0ef          	jal	ra,8000181a <myproc>
    80002c80:	40400693          	li	a3,1028
    80002c84:	bd040613          	addi	a2,s0,-1072
    80002c88:	fd843583          	ld	a1,-40(s0)
    80002c8c:	6928                	ld	a0,80(a0)
    80002c8e:	8dbfe0ef          	jal	ra,80001568 <copyout>
    80002c92:	00054f63          	bltz	a0,80002cb0 <sys_getpinfo+0xb4>
    return -1;

  return info.nproc;
    80002c96:	bd042503          	lw	a0,-1072(s0)
}
    80002c9a:	42813083          	ld	ra,1064(sp)
    80002c9e:	42013403          	ld	s0,1056(sp)
    80002ca2:	41813483          	ld	s1,1048(sp)
    80002ca6:	41013903          	ld	s2,1040(sp)
    80002caa:	43010113          	addi	sp,sp,1072
    80002cae:	8082                	ret
    return -1;
    80002cb0:	557d                	li	a0,-1
    80002cb2:	b7e5                	j	80002c9a <sys_getpinfo+0x9e>

0000000080002cb4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cb4:	7179                	addi	sp,sp,-48
    80002cb6:	f406                	sd	ra,40(sp)
    80002cb8:	f022                	sd	s0,32(sp)
    80002cba:	ec26                	sd	s1,24(sp)
    80002cbc:	e84a                	sd	s2,16(sp)
    80002cbe:	e44e                	sd	s3,8(sp)
    80002cc0:	e052                	sd	s4,0(sp)
    80002cc2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cc4:	00005597          	auipc	a1,0x5
    80002cc8:	89c58593          	addi	a1,a1,-1892 # 80007560 <syscalls+0xc0>
    80002ccc:	00013517          	auipc	a0,0x13
    80002cd0:	fc450513          	addi	a0,a0,-60 # 80015c90 <bcache>
    80002cd4:	e27fd0ef          	jal	ra,80000afa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cd8:	0001b797          	auipc	a5,0x1b
    80002cdc:	fb878793          	addi	a5,a5,-72 # 8001dc90 <bcache+0x8000>
    80002ce0:	0001b717          	auipc	a4,0x1b
    80002ce4:	21870713          	addi	a4,a4,536 # 8001def8 <bcache+0x8268>
    80002ce8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002cec:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cf0:	00013497          	auipc	s1,0x13
    80002cf4:	fb848493          	addi	s1,s1,-72 # 80015ca8 <bcache+0x18>
    b->next = bcache.head.next;
    80002cf8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002cfa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cfc:	00005a17          	auipc	s4,0x5
    80002d00:	86ca0a13          	addi	s4,s4,-1940 # 80007568 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002d04:	2b893783          	ld	a5,696(s2)
    80002d08:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d0a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d0e:	85d2                	mv	a1,s4
    80002d10:	01048513          	addi	a0,s1,16
    80002d14:	2fe010ef          	jal	ra,80004012 <initsleeplock>
    bcache.head.next->prev = b;
    80002d18:	2b893783          	ld	a5,696(s2)
    80002d1c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d1e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d22:	45848493          	addi	s1,s1,1112
    80002d26:	fd349fe3          	bne	s1,s3,80002d04 <binit+0x50>
  }
}
    80002d2a:	70a2                	ld	ra,40(sp)
    80002d2c:	7402                	ld	s0,32(sp)
    80002d2e:	64e2                	ld	s1,24(sp)
    80002d30:	6942                	ld	s2,16(sp)
    80002d32:	69a2                	ld	s3,8(sp)
    80002d34:	6a02                	ld	s4,0(sp)
    80002d36:	6145                	addi	sp,sp,48
    80002d38:	8082                	ret

0000000080002d3a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d3a:	7179                	addi	sp,sp,-48
    80002d3c:	f406                	sd	ra,40(sp)
    80002d3e:	f022                	sd	s0,32(sp)
    80002d40:	ec26                	sd	s1,24(sp)
    80002d42:	e84a                	sd	s2,16(sp)
    80002d44:	e44e                	sd	s3,8(sp)
    80002d46:	1800                	addi	s0,sp,48
    80002d48:	89aa                	mv	s3,a0
    80002d4a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002d4c:	00013517          	auipc	a0,0x13
    80002d50:	f4450513          	addi	a0,a0,-188 # 80015c90 <bcache>
    80002d54:	e27fd0ef          	jal	ra,80000b7a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d58:	0001b497          	auipc	s1,0x1b
    80002d5c:	1f04b483          	ld	s1,496(s1) # 8001df48 <bcache+0x82b8>
    80002d60:	0001b797          	auipc	a5,0x1b
    80002d64:	19878793          	addi	a5,a5,408 # 8001def8 <bcache+0x8268>
    80002d68:	02f48b63          	beq	s1,a5,80002d9e <bread+0x64>
    80002d6c:	873e                	mv	a4,a5
    80002d6e:	a021                	j	80002d76 <bread+0x3c>
    80002d70:	68a4                	ld	s1,80(s1)
    80002d72:	02e48663          	beq	s1,a4,80002d9e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d76:	449c                	lw	a5,8(s1)
    80002d78:	ff379ce3          	bne	a5,s3,80002d70 <bread+0x36>
    80002d7c:	44dc                	lw	a5,12(s1)
    80002d7e:	ff2799e3          	bne	a5,s2,80002d70 <bread+0x36>
      b->refcnt++;
    80002d82:	40bc                	lw	a5,64(s1)
    80002d84:	2785                	addiw	a5,a5,1
    80002d86:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d88:	00013517          	auipc	a0,0x13
    80002d8c:	f0850513          	addi	a0,a0,-248 # 80015c90 <bcache>
    80002d90:	e83fd0ef          	jal	ra,80000c12 <release>
      acquiresleep(&b->lock);
    80002d94:	01048513          	addi	a0,s1,16
    80002d98:	2b0010ef          	jal	ra,80004048 <acquiresleep>
      return b;
    80002d9c:	a889                	j	80002dee <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d9e:	0001b497          	auipc	s1,0x1b
    80002da2:	1a24b483          	ld	s1,418(s1) # 8001df40 <bcache+0x82b0>
    80002da6:	0001b797          	auipc	a5,0x1b
    80002daa:	15278793          	addi	a5,a5,338 # 8001def8 <bcache+0x8268>
    80002dae:	00f48863          	beq	s1,a5,80002dbe <bread+0x84>
    80002db2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002db4:	40bc                	lw	a5,64(s1)
    80002db6:	cb91                	beqz	a5,80002dca <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002db8:	64a4                	ld	s1,72(s1)
    80002dba:	fee49de3          	bne	s1,a4,80002db4 <bread+0x7a>
  panic("bget: no buffers");
    80002dbe:	00004517          	auipc	a0,0x4
    80002dc2:	7b250513          	addi	a0,a0,1970 # 80007570 <syscalls+0xd0>
    80002dc6:	9cbfd0ef          	jal	ra,80000790 <panic>
      b->dev = dev;
    80002dca:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002dce:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002dd2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002dd6:	4785                	li	a5,1
    80002dd8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002dda:	00013517          	auipc	a0,0x13
    80002dde:	eb650513          	addi	a0,a0,-330 # 80015c90 <bcache>
    80002de2:	e31fd0ef          	jal	ra,80000c12 <release>
      acquiresleep(&b->lock);
    80002de6:	01048513          	addi	a0,s1,16
    80002dea:	25e010ef          	jal	ra,80004048 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002dee:	409c                	lw	a5,0(s1)
    80002df0:	cb89                	beqz	a5,80002e02 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002df2:	8526                	mv	a0,s1
    80002df4:	70a2                	ld	ra,40(sp)
    80002df6:	7402                	ld	s0,32(sp)
    80002df8:	64e2                	ld	s1,24(sp)
    80002dfa:	6942                	ld	s2,16(sp)
    80002dfc:	69a2                	ld	s3,8(sp)
    80002dfe:	6145                	addi	sp,sp,48
    80002e00:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e02:	4581                	li	a1,0
    80002e04:	8526                	mv	a0,s1
    80002e06:	1ab020ef          	jal	ra,800057b0 <virtio_disk_rw>
    b->valid = 1;
    80002e0a:	4785                	li	a5,1
    80002e0c:	c09c                	sw	a5,0(s1)
  return b;
    80002e0e:	b7d5                	j	80002df2 <bread+0xb8>

0000000080002e10 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e10:	1101                	addi	sp,sp,-32
    80002e12:	ec06                	sd	ra,24(sp)
    80002e14:	e822                	sd	s0,16(sp)
    80002e16:	e426                	sd	s1,8(sp)
    80002e18:	1000                	addi	s0,sp,32
    80002e1a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e1c:	0541                	addi	a0,a0,16
    80002e1e:	2a8010ef          	jal	ra,800040c6 <holdingsleep>
    80002e22:	c911                	beqz	a0,80002e36 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e24:	4585                	li	a1,1
    80002e26:	8526                	mv	a0,s1
    80002e28:	189020ef          	jal	ra,800057b0 <virtio_disk_rw>
}
    80002e2c:	60e2                	ld	ra,24(sp)
    80002e2e:	6442                	ld	s0,16(sp)
    80002e30:	64a2                	ld	s1,8(sp)
    80002e32:	6105                	addi	sp,sp,32
    80002e34:	8082                	ret
    panic("bwrite");
    80002e36:	00004517          	auipc	a0,0x4
    80002e3a:	75250513          	addi	a0,a0,1874 # 80007588 <syscalls+0xe8>
    80002e3e:	953fd0ef          	jal	ra,80000790 <panic>

0000000080002e42 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	e04a                	sd	s2,0(sp)
    80002e4c:	1000                	addi	s0,sp,32
    80002e4e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e50:	01050913          	addi	s2,a0,16
    80002e54:	854a                	mv	a0,s2
    80002e56:	270010ef          	jal	ra,800040c6 <holdingsleep>
    80002e5a:	c13d                	beqz	a0,80002ec0 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002e5c:	854a                	mv	a0,s2
    80002e5e:	230010ef          	jal	ra,8000408e <releasesleep>

  acquire(&bcache.lock);
    80002e62:	00013517          	auipc	a0,0x13
    80002e66:	e2e50513          	addi	a0,a0,-466 # 80015c90 <bcache>
    80002e6a:	d11fd0ef          	jal	ra,80000b7a <acquire>
  b->refcnt--;
    80002e6e:	40bc                	lw	a5,64(s1)
    80002e70:	37fd                	addiw	a5,a5,-1
    80002e72:	0007871b          	sext.w	a4,a5
    80002e76:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e78:	eb05                	bnez	a4,80002ea8 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e7a:	68bc                	ld	a5,80(s1)
    80002e7c:	64b8                	ld	a4,72(s1)
    80002e7e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002e80:	64bc                	ld	a5,72(s1)
    80002e82:	68b8                	ld	a4,80(s1)
    80002e84:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e86:	0001b797          	auipc	a5,0x1b
    80002e8a:	e0a78793          	addi	a5,a5,-502 # 8001dc90 <bcache+0x8000>
    80002e8e:	2b87b703          	ld	a4,696(a5)
    80002e92:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e94:	0001b717          	auipc	a4,0x1b
    80002e98:	06470713          	addi	a4,a4,100 # 8001def8 <bcache+0x8268>
    80002e9c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e9e:	2b87b703          	ld	a4,696(a5)
    80002ea2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ea4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ea8:	00013517          	auipc	a0,0x13
    80002eac:	de850513          	addi	a0,a0,-536 # 80015c90 <bcache>
    80002eb0:	d63fd0ef          	jal	ra,80000c12 <release>
}
    80002eb4:	60e2                	ld	ra,24(sp)
    80002eb6:	6442                	ld	s0,16(sp)
    80002eb8:	64a2                	ld	s1,8(sp)
    80002eba:	6902                	ld	s2,0(sp)
    80002ebc:	6105                	addi	sp,sp,32
    80002ebe:	8082                	ret
    panic("brelse");
    80002ec0:	00004517          	auipc	a0,0x4
    80002ec4:	6d050513          	addi	a0,a0,1744 # 80007590 <syscalls+0xf0>
    80002ec8:	8c9fd0ef          	jal	ra,80000790 <panic>

0000000080002ecc <bpin>:

void
bpin(struct buf *b) {
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	e426                	sd	s1,8(sp)
    80002ed4:	1000                	addi	s0,sp,32
    80002ed6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ed8:	00013517          	auipc	a0,0x13
    80002edc:	db850513          	addi	a0,a0,-584 # 80015c90 <bcache>
    80002ee0:	c9bfd0ef          	jal	ra,80000b7a <acquire>
  b->refcnt++;
    80002ee4:	40bc                	lw	a5,64(s1)
    80002ee6:	2785                	addiw	a5,a5,1
    80002ee8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002eea:	00013517          	auipc	a0,0x13
    80002eee:	da650513          	addi	a0,a0,-602 # 80015c90 <bcache>
    80002ef2:	d21fd0ef          	jal	ra,80000c12 <release>
}
    80002ef6:	60e2                	ld	ra,24(sp)
    80002ef8:	6442                	ld	s0,16(sp)
    80002efa:	64a2                	ld	s1,8(sp)
    80002efc:	6105                	addi	sp,sp,32
    80002efe:	8082                	ret

0000000080002f00 <bunpin>:

void
bunpin(struct buf *b) {
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f0c:	00013517          	auipc	a0,0x13
    80002f10:	d8450513          	addi	a0,a0,-636 # 80015c90 <bcache>
    80002f14:	c67fd0ef          	jal	ra,80000b7a <acquire>
  b->refcnt--;
    80002f18:	40bc                	lw	a5,64(s1)
    80002f1a:	37fd                	addiw	a5,a5,-1
    80002f1c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f1e:	00013517          	auipc	a0,0x13
    80002f22:	d7250513          	addi	a0,a0,-654 # 80015c90 <bcache>
    80002f26:	cedfd0ef          	jal	ra,80000c12 <release>
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	e04a                	sd	s2,0(sp)
    80002f3e:	1000                	addi	s0,sp,32
    80002f40:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f42:	00d5d59b          	srliw	a1,a1,0xd
    80002f46:	0001b797          	auipc	a5,0x1b
    80002f4a:	4267a783          	lw	a5,1062(a5) # 8001e36c <sb+0x1c>
    80002f4e:	9dbd                	addw	a1,a1,a5
    80002f50:	debff0ef          	jal	ra,80002d3a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f54:	0074f713          	andi	a4,s1,7
    80002f58:	4785                	li	a5,1
    80002f5a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f5e:	14ce                	slli	s1,s1,0x33
    80002f60:	90d9                	srli	s1,s1,0x36
    80002f62:	00950733          	add	a4,a0,s1
    80002f66:	05874703          	lbu	a4,88(a4)
    80002f6a:	00e7f6b3          	and	a3,a5,a4
    80002f6e:	c29d                	beqz	a3,80002f94 <bfree+0x60>
    80002f70:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f72:	94aa                	add	s1,s1,a0
    80002f74:	fff7c793          	not	a5,a5
    80002f78:	8ff9                	and	a5,a5,a4
    80002f7a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002f7e:	7d1000ef          	jal	ra,80003f4e <log_write>
  brelse(bp);
    80002f82:	854a                	mv	a0,s2
    80002f84:	ebfff0ef          	jal	ra,80002e42 <brelse>
}
    80002f88:	60e2                	ld	ra,24(sp)
    80002f8a:	6442                	ld	s0,16(sp)
    80002f8c:	64a2                	ld	s1,8(sp)
    80002f8e:	6902                	ld	s2,0(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret
    panic("freeing free block");
    80002f94:	00004517          	auipc	a0,0x4
    80002f98:	60450513          	addi	a0,a0,1540 # 80007598 <syscalls+0xf8>
    80002f9c:	ff4fd0ef          	jal	ra,80000790 <panic>

0000000080002fa0 <balloc>:
{
    80002fa0:	711d                	addi	sp,sp,-96
    80002fa2:	ec86                	sd	ra,88(sp)
    80002fa4:	e8a2                	sd	s0,80(sp)
    80002fa6:	e4a6                	sd	s1,72(sp)
    80002fa8:	e0ca                	sd	s2,64(sp)
    80002faa:	fc4e                	sd	s3,56(sp)
    80002fac:	f852                	sd	s4,48(sp)
    80002fae:	f456                	sd	s5,40(sp)
    80002fb0:	f05a                	sd	s6,32(sp)
    80002fb2:	ec5e                	sd	s7,24(sp)
    80002fb4:	e862                	sd	s8,16(sp)
    80002fb6:	e466                	sd	s9,8(sp)
    80002fb8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fba:	0001b797          	auipc	a5,0x1b
    80002fbe:	39a7a783          	lw	a5,922(a5) # 8001e354 <sb+0x4>
    80002fc2:	0e078163          	beqz	a5,800030a4 <balloc+0x104>
    80002fc6:	8baa                	mv	s7,a0
    80002fc8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fca:	0001bb17          	auipc	s6,0x1b
    80002fce:	386b0b13          	addi	s6,s6,902 # 8001e350 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fd2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002fd4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fd6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002fd8:	6c89                	lui	s9,0x2
    80002fda:	a0b5                	j	80003046 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002fdc:	974a                	add	a4,a4,s2
    80002fde:	8fd5                	or	a5,a5,a3
    80002fe0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002fe4:	854a                	mv	a0,s2
    80002fe6:	769000ef          	jal	ra,80003f4e <log_write>
        brelse(bp);
    80002fea:	854a                	mv	a0,s2
    80002fec:	e57ff0ef          	jal	ra,80002e42 <brelse>
  bp = bread(dev, bno);
    80002ff0:	85a6                	mv	a1,s1
    80002ff2:	855e                	mv	a0,s7
    80002ff4:	d47ff0ef          	jal	ra,80002d3a <bread>
    80002ff8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ffa:	40000613          	li	a2,1024
    80002ffe:	4581                	li	a1,0
    80003000:	05850513          	addi	a0,a0,88
    80003004:	c4bfd0ef          	jal	ra,80000c4e <memset>
  log_write(bp);
    80003008:	854a                	mv	a0,s2
    8000300a:	745000ef          	jal	ra,80003f4e <log_write>
  brelse(bp);
    8000300e:	854a                	mv	a0,s2
    80003010:	e33ff0ef          	jal	ra,80002e42 <brelse>
}
    80003014:	8526                	mv	a0,s1
    80003016:	60e6                	ld	ra,88(sp)
    80003018:	6446                	ld	s0,80(sp)
    8000301a:	64a6                	ld	s1,72(sp)
    8000301c:	6906                	ld	s2,64(sp)
    8000301e:	79e2                	ld	s3,56(sp)
    80003020:	7a42                	ld	s4,48(sp)
    80003022:	7aa2                	ld	s5,40(sp)
    80003024:	7b02                	ld	s6,32(sp)
    80003026:	6be2                	ld	s7,24(sp)
    80003028:	6c42                	ld	s8,16(sp)
    8000302a:	6ca2                	ld	s9,8(sp)
    8000302c:	6125                	addi	sp,sp,96
    8000302e:	8082                	ret
    brelse(bp);
    80003030:	854a                	mv	a0,s2
    80003032:	e11ff0ef          	jal	ra,80002e42 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003036:	015c87bb          	addw	a5,s9,s5
    8000303a:	00078a9b          	sext.w	s5,a5
    8000303e:	004b2703          	lw	a4,4(s6)
    80003042:	06eaf163          	bgeu	s5,a4,800030a4 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80003046:	41fad79b          	sraiw	a5,s5,0x1f
    8000304a:	0137d79b          	srliw	a5,a5,0x13
    8000304e:	015787bb          	addw	a5,a5,s5
    80003052:	40d7d79b          	sraiw	a5,a5,0xd
    80003056:	01cb2583          	lw	a1,28(s6)
    8000305a:	9dbd                	addw	a1,a1,a5
    8000305c:	855e                	mv	a0,s7
    8000305e:	cddff0ef          	jal	ra,80002d3a <bread>
    80003062:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003064:	004b2503          	lw	a0,4(s6)
    80003068:	000a849b          	sext.w	s1,s5
    8000306c:	8662                	mv	a2,s8
    8000306e:	fca4f1e3          	bgeu	s1,a0,80003030 <balloc+0x90>
      m = 1 << (bi % 8);
    80003072:	41f6579b          	sraiw	a5,a2,0x1f
    80003076:	01d7d69b          	srliw	a3,a5,0x1d
    8000307a:	00c6873b          	addw	a4,a3,a2
    8000307e:	00777793          	andi	a5,a4,7
    80003082:	9f95                	subw	a5,a5,a3
    80003084:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003088:	4037571b          	sraiw	a4,a4,0x3
    8000308c:	00e906b3          	add	a3,s2,a4
    80003090:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80003094:	00d7f5b3          	and	a1,a5,a3
    80003098:	d1b1                	beqz	a1,80002fdc <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000309a:	2605                	addiw	a2,a2,1
    8000309c:	2485                	addiw	s1,s1,1
    8000309e:	fd4618e3          	bne	a2,s4,8000306e <balloc+0xce>
    800030a2:	b779                	j	80003030 <balloc+0x90>
  printf("balloc: out of blocks\n");
    800030a4:	00004517          	auipc	a0,0x4
    800030a8:	50c50513          	addi	a0,a0,1292 # 800075b0 <syscalls+0x110>
    800030ac:	c1efd0ef          	jal	ra,800004ca <printf>
  return 0;
    800030b0:	4481                	li	s1,0
    800030b2:	b78d                	j	80003014 <balloc+0x74>

00000000800030b4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030b4:	7179                	addi	sp,sp,-48
    800030b6:	f406                	sd	ra,40(sp)
    800030b8:	f022                	sd	s0,32(sp)
    800030ba:	ec26                	sd	s1,24(sp)
    800030bc:	e84a                	sd	s2,16(sp)
    800030be:	e44e                	sd	s3,8(sp)
    800030c0:	e052                	sd	s4,0(sp)
    800030c2:	1800                	addi	s0,sp,48
    800030c4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030c6:	47ad                	li	a5,11
    800030c8:	02b7e563          	bltu	a5,a1,800030f2 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030cc:	02059493          	slli	s1,a1,0x20
    800030d0:	9081                	srli	s1,s1,0x20
    800030d2:	048a                	slli	s1,s1,0x2
    800030d4:	94aa                	add	s1,s1,a0
    800030d6:	0504a903          	lw	s2,80(s1)
    800030da:	06091663          	bnez	s2,80003146 <bmap+0x92>
      addr = balloc(ip->dev);
    800030de:	4108                	lw	a0,0(a0)
    800030e0:	ec1ff0ef          	jal	ra,80002fa0 <balloc>
    800030e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030e8:	04090f63          	beqz	s2,80003146 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    800030ec:	0524a823          	sw	s2,80(s1)
    800030f0:	a899                	j	80003146 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030f2:	ff45849b          	addiw	s1,a1,-12
    800030f6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030fa:	0ff00793          	li	a5,255
    800030fe:	06e7eb63          	bltu	a5,a4,80003174 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003102:	08052903          	lw	s2,128(a0)
    80003106:	00091b63          	bnez	s2,8000311c <bmap+0x68>
      addr = balloc(ip->dev);
    8000310a:	4108                	lw	a0,0(a0)
    8000310c:	e95ff0ef          	jal	ra,80002fa0 <balloc>
    80003110:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003114:	02090963          	beqz	s2,80003146 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003118:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000311c:	85ca                	mv	a1,s2
    8000311e:	0009a503          	lw	a0,0(s3)
    80003122:	c19ff0ef          	jal	ra,80002d3a <bread>
    80003126:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003128:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000312c:	02049593          	slli	a1,s1,0x20
    80003130:	9181                	srli	a1,a1,0x20
    80003132:	058a                	slli	a1,a1,0x2
    80003134:	00b784b3          	add	s1,a5,a1
    80003138:	0004a903          	lw	s2,0(s1)
    8000313c:	00090e63          	beqz	s2,80003158 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003140:	8552                	mv	a0,s4
    80003142:	d01ff0ef          	jal	ra,80002e42 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003146:	854a                	mv	a0,s2
    80003148:	70a2                	ld	ra,40(sp)
    8000314a:	7402                	ld	s0,32(sp)
    8000314c:	64e2                	ld	s1,24(sp)
    8000314e:	6942                	ld	s2,16(sp)
    80003150:	69a2                	ld	s3,8(sp)
    80003152:	6a02                	ld	s4,0(sp)
    80003154:	6145                	addi	sp,sp,48
    80003156:	8082                	ret
      addr = balloc(ip->dev);
    80003158:	0009a503          	lw	a0,0(s3)
    8000315c:	e45ff0ef          	jal	ra,80002fa0 <balloc>
    80003160:	0005091b          	sext.w	s2,a0
      if(addr){
    80003164:	fc090ee3          	beqz	s2,80003140 <bmap+0x8c>
        a[bn] = addr;
    80003168:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000316c:	8552                	mv	a0,s4
    8000316e:	5e1000ef          	jal	ra,80003f4e <log_write>
    80003172:	b7f9                	j	80003140 <bmap+0x8c>
  panic("bmap: out of range");
    80003174:	00004517          	auipc	a0,0x4
    80003178:	45450513          	addi	a0,a0,1108 # 800075c8 <syscalls+0x128>
    8000317c:	e14fd0ef          	jal	ra,80000790 <panic>

0000000080003180 <iget>:
{
    80003180:	7179                	addi	sp,sp,-48
    80003182:	f406                	sd	ra,40(sp)
    80003184:	f022                	sd	s0,32(sp)
    80003186:	ec26                	sd	s1,24(sp)
    80003188:	e84a                	sd	s2,16(sp)
    8000318a:	e44e                	sd	s3,8(sp)
    8000318c:	e052                	sd	s4,0(sp)
    8000318e:	1800                	addi	s0,sp,48
    80003190:	89aa                	mv	s3,a0
    80003192:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003194:	0001b517          	auipc	a0,0x1b
    80003198:	1dc50513          	addi	a0,a0,476 # 8001e370 <itable>
    8000319c:	9dffd0ef          	jal	ra,80000b7a <acquire>
  empty = 0;
    800031a0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031a2:	0001b497          	auipc	s1,0x1b
    800031a6:	1e648493          	addi	s1,s1,486 # 8001e388 <itable+0x18>
    800031aa:	0001d697          	auipc	a3,0x1d
    800031ae:	c6e68693          	addi	a3,a3,-914 # 8001fe18 <log>
    800031b2:	a039                	j	800031c0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031b4:	02090963          	beqz	s2,800031e6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031b8:	08848493          	addi	s1,s1,136
    800031bc:	02d48863          	beq	s1,a3,800031ec <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031c0:	449c                	lw	a5,8(s1)
    800031c2:	fef059e3          	blez	a5,800031b4 <iget+0x34>
    800031c6:	4098                	lw	a4,0(s1)
    800031c8:	ff3716e3          	bne	a4,s3,800031b4 <iget+0x34>
    800031cc:	40d8                	lw	a4,4(s1)
    800031ce:	ff4713e3          	bne	a4,s4,800031b4 <iget+0x34>
      ip->ref++;
    800031d2:	2785                	addiw	a5,a5,1
    800031d4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031d6:	0001b517          	auipc	a0,0x1b
    800031da:	19a50513          	addi	a0,a0,410 # 8001e370 <itable>
    800031de:	a35fd0ef          	jal	ra,80000c12 <release>
      return ip;
    800031e2:	8926                	mv	s2,s1
    800031e4:	a02d                	j	8000320e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031e6:	fbe9                	bnez	a5,800031b8 <iget+0x38>
    800031e8:	8926                	mv	s2,s1
    800031ea:	b7f9                	j	800031b8 <iget+0x38>
  if(empty == 0)
    800031ec:	02090a63          	beqz	s2,80003220 <iget+0xa0>
  ip->dev = dev;
    800031f0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031f4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031f8:	4785                	li	a5,1
    800031fa:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031fe:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003202:	0001b517          	auipc	a0,0x1b
    80003206:	16e50513          	addi	a0,a0,366 # 8001e370 <itable>
    8000320a:	a09fd0ef          	jal	ra,80000c12 <release>
}
    8000320e:	854a                	mv	a0,s2
    80003210:	70a2                	ld	ra,40(sp)
    80003212:	7402                	ld	s0,32(sp)
    80003214:	64e2                	ld	s1,24(sp)
    80003216:	6942                	ld	s2,16(sp)
    80003218:	69a2                	ld	s3,8(sp)
    8000321a:	6a02                	ld	s4,0(sp)
    8000321c:	6145                	addi	sp,sp,48
    8000321e:	8082                	ret
    panic("iget: no inodes");
    80003220:	00004517          	auipc	a0,0x4
    80003224:	3c050513          	addi	a0,a0,960 # 800075e0 <syscalls+0x140>
    80003228:	d68fd0ef          	jal	ra,80000790 <panic>

000000008000322c <iinit>:
{
    8000322c:	7179                	addi	sp,sp,-48
    8000322e:	f406                	sd	ra,40(sp)
    80003230:	f022                	sd	s0,32(sp)
    80003232:	ec26                	sd	s1,24(sp)
    80003234:	e84a                	sd	s2,16(sp)
    80003236:	e44e                	sd	s3,8(sp)
    80003238:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000323a:	00004597          	auipc	a1,0x4
    8000323e:	3b658593          	addi	a1,a1,950 # 800075f0 <syscalls+0x150>
    80003242:	0001b517          	auipc	a0,0x1b
    80003246:	12e50513          	addi	a0,a0,302 # 8001e370 <itable>
    8000324a:	8b1fd0ef          	jal	ra,80000afa <initlock>
  for(i = 0; i < NINODE; i++) {
    8000324e:	0001b497          	auipc	s1,0x1b
    80003252:	14a48493          	addi	s1,s1,330 # 8001e398 <itable+0x28>
    80003256:	0001d997          	auipc	s3,0x1d
    8000325a:	bd298993          	addi	s3,s3,-1070 # 8001fe28 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000325e:	00004917          	auipc	s2,0x4
    80003262:	39a90913          	addi	s2,s2,922 # 800075f8 <syscalls+0x158>
    80003266:	85ca                	mv	a1,s2
    80003268:	8526                	mv	a0,s1
    8000326a:	5a9000ef          	jal	ra,80004012 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000326e:	08848493          	addi	s1,s1,136
    80003272:	ff349ae3          	bne	s1,s3,80003266 <iinit+0x3a>
}
    80003276:	70a2                	ld	ra,40(sp)
    80003278:	7402                	ld	s0,32(sp)
    8000327a:	64e2                	ld	s1,24(sp)
    8000327c:	6942                	ld	s2,16(sp)
    8000327e:	69a2                	ld	s3,8(sp)
    80003280:	6145                	addi	sp,sp,48
    80003282:	8082                	ret

0000000080003284 <ialloc>:
{
    80003284:	715d                	addi	sp,sp,-80
    80003286:	e486                	sd	ra,72(sp)
    80003288:	e0a2                	sd	s0,64(sp)
    8000328a:	fc26                	sd	s1,56(sp)
    8000328c:	f84a                	sd	s2,48(sp)
    8000328e:	f44e                	sd	s3,40(sp)
    80003290:	f052                	sd	s4,32(sp)
    80003292:	ec56                	sd	s5,24(sp)
    80003294:	e85a                	sd	s6,16(sp)
    80003296:	e45e                	sd	s7,8(sp)
    80003298:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000329a:	0001b717          	auipc	a4,0x1b
    8000329e:	0c272703          	lw	a4,194(a4) # 8001e35c <sb+0xc>
    800032a2:	4785                	li	a5,1
    800032a4:	04e7f663          	bgeu	a5,a4,800032f0 <ialloc+0x6c>
    800032a8:	8aaa                	mv	s5,a0
    800032aa:	8bae                	mv	s7,a1
    800032ac:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800032ae:	0001ba17          	auipc	s4,0x1b
    800032b2:	0a2a0a13          	addi	s4,s4,162 # 8001e350 <sb>
    800032b6:	00048b1b          	sext.w	s6,s1
    800032ba:	0044d593          	srli	a1,s1,0x4
    800032be:	018a2783          	lw	a5,24(s4)
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	8556                	mv	a0,s5
    800032c6:	a75ff0ef          	jal	ra,80002d3a <bread>
    800032ca:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032cc:	05850993          	addi	s3,a0,88
    800032d0:	00f4f793          	andi	a5,s1,15
    800032d4:	079a                	slli	a5,a5,0x6
    800032d6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032d8:	00099783          	lh	a5,0(s3)
    800032dc:	cf85                	beqz	a5,80003314 <ialloc+0x90>
    brelse(bp);
    800032de:	b65ff0ef          	jal	ra,80002e42 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032e2:	0485                	addi	s1,s1,1
    800032e4:	00ca2703          	lw	a4,12(s4)
    800032e8:	0004879b          	sext.w	a5,s1
    800032ec:	fce7e5e3          	bltu	a5,a4,800032b6 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800032f0:	00004517          	auipc	a0,0x4
    800032f4:	31050513          	addi	a0,a0,784 # 80007600 <syscalls+0x160>
    800032f8:	9d2fd0ef          	jal	ra,800004ca <printf>
  return 0;
    800032fc:	4501                	li	a0,0
}
    800032fe:	60a6                	ld	ra,72(sp)
    80003300:	6406                	ld	s0,64(sp)
    80003302:	74e2                	ld	s1,56(sp)
    80003304:	7942                	ld	s2,48(sp)
    80003306:	79a2                	ld	s3,40(sp)
    80003308:	7a02                	ld	s4,32(sp)
    8000330a:	6ae2                	ld	s5,24(sp)
    8000330c:	6b42                	ld	s6,16(sp)
    8000330e:	6ba2                	ld	s7,8(sp)
    80003310:	6161                	addi	sp,sp,80
    80003312:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003314:	04000613          	li	a2,64
    80003318:	4581                	li	a1,0
    8000331a:	854e                	mv	a0,s3
    8000331c:	933fd0ef          	jal	ra,80000c4e <memset>
      dip->type = type;
    80003320:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003324:	854a                	mv	a0,s2
    80003326:	429000ef          	jal	ra,80003f4e <log_write>
      brelse(bp);
    8000332a:	854a                	mv	a0,s2
    8000332c:	b17ff0ef          	jal	ra,80002e42 <brelse>
      return iget(dev, inum);
    80003330:	85da                	mv	a1,s6
    80003332:	8556                	mv	a0,s5
    80003334:	e4dff0ef          	jal	ra,80003180 <iget>
    80003338:	b7d9                	j	800032fe <ialloc+0x7a>

000000008000333a <iupdate>:
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	e04a                	sd	s2,0(sp)
    80003344:	1000                	addi	s0,sp,32
    80003346:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003348:	415c                	lw	a5,4(a0)
    8000334a:	0047d79b          	srliw	a5,a5,0x4
    8000334e:	0001b597          	auipc	a1,0x1b
    80003352:	01a5a583          	lw	a1,26(a1) # 8001e368 <sb+0x18>
    80003356:	9dbd                	addw	a1,a1,a5
    80003358:	4108                	lw	a0,0(a0)
    8000335a:	9e1ff0ef          	jal	ra,80002d3a <bread>
    8000335e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003360:	05850793          	addi	a5,a0,88
    80003364:	40c8                	lw	a0,4(s1)
    80003366:	893d                	andi	a0,a0,15
    80003368:	051a                	slli	a0,a0,0x6
    8000336a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000336c:	04449703          	lh	a4,68(s1)
    80003370:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003374:	04649703          	lh	a4,70(s1)
    80003378:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000337c:	04849703          	lh	a4,72(s1)
    80003380:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003384:	04a49703          	lh	a4,74(s1)
    80003388:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000338c:	44f8                	lw	a4,76(s1)
    8000338e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003390:	03400613          	li	a2,52
    80003394:	05048593          	addi	a1,s1,80
    80003398:	0531                	addi	a0,a0,12
    8000339a:	915fd0ef          	jal	ra,80000cae <memmove>
  log_write(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	3af000ef          	jal	ra,80003f4e <log_write>
  brelse(bp);
    800033a4:	854a                	mv	a0,s2
    800033a6:	a9dff0ef          	jal	ra,80002e42 <brelse>
}
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	64a2                	ld	s1,8(sp)
    800033b0:	6902                	ld	s2,0(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <idup>:
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	1000                	addi	s0,sp,32
    800033c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033c2:	0001b517          	auipc	a0,0x1b
    800033c6:	fae50513          	addi	a0,a0,-82 # 8001e370 <itable>
    800033ca:	fb0fd0ef          	jal	ra,80000b7a <acquire>
  ip->ref++;
    800033ce:	449c                	lw	a5,8(s1)
    800033d0:	2785                	addiw	a5,a5,1
    800033d2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033d4:	0001b517          	auipc	a0,0x1b
    800033d8:	f9c50513          	addi	a0,a0,-100 # 8001e370 <itable>
    800033dc:	837fd0ef          	jal	ra,80000c12 <release>
}
    800033e0:	8526                	mv	a0,s1
    800033e2:	60e2                	ld	ra,24(sp)
    800033e4:	6442                	ld	s0,16(sp)
    800033e6:	64a2                	ld	s1,8(sp)
    800033e8:	6105                	addi	sp,sp,32
    800033ea:	8082                	ret

00000000800033ec <ilock>:
{
    800033ec:	1101                	addi	sp,sp,-32
    800033ee:	ec06                	sd	ra,24(sp)
    800033f0:	e822                	sd	s0,16(sp)
    800033f2:	e426                	sd	s1,8(sp)
    800033f4:	e04a                	sd	s2,0(sp)
    800033f6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033f8:	c105                	beqz	a0,80003418 <ilock+0x2c>
    800033fa:	84aa                	mv	s1,a0
    800033fc:	451c                	lw	a5,8(a0)
    800033fe:	00f05d63          	blez	a5,80003418 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003402:	0541                	addi	a0,a0,16
    80003404:	445000ef          	jal	ra,80004048 <acquiresleep>
  if(ip->valid == 0){
    80003408:	40bc                	lw	a5,64(s1)
    8000340a:	cf89                	beqz	a5,80003424 <ilock+0x38>
}
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	64a2                	ld	s1,8(sp)
    80003412:	6902                	ld	s2,0(sp)
    80003414:	6105                	addi	sp,sp,32
    80003416:	8082                	ret
    panic("ilock");
    80003418:	00004517          	auipc	a0,0x4
    8000341c:	20050513          	addi	a0,a0,512 # 80007618 <syscalls+0x178>
    80003420:	b70fd0ef          	jal	ra,80000790 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003424:	40dc                	lw	a5,4(s1)
    80003426:	0047d79b          	srliw	a5,a5,0x4
    8000342a:	0001b597          	auipc	a1,0x1b
    8000342e:	f3e5a583          	lw	a1,-194(a1) # 8001e368 <sb+0x18>
    80003432:	9dbd                	addw	a1,a1,a5
    80003434:	4088                	lw	a0,0(s1)
    80003436:	905ff0ef          	jal	ra,80002d3a <bread>
    8000343a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000343c:	05850593          	addi	a1,a0,88
    80003440:	40dc                	lw	a5,4(s1)
    80003442:	8bbd                	andi	a5,a5,15
    80003444:	079a                	slli	a5,a5,0x6
    80003446:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003448:	00059783          	lh	a5,0(a1)
    8000344c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003450:	00259783          	lh	a5,2(a1)
    80003454:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003458:	00459783          	lh	a5,4(a1)
    8000345c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003460:	00659783          	lh	a5,6(a1)
    80003464:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003468:	459c                	lw	a5,8(a1)
    8000346a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000346c:	03400613          	li	a2,52
    80003470:	05b1                	addi	a1,a1,12
    80003472:	05048513          	addi	a0,s1,80
    80003476:	839fd0ef          	jal	ra,80000cae <memmove>
    brelse(bp);
    8000347a:	854a                	mv	a0,s2
    8000347c:	9c7ff0ef          	jal	ra,80002e42 <brelse>
    ip->valid = 1;
    80003480:	4785                	li	a5,1
    80003482:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003484:	04449783          	lh	a5,68(s1)
    80003488:	f3d1                	bnez	a5,8000340c <ilock+0x20>
      panic("ilock: no type");
    8000348a:	00004517          	auipc	a0,0x4
    8000348e:	19650513          	addi	a0,a0,406 # 80007620 <syscalls+0x180>
    80003492:	afefd0ef          	jal	ra,80000790 <panic>

0000000080003496 <iunlock>:
{
    80003496:	1101                	addi	sp,sp,-32
    80003498:	ec06                	sd	ra,24(sp)
    8000349a:	e822                	sd	s0,16(sp)
    8000349c:	e426                	sd	s1,8(sp)
    8000349e:	e04a                	sd	s2,0(sp)
    800034a0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034a2:	c505                	beqz	a0,800034ca <iunlock+0x34>
    800034a4:	84aa                	mv	s1,a0
    800034a6:	01050913          	addi	s2,a0,16
    800034aa:	854a                	mv	a0,s2
    800034ac:	41b000ef          	jal	ra,800040c6 <holdingsleep>
    800034b0:	cd09                	beqz	a0,800034ca <iunlock+0x34>
    800034b2:	449c                	lw	a5,8(s1)
    800034b4:	00f05b63          	blez	a5,800034ca <iunlock+0x34>
  releasesleep(&ip->lock);
    800034b8:	854a                	mv	a0,s2
    800034ba:	3d5000ef          	jal	ra,8000408e <releasesleep>
}
    800034be:	60e2                	ld	ra,24(sp)
    800034c0:	6442                	ld	s0,16(sp)
    800034c2:	64a2                	ld	s1,8(sp)
    800034c4:	6902                	ld	s2,0(sp)
    800034c6:	6105                	addi	sp,sp,32
    800034c8:	8082                	ret
    panic("iunlock");
    800034ca:	00004517          	auipc	a0,0x4
    800034ce:	16650513          	addi	a0,a0,358 # 80007630 <syscalls+0x190>
    800034d2:	abefd0ef          	jal	ra,80000790 <panic>

00000000800034d6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034d6:	7179                	addi	sp,sp,-48
    800034d8:	f406                	sd	ra,40(sp)
    800034da:	f022                	sd	s0,32(sp)
    800034dc:	ec26                	sd	s1,24(sp)
    800034de:	e84a                	sd	s2,16(sp)
    800034e0:	e44e                	sd	s3,8(sp)
    800034e2:	e052                	sd	s4,0(sp)
    800034e4:	1800                	addi	s0,sp,48
    800034e6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034e8:	05050493          	addi	s1,a0,80
    800034ec:	08050913          	addi	s2,a0,128
    800034f0:	a021                	j	800034f8 <itrunc+0x22>
    800034f2:	0491                	addi	s1,s1,4
    800034f4:	01248b63          	beq	s1,s2,8000350a <itrunc+0x34>
    if(ip->addrs[i]){
    800034f8:	408c                	lw	a1,0(s1)
    800034fa:	dde5                	beqz	a1,800034f2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800034fc:	0009a503          	lw	a0,0(s3)
    80003500:	a35ff0ef          	jal	ra,80002f34 <bfree>
      ip->addrs[i] = 0;
    80003504:	0004a023          	sw	zero,0(s1)
    80003508:	b7ed                	j	800034f2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000350a:	0809a583          	lw	a1,128(s3)
    8000350e:	ed91                	bnez	a1,8000352a <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003510:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003514:	854e                	mv	a0,s3
    80003516:	e25ff0ef          	jal	ra,8000333a <iupdate>
}
    8000351a:	70a2                	ld	ra,40(sp)
    8000351c:	7402                	ld	s0,32(sp)
    8000351e:	64e2                	ld	s1,24(sp)
    80003520:	6942                	ld	s2,16(sp)
    80003522:	69a2                	ld	s3,8(sp)
    80003524:	6a02                	ld	s4,0(sp)
    80003526:	6145                	addi	sp,sp,48
    80003528:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000352a:	0009a503          	lw	a0,0(s3)
    8000352e:	80dff0ef          	jal	ra,80002d3a <bread>
    80003532:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003534:	05850493          	addi	s1,a0,88
    80003538:	45850913          	addi	s2,a0,1112
    8000353c:	a801                	j	8000354c <itrunc+0x76>
        bfree(ip->dev, a[j]);
    8000353e:	0009a503          	lw	a0,0(s3)
    80003542:	9f3ff0ef          	jal	ra,80002f34 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003546:	0491                	addi	s1,s1,4
    80003548:	01248563          	beq	s1,s2,80003552 <itrunc+0x7c>
      if(a[j])
    8000354c:	408c                	lw	a1,0(s1)
    8000354e:	dde5                	beqz	a1,80003546 <itrunc+0x70>
    80003550:	b7fd                	j	8000353e <itrunc+0x68>
    brelse(bp);
    80003552:	8552                	mv	a0,s4
    80003554:	8efff0ef          	jal	ra,80002e42 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003558:	0809a583          	lw	a1,128(s3)
    8000355c:	0009a503          	lw	a0,0(s3)
    80003560:	9d5ff0ef          	jal	ra,80002f34 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003564:	0809a023          	sw	zero,128(s3)
    80003568:	b765                	j	80003510 <itrunc+0x3a>

000000008000356a <iput>:
{
    8000356a:	1101                	addi	sp,sp,-32
    8000356c:	ec06                	sd	ra,24(sp)
    8000356e:	e822                	sd	s0,16(sp)
    80003570:	e426                	sd	s1,8(sp)
    80003572:	e04a                	sd	s2,0(sp)
    80003574:	1000                	addi	s0,sp,32
    80003576:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003578:	0001b517          	auipc	a0,0x1b
    8000357c:	df850513          	addi	a0,a0,-520 # 8001e370 <itable>
    80003580:	dfafd0ef          	jal	ra,80000b7a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003584:	4498                	lw	a4,8(s1)
    80003586:	4785                	li	a5,1
    80003588:	02f70163          	beq	a4,a5,800035aa <iput+0x40>
  ip->ref--;
    8000358c:	449c                	lw	a5,8(s1)
    8000358e:	37fd                	addiw	a5,a5,-1
    80003590:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003592:	0001b517          	auipc	a0,0x1b
    80003596:	dde50513          	addi	a0,a0,-546 # 8001e370 <itable>
    8000359a:	e78fd0ef          	jal	ra,80000c12 <release>
}
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	64a2                	ld	s1,8(sp)
    800035a4:	6902                	ld	s2,0(sp)
    800035a6:	6105                	addi	sp,sp,32
    800035a8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035aa:	40bc                	lw	a5,64(s1)
    800035ac:	d3e5                	beqz	a5,8000358c <iput+0x22>
    800035ae:	04a49783          	lh	a5,74(s1)
    800035b2:	ffe9                	bnez	a5,8000358c <iput+0x22>
    acquiresleep(&ip->lock);
    800035b4:	01048913          	addi	s2,s1,16
    800035b8:	854a                	mv	a0,s2
    800035ba:	28f000ef          	jal	ra,80004048 <acquiresleep>
    release(&itable.lock);
    800035be:	0001b517          	auipc	a0,0x1b
    800035c2:	db250513          	addi	a0,a0,-590 # 8001e370 <itable>
    800035c6:	e4cfd0ef          	jal	ra,80000c12 <release>
    itrunc(ip);
    800035ca:	8526                	mv	a0,s1
    800035cc:	f0bff0ef          	jal	ra,800034d6 <itrunc>
    ip->type = 0;
    800035d0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035d4:	8526                	mv	a0,s1
    800035d6:	d65ff0ef          	jal	ra,8000333a <iupdate>
    ip->valid = 0;
    800035da:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035de:	854a                	mv	a0,s2
    800035e0:	2af000ef          	jal	ra,8000408e <releasesleep>
    acquire(&itable.lock);
    800035e4:	0001b517          	auipc	a0,0x1b
    800035e8:	d8c50513          	addi	a0,a0,-628 # 8001e370 <itable>
    800035ec:	d8efd0ef          	jal	ra,80000b7a <acquire>
    800035f0:	bf71                	j	8000358c <iput+0x22>

00000000800035f2 <iunlockput>:
{
    800035f2:	1101                	addi	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	1000                	addi	s0,sp,32
    800035fc:	84aa                	mv	s1,a0
  iunlock(ip);
    800035fe:	e99ff0ef          	jal	ra,80003496 <iunlock>
  iput(ip);
    80003602:	8526                	mv	a0,s1
    80003604:	f67ff0ef          	jal	ra,8000356a <iput>
}
    80003608:	60e2                	ld	ra,24(sp)
    8000360a:	6442                	ld	s0,16(sp)
    8000360c:	64a2                	ld	s1,8(sp)
    8000360e:	6105                	addi	sp,sp,32
    80003610:	8082                	ret

0000000080003612 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003612:	0001b717          	auipc	a4,0x1b
    80003616:	d4a72703          	lw	a4,-694(a4) # 8001e35c <sb+0xc>
    8000361a:	4785                	li	a5,1
    8000361c:	0ae7ff63          	bgeu	a5,a4,800036da <ireclaim+0xc8>
{
    80003620:	7139                	addi	sp,sp,-64
    80003622:	fc06                	sd	ra,56(sp)
    80003624:	f822                	sd	s0,48(sp)
    80003626:	f426                	sd	s1,40(sp)
    80003628:	f04a                	sd	s2,32(sp)
    8000362a:	ec4e                	sd	s3,24(sp)
    8000362c:	e852                	sd	s4,16(sp)
    8000362e:	e456                	sd	s5,8(sp)
    80003630:	e05a                	sd	s6,0(sp)
    80003632:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003634:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003636:	00050a1b          	sext.w	s4,a0
    8000363a:	0001ba97          	auipc	s5,0x1b
    8000363e:	d16a8a93          	addi	s5,s5,-746 # 8001e350 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003642:	00004b17          	auipc	s6,0x4
    80003646:	ff6b0b13          	addi	s6,s6,-10 # 80007638 <syscalls+0x198>
    8000364a:	a099                	j	80003690 <ireclaim+0x7e>
    8000364c:	85ce                	mv	a1,s3
    8000364e:	855a                	mv	a0,s6
    80003650:	e7bfc0ef          	jal	ra,800004ca <printf>
      ip = iget(dev, inum);
    80003654:	85ce                	mv	a1,s3
    80003656:	8552                	mv	a0,s4
    80003658:	b29ff0ef          	jal	ra,80003180 <iget>
    8000365c:	89aa                	mv	s3,a0
    brelse(bp);
    8000365e:	854a                	mv	a0,s2
    80003660:	fe2ff0ef          	jal	ra,80002e42 <brelse>
    if (ip) {
    80003664:	00098f63          	beqz	s3,80003682 <ireclaim+0x70>
      begin_op();
    80003668:	762000ef          	jal	ra,80003dca <begin_op>
      ilock(ip);
    8000366c:	854e                	mv	a0,s3
    8000366e:	d7fff0ef          	jal	ra,800033ec <ilock>
      iunlock(ip);
    80003672:	854e                	mv	a0,s3
    80003674:	e23ff0ef          	jal	ra,80003496 <iunlock>
      iput(ip);
    80003678:	854e                	mv	a0,s3
    8000367a:	ef1ff0ef          	jal	ra,8000356a <iput>
      end_op();
    8000367e:	7bc000ef          	jal	ra,80003e3a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003682:	0485                	addi	s1,s1,1
    80003684:	00caa703          	lw	a4,12(s5)
    80003688:	0004879b          	sext.w	a5,s1
    8000368c:	02e7fd63          	bgeu	a5,a4,800036c6 <ireclaim+0xb4>
    80003690:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003694:	0044d593          	srli	a1,s1,0x4
    80003698:	018aa783          	lw	a5,24(s5)
    8000369c:	9dbd                	addw	a1,a1,a5
    8000369e:	8552                	mv	a0,s4
    800036a0:	e9aff0ef          	jal	ra,80002d3a <bread>
    800036a4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036a6:	05850793          	addi	a5,a0,88
    800036aa:	00f9f713          	andi	a4,s3,15
    800036ae:	071a                	slli	a4,a4,0x6
    800036b0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036b2:	00079703          	lh	a4,0(a5)
    800036b6:	c701                	beqz	a4,800036be <ireclaim+0xac>
    800036b8:	00679783          	lh	a5,6(a5)
    800036bc:	dbc1                	beqz	a5,8000364c <ireclaim+0x3a>
    brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	f82ff0ef          	jal	ra,80002e42 <brelse>
    if (ip) {
    800036c4:	bf7d                	j	80003682 <ireclaim+0x70>
}
    800036c6:	70e2                	ld	ra,56(sp)
    800036c8:	7442                	ld	s0,48(sp)
    800036ca:	74a2                	ld	s1,40(sp)
    800036cc:	7902                	ld	s2,32(sp)
    800036ce:	69e2                	ld	s3,24(sp)
    800036d0:	6a42                	ld	s4,16(sp)
    800036d2:	6aa2                	ld	s5,8(sp)
    800036d4:	6b02                	ld	s6,0(sp)
    800036d6:	6121                	addi	sp,sp,64
    800036d8:	8082                	ret
    800036da:	8082                	ret

00000000800036dc <fsinit>:
fsinit(int dev) {
    800036dc:	7179                	addi	sp,sp,-48
    800036de:	f406                	sd	ra,40(sp)
    800036e0:	f022                	sd	s0,32(sp)
    800036e2:	ec26                	sd	s1,24(sp)
    800036e4:	e84a                	sd	s2,16(sp)
    800036e6:	e44e                	sd	s3,8(sp)
    800036e8:	1800                	addi	s0,sp,48
    800036ea:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036ec:	4585                	li	a1,1
    800036ee:	e4cff0ef          	jal	ra,80002d3a <bread>
    800036f2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036f4:	0001b997          	auipc	s3,0x1b
    800036f8:	c5c98993          	addi	s3,s3,-932 # 8001e350 <sb>
    800036fc:	02000613          	li	a2,32
    80003700:	05850593          	addi	a1,a0,88
    80003704:	854e                	mv	a0,s3
    80003706:	da8fd0ef          	jal	ra,80000cae <memmove>
  brelse(bp);
    8000370a:	854a                	mv	a0,s2
    8000370c:	f36ff0ef          	jal	ra,80002e42 <brelse>
  if(sb.magic != FSMAGIC)
    80003710:	0009a703          	lw	a4,0(s3)
    80003714:	102037b7          	lui	a5,0x10203
    80003718:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000371c:	02f71363          	bne	a4,a5,80003742 <fsinit+0x66>
  initlog(dev, &sb);
    80003720:	0001b597          	auipc	a1,0x1b
    80003724:	c3058593          	addi	a1,a1,-976 # 8001e350 <sb>
    80003728:	8526                	mv	a0,s1
    8000372a:	616000ef          	jal	ra,80003d40 <initlog>
  ireclaim(dev);
    8000372e:	8526                	mv	a0,s1
    80003730:	ee3ff0ef          	jal	ra,80003612 <ireclaim>
}
    80003734:	70a2                	ld	ra,40(sp)
    80003736:	7402                	ld	s0,32(sp)
    80003738:	64e2                	ld	s1,24(sp)
    8000373a:	6942                	ld	s2,16(sp)
    8000373c:	69a2                	ld	s3,8(sp)
    8000373e:	6145                	addi	sp,sp,48
    80003740:	8082                	ret
    panic("invalid file system");
    80003742:	00004517          	auipc	a0,0x4
    80003746:	f1650513          	addi	a0,a0,-234 # 80007658 <syscalls+0x1b8>
    8000374a:	846fd0ef          	jal	ra,80000790 <panic>

000000008000374e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000374e:	1141                	addi	sp,sp,-16
    80003750:	e422                	sd	s0,8(sp)
    80003752:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003754:	411c                	lw	a5,0(a0)
    80003756:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003758:	415c                	lw	a5,4(a0)
    8000375a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000375c:	04451783          	lh	a5,68(a0)
    80003760:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003764:	04a51783          	lh	a5,74(a0)
    80003768:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000376c:	04c56783          	lwu	a5,76(a0)
    80003770:	e99c                	sd	a5,16(a1)
}
    80003772:	6422                	ld	s0,8(sp)
    80003774:	0141                	addi	sp,sp,16
    80003776:	8082                	ret

0000000080003778 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003778:	457c                	lw	a5,76(a0)
    8000377a:	0cd7ef63          	bltu	a5,a3,80003858 <readi+0xe0>
{
    8000377e:	7159                	addi	sp,sp,-112
    80003780:	f486                	sd	ra,104(sp)
    80003782:	f0a2                	sd	s0,96(sp)
    80003784:	eca6                	sd	s1,88(sp)
    80003786:	e8ca                	sd	s2,80(sp)
    80003788:	e4ce                	sd	s3,72(sp)
    8000378a:	e0d2                	sd	s4,64(sp)
    8000378c:	fc56                	sd	s5,56(sp)
    8000378e:	f85a                	sd	s6,48(sp)
    80003790:	f45e                	sd	s7,40(sp)
    80003792:	f062                	sd	s8,32(sp)
    80003794:	ec66                	sd	s9,24(sp)
    80003796:	e86a                	sd	s10,16(sp)
    80003798:	e46e                	sd	s11,8(sp)
    8000379a:	1880                	addi	s0,sp,112
    8000379c:	8b2a                	mv	s6,a0
    8000379e:	8bae                	mv	s7,a1
    800037a0:	8a32                	mv	s4,a2
    800037a2:	84b6                	mv	s1,a3
    800037a4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037a6:	9f35                	addw	a4,a4,a3
    return 0;
    800037a8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037aa:	08d76663          	bltu	a4,a3,80003836 <readi+0xbe>
  if(off + n > ip->size)
    800037ae:	00e7f463          	bgeu	a5,a4,800037b6 <readi+0x3e>
    n = ip->size - off;
    800037b2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b6:	080a8f63          	beqz	s5,80003854 <readi+0xdc>
    800037ba:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037bc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037c0:	5c7d                	li	s8,-1
    800037c2:	a80d                	j	800037f4 <readi+0x7c>
    800037c4:	020d1d93          	slli	s11,s10,0x20
    800037c8:	020ddd93          	srli	s11,s11,0x20
    800037cc:	05890613          	addi	a2,s2,88
    800037d0:	86ee                	mv	a3,s11
    800037d2:	963a                	add	a2,a2,a4
    800037d4:	85d2                	mv	a1,s4
    800037d6:	855e                	mv	a0,s7
    800037d8:	af5fe0ef          	jal	ra,800022cc <either_copyout>
    800037dc:	05850763          	beq	a0,s8,8000382a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	e60ff0ef          	jal	ra,80002e42 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037e6:	013d09bb          	addw	s3,s10,s3
    800037ea:	009d04bb          	addw	s1,s10,s1
    800037ee:	9a6e                	add	s4,s4,s11
    800037f0:	0559f163          	bgeu	s3,s5,80003832 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800037f4:	00a4d59b          	srliw	a1,s1,0xa
    800037f8:	855a                	mv	a0,s6
    800037fa:	8bbff0ef          	jal	ra,800030b4 <bmap>
    800037fe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003802:	c985                	beqz	a1,80003832 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003804:	000b2503          	lw	a0,0(s6)
    80003808:	d32ff0ef          	jal	ra,80002d3a <bread>
    8000380c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000380e:	3ff4f713          	andi	a4,s1,1023
    80003812:	40ec87bb          	subw	a5,s9,a4
    80003816:	413a86bb          	subw	a3,s5,s3
    8000381a:	8d3e                	mv	s10,a5
    8000381c:	2781                	sext.w	a5,a5
    8000381e:	0006861b          	sext.w	a2,a3
    80003822:	faf671e3          	bgeu	a2,a5,800037c4 <readi+0x4c>
    80003826:	8d36                	mv	s10,a3
    80003828:	bf71                	j	800037c4 <readi+0x4c>
      brelse(bp);
    8000382a:	854a                	mv	a0,s2
    8000382c:	e16ff0ef          	jal	ra,80002e42 <brelse>
      tot = -1;
    80003830:	59fd                	li	s3,-1
  }
  return tot;
    80003832:	0009851b          	sext.w	a0,s3
}
    80003836:	70a6                	ld	ra,104(sp)
    80003838:	7406                	ld	s0,96(sp)
    8000383a:	64e6                	ld	s1,88(sp)
    8000383c:	6946                	ld	s2,80(sp)
    8000383e:	69a6                	ld	s3,72(sp)
    80003840:	6a06                	ld	s4,64(sp)
    80003842:	7ae2                	ld	s5,56(sp)
    80003844:	7b42                	ld	s6,48(sp)
    80003846:	7ba2                	ld	s7,40(sp)
    80003848:	7c02                	ld	s8,32(sp)
    8000384a:	6ce2                	ld	s9,24(sp)
    8000384c:	6d42                	ld	s10,16(sp)
    8000384e:	6da2                	ld	s11,8(sp)
    80003850:	6165                	addi	sp,sp,112
    80003852:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003854:	89d6                	mv	s3,s5
    80003856:	bff1                	j	80003832 <readi+0xba>
    return 0;
    80003858:	4501                	li	a0,0
}
    8000385a:	8082                	ret

000000008000385c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000385c:	457c                	lw	a5,76(a0)
    8000385e:	0ed7ea63          	bltu	a5,a3,80003952 <writei+0xf6>
{
    80003862:	7159                	addi	sp,sp,-112
    80003864:	f486                	sd	ra,104(sp)
    80003866:	f0a2                	sd	s0,96(sp)
    80003868:	eca6                	sd	s1,88(sp)
    8000386a:	e8ca                	sd	s2,80(sp)
    8000386c:	e4ce                	sd	s3,72(sp)
    8000386e:	e0d2                	sd	s4,64(sp)
    80003870:	fc56                	sd	s5,56(sp)
    80003872:	f85a                	sd	s6,48(sp)
    80003874:	f45e                	sd	s7,40(sp)
    80003876:	f062                	sd	s8,32(sp)
    80003878:	ec66                	sd	s9,24(sp)
    8000387a:	e86a                	sd	s10,16(sp)
    8000387c:	e46e                	sd	s11,8(sp)
    8000387e:	1880                	addi	s0,sp,112
    80003880:	8aaa                	mv	s5,a0
    80003882:	8bae                	mv	s7,a1
    80003884:	8a32                	mv	s4,a2
    80003886:	8936                	mv	s2,a3
    80003888:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000388a:	00e687bb          	addw	a5,a3,a4
    8000388e:	0cd7e463          	bltu	a5,a3,80003956 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003892:	00043737          	lui	a4,0x43
    80003896:	0cf76263          	bltu	a4,a5,8000395a <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000389a:	0a0b0a63          	beqz	s6,8000394e <writei+0xf2>
    8000389e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038a0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038a4:	5c7d                	li	s8,-1
    800038a6:	a825                	j	800038de <writei+0x82>
    800038a8:	020d1d93          	slli	s11,s10,0x20
    800038ac:	020ddd93          	srli	s11,s11,0x20
    800038b0:	05848513          	addi	a0,s1,88
    800038b4:	86ee                	mv	a3,s11
    800038b6:	8652                	mv	a2,s4
    800038b8:	85de                	mv	a1,s7
    800038ba:	953a                	add	a0,a0,a4
    800038bc:	a5bfe0ef          	jal	ra,80002316 <either_copyin>
    800038c0:	05850a63          	beq	a0,s8,80003914 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038c4:	8526                	mv	a0,s1
    800038c6:	688000ef          	jal	ra,80003f4e <log_write>
    brelse(bp);
    800038ca:	8526                	mv	a0,s1
    800038cc:	d76ff0ef          	jal	ra,80002e42 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038d0:	013d09bb          	addw	s3,s10,s3
    800038d4:	012d093b          	addw	s2,s10,s2
    800038d8:	9a6e                	add	s4,s4,s11
    800038da:	0569f063          	bgeu	s3,s6,8000391a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038de:	00a9559b          	srliw	a1,s2,0xa
    800038e2:	8556                	mv	a0,s5
    800038e4:	fd0ff0ef          	jal	ra,800030b4 <bmap>
    800038e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038ec:	c59d                	beqz	a1,8000391a <writei+0xbe>
    bp = bread(ip->dev, addr);
    800038ee:	000aa503          	lw	a0,0(s5)
    800038f2:	c48ff0ef          	jal	ra,80002d3a <bread>
    800038f6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038f8:	3ff97713          	andi	a4,s2,1023
    800038fc:	40ec87bb          	subw	a5,s9,a4
    80003900:	413b06bb          	subw	a3,s6,s3
    80003904:	8d3e                	mv	s10,a5
    80003906:	2781                	sext.w	a5,a5
    80003908:	0006861b          	sext.w	a2,a3
    8000390c:	f8f67ee3          	bgeu	a2,a5,800038a8 <writei+0x4c>
    80003910:	8d36                	mv	s10,a3
    80003912:	bf59                	j	800038a8 <writei+0x4c>
      brelse(bp);
    80003914:	8526                	mv	a0,s1
    80003916:	d2cff0ef          	jal	ra,80002e42 <brelse>
  }

  if(off > ip->size)
    8000391a:	04caa783          	lw	a5,76(s5)
    8000391e:	0127f463          	bgeu	a5,s2,80003926 <writei+0xca>
    ip->size = off;
    80003922:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003926:	8556                	mv	a0,s5
    80003928:	a13ff0ef          	jal	ra,8000333a <iupdate>

  return tot;
    8000392c:	0009851b          	sext.w	a0,s3
}
    80003930:	70a6                	ld	ra,104(sp)
    80003932:	7406                	ld	s0,96(sp)
    80003934:	64e6                	ld	s1,88(sp)
    80003936:	6946                	ld	s2,80(sp)
    80003938:	69a6                	ld	s3,72(sp)
    8000393a:	6a06                	ld	s4,64(sp)
    8000393c:	7ae2                	ld	s5,56(sp)
    8000393e:	7b42                	ld	s6,48(sp)
    80003940:	7ba2                	ld	s7,40(sp)
    80003942:	7c02                	ld	s8,32(sp)
    80003944:	6ce2                	ld	s9,24(sp)
    80003946:	6d42                	ld	s10,16(sp)
    80003948:	6da2                	ld	s11,8(sp)
    8000394a:	6165                	addi	sp,sp,112
    8000394c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000394e:	89da                	mv	s3,s6
    80003950:	bfd9                	j	80003926 <writei+0xca>
    return -1;
    80003952:	557d                	li	a0,-1
}
    80003954:	8082                	ret
    return -1;
    80003956:	557d                	li	a0,-1
    80003958:	bfe1                	j	80003930 <writei+0xd4>
    return -1;
    8000395a:	557d                	li	a0,-1
    8000395c:	bfd1                	j	80003930 <writei+0xd4>

000000008000395e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000395e:	1141                	addi	sp,sp,-16
    80003960:	e406                	sd	ra,8(sp)
    80003962:	e022                	sd	s0,0(sp)
    80003964:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003966:	4639                	li	a2,14
    80003968:	bbafd0ef          	jal	ra,80000d22 <strncmp>
}
    8000396c:	60a2                	ld	ra,8(sp)
    8000396e:	6402                	ld	s0,0(sp)
    80003970:	0141                	addi	sp,sp,16
    80003972:	8082                	ret

0000000080003974 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003974:	7139                	addi	sp,sp,-64
    80003976:	fc06                	sd	ra,56(sp)
    80003978:	f822                	sd	s0,48(sp)
    8000397a:	f426                	sd	s1,40(sp)
    8000397c:	f04a                	sd	s2,32(sp)
    8000397e:	ec4e                	sd	s3,24(sp)
    80003980:	e852                	sd	s4,16(sp)
    80003982:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003984:	04451703          	lh	a4,68(a0)
    80003988:	4785                	li	a5,1
    8000398a:	00f71a63          	bne	a4,a5,8000399e <dirlookup+0x2a>
    8000398e:	892a                	mv	s2,a0
    80003990:	89ae                	mv	s3,a1
    80003992:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003994:	457c                	lw	a5,76(a0)
    80003996:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003998:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000399a:	e39d                	bnez	a5,800039c0 <dirlookup+0x4c>
    8000399c:	a095                	j	80003a00 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000399e:	00004517          	auipc	a0,0x4
    800039a2:	cd250513          	addi	a0,a0,-814 # 80007670 <syscalls+0x1d0>
    800039a6:	debfc0ef          	jal	ra,80000790 <panic>
      panic("dirlookup read");
    800039aa:	00004517          	auipc	a0,0x4
    800039ae:	cde50513          	addi	a0,a0,-802 # 80007688 <syscalls+0x1e8>
    800039b2:	ddffc0ef          	jal	ra,80000790 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039b6:	24c1                	addiw	s1,s1,16
    800039b8:	04c92783          	lw	a5,76(s2)
    800039bc:	04f4f163          	bgeu	s1,a5,800039fe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039c0:	4741                	li	a4,16
    800039c2:	86a6                	mv	a3,s1
    800039c4:	fc040613          	addi	a2,s0,-64
    800039c8:	4581                	li	a1,0
    800039ca:	854a                	mv	a0,s2
    800039cc:	dadff0ef          	jal	ra,80003778 <readi>
    800039d0:	47c1                	li	a5,16
    800039d2:	fcf51ce3          	bne	a0,a5,800039aa <dirlookup+0x36>
    if(de.inum == 0)
    800039d6:	fc045783          	lhu	a5,-64(s0)
    800039da:	dff1                	beqz	a5,800039b6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800039dc:	fc240593          	addi	a1,s0,-62
    800039e0:	854e                	mv	a0,s3
    800039e2:	f7dff0ef          	jal	ra,8000395e <namecmp>
    800039e6:	f961                	bnez	a0,800039b6 <dirlookup+0x42>
      if(poff)
    800039e8:	000a0463          	beqz	s4,800039f0 <dirlookup+0x7c>
        *poff = off;
    800039ec:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039f0:	fc045583          	lhu	a1,-64(s0)
    800039f4:	00092503          	lw	a0,0(s2)
    800039f8:	f88ff0ef          	jal	ra,80003180 <iget>
    800039fc:	a011                	j	80003a00 <dirlookup+0x8c>
  return 0;
    800039fe:	4501                	li	a0,0
}
    80003a00:	70e2                	ld	ra,56(sp)
    80003a02:	7442                	ld	s0,48(sp)
    80003a04:	74a2                	ld	s1,40(sp)
    80003a06:	7902                	ld	s2,32(sp)
    80003a08:	69e2                	ld	s3,24(sp)
    80003a0a:	6a42                	ld	s4,16(sp)
    80003a0c:	6121                	addi	sp,sp,64
    80003a0e:	8082                	ret

0000000080003a10 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a10:	711d                	addi	sp,sp,-96
    80003a12:	ec86                	sd	ra,88(sp)
    80003a14:	e8a2                	sd	s0,80(sp)
    80003a16:	e4a6                	sd	s1,72(sp)
    80003a18:	e0ca                	sd	s2,64(sp)
    80003a1a:	fc4e                	sd	s3,56(sp)
    80003a1c:	f852                	sd	s4,48(sp)
    80003a1e:	f456                	sd	s5,40(sp)
    80003a20:	f05a                	sd	s6,32(sp)
    80003a22:	ec5e                	sd	s7,24(sp)
    80003a24:	e862                	sd	s8,16(sp)
    80003a26:	e466                	sd	s9,8(sp)
    80003a28:	1080                	addi	s0,sp,96
    80003a2a:	84aa                	mv	s1,a0
    80003a2c:	8b2e                	mv	s6,a1
    80003a2e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a30:	00054703          	lbu	a4,0(a0)
    80003a34:	02f00793          	li	a5,47
    80003a38:	00f70f63          	beq	a4,a5,80003a56 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a3c:	ddffd0ef          	jal	ra,8000181a <myproc>
    80003a40:	15053503          	ld	a0,336(a0)
    80003a44:	973ff0ef          	jal	ra,800033b6 <idup>
    80003a48:	89aa                	mv	s3,a0
  while(*path == '/')
    80003a4a:	02f00913          	li	s2,47
  len = path - s;
    80003a4e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003a50:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a52:	4c05                	li	s8,1
    80003a54:	a861                	j	80003aec <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80003a56:	4585                	li	a1,1
    80003a58:	4505                	li	a0,1
    80003a5a:	f26ff0ef          	jal	ra,80003180 <iget>
    80003a5e:	89aa                	mv	s3,a0
    80003a60:	b7ed                	j	80003a4a <namex+0x3a>
      iunlockput(ip);
    80003a62:	854e                	mv	a0,s3
    80003a64:	b8fff0ef          	jal	ra,800035f2 <iunlockput>
      return 0;
    80003a68:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a6a:	854e                	mv	a0,s3
    80003a6c:	60e6                	ld	ra,88(sp)
    80003a6e:	6446                	ld	s0,80(sp)
    80003a70:	64a6                	ld	s1,72(sp)
    80003a72:	6906                	ld	s2,64(sp)
    80003a74:	79e2                	ld	s3,56(sp)
    80003a76:	7a42                	ld	s4,48(sp)
    80003a78:	7aa2                	ld	s5,40(sp)
    80003a7a:	7b02                	ld	s6,32(sp)
    80003a7c:	6be2                	ld	s7,24(sp)
    80003a7e:	6c42                	ld	s8,16(sp)
    80003a80:	6ca2                	ld	s9,8(sp)
    80003a82:	6125                	addi	sp,sp,96
    80003a84:	8082                	ret
      iunlock(ip);
    80003a86:	854e                	mv	a0,s3
    80003a88:	a0fff0ef          	jal	ra,80003496 <iunlock>
      return ip;
    80003a8c:	bff9                	j	80003a6a <namex+0x5a>
      iunlockput(ip);
    80003a8e:	854e                	mv	a0,s3
    80003a90:	b63ff0ef          	jal	ra,800035f2 <iunlockput>
      return 0;
    80003a94:	89d2                	mv	s3,s4
    80003a96:	bfd1                	j	80003a6a <namex+0x5a>
  len = path - s;
    80003a98:	40b48633          	sub	a2,s1,a1
    80003a9c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003aa0:	074cdc63          	bge	s9,s4,80003b18 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003aa4:	4639                	li	a2,14
    80003aa6:	8556                	mv	a0,s5
    80003aa8:	a06fd0ef          	jal	ra,80000cae <memmove>
  while(*path == '/')
    80003aac:	0004c783          	lbu	a5,0(s1)
    80003ab0:	01279763          	bne	a5,s2,80003abe <namex+0xae>
    path++;
    80003ab4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ab6:	0004c783          	lbu	a5,0(s1)
    80003aba:	ff278de3          	beq	a5,s2,80003ab4 <namex+0xa4>
    ilock(ip);
    80003abe:	854e                	mv	a0,s3
    80003ac0:	92dff0ef          	jal	ra,800033ec <ilock>
    if(ip->type != T_DIR){
    80003ac4:	04499783          	lh	a5,68(s3)
    80003ac8:	f9879de3          	bne	a5,s8,80003a62 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003acc:	000b0563          	beqz	s6,80003ad6 <namex+0xc6>
    80003ad0:	0004c783          	lbu	a5,0(s1)
    80003ad4:	dbcd                	beqz	a5,80003a86 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ad6:	865e                	mv	a2,s7
    80003ad8:	85d6                	mv	a1,s5
    80003ada:	854e                	mv	a0,s3
    80003adc:	e99ff0ef          	jal	ra,80003974 <dirlookup>
    80003ae0:	8a2a                	mv	s4,a0
    80003ae2:	d555                	beqz	a0,80003a8e <namex+0x7e>
    iunlockput(ip);
    80003ae4:	854e                	mv	a0,s3
    80003ae6:	b0dff0ef          	jal	ra,800035f2 <iunlockput>
    ip = next;
    80003aea:	89d2                	mv	s3,s4
  while(*path == '/')
    80003aec:	0004c783          	lbu	a5,0(s1)
    80003af0:	05279363          	bne	a5,s2,80003b36 <namex+0x126>
    path++;
    80003af4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003af6:	0004c783          	lbu	a5,0(s1)
    80003afa:	ff278de3          	beq	a5,s2,80003af4 <namex+0xe4>
  if(*path == 0)
    80003afe:	c78d                	beqz	a5,80003b28 <namex+0x118>
    path++;
    80003b00:	85a6                	mv	a1,s1
  len = path - s;
    80003b02:	8a5e                	mv	s4,s7
    80003b04:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003b06:	01278963          	beq	a5,s2,80003b18 <namex+0x108>
    80003b0a:	d7d9                	beqz	a5,80003a98 <namex+0x88>
    path++;
    80003b0c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003b0e:	0004c783          	lbu	a5,0(s1)
    80003b12:	ff279ce3          	bne	a5,s2,80003b0a <namex+0xfa>
    80003b16:	b749                	j	80003a98 <namex+0x88>
    memmove(name, s, len);
    80003b18:	2601                	sext.w	a2,a2
    80003b1a:	8556                	mv	a0,s5
    80003b1c:	992fd0ef          	jal	ra,80000cae <memmove>
    name[len] = 0;
    80003b20:	9a56                	add	s4,s4,s5
    80003b22:	000a0023          	sb	zero,0(s4)
    80003b26:	b759                	j	80003aac <namex+0x9c>
  if(nameiparent){
    80003b28:	f40b01e3          	beqz	s6,80003a6a <namex+0x5a>
    iput(ip);
    80003b2c:	854e                	mv	a0,s3
    80003b2e:	a3dff0ef          	jal	ra,8000356a <iput>
    return 0;
    80003b32:	4981                	li	s3,0
    80003b34:	bf1d                	j	80003a6a <namex+0x5a>
  if(*path == 0)
    80003b36:	dbed                	beqz	a5,80003b28 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003b38:	0004c783          	lbu	a5,0(s1)
    80003b3c:	85a6                	mv	a1,s1
    80003b3e:	b7f1                	j	80003b0a <namex+0xfa>

0000000080003b40 <dirlink>:
{
    80003b40:	7139                	addi	sp,sp,-64
    80003b42:	fc06                	sd	ra,56(sp)
    80003b44:	f822                	sd	s0,48(sp)
    80003b46:	f426                	sd	s1,40(sp)
    80003b48:	f04a                	sd	s2,32(sp)
    80003b4a:	ec4e                	sd	s3,24(sp)
    80003b4c:	e852                	sd	s4,16(sp)
    80003b4e:	0080                	addi	s0,sp,64
    80003b50:	892a                	mv	s2,a0
    80003b52:	8a2e                	mv	s4,a1
    80003b54:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b56:	4601                	li	a2,0
    80003b58:	e1dff0ef          	jal	ra,80003974 <dirlookup>
    80003b5c:	e52d                	bnez	a0,80003bc6 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b5e:	04c92483          	lw	s1,76(s2)
    80003b62:	c48d                	beqz	s1,80003b8c <dirlink+0x4c>
    80003b64:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b66:	4741                	li	a4,16
    80003b68:	86a6                	mv	a3,s1
    80003b6a:	fc040613          	addi	a2,s0,-64
    80003b6e:	4581                	li	a1,0
    80003b70:	854a                	mv	a0,s2
    80003b72:	c07ff0ef          	jal	ra,80003778 <readi>
    80003b76:	47c1                	li	a5,16
    80003b78:	04f51b63          	bne	a0,a5,80003bce <dirlink+0x8e>
    if(de.inum == 0)
    80003b7c:	fc045783          	lhu	a5,-64(s0)
    80003b80:	c791                	beqz	a5,80003b8c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b82:	24c1                	addiw	s1,s1,16
    80003b84:	04c92783          	lw	a5,76(s2)
    80003b88:	fcf4efe3          	bltu	s1,a5,80003b66 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b8c:	4639                	li	a2,14
    80003b8e:	85d2                	mv	a1,s4
    80003b90:	fc240513          	addi	a0,s0,-62
    80003b94:	9cafd0ef          	jal	ra,80000d5e <strncpy>
  de.inum = inum;
    80003b98:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9c:	4741                	li	a4,16
    80003b9e:	86a6                	mv	a3,s1
    80003ba0:	fc040613          	addi	a2,s0,-64
    80003ba4:	4581                	li	a1,0
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	cb5ff0ef          	jal	ra,8000385c <writei>
    80003bac:	1541                	addi	a0,a0,-16
    80003bae:	00a03533          	snez	a0,a0
    80003bb2:	40a00533          	neg	a0,a0
}
    80003bb6:	70e2                	ld	ra,56(sp)
    80003bb8:	7442                	ld	s0,48(sp)
    80003bba:	74a2                	ld	s1,40(sp)
    80003bbc:	7902                	ld	s2,32(sp)
    80003bbe:	69e2                	ld	s3,24(sp)
    80003bc0:	6a42                	ld	s4,16(sp)
    80003bc2:	6121                	addi	sp,sp,64
    80003bc4:	8082                	ret
    iput(ip);
    80003bc6:	9a5ff0ef          	jal	ra,8000356a <iput>
    return -1;
    80003bca:	557d                	li	a0,-1
    80003bcc:	b7ed                	j	80003bb6 <dirlink+0x76>
      panic("dirlink read");
    80003bce:	00004517          	auipc	a0,0x4
    80003bd2:	aca50513          	addi	a0,a0,-1334 # 80007698 <syscalls+0x1f8>
    80003bd6:	bbbfc0ef          	jal	ra,80000790 <panic>

0000000080003bda <namei>:

struct inode*
namei(char *path)
{
    80003bda:	1101                	addi	sp,sp,-32
    80003bdc:	ec06                	sd	ra,24(sp)
    80003bde:	e822                	sd	s0,16(sp)
    80003be0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003be2:	fe040613          	addi	a2,s0,-32
    80003be6:	4581                	li	a1,0
    80003be8:	e29ff0ef          	jal	ra,80003a10 <namex>
}
    80003bec:	60e2                	ld	ra,24(sp)
    80003bee:	6442                	ld	s0,16(sp)
    80003bf0:	6105                	addi	sp,sp,32
    80003bf2:	8082                	ret

0000000080003bf4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bf4:	1141                	addi	sp,sp,-16
    80003bf6:	e406                	sd	ra,8(sp)
    80003bf8:	e022                	sd	s0,0(sp)
    80003bfa:	0800                	addi	s0,sp,16
    80003bfc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bfe:	4585                	li	a1,1
    80003c00:	e11ff0ef          	jal	ra,80003a10 <namex>
}
    80003c04:	60a2                	ld	ra,8(sp)
    80003c06:	6402                	ld	s0,0(sp)
    80003c08:	0141                	addi	sp,sp,16
    80003c0a:	8082                	ret

0000000080003c0c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c0c:	1101                	addi	sp,sp,-32
    80003c0e:	ec06                	sd	ra,24(sp)
    80003c10:	e822                	sd	s0,16(sp)
    80003c12:	e426                	sd	s1,8(sp)
    80003c14:	e04a                	sd	s2,0(sp)
    80003c16:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c18:	0001c917          	auipc	s2,0x1c
    80003c1c:	20090913          	addi	s2,s2,512 # 8001fe18 <log>
    80003c20:	01892583          	lw	a1,24(s2)
    80003c24:	02492503          	lw	a0,36(s2)
    80003c28:	912ff0ef          	jal	ra,80002d3a <bread>
    80003c2c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c2e:	02892683          	lw	a3,40(s2)
    80003c32:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c34:	02d05763          	blez	a3,80003c62 <write_head+0x56>
    80003c38:	0001c797          	auipc	a5,0x1c
    80003c3c:	20c78793          	addi	a5,a5,524 # 8001fe44 <log+0x2c>
    80003c40:	05c50713          	addi	a4,a0,92
    80003c44:	36fd                	addiw	a3,a3,-1
    80003c46:	1682                	slli	a3,a3,0x20
    80003c48:	9281                	srli	a3,a3,0x20
    80003c4a:	068a                	slli	a3,a3,0x2
    80003c4c:	0001c617          	auipc	a2,0x1c
    80003c50:	1fc60613          	addi	a2,a2,508 # 8001fe48 <log+0x30>
    80003c54:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003c56:	4390                	lw	a2,0(a5)
    80003c58:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c5a:	0791                	addi	a5,a5,4
    80003c5c:	0711                	addi	a4,a4,4
    80003c5e:	fed79ce3          	bne	a5,a3,80003c56 <write_head+0x4a>
  }
  bwrite(buf);
    80003c62:	8526                	mv	a0,s1
    80003c64:	9acff0ef          	jal	ra,80002e10 <bwrite>
  brelse(buf);
    80003c68:	8526                	mv	a0,s1
    80003c6a:	9d8ff0ef          	jal	ra,80002e42 <brelse>
}
    80003c6e:	60e2                	ld	ra,24(sp)
    80003c70:	6442                	ld	s0,16(sp)
    80003c72:	64a2                	ld	s1,8(sp)
    80003c74:	6902                	ld	s2,0(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret

0000000080003c7a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c7a:	0001c797          	auipc	a5,0x1c
    80003c7e:	1c67a783          	lw	a5,454(a5) # 8001fe40 <log+0x28>
    80003c82:	0af05e63          	blez	a5,80003d3e <install_trans+0xc4>
{
    80003c86:	715d                	addi	sp,sp,-80
    80003c88:	e486                	sd	ra,72(sp)
    80003c8a:	e0a2                	sd	s0,64(sp)
    80003c8c:	fc26                	sd	s1,56(sp)
    80003c8e:	f84a                	sd	s2,48(sp)
    80003c90:	f44e                	sd	s3,40(sp)
    80003c92:	f052                	sd	s4,32(sp)
    80003c94:	ec56                	sd	s5,24(sp)
    80003c96:	e85a                	sd	s6,16(sp)
    80003c98:	e45e                	sd	s7,8(sp)
    80003c9a:	0880                	addi	s0,sp,80
    80003c9c:	8b2a                	mv	s6,a0
    80003c9e:	0001ca97          	auipc	s5,0x1c
    80003ca2:	1a6a8a93          	addi	s5,s5,422 # 8001fe44 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ca6:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ca8:	00004b97          	auipc	s7,0x4
    80003cac:	a00b8b93          	addi	s7,s7,-1536 # 800076a8 <syscalls+0x208>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cb0:	0001ca17          	auipc	s4,0x1c
    80003cb4:	168a0a13          	addi	s4,s4,360 # 8001fe18 <log>
    80003cb8:	a03d                	j	80003ce6 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cba:	000aa603          	lw	a2,0(s5)
    80003cbe:	85ce                	mv	a1,s3
    80003cc0:	855e                	mv	a0,s7
    80003cc2:	809fc0ef          	jal	ra,800004ca <printf>
    80003cc6:	a015                	j	80003cea <install_trans+0x70>
      bunpin(dbuf);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	a36ff0ef          	jal	ra,80002f00 <bunpin>
    brelse(lbuf);
    80003cce:	854a                	mv	a0,s2
    80003cd0:	972ff0ef          	jal	ra,80002e42 <brelse>
    brelse(dbuf);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	96cff0ef          	jal	ra,80002e42 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cda:	2985                	addiw	s3,s3,1
    80003cdc:	0a91                	addi	s5,s5,4
    80003cde:	028a2783          	lw	a5,40(s4)
    80003ce2:	04f9d363          	bge	s3,a5,80003d28 <install_trans+0xae>
    if(recovering) {
    80003ce6:	fc0b1ae3          	bnez	s6,80003cba <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cea:	018a2583          	lw	a1,24(s4)
    80003cee:	013585bb          	addw	a1,a1,s3
    80003cf2:	2585                	addiw	a1,a1,1
    80003cf4:	024a2503          	lw	a0,36(s4)
    80003cf8:	842ff0ef          	jal	ra,80002d3a <bread>
    80003cfc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cfe:	000aa583          	lw	a1,0(s5)
    80003d02:	024a2503          	lw	a0,36(s4)
    80003d06:	834ff0ef          	jal	ra,80002d3a <bread>
    80003d0a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d0c:	40000613          	li	a2,1024
    80003d10:	05890593          	addi	a1,s2,88
    80003d14:	05850513          	addi	a0,a0,88
    80003d18:	f97fc0ef          	jal	ra,80000cae <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d1c:	8526                	mv	a0,s1
    80003d1e:	8f2ff0ef          	jal	ra,80002e10 <bwrite>
    if(recovering == 0)
    80003d22:	fa0b16e3          	bnez	s6,80003cce <install_trans+0x54>
    80003d26:	b74d                	j	80003cc8 <install_trans+0x4e>
}
    80003d28:	60a6                	ld	ra,72(sp)
    80003d2a:	6406                	ld	s0,64(sp)
    80003d2c:	74e2                	ld	s1,56(sp)
    80003d2e:	7942                	ld	s2,48(sp)
    80003d30:	79a2                	ld	s3,40(sp)
    80003d32:	7a02                	ld	s4,32(sp)
    80003d34:	6ae2                	ld	s5,24(sp)
    80003d36:	6b42                	ld	s6,16(sp)
    80003d38:	6ba2                	ld	s7,8(sp)
    80003d3a:	6161                	addi	sp,sp,80
    80003d3c:	8082                	ret
    80003d3e:	8082                	ret

0000000080003d40 <initlog>:
{
    80003d40:	7179                	addi	sp,sp,-48
    80003d42:	f406                	sd	ra,40(sp)
    80003d44:	f022                	sd	s0,32(sp)
    80003d46:	ec26                	sd	s1,24(sp)
    80003d48:	e84a                	sd	s2,16(sp)
    80003d4a:	e44e                	sd	s3,8(sp)
    80003d4c:	1800                	addi	s0,sp,48
    80003d4e:	892a                	mv	s2,a0
    80003d50:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d52:	0001c497          	auipc	s1,0x1c
    80003d56:	0c648493          	addi	s1,s1,198 # 8001fe18 <log>
    80003d5a:	00004597          	auipc	a1,0x4
    80003d5e:	96e58593          	addi	a1,a1,-1682 # 800076c8 <syscalls+0x228>
    80003d62:	8526                	mv	a0,s1
    80003d64:	d97fc0ef          	jal	ra,80000afa <initlock>
  log.start = sb->logstart;
    80003d68:	0149a583          	lw	a1,20(s3)
    80003d6c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d6e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d72:	854a                	mv	a0,s2
    80003d74:	fc7fe0ef          	jal	ra,80002d3a <bread>
  log.lh.n = lh->n;
    80003d78:	4d3c                	lw	a5,88(a0)
    80003d7a:	d49c                	sw	a5,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d7c:	02f05563          	blez	a5,80003da6 <initlog+0x66>
    80003d80:	05c50713          	addi	a4,a0,92
    80003d84:	0001c697          	auipc	a3,0x1c
    80003d88:	0c068693          	addi	a3,a3,192 # 8001fe44 <log+0x2c>
    80003d8c:	37fd                	addiw	a5,a5,-1
    80003d8e:	1782                	slli	a5,a5,0x20
    80003d90:	9381                	srli	a5,a5,0x20
    80003d92:	078a                	slli	a5,a5,0x2
    80003d94:	06050613          	addi	a2,a0,96
    80003d98:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003d9a:	4310                	lw	a2,0(a4)
    80003d9c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003d9e:	0711                	addi	a4,a4,4
    80003da0:	0691                	addi	a3,a3,4
    80003da2:	fef71ce3          	bne	a4,a5,80003d9a <initlog+0x5a>
  brelse(buf);
    80003da6:	89cff0ef          	jal	ra,80002e42 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003daa:	4505                	li	a0,1
    80003dac:	ecfff0ef          	jal	ra,80003c7a <install_trans>
  log.lh.n = 0;
    80003db0:	0001c797          	auipc	a5,0x1c
    80003db4:	0807a823          	sw	zero,144(a5) # 8001fe40 <log+0x28>
  write_head(); // clear the log
    80003db8:	e55ff0ef          	jal	ra,80003c0c <write_head>
}
    80003dbc:	70a2                	ld	ra,40(sp)
    80003dbe:	7402                	ld	s0,32(sp)
    80003dc0:	64e2                	ld	s1,24(sp)
    80003dc2:	6942                	ld	s2,16(sp)
    80003dc4:	69a2                	ld	s3,8(sp)
    80003dc6:	6145                	addi	sp,sp,48
    80003dc8:	8082                	ret

0000000080003dca <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003dca:	1101                	addi	sp,sp,-32
    80003dcc:	ec06                	sd	ra,24(sp)
    80003dce:	e822                	sd	s0,16(sp)
    80003dd0:	e426                	sd	s1,8(sp)
    80003dd2:	e04a                	sd	s2,0(sp)
    80003dd4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dd6:	0001c517          	auipc	a0,0x1c
    80003dda:	04250513          	addi	a0,a0,66 # 8001fe18 <log>
    80003dde:	d9dfc0ef          	jal	ra,80000b7a <acquire>
  while(1){
    if(log.committing){
    80003de2:	0001c497          	auipc	s1,0x1c
    80003de6:	03648493          	addi	s1,s1,54 # 8001fe18 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dea:	4979                	li	s2,30
    80003dec:	a029                	j	80003df6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003dee:	85a6                	mv	a1,s1
    80003df0:	8526                	mv	a0,s1
    80003df2:	93efe0ef          	jal	ra,80001f30 <sleep>
    if(log.committing){
    80003df6:	509c                	lw	a5,32(s1)
    80003df8:	fbfd                	bnez	a5,80003dee <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dfa:	4cdc                	lw	a5,28(s1)
    80003dfc:	0017871b          	addiw	a4,a5,1
    80003e00:	0007069b          	sext.w	a3,a4
    80003e04:	0027179b          	slliw	a5,a4,0x2
    80003e08:	9fb9                	addw	a5,a5,a4
    80003e0a:	0017979b          	slliw	a5,a5,0x1
    80003e0e:	5498                	lw	a4,40(s1)
    80003e10:	9fb9                	addw	a5,a5,a4
    80003e12:	00f95763          	bge	s2,a5,80003e20 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e16:	85a6                	mv	a1,s1
    80003e18:	8526                	mv	a0,s1
    80003e1a:	916fe0ef          	jal	ra,80001f30 <sleep>
    80003e1e:	bfe1                	j	80003df6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e20:	0001c517          	auipc	a0,0x1c
    80003e24:	ff850513          	addi	a0,a0,-8 # 8001fe18 <log>
    80003e28:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003e2a:	de9fc0ef          	jal	ra,80000c12 <release>
      break;
    }
  }
}
    80003e2e:	60e2                	ld	ra,24(sp)
    80003e30:	6442                	ld	s0,16(sp)
    80003e32:	64a2                	ld	s1,8(sp)
    80003e34:	6902                	ld	s2,0(sp)
    80003e36:	6105                	addi	sp,sp,32
    80003e38:	8082                	ret

0000000080003e3a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e3a:	7139                	addi	sp,sp,-64
    80003e3c:	fc06                	sd	ra,56(sp)
    80003e3e:	f822                	sd	s0,48(sp)
    80003e40:	f426                	sd	s1,40(sp)
    80003e42:	f04a                	sd	s2,32(sp)
    80003e44:	ec4e                	sd	s3,24(sp)
    80003e46:	e852                	sd	s4,16(sp)
    80003e48:	e456                	sd	s5,8(sp)
    80003e4a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e4c:	0001c497          	auipc	s1,0x1c
    80003e50:	fcc48493          	addi	s1,s1,-52 # 8001fe18 <log>
    80003e54:	8526                	mv	a0,s1
    80003e56:	d25fc0ef          	jal	ra,80000b7a <acquire>
  log.outstanding -= 1;
    80003e5a:	4cdc                	lw	a5,28(s1)
    80003e5c:	37fd                	addiw	a5,a5,-1
    80003e5e:	0007891b          	sext.w	s2,a5
    80003e62:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e64:	509c                	lw	a5,32(s1)
    80003e66:	e7b9                	bnez	a5,80003eb4 <end_op+0x7a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e68:	04091c63          	bnez	s2,80003ec0 <end_op+0x86>
    do_commit = 1;
    log.committing = 1;
    80003e6c:	0001c497          	auipc	s1,0x1c
    80003e70:	fac48493          	addi	s1,s1,-84 # 8001fe18 <log>
    80003e74:	4785                	li	a5,1
    80003e76:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e78:	8526                	mv	a0,s1
    80003e7a:	d99fc0ef          	jal	ra,80000c12 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e7e:	549c                	lw	a5,40(s1)
    80003e80:	04f04b63          	bgtz	a5,80003ed6 <end_op+0x9c>
    acquire(&log.lock);
    80003e84:	0001c497          	auipc	s1,0x1c
    80003e88:	f9448493          	addi	s1,s1,-108 # 8001fe18 <log>
    80003e8c:	8526                	mv	a0,s1
    80003e8e:	cedfc0ef          	jal	ra,80000b7a <acquire>
    log.committing = 0;
    80003e92:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e96:	8526                	mv	a0,s1
    80003e98:	8e4fe0ef          	jal	ra,80001f7c <wakeup>
    release(&log.lock);
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	d75fc0ef          	jal	ra,80000c12 <release>
}
    80003ea2:	70e2                	ld	ra,56(sp)
    80003ea4:	7442                	ld	s0,48(sp)
    80003ea6:	74a2                	ld	s1,40(sp)
    80003ea8:	7902                	ld	s2,32(sp)
    80003eaa:	69e2                	ld	s3,24(sp)
    80003eac:	6a42                	ld	s4,16(sp)
    80003eae:	6aa2                	ld	s5,8(sp)
    80003eb0:	6121                	addi	sp,sp,64
    80003eb2:	8082                	ret
    panic("log.committing");
    80003eb4:	00004517          	auipc	a0,0x4
    80003eb8:	81c50513          	addi	a0,a0,-2020 # 800076d0 <syscalls+0x230>
    80003ebc:	8d5fc0ef          	jal	ra,80000790 <panic>
    wakeup(&log);
    80003ec0:	0001c497          	auipc	s1,0x1c
    80003ec4:	f5848493          	addi	s1,s1,-168 # 8001fe18 <log>
    80003ec8:	8526                	mv	a0,s1
    80003eca:	8b2fe0ef          	jal	ra,80001f7c <wakeup>
  release(&log.lock);
    80003ece:	8526                	mv	a0,s1
    80003ed0:	d43fc0ef          	jal	ra,80000c12 <release>
  if(do_commit){
    80003ed4:	b7f9                	j	80003ea2 <end_op+0x68>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed6:	0001ca97          	auipc	s5,0x1c
    80003eda:	f6ea8a93          	addi	s5,s5,-146 # 8001fe44 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ede:	0001ca17          	auipc	s4,0x1c
    80003ee2:	f3aa0a13          	addi	s4,s4,-198 # 8001fe18 <log>
    80003ee6:	018a2583          	lw	a1,24(s4)
    80003eea:	012585bb          	addw	a1,a1,s2
    80003eee:	2585                	addiw	a1,a1,1
    80003ef0:	024a2503          	lw	a0,36(s4)
    80003ef4:	e47fe0ef          	jal	ra,80002d3a <bread>
    80003ef8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003efa:	000aa583          	lw	a1,0(s5)
    80003efe:	024a2503          	lw	a0,36(s4)
    80003f02:	e39fe0ef          	jal	ra,80002d3a <bread>
    80003f06:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f08:	40000613          	li	a2,1024
    80003f0c:	05850593          	addi	a1,a0,88
    80003f10:	05848513          	addi	a0,s1,88
    80003f14:	d9bfc0ef          	jal	ra,80000cae <memmove>
    bwrite(to);  // write the log
    80003f18:	8526                	mv	a0,s1
    80003f1a:	ef7fe0ef          	jal	ra,80002e10 <bwrite>
    brelse(from);
    80003f1e:	854e                	mv	a0,s3
    80003f20:	f23fe0ef          	jal	ra,80002e42 <brelse>
    brelse(to);
    80003f24:	8526                	mv	a0,s1
    80003f26:	f1dfe0ef          	jal	ra,80002e42 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2a:	2905                	addiw	s2,s2,1
    80003f2c:	0a91                	addi	s5,s5,4
    80003f2e:	028a2783          	lw	a5,40(s4)
    80003f32:	faf94ae3          	blt	s2,a5,80003ee6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f36:	cd7ff0ef          	jal	ra,80003c0c <write_head>
    install_trans(0); // Now install writes to home locations
    80003f3a:	4501                	li	a0,0
    80003f3c:	d3fff0ef          	jal	ra,80003c7a <install_trans>
    log.lh.n = 0;
    80003f40:	0001c797          	auipc	a5,0x1c
    80003f44:	f007a023          	sw	zero,-256(a5) # 8001fe40 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f48:	cc5ff0ef          	jal	ra,80003c0c <write_head>
    80003f4c:	bf25                	j	80003e84 <end_op+0x4a>

0000000080003f4e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f4e:	1101                	addi	sp,sp,-32
    80003f50:	ec06                	sd	ra,24(sp)
    80003f52:	e822                	sd	s0,16(sp)
    80003f54:	e426                	sd	s1,8(sp)
    80003f56:	e04a                	sd	s2,0(sp)
    80003f58:	1000                	addi	s0,sp,32
    80003f5a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f5c:	0001c917          	auipc	s2,0x1c
    80003f60:	ebc90913          	addi	s2,s2,-324 # 8001fe18 <log>
    80003f64:	854a                	mv	a0,s2
    80003f66:	c15fc0ef          	jal	ra,80000b7a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f6a:	02892603          	lw	a2,40(s2)
    80003f6e:	47f5                	li	a5,29
    80003f70:	04c7cc63          	blt	a5,a2,80003fc8 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f74:	0001c797          	auipc	a5,0x1c
    80003f78:	ec07a783          	lw	a5,-320(a5) # 8001fe34 <log+0x1c>
    80003f7c:	04f05c63          	blez	a5,80003fd4 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f80:	4781                	li	a5,0
    80003f82:	04c05f63          	blez	a2,80003fe0 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f86:	44cc                	lw	a1,12(s1)
    80003f88:	0001c717          	auipc	a4,0x1c
    80003f8c:	ebc70713          	addi	a4,a4,-324 # 8001fe44 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f90:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f92:	4314                	lw	a3,0(a4)
    80003f94:	04b68663          	beq	a3,a1,80003fe0 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f98:	2785                	addiw	a5,a5,1
    80003f9a:	0711                	addi	a4,a4,4
    80003f9c:	fef61be3          	bne	a2,a5,80003f92 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fa0:	0621                	addi	a2,a2,8
    80003fa2:	060a                	slli	a2,a2,0x2
    80003fa4:	0001c797          	auipc	a5,0x1c
    80003fa8:	e7478793          	addi	a5,a5,-396 # 8001fe18 <log>
    80003fac:	963e                	add	a2,a2,a5
    80003fae:	44dc                	lw	a5,12(s1)
    80003fb0:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003fb2:	8526                	mv	a0,s1
    80003fb4:	f19fe0ef          	jal	ra,80002ecc <bpin>
    log.lh.n++;
    80003fb8:	0001c717          	auipc	a4,0x1c
    80003fbc:	e6070713          	addi	a4,a4,-416 # 8001fe18 <log>
    80003fc0:	571c                	lw	a5,40(a4)
    80003fc2:	2785                	addiw	a5,a5,1
    80003fc4:	d71c                	sw	a5,40(a4)
    80003fc6:	a815                	j	80003ffa <log_write+0xac>
    panic("too big a transaction");
    80003fc8:	00003517          	auipc	a0,0x3
    80003fcc:	71850513          	addi	a0,a0,1816 # 800076e0 <syscalls+0x240>
    80003fd0:	fc0fc0ef          	jal	ra,80000790 <panic>
    panic("log_write outside of trans");
    80003fd4:	00003517          	auipc	a0,0x3
    80003fd8:	72450513          	addi	a0,a0,1828 # 800076f8 <syscalls+0x258>
    80003fdc:	fb4fc0ef          	jal	ra,80000790 <panic>
  log.lh.block[i] = b->blockno;
    80003fe0:	00878713          	addi	a4,a5,8
    80003fe4:	00271693          	slli	a3,a4,0x2
    80003fe8:	0001c717          	auipc	a4,0x1c
    80003fec:	e3070713          	addi	a4,a4,-464 # 8001fe18 <log>
    80003ff0:	9736                	add	a4,a4,a3
    80003ff2:	44d4                	lw	a3,12(s1)
    80003ff4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ff6:	faf60ee3          	beq	a2,a5,80003fb2 <log_write+0x64>
  }
  release(&log.lock);
    80003ffa:	0001c517          	auipc	a0,0x1c
    80003ffe:	e1e50513          	addi	a0,a0,-482 # 8001fe18 <log>
    80004002:	c11fc0ef          	jal	ra,80000c12 <release>
}
    80004006:	60e2                	ld	ra,24(sp)
    80004008:	6442                	ld	s0,16(sp)
    8000400a:	64a2                	ld	s1,8(sp)
    8000400c:	6902                	ld	s2,0(sp)
    8000400e:	6105                	addi	sp,sp,32
    80004010:	8082                	ret

0000000080004012 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004012:	1101                	addi	sp,sp,-32
    80004014:	ec06                	sd	ra,24(sp)
    80004016:	e822                	sd	s0,16(sp)
    80004018:	e426                	sd	s1,8(sp)
    8000401a:	e04a                	sd	s2,0(sp)
    8000401c:	1000                	addi	s0,sp,32
    8000401e:	84aa                	mv	s1,a0
    80004020:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004022:	00003597          	auipc	a1,0x3
    80004026:	6f658593          	addi	a1,a1,1782 # 80007718 <syscalls+0x278>
    8000402a:	0521                	addi	a0,a0,8
    8000402c:	acffc0ef          	jal	ra,80000afa <initlock>
  lk->name = name;
    80004030:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004034:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004038:	0204a423          	sw	zero,40(s1)
}
    8000403c:	60e2                	ld	ra,24(sp)
    8000403e:	6442                	ld	s0,16(sp)
    80004040:	64a2                	ld	s1,8(sp)
    80004042:	6902                	ld	s2,0(sp)
    80004044:	6105                	addi	sp,sp,32
    80004046:	8082                	ret

0000000080004048 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004048:	1101                	addi	sp,sp,-32
    8000404a:	ec06                	sd	ra,24(sp)
    8000404c:	e822                	sd	s0,16(sp)
    8000404e:	e426                	sd	s1,8(sp)
    80004050:	e04a                	sd	s2,0(sp)
    80004052:	1000                	addi	s0,sp,32
    80004054:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004056:	00850913          	addi	s2,a0,8
    8000405a:	854a                	mv	a0,s2
    8000405c:	b1ffc0ef          	jal	ra,80000b7a <acquire>
  while (lk->locked) {
    80004060:	409c                	lw	a5,0(s1)
    80004062:	c799                	beqz	a5,80004070 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004064:	85ca                	mv	a1,s2
    80004066:	8526                	mv	a0,s1
    80004068:	ec9fd0ef          	jal	ra,80001f30 <sleep>
  while (lk->locked) {
    8000406c:	409c                	lw	a5,0(s1)
    8000406e:	fbfd                	bnez	a5,80004064 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004070:	4785                	li	a5,1
    80004072:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004074:	fa6fd0ef          	jal	ra,8000181a <myproc>
    80004078:	591c                	lw	a5,48(a0)
    8000407a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000407c:	854a                	mv	a0,s2
    8000407e:	b95fc0ef          	jal	ra,80000c12 <release>
}
    80004082:	60e2                	ld	ra,24(sp)
    80004084:	6442                	ld	s0,16(sp)
    80004086:	64a2                	ld	s1,8(sp)
    80004088:	6902                	ld	s2,0(sp)
    8000408a:	6105                	addi	sp,sp,32
    8000408c:	8082                	ret

000000008000408e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000408e:	1101                	addi	sp,sp,-32
    80004090:	ec06                	sd	ra,24(sp)
    80004092:	e822                	sd	s0,16(sp)
    80004094:	e426                	sd	s1,8(sp)
    80004096:	e04a                	sd	s2,0(sp)
    80004098:	1000                	addi	s0,sp,32
    8000409a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000409c:	00850913          	addi	s2,a0,8
    800040a0:	854a                	mv	a0,s2
    800040a2:	ad9fc0ef          	jal	ra,80000b7a <acquire>
  lk->locked = 0;
    800040a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040aa:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040ae:	8526                	mv	a0,s1
    800040b0:	ecdfd0ef          	jal	ra,80001f7c <wakeup>
  release(&lk->lk);
    800040b4:	854a                	mv	a0,s2
    800040b6:	b5dfc0ef          	jal	ra,80000c12 <release>
}
    800040ba:	60e2                	ld	ra,24(sp)
    800040bc:	6442                	ld	s0,16(sp)
    800040be:	64a2                	ld	s1,8(sp)
    800040c0:	6902                	ld	s2,0(sp)
    800040c2:	6105                	addi	sp,sp,32
    800040c4:	8082                	ret

00000000800040c6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040c6:	7179                	addi	sp,sp,-48
    800040c8:	f406                	sd	ra,40(sp)
    800040ca:	f022                	sd	s0,32(sp)
    800040cc:	ec26                	sd	s1,24(sp)
    800040ce:	e84a                	sd	s2,16(sp)
    800040d0:	e44e                	sd	s3,8(sp)
    800040d2:	1800                	addi	s0,sp,48
    800040d4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040d6:	00850913          	addi	s2,a0,8
    800040da:	854a                	mv	a0,s2
    800040dc:	a9ffc0ef          	jal	ra,80000b7a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e0:	409c                	lw	a5,0(s1)
    800040e2:	ef89                	bnez	a5,800040fc <holdingsleep+0x36>
    800040e4:	4481                	li	s1,0
  release(&lk->lk);
    800040e6:	854a                	mv	a0,s2
    800040e8:	b2bfc0ef          	jal	ra,80000c12 <release>
  return r;
}
    800040ec:	8526                	mv	a0,s1
    800040ee:	70a2                	ld	ra,40(sp)
    800040f0:	7402                	ld	s0,32(sp)
    800040f2:	64e2                	ld	s1,24(sp)
    800040f4:	6942                	ld	s2,16(sp)
    800040f6:	69a2                	ld	s3,8(sp)
    800040f8:	6145                	addi	sp,sp,48
    800040fa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800040fc:	0284a983          	lw	s3,40(s1)
    80004100:	f1afd0ef          	jal	ra,8000181a <myproc>
    80004104:	5904                	lw	s1,48(a0)
    80004106:	413484b3          	sub	s1,s1,s3
    8000410a:	0014b493          	seqz	s1,s1
    8000410e:	bfe1                	j	800040e6 <holdingsleep+0x20>

0000000080004110 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004110:	1141                	addi	sp,sp,-16
    80004112:	e406                	sd	ra,8(sp)
    80004114:	e022                	sd	s0,0(sp)
    80004116:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004118:	00003597          	auipc	a1,0x3
    8000411c:	61058593          	addi	a1,a1,1552 # 80007728 <syscalls+0x288>
    80004120:	0001c517          	auipc	a0,0x1c
    80004124:	e4050513          	addi	a0,a0,-448 # 8001ff60 <ftable>
    80004128:	9d3fc0ef          	jal	ra,80000afa <initlock>
}
    8000412c:	60a2                	ld	ra,8(sp)
    8000412e:	6402                	ld	s0,0(sp)
    80004130:	0141                	addi	sp,sp,16
    80004132:	8082                	ret

0000000080004134 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004134:	1101                	addi	sp,sp,-32
    80004136:	ec06                	sd	ra,24(sp)
    80004138:	e822                	sd	s0,16(sp)
    8000413a:	e426                	sd	s1,8(sp)
    8000413c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000413e:	0001c517          	auipc	a0,0x1c
    80004142:	e2250513          	addi	a0,a0,-478 # 8001ff60 <ftable>
    80004146:	a35fc0ef          	jal	ra,80000b7a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000414a:	0001c497          	auipc	s1,0x1c
    8000414e:	e2e48493          	addi	s1,s1,-466 # 8001ff78 <ftable+0x18>
    80004152:	0001d717          	auipc	a4,0x1d
    80004156:	dc670713          	addi	a4,a4,-570 # 80020f18 <disk>
    if(f->ref == 0){
    8000415a:	40dc                	lw	a5,4(s1)
    8000415c:	cf89                	beqz	a5,80004176 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000415e:	02848493          	addi	s1,s1,40
    80004162:	fee49ce3          	bne	s1,a4,8000415a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004166:	0001c517          	auipc	a0,0x1c
    8000416a:	dfa50513          	addi	a0,a0,-518 # 8001ff60 <ftable>
    8000416e:	aa5fc0ef          	jal	ra,80000c12 <release>
  return 0;
    80004172:	4481                	li	s1,0
    80004174:	a809                	j	80004186 <filealloc+0x52>
      f->ref = 1;
    80004176:	4785                	li	a5,1
    80004178:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000417a:	0001c517          	auipc	a0,0x1c
    8000417e:	de650513          	addi	a0,a0,-538 # 8001ff60 <ftable>
    80004182:	a91fc0ef          	jal	ra,80000c12 <release>
}
    80004186:	8526                	mv	a0,s1
    80004188:	60e2                	ld	ra,24(sp)
    8000418a:	6442                	ld	s0,16(sp)
    8000418c:	64a2                	ld	s1,8(sp)
    8000418e:	6105                	addi	sp,sp,32
    80004190:	8082                	ret

0000000080004192 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004192:	1101                	addi	sp,sp,-32
    80004194:	ec06                	sd	ra,24(sp)
    80004196:	e822                	sd	s0,16(sp)
    80004198:	e426                	sd	s1,8(sp)
    8000419a:	1000                	addi	s0,sp,32
    8000419c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000419e:	0001c517          	auipc	a0,0x1c
    800041a2:	dc250513          	addi	a0,a0,-574 # 8001ff60 <ftable>
    800041a6:	9d5fc0ef          	jal	ra,80000b7a <acquire>
  if(f->ref < 1)
    800041aa:	40dc                	lw	a5,4(s1)
    800041ac:	02f05063          	blez	a5,800041cc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041b0:	2785                	addiw	a5,a5,1
    800041b2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041b4:	0001c517          	auipc	a0,0x1c
    800041b8:	dac50513          	addi	a0,a0,-596 # 8001ff60 <ftable>
    800041bc:	a57fc0ef          	jal	ra,80000c12 <release>
  return f;
}
    800041c0:	8526                	mv	a0,s1
    800041c2:	60e2                	ld	ra,24(sp)
    800041c4:	6442                	ld	s0,16(sp)
    800041c6:	64a2                	ld	s1,8(sp)
    800041c8:	6105                	addi	sp,sp,32
    800041ca:	8082                	ret
    panic("filedup");
    800041cc:	00003517          	auipc	a0,0x3
    800041d0:	56450513          	addi	a0,a0,1380 # 80007730 <syscalls+0x290>
    800041d4:	dbcfc0ef          	jal	ra,80000790 <panic>

00000000800041d8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041d8:	7139                	addi	sp,sp,-64
    800041da:	fc06                	sd	ra,56(sp)
    800041dc:	f822                	sd	s0,48(sp)
    800041de:	f426                	sd	s1,40(sp)
    800041e0:	f04a                	sd	s2,32(sp)
    800041e2:	ec4e                	sd	s3,24(sp)
    800041e4:	e852                	sd	s4,16(sp)
    800041e6:	e456                	sd	s5,8(sp)
    800041e8:	0080                	addi	s0,sp,64
    800041ea:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ec:	0001c517          	auipc	a0,0x1c
    800041f0:	d7450513          	addi	a0,a0,-652 # 8001ff60 <ftable>
    800041f4:	987fc0ef          	jal	ra,80000b7a <acquire>
  if(f->ref < 1)
    800041f8:	40dc                	lw	a5,4(s1)
    800041fa:	04f05963          	blez	a5,8000424c <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800041fe:	37fd                	addiw	a5,a5,-1
    80004200:	0007871b          	sext.w	a4,a5
    80004204:	c0dc                	sw	a5,4(s1)
    80004206:	04e04963          	bgtz	a4,80004258 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000420a:	0004a903          	lw	s2,0(s1)
    8000420e:	0094ca83          	lbu	s5,9(s1)
    80004212:	0104ba03          	ld	s4,16(s1)
    80004216:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000421a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000421e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004222:	0001c517          	auipc	a0,0x1c
    80004226:	d3e50513          	addi	a0,a0,-706 # 8001ff60 <ftable>
    8000422a:	9e9fc0ef          	jal	ra,80000c12 <release>

  if(ff.type == FD_PIPE){
    8000422e:	4785                	li	a5,1
    80004230:	04f90363          	beq	s2,a5,80004276 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004234:	3979                	addiw	s2,s2,-2
    80004236:	4785                	li	a5,1
    80004238:	0327e663          	bltu	a5,s2,80004264 <fileclose+0x8c>
    begin_op();
    8000423c:	b8fff0ef          	jal	ra,80003dca <begin_op>
    iput(ff.ip);
    80004240:	854e                	mv	a0,s3
    80004242:	b28ff0ef          	jal	ra,8000356a <iput>
    end_op();
    80004246:	bf5ff0ef          	jal	ra,80003e3a <end_op>
    8000424a:	a829                	j	80004264 <fileclose+0x8c>
    panic("fileclose");
    8000424c:	00003517          	auipc	a0,0x3
    80004250:	4ec50513          	addi	a0,a0,1260 # 80007738 <syscalls+0x298>
    80004254:	d3cfc0ef          	jal	ra,80000790 <panic>
    release(&ftable.lock);
    80004258:	0001c517          	auipc	a0,0x1c
    8000425c:	d0850513          	addi	a0,a0,-760 # 8001ff60 <ftable>
    80004260:	9b3fc0ef          	jal	ra,80000c12 <release>
  }
}
    80004264:	70e2                	ld	ra,56(sp)
    80004266:	7442                	ld	s0,48(sp)
    80004268:	74a2                	ld	s1,40(sp)
    8000426a:	7902                	ld	s2,32(sp)
    8000426c:	69e2                	ld	s3,24(sp)
    8000426e:	6a42                	ld	s4,16(sp)
    80004270:	6aa2                	ld	s5,8(sp)
    80004272:	6121                	addi	sp,sp,64
    80004274:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004276:	85d6                	mv	a1,s5
    80004278:	8552                	mv	a0,s4
    8000427a:	2ec000ef          	jal	ra,80004566 <pipeclose>
    8000427e:	b7dd                	j	80004264 <fileclose+0x8c>

0000000080004280 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004280:	715d                	addi	sp,sp,-80
    80004282:	e486                	sd	ra,72(sp)
    80004284:	e0a2                	sd	s0,64(sp)
    80004286:	fc26                	sd	s1,56(sp)
    80004288:	f84a                	sd	s2,48(sp)
    8000428a:	f44e                	sd	s3,40(sp)
    8000428c:	0880                	addi	s0,sp,80
    8000428e:	84aa                	mv	s1,a0
    80004290:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004292:	d88fd0ef          	jal	ra,8000181a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004296:	409c                	lw	a5,0(s1)
    80004298:	37f9                	addiw	a5,a5,-2
    8000429a:	4705                	li	a4,1
    8000429c:	02f76f63          	bltu	a4,a5,800042da <filestat+0x5a>
    800042a0:	892a                	mv	s2,a0
    ilock(f->ip);
    800042a2:	6c88                	ld	a0,24(s1)
    800042a4:	948ff0ef          	jal	ra,800033ec <ilock>
    stati(f->ip, &st);
    800042a8:	fb840593          	addi	a1,s0,-72
    800042ac:	6c88                	ld	a0,24(s1)
    800042ae:	ca0ff0ef          	jal	ra,8000374e <stati>
    iunlock(f->ip);
    800042b2:	6c88                	ld	a0,24(s1)
    800042b4:	9e2ff0ef          	jal	ra,80003496 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042b8:	46e1                	li	a3,24
    800042ba:	fb840613          	addi	a2,s0,-72
    800042be:	85ce                	mv	a1,s3
    800042c0:	05093503          	ld	a0,80(s2)
    800042c4:	aa4fd0ef          	jal	ra,80001568 <copyout>
    800042c8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800042cc:	60a6                	ld	ra,72(sp)
    800042ce:	6406                	ld	s0,64(sp)
    800042d0:	74e2                	ld	s1,56(sp)
    800042d2:	7942                	ld	s2,48(sp)
    800042d4:	79a2                	ld	s3,40(sp)
    800042d6:	6161                	addi	sp,sp,80
    800042d8:	8082                	ret
  return -1;
    800042da:	557d                	li	a0,-1
    800042dc:	bfc5                	j	800042cc <filestat+0x4c>

00000000800042de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042de:	7179                	addi	sp,sp,-48
    800042e0:	f406                	sd	ra,40(sp)
    800042e2:	f022                	sd	s0,32(sp)
    800042e4:	ec26                	sd	s1,24(sp)
    800042e6:	e84a                	sd	s2,16(sp)
    800042e8:	e44e                	sd	s3,8(sp)
    800042ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042ec:	00854783          	lbu	a5,8(a0)
    800042f0:	cbc1                	beqz	a5,80004380 <fileread+0xa2>
    800042f2:	84aa                	mv	s1,a0
    800042f4:	89ae                	mv	s3,a1
    800042f6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042f8:	411c                	lw	a5,0(a0)
    800042fa:	4705                	li	a4,1
    800042fc:	04e78363          	beq	a5,a4,80004342 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004300:	470d                	li	a4,3
    80004302:	04e78563          	beq	a5,a4,8000434c <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004306:	4709                	li	a4,2
    80004308:	06e79663          	bne	a5,a4,80004374 <fileread+0x96>
    ilock(f->ip);
    8000430c:	6d08                	ld	a0,24(a0)
    8000430e:	8deff0ef          	jal	ra,800033ec <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004312:	874a                	mv	a4,s2
    80004314:	5094                	lw	a3,32(s1)
    80004316:	864e                	mv	a2,s3
    80004318:	4585                	li	a1,1
    8000431a:	6c88                	ld	a0,24(s1)
    8000431c:	c5cff0ef          	jal	ra,80003778 <readi>
    80004320:	892a                	mv	s2,a0
    80004322:	00a05563          	blez	a0,8000432c <fileread+0x4e>
      f->off += r;
    80004326:	509c                	lw	a5,32(s1)
    80004328:	9fa9                	addw	a5,a5,a0
    8000432a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000432c:	6c88                	ld	a0,24(s1)
    8000432e:	968ff0ef          	jal	ra,80003496 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004332:	854a                	mv	a0,s2
    80004334:	70a2                	ld	ra,40(sp)
    80004336:	7402                	ld	s0,32(sp)
    80004338:	64e2                	ld	s1,24(sp)
    8000433a:	6942                	ld	s2,16(sp)
    8000433c:	69a2                	ld	s3,8(sp)
    8000433e:	6145                	addi	sp,sp,48
    80004340:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004342:	6908                	ld	a0,16(a0)
    80004344:	356000ef          	jal	ra,8000469a <piperead>
    80004348:	892a                	mv	s2,a0
    8000434a:	b7e5                	j	80004332 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000434c:	02451783          	lh	a5,36(a0)
    80004350:	03079693          	slli	a3,a5,0x30
    80004354:	92c1                	srli	a3,a3,0x30
    80004356:	4725                	li	a4,9
    80004358:	02d76663          	bltu	a4,a3,80004384 <fileread+0xa6>
    8000435c:	0792                	slli	a5,a5,0x4
    8000435e:	0001c717          	auipc	a4,0x1c
    80004362:	b6270713          	addi	a4,a4,-1182 # 8001fec0 <devsw>
    80004366:	97ba                	add	a5,a5,a4
    80004368:	639c                	ld	a5,0(a5)
    8000436a:	cf99                	beqz	a5,80004388 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    8000436c:	4505                	li	a0,1
    8000436e:	9782                	jalr	a5
    80004370:	892a                	mv	s2,a0
    80004372:	b7c1                	j	80004332 <fileread+0x54>
    panic("fileread");
    80004374:	00003517          	auipc	a0,0x3
    80004378:	3d450513          	addi	a0,a0,980 # 80007748 <syscalls+0x2a8>
    8000437c:	c14fc0ef          	jal	ra,80000790 <panic>
    return -1;
    80004380:	597d                	li	s2,-1
    80004382:	bf45                	j	80004332 <fileread+0x54>
      return -1;
    80004384:	597d                	li	s2,-1
    80004386:	b775                	j	80004332 <fileread+0x54>
    80004388:	597d                	li	s2,-1
    8000438a:	b765                	j	80004332 <fileread+0x54>

000000008000438c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000438c:	715d                	addi	sp,sp,-80
    8000438e:	e486                	sd	ra,72(sp)
    80004390:	e0a2                	sd	s0,64(sp)
    80004392:	fc26                	sd	s1,56(sp)
    80004394:	f84a                	sd	s2,48(sp)
    80004396:	f44e                	sd	s3,40(sp)
    80004398:	f052                	sd	s4,32(sp)
    8000439a:	ec56                	sd	s5,24(sp)
    8000439c:	e85a                	sd	s6,16(sp)
    8000439e:	e45e                	sd	s7,8(sp)
    800043a0:	e062                	sd	s8,0(sp)
    800043a2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800043a4:	00954783          	lbu	a5,9(a0)
    800043a8:	0e078863          	beqz	a5,80004498 <filewrite+0x10c>
    800043ac:	892a                	mv	s2,a0
    800043ae:	8aae                	mv	s5,a1
    800043b0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800043b2:	411c                	lw	a5,0(a0)
    800043b4:	4705                	li	a4,1
    800043b6:	02e78263          	beq	a5,a4,800043da <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043ba:	470d                	li	a4,3
    800043bc:	02e78463          	beq	a5,a4,800043e4 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043c0:	4709                	li	a4,2
    800043c2:	0ce79563          	bne	a5,a4,8000448c <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043c6:	0ac05163          	blez	a2,80004468 <filewrite+0xdc>
    int i = 0;
    800043ca:	4981                	li	s3,0
    800043cc:	6b05                	lui	s6,0x1
    800043ce:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800043d2:	6b85                	lui	s7,0x1
    800043d4:	c00b8b9b          	addiw	s7,s7,-1024
    800043d8:	a041                	j	80004458 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043da:	6908                	ld	a0,16(a0)
    800043dc:	1e2000ef          	jal	ra,800045be <pipewrite>
    800043e0:	8a2a                	mv	s4,a0
    800043e2:	a071                	j	8000446e <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043e4:	02451783          	lh	a5,36(a0)
    800043e8:	03079693          	slli	a3,a5,0x30
    800043ec:	92c1                	srli	a3,a3,0x30
    800043ee:	4725                	li	a4,9
    800043f0:	0ad76663          	bltu	a4,a3,8000449c <filewrite+0x110>
    800043f4:	0792                	slli	a5,a5,0x4
    800043f6:	0001c717          	auipc	a4,0x1c
    800043fa:	aca70713          	addi	a4,a4,-1334 # 8001fec0 <devsw>
    800043fe:	97ba                	add	a5,a5,a4
    80004400:	679c                	ld	a5,8(a5)
    80004402:	cfd9                	beqz	a5,800044a0 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004404:	4505                	li	a0,1
    80004406:	9782                	jalr	a5
    80004408:	8a2a                	mv	s4,a0
    8000440a:	a095                	j	8000446e <filewrite+0xe2>
    8000440c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004410:	9bbff0ef          	jal	ra,80003dca <begin_op>
      ilock(f->ip);
    80004414:	01893503          	ld	a0,24(s2)
    80004418:	fd5fe0ef          	jal	ra,800033ec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000441c:	8762                	mv	a4,s8
    8000441e:	02092683          	lw	a3,32(s2)
    80004422:	01598633          	add	a2,s3,s5
    80004426:	4585                	li	a1,1
    80004428:	01893503          	ld	a0,24(s2)
    8000442c:	c30ff0ef          	jal	ra,8000385c <writei>
    80004430:	84aa                	mv	s1,a0
    80004432:	00a05763          	blez	a0,80004440 <filewrite+0xb4>
        f->off += r;
    80004436:	02092783          	lw	a5,32(s2)
    8000443a:	9fa9                	addw	a5,a5,a0
    8000443c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004440:	01893503          	ld	a0,24(s2)
    80004444:	852ff0ef          	jal	ra,80003496 <iunlock>
      end_op();
    80004448:	9f3ff0ef          	jal	ra,80003e3a <end_op>

      if(r != n1){
    8000444c:	009c1f63          	bne	s8,s1,8000446a <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004450:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004454:	0149db63          	bge	s3,s4,8000446a <filewrite+0xde>
      int n1 = n - i;
    80004458:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000445c:	84be                	mv	s1,a5
    8000445e:	2781                	sext.w	a5,a5
    80004460:	fafb56e3          	bge	s6,a5,8000440c <filewrite+0x80>
    80004464:	84de                	mv	s1,s7
    80004466:	b75d                	j	8000440c <filewrite+0x80>
    int i = 0;
    80004468:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000446a:	013a1f63          	bne	s4,s3,80004488 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000446e:	8552                	mv	a0,s4
    80004470:	60a6                	ld	ra,72(sp)
    80004472:	6406                	ld	s0,64(sp)
    80004474:	74e2                	ld	s1,56(sp)
    80004476:	7942                	ld	s2,48(sp)
    80004478:	79a2                	ld	s3,40(sp)
    8000447a:	7a02                	ld	s4,32(sp)
    8000447c:	6ae2                	ld	s5,24(sp)
    8000447e:	6b42                	ld	s6,16(sp)
    80004480:	6ba2                	ld	s7,8(sp)
    80004482:	6c02                	ld	s8,0(sp)
    80004484:	6161                	addi	sp,sp,80
    80004486:	8082                	ret
    ret = (i == n ? n : -1);
    80004488:	5a7d                	li	s4,-1
    8000448a:	b7d5                	j	8000446e <filewrite+0xe2>
    panic("filewrite");
    8000448c:	00003517          	auipc	a0,0x3
    80004490:	2cc50513          	addi	a0,a0,716 # 80007758 <syscalls+0x2b8>
    80004494:	afcfc0ef          	jal	ra,80000790 <panic>
    return -1;
    80004498:	5a7d                	li	s4,-1
    8000449a:	bfd1                	j	8000446e <filewrite+0xe2>
      return -1;
    8000449c:	5a7d                	li	s4,-1
    8000449e:	bfc1                	j	8000446e <filewrite+0xe2>
    800044a0:	5a7d                	li	s4,-1
    800044a2:	b7f1                	j	8000446e <filewrite+0xe2>

00000000800044a4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044a4:	7179                	addi	sp,sp,-48
    800044a6:	f406                	sd	ra,40(sp)
    800044a8:	f022                	sd	s0,32(sp)
    800044aa:	ec26                	sd	s1,24(sp)
    800044ac:	e84a                	sd	s2,16(sp)
    800044ae:	e44e                	sd	s3,8(sp)
    800044b0:	e052                	sd	s4,0(sp)
    800044b2:	1800                	addi	s0,sp,48
    800044b4:	84aa                	mv	s1,a0
    800044b6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044b8:	0005b023          	sd	zero,0(a1)
    800044bc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044c0:	c75ff0ef          	jal	ra,80004134 <filealloc>
    800044c4:	e088                	sd	a0,0(s1)
    800044c6:	cd35                	beqz	a0,80004542 <pipealloc+0x9e>
    800044c8:	c6dff0ef          	jal	ra,80004134 <filealloc>
    800044cc:	00aa3023          	sd	a0,0(s4)
    800044d0:	c52d                	beqz	a0,8000453a <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044d2:	dd8fc0ef          	jal	ra,80000aaa <kalloc>
    800044d6:	892a                	mv	s2,a0
    800044d8:	cd31                	beqz	a0,80004534 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800044da:	4985                	li	s3,1
    800044dc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044e0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044e4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044e8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044ec:	00003597          	auipc	a1,0x3
    800044f0:	27c58593          	addi	a1,a1,636 # 80007768 <syscalls+0x2c8>
    800044f4:	e06fc0ef          	jal	ra,80000afa <initlock>
  (*f0)->type = FD_PIPE;
    800044f8:	609c                	ld	a5,0(s1)
    800044fa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044fe:	609c                	ld	a5,0(s1)
    80004500:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004504:	609c                	ld	a5,0(s1)
    80004506:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000450a:	609c                	ld	a5,0(s1)
    8000450c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004510:	000a3783          	ld	a5,0(s4)
    80004514:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004518:	000a3783          	ld	a5,0(s4)
    8000451c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004520:	000a3783          	ld	a5,0(s4)
    80004524:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004528:	000a3783          	ld	a5,0(s4)
    8000452c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004530:	4501                	li	a0,0
    80004532:	a005                	j	80004552 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004534:	6088                	ld	a0,0(s1)
    80004536:	e501                	bnez	a0,8000453e <pipealloc+0x9a>
    80004538:	a029                	j	80004542 <pipealloc+0x9e>
    8000453a:	6088                	ld	a0,0(s1)
    8000453c:	c11d                	beqz	a0,80004562 <pipealloc+0xbe>
    fileclose(*f0);
    8000453e:	c9bff0ef          	jal	ra,800041d8 <fileclose>
  if(*f1)
    80004542:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004546:	557d                	li	a0,-1
  if(*f1)
    80004548:	c789                	beqz	a5,80004552 <pipealloc+0xae>
    fileclose(*f1);
    8000454a:	853e                	mv	a0,a5
    8000454c:	c8dff0ef          	jal	ra,800041d8 <fileclose>
  return -1;
    80004550:	557d                	li	a0,-1
}
    80004552:	70a2                	ld	ra,40(sp)
    80004554:	7402                	ld	s0,32(sp)
    80004556:	64e2                	ld	s1,24(sp)
    80004558:	6942                	ld	s2,16(sp)
    8000455a:	69a2                	ld	s3,8(sp)
    8000455c:	6a02                	ld	s4,0(sp)
    8000455e:	6145                	addi	sp,sp,48
    80004560:	8082                	ret
  return -1;
    80004562:	557d                	li	a0,-1
    80004564:	b7fd                	j	80004552 <pipealloc+0xae>

0000000080004566 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004566:	1101                	addi	sp,sp,-32
    80004568:	ec06                	sd	ra,24(sp)
    8000456a:	e822                	sd	s0,16(sp)
    8000456c:	e426                	sd	s1,8(sp)
    8000456e:	e04a                	sd	s2,0(sp)
    80004570:	1000                	addi	s0,sp,32
    80004572:	84aa                	mv	s1,a0
    80004574:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004576:	e04fc0ef          	jal	ra,80000b7a <acquire>
  if(writable){
    8000457a:	02090763          	beqz	s2,800045a8 <pipeclose+0x42>
    pi->writeopen = 0;
    8000457e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004582:	21848513          	addi	a0,s1,536
    80004586:	9f7fd0ef          	jal	ra,80001f7c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000458a:	2204b783          	ld	a5,544(s1)
    8000458e:	e785                	bnez	a5,800045b6 <pipeclose+0x50>
    release(&pi->lock);
    80004590:	8526                	mv	a0,s1
    80004592:	e80fc0ef          	jal	ra,80000c12 <release>
    kfree((char*)pi);
    80004596:	8526                	mv	a0,s1
    80004598:	c32fc0ef          	jal	ra,800009ca <kfree>
  } else
    release(&pi->lock);
}
    8000459c:	60e2                	ld	ra,24(sp)
    8000459e:	6442                	ld	s0,16(sp)
    800045a0:	64a2                	ld	s1,8(sp)
    800045a2:	6902                	ld	s2,0(sp)
    800045a4:	6105                	addi	sp,sp,32
    800045a6:	8082                	ret
    pi->readopen = 0;
    800045a8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045ac:	21c48513          	addi	a0,s1,540
    800045b0:	9cdfd0ef          	jal	ra,80001f7c <wakeup>
    800045b4:	bfd9                	j	8000458a <pipeclose+0x24>
    release(&pi->lock);
    800045b6:	8526                	mv	a0,s1
    800045b8:	e5afc0ef          	jal	ra,80000c12 <release>
}
    800045bc:	b7c5                	j	8000459c <pipeclose+0x36>

00000000800045be <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045be:	7159                	addi	sp,sp,-112
    800045c0:	f486                	sd	ra,104(sp)
    800045c2:	f0a2                	sd	s0,96(sp)
    800045c4:	eca6                	sd	s1,88(sp)
    800045c6:	e8ca                	sd	s2,80(sp)
    800045c8:	e4ce                	sd	s3,72(sp)
    800045ca:	e0d2                	sd	s4,64(sp)
    800045cc:	fc56                	sd	s5,56(sp)
    800045ce:	f85a                	sd	s6,48(sp)
    800045d0:	f45e                	sd	s7,40(sp)
    800045d2:	f062                	sd	s8,32(sp)
    800045d4:	ec66                	sd	s9,24(sp)
    800045d6:	1880                	addi	s0,sp,112
    800045d8:	84aa                	mv	s1,a0
    800045da:	8aae                	mv	s5,a1
    800045dc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045de:	a3cfd0ef          	jal	ra,8000181a <myproc>
    800045e2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045e4:	8526                	mv	a0,s1
    800045e6:	d94fc0ef          	jal	ra,80000b7a <acquire>
  while(i < n){
    800045ea:	0b405663          	blez	s4,80004696 <pipewrite+0xd8>
    800045ee:	8ba6                	mv	s7,s1
  int i = 0;
    800045f0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045f2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045f4:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800045f8:	21c48c13          	addi	s8,s1,540
    800045fc:	a899                	j	80004652 <pipewrite+0x94>
      release(&pi->lock);
    800045fe:	8526                	mv	a0,s1
    80004600:	e12fc0ef          	jal	ra,80000c12 <release>
      return -1;
    80004604:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004606:	854a                	mv	a0,s2
    80004608:	70a6                	ld	ra,104(sp)
    8000460a:	7406                	ld	s0,96(sp)
    8000460c:	64e6                	ld	s1,88(sp)
    8000460e:	6946                	ld	s2,80(sp)
    80004610:	69a6                	ld	s3,72(sp)
    80004612:	6a06                	ld	s4,64(sp)
    80004614:	7ae2                	ld	s5,56(sp)
    80004616:	7b42                	ld	s6,48(sp)
    80004618:	7ba2                	ld	s7,40(sp)
    8000461a:	7c02                	ld	s8,32(sp)
    8000461c:	6ce2                	ld	s9,24(sp)
    8000461e:	6165                	addi	sp,sp,112
    80004620:	8082                	ret
      wakeup(&pi->nread);
    80004622:	8566                	mv	a0,s9
    80004624:	959fd0ef          	jal	ra,80001f7c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004628:	85de                	mv	a1,s7
    8000462a:	8562                	mv	a0,s8
    8000462c:	905fd0ef          	jal	ra,80001f30 <sleep>
    80004630:	a839                	j	8000464e <pipewrite+0x90>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004632:	21c4a783          	lw	a5,540(s1)
    80004636:	0017871b          	addiw	a4,a5,1
    8000463a:	20e4ae23          	sw	a4,540(s1)
    8000463e:	1ff7f793          	andi	a5,a5,511
    80004642:	97a6                	add	a5,a5,s1
    80004644:	f9f44703          	lbu	a4,-97(s0)
    80004648:	00e78c23          	sb	a4,24(a5)
      i++;
    8000464c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000464e:	03495c63          	bge	s2,s4,80004686 <pipewrite+0xc8>
    if(pi->readopen == 0 || killed(pr)){
    80004652:	2204a783          	lw	a5,544(s1)
    80004656:	d7c5                	beqz	a5,800045fe <pipewrite+0x40>
    80004658:	854e                	mv	a0,s3
    8000465a:	b4ffd0ef          	jal	ra,800021a8 <killed>
    8000465e:	f145                	bnez	a0,800045fe <pipewrite+0x40>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004660:	2184a783          	lw	a5,536(s1)
    80004664:	21c4a703          	lw	a4,540(s1)
    80004668:	2007879b          	addiw	a5,a5,512
    8000466c:	faf70be3          	beq	a4,a5,80004622 <pipewrite+0x64>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004670:	4685                	li	a3,1
    80004672:	01590633          	add	a2,s2,s5
    80004676:	f9f40593          	addi	a1,s0,-97
    8000467a:	0509b503          	ld	a0,80(s3)
    8000467e:	fb1fc0ef          	jal	ra,8000162e <copyin>
    80004682:	fb6518e3          	bne	a0,s6,80004632 <pipewrite+0x74>
  wakeup(&pi->nread);
    80004686:	21848513          	addi	a0,s1,536
    8000468a:	8f3fd0ef          	jal	ra,80001f7c <wakeup>
  release(&pi->lock);
    8000468e:	8526                	mv	a0,s1
    80004690:	d82fc0ef          	jal	ra,80000c12 <release>
  return i;
    80004694:	bf8d                	j	80004606 <pipewrite+0x48>
  int i = 0;
    80004696:	4901                	li	s2,0
    80004698:	b7fd                	j	80004686 <pipewrite+0xc8>

000000008000469a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000469a:	715d                	addi	sp,sp,-80
    8000469c:	e486                	sd	ra,72(sp)
    8000469e:	e0a2                	sd	s0,64(sp)
    800046a0:	fc26                	sd	s1,56(sp)
    800046a2:	f84a                	sd	s2,48(sp)
    800046a4:	f44e                	sd	s3,40(sp)
    800046a6:	f052                	sd	s4,32(sp)
    800046a8:	ec56                	sd	s5,24(sp)
    800046aa:	e85a                	sd	s6,16(sp)
    800046ac:	0880                	addi	s0,sp,80
    800046ae:	84aa                	mv	s1,a0
    800046b0:	892e                	mv	s2,a1
    800046b2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046b4:	966fd0ef          	jal	ra,8000181a <myproc>
    800046b8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046ba:	8b26                	mv	s6,s1
    800046bc:	8526                	mv	a0,s1
    800046be:	cbcfc0ef          	jal	ra,80000b7a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046c2:	2184a703          	lw	a4,536(s1)
    800046c6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046ca:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046ce:	02f71363          	bne	a4,a5,800046f4 <piperead+0x5a>
    800046d2:	2244a783          	lw	a5,548(s1)
    800046d6:	cf99                	beqz	a5,800046f4 <piperead+0x5a>
    if(killed(pr)){
    800046d8:	8552                	mv	a0,s4
    800046da:	acffd0ef          	jal	ra,800021a8 <killed>
    800046de:	e149                	bnez	a0,80004760 <piperead+0xc6>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046e0:	85da                	mv	a1,s6
    800046e2:	854e                	mv	a0,s3
    800046e4:	84dfd0ef          	jal	ra,80001f30 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046e8:	2184a703          	lw	a4,536(s1)
    800046ec:	21c4a783          	lw	a5,540(s1)
    800046f0:	fef701e3          	beq	a4,a5,800046d2 <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046f4:	07505f63          	blez	s5,80004772 <piperead+0xd8>
    800046f8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046fa:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800046fc:	2184a783          	lw	a5,536(s1)
    80004700:	21c4a703          	lw	a4,540(s1)
    80004704:	02f70c63          	beq	a4,a5,8000473c <piperead+0xa2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004708:	1ff7f793          	andi	a5,a5,511
    8000470c:	97a6                	add	a5,a5,s1
    8000470e:	0187c783          	lbu	a5,24(a5)
    80004712:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004716:	4685                	li	a3,1
    80004718:	fbf40613          	addi	a2,s0,-65
    8000471c:	85ca                	mv	a1,s2
    8000471e:	050a3503          	ld	a0,80(s4)
    80004722:	e47fc0ef          	jal	ra,80001568 <copyout>
    80004726:	05650263          	beq	a0,s6,8000476a <piperead+0xd0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000472a:	2184a783          	lw	a5,536(s1)
    8000472e:	2785                	addiw	a5,a5,1
    80004730:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004734:	2985                	addiw	s3,s3,1
    80004736:	0905                	addi	s2,s2,1
    80004738:	fd3a92e3          	bne	s5,s3,800046fc <piperead+0x62>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000473c:	21c48513          	addi	a0,s1,540
    80004740:	83dfd0ef          	jal	ra,80001f7c <wakeup>
  release(&pi->lock);
    80004744:	8526                	mv	a0,s1
    80004746:	cccfc0ef          	jal	ra,80000c12 <release>
  return i;
}
    8000474a:	854e                	mv	a0,s3
    8000474c:	60a6                	ld	ra,72(sp)
    8000474e:	6406                	ld	s0,64(sp)
    80004750:	74e2                	ld	s1,56(sp)
    80004752:	7942                	ld	s2,48(sp)
    80004754:	79a2                	ld	s3,40(sp)
    80004756:	7a02                	ld	s4,32(sp)
    80004758:	6ae2                	ld	s5,24(sp)
    8000475a:	6b42                	ld	s6,16(sp)
    8000475c:	6161                	addi	sp,sp,80
    8000475e:	8082                	ret
      release(&pi->lock);
    80004760:	8526                	mv	a0,s1
    80004762:	cb0fc0ef          	jal	ra,80000c12 <release>
      return -1;
    80004766:	59fd                	li	s3,-1
    80004768:	b7cd                	j	8000474a <piperead+0xb0>
      if(i == 0)
    8000476a:	fc0999e3          	bnez	s3,8000473c <piperead+0xa2>
        i = -1;
    8000476e:	89aa                	mv	s3,a0
    80004770:	b7f1                	j	8000473c <piperead+0xa2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004772:	4981                	li	s3,0
    80004774:	b7e1                	j	8000473c <piperead+0xa2>

0000000080004776 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004776:	1141                	addi	sp,sp,-16
    80004778:	e422                	sd	s0,8(sp)
    8000477a:	0800                	addi	s0,sp,16
    8000477c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000477e:	8905                	andi	a0,a0,1
    80004780:	c111                	beqz	a0,80004784 <flags2perm+0xe>
      perm = PTE_X;
    80004782:	4521                	li	a0,8
    if(flags & 0x2)
    80004784:	8b89                	andi	a5,a5,2
    80004786:	c399                	beqz	a5,8000478c <flags2perm+0x16>
      perm |= PTE_W;
    80004788:	00456513          	ori	a0,a0,4
    return perm;
}
    8000478c:	6422                	ld	s0,8(sp)
    8000478e:	0141                	addi	sp,sp,16
    80004790:	8082                	ret

0000000080004792 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004792:	df010113          	addi	sp,sp,-528
    80004796:	20113423          	sd	ra,520(sp)
    8000479a:	20813023          	sd	s0,512(sp)
    8000479e:	ffa6                	sd	s1,504(sp)
    800047a0:	fbca                	sd	s2,496(sp)
    800047a2:	f7ce                	sd	s3,488(sp)
    800047a4:	f3d2                	sd	s4,480(sp)
    800047a6:	efd6                	sd	s5,472(sp)
    800047a8:	ebda                	sd	s6,464(sp)
    800047aa:	e7de                	sd	s7,456(sp)
    800047ac:	e3e2                	sd	s8,448(sp)
    800047ae:	ff66                	sd	s9,440(sp)
    800047b0:	fb6a                	sd	s10,432(sp)
    800047b2:	f76e                	sd	s11,424(sp)
    800047b4:	0c00                	addi	s0,sp,528
    800047b6:	84aa                	mv	s1,a0
    800047b8:	dea43c23          	sd	a0,-520(s0)
    800047bc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800047c0:	85afd0ef          	jal	ra,8000181a <myproc>
    800047c4:	892a                	mv	s2,a0

  begin_op();
    800047c6:	e04ff0ef          	jal	ra,80003dca <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047ca:	8526                	mv	a0,s1
    800047cc:	c0eff0ef          	jal	ra,80003bda <namei>
    800047d0:	c12d                	beqz	a0,80004832 <kexec+0xa0>
    800047d2:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047d4:	c19fe0ef          	jal	ra,800033ec <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047d8:	04000713          	li	a4,64
    800047dc:	4681                	li	a3,0
    800047de:	e5040613          	addi	a2,s0,-432
    800047e2:	4581                	li	a1,0
    800047e4:	8526                	mv	a0,s1
    800047e6:	f93fe0ef          	jal	ra,80003778 <readi>
    800047ea:	04000793          	li	a5,64
    800047ee:	00f51a63          	bne	a0,a5,80004802 <kexec+0x70>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047f2:	e5042703          	lw	a4,-432(s0)
    800047f6:	464c47b7          	lui	a5,0x464c4
    800047fa:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047fe:	02f70e63          	beq	a4,a5,8000483a <kexec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004802:	8526                	mv	a0,s1
    80004804:	deffe0ef          	jal	ra,800035f2 <iunlockput>
    end_op();
    80004808:	e32ff0ef          	jal	ra,80003e3a <end_op>
  }
  return -1;
    8000480c:	557d                	li	a0,-1
}
    8000480e:	20813083          	ld	ra,520(sp)
    80004812:	20013403          	ld	s0,512(sp)
    80004816:	74fe                	ld	s1,504(sp)
    80004818:	795e                	ld	s2,496(sp)
    8000481a:	79be                	ld	s3,488(sp)
    8000481c:	7a1e                	ld	s4,480(sp)
    8000481e:	6afe                	ld	s5,472(sp)
    80004820:	6b5e                	ld	s6,464(sp)
    80004822:	6bbe                	ld	s7,456(sp)
    80004824:	6c1e                	ld	s8,448(sp)
    80004826:	7cfa                	ld	s9,440(sp)
    80004828:	7d5a                	ld	s10,432(sp)
    8000482a:	7dba                	ld	s11,424(sp)
    8000482c:	21010113          	addi	sp,sp,528
    80004830:	8082                	ret
    end_op();
    80004832:	e08ff0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80004836:	557d                	li	a0,-1
    80004838:	bfd9                	j	8000480e <kexec+0x7c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000483a:	854a                	mv	a0,s2
    8000483c:	8e4fd0ef          	jal	ra,80001920 <proc_pagetable>
    80004840:	8baa                	mv	s7,a0
    80004842:	d161                	beqz	a0,80004802 <kexec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004844:	e7042983          	lw	s3,-400(s0)
    80004848:	e8845783          	lhu	a5,-376(s0)
    8000484c:	cfb9                	beqz	a5,800048aa <kexec+0x118>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000484e:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004850:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004852:	6c85                	lui	s9,0x1
    80004854:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004858:	def43823          	sd	a5,-528(s0)
    8000485c:	aadd                	j	80004a52 <kexec+0x2c0>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000485e:	00003517          	auipc	a0,0x3
    80004862:	f1250513          	addi	a0,a0,-238 # 80007770 <syscalls+0x2d0>
    80004866:	f2bfb0ef          	jal	ra,80000790 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000486a:	8756                	mv	a4,s5
    8000486c:	012d86bb          	addw	a3,s11,s2
    80004870:	4581                	li	a1,0
    80004872:	8526                	mv	a0,s1
    80004874:	f05fe0ef          	jal	ra,80003778 <readi>
    80004878:	2501                	sext.w	a0,a0
    8000487a:	18aa9263          	bne	s5,a0,800049fe <kexec+0x26c>
  for(i = 0; i < sz; i += PGSIZE){
    8000487e:	6785                	lui	a5,0x1
    80004880:	0127893b          	addw	s2,a5,s2
    80004884:	77fd                	lui	a5,0xfffff
    80004886:	01478a3b          	addw	s4,a5,s4
    8000488a:	1b897b63          	bgeu	s2,s8,80004a40 <kexec+0x2ae>
    pa = walkaddr(pagetable, va + i);
    8000488e:	02091593          	slli	a1,s2,0x20
    80004892:	9181                	srli	a1,a1,0x20
    80004894:	95ea                	add	a1,a1,s10
    80004896:	855e                	mv	a0,s7
    80004898:	ed4fc0ef          	jal	ra,80000f6c <walkaddr>
    8000489c:	862a                	mv	a2,a0
    if(pa == 0)
    8000489e:	d161                	beqz	a0,8000485e <kexec+0xcc>
      n = PGSIZE;
    800048a0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800048a2:	fd9a74e3          	bgeu	s4,s9,8000486a <kexec+0xd8>
      n = sz - i;
    800048a6:	8ad2                	mv	s5,s4
    800048a8:	b7c9                	j	8000486a <kexec+0xd8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048aa:	4a01                	li	s4,0
  iunlockput(ip);
    800048ac:	8526                	mv	a0,s1
    800048ae:	d45fe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    800048b2:	d88ff0ef          	jal	ra,80003e3a <end_op>
  p = myproc();
    800048b6:	f65fc0ef          	jal	ra,8000181a <myproc>
    800048ba:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048bc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048c0:	6785                	lui	a5,0x1
    800048c2:	17fd                	addi	a5,a5,-1
    800048c4:	9a3e                	add	s4,s4,a5
    800048c6:	757d                	lui	a0,0xfffff
    800048c8:	00aa77b3          	and	a5,s4,a0
    800048cc:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048d0:	4691                	li	a3,4
    800048d2:	6609                	lui	a2,0x2
    800048d4:	963e                	add	a2,a2,a5
    800048d6:	85be                	mv	a1,a5
    800048d8:	855e                	mv	a0,s7
    800048da:	95dfc0ef          	jal	ra,80001236 <uvmalloc>
    800048de:	8b2a                	mv	s6,a0
  ip = 0;
    800048e0:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048e2:	10050e63          	beqz	a0,800049fe <kexec+0x26c>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048e6:	75f9                	lui	a1,0xffffe
    800048e8:	95aa                	add	a1,a1,a0
    800048ea:	855e                	mv	a0,s7
    800048ec:	b11fc0ef          	jal	ra,800013fc <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048f0:	7c7d                	lui	s8,0xfffff
    800048f2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800048f4:	e0043783          	ld	a5,-512(s0)
    800048f8:	6388                	ld	a0,0(a5)
    800048fa:	c125                	beqz	a0,8000495a <kexec+0x1c8>
    800048fc:	e9040993          	addi	s3,s0,-368
    80004900:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004904:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004906:	cc8fc0ef          	jal	ra,80000dce <strlen>
    8000490a:	2505                	addiw	a0,a0,1
    8000490c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004910:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004914:	11896a63          	bltu	s2,s8,80004a28 <kexec+0x296>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004918:	e0043d83          	ld	s11,-512(s0)
    8000491c:	000dba03          	ld	s4,0(s11)
    80004920:	8552                	mv	a0,s4
    80004922:	cacfc0ef          	jal	ra,80000dce <strlen>
    80004926:	0015069b          	addiw	a3,a0,1
    8000492a:	8652                	mv	a2,s4
    8000492c:	85ca                	mv	a1,s2
    8000492e:	855e                	mv	a0,s7
    80004930:	c39fc0ef          	jal	ra,80001568 <copyout>
    80004934:	0e054e63          	bltz	a0,80004a30 <kexec+0x29e>
    ustack[argc] = sp;
    80004938:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000493c:	0485                	addi	s1,s1,1
    8000493e:	008d8793          	addi	a5,s11,8
    80004942:	e0f43023          	sd	a5,-512(s0)
    80004946:	008db503          	ld	a0,8(s11)
    8000494a:	c911                	beqz	a0,8000495e <kexec+0x1cc>
    if(argc >= MAXARG)
    8000494c:	09a1                	addi	s3,s3,8
    8000494e:	fb3c9ce3          	bne	s9,s3,80004906 <kexec+0x174>
  sz = sz1;
    80004952:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004956:	4481                	li	s1,0
    80004958:	a05d                	j	800049fe <kexec+0x26c>
  sp = sz;
    8000495a:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000495c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000495e:	00349793          	slli	a5,s1,0x3
    80004962:	f9040713          	addi	a4,s0,-112
    80004966:	97ba                	add	a5,a5,a4
    80004968:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000496c:	00148693          	addi	a3,s1,1
    80004970:	068e                	slli	a3,a3,0x3
    80004972:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004976:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000497a:	01897663          	bgeu	s2,s8,80004986 <kexec+0x1f4>
  sz = sz1;
    8000497e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004982:	4481                	li	s1,0
    80004984:	a8ad                	j	800049fe <kexec+0x26c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004986:	e9040613          	addi	a2,s0,-368
    8000498a:	85ca                	mv	a1,s2
    8000498c:	855e                	mv	a0,s7
    8000498e:	bdbfc0ef          	jal	ra,80001568 <copyout>
    80004992:	0a054363          	bltz	a0,80004a38 <kexec+0x2a6>
  p->trapframe->a1 = sp;
    80004996:	058ab783          	ld	a5,88(s5)
    8000499a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000499e:	df843783          	ld	a5,-520(s0)
    800049a2:	0007c703          	lbu	a4,0(a5)
    800049a6:	cf11                	beqz	a4,800049c2 <kexec+0x230>
    800049a8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049aa:	02f00693          	li	a3,47
    800049ae:	a039                	j	800049bc <kexec+0x22a>
      last = s+1;
    800049b0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800049b4:	0785                	addi	a5,a5,1
    800049b6:	fff7c703          	lbu	a4,-1(a5)
    800049ba:	c701                	beqz	a4,800049c2 <kexec+0x230>
    if(*s == '/')
    800049bc:	fed71ce3          	bne	a4,a3,800049b4 <kexec+0x222>
    800049c0:	bfc5                	j	800049b0 <kexec+0x21e>
  safestrcpy(p->name, last, sizeof(p->name));
    800049c2:	4641                	li	a2,16
    800049c4:	df843583          	ld	a1,-520(s0)
    800049c8:	158a8513          	addi	a0,s5,344
    800049cc:	bd0fc0ef          	jal	ra,80000d9c <safestrcpy>
  oldpagetable = p->pagetable;
    800049d0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049d4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800049d8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049dc:	058ab783          	ld	a5,88(s5)
    800049e0:	e6843703          	ld	a4,-408(s0)
    800049e4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049e6:	058ab783          	ld	a5,88(s5)
    800049ea:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049ee:	85ea                	mv	a1,s10
    800049f0:	fb5fc0ef          	jal	ra,800019a4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049f4:	0004851b          	sext.w	a0,s1
    800049f8:	bd19                	j	8000480e <kexec+0x7c>
    800049fa:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800049fe:	e0843583          	ld	a1,-504(s0)
    80004a02:	855e                	mv	a0,s7
    80004a04:	fa1fc0ef          	jal	ra,800019a4 <proc_freepagetable>
  if(ip){
    80004a08:	de049de3          	bnez	s1,80004802 <kexec+0x70>
  return -1;
    80004a0c:	557d                	li	a0,-1
    80004a0e:	b501                	j	8000480e <kexec+0x7c>
    80004a10:	e1443423          	sd	s4,-504(s0)
    80004a14:	b7ed                	j	800049fe <kexec+0x26c>
    80004a16:	e1443423          	sd	s4,-504(s0)
    80004a1a:	b7d5                	j	800049fe <kexec+0x26c>
    80004a1c:	e1443423          	sd	s4,-504(s0)
    80004a20:	bff9                	j	800049fe <kexec+0x26c>
    80004a22:	e1443423          	sd	s4,-504(s0)
    80004a26:	bfe1                	j	800049fe <kexec+0x26c>
  sz = sz1;
    80004a28:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004a2c:	4481                	li	s1,0
    80004a2e:	bfc1                	j	800049fe <kexec+0x26c>
  sz = sz1;
    80004a30:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004a34:	4481                	li	s1,0
    80004a36:	b7e1                	j	800049fe <kexec+0x26c>
  sz = sz1;
    80004a38:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004a3c:	4481                	li	s1,0
    80004a3e:	b7c1                	j	800049fe <kexec+0x26c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a40:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a44:	2b05                	addiw	s6,s6,1
    80004a46:	0389899b          	addiw	s3,s3,56
    80004a4a:	e8845783          	lhu	a5,-376(s0)
    80004a4e:	e4fb5fe3          	bge	s6,a5,800048ac <kexec+0x11a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a52:	2981                	sext.w	s3,s3
    80004a54:	03800713          	li	a4,56
    80004a58:	86ce                	mv	a3,s3
    80004a5a:	e1840613          	addi	a2,s0,-488
    80004a5e:	4581                	li	a1,0
    80004a60:	8526                	mv	a0,s1
    80004a62:	d17fe0ef          	jal	ra,80003778 <readi>
    80004a66:	03800793          	li	a5,56
    80004a6a:	f8f518e3          	bne	a0,a5,800049fa <kexec+0x268>
    if(ph.type != ELF_PROG_LOAD)
    80004a6e:	e1842783          	lw	a5,-488(s0)
    80004a72:	4705                	li	a4,1
    80004a74:	fce798e3          	bne	a5,a4,80004a44 <kexec+0x2b2>
    if(ph.memsz < ph.filesz)
    80004a78:	e4043903          	ld	s2,-448(s0)
    80004a7c:	e3843783          	ld	a5,-456(s0)
    80004a80:	f8f968e3          	bltu	s2,a5,80004a10 <kexec+0x27e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a84:	e2843783          	ld	a5,-472(s0)
    80004a88:	993e                	add	s2,s2,a5
    80004a8a:	f8f966e3          	bltu	s2,a5,80004a16 <kexec+0x284>
    if(ph.vaddr % PGSIZE != 0)
    80004a8e:	df043703          	ld	a4,-528(s0)
    80004a92:	8ff9                	and	a5,a5,a4
    80004a94:	f7c1                	bnez	a5,80004a1c <kexec+0x28a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a96:	e1c42503          	lw	a0,-484(s0)
    80004a9a:	cddff0ef          	jal	ra,80004776 <flags2perm>
    80004a9e:	86aa                	mv	a3,a0
    80004aa0:	864a                	mv	a2,s2
    80004aa2:	85d2                	mv	a1,s4
    80004aa4:	855e                	mv	a0,s7
    80004aa6:	f90fc0ef          	jal	ra,80001236 <uvmalloc>
    80004aaa:	e0a43423          	sd	a0,-504(s0)
    80004aae:	d935                	beqz	a0,80004a22 <kexec+0x290>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ab0:	e2843d03          	ld	s10,-472(s0)
    80004ab4:	e2042d83          	lw	s11,-480(s0)
    80004ab8:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004abc:	f80c02e3          	beqz	s8,80004a40 <kexec+0x2ae>
    80004ac0:	8a62                	mv	s4,s8
    80004ac2:	4901                	li	s2,0
    80004ac4:	b3e9                	j	8000488e <kexec+0xfc>

0000000080004ac6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ac6:	7179                	addi	sp,sp,-48
    80004ac8:	f406                	sd	ra,40(sp)
    80004aca:	f022                	sd	s0,32(sp)
    80004acc:	ec26                	sd	s1,24(sp)
    80004ace:	e84a                	sd	s2,16(sp)
    80004ad0:	1800                	addi	s0,sp,48
    80004ad2:	892e                	mv	s2,a1
    80004ad4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ad6:	fdc40593          	addi	a1,s0,-36
    80004ada:	e73fd0ef          	jal	ra,8000294c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ade:	fdc42703          	lw	a4,-36(s0)
    80004ae2:	47bd                	li	a5,15
    80004ae4:	02e7e963          	bltu	a5,a4,80004b16 <argfd+0x50>
    80004ae8:	d33fc0ef          	jal	ra,8000181a <myproc>
    80004aec:	fdc42703          	lw	a4,-36(s0)
    80004af0:	01a70793          	addi	a5,a4,26
    80004af4:	078e                	slli	a5,a5,0x3
    80004af6:	953e                	add	a0,a0,a5
    80004af8:	611c                	ld	a5,0(a0)
    80004afa:	c385                	beqz	a5,80004b1a <argfd+0x54>
    return -1;
  if(pfd)
    80004afc:	00090463          	beqz	s2,80004b04 <argfd+0x3e>
    *pfd = fd;
    80004b00:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b04:	4501                	li	a0,0
  if(pf)
    80004b06:	c091                	beqz	s1,80004b0a <argfd+0x44>
    *pf = f;
    80004b08:	e09c                	sd	a5,0(s1)
}
    80004b0a:	70a2                	ld	ra,40(sp)
    80004b0c:	7402                	ld	s0,32(sp)
    80004b0e:	64e2                	ld	s1,24(sp)
    80004b10:	6942                	ld	s2,16(sp)
    80004b12:	6145                	addi	sp,sp,48
    80004b14:	8082                	ret
    return -1;
    80004b16:	557d                	li	a0,-1
    80004b18:	bfcd                	j	80004b0a <argfd+0x44>
    80004b1a:	557d                	li	a0,-1
    80004b1c:	b7fd                	j	80004b0a <argfd+0x44>

0000000080004b1e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b1e:	1101                	addi	sp,sp,-32
    80004b20:	ec06                	sd	ra,24(sp)
    80004b22:	e822                	sd	s0,16(sp)
    80004b24:	e426                	sd	s1,8(sp)
    80004b26:	1000                	addi	s0,sp,32
    80004b28:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b2a:	cf1fc0ef          	jal	ra,8000181a <myproc>
    80004b2e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b30:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffde078>
    80004b34:	4501                	li	a0,0
    80004b36:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b38:	6398                	ld	a4,0(a5)
    80004b3a:	cb19                	beqz	a4,80004b50 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b3c:	2505                	addiw	a0,a0,1
    80004b3e:	07a1                	addi	a5,a5,8
    80004b40:	fed51ce3          	bne	a0,a3,80004b38 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b44:	557d                	li	a0,-1
}
    80004b46:	60e2                	ld	ra,24(sp)
    80004b48:	6442                	ld	s0,16(sp)
    80004b4a:	64a2                	ld	s1,8(sp)
    80004b4c:	6105                	addi	sp,sp,32
    80004b4e:	8082                	ret
      p->ofile[fd] = f;
    80004b50:	01a50793          	addi	a5,a0,26
    80004b54:	078e                	slli	a5,a5,0x3
    80004b56:	963e                	add	a2,a2,a5
    80004b58:	e204                	sd	s1,0(a2)
      return fd;
    80004b5a:	b7f5                	j	80004b46 <fdalloc+0x28>

0000000080004b5c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b5c:	715d                	addi	sp,sp,-80
    80004b5e:	e486                	sd	ra,72(sp)
    80004b60:	e0a2                	sd	s0,64(sp)
    80004b62:	fc26                	sd	s1,56(sp)
    80004b64:	f84a                	sd	s2,48(sp)
    80004b66:	f44e                	sd	s3,40(sp)
    80004b68:	f052                	sd	s4,32(sp)
    80004b6a:	ec56                	sd	s5,24(sp)
    80004b6c:	e85a                	sd	s6,16(sp)
    80004b6e:	0880                	addi	s0,sp,80
    80004b70:	8b2e                	mv	s6,a1
    80004b72:	89b2                	mv	s3,a2
    80004b74:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b76:	fb040593          	addi	a1,s0,-80
    80004b7a:	87aff0ef          	jal	ra,80003bf4 <nameiparent>
    80004b7e:	84aa                	mv	s1,a0
    80004b80:	10050c63          	beqz	a0,80004c98 <create+0x13c>
    return 0;

  ilock(dp);
    80004b84:	869fe0ef          	jal	ra,800033ec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b88:	4601                	li	a2,0
    80004b8a:	fb040593          	addi	a1,s0,-80
    80004b8e:	8526                	mv	a0,s1
    80004b90:	de5fe0ef          	jal	ra,80003974 <dirlookup>
    80004b94:	8aaa                	mv	s5,a0
    80004b96:	c521                	beqz	a0,80004bde <create+0x82>
    iunlockput(dp);
    80004b98:	8526                	mv	a0,s1
    80004b9a:	a59fe0ef          	jal	ra,800035f2 <iunlockput>
    ilock(ip);
    80004b9e:	8556                	mv	a0,s5
    80004ba0:	84dfe0ef          	jal	ra,800033ec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ba4:	000b059b          	sext.w	a1,s6
    80004ba8:	4789                	li	a5,2
    80004baa:	02f59563          	bne	a1,a5,80004bd4 <create+0x78>
    80004bae:	044ad783          	lhu	a5,68(s5)
    80004bb2:	37f9                	addiw	a5,a5,-2
    80004bb4:	17c2                	slli	a5,a5,0x30
    80004bb6:	93c1                	srli	a5,a5,0x30
    80004bb8:	4705                	li	a4,1
    80004bba:	00f76d63          	bltu	a4,a5,80004bd4 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004bbe:	8556                	mv	a0,s5
    80004bc0:	60a6                	ld	ra,72(sp)
    80004bc2:	6406                	ld	s0,64(sp)
    80004bc4:	74e2                	ld	s1,56(sp)
    80004bc6:	7942                	ld	s2,48(sp)
    80004bc8:	79a2                	ld	s3,40(sp)
    80004bca:	7a02                	ld	s4,32(sp)
    80004bcc:	6ae2                	ld	s5,24(sp)
    80004bce:	6b42                	ld	s6,16(sp)
    80004bd0:	6161                	addi	sp,sp,80
    80004bd2:	8082                	ret
    iunlockput(ip);
    80004bd4:	8556                	mv	a0,s5
    80004bd6:	a1dfe0ef          	jal	ra,800035f2 <iunlockput>
    return 0;
    80004bda:	4a81                	li	s5,0
    80004bdc:	b7cd                	j	80004bbe <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bde:	85da                	mv	a1,s6
    80004be0:	4088                	lw	a0,0(s1)
    80004be2:	ea2fe0ef          	jal	ra,80003284 <ialloc>
    80004be6:	8a2a                	mv	s4,a0
    80004be8:	c121                	beqz	a0,80004c28 <create+0xcc>
  ilock(ip);
    80004bea:	803fe0ef          	jal	ra,800033ec <ilock>
  ip->major = major;
    80004bee:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004bf2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004bf6:	4785                	li	a5,1
    80004bf8:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80004bfc:	8552                	mv	a0,s4
    80004bfe:	f3cfe0ef          	jal	ra,8000333a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c02:	000b059b          	sext.w	a1,s6
    80004c06:	4785                	li	a5,1
    80004c08:	02f58563          	beq	a1,a5,80004c32 <create+0xd6>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c0c:	004a2603          	lw	a2,4(s4)
    80004c10:	fb040593          	addi	a1,s0,-80
    80004c14:	8526                	mv	a0,s1
    80004c16:	f2bfe0ef          	jal	ra,80003b40 <dirlink>
    80004c1a:	06054363          	bltz	a0,80004c80 <create+0x124>
  iunlockput(dp);
    80004c1e:	8526                	mv	a0,s1
    80004c20:	9d3fe0ef          	jal	ra,800035f2 <iunlockput>
  return ip;
    80004c24:	8ad2                	mv	s5,s4
    80004c26:	bf61                	j	80004bbe <create+0x62>
    iunlockput(dp);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	9c9fe0ef          	jal	ra,800035f2 <iunlockput>
    return 0;
    80004c2e:	8ad2                	mv	s5,s4
    80004c30:	b779                	j	80004bbe <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c32:	004a2603          	lw	a2,4(s4)
    80004c36:	00003597          	auipc	a1,0x3
    80004c3a:	b5a58593          	addi	a1,a1,-1190 # 80007790 <syscalls+0x2f0>
    80004c3e:	8552                	mv	a0,s4
    80004c40:	f01fe0ef          	jal	ra,80003b40 <dirlink>
    80004c44:	02054e63          	bltz	a0,80004c80 <create+0x124>
    80004c48:	40d0                	lw	a2,4(s1)
    80004c4a:	00003597          	auipc	a1,0x3
    80004c4e:	b4e58593          	addi	a1,a1,-1202 # 80007798 <syscalls+0x2f8>
    80004c52:	8552                	mv	a0,s4
    80004c54:	eedfe0ef          	jal	ra,80003b40 <dirlink>
    80004c58:	02054463          	bltz	a0,80004c80 <create+0x124>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c5c:	004a2603          	lw	a2,4(s4)
    80004c60:	fb040593          	addi	a1,s0,-80
    80004c64:	8526                	mv	a0,s1
    80004c66:	edbfe0ef          	jal	ra,80003b40 <dirlink>
    80004c6a:	00054b63          	bltz	a0,80004c80 <create+0x124>
    dp->nlink++;  // for ".."
    80004c6e:	04a4d783          	lhu	a5,74(s1)
    80004c72:	2785                	addiw	a5,a5,1
    80004c74:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ec0fe0ef          	jal	ra,8000333a <iupdate>
    80004c7e:	b745                	j	80004c1e <create+0xc2>
  ip->nlink = 0;
    80004c80:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c84:	8552                	mv	a0,s4
    80004c86:	eb4fe0ef          	jal	ra,8000333a <iupdate>
  iunlockput(ip);
    80004c8a:	8552                	mv	a0,s4
    80004c8c:	967fe0ef          	jal	ra,800035f2 <iunlockput>
  iunlockput(dp);
    80004c90:	8526                	mv	a0,s1
    80004c92:	961fe0ef          	jal	ra,800035f2 <iunlockput>
  return 0;
    80004c96:	b725                	j	80004bbe <create+0x62>
    return 0;
    80004c98:	8aaa                	mv	s5,a0
    80004c9a:	b715                	j	80004bbe <create+0x62>

0000000080004c9c <sys_dup>:
{
    80004c9c:	7179                	addi	sp,sp,-48
    80004c9e:	f406                	sd	ra,40(sp)
    80004ca0:	f022                	sd	s0,32(sp)
    80004ca2:	ec26                	sd	s1,24(sp)
    80004ca4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ca6:	fd840613          	addi	a2,s0,-40
    80004caa:	4581                	li	a1,0
    80004cac:	4501                	li	a0,0
    80004cae:	e19ff0ef          	jal	ra,80004ac6 <argfd>
    return -1;
    80004cb2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004cb4:	00054f63          	bltz	a0,80004cd2 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004cb8:	fd843503          	ld	a0,-40(s0)
    80004cbc:	e63ff0ef          	jal	ra,80004b1e <fdalloc>
    80004cc0:	84aa                	mv	s1,a0
    return -1;
    80004cc2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cc4:	00054763          	bltz	a0,80004cd2 <sys_dup+0x36>
  filedup(f);
    80004cc8:	fd843503          	ld	a0,-40(s0)
    80004ccc:	cc6ff0ef          	jal	ra,80004192 <filedup>
  return fd;
    80004cd0:	87a6                	mv	a5,s1
}
    80004cd2:	853e                	mv	a0,a5
    80004cd4:	70a2                	ld	ra,40(sp)
    80004cd6:	7402                	ld	s0,32(sp)
    80004cd8:	64e2                	ld	s1,24(sp)
    80004cda:	6145                	addi	sp,sp,48
    80004cdc:	8082                	ret

0000000080004cde <sys_read>:
{
    80004cde:	7179                	addi	sp,sp,-48
    80004ce0:	f406                	sd	ra,40(sp)
    80004ce2:	f022                	sd	s0,32(sp)
    80004ce4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ce6:	fd840593          	addi	a1,s0,-40
    80004cea:	4505                	li	a0,1
    80004cec:	c7dfd0ef          	jal	ra,80002968 <argaddr>
  argint(2, &n);
    80004cf0:	fe440593          	addi	a1,s0,-28
    80004cf4:	4509                	li	a0,2
    80004cf6:	c57fd0ef          	jal	ra,8000294c <argint>
  if(argfd(0, 0, &f) < 0)
    80004cfa:	fe840613          	addi	a2,s0,-24
    80004cfe:	4581                	li	a1,0
    80004d00:	4501                	li	a0,0
    80004d02:	dc5ff0ef          	jal	ra,80004ac6 <argfd>
    80004d06:	87aa                	mv	a5,a0
    return -1;
    80004d08:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d0a:	0007ca63          	bltz	a5,80004d1e <sys_read+0x40>
  return fileread(f, p, n);
    80004d0e:	fe442603          	lw	a2,-28(s0)
    80004d12:	fd843583          	ld	a1,-40(s0)
    80004d16:	fe843503          	ld	a0,-24(s0)
    80004d1a:	dc4ff0ef          	jal	ra,800042de <fileread>
}
    80004d1e:	70a2                	ld	ra,40(sp)
    80004d20:	7402                	ld	s0,32(sp)
    80004d22:	6145                	addi	sp,sp,48
    80004d24:	8082                	ret

0000000080004d26 <sys_write>:
{
    80004d26:	7179                	addi	sp,sp,-48
    80004d28:	f406                	sd	ra,40(sp)
    80004d2a:	f022                	sd	s0,32(sp)
    80004d2c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d2e:	fd840593          	addi	a1,s0,-40
    80004d32:	4505                	li	a0,1
    80004d34:	c35fd0ef          	jal	ra,80002968 <argaddr>
  argint(2, &n);
    80004d38:	fe440593          	addi	a1,s0,-28
    80004d3c:	4509                	li	a0,2
    80004d3e:	c0ffd0ef          	jal	ra,8000294c <argint>
  if(argfd(0, 0, &f) < 0)
    80004d42:	fe840613          	addi	a2,s0,-24
    80004d46:	4581                	li	a1,0
    80004d48:	4501                	li	a0,0
    80004d4a:	d7dff0ef          	jal	ra,80004ac6 <argfd>
    80004d4e:	87aa                	mv	a5,a0
    return -1;
    80004d50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d52:	0007ca63          	bltz	a5,80004d66 <sys_write+0x40>
  return filewrite(f, p, n);
    80004d56:	fe442603          	lw	a2,-28(s0)
    80004d5a:	fd843583          	ld	a1,-40(s0)
    80004d5e:	fe843503          	ld	a0,-24(s0)
    80004d62:	e2aff0ef          	jal	ra,8000438c <filewrite>
}
    80004d66:	70a2                	ld	ra,40(sp)
    80004d68:	7402                	ld	s0,32(sp)
    80004d6a:	6145                	addi	sp,sp,48
    80004d6c:	8082                	ret

0000000080004d6e <sys_close>:
{
    80004d6e:	1101                	addi	sp,sp,-32
    80004d70:	ec06                	sd	ra,24(sp)
    80004d72:	e822                	sd	s0,16(sp)
    80004d74:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d76:	fe040613          	addi	a2,s0,-32
    80004d7a:	fec40593          	addi	a1,s0,-20
    80004d7e:	4501                	li	a0,0
    80004d80:	d47ff0ef          	jal	ra,80004ac6 <argfd>
    return -1;
    80004d84:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d86:	02054063          	bltz	a0,80004da6 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d8a:	a91fc0ef          	jal	ra,8000181a <myproc>
    80004d8e:	fec42783          	lw	a5,-20(s0)
    80004d92:	07e9                	addi	a5,a5,26
    80004d94:	078e                	slli	a5,a5,0x3
    80004d96:	97aa                	add	a5,a5,a0
    80004d98:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004d9c:	fe043503          	ld	a0,-32(s0)
    80004da0:	c38ff0ef          	jal	ra,800041d8 <fileclose>
  return 0;
    80004da4:	4781                	li	a5,0
}
    80004da6:	853e                	mv	a0,a5
    80004da8:	60e2                	ld	ra,24(sp)
    80004daa:	6442                	ld	s0,16(sp)
    80004dac:	6105                	addi	sp,sp,32
    80004dae:	8082                	ret

0000000080004db0 <sys_fstat>:
{
    80004db0:	1101                	addi	sp,sp,-32
    80004db2:	ec06                	sd	ra,24(sp)
    80004db4:	e822                	sd	s0,16(sp)
    80004db6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004db8:	fe040593          	addi	a1,s0,-32
    80004dbc:	4505                	li	a0,1
    80004dbe:	babfd0ef          	jal	ra,80002968 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004dc2:	fe840613          	addi	a2,s0,-24
    80004dc6:	4581                	li	a1,0
    80004dc8:	4501                	li	a0,0
    80004dca:	cfdff0ef          	jal	ra,80004ac6 <argfd>
    80004dce:	87aa                	mv	a5,a0
    return -1;
    80004dd0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dd2:	0007c863          	bltz	a5,80004de2 <sys_fstat+0x32>
  return filestat(f, st);
    80004dd6:	fe043583          	ld	a1,-32(s0)
    80004dda:	fe843503          	ld	a0,-24(s0)
    80004dde:	ca2ff0ef          	jal	ra,80004280 <filestat>
}
    80004de2:	60e2                	ld	ra,24(sp)
    80004de4:	6442                	ld	s0,16(sp)
    80004de6:	6105                	addi	sp,sp,32
    80004de8:	8082                	ret

0000000080004dea <sys_link>:
{
    80004dea:	7169                	addi	sp,sp,-304
    80004dec:	f606                	sd	ra,296(sp)
    80004dee:	f222                	sd	s0,288(sp)
    80004df0:	ee26                	sd	s1,280(sp)
    80004df2:	ea4a                	sd	s2,272(sp)
    80004df4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004df6:	08000613          	li	a2,128
    80004dfa:	ed040593          	addi	a1,s0,-304
    80004dfe:	4501                	li	a0,0
    80004e00:	b85fd0ef          	jal	ra,80002984 <argstr>
    return -1;
    80004e04:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e06:	0c054663          	bltz	a0,80004ed2 <sys_link+0xe8>
    80004e0a:	08000613          	li	a2,128
    80004e0e:	f5040593          	addi	a1,s0,-176
    80004e12:	4505                	li	a0,1
    80004e14:	b71fd0ef          	jal	ra,80002984 <argstr>
    return -1;
    80004e18:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e1a:	0a054c63          	bltz	a0,80004ed2 <sys_link+0xe8>
  begin_op();
    80004e1e:	fadfe0ef          	jal	ra,80003dca <begin_op>
  if((ip = namei(old)) == 0){
    80004e22:	ed040513          	addi	a0,s0,-304
    80004e26:	db5fe0ef          	jal	ra,80003bda <namei>
    80004e2a:	84aa                	mv	s1,a0
    80004e2c:	c525                	beqz	a0,80004e94 <sys_link+0xaa>
  ilock(ip);
    80004e2e:	dbefe0ef          	jal	ra,800033ec <ilock>
  if(ip->type == T_DIR){
    80004e32:	04449703          	lh	a4,68(s1)
    80004e36:	4785                	li	a5,1
    80004e38:	06f70263          	beq	a4,a5,80004e9c <sys_link+0xb2>
  ip->nlink++;
    80004e3c:	04a4d783          	lhu	a5,74(s1)
    80004e40:	2785                	addiw	a5,a5,1
    80004e42:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e46:	8526                	mv	a0,s1
    80004e48:	cf2fe0ef          	jal	ra,8000333a <iupdate>
  iunlock(ip);
    80004e4c:	8526                	mv	a0,s1
    80004e4e:	e48fe0ef          	jal	ra,80003496 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e52:	fd040593          	addi	a1,s0,-48
    80004e56:	f5040513          	addi	a0,s0,-176
    80004e5a:	d9bfe0ef          	jal	ra,80003bf4 <nameiparent>
    80004e5e:	892a                	mv	s2,a0
    80004e60:	c921                	beqz	a0,80004eb0 <sys_link+0xc6>
  ilock(dp);
    80004e62:	d8afe0ef          	jal	ra,800033ec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e66:	00092703          	lw	a4,0(s2)
    80004e6a:	409c                	lw	a5,0(s1)
    80004e6c:	02f71f63          	bne	a4,a5,80004eaa <sys_link+0xc0>
    80004e70:	40d0                	lw	a2,4(s1)
    80004e72:	fd040593          	addi	a1,s0,-48
    80004e76:	854a                	mv	a0,s2
    80004e78:	cc9fe0ef          	jal	ra,80003b40 <dirlink>
    80004e7c:	02054763          	bltz	a0,80004eaa <sys_link+0xc0>
  iunlockput(dp);
    80004e80:	854a                	mv	a0,s2
    80004e82:	f70fe0ef          	jal	ra,800035f2 <iunlockput>
  iput(ip);
    80004e86:	8526                	mv	a0,s1
    80004e88:	ee2fe0ef          	jal	ra,8000356a <iput>
  end_op();
    80004e8c:	faffe0ef          	jal	ra,80003e3a <end_op>
  return 0;
    80004e90:	4781                	li	a5,0
    80004e92:	a081                	j	80004ed2 <sys_link+0xe8>
    end_op();
    80004e94:	fa7fe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80004e98:	57fd                	li	a5,-1
    80004e9a:	a825                	j	80004ed2 <sys_link+0xe8>
    iunlockput(ip);
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	f54fe0ef          	jal	ra,800035f2 <iunlockput>
    end_op();
    80004ea2:	f99fe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80004ea6:	57fd                	li	a5,-1
    80004ea8:	a02d                	j	80004ed2 <sys_link+0xe8>
    iunlockput(dp);
    80004eaa:	854a                	mv	a0,s2
    80004eac:	f46fe0ef          	jal	ra,800035f2 <iunlockput>
  ilock(ip);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	d3afe0ef          	jal	ra,800033ec <ilock>
  ip->nlink--;
    80004eb6:	04a4d783          	lhu	a5,74(s1)
    80004eba:	37fd                	addiw	a5,a5,-1
    80004ebc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	c78fe0ef          	jal	ra,8000333a <iupdate>
  iunlockput(ip);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	f2afe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    80004ecc:	f6ffe0ef          	jal	ra,80003e3a <end_op>
  return -1;
    80004ed0:	57fd                	li	a5,-1
}
    80004ed2:	853e                	mv	a0,a5
    80004ed4:	70b2                	ld	ra,296(sp)
    80004ed6:	7412                	ld	s0,288(sp)
    80004ed8:	64f2                	ld	s1,280(sp)
    80004eda:	6952                	ld	s2,272(sp)
    80004edc:	6155                	addi	sp,sp,304
    80004ede:	8082                	ret

0000000080004ee0 <sys_unlink>:
{
    80004ee0:	7151                	addi	sp,sp,-240
    80004ee2:	f586                	sd	ra,232(sp)
    80004ee4:	f1a2                	sd	s0,224(sp)
    80004ee6:	eda6                	sd	s1,216(sp)
    80004ee8:	e9ca                	sd	s2,208(sp)
    80004eea:	e5ce                	sd	s3,200(sp)
    80004eec:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004eee:	08000613          	li	a2,128
    80004ef2:	f3040593          	addi	a1,s0,-208
    80004ef6:	4501                	li	a0,0
    80004ef8:	a8dfd0ef          	jal	ra,80002984 <argstr>
    80004efc:	12054b63          	bltz	a0,80005032 <sys_unlink+0x152>
  begin_op();
    80004f00:	ecbfe0ef          	jal	ra,80003dca <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f04:	fb040593          	addi	a1,s0,-80
    80004f08:	f3040513          	addi	a0,s0,-208
    80004f0c:	ce9fe0ef          	jal	ra,80003bf4 <nameiparent>
    80004f10:	84aa                	mv	s1,a0
    80004f12:	c54d                	beqz	a0,80004fbc <sys_unlink+0xdc>
  ilock(dp);
    80004f14:	cd8fe0ef          	jal	ra,800033ec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f18:	00003597          	auipc	a1,0x3
    80004f1c:	87858593          	addi	a1,a1,-1928 # 80007790 <syscalls+0x2f0>
    80004f20:	fb040513          	addi	a0,s0,-80
    80004f24:	a3bfe0ef          	jal	ra,8000395e <namecmp>
    80004f28:	10050a63          	beqz	a0,8000503c <sys_unlink+0x15c>
    80004f2c:	00003597          	auipc	a1,0x3
    80004f30:	86c58593          	addi	a1,a1,-1940 # 80007798 <syscalls+0x2f8>
    80004f34:	fb040513          	addi	a0,s0,-80
    80004f38:	a27fe0ef          	jal	ra,8000395e <namecmp>
    80004f3c:	10050063          	beqz	a0,8000503c <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f40:	f2c40613          	addi	a2,s0,-212
    80004f44:	fb040593          	addi	a1,s0,-80
    80004f48:	8526                	mv	a0,s1
    80004f4a:	a2bfe0ef          	jal	ra,80003974 <dirlookup>
    80004f4e:	892a                	mv	s2,a0
    80004f50:	0e050663          	beqz	a0,8000503c <sys_unlink+0x15c>
  ilock(ip);
    80004f54:	c98fe0ef          	jal	ra,800033ec <ilock>
  if(ip->nlink < 1)
    80004f58:	04a91783          	lh	a5,74(s2)
    80004f5c:	06f05463          	blez	a5,80004fc4 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f60:	04491703          	lh	a4,68(s2)
    80004f64:	4785                	li	a5,1
    80004f66:	06f70563          	beq	a4,a5,80004fd0 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004f6a:	4641                	li	a2,16
    80004f6c:	4581                	li	a1,0
    80004f6e:	fc040513          	addi	a0,s0,-64
    80004f72:	cddfb0ef          	jal	ra,80000c4e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f76:	4741                	li	a4,16
    80004f78:	f2c42683          	lw	a3,-212(s0)
    80004f7c:	fc040613          	addi	a2,s0,-64
    80004f80:	4581                	li	a1,0
    80004f82:	8526                	mv	a0,s1
    80004f84:	8d9fe0ef          	jal	ra,8000385c <writei>
    80004f88:	47c1                	li	a5,16
    80004f8a:	08f51563          	bne	a0,a5,80005014 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004f8e:	04491703          	lh	a4,68(s2)
    80004f92:	4785                	li	a5,1
    80004f94:	08f70663          	beq	a4,a5,80005020 <sys_unlink+0x140>
  iunlockput(dp);
    80004f98:	8526                	mv	a0,s1
    80004f9a:	e58fe0ef          	jal	ra,800035f2 <iunlockput>
  ip->nlink--;
    80004f9e:	04a95783          	lhu	a5,74(s2)
    80004fa2:	37fd                	addiw	a5,a5,-1
    80004fa4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004fa8:	854a                	mv	a0,s2
    80004faa:	b90fe0ef          	jal	ra,8000333a <iupdate>
  iunlockput(ip);
    80004fae:	854a                	mv	a0,s2
    80004fb0:	e42fe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    80004fb4:	e87fe0ef          	jal	ra,80003e3a <end_op>
  return 0;
    80004fb8:	4501                	li	a0,0
    80004fba:	a079                	j	80005048 <sys_unlink+0x168>
    end_op();
    80004fbc:	e7ffe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	a059                	j	80005048 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004fc4:	00002517          	auipc	a0,0x2
    80004fc8:	7dc50513          	addi	a0,a0,2012 # 800077a0 <syscalls+0x300>
    80004fcc:	fc4fb0ef          	jal	ra,80000790 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fd0:	04c92703          	lw	a4,76(s2)
    80004fd4:	02000793          	li	a5,32
    80004fd8:	f8e7f9e3          	bgeu	a5,a4,80004f6a <sys_unlink+0x8a>
    80004fdc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fe0:	4741                	li	a4,16
    80004fe2:	86ce                	mv	a3,s3
    80004fe4:	f1840613          	addi	a2,s0,-232
    80004fe8:	4581                	li	a1,0
    80004fea:	854a                	mv	a0,s2
    80004fec:	f8cfe0ef          	jal	ra,80003778 <readi>
    80004ff0:	47c1                	li	a5,16
    80004ff2:	00f51b63          	bne	a0,a5,80005008 <sys_unlink+0x128>
    if(de.inum != 0)
    80004ff6:	f1845783          	lhu	a5,-232(s0)
    80004ffa:	ef95                	bnez	a5,80005036 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ffc:	29c1                	addiw	s3,s3,16
    80004ffe:	04c92783          	lw	a5,76(s2)
    80005002:	fcf9efe3          	bltu	s3,a5,80004fe0 <sys_unlink+0x100>
    80005006:	b795                	j	80004f6a <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005008:	00002517          	auipc	a0,0x2
    8000500c:	7b050513          	addi	a0,a0,1968 # 800077b8 <syscalls+0x318>
    80005010:	f80fb0ef          	jal	ra,80000790 <panic>
    panic("unlink: writei");
    80005014:	00002517          	auipc	a0,0x2
    80005018:	7bc50513          	addi	a0,a0,1980 # 800077d0 <syscalls+0x330>
    8000501c:	f74fb0ef          	jal	ra,80000790 <panic>
    dp->nlink--;
    80005020:	04a4d783          	lhu	a5,74(s1)
    80005024:	37fd                	addiw	a5,a5,-1
    80005026:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000502a:	8526                	mv	a0,s1
    8000502c:	b0efe0ef          	jal	ra,8000333a <iupdate>
    80005030:	b7a5                	j	80004f98 <sys_unlink+0xb8>
    return -1;
    80005032:	557d                	li	a0,-1
    80005034:	a811                	j	80005048 <sys_unlink+0x168>
    iunlockput(ip);
    80005036:	854a                	mv	a0,s2
    80005038:	dbafe0ef          	jal	ra,800035f2 <iunlockput>
  iunlockput(dp);
    8000503c:	8526                	mv	a0,s1
    8000503e:	db4fe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    80005042:	df9fe0ef          	jal	ra,80003e3a <end_op>
  return -1;
    80005046:	557d                	li	a0,-1
}
    80005048:	70ae                	ld	ra,232(sp)
    8000504a:	740e                	ld	s0,224(sp)
    8000504c:	64ee                	ld	s1,216(sp)
    8000504e:	694e                	ld	s2,208(sp)
    80005050:	69ae                	ld	s3,200(sp)
    80005052:	616d                	addi	sp,sp,240
    80005054:	8082                	ret

0000000080005056 <sys_open>:

uint64
sys_open(void)
{
    80005056:	7131                	addi	sp,sp,-192
    80005058:	fd06                	sd	ra,184(sp)
    8000505a:	f922                	sd	s0,176(sp)
    8000505c:	f526                	sd	s1,168(sp)
    8000505e:	f14a                	sd	s2,160(sp)
    80005060:	ed4e                	sd	s3,152(sp)
    80005062:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005064:	f4c40593          	addi	a1,s0,-180
    80005068:	4505                	li	a0,1
    8000506a:	8e3fd0ef          	jal	ra,8000294c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000506e:	08000613          	li	a2,128
    80005072:	f5040593          	addi	a1,s0,-176
    80005076:	4501                	li	a0,0
    80005078:	90dfd0ef          	jal	ra,80002984 <argstr>
    8000507c:	87aa                	mv	a5,a0
    return -1;
    8000507e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005080:	0807cd63          	bltz	a5,8000511a <sys_open+0xc4>

  begin_op();
    80005084:	d47fe0ef          	jal	ra,80003dca <begin_op>

  if(omode & O_CREATE){
    80005088:	f4c42783          	lw	a5,-180(s0)
    8000508c:	2007f793          	andi	a5,a5,512
    80005090:	c3c5                	beqz	a5,80005130 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005092:	4681                	li	a3,0
    80005094:	4601                	li	a2,0
    80005096:	4589                	li	a1,2
    80005098:	f5040513          	addi	a0,s0,-176
    8000509c:	ac1ff0ef          	jal	ra,80004b5c <create>
    800050a0:	84aa                	mv	s1,a0
    if(ip == 0){
    800050a2:	c159                	beqz	a0,80005128 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800050a4:	04449703          	lh	a4,68(s1)
    800050a8:	478d                	li	a5,3
    800050aa:	00f71763          	bne	a4,a5,800050b8 <sys_open+0x62>
    800050ae:	0464d703          	lhu	a4,70(s1)
    800050b2:	47a5                	li	a5,9
    800050b4:	0ae7e963          	bltu	a5,a4,80005166 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050b8:	87cff0ef          	jal	ra,80004134 <filealloc>
    800050bc:	89aa                	mv	s3,a0
    800050be:	0c050963          	beqz	a0,80005190 <sys_open+0x13a>
    800050c2:	a5dff0ef          	jal	ra,80004b1e <fdalloc>
    800050c6:	892a                	mv	s2,a0
    800050c8:	0c054163          	bltz	a0,8000518a <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050cc:	04449703          	lh	a4,68(s1)
    800050d0:	478d                	li	a5,3
    800050d2:	0af70163          	beq	a4,a5,80005174 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050d6:	4789                	li	a5,2
    800050d8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800050dc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800050e0:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800050e4:	f4c42783          	lw	a5,-180(s0)
    800050e8:	0017c713          	xori	a4,a5,1
    800050ec:	8b05                	andi	a4,a4,1
    800050ee:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050f2:	0037f713          	andi	a4,a5,3
    800050f6:	00e03733          	snez	a4,a4
    800050fa:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050fe:	4007f793          	andi	a5,a5,1024
    80005102:	c791                	beqz	a5,8000510e <sys_open+0xb8>
    80005104:	04449703          	lh	a4,68(s1)
    80005108:	4789                	li	a5,2
    8000510a:	06f70c63          	beq	a4,a5,80005182 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000510e:	8526                	mv	a0,s1
    80005110:	b86fe0ef          	jal	ra,80003496 <iunlock>
  end_op();
    80005114:	d27fe0ef          	jal	ra,80003e3a <end_op>

  return fd;
    80005118:	854a                	mv	a0,s2
}
    8000511a:	70ea                	ld	ra,184(sp)
    8000511c:	744a                	ld	s0,176(sp)
    8000511e:	74aa                	ld	s1,168(sp)
    80005120:	790a                	ld	s2,160(sp)
    80005122:	69ea                	ld	s3,152(sp)
    80005124:	6129                	addi	sp,sp,192
    80005126:	8082                	ret
      end_op();
    80005128:	d13fe0ef          	jal	ra,80003e3a <end_op>
      return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	b7f5                	j	8000511a <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005130:	f5040513          	addi	a0,s0,-176
    80005134:	aa7fe0ef          	jal	ra,80003bda <namei>
    80005138:	84aa                	mv	s1,a0
    8000513a:	c115                	beqz	a0,8000515e <sys_open+0x108>
    ilock(ip);
    8000513c:	ab0fe0ef          	jal	ra,800033ec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005140:	04449703          	lh	a4,68(s1)
    80005144:	4785                	li	a5,1
    80005146:	f4f71fe3          	bne	a4,a5,800050a4 <sys_open+0x4e>
    8000514a:	f4c42783          	lw	a5,-180(s0)
    8000514e:	d7ad                	beqz	a5,800050b8 <sys_open+0x62>
      iunlockput(ip);
    80005150:	8526                	mv	a0,s1
    80005152:	ca0fe0ef          	jal	ra,800035f2 <iunlockput>
      end_op();
    80005156:	ce5fe0ef          	jal	ra,80003e3a <end_op>
      return -1;
    8000515a:	557d                	li	a0,-1
    8000515c:	bf7d                	j	8000511a <sys_open+0xc4>
      end_op();
    8000515e:	cddfe0ef          	jal	ra,80003e3a <end_op>
      return -1;
    80005162:	557d                	li	a0,-1
    80005164:	bf5d                	j	8000511a <sys_open+0xc4>
    iunlockput(ip);
    80005166:	8526                	mv	a0,s1
    80005168:	c8afe0ef          	jal	ra,800035f2 <iunlockput>
    end_op();
    8000516c:	ccffe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80005170:	557d                	li	a0,-1
    80005172:	b765                	j	8000511a <sys_open+0xc4>
    f->type = FD_DEVICE;
    80005174:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005178:	04649783          	lh	a5,70(s1)
    8000517c:	02f99223          	sh	a5,36(s3)
    80005180:	b785                	j	800050e0 <sys_open+0x8a>
    itrunc(ip);
    80005182:	8526                	mv	a0,s1
    80005184:	b52fe0ef          	jal	ra,800034d6 <itrunc>
    80005188:	b759                	j	8000510e <sys_open+0xb8>
      fileclose(f);
    8000518a:	854e                	mv	a0,s3
    8000518c:	84cff0ef          	jal	ra,800041d8 <fileclose>
    iunlockput(ip);
    80005190:	8526                	mv	a0,s1
    80005192:	c60fe0ef          	jal	ra,800035f2 <iunlockput>
    end_op();
    80005196:	ca5fe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    8000519a:	557d                	li	a0,-1
    8000519c:	bfbd                	j	8000511a <sys_open+0xc4>

000000008000519e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000519e:	7175                	addi	sp,sp,-144
    800051a0:	e506                	sd	ra,136(sp)
    800051a2:	e122                	sd	s0,128(sp)
    800051a4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800051a6:	c25fe0ef          	jal	ra,80003dca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800051aa:	08000613          	li	a2,128
    800051ae:	f7040593          	addi	a1,s0,-144
    800051b2:	4501                	li	a0,0
    800051b4:	fd0fd0ef          	jal	ra,80002984 <argstr>
    800051b8:	02054363          	bltz	a0,800051de <sys_mkdir+0x40>
    800051bc:	4681                	li	a3,0
    800051be:	4601                	li	a2,0
    800051c0:	4585                	li	a1,1
    800051c2:	f7040513          	addi	a0,s0,-144
    800051c6:	997ff0ef          	jal	ra,80004b5c <create>
    800051ca:	c911                	beqz	a0,800051de <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051cc:	c26fe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    800051d0:	c6bfe0ef          	jal	ra,80003e3a <end_op>
  return 0;
    800051d4:	4501                	li	a0,0
}
    800051d6:	60aa                	ld	ra,136(sp)
    800051d8:	640a                	ld	s0,128(sp)
    800051da:	6149                	addi	sp,sp,144
    800051dc:	8082                	ret
    end_op();
    800051de:	c5dfe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    800051e2:	557d                	li	a0,-1
    800051e4:	bfcd                	j	800051d6 <sys_mkdir+0x38>

00000000800051e6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800051e6:	7135                	addi	sp,sp,-160
    800051e8:	ed06                	sd	ra,152(sp)
    800051ea:	e922                	sd	s0,144(sp)
    800051ec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051ee:	bddfe0ef          	jal	ra,80003dca <begin_op>
  argint(1, &major);
    800051f2:	f6c40593          	addi	a1,s0,-148
    800051f6:	4505                	li	a0,1
    800051f8:	f54fd0ef          	jal	ra,8000294c <argint>
  argint(2, &minor);
    800051fc:	f6840593          	addi	a1,s0,-152
    80005200:	4509                	li	a0,2
    80005202:	f4afd0ef          	jal	ra,8000294c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005206:	08000613          	li	a2,128
    8000520a:	f7040593          	addi	a1,s0,-144
    8000520e:	4501                	li	a0,0
    80005210:	f74fd0ef          	jal	ra,80002984 <argstr>
    80005214:	02054563          	bltz	a0,8000523e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005218:	f6841683          	lh	a3,-152(s0)
    8000521c:	f6c41603          	lh	a2,-148(s0)
    80005220:	458d                	li	a1,3
    80005222:	f7040513          	addi	a0,s0,-144
    80005226:	937ff0ef          	jal	ra,80004b5c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000522a:	c911                	beqz	a0,8000523e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000522c:	bc6fe0ef          	jal	ra,800035f2 <iunlockput>
  end_op();
    80005230:	c0bfe0ef          	jal	ra,80003e3a <end_op>
  return 0;
    80005234:	4501                	li	a0,0
}
    80005236:	60ea                	ld	ra,152(sp)
    80005238:	644a                	ld	s0,144(sp)
    8000523a:	610d                	addi	sp,sp,160
    8000523c:	8082                	ret
    end_op();
    8000523e:	bfdfe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	bfcd                	j	80005236 <sys_mknod+0x50>

0000000080005246 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005246:	7135                	addi	sp,sp,-160
    80005248:	ed06                	sd	ra,152(sp)
    8000524a:	e922                	sd	s0,144(sp)
    8000524c:	e526                	sd	s1,136(sp)
    8000524e:	e14a                	sd	s2,128(sp)
    80005250:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005252:	dc8fc0ef          	jal	ra,8000181a <myproc>
    80005256:	892a                	mv	s2,a0
  
  begin_op();
    80005258:	b73fe0ef          	jal	ra,80003dca <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000525c:	08000613          	li	a2,128
    80005260:	f6040593          	addi	a1,s0,-160
    80005264:	4501                	li	a0,0
    80005266:	f1efd0ef          	jal	ra,80002984 <argstr>
    8000526a:	04054163          	bltz	a0,800052ac <sys_chdir+0x66>
    8000526e:	f6040513          	addi	a0,s0,-160
    80005272:	969fe0ef          	jal	ra,80003bda <namei>
    80005276:	84aa                	mv	s1,a0
    80005278:	c915                	beqz	a0,800052ac <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000527a:	972fe0ef          	jal	ra,800033ec <ilock>
  if(ip->type != T_DIR){
    8000527e:	04449703          	lh	a4,68(s1)
    80005282:	4785                	li	a5,1
    80005284:	02f71863          	bne	a4,a5,800052b4 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005288:	8526                	mv	a0,s1
    8000528a:	a0cfe0ef          	jal	ra,80003496 <iunlock>
  iput(p->cwd);
    8000528e:	15093503          	ld	a0,336(s2)
    80005292:	ad8fe0ef          	jal	ra,8000356a <iput>
  end_op();
    80005296:	ba5fe0ef          	jal	ra,80003e3a <end_op>
  p->cwd = ip;
    8000529a:	14993823          	sd	s1,336(s2)
  return 0;
    8000529e:	4501                	li	a0,0
}
    800052a0:	60ea                	ld	ra,152(sp)
    800052a2:	644a                	ld	s0,144(sp)
    800052a4:	64aa                	ld	s1,136(sp)
    800052a6:	690a                	ld	s2,128(sp)
    800052a8:	610d                	addi	sp,sp,160
    800052aa:	8082                	ret
    end_op();
    800052ac:	b8ffe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    800052b0:	557d                	li	a0,-1
    800052b2:	b7fd                	j	800052a0 <sys_chdir+0x5a>
    iunlockput(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	b3cfe0ef          	jal	ra,800035f2 <iunlockput>
    end_op();
    800052ba:	b81fe0ef          	jal	ra,80003e3a <end_op>
    return -1;
    800052be:	557d                	li	a0,-1
    800052c0:	b7c5                	j	800052a0 <sys_chdir+0x5a>

00000000800052c2 <sys_exec>:

uint64
sys_exec(void)
{
    800052c2:	7145                	addi	sp,sp,-464
    800052c4:	e786                	sd	ra,456(sp)
    800052c6:	e3a2                	sd	s0,448(sp)
    800052c8:	ff26                	sd	s1,440(sp)
    800052ca:	fb4a                	sd	s2,432(sp)
    800052cc:	f74e                	sd	s3,424(sp)
    800052ce:	f352                	sd	s4,416(sp)
    800052d0:	ef56                	sd	s5,408(sp)
    800052d2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052d4:	e3840593          	addi	a1,s0,-456
    800052d8:	4505                	li	a0,1
    800052da:	e8efd0ef          	jal	ra,80002968 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052de:	08000613          	li	a2,128
    800052e2:	f4040593          	addi	a1,s0,-192
    800052e6:	4501                	li	a0,0
    800052e8:	e9cfd0ef          	jal	ra,80002984 <argstr>
    800052ec:	87aa                	mv	a5,a0
    return -1;
    800052ee:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052f0:	0a07c463          	bltz	a5,80005398 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    800052f4:	10000613          	li	a2,256
    800052f8:	4581                	li	a1,0
    800052fa:	e4040513          	addi	a0,s0,-448
    800052fe:	951fb0ef          	jal	ra,80000c4e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005302:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005306:	89a6                	mv	s3,s1
    80005308:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000530a:	02000a13          	li	s4,32
    8000530e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005312:	00391513          	slli	a0,s2,0x3
    80005316:	e3040593          	addi	a1,s0,-464
    8000531a:	e3843783          	ld	a5,-456(s0)
    8000531e:	953e                	add	a0,a0,a5
    80005320:	da2fd0ef          	jal	ra,800028c2 <fetchaddr>
    80005324:	02054663          	bltz	a0,80005350 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005328:	e3043783          	ld	a5,-464(s0)
    8000532c:	cf8d                	beqz	a5,80005366 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000532e:	f7cfb0ef          	jal	ra,80000aaa <kalloc>
    80005332:	85aa                	mv	a1,a0
    80005334:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005338:	cd01                	beqz	a0,80005350 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000533a:	6605                	lui	a2,0x1
    8000533c:	e3043503          	ld	a0,-464(s0)
    80005340:	dccfd0ef          	jal	ra,8000290c <fetchstr>
    80005344:	00054663          	bltz	a0,80005350 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005348:	0905                	addi	s2,s2,1
    8000534a:	09a1                	addi	s3,s3,8
    8000534c:	fd4911e3          	bne	s2,s4,8000530e <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005350:	10048913          	addi	s2,s1,256
    80005354:	6088                	ld	a0,0(s1)
    80005356:	c121                	beqz	a0,80005396 <sys_exec+0xd4>
    kfree(argv[i]);
    80005358:	e72fb0ef          	jal	ra,800009ca <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000535c:	04a1                	addi	s1,s1,8
    8000535e:	ff249be3          	bne	s1,s2,80005354 <sys_exec+0x92>
  return -1;
    80005362:	557d                	li	a0,-1
    80005364:	a815                	j	80005398 <sys_exec+0xd6>
      argv[i] = 0;
    80005366:	0a8e                	slli	s5,s5,0x3
    80005368:	fc040793          	addi	a5,s0,-64
    8000536c:	9abe                	add	s5,s5,a5
    8000536e:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    80005372:	e4040593          	addi	a1,s0,-448
    80005376:	f4040513          	addi	a0,s0,-192
    8000537a:	c18ff0ef          	jal	ra,80004792 <kexec>
    8000537e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005380:	10048993          	addi	s3,s1,256
    80005384:	6088                	ld	a0,0(s1)
    80005386:	c511                	beqz	a0,80005392 <sys_exec+0xd0>
    kfree(argv[i]);
    80005388:	e42fb0ef          	jal	ra,800009ca <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000538c:	04a1                	addi	s1,s1,8
    8000538e:	ff349be3          	bne	s1,s3,80005384 <sys_exec+0xc2>
  return ret;
    80005392:	854a                	mv	a0,s2
    80005394:	a011                	j	80005398 <sys_exec+0xd6>
  return -1;
    80005396:	557d                	li	a0,-1
}
    80005398:	60be                	ld	ra,456(sp)
    8000539a:	641e                	ld	s0,448(sp)
    8000539c:	74fa                	ld	s1,440(sp)
    8000539e:	795a                	ld	s2,432(sp)
    800053a0:	79ba                	ld	s3,424(sp)
    800053a2:	7a1a                	ld	s4,416(sp)
    800053a4:	6afa                	ld	s5,408(sp)
    800053a6:	6179                	addi	sp,sp,464
    800053a8:	8082                	ret

00000000800053aa <sys_pipe>:

uint64
sys_pipe(void)
{
    800053aa:	7139                	addi	sp,sp,-64
    800053ac:	fc06                	sd	ra,56(sp)
    800053ae:	f822                	sd	s0,48(sp)
    800053b0:	f426                	sd	s1,40(sp)
    800053b2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053b4:	c66fc0ef          	jal	ra,8000181a <myproc>
    800053b8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053ba:	fd840593          	addi	a1,s0,-40
    800053be:	4501                	li	a0,0
    800053c0:	da8fd0ef          	jal	ra,80002968 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053c4:	fc840593          	addi	a1,s0,-56
    800053c8:	fd040513          	addi	a0,s0,-48
    800053cc:	8d8ff0ef          	jal	ra,800044a4 <pipealloc>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053d2:	0a054463          	bltz	a0,8000547a <sys_pipe+0xd0>
  fd0 = -1;
    800053d6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053da:	fd043503          	ld	a0,-48(s0)
    800053de:	f40ff0ef          	jal	ra,80004b1e <fdalloc>
    800053e2:	fca42223          	sw	a0,-60(s0)
    800053e6:	08054163          	bltz	a0,80005468 <sys_pipe+0xbe>
    800053ea:	fc843503          	ld	a0,-56(s0)
    800053ee:	f30ff0ef          	jal	ra,80004b1e <fdalloc>
    800053f2:	fca42023          	sw	a0,-64(s0)
    800053f6:	06054063          	bltz	a0,80005456 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053fa:	4691                	li	a3,4
    800053fc:	fc440613          	addi	a2,s0,-60
    80005400:	fd843583          	ld	a1,-40(s0)
    80005404:	68a8                	ld	a0,80(s1)
    80005406:	962fc0ef          	jal	ra,80001568 <copyout>
    8000540a:	00054e63          	bltz	a0,80005426 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000540e:	4691                	li	a3,4
    80005410:	fc040613          	addi	a2,s0,-64
    80005414:	fd843583          	ld	a1,-40(s0)
    80005418:	0591                	addi	a1,a1,4
    8000541a:	68a8                	ld	a0,80(s1)
    8000541c:	94cfc0ef          	jal	ra,80001568 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005420:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005422:	04055c63          	bgez	a0,8000547a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005426:	fc442783          	lw	a5,-60(s0)
    8000542a:	07e9                	addi	a5,a5,26
    8000542c:	078e                	slli	a5,a5,0x3
    8000542e:	97a6                	add	a5,a5,s1
    80005430:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005434:	fc042503          	lw	a0,-64(s0)
    80005438:	0569                	addi	a0,a0,26
    8000543a:	050e                	slli	a0,a0,0x3
    8000543c:	94aa                	add	s1,s1,a0
    8000543e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005442:	fd043503          	ld	a0,-48(s0)
    80005446:	d93fe0ef          	jal	ra,800041d8 <fileclose>
    fileclose(wf);
    8000544a:	fc843503          	ld	a0,-56(s0)
    8000544e:	d8bfe0ef          	jal	ra,800041d8 <fileclose>
    return -1;
    80005452:	57fd                	li	a5,-1
    80005454:	a01d                	j	8000547a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005456:	fc442783          	lw	a5,-60(s0)
    8000545a:	0007c763          	bltz	a5,80005468 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000545e:	07e9                	addi	a5,a5,26
    80005460:	078e                	slli	a5,a5,0x3
    80005462:	94be                	add	s1,s1,a5
    80005464:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005468:	fd043503          	ld	a0,-48(s0)
    8000546c:	d6dfe0ef          	jal	ra,800041d8 <fileclose>
    fileclose(wf);
    80005470:	fc843503          	ld	a0,-56(s0)
    80005474:	d65fe0ef          	jal	ra,800041d8 <fileclose>
    return -1;
    80005478:	57fd                	li	a5,-1
}
    8000547a:	853e                	mv	a0,a5
    8000547c:	70e2                	ld	ra,56(sp)
    8000547e:	7442                	ld	s0,48(sp)
    80005480:	74a2                	ld	s1,40(sp)
    80005482:	6121                	addi	sp,sp,64
    80005484:	8082                	ret
	...

0000000080005490 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005490:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005492:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005494:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005496:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005498:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000549a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000549c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000549e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800054a0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800054a2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800054a4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800054a6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800054a8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800054aa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800054ac:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800054ae:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054b0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054b2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054b4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054b6:	abafd0ef          	jal	ra,80002770 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054ba:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054bc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054be:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054c0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054c2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054c4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054c6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054c8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054ca:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054cc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054ce:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054d0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054d2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054d4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054d6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054d8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054da:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054dc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054de:	10200073          	sret
	...

00000000800054ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054ee:	1141                	addi	sp,sp,-16
    800054f0:	e422                	sd	s0,8(sp)
    800054f2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054f4:	0c0007b7          	lui	a5,0xc000
    800054f8:	4705                	li	a4,1
    800054fa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054fc:	c3d8                	sw	a4,4(a5)
}
    800054fe:	6422                	ld	s0,8(sp)
    80005500:	0141                	addi	sp,sp,16
    80005502:	8082                	ret

0000000080005504 <plicinithart>:

void
plicinithart(void)
{
    80005504:	1141                	addi	sp,sp,-16
    80005506:	e406                	sd	ra,8(sp)
    80005508:	e022                	sd	s0,0(sp)
    8000550a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000550c:	ae2fc0ef          	jal	ra,800017ee <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005510:	0085171b          	slliw	a4,a0,0x8
    80005514:	0c0027b7          	lui	a5,0xc002
    80005518:	97ba                	add	a5,a5,a4
    8000551a:	40200713          	li	a4,1026
    8000551e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005522:	00d5151b          	slliw	a0,a0,0xd
    80005526:	0c2017b7          	lui	a5,0xc201
    8000552a:	953e                	add	a0,a0,a5
    8000552c:	00052023          	sw	zero,0(a0)
}
    80005530:	60a2                	ld	ra,8(sp)
    80005532:	6402                	ld	s0,0(sp)
    80005534:	0141                	addi	sp,sp,16
    80005536:	8082                	ret

0000000080005538 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005538:	1141                	addi	sp,sp,-16
    8000553a:	e406                	sd	ra,8(sp)
    8000553c:	e022                	sd	s0,0(sp)
    8000553e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005540:	aaefc0ef          	jal	ra,800017ee <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005544:	00d5179b          	slliw	a5,a0,0xd
    80005548:	0c201537          	lui	a0,0xc201
    8000554c:	953e                	add	a0,a0,a5
  return irq;
}
    8000554e:	4148                	lw	a0,4(a0)
    80005550:	60a2                	ld	ra,8(sp)
    80005552:	6402                	ld	s0,0(sp)
    80005554:	0141                	addi	sp,sp,16
    80005556:	8082                	ret

0000000080005558 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005558:	1101                	addi	sp,sp,-32
    8000555a:	ec06                	sd	ra,24(sp)
    8000555c:	e822                	sd	s0,16(sp)
    8000555e:	e426                	sd	s1,8(sp)
    80005560:	1000                	addi	s0,sp,32
    80005562:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005564:	a8afc0ef          	jal	ra,800017ee <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005568:	00d5151b          	slliw	a0,a0,0xd
    8000556c:	0c2017b7          	lui	a5,0xc201
    80005570:	97aa                	add	a5,a5,a0
    80005572:	c3c4                	sw	s1,4(a5)
}
    80005574:	60e2                	ld	ra,24(sp)
    80005576:	6442                	ld	s0,16(sp)
    80005578:	64a2                	ld	s1,8(sp)
    8000557a:	6105                	addi	sp,sp,32
    8000557c:	8082                	ret

000000008000557e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000557e:	1141                	addi	sp,sp,-16
    80005580:	e406                	sd	ra,8(sp)
    80005582:	e022                	sd	s0,0(sp)
    80005584:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005586:	479d                	li	a5,7
    80005588:	04a7ca63          	blt	a5,a0,800055dc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000558c:	0001c797          	auipc	a5,0x1c
    80005590:	98c78793          	addi	a5,a5,-1652 # 80020f18 <disk>
    80005594:	97aa                	add	a5,a5,a0
    80005596:	0187c783          	lbu	a5,24(a5)
    8000559a:	e7b9                	bnez	a5,800055e8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000559c:	00451613          	slli	a2,a0,0x4
    800055a0:	0001c797          	auipc	a5,0x1c
    800055a4:	97878793          	addi	a5,a5,-1672 # 80020f18 <disk>
    800055a8:	6394                	ld	a3,0(a5)
    800055aa:	96b2                	add	a3,a3,a2
    800055ac:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800055b0:	6398                	ld	a4,0(a5)
    800055b2:	9732                	add	a4,a4,a2
    800055b4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055b8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055bc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055c0:	953e                	add	a0,a0,a5
    800055c2:	4785                	li	a5,1
    800055c4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800055c8:	0001c517          	auipc	a0,0x1c
    800055cc:	96850513          	addi	a0,a0,-1688 # 80020f30 <disk+0x18>
    800055d0:	9adfc0ef          	jal	ra,80001f7c <wakeup>
}
    800055d4:	60a2                	ld	ra,8(sp)
    800055d6:	6402                	ld	s0,0(sp)
    800055d8:	0141                	addi	sp,sp,16
    800055da:	8082                	ret
    panic("free_desc 1");
    800055dc:	00002517          	auipc	a0,0x2
    800055e0:	20450513          	addi	a0,a0,516 # 800077e0 <syscalls+0x340>
    800055e4:	9acfb0ef          	jal	ra,80000790 <panic>
    panic("free_desc 2");
    800055e8:	00002517          	auipc	a0,0x2
    800055ec:	20850513          	addi	a0,a0,520 # 800077f0 <syscalls+0x350>
    800055f0:	9a0fb0ef          	jal	ra,80000790 <panic>

00000000800055f4 <virtio_disk_init>:
{
    800055f4:	1101                	addi	sp,sp,-32
    800055f6:	ec06                	sd	ra,24(sp)
    800055f8:	e822                	sd	s0,16(sp)
    800055fa:	e426                	sd	s1,8(sp)
    800055fc:	e04a                	sd	s2,0(sp)
    800055fe:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005600:	00002597          	auipc	a1,0x2
    80005604:	20058593          	addi	a1,a1,512 # 80007800 <syscalls+0x360>
    80005608:	0001c517          	auipc	a0,0x1c
    8000560c:	a3850513          	addi	a0,a0,-1480 # 80021040 <disk+0x128>
    80005610:	ceafb0ef          	jal	ra,80000afa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005614:	100017b7          	lui	a5,0x10001
    80005618:	4398                	lw	a4,0(a5)
    8000561a:	2701                	sext.w	a4,a4
    8000561c:	747277b7          	lui	a5,0x74727
    80005620:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005624:	14f71263          	bne	a4,a5,80005768 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005628:	100017b7          	lui	a5,0x10001
    8000562c:	43dc                	lw	a5,4(a5)
    8000562e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005630:	4709                	li	a4,2
    80005632:	12e79b63          	bne	a5,a4,80005768 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005636:	100017b7          	lui	a5,0x10001
    8000563a:	479c                	lw	a5,8(a5)
    8000563c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000563e:	12e79563          	bne	a5,a4,80005768 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005642:	100017b7          	lui	a5,0x10001
    80005646:	47d8                	lw	a4,12(a5)
    80005648:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000564a:	554d47b7          	lui	a5,0x554d4
    8000564e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005652:	10f71b63          	bne	a4,a5,80005768 <virtio_disk_init+0x174>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005656:	100017b7          	lui	a5,0x10001
    8000565a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000565e:	4705                	li	a4,1
    80005660:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005662:	470d                	li	a4,3
    80005664:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005666:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005668:	c7ffe737          	lui	a4,0xc7ffe
    8000566c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd707>
    80005670:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005672:	2701                	sext.w	a4,a4
    80005674:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005676:	472d                	li	a4,11
    80005678:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000567a:	0707a903          	lw	s2,112(a5)
    8000567e:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005680:	00897793          	andi	a5,s2,8
    80005684:	0e078863          	beqz	a5,80005774 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005688:	100017b7          	lui	a5,0x10001
    8000568c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005690:	43fc                	lw	a5,68(a5)
    80005692:	2781                	sext.w	a5,a5
    80005694:	0e079663          	bnez	a5,80005780 <virtio_disk_init+0x18c>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005698:	100017b7          	lui	a5,0x10001
    8000569c:	5bdc                	lw	a5,52(a5)
    8000569e:	2781                	sext.w	a5,a5
  if(max == 0)
    800056a0:	0e078663          	beqz	a5,8000578c <virtio_disk_init+0x198>
  if(max < NUM)
    800056a4:	471d                	li	a4,7
    800056a6:	0ef77963          	bgeu	a4,a5,80005798 <virtio_disk_init+0x1a4>
  disk.desc = kalloc();
    800056aa:	c00fb0ef          	jal	ra,80000aaa <kalloc>
    800056ae:	0001c497          	auipc	s1,0x1c
    800056b2:	86a48493          	addi	s1,s1,-1942 # 80020f18 <disk>
    800056b6:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056b8:	bf2fb0ef          	jal	ra,80000aaa <kalloc>
    800056bc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056be:	becfb0ef          	jal	ra,80000aaa <kalloc>
    800056c2:	87aa                	mv	a5,a0
    800056c4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056c6:	6088                	ld	a0,0(s1)
    800056c8:	cd71                	beqz	a0,800057a4 <virtio_disk_init+0x1b0>
    800056ca:	0001c717          	auipc	a4,0x1c
    800056ce:	85673703          	ld	a4,-1962(a4) # 80020f20 <disk+0x8>
    800056d2:	cb69                	beqz	a4,800057a4 <virtio_disk_init+0x1b0>
    800056d4:	cbe1                	beqz	a5,800057a4 <virtio_disk_init+0x1b0>
  memset(disk.desc, 0, PGSIZE);
    800056d6:	6605                	lui	a2,0x1
    800056d8:	4581                	li	a1,0
    800056da:	d74fb0ef          	jal	ra,80000c4e <memset>
  memset(disk.avail, 0, PGSIZE);
    800056de:	0001c497          	auipc	s1,0x1c
    800056e2:	83a48493          	addi	s1,s1,-1990 # 80020f18 <disk>
    800056e6:	6605                	lui	a2,0x1
    800056e8:	4581                	li	a1,0
    800056ea:	6488                	ld	a0,8(s1)
    800056ec:	d62fb0ef          	jal	ra,80000c4e <memset>
  memset(disk.used, 0, PGSIZE);
    800056f0:	6605                	lui	a2,0x1
    800056f2:	4581                	li	a1,0
    800056f4:	6888                	ld	a0,16(s1)
    800056f6:	d58fb0ef          	jal	ra,80000c4e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056fa:	100017b7          	lui	a5,0x10001
    800056fe:	4721                	li	a4,8
    80005700:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005702:	4098                	lw	a4,0(s1)
    80005704:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005708:	40d8                	lw	a4,4(s1)
    8000570a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000570e:	6498                	ld	a4,8(s1)
    80005710:	0007069b          	sext.w	a3,a4
    80005714:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005718:	9701                	srai	a4,a4,0x20
    8000571a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000571e:	6898                	ld	a4,16(s1)
    80005720:	0007069b          	sext.w	a3,a4
    80005724:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005728:	9701                	srai	a4,a4,0x20
    8000572a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000572e:	4685                	li	a3,1
    80005730:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80005732:	4705                	li	a4,1
    80005734:	00d48c23          	sb	a3,24(s1)
    80005738:	00e48ca3          	sb	a4,25(s1)
    8000573c:	00e48d23          	sb	a4,26(s1)
    80005740:	00e48da3          	sb	a4,27(s1)
    80005744:	00e48e23          	sb	a4,28(s1)
    80005748:	00e48ea3          	sb	a4,29(s1)
    8000574c:	00e48f23          	sb	a4,30(s1)
    80005750:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005754:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005758:	0727a823          	sw	s2,112(a5)
}
    8000575c:	60e2                	ld	ra,24(sp)
    8000575e:	6442                	ld	s0,16(sp)
    80005760:	64a2                	ld	s1,8(sp)
    80005762:	6902                	ld	s2,0(sp)
    80005764:	6105                	addi	sp,sp,32
    80005766:	8082                	ret
    panic("could not find virtio disk");
    80005768:	00002517          	auipc	a0,0x2
    8000576c:	0a850513          	addi	a0,a0,168 # 80007810 <syscalls+0x370>
    80005770:	820fb0ef          	jal	ra,80000790 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005774:	00002517          	auipc	a0,0x2
    80005778:	0bc50513          	addi	a0,a0,188 # 80007830 <syscalls+0x390>
    8000577c:	814fb0ef          	jal	ra,80000790 <panic>
    panic("virtio disk should not be ready");
    80005780:	00002517          	auipc	a0,0x2
    80005784:	0d050513          	addi	a0,a0,208 # 80007850 <syscalls+0x3b0>
    80005788:	808fb0ef          	jal	ra,80000790 <panic>
    panic("virtio disk has no queue 0");
    8000578c:	00002517          	auipc	a0,0x2
    80005790:	0e450513          	addi	a0,a0,228 # 80007870 <syscalls+0x3d0>
    80005794:	ffdfa0ef          	jal	ra,80000790 <panic>
    panic("virtio disk max queue too short");
    80005798:	00002517          	auipc	a0,0x2
    8000579c:	0f850513          	addi	a0,a0,248 # 80007890 <syscalls+0x3f0>
    800057a0:	ff1fa0ef          	jal	ra,80000790 <panic>
    panic("virtio disk kalloc");
    800057a4:	00002517          	auipc	a0,0x2
    800057a8:	10c50513          	addi	a0,a0,268 # 800078b0 <syscalls+0x410>
    800057ac:	fe5fa0ef          	jal	ra,80000790 <panic>

00000000800057b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057b0:	7159                	addi	sp,sp,-112
    800057b2:	f486                	sd	ra,104(sp)
    800057b4:	f0a2                	sd	s0,96(sp)
    800057b6:	eca6                	sd	s1,88(sp)
    800057b8:	e8ca                	sd	s2,80(sp)
    800057ba:	e4ce                	sd	s3,72(sp)
    800057bc:	e0d2                	sd	s4,64(sp)
    800057be:	fc56                	sd	s5,56(sp)
    800057c0:	f85a                	sd	s6,48(sp)
    800057c2:	f45e                	sd	s7,40(sp)
    800057c4:	f062                	sd	s8,32(sp)
    800057c6:	ec66                	sd	s9,24(sp)
    800057c8:	e86a                	sd	s10,16(sp)
    800057ca:	1880                	addi	s0,sp,112
    800057cc:	892a                	mv	s2,a0
    800057ce:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057d0:	00c52c83          	lw	s9,12(a0)
    800057d4:	001c9c9b          	slliw	s9,s9,0x1
    800057d8:	1c82                	slli	s9,s9,0x20
    800057da:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800057de:	0001c517          	auipc	a0,0x1c
    800057e2:	86250513          	addi	a0,a0,-1950 # 80021040 <disk+0x128>
    800057e6:	b94fb0ef          	jal	ra,80000b7a <acquire>
  for(int i = 0; i < 3; i++){
    800057ea:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057ec:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800057ee:	0001bb17          	auipc	s6,0x1b
    800057f2:	72ab0b13          	addi	s6,s6,1834 # 80020f18 <disk>
  for(int i = 0; i < 3; i++){
    800057f6:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800057f8:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057fa:	0001cc17          	auipc	s8,0x1c
    800057fe:	846c0c13          	addi	s8,s8,-1978 # 80021040 <disk+0x128>
    80005802:	a0b5                	j	8000586e <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    80005804:	00fb06b3          	add	a3,s6,a5
    80005808:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    8000580c:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000580e:	0207c563          	bltz	a5,80005838 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005812:	2485                	addiw	s1,s1,1
    80005814:	0711                	addi	a4,a4,4
    80005816:	1d548c63          	beq	s1,s5,800059ee <virtio_disk_rw+0x23e>
    idx[i] = alloc_desc();
    8000581a:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    8000581c:	0001b697          	auipc	a3,0x1b
    80005820:	6fc68693          	addi	a3,a3,1788 # 80020f18 <disk>
    80005824:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005826:	0186c583          	lbu	a1,24(a3)
    8000582a:	fde9                	bnez	a1,80005804 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    8000582c:	2785                	addiw	a5,a5,1
    8000582e:	0685                	addi	a3,a3,1
    80005830:	ff779be3          	bne	a5,s7,80005826 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005834:	57fd                	li	a5,-1
    80005836:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005838:	02905463          	blez	s1,80005860 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    8000583c:	f9042503          	lw	a0,-112(s0)
    80005840:	d3fff0ef          	jal	ra,8000557e <free_desc>
      for(int j = 0; j < i; j++)
    80005844:	4785                	li	a5,1
    80005846:	0097dd63          	bge	a5,s1,80005860 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    8000584a:	f9442503          	lw	a0,-108(s0)
    8000584e:	d31ff0ef          	jal	ra,8000557e <free_desc>
      for(int j = 0; j < i; j++)
    80005852:	4789                	li	a5,2
    80005854:	0097d663          	bge	a5,s1,80005860 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    80005858:	f9842503          	lw	a0,-104(s0)
    8000585c:	d23ff0ef          	jal	ra,8000557e <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005860:	85e2                	mv	a1,s8
    80005862:	0001b517          	auipc	a0,0x1b
    80005866:	6ce50513          	addi	a0,a0,1742 # 80020f30 <disk+0x18>
    8000586a:	ec6fc0ef          	jal	ra,80001f30 <sleep>
  for(int i = 0; i < 3; i++){
    8000586e:	f9040713          	addi	a4,s0,-112
    80005872:	84ce                	mv	s1,s3
    80005874:	b75d                	j	8000581a <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005876:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    8000587a:	00479693          	slli	a3,a5,0x4
    8000587e:	0001b797          	auipc	a5,0x1b
    80005882:	69a78793          	addi	a5,a5,1690 # 80020f18 <disk>
    80005886:	97b6                	add	a5,a5,a3
    80005888:	4685                	li	a3,1
    8000588a:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000588c:	0001b597          	auipc	a1,0x1b
    80005890:	68c58593          	addi	a1,a1,1676 # 80020f18 <disk>
    80005894:	00a60793          	addi	a5,a2,10
    80005898:	0792                	slli	a5,a5,0x4
    8000589a:	97ae                	add	a5,a5,a1
    8000589c:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800058a0:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800058a4:	f6070693          	addi	a3,a4,-160
    800058a8:	619c                	ld	a5,0(a1)
    800058aa:	97b6                	add	a5,a5,a3
    800058ac:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800058ae:	6188                	ld	a0,0(a1)
    800058b0:	96aa                	add	a3,a3,a0
    800058b2:	47c1                	li	a5,16
    800058b4:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800058b6:	4785                	li	a5,1
    800058b8:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800058bc:	f9442783          	lw	a5,-108(s0)
    800058c0:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800058c4:	0792                	slli	a5,a5,0x4
    800058c6:	953e                	add	a0,a0,a5
    800058c8:	05890693          	addi	a3,s2,88
    800058cc:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800058ce:	6188                	ld	a0,0(a1)
    800058d0:	97aa                	add	a5,a5,a0
    800058d2:	40000693          	li	a3,1024
    800058d6:	c794                	sw	a3,8(a5)
  if(write)
    800058d8:	100d0763          	beqz	s10,800059e6 <virtio_disk_rw+0x236>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800058dc:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058e0:	00c7d683          	lhu	a3,12(a5)
    800058e4:	0016e693          	ori	a3,a3,1
    800058e8:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800058ec:	f9842583          	lw	a1,-104(s0)
    800058f0:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058f4:	0001b697          	auipc	a3,0x1b
    800058f8:	62468693          	addi	a3,a3,1572 # 80020f18 <disk>
    800058fc:	00260793          	addi	a5,a2,2
    80005900:	0792                	slli	a5,a5,0x4
    80005902:	97b6                	add	a5,a5,a3
    80005904:	587d                	li	a6,-1
    80005906:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000590a:	0592                	slli	a1,a1,0x4
    8000590c:	952e                	add	a0,a0,a1
    8000590e:	f9070713          	addi	a4,a4,-112
    80005912:	9736                	add	a4,a4,a3
    80005914:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80005916:	6298                	ld	a4,0(a3)
    80005918:	972e                	add	a4,a4,a1
    8000591a:	4585                	li	a1,1
    8000591c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000591e:	4509                	li	a0,2
    80005920:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80005924:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005928:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    8000592c:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005930:	6698                	ld	a4,8(a3)
    80005932:	00275783          	lhu	a5,2(a4)
    80005936:	8b9d                	andi	a5,a5,7
    80005938:	0786                	slli	a5,a5,0x1
    8000593a:	97ba                	add	a5,a5,a4
    8000593c:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    80005940:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005944:	6698                	ld	a4,8(a3)
    80005946:	00275783          	lhu	a5,2(a4)
    8000594a:	2785                	addiw	a5,a5,1
    8000594c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005950:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005954:	100017b7          	lui	a5,0x10001
    80005958:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000595c:	00492703          	lw	a4,4(s2)
    80005960:	4785                	li	a5,1
    80005962:	00f71f63          	bne	a4,a5,80005980 <virtio_disk_rw+0x1d0>
    sleep(b, &disk.vdisk_lock);
    80005966:	0001b997          	auipc	s3,0x1b
    8000596a:	6da98993          	addi	s3,s3,1754 # 80021040 <disk+0x128>
  while(b->disk == 1) {
    8000596e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005970:	85ce                	mv	a1,s3
    80005972:	854a                	mv	a0,s2
    80005974:	dbcfc0ef          	jal	ra,80001f30 <sleep>
  while(b->disk == 1) {
    80005978:	00492783          	lw	a5,4(s2)
    8000597c:	fe978ae3          	beq	a5,s1,80005970 <virtio_disk_rw+0x1c0>
  }

  disk.info[idx[0]].b = 0;
    80005980:	f9042903          	lw	s2,-112(s0)
    80005984:	00290793          	addi	a5,s2,2
    80005988:	00479713          	slli	a4,a5,0x4
    8000598c:	0001b797          	auipc	a5,0x1b
    80005990:	58c78793          	addi	a5,a5,1420 # 80020f18 <disk>
    80005994:	97ba                	add	a5,a5,a4
    80005996:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000599a:	0001b997          	auipc	s3,0x1b
    8000599e:	57e98993          	addi	s3,s3,1406 # 80020f18 <disk>
    800059a2:	00491713          	slli	a4,s2,0x4
    800059a6:	0009b783          	ld	a5,0(s3)
    800059aa:	97ba                	add	a5,a5,a4
    800059ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800059b0:	854a                	mv	a0,s2
    800059b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800059b6:	bc9ff0ef          	jal	ra,8000557e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800059ba:	8885                	andi	s1,s1,1
    800059bc:	f0fd                	bnez	s1,800059a2 <virtio_disk_rw+0x1f2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800059be:	0001b517          	auipc	a0,0x1b
    800059c2:	68250513          	addi	a0,a0,1666 # 80021040 <disk+0x128>
    800059c6:	a4cfb0ef          	jal	ra,80000c12 <release>
}
    800059ca:	70a6                	ld	ra,104(sp)
    800059cc:	7406                	ld	s0,96(sp)
    800059ce:	64e6                	ld	s1,88(sp)
    800059d0:	6946                	ld	s2,80(sp)
    800059d2:	69a6                	ld	s3,72(sp)
    800059d4:	6a06                	ld	s4,64(sp)
    800059d6:	7ae2                	ld	s5,56(sp)
    800059d8:	7b42                	ld	s6,48(sp)
    800059da:	7ba2                	ld	s7,40(sp)
    800059dc:	7c02                	ld	s8,32(sp)
    800059de:	6ce2                	ld	s9,24(sp)
    800059e0:	6d42                	ld	s10,16(sp)
    800059e2:	6165                	addi	sp,sp,112
    800059e4:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800059e6:	4689                	li	a3,2
    800059e8:	00d79623          	sh	a3,12(a5)
    800059ec:	bdd5                	j	800058e0 <virtio_disk_rw+0x130>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059ee:	f9042603          	lw	a2,-112(s0)
    800059f2:	00a60713          	addi	a4,a2,10
    800059f6:	0712                	slli	a4,a4,0x4
    800059f8:	0001b517          	auipc	a0,0x1b
    800059fc:	52850513          	addi	a0,a0,1320 # 80020f20 <disk+0x8>
    80005a00:	953a                	add	a0,a0,a4
  if(write)
    80005a02:	e60d1ae3          	bnez	s10,80005876 <virtio_disk_rw+0xc6>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005a06:	00a60793          	addi	a5,a2,10
    80005a0a:	00479693          	slli	a3,a5,0x4
    80005a0e:	0001b797          	auipc	a5,0x1b
    80005a12:	50a78793          	addi	a5,a5,1290 # 80020f18 <disk>
    80005a16:	97b6                	add	a5,a5,a3
    80005a18:	0007a423          	sw	zero,8(a5)
    80005a1c:	bd85                	j	8000588c <virtio_disk_rw+0xdc>

0000000080005a1e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a1e:	1101                	addi	sp,sp,-32
    80005a20:	ec06                	sd	ra,24(sp)
    80005a22:	e822                	sd	s0,16(sp)
    80005a24:	e426                	sd	s1,8(sp)
    80005a26:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a28:	0001b497          	auipc	s1,0x1b
    80005a2c:	4f048493          	addi	s1,s1,1264 # 80020f18 <disk>
    80005a30:	0001b517          	auipc	a0,0x1b
    80005a34:	61050513          	addi	a0,a0,1552 # 80021040 <disk+0x128>
    80005a38:	942fb0ef          	jal	ra,80000b7a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a3c:	10001737          	lui	a4,0x10001
    80005a40:	533c                	lw	a5,96(a4)
    80005a42:	8b8d                	andi	a5,a5,3
    80005a44:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005a46:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a4a:	689c                	ld	a5,16(s1)
    80005a4c:	0204d703          	lhu	a4,32(s1)
    80005a50:	0027d783          	lhu	a5,2(a5)
    80005a54:	04f70663          	beq	a4,a5,80005aa0 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005a58:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a5c:	6898                	ld	a4,16(s1)
    80005a5e:	0204d783          	lhu	a5,32(s1)
    80005a62:	8b9d                	andi	a5,a5,7
    80005a64:	078e                	slli	a5,a5,0x3
    80005a66:	97ba                	add	a5,a5,a4
    80005a68:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a6a:	00278713          	addi	a4,a5,2
    80005a6e:	0712                	slli	a4,a4,0x4
    80005a70:	9726                	add	a4,a4,s1
    80005a72:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005a76:	e321                	bnez	a4,80005ab6 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a78:	0789                	addi	a5,a5,2
    80005a7a:	0792                	slli	a5,a5,0x4
    80005a7c:	97a6                	add	a5,a5,s1
    80005a7e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a80:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a84:	cf8fc0ef          	jal	ra,80001f7c <wakeup>

    disk.used_idx += 1;
    80005a88:	0204d783          	lhu	a5,32(s1)
    80005a8c:	2785                	addiw	a5,a5,1
    80005a8e:	17c2                	slli	a5,a5,0x30
    80005a90:	93c1                	srli	a5,a5,0x30
    80005a92:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a96:	6898                	ld	a4,16(s1)
    80005a98:	00275703          	lhu	a4,2(a4)
    80005a9c:	faf71ee3          	bne	a4,a5,80005a58 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005aa0:	0001b517          	auipc	a0,0x1b
    80005aa4:	5a050513          	addi	a0,a0,1440 # 80021040 <disk+0x128>
    80005aa8:	96afb0ef          	jal	ra,80000c12 <release>
}
    80005aac:	60e2                	ld	ra,24(sp)
    80005aae:	6442                	ld	s0,16(sp)
    80005ab0:	64a2                	ld	s1,8(sp)
    80005ab2:	6105                	addi	sp,sp,32
    80005ab4:	8082                	ret
      panic("virtio_disk_intr status");
    80005ab6:	00002517          	auipc	a0,0x2
    80005aba:	e1250513          	addi	a0,a0,-494 # 800078c8 <syscalls+0x428>
    80005abe:	cd3fa0ef          	jal	ra,80000790 <panic>
	...

0000000080006000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80006000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80006010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80006014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80006018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000601c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80006020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80006024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80006028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000602a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000602e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80006030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80006032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80006034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80006036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80006046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80006056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80006066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80006072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80006076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000607a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000607e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80006082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80006086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000608a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000608e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80006092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80006096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000609c:	12000073          	sfence.vma
        csrw satp, a0
    800060a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800060a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800060b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800060b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800060bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800060c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800060c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800060c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800060cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800060ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800060d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800060d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800060d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800060da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800060de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80006112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80006116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000611a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000611c:	10200073          	sret
	...
