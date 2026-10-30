
user/_Q3_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_pinfo_snapshot>:
#define TYPE_IO_INTENSIVE 1
#define TYPE_MIXED 2

struct pinfo_all info;

void print_pinfo_snapshot(const char *label) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
    int n = getpinfo(&info);
  10:	00001517          	auipc	a0,0x1
  14:	00050513          	mv	a0,a0
  18:	6b2000ef          	jal	ra,6ca <getpinfo>
  1c:	892a                	mv	s2,a0
    printf("\n--- %s ---\n", label);
  1e:	85a6                	mv	a1,s1
  20:	00001517          	auipc	a0,0x1
  24:	bd050513          	addi	a0,a0,-1072 # bf0 <malloc+0xe8>
  28:	227000ef          	jal	ra,a4e <printf>
    printf("PID\tSTATE\tQ\tREMAIN\n");
  2c:	00001517          	auipc	a0,0x1
  30:	bd450513          	addi	a0,a0,-1068 # c00 <malloc+0xf8>
  34:	21b000ef          	jal	ra,a4e <printf>
    for (int i = 0; i < n; i++) {
  38:	03205e63          	blez	s2,74 <print_pinfo_snapshot+0x74>
  3c:	00001497          	auipc	s1,0x1
  40:	fd848493          	addi	s1,s1,-40 # 1014 <info+0x4>
  44:	397d                	addiw	s2,s2,-1
  46:	1902                	slli	s2,s2,0x20
  48:	02095913          	srli	s2,s2,0x20
  4c:	0912                	slli	s2,s2,0x4
  4e:	00001797          	auipc	a5,0x1
  52:	fd678793          	addi	a5,a5,-42 # 1024 <info+0x14>
  56:	993e                	add	s2,s2,a5
        printf("%d\t%d\t%d\t%d\n",
  58:	00001997          	auipc	s3,0x1
  5c:	bc098993          	addi	s3,s3,-1088 # c18 <malloc+0x110>
  60:	44d8                	lw	a4,12(s1)
  62:	4494                	lw	a3,8(s1)
  64:	40d0                	lw	a2,4(s1)
  66:	408c                	lw	a1,0(s1)
  68:	854e                	mv	a0,s3
  6a:	1e5000ef          	jal	ra,a4e <printf>
    for (int i = 0; i < n; i++) {
  6e:	04c1                	addi	s1,s1,16
  70:	ff2498e3          	bne	s1,s2,60 <print_pinfo_snapshot+0x60>
            info.infos[i].pid,
            info.infos[i].state,
            info.infos[i].queue_level,
            info.infos[i].remaining_ticks);
    }
    printf("--------------------------\n");
  74:	00001517          	auipc	a0,0x1
  78:	bb450513          	addi	a0,a0,-1100 # c28 <malloc+0x120>
  7c:	1d3000ef          	jal	ra,a4e <printf>
}
  80:	70a2                	ld	ra,40(sp)
  82:	7402                	ld	s0,32(sp)
  84:	64e2                	ld	s1,24(sp)
  86:	6942                	ld	s2,16(sp)
  88:	69a2                	ld	s3,8(sp)
  8a:	6145                	addi	sp,sp,48
  8c:	8082                	ret

000000000000008e <busy_wait>:

void busy_wait(int ticks) {
  8e:	1101                	addi	sp,sp,-32
  90:	ec22                	sd	s0,24(sp)
  92:	1000                	addi	s0,sp,32
    volatile int i =0;
  94:	fe042623          	sw	zero,-20(s0)
    while (i<ticks) {
  98:	fec42783          	lw	a5,-20(s0)
  9c:	2781                	sext.w	a5,a5
  9e:	00a7dc63          	bge	a5,a0,b6 <busy_wait+0x28>
        i++;
  a2:	fec42783          	lw	a5,-20(s0)
  a6:	2785                	addiw	a5,a5,1
  a8:	fef42623          	sw	a5,-20(s0)
    while (i<ticks) {
  ac:	fec42783          	lw	a5,-20(s0)
  b0:	2781                	sext.w	a5,a5
  b2:	fea7c8e3          	blt	a5,a0,a2 <busy_wait+0x14>
    }
}
  b6:	6462                	ld	s0,24(sp)
  b8:	6105                	addi	sp,sp,32
  ba:	8082                	ret

00000000000000bc <cpu_worker>:

void cpu_worker(int id, int duration) {
  bc:	715d                	addi	sp,sp,-80
  be:	e486                	sd	ra,72(sp)
  c0:	e0a2                	sd	s0,64(sp)
  c2:	fc26                	sd	s1,56(sp)
  c4:	f84a                	sd	s2,48(sp)
  c6:	f44e                	sd	s3,40(sp)
  c8:	f052                	sd	s4,32(sp)
  ca:	ec56                	sd	s5,24(sp)
  cc:	e85a                	sd	s6,16(sp)
  ce:	e45e                	sd	s7,8(sp)
  d0:	0880                	addi	s0,sp,80
  d2:	8b2a                	mv	s6,a0
  d4:	84ae                	mv	s1,a1
    int pid = getpid();
  d6:	5d4000ef          	jal	ra,6aa <getpid>
  da:	8aaa                	mv	s5,a0
    int work_units = duration / 100;
  dc:	06400993          	li	s3,100
  e0:	0334ca3b          	divw	s4,s1,s3
  e4:	000a091b          	sext.w	s2,s4
    
    printf("[START] PID %d (CPU Worker %d) started - will do %d work units\n", 
  e8:	86ca                	mv	a3,s2
  ea:	865a                	mv	a2,s6
  ec:	85aa                	mv	a1,a0
  ee:	00001517          	auipc	a0,0x1
  f2:	b5a50513          	addi	a0,a0,-1190 # c48 <malloc+0x140>
  f6:	159000ef          	jal	ra,a4e <printf>
                  pid, id, work_units);
    
    for (int i = 0; i < work_units; i++) {
  fa:	06300793          	li	a5,99
  fe:	0297de63          	bge	a5,s1,13a <cpu_worker+0x7e>
        busy_wait(1000*work_units); 
 102:	3e800993          	li	s3,1000
 106:	034989bb          	mulw	s3,s3,s4
    for (int i = 0; i < work_units; i++) {
 10a:	4481                	li	s1,0
        if (i % 100 == 0) {
 10c:	06400a13          	li	s4,100
            printf("[OBSERVE] PID %d completed %d/%d work units\n", 
 110:	00001b97          	auipc	s7,0x1
 114:	b78b8b93          	addi	s7,s7,-1160 # c88 <malloc+0x180>
 118:	a811                	j	12c <cpu_worker+0x70>
 11a:	86ca                	mv	a3,s2
 11c:	8626                	mv	a2,s1
 11e:	85d6                	mv	a1,s5
 120:	855e                	mv	a0,s7
 122:	12d000ef          	jal	ra,a4e <printf>
    for (int i = 0; i < work_units; i++) {
 126:	2485                	addiw	s1,s1,1
 128:	0124d963          	bge	s1,s2,13a <cpu_worker+0x7e>
        busy_wait(1000*work_units); 
 12c:	854e                	mv	a0,s3
 12e:	f61ff0ef          	jal	ra,8e <busy_wait>
        if (i % 100 == 0) {
 132:	0344e7bb          	remw	a5,s1,s4
 136:	fbe5                	bnez	a5,126 <cpu_worker+0x6a>
 138:	b7cd                	j	11a <cpu_worker+0x5e>
                         pid, i, work_units);
        }
    }
    
    printf("[Finish] PID %d (CPU Worker %d) completed all %d work units\n", 
 13a:	86ca                	mv	a3,s2
 13c:	865a                	mv	a2,s6
 13e:	85d6                	mv	a1,s5
 140:	00001517          	auipc	a0,0x1
 144:	b7850513          	addi	a0,a0,-1160 # cb8 <malloc+0x1b0>
 148:	107000ef          	jal	ra,a4e <printf>
                  pid, id, work_units);
    exit(0);
 14c:	4501                	li	a0,0
 14e:	4dc000ef          	jal	ra,62a <exit>

0000000000000152 <io_worker>:
}

void io_worker(int id, int duration) {
 152:	7179                	addi	sp,sp,-48
 154:	f406                	sd	ra,40(sp)
 156:	f022                	sd	s0,32(sp)
 158:	ec26                	sd	s1,24(sp)
 15a:	e84a                	sd	s2,16(sp)
 15c:	e44e                	sd	s3,8(sp)
 15e:	e052                	sd	s4,0(sp)
 160:	1800                	addi	s0,sp,48
 162:	8a2a                	mv	s4,a0
 164:	84ae                	mv	s1,a1
    int pid = getpid();
 166:	544000ef          	jal	ra,6aa <getpid>
 16a:	89aa                	mv	s3,a0
    int io_operations = duration / 200;
 16c:	0c800913          	li	s2,200
 170:	0324c93b          	divw	s2,s1,s2
    
    printf("[TEST] PID %d (IO Worker %d) started - will do %d IO operations\n", 
 174:	86ca                	mv	a3,s2
 176:	8652                	mv	a2,s4
 178:	85aa                	mv	a1,a0
 17a:	00001517          	auipc	a0,0x1
 17e:	b7e50513          	addi	a0,a0,-1154 # cf8 <malloc+0x1f0>
 182:	0cd000ef          	jal	ra,a4e <printf>
                  pid, id, io_operations);
    
    for (int i = 0; i < io_operations; i++) {
 186:	0c700793          	li	a5,199
 18a:	0097dd63          	bge	a5,s1,1a4 <io_worker+0x52>
 18e:	4481                	li	s1,0
        busy_wait(50);   
 190:	03200513          	li	a0,50
 194:	efbff0ef          	jal	ra,8e <busy_wait>
        //printf("[OBSERVE] PID %d completed CPU operation %d/%d\n", 
        //              pid, i + 1, io_operations);
        pause(1);        
 198:	4505                	li	a0,1
 19a:	520000ef          	jal	ra,6ba <pause>
    for (int i = 0; i < io_operations; i++) {
 19e:	2485                	addiw	s1,s1,1
 1a0:	ff24c8e3          	blt	s1,s2,190 <io_worker+0x3e>
        //printf("[OBSERVE] PID %d completed IO operation %d/%d\n", 
        //              pid, i + 1, io_operations);
    }
    
    printf("[TEST] PID %d (IO Worker %d) completed all %d IO operations\n", 
 1a4:	86ca                	mv	a3,s2
 1a6:	8652                	mv	a2,s4
 1a8:	85ce                	mv	a1,s3
 1aa:	00001517          	auipc	a0,0x1
 1ae:	b9650513          	addi	a0,a0,-1130 # d40 <malloc+0x238>
 1b2:	09d000ef          	jal	ra,a4e <printf>
                  pid, id, io_operations);
    exit(0);
 1b6:	4501                	li	a0,0
 1b8:	472000ef          	jal	ra,62a <exit>

00000000000001bc <mixed_worker>:
}


void mixed_worker(int id, int duration) {
 1bc:	7179                	addi	sp,sp,-48
 1be:	f406                	sd	ra,40(sp)
 1c0:	f022                	sd	s0,32(sp)
 1c2:	ec26                	sd	s1,24(sp)
 1c4:	e84a                	sd	s2,16(sp)
 1c6:	e44e                	sd	s3,8(sp)
 1c8:	e052                	sd	s4,0(sp)
 1ca:	1800                	addi	s0,sp,48
 1cc:	8a2a                	mv	s4,a0
 1ce:	84ae                	mv	s1,a1
    int pid = getpid();
 1d0:	4da000ef          	jal	ra,6aa <getpid>
 1d4:	89aa                	mv	s3,a0
    int cycles = duration / 300;
 1d6:	12c00913          	li	s2,300
 1da:	0324c93b          	divw	s2,s1,s2
    
    printf("[TEST] PID %d (Mixed Worker %d) started - will do %d cycles\n", 
 1de:	86ca                	mv	a3,s2
 1e0:	8652                	mv	a2,s4
 1e2:	85aa                	mv	a1,a0
 1e4:	00001517          	auipc	a0,0x1
 1e8:	b9c50513          	addi	a0,a0,-1124 # d80 <malloc+0x278>
 1ec:	063000ef          	jal	ra,a4e <printf>
                  pid, id, cycles);
    
    for (int i = 0; i < cycles; i++) {
 1f0:	12b00793          	li	a5,299
 1f4:	0297d163          	bge	a5,s1,216 <mixed_worker+0x5a>
 1f8:	4481                	li	s1,0
        busy_wait(150);
 1fa:	09600513          	li	a0,150
 1fe:	e91ff0ef          	jal	ra,8e <busy_wait>
        pause(8);
 202:	4521                	li	a0,8
 204:	4b6000ef          	jal	ra,6ba <pause>
        busy_wait(50);
 208:	03200513          	li	a0,50
 20c:	e83ff0ef          	jal	ra,8e <busy_wait>
    for (int i = 0; i < cycles; i++) {
 210:	2485                	addiw	s1,s1,1
 212:	ff24c4e3          	blt	s1,s2,1fa <mixed_worker+0x3e>
    }
    printf("[TEST] PID %d (Mixed Worker %d) completed all %d cycles\n", 
 216:	86ca                	mv	a3,s2
 218:	8652                	mv	a2,s4
 21a:	85ce                	mv	a1,s3
 21c:	00001517          	auipc	a0,0x1
 220:	ba450513          	addi	a0,a0,-1116 # dc0 <malloc+0x2b8>
 224:	02b000ef          	jal	ra,a4e <printf>
                  pid, id, cycles);
    exit(0);
 228:	4501                	li	a0,0
 22a:	400000ef          	jal	ra,62a <exit>

000000000000022e <main>:
}

int main(int argc, char *argv[]) {
 22e:	7139                	addi	sp,sp,-64
 230:	fc06                	sd	ra,56(sp)
 232:	f822                	sd	s0,48(sp)
 234:	f426                	sd	s1,40(sp)
 236:	f04a                	sd	s2,32(sp)
 238:	ec4e                	sd	s3,24(sp)
 23a:	e852                	sd	s4,16(sp)
 23c:	0080                	addi	s0,sp,64

    
    printf("\n");
 23e:	00001517          	auipc	a0,0x1
 242:	c8a50513          	addi	a0,a0,-886 # ec8 <malloc+0x3c0>
 246:	009000ef          	jal	ra,a4e <printf>
    printf("===============================================\n");
 24a:	00001517          	auipc	a0,0x1
 24e:	bb650513          	addi	a0,a0,-1098 # e00 <malloc+0x2f8>
 252:	7fc000ef          	jal	ra,a4e <printf>
    printf("=        MLFQ Scheduler Test Program         =\n");
 256:	00001517          	auipc	a0,0x1
 25a:	be250513          	addi	a0,a0,-1054 # e38 <malloc+0x330>
 25e:	7f0000ef          	jal	ra,a4e <printf>
    printf("=        Testing SECH under MLFQ            =\n");
 262:	00001517          	auipc	a0,0x1
 266:	c0650513          	addi	a0,a0,-1018 # e68 <malloc+0x360>
 26a:	7e4000ef          	jal	ra,a4e <printf>
    printf("===============================================\n");
 26e:	00001517          	auipc	a0,0x1
 272:	b9250513          	addi	a0,a0,-1134 # e00 <malloc+0x2f8>
 276:	7d8000ef          	jal	ra,a4e <printf>
    printf("===============================================\n\n");
 27a:	00001517          	auipc	a0,0x1
 27e:	c1e50513          	addi	a0,a0,-994 # e98 <malloc+0x390>
 282:	7cc000ef          	jal	ra,a4e <printf>
    
        printf("[TEST] Starting basic MLFQ test with mixed workloads\n");
 286:	00001517          	auipc	a0,0x1
 28a:	c4a50513          	addi	a0,a0,-950 # ed0 <malloc+0x3c8>
 28e:	7c0000ef          	jal	ra,a4e <printf>
        if (fork() == 0) cpu_worker(1, 200000);    
 292:	390000ef          	jal	ra,622 <fork>
 296:	e901                	bnez	a0,2a6 <main+0x78>
 298:	000315b7          	lui	a1,0x31
 29c:	d4058593          	addi	a1,a1,-704 # 30d40 <base+0x2f928>
 2a0:	4505                	li	a0,1
 2a2:	e1bff0ef          	jal	ra,bc <cpu_worker>
        if (fork() == 0) io_worker(1, 20000);      
 2a6:	37c000ef          	jal	ra,622 <fork>
 2aa:	e519                	bnez	a0,2b8 <main+0x8a>
 2ac:	6595                	lui	a1,0x5
 2ae:	e2058593          	addi	a1,a1,-480 # 4e20 <base+0x3a08>
 2b2:	4505                	li	a0,1
 2b4:	e9fff0ef          	jal	ra,152 <io_worker>
        if (fork() == 0) cpu_worker(1, 250000); 
 2b8:	36a000ef          	jal	ra,622 <fork>
 2bc:	e901                	bnez	a0,2cc <main+0x9e>
 2be:	0003d5b7          	lui	a1,0x3d
 2c2:	09058593          	addi	a1,a1,144 # 3d090 <base+0x3bc78>
 2c6:	4505                	li	a0,1
 2c8:	df5ff0ef          	jal	ra,bc <cpu_worker>
        if (fork() == 0) cpu_worker(2, 180000);    
 2cc:	356000ef          	jal	ra,622 <fork>
 2d0:	e901                	bnez	a0,2e0 <main+0xb2>
 2d2:	0002c5b7          	lui	a1,0x2c
 2d6:	f2058593          	addi	a1,a1,-224 # 2bf20 <base+0x2ab08>
 2da:	4509                	li	a0,2
 2dc:	de1ff0ef          	jal	ra,bc <cpu_worker>
        if (fork() == 0) io_worker(2, 22000);     
 2e0:	342000ef          	jal	ra,622 <fork>
 2e4:	e519                	bnez	a0,2f2 <main+0xc4>
 2e6:	6595                	lui	a1,0x5
 2e8:	5f058593          	addi	a1,a1,1520 # 55f0 <base+0x41d8>
 2ec:	4509                	li	a0,2
 2ee:	e65ff0ef          	jal	ra,152 <io_worker>
    int children = 0;
    children = 5;

    
    printf("[TEST] Waiting for %d child processes to complete...\n", children);
 2f2:	4595                	li	a1,5
 2f4:	00001517          	auipc	a0,0x1
 2f8:	c1450513          	addi	a0,a0,-1004 # f08 <malloc+0x400>
 2fc:	752000ef          	jal	ra,a4e <printf>
    print_pinfo_snapshot("Initial snapshot");
 300:	00001517          	auipc	a0,0x1
 304:	c4050513          	addi	a0,a0,-960 # f40 <malloc+0x438>
 308:	cf9ff0ef          	jal	ra,0 <print_pinfo_snapshot>
    int completed = 0;
 30c:	4481                	li	s1,0
    while (completed < children) {
        int status;
        int pid = wait(&status);
        if (pid > 0) {
            printf("[TEST] Child PID %d exited with status %d\n", pid, status);
 30e:	00001a17          	auipc	s4,0x1
 312:	c4aa0a13          	addi	s4,s4,-950 # f58 <malloc+0x450>
            completed++;
            print_pinfo_snapshot("After child exit");
 316:	00001997          	auipc	s3,0x1
 31a:	c7298993          	addi	s3,s3,-910 # f88 <malloc+0x480>
    while (completed < children) {
 31e:	4911                	li	s2,4
 320:	a019                	j	326 <main+0xf8>
 322:	02994363          	blt	s2,s1,348 <main+0x11a>
        int pid = wait(&status);
 326:	fcc40513          	addi	a0,s0,-52
 32a:	308000ef          	jal	ra,632 <wait>
        if (pid > 0) {
 32e:	fea05ae3          	blez	a0,322 <main+0xf4>
            printf("[TEST] Child PID %d exited with status %d\n", pid, status);
 332:	fcc42603          	lw	a2,-52(s0)
 336:	85aa                	mv	a1,a0
 338:	8552                	mv	a0,s4
 33a:	714000ef          	jal	ra,a4e <printf>
            completed++;
 33e:	2485                	addiw	s1,s1,1
            print_pinfo_snapshot("After child exit");
 340:	854e                	mv	a0,s3
 342:	cbfff0ef          	jal	ra,0 <print_pinfo_snapshot>
 346:	bff1                	j	322 <main+0xf4>
        }
    }
    print_pinfo_snapshot("Final snapshot");
 348:	00001517          	auipc	a0,0x1
 34c:	c5850513          	addi	a0,a0,-936 # fa0 <malloc+0x498>
 350:	cb1ff0ef          	jal	ra,0 <print_pinfo_snapshot>
    
    printf("\n");
 354:	00001517          	auipc	a0,0x1
 358:	b7450513          	addi	a0,a0,-1164 # ec8 <malloc+0x3c0>
 35c:	6f2000ef          	jal	ra,a4e <printf>
    printf("===============================================\n");
 360:	00001517          	auipc	a0,0x1
 364:	aa050513          	addi	a0,a0,-1376 # e00 <malloc+0x2f8>
 368:	6e6000ef          	jal	ra,a4e <printf>
    printf("=           Processes completed: %d          =\n", completed);
 36c:	85a6                	mv	a1,s1
 36e:	00001517          	auipc	a0,0x1
 372:	c4250513          	addi	a0,a0,-958 # fb0 <malloc+0x4a8>
 376:	6d8000ef          	jal	ra,a4e <printf>
    printf("===============================================\n\n");
 37a:	00001517          	auipc	a0,0x1
 37e:	b1e50513          	addi	a0,a0,-1250 # e98 <malloc+0x390>
 382:	6cc000ef          	jal	ra,a4e <printf>
    exit(0);
 386:	4501                	li	a0,0
 388:	2a2000ef          	jal	ra,62a <exit>

000000000000038c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e406                	sd	ra,8(sp)
 390:	e022                	sd	s0,0(sp)
 392:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 394:	e9bff0ef          	jal	ra,22e <main>
  exit(r);
 398:	292000ef          	jal	ra,62a <exit>

000000000000039c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3a2:	87aa                	mv	a5,a0
 3a4:	0585                	addi	a1,a1,1
 3a6:	0785                	addi	a5,a5,1
 3a8:	fff5c703          	lbu	a4,-1(a1)
 3ac:	fee78fa3          	sb	a4,-1(a5)
 3b0:	fb75                	bnez	a4,3a4 <strcpy+0x8>
    ;
  return os;
}
 3b2:	6422                	ld	s0,8(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret

00000000000003b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e422                	sd	s0,8(sp)
 3bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3be:	00054783          	lbu	a5,0(a0)
 3c2:	cb91                	beqz	a5,3d6 <strcmp+0x1e>
 3c4:	0005c703          	lbu	a4,0(a1)
 3c8:	00f71763          	bne	a4,a5,3d6 <strcmp+0x1e>
    p++, q++;
 3cc:	0505                	addi	a0,a0,1
 3ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	fbe5                	bnez	a5,3c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3d6:	0005c503          	lbu	a0,0(a1)
}
 3da:	40a7853b          	subw	a0,a5,a0
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret

00000000000003e4 <strlen>:

uint
strlen(const char *s)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e422                	sd	s0,8(sp)
 3e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	cf91                	beqz	a5,40a <strlen+0x26>
 3f0:	0505                	addi	a0,a0,1
 3f2:	87aa                	mv	a5,a0
 3f4:	4685                	li	a3,1
 3f6:	9e89                	subw	a3,a3,a0
 3f8:	00f6853b          	addw	a0,a3,a5
 3fc:	0785                	addi	a5,a5,1
 3fe:	fff7c703          	lbu	a4,-1(a5)
 402:	fb7d                	bnez	a4,3f8 <strlen+0x14>
    ;
  return n;
}
 404:	6422                	ld	s0,8(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret
  for(n = 0; s[n]; n++)
 40a:	4501                	li	a0,0
 40c:	bfe5                	j	404 <strlen+0x20>

000000000000040e <memset>:

void*
memset(void *dst, int c, uint n)
{
 40e:	1141                	addi	sp,sp,-16
 410:	e422                	sd	s0,8(sp)
 412:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 414:	ce09                	beqz	a2,42e <memset+0x20>
 416:	87aa                	mv	a5,a0
 418:	fff6071b          	addiw	a4,a2,-1
 41c:	1702                	slli	a4,a4,0x20
 41e:	9301                	srli	a4,a4,0x20
 420:	0705                	addi	a4,a4,1
 422:	972a                	add	a4,a4,a0
    cdst[i] = c;
 424:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 428:	0785                	addi	a5,a5,1
 42a:	fee79de3          	bne	a5,a4,424 <memset+0x16>
  }
  return dst;
}
 42e:	6422                	ld	s0,8(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret

0000000000000434 <strchr>:

char*
strchr(const char *s, char c)
{
 434:	1141                	addi	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	addi	s0,sp,16
  for(; *s; s++)
 43a:	00054783          	lbu	a5,0(a0)
 43e:	cb99                	beqz	a5,454 <strchr+0x20>
    if(*s == c)
 440:	00f58763          	beq	a1,a5,44e <strchr+0x1a>
  for(; *s; s++)
 444:	0505                	addi	a0,a0,1
 446:	00054783          	lbu	a5,0(a0)
 44a:	fbfd                	bnez	a5,440 <strchr+0xc>
      return (char*)s;
  return 0;
 44c:	4501                	li	a0,0
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
  return 0;
 454:	4501                	li	a0,0
 456:	bfe5                	j	44e <strchr+0x1a>

0000000000000458 <gets>:

char*
gets(char *buf, int max)
{
 458:	711d                	addi	sp,sp,-96
 45a:	ec86                	sd	ra,88(sp)
 45c:	e8a2                	sd	s0,80(sp)
 45e:	e4a6                	sd	s1,72(sp)
 460:	e0ca                	sd	s2,64(sp)
 462:	fc4e                	sd	s3,56(sp)
 464:	f852                	sd	s4,48(sp)
 466:	f456                	sd	s5,40(sp)
 468:	f05a                	sd	s6,32(sp)
 46a:	ec5e                	sd	s7,24(sp)
 46c:	1080                	addi	s0,sp,96
 46e:	8baa                	mv	s7,a0
 470:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 472:	892a                	mv	s2,a0
 474:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 476:	4aa9                	li	s5,10
 478:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 47a:	89a6                	mv	s3,s1
 47c:	2485                	addiw	s1,s1,1
 47e:	0344d663          	bge	s1,s4,4aa <gets+0x52>
    cc = read(0, &c, 1);
 482:	4605                	li	a2,1
 484:	faf40593          	addi	a1,s0,-81
 488:	4501                	li	a0,0
 48a:	1b8000ef          	jal	ra,642 <read>
    if(cc < 1)
 48e:	00a05e63          	blez	a0,4aa <gets+0x52>
    buf[i++] = c;
 492:	faf44783          	lbu	a5,-81(s0)
 496:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 49a:	01578763          	beq	a5,s5,4a8 <gets+0x50>
 49e:	0905                	addi	s2,s2,1
 4a0:	fd679de3          	bne	a5,s6,47a <gets+0x22>
  for(i=0; i+1 < max; ){
 4a4:	89a6                	mv	s3,s1
 4a6:	a011                	j	4aa <gets+0x52>
 4a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4aa:	99de                	add	s3,s3,s7
 4ac:	00098023          	sb	zero,0(s3)
  return buf;
}
 4b0:	855e                	mv	a0,s7
 4b2:	60e6                	ld	ra,88(sp)
 4b4:	6446                	ld	s0,80(sp)
 4b6:	64a6                	ld	s1,72(sp)
 4b8:	6906                	ld	s2,64(sp)
 4ba:	79e2                	ld	s3,56(sp)
 4bc:	7a42                	ld	s4,48(sp)
 4be:	7aa2                	ld	s5,40(sp)
 4c0:	7b02                	ld	s6,32(sp)
 4c2:	6be2                	ld	s7,24(sp)
 4c4:	6125                	addi	sp,sp,96
 4c6:	8082                	ret

00000000000004c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 4c8:	1101                	addi	sp,sp,-32
 4ca:	ec06                	sd	ra,24(sp)
 4cc:	e822                	sd	s0,16(sp)
 4ce:	e426                	sd	s1,8(sp)
 4d0:	e04a                	sd	s2,0(sp)
 4d2:	1000                	addi	s0,sp,32
 4d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d6:	4581                	li	a1,0
 4d8:	192000ef          	jal	ra,66a <open>
  if(fd < 0)
 4dc:	02054163          	bltz	a0,4fe <stat+0x36>
 4e0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4e2:	85ca                	mv	a1,s2
 4e4:	19e000ef          	jal	ra,682 <fstat>
 4e8:	892a                	mv	s2,a0
  close(fd);
 4ea:	8526                	mv	a0,s1
 4ec:	166000ef          	jal	ra,652 <close>
  return r;
}
 4f0:	854a                	mv	a0,s2
 4f2:	60e2                	ld	ra,24(sp)
 4f4:	6442                	ld	s0,16(sp)
 4f6:	64a2                	ld	s1,8(sp)
 4f8:	6902                	ld	s2,0(sp)
 4fa:	6105                	addi	sp,sp,32
 4fc:	8082                	ret
    return -1;
 4fe:	597d                	li	s2,-1
 500:	bfc5                	j	4f0 <stat+0x28>

0000000000000502 <atoi>:

int
atoi(const char *s)
{
 502:	1141                	addi	sp,sp,-16
 504:	e422                	sd	s0,8(sp)
 506:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 508:	00054603          	lbu	a2,0(a0)
 50c:	fd06079b          	addiw	a5,a2,-48
 510:	0ff7f793          	andi	a5,a5,255
 514:	4725                	li	a4,9
 516:	02f76963          	bltu	a4,a5,548 <atoi+0x46>
 51a:	86aa                	mv	a3,a0
  n = 0;
 51c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 51e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 520:	0685                	addi	a3,a3,1
 522:	0025179b          	slliw	a5,a0,0x2
 526:	9fa9                	addw	a5,a5,a0
 528:	0017979b          	slliw	a5,a5,0x1
 52c:	9fb1                	addw	a5,a5,a2
 52e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 532:	0006c603          	lbu	a2,0(a3)
 536:	fd06071b          	addiw	a4,a2,-48
 53a:	0ff77713          	andi	a4,a4,255
 53e:	fee5f1e3          	bgeu	a1,a4,520 <atoi+0x1e>
  return n;
}
 542:	6422                	ld	s0,8(sp)
 544:	0141                	addi	sp,sp,16
 546:	8082                	ret
  n = 0;
 548:	4501                	li	a0,0
 54a:	bfe5                	j	542 <atoi+0x40>

000000000000054c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 54c:	1141                	addi	sp,sp,-16
 54e:	e422                	sd	s0,8(sp)
 550:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 552:	02b57663          	bgeu	a0,a1,57e <memmove+0x32>
    while(n-- > 0)
 556:	02c05163          	blez	a2,578 <memmove+0x2c>
 55a:	fff6079b          	addiw	a5,a2,-1
 55e:	1782                	slli	a5,a5,0x20
 560:	9381                	srli	a5,a5,0x20
 562:	0785                	addi	a5,a5,1
 564:	97aa                	add	a5,a5,a0
  dst = vdst;
 566:	872a                	mv	a4,a0
      *dst++ = *src++;
 568:	0585                	addi	a1,a1,1
 56a:	0705                	addi	a4,a4,1
 56c:	fff5c683          	lbu	a3,-1(a1)
 570:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 574:	fee79ae3          	bne	a5,a4,568 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 578:	6422                	ld	s0,8(sp)
 57a:	0141                	addi	sp,sp,16
 57c:	8082                	ret
    dst += n;
 57e:	00c50733          	add	a4,a0,a2
    src += n;
 582:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 584:	fec05ae3          	blez	a2,578 <memmove+0x2c>
 588:	fff6079b          	addiw	a5,a2,-1
 58c:	1782                	slli	a5,a5,0x20
 58e:	9381                	srli	a5,a5,0x20
 590:	fff7c793          	not	a5,a5
 594:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 596:	15fd                	addi	a1,a1,-1
 598:	177d                	addi	a4,a4,-1
 59a:	0005c683          	lbu	a3,0(a1)
 59e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5a2:	fee79ae3          	bne	a5,a4,596 <memmove+0x4a>
 5a6:	bfc9                	j	578 <memmove+0x2c>

00000000000005a8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5a8:	1141                	addi	sp,sp,-16
 5aa:	e422                	sd	s0,8(sp)
 5ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5ae:	ca05                	beqz	a2,5de <memcmp+0x36>
 5b0:	fff6069b          	addiw	a3,a2,-1
 5b4:	1682                	slli	a3,a3,0x20
 5b6:	9281                	srli	a3,a3,0x20
 5b8:	0685                	addi	a3,a3,1
 5ba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5bc:	00054783          	lbu	a5,0(a0)
 5c0:	0005c703          	lbu	a4,0(a1)
 5c4:	00e79863          	bne	a5,a4,5d4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5c8:	0505                	addi	a0,a0,1
    p2++;
 5ca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5cc:	fed518e3          	bne	a0,a3,5bc <memcmp+0x14>
  }
  return 0;
 5d0:	4501                	li	a0,0
 5d2:	a019                	j	5d8 <memcmp+0x30>
      return *p1 - *p2;
 5d4:	40e7853b          	subw	a0,a5,a4
}
 5d8:	6422                	ld	s0,8(sp)
 5da:	0141                	addi	sp,sp,16
 5dc:	8082                	ret
  return 0;
 5de:	4501                	li	a0,0
 5e0:	bfe5                	j	5d8 <memcmp+0x30>

00000000000005e2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5e2:	1141                	addi	sp,sp,-16
 5e4:	e406                	sd	ra,8(sp)
 5e6:	e022                	sd	s0,0(sp)
 5e8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5ea:	f63ff0ef          	jal	ra,54c <memmove>
}
 5ee:	60a2                	ld	ra,8(sp)
 5f0:	6402                	ld	s0,0(sp)
 5f2:	0141                	addi	sp,sp,16
 5f4:	8082                	ret

00000000000005f6 <sbrk>:

char *
sbrk(int n) {
 5f6:	1141                	addi	sp,sp,-16
 5f8:	e406                	sd	ra,8(sp)
 5fa:	e022                	sd	s0,0(sp)
 5fc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 5fe:	4585                	li	a1,1
 600:	0b2000ef          	jal	ra,6b2 <sys_sbrk>
}
 604:	60a2                	ld	ra,8(sp)
 606:	6402                	ld	s0,0(sp)
 608:	0141                	addi	sp,sp,16
 60a:	8082                	ret

000000000000060c <sbrklazy>:

char *
sbrklazy(int n) {
 60c:	1141                	addi	sp,sp,-16
 60e:	e406                	sd	ra,8(sp)
 610:	e022                	sd	s0,0(sp)
 612:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 614:	4589                	li	a1,2
 616:	09c000ef          	jal	ra,6b2 <sys_sbrk>
}
 61a:	60a2                	ld	ra,8(sp)
 61c:	6402                	ld	s0,0(sp)
 61e:	0141                	addi	sp,sp,16
 620:	8082                	ret

0000000000000622 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 622:	4885                	li	a7,1
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <exit>:
.global exit
exit:
 li a7, SYS_exit
 62a:	4889                	li	a7,2
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <wait>:
.global wait
wait:
 li a7, SYS_wait
 632:	488d                	li	a7,3
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 63a:	4891                	li	a7,4
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <read>:
.global read
read:
 li a7, SYS_read
 642:	4895                	li	a7,5
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <write>:
.global write
write:
 li a7, SYS_write
 64a:	48c1                	li	a7,16
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <close>:
.global close
close:
 li a7, SYS_close
 652:	48d5                	li	a7,21
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <kill>:
.global kill
kill:
 li a7, SYS_kill
 65a:	4899                	li	a7,6
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <exec>:
.global exec
exec:
 li a7, SYS_exec
 662:	489d                	li	a7,7
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <open>:
.global open
open:
 li a7, SYS_open
 66a:	48bd                	li	a7,15
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 672:	48c5                	li	a7,17
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 67a:	48c9                	li	a7,18
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 682:	48a1                	li	a7,8
 ecall
 684:	00000073          	ecall
 ret
 688:	8082                	ret

000000000000068a <link>:
.global link
link:
 li a7, SYS_link
 68a:	48cd                	li	a7,19
 ecall
 68c:	00000073          	ecall
 ret
 690:	8082                	ret

0000000000000692 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 692:	48d1                	li	a7,20
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 69a:	48a5                	li	a7,9
 ecall
 69c:	00000073          	ecall
 ret
 6a0:	8082                	ret

00000000000006a2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6a2:	48a9                	li	a7,10
 ecall
 6a4:	00000073          	ecall
 ret
 6a8:	8082                	ret

00000000000006aa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6aa:	48ad                	li	a7,11
 ecall
 6ac:	00000073          	ecall
 ret
 6b0:	8082                	ret

00000000000006b2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 6b2:	48b1                	li	a7,12
 ecall
 6b4:	00000073          	ecall
 ret
 6b8:	8082                	ret

00000000000006ba <pause>:
.global pause
pause:
 li a7, SYS_pause
 6ba:	48b5                	li	a7,13
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6c2:	48b9                	li	a7,14
 ecall
 6c4:	00000073          	ecall
 ret
 6c8:	8082                	ret

00000000000006ca <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 6ca:	48dd                	li	a7,23
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6d2:	1101                	addi	sp,sp,-32
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	addi	s0,sp,32
 6da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6de:	4605                	li	a2,1
 6e0:	fef40593          	addi	a1,s0,-17
 6e4:	f67ff0ef          	jal	ra,64a <write>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6105                	addi	sp,sp,32
 6ee:	8082                	ret

00000000000006f0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 6f0:	715d                	addi	sp,sp,-80
 6f2:	e486                	sd	ra,72(sp)
 6f4:	e0a2                	sd	s0,64(sp)
 6f6:	fc26                	sd	s1,56(sp)
 6f8:	f84a                	sd	s2,48(sp)
 6fa:	f44e                	sd	s3,40(sp)
 6fc:	0880                	addi	s0,sp,80
 6fe:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 700:	c299                	beqz	a3,706 <printint+0x16>
 702:	0805c163          	bltz	a1,784 <printint+0x94>
  neg = 0;
 706:	4881                	li	a7,0
 708:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 70c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 70e:	00001517          	auipc	a0,0x1
 712:	8da50513          	addi	a0,a0,-1830 # fe8 <digits>
 716:	883e                	mv	a6,a5
 718:	2785                	addiw	a5,a5,1
 71a:	02c5f733          	remu	a4,a1,a2
 71e:	972a                	add	a4,a4,a0
 720:	00074703          	lbu	a4,0(a4)
 724:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 728:	872e                	mv	a4,a1
 72a:	02c5d5b3          	divu	a1,a1,a2
 72e:	0685                	addi	a3,a3,1
 730:	fec773e3          	bgeu	a4,a2,716 <printint+0x26>
  if(neg)
 734:	00088b63          	beqz	a7,74a <printint+0x5a>
    buf[i++] = '-';
 738:	fd040713          	addi	a4,s0,-48
 73c:	97ba                	add	a5,a5,a4
 73e:	02d00713          	li	a4,45
 742:	fee78423          	sb	a4,-24(a5)
 746:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 74a:	02f05663          	blez	a5,776 <printint+0x86>
 74e:	fb840713          	addi	a4,s0,-72
 752:	00f704b3          	add	s1,a4,a5
 756:	fff70993          	addi	s3,a4,-1
 75a:	99be                	add	s3,s3,a5
 75c:	37fd                	addiw	a5,a5,-1
 75e:	1782                	slli	a5,a5,0x20
 760:	9381                	srli	a5,a5,0x20
 762:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 766:	fff4c583          	lbu	a1,-1(s1)
 76a:	854a                	mv	a0,s2
 76c:	f67ff0ef          	jal	ra,6d2 <putc>
  while(--i >= 0)
 770:	14fd                	addi	s1,s1,-1
 772:	ff349ae3          	bne	s1,s3,766 <printint+0x76>
}
 776:	60a6                	ld	ra,72(sp)
 778:	6406                	ld	s0,64(sp)
 77a:	74e2                	ld	s1,56(sp)
 77c:	7942                	ld	s2,48(sp)
 77e:	79a2                	ld	s3,40(sp)
 780:	6161                	addi	sp,sp,80
 782:	8082                	ret
    x = -xx;
 784:	40b005b3          	neg	a1,a1
    neg = 1;
 788:	4885                	li	a7,1
    x = -xx;
 78a:	bfbd                	j	708 <printint+0x18>

000000000000078c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 78c:	7119                	addi	sp,sp,-128
 78e:	fc86                	sd	ra,120(sp)
 790:	f8a2                	sd	s0,112(sp)
 792:	f4a6                	sd	s1,104(sp)
 794:	f0ca                	sd	s2,96(sp)
 796:	ecce                	sd	s3,88(sp)
 798:	e8d2                	sd	s4,80(sp)
 79a:	e4d6                	sd	s5,72(sp)
 79c:	e0da                	sd	s6,64(sp)
 79e:	fc5e                	sd	s7,56(sp)
 7a0:	f862                	sd	s8,48(sp)
 7a2:	f466                	sd	s9,40(sp)
 7a4:	f06a                	sd	s10,32(sp)
 7a6:	ec6e                	sd	s11,24(sp)
 7a8:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7aa:	0005c903          	lbu	s2,0(a1)
 7ae:	24090c63          	beqz	s2,a06 <vprintf+0x27a>
 7b2:	8b2a                	mv	s6,a0
 7b4:	8a2e                	mv	s4,a1
 7b6:	8bb2                	mv	s7,a2
  state = 0;
 7b8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 7ba:	4481                	li	s1,0
 7bc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 7be:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 7c2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 7c6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 7ca:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ce:	00001c97          	auipc	s9,0x1
 7d2:	81ac8c93          	addi	s9,s9,-2022 # fe8 <digits>
 7d6:	a005                	j	7f6 <vprintf+0x6a>
        putc(fd, c0);
 7d8:	85ca                	mv	a1,s2
 7da:	855a                	mv	a0,s6
 7dc:	ef7ff0ef          	jal	ra,6d2 <putc>
 7e0:	a019                	j	7e6 <vprintf+0x5a>
    } else if(state == '%'){
 7e2:	03598263          	beq	s3,s5,806 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7e6:	2485                	addiw	s1,s1,1
 7e8:	8726                	mv	a4,s1
 7ea:	009a07b3          	add	a5,s4,s1
 7ee:	0007c903          	lbu	s2,0(a5)
 7f2:	20090a63          	beqz	s2,a06 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 7f6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7fa:	fe0994e3          	bnez	s3,7e2 <vprintf+0x56>
      if(c0 == '%'){
 7fe:	fd579de3          	bne	a5,s5,7d8 <vprintf+0x4c>
        state = '%';
 802:	89be                	mv	s3,a5
 804:	b7cd                	j	7e6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 806:	c3c1                	beqz	a5,886 <vprintf+0xfa>
 808:	00ea06b3          	add	a3,s4,a4
 80c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 810:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 812:	c681                	beqz	a3,81a <vprintf+0x8e>
 814:	9752                	add	a4,a4,s4
 816:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 81a:	03878e63          	beq	a5,s8,856 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 81e:	05a78863          	beq	a5,s10,86e <vprintf+0xe2>
      } else if(c0 == 'u'){
 822:	0db78b63          	beq	a5,s11,8f8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 826:	07800713          	li	a4,120
 82a:	10e78d63          	beq	a5,a4,944 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 82e:	07000713          	li	a4,112
 832:	14e78263          	beq	a5,a4,976 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 836:	06300713          	li	a4,99
 83a:	16e78f63          	beq	a5,a4,9b8 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 83e:	07300713          	li	a4,115
 842:	18e78563          	beq	a5,a4,9cc <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 846:	05579063          	bne	a5,s5,886 <vprintf+0xfa>
        putc(fd, '%');
 84a:	85d6                	mv	a1,s5
 84c:	855a                	mv	a0,s6
 84e:	e85ff0ef          	jal	ra,6d2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 852:	4981                	li	s3,0
 854:	bf49                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 856:	008b8913          	addi	s2,s7,8
 85a:	4685                	li	a3,1
 85c:	4629                	li	a2,10
 85e:	000ba583          	lw	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	e8dff0ef          	jal	ra,6f0 <printint>
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bfad                	j	7e6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 86e:	03868663          	beq	a3,s8,89a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 872:	05a68163          	beq	a3,s10,8b4 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 876:	09b68d63          	beq	a3,s11,910 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 87a:	03a68f63          	beq	a3,s10,8b8 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 87e:	07800793          	li	a5,120
 882:	0cf68d63          	beq	a3,a5,95c <vprintf+0x1d0>
        putc(fd, '%');
 886:	85d6                	mv	a1,s5
 888:	855a                	mv	a0,s6
 88a:	e49ff0ef          	jal	ra,6d2 <putc>
        putc(fd, c0);
 88e:	85ca                	mv	a1,s2
 890:	855a                	mv	a0,s6
 892:	e41ff0ef          	jal	ra,6d2 <putc>
      state = 0;
 896:	4981                	li	s3,0
 898:	b7b9                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 89a:	008b8913          	addi	s2,s7,8
 89e:	4685                	li	a3,1
 8a0:	4629                	li	a2,10
 8a2:	000bb583          	ld	a1,0(s7)
 8a6:	855a                	mv	a0,s6
 8a8:	e49ff0ef          	jal	ra,6f0 <printint>
        i += 1;
 8ac:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ae:	8bca                	mv	s7,s2
      state = 0;
 8b0:	4981                	li	s3,0
        i += 1;
 8b2:	bf15                	j	7e6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8b4:	03860563          	beq	a2,s8,8de <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8b8:	07b60963          	beq	a2,s11,92a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8bc:	07800793          	li	a5,120
 8c0:	fcf613e3          	bne	a2,a5,886 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8c4:	008b8913          	addi	s2,s7,8
 8c8:	4681                	li	a3,0
 8ca:	4641                	li	a2,16
 8cc:	000bb583          	ld	a1,0(s7)
 8d0:	855a                	mv	a0,s6
 8d2:	e1fff0ef          	jal	ra,6f0 <printint>
        i += 2;
 8d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 8d8:	8bca                	mv	s7,s2
      state = 0;
 8da:	4981                	li	s3,0
        i += 2;
 8dc:	b729                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8de:	008b8913          	addi	s2,s7,8
 8e2:	4685                	li	a3,1
 8e4:	4629                	li	a2,10
 8e6:	000bb583          	ld	a1,0(s7)
 8ea:	855a                	mv	a0,s6
 8ec:	e05ff0ef          	jal	ra,6f0 <printint>
        i += 2;
 8f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8f2:	8bca                	mv	s7,s2
      state = 0;
 8f4:	4981                	li	s3,0
        i += 2;
 8f6:	bdc5                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8f8:	008b8913          	addi	s2,s7,8
 8fc:	4681                	li	a3,0
 8fe:	4629                	li	a2,10
 900:	000be583          	lwu	a1,0(s7)
 904:	855a                	mv	a0,s6
 906:	debff0ef          	jal	ra,6f0 <printint>
 90a:	8bca                	mv	s7,s2
      state = 0;
 90c:	4981                	li	s3,0
 90e:	bde1                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 910:	008b8913          	addi	s2,s7,8
 914:	4681                	li	a3,0
 916:	4629                	li	a2,10
 918:	000bb583          	ld	a1,0(s7)
 91c:	855a                	mv	a0,s6
 91e:	dd3ff0ef          	jal	ra,6f0 <printint>
        i += 1;
 922:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 924:	8bca                	mv	s7,s2
      state = 0;
 926:	4981                	li	s3,0
        i += 1;
 928:	bd7d                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 92a:	008b8913          	addi	s2,s7,8
 92e:	4681                	li	a3,0
 930:	4629                	li	a2,10
 932:	000bb583          	ld	a1,0(s7)
 936:	855a                	mv	a0,s6
 938:	db9ff0ef          	jal	ra,6f0 <printint>
        i += 2;
 93c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 93e:	8bca                	mv	s7,s2
      state = 0;
 940:	4981                	li	s3,0
        i += 2;
 942:	b555                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 944:	008b8913          	addi	s2,s7,8
 948:	4681                	li	a3,0
 94a:	4641                	li	a2,16
 94c:	000be583          	lwu	a1,0(s7)
 950:	855a                	mv	a0,s6
 952:	d9fff0ef          	jal	ra,6f0 <printint>
 956:	8bca                	mv	s7,s2
      state = 0;
 958:	4981                	li	s3,0
 95a:	b571                	j	7e6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 95c:	008b8913          	addi	s2,s7,8
 960:	4681                	li	a3,0
 962:	4641                	li	a2,16
 964:	000bb583          	ld	a1,0(s7)
 968:	855a                	mv	a0,s6
 96a:	d87ff0ef          	jal	ra,6f0 <printint>
        i += 1;
 96e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 970:	8bca                	mv	s7,s2
      state = 0;
 972:	4981                	li	s3,0
        i += 1;
 974:	bd8d                	j	7e6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 976:	008b8793          	addi	a5,s7,8
 97a:	f8f43423          	sd	a5,-120(s0)
 97e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 982:	03000593          	li	a1,48
 986:	855a                	mv	a0,s6
 988:	d4bff0ef          	jal	ra,6d2 <putc>
  putc(fd, 'x');
 98c:	07800593          	li	a1,120
 990:	855a                	mv	a0,s6
 992:	d41ff0ef          	jal	ra,6d2 <putc>
 996:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 998:	03c9d793          	srli	a5,s3,0x3c
 99c:	97e6                	add	a5,a5,s9
 99e:	0007c583          	lbu	a1,0(a5)
 9a2:	855a                	mv	a0,s6
 9a4:	d2fff0ef          	jal	ra,6d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9a8:	0992                	slli	s3,s3,0x4
 9aa:	397d                	addiw	s2,s2,-1
 9ac:	fe0916e3          	bnez	s2,998 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 9b0:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	bd05                	j	7e6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 9b8:	008b8913          	addi	s2,s7,8
 9bc:	000bc583          	lbu	a1,0(s7)
 9c0:	855a                	mv	a0,s6
 9c2:	d11ff0ef          	jal	ra,6d2 <putc>
 9c6:	8bca                	mv	s7,s2
      state = 0;
 9c8:	4981                	li	s3,0
 9ca:	bd31                	j	7e6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 9cc:	008b8993          	addi	s3,s7,8
 9d0:	000bb903          	ld	s2,0(s7)
 9d4:	00090f63          	beqz	s2,9f2 <vprintf+0x266>
        for(; *s; s++)
 9d8:	00094583          	lbu	a1,0(s2)
 9dc:	c195                	beqz	a1,a00 <vprintf+0x274>
          putc(fd, *s);
 9de:	855a                	mv	a0,s6
 9e0:	cf3ff0ef          	jal	ra,6d2 <putc>
        for(; *s; s++)
 9e4:	0905                	addi	s2,s2,1
 9e6:	00094583          	lbu	a1,0(s2)
 9ea:	f9f5                	bnez	a1,9de <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 9ec:	8bce                	mv	s7,s3
      state = 0;
 9ee:	4981                	li	s3,0
 9f0:	bbdd                	j	7e6 <vprintf+0x5a>
          s = "(null)";
 9f2:	00000917          	auipc	s2,0x0
 9f6:	5ee90913          	addi	s2,s2,1518 # fe0 <malloc+0x4d8>
        for(; *s; s++)
 9fa:	02800593          	li	a1,40
 9fe:	b7c5                	j	9de <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 a00:	8bce                	mv	s7,s3
      state = 0;
 a02:	4981                	li	s3,0
 a04:	b3cd                	j	7e6 <vprintf+0x5a>
    }
  }
}
 a06:	70e6                	ld	ra,120(sp)
 a08:	7446                	ld	s0,112(sp)
 a0a:	74a6                	ld	s1,104(sp)
 a0c:	7906                	ld	s2,96(sp)
 a0e:	69e6                	ld	s3,88(sp)
 a10:	6a46                	ld	s4,80(sp)
 a12:	6aa6                	ld	s5,72(sp)
 a14:	6b06                	ld	s6,64(sp)
 a16:	7be2                	ld	s7,56(sp)
 a18:	7c42                	ld	s8,48(sp)
 a1a:	7ca2                	ld	s9,40(sp)
 a1c:	7d02                	ld	s10,32(sp)
 a1e:	6de2                	ld	s11,24(sp)
 a20:	6109                	addi	sp,sp,128
 a22:	8082                	ret

0000000000000a24 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a24:	715d                	addi	sp,sp,-80
 a26:	ec06                	sd	ra,24(sp)
 a28:	e822                	sd	s0,16(sp)
 a2a:	1000                	addi	s0,sp,32
 a2c:	e010                	sd	a2,0(s0)
 a2e:	e414                	sd	a3,8(s0)
 a30:	e818                	sd	a4,16(s0)
 a32:	ec1c                	sd	a5,24(s0)
 a34:	03043023          	sd	a6,32(s0)
 a38:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a3c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a40:	8622                	mv	a2,s0
 a42:	d4bff0ef          	jal	ra,78c <vprintf>
}
 a46:	60e2                	ld	ra,24(sp)
 a48:	6442                	ld	s0,16(sp)
 a4a:	6161                	addi	sp,sp,80
 a4c:	8082                	ret

0000000000000a4e <printf>:

void
printf(const char *fmt, ...)
{
 a4e:	711d                	addi	sp,sp,-96
 a50:	ec06                	sd	ra,24(sp)
 a52:	e822                	sd	s0,16(sp)
 a54:	1000                	addi	s0,sp,32
 a56:	e40c                	sd	a1,8(s0)
 a58:	e810                	sd	a2,16(s0)
 a5a:	ec14                	sd	a3,24(s0)
 a5c:	f018                	sd	a4,32(s0)
 a5e:	f41c                	sd	a5,40(s0)
 a60:	03043823          	sd	a6,48(s0)
 a64:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a68:	00840613          	addi	a2,s0,8
 a6c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a70:	85aa                	mv	a1,a0
 a72:	4505                	li	a0,1
 a74:	d19ff0ef          	jal	ra,78c <vprintf>
}
 a78:	60e2                	ld	ra,24(sp)
 a7a:	6442                	ld	s0,16(sp)
 a7c:	6125                	addi	sp,sp,96
 a7e:	8082                	ret

0000000000000a80 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a80:	1141                	addi	sp,sp,-16
 a82:	e422                	sd	s0,8(sp)
 a84:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a86:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a8a:	00000797          	auipc	a5,0x0
 a8e:	5767b783          	ld	a5,1398(a5) # 1000 <freep>
 a92:	a805                	j	ac2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a94:	4618                	lw	a4,8(a2)
 a96:	9db9                	addw	a1,a1,a4
 a98:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a9c:	6398                	ld	a4,0(a5)
 a9e:	6318                	ld	a4,0(a4)
 aa0:	fee53823          	sd	a4,-16(a0)
 aa4:	a091                	j	ae8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 aa6:	ff852703          	lw	a4,-8(a0)
 aaa:	9e39                	addw	a2,a2,a4
 aac:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 aae:	ff053703          	ld	a4,-16(a0)
 ab2:	e398                	sd	a4,0(a5)
 ab4:	a099                	j	afa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ab6:	6398                	ld	a4,0(a5)
 ab8:	00e7e463          	bltu	a5,a4,ac0 <free+0x40>
 abc:	00e6ea63          	bltu	a3,a4,ad0 <free+0x50>
{
 ac0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac2:	fed7fae3          	bgeu	a5,a3,ab6 <free+0x36>
 ac6:	6398                	ld	a4,0(a5)
 ac8:	00e6e463          	bltu	a3,a4,ad0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 acc:	fee7eae3          	bltu	a5,a4,ac0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ad0:	ff852583          	lw	a1,-8(a0)
 ad4:	6390                	ld	a2,0(a5)
 ad6:	02059713          	slli	a4,a1,0x20
 ada:	9301                	srli	a4,a4,0x20
 adc:	0712                	slli	a4,a4,0x4
 ade:	9736                	add	a4,a4,a3
 ae0:	fae60ae3          	beq	a2,a4,a94 <free+0x14>
    bp->s.ptr = p->s.ptr;
 ae4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ae8:	4790                	lw	a2,8(a5)
 aea:	02061713          	slli	a4,a2,0x20
 aee:	9301                	srli	a4,a4,0x20
 af0:	0712                	slli	a4,a4,0x4
 af2:	973e                	add	a4,a4,a5
 af4:	fae689e3          	beq	a3,a4,aa6 <free+0x26>
  } else
    p->s.ptr = bp;
 af8:	e394                	sd	a3,0(a5)
  freep = p;
 afa:	00000717          	auipc	a4,0x0
 afe:	50f73323          	sd	a5,1286(a4) # 1000 <freep>
}
 b02:	6422                	ld	s0,8(sp)
 b04:	0141                	addi	sp,sp,16
 b06:	8082                	ret

0000000000000b08 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b08:	7139                	addi	sp,sp,-64
 b0a:	fc06                	sd	ra,56(sp)
 b0c:	f822                	sd	s0,48(sp)
 b0e:	f426                	sd	s1,40(sp)
 b10:	f04a                	sd	s2,32(sp)
 b12:	ec4e                	sd	s3,24(sp)
 b14:	e852                	sd	s4,16(sp)
 b16:	e456                	sd	s5,8(sp)
 b18:	e05a                	sd	s6,0(sp)
 b1a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b1c:	02051493          	slli	s1,a0,0x20
 b20:	9081                	srli	s1,s1,0x20
 b22:	04bd                	addi	s1,s1,15
 b24:	8091                	srli	s1,s1,0x4
 b26:	0014899b          	addiw	s3,s1,1
 b2a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b2c:	00000517          	auipc	a0,0x0
 b30:	4d453503          	ld	a0,1236(a0) # 1000 <freep>
 b34:	c515                	beqz	a0,b60 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b36:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b38:	4798                	lw	a4,8(a5)
 b3a:	02977f63          	bgeu	a4,s1,b78 <malloc+0x70>
 b3e:	8a4e                	mv	s4,s3
 b40:	0009871b          	sext.w	a4,s3
 b44:	6685                	lui	a3,0x1
 b46:	00d77363          	bgeu	a4,a3,b4c <malloc+0x44>
 b4a:	6a05                	lui	s4,0x1
 b4c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b50:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b54:	00000917          	auipc	s2,0x0
 b58:	4ac90913          	addi	s2,s2,1196 # 1000 <freep>
  if(p == SBRK_ERROR)
 b5c:	5afd                	li	s5,-1
 b5e:	a0bd                	j	bcc <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 b60:	00001797          	auipc	a5,0x1
 b64:	8b878793          	addi	a5,a5,-1864 # 1418 <base>
 b68:	00000717          	auipc	a4,0x0
 b6c:	48f73c23          	sd	a5,1176(a4) # 1000 <freep>
 b70:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b72:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b76:	b7e1                	j	b3e <malloc+0x36>
      if(p->s.size == nunits)
 b78:	02e48b63          	beq	s1,a4,bae <malloc+0xa6>
        p->s.size -= nunits;
 b7c:	4137073b          	subw	a4,a4,s3
 b80:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b82:	1702                	slli	a4,a4,0x20
 b84:	9301                	srli	a4,a4,0x20
 b86:	0712                	slli	a4,a4,0x4
 b88:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b8a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b8e:	00000717          	auipc	a4,0x0
 b92:	46a73923          	sd	a0,1138(a4) # 1000 <freep>
      return (void*)(p + 1);
 b96:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b9a:	70e2                	ld	ra,56(sp)
 b9c:	7442                	ld	s0,48(sp)
 b9e:	74a2                	ld	s1,40(sp)
 ba0:	7902                	ld	s2,32(sp)
 ba2:	69e2                	ld	s3,24(sp)
 ba4:	6a42                	ld	s4,16(sp)
 ba6:	6aa2                	ld	s5,8(sp)
 ba8:	6b02                	ld	s6,0(sp)
 baa:	6121                	addi	sp,sp,64
 bac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bae:	6398                	ld	a4,0(a5)
 bb0:	e118                	sd	a4,0(a0)
 bb2:	bff1                	j	b8e <malloc+0x86>
  hp->s.size = nu;
 bb4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bb8:	0541                	addi	a0,a0,16
 bba:	ec7ff0ef          	jal	ra,a80 <free>
  return freep;
 bbe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bc2:	dd61                	beqz	a0,b9a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bc4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc6:	4798                	lw	a4,8(a5)
 bc8:	fa9778e3          	bgeu	a4,s1,b78 <malloc+0x70>
    if(p == freep)
 bcc:	00093703          	ld	a4,0(s2)
 bd0:	853e                	mv	a0,a5
 bd2:	fef719e3          	bne	a4,a5,bc4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 bd6:	8552                	mv	a0,s4
 bd8:	a1fff0ef          	jal	ra,5f6 <sbrk>
  if(p == SBRK_ERROR)
 bdc:	fd551ce3          	bne	a0,s5,bb4 <malloc+0xac>
        return 0;
 be0:	4501                	li	a0,0
 be2:	bf65                	j	b9a <malloc+0x92>
