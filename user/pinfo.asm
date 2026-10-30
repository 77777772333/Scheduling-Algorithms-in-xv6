
user/_pinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/stat.h"

int
main(void)
{
   0:	bc010113          	addi	sp,sp,-1088
   4:	42113c23          	sd	ra,1080(sp)
   8:	42813823          	sd	s0,1072(sp)
   c:	42913423          	sd	s1,1064(sp)
  10:	43213023          	sd	s2,1056(sp)
  14:	41313c23          	sd	s3,1048(sp)
  18:	44010413          	addi	s0,sp,1088
  struct pinfo_all info;
  int n = getpinfo(&info);
  1c:	bc840513          	addi	a0,s0,-1080
  20:	38a000ef          	jal	ra,3aa <getpinfo>
  24:	892a                	mv	s2,a0
  printf("PID\tSTATE\tQ\tREMAIN\n");
  26:	00001517          	auipc	a0,0x1
  2a:	8aa50513          	addi	a0,a0,-1878 # 8d0 <malloc+0xe8>
  2e:	700000ef          	jal	ra,72e <printf>
  for (int i = 0; i < n; i++) {
  32:	03205a63          	blez	s2,66 <main+0x66>
  36:	bcc40493          	addi	s1,s0,-1076
  3a:	397d                	addiw	s2,s2,-1
  3c:	1902                	slli	s2,s2,0x20
  3e:	02095913          	srli	s2,s2,0x20
  42:	0912                	slli	s2,s2,0x4
  44:	bdc40793          	addi	a5,s0,-1060
  48:	993e                	add	s2,s2,a5
    printf("%d\t%d\t%d\t%d\n",
  4a:	00001997          	auipc	s3,0x1
  4e:	89e98993          	addi	s3,s3,-1890 # 8e8 <malloc+0x100>
  52:	44d8                	lw	a4,12(s1)
  54:	4494                	lw	a3,8(s1)
  56:	40d0                	lw	a2,4(s1)
  58:	408c                	lw	a1,0(s1)
  5a:	854e                	mv	a0,s3
  5c:	6d2000ef          	jal	ra,72e <printf>
  for (int i = 0; i < n; i++) {
  60:	04c1                	addi	s1,s1,16
  62:	ff2498e3          	bne	s1,s2,52 <main+0x52>
      info.infos[i].pid,
      info.infos[i].state,
      info.infos[i].queue_level,
      info.infos[i].remaining_ticks);
  }
  exit(0);
  66:	4501                	li	a0,0
  68:	2a2000ef          	jal	ra,30a <exit>

000000000000006c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  6c:	1141                	addi	sp,sp,-16
  6e:	e406                	sd	ra,8(sp)
  70:	e022                	sd	s0,0(sp)
  72:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  74:	f8dff0ef          	jal	ra,0 <main>
  exit(r);
  78:	292000ef          	jal	ra,30a <exit>

000000000000007c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  82:	87aa                	mv	a5,a0
  84:	0585                	addi	a1,a1,1
  86:	0785                	addi	a5,a5,1
  88:	fff5c703          	lbu	a4,-1(a1)
  8c:	fee78fa3          	sb	a4,-1(a5)
  90:	fb75                	bnez	a4,84 <strcpy+0x8>
    ;
  return os;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9e:	00054783          	lbu	a5,0(a0)
  a2:	cb91                	beqz	a5,b6 <strcmp+0x1e>
  a4:	0005c703          	lbu	a4,0(a1)
  a8:	00f71763          	bne	a4,a5,b6 <strcmp+0x1e>
    p++, q++;
  ac:	0505                	addi	a0,a0,1
  ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	fbe5                	bnez	a5,a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b6:	0005c503          	lbu	a0,0(a1)
}
  ba:	40a7853b          	subw	a0,a5,a0
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strlen>:

uint
strlen(const char *s)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cf91                	beqz	a5,ea <strlen+0x26>
  d0:	0505                	addi	a0,a0,1
  d2:	87aa                	mv	a5,a0
  d4:	4685                	li	a3,1
  d6:	9e89                	subw	a3,a3,a0
  d8:	00f6853b          	addw	a0,a3,a5
  dc:	0785                	addi	a5,a5,1
  de:	fff7c703          	lbu	a4,-1(a5)
  e2:	fb7d                	bnez	a4,d8 <strlen+0x14>
    ;
  return n;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret
  for(n = 0; s[n]; n++)
  ea:	4501                	li	a0,0
  ec:	bfe5                	j	e4 <strlen+0x20>

00000000000000ee <memset>:

void*
memset(void *dst, int c, uint n)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f4:	ce09                	beqz	a2,10e <memset+0x20>
  f6:	87aa                	mv	a5,a0
  f8:	fff6071b          	addiw	a4,a2,-1
  fc:	1702                	slli	a4,a4,0x20
  fe:	9301                	srli	a4,a4,0x20
 100:	0705                	addi	a4,a4,1
 102:	972a                	add	a4,a4,a0
    cdst[i] = c;
 104:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 108:	0785                	addi	a5,a5,1
 10a:	fee79de3          	bne	a5,a4,104 <memset+0x16>
  }
  return dst;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strchr>:

char*
strchr(const char *s, char c)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb99                	beqz	a5,134 <strchr+0x20>
    if(*s == c)
 120:	00f58763          	beq	a1,a5,12e <strchr+0x1a>
  for(; *s; s++)
 124:	0505                	addi	a0,a0,1
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbfd                	bnez	a5,120 <strchr+0xc>
      return (char*)s;
  return 0;
 12c:	4501                	li	a0,0
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret
  return 0;
 134:	4501                	li	a0,0
 136:	bfe5                	j	12e <strchr+0x1a>

0000000000000138 <gets>:

char*
gets(char *buf, int max)
{
 138:	711d                	addi	sp,sp,-96
 13a:	ec86                	sd	ra,88(sp)
 13c:	e8a2                	sd	s0,80(sp)
 13e:	e4a6                	sd	s1,72(sp)
 140:	e0ca                	sd	s2,64(sp)
 142:	fc4e                	sd	s3,56(sp)
 144:	f852                	sd	s4,48(sp)
 146:	f456                	sd	s5,40(sp)
 148:	f05a                	sd	s6,32(sp)
 14a:	ec5e                	sd	s7,24(sp)
 14c:	1080                	addi	s0,sp,96
 14e:	8baa                	mv	s7,a0
 150:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 152:	892a                	mv	s2,a0
 154:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 156:	4aa9                	li	s5,10
 158:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15a:	89a6                	mv	s3,s1
 15c:	2485                	addiw	s1,s1,1
 15e:	0344d663          	bge	s1,s4,18a <gets+0x52>
    cc = read(0, &c, 1);
 162:	4605                	li	a2,1
 164:	faf40593          	addi	a1,s0,-81
 168:	4501                	li	a0,0
 16a:	1b8000ef          	jal	ra,322 <read>
    if(cc < 1)
 16e:	00a05e63          	blez	a0,18a <gets+0x52>
    buf[i++] = c;
 172:	faf44783          	lbu	a5,-81(s0)
 176:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17a:	01578763          	beq	a5,s5,188 <gets+0x50>
 17e:	0905                	addi	s2,s2,1
 180:	fd679de3          	bne	a5,s6,15a <gets+0x22>
  for(i=0; i+1 < max; ){
 184:	89a6                	mv	s3,s1
 186:	a011                	j	18a <gets+0x52>
 188:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18a:	99de                	add	s3,s3,s7
 18c:	00098023          	sb	zero,0(s3)
  return buf;
}
 190:	855e                	mv	a0,s7
 192:	60e6                	ld	ra,88(sp)
 194:	6446                	ld	s0,80(sp)
 196:	64a6                	ld	s1,72(sp)
 198:	6906                	ld	s2,64(sp)
 19a:	79e2                	ld	s3,56(sp)
 19c:	7a42                	ld	s4,48(sp)
 19e:	7aa2                	ld	s5,40(sp)
 1a0:	7b02                	ld	s6,32(sp)
 1a2:	6be2                	ld	s7,24(sp)
 1a4:	6125                	addi	sp,sp,96
 1a6:	8082                	ret

00000000000001a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a8:	1101                	addi	sp,sp,-32
 1aa:	ec06                	sd	ra,24(sp)
 1ac:	e822                	sd	s0,16(sp)
 1ae:	e426                	sd	s1,8(sp)
 1b0:	e04a                	sd	s2,0(sp)
 1b2:	1000                	addi	s0,sp,32
 1b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b6:	4581                	li	a1,0
 1b8:	192000ef          	jal	ra,34a <open>
  if(fd < 0)
 1bc:	02054163          	bltz	a0,1de <stat+0x36>
 1c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c2:	85ca                	mv	a1,s2
 1c4:	19e000ef          	jal	ra,362 <fstat>
 1c8:	892a                	mv	s2,a0
  close(fd);
 1ca:	8526                	mv	a0,s1
 1cc:	166000ef          	jal	ra,332 <close>
  return r;
}
 1d0:	854a                	mv	a0,s2
 1d2:	60e2                	ld	ra,24(sp)
 1d4:	6442                	ld	s0,16(sp)
 1d6:	64a2                	ld	s1,8(sp)
 1d8:	6902                	ld	s2,0(sp)
 1da:	6105                	addi	sp,sp,32
 1dc:	8082                	ret
    return -1;
 1de:	597d                	li	s2,-1
 1e0:	bfc5                	j	1d0 <stat+0x28>

00000000000001e2 <atoi>:

int
atoi(const char *s)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e8:	00054603          	lbu	a2,0(a0)
 1ec:	fd06079b          	addiw	a5,a2,-48
 1f0:	0ff7f793          	andi	a5,a5,255
 1f4:	4725                	li	a4,9
 1f6:	02f76963          	bltu	a4,a5,228 <atoi+0x46>
 1fa:	86aa                	mv	a3,a0
  n = 0;
 1fc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1fe:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 200:	0685                	addi	a3,a3,1
 202:	0025179b          	slliw	a5,a0,0x2
 206:	9fa9                	addw	a5,a5,a0
 208:	0017979b          	slliw	a5,a5,0x1
 20c:	9fb1                	addw	a5,a5,a2
 20e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 212:	0006c603          	lbu	a2,0(a3)
 216:	fd06071b          	addiw	a4,a2,-48
 21a:	0ff77713          	andi	a4,a4,255
 21e:	fee5f1e3          	bgeu	a1,a4,200 <atoi+0x1e>
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  n = 0;
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <atoi+0x40>

000000000000022c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 232:	02b57663          	bgeu	a0,a1,25e <memmove+0x32>
    while(n-- > 0)
 236:	02c05163          	blez	a2,258 <memmove+0x2c>
 23a:	fff6079b          	addiw	a5,a2,-1
 23e:	1782                	slli	a5,a5,0x20
 240:	9381                	srli	a5,a5,0x20
 242:	0785                	addi	a5,a5,1
 244:	97aa                	add	a5,a5,a0
  dst = vdst;
 246:	872a                	mv	a4,a0
      *dst++ = *src++;
 248:	0585                	addi	a1,a1,1
 24a:	0705                	addi	a4,a4,1
 24c:	fff5c683          	lbu	a3,-1(a1)
 250:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 254:	fee79ae3          	bne	a5,a4,248 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
    dst += n;
 25e:	00c50733          	add	a4,a0,a2
    src += n;
 262:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 264:	fec05ae3          	blez	a2,258 <memmove+0x2c>
 268:	fff6079b          	addiw	a5,a2,-1
 26c:	1782                	slli	a5,a5,0x20
 26e:	9381                	srli	a5,a5,0x20
 270:	fff7c793          	not	a5,a5
 274:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 276:	15fd                	addi	a1,a1,-1
 278:	177d                	addi	a4,a4,-1
 27a:	0005c683          	lbu	a3,0(a1)
 27e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x4a>
 286:	bfc9                	j	258 <memmove+0x2c>

0000000000000288 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28e:	ca05                	beqz	a2,2be <memcmp+0x36>
 290:	fff6069b          	addiw	a3,a2,-1
 294:	1682                	slli	a3,a3,0x20
 296:	9281                	srli	a3,a3,0x20
 298:	0685                	addi	a3,a3,1
 29a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00e79863          	bne	a5,a4,2b4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a8:	0505                	addi	a0,a0,1
    p2++;
 2aa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ac:	fed518e3          	bne	a0,a3,29c <memcmp+0x14>
  }
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	a019                	j	2b8 <memcmp+0x30>
      return *p1 - *p2;
 2b4:	40e7853b          	subw	a0,a5,a4
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
  return 0;
 2be:	4501                	li	a0,0
 2c0:	bfe5                	j	2b8 <memcmp+0x30>

00000000000002c2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e406                	sd	ra,8(sp)
 2c6:	e022                	sd	s0,0(sp)
 2c8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ca:	f63ff0ef          	jal	ra,22c <memmove>
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <sbrk>:

char *
sbrk(int n) {
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2de:	4585                	li	a1,1
 2e0:	0b2000ef          	jal	ra,392 <sys_sbrk>
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <sbrklazy>:

char *
sbrklazy(int n) {
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e406                	sd	ra,8(sp)
 2f0:	e022                	sd	s0,0(sp)
 2f2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f4:	4589                	li	a1,2
 2f6:	09c000ef          	jal	ra,392 <sys_sbrk>
}
 2fa:	60a2                	ld	ra,8(sp)
 2fc:	6402                	ld	s0,0(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret

0000000000000302 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 302:	4885                	li	a7,1
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <exit>:
.global exit
exit:
 li a7, SYS_exit
 30a:	4889                	li	a7,2
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <wait>:
.global wait
wait:
 li a7, SYS_wait
 312:	488d                	li	a7,3
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31a:	4891                	li	a7,4
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <read>:
.global read
read:
 li a7, SYS_read
 322:	4895                	li	a7,5
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <write>:
.global write
write:
 li a7, SYS_write
 32a:	48c1                	li	a7,16
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <close>:
.global close
close:
 li a7, SYS_close
 332:	48d5                	li	a7,21
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <kill>:
.global kill
kill:
 li a7, SYS_kill
 33a:	4899                	li	a7,6
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <exec>:
.global exec
exec:
 li a7, SYS_exec
 342:	489d                	li	a7,7
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <open>:
.global open
open:
 li a7, SYS_open
 34a:	48bd                	li	a7,15
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 352:	48c5                	li	a7,17
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35a:	48c9                	li	a7,18
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 362:	48a1                	li	a7,8
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <link>:
.global link
link:
 li a7, SYS_link
 36a:	48cd                	li	a7,19
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 372:	48d1                	li	a7,20
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37a:	48a5                	li	a7,9
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <dup>:
.global dup
dup:
 li a7, SYS_dup
 382:	48a9                	li	a7,10
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38a:	48ad                	li	a7,11
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 392:	48b1                	li	a7,12
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <pause>:
.global pause
pause:
 li a7, SYS_pause
 39a:	48b5                	li	a7,13
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a2:	48b9                	li	a7,14
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 3aa:	48dd                	li	a7,23
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b2:	1101                	addi	sp,sp,-32
 3b4:	ec06                	sd	ra,24(sp)
 3b6:	e822                	sd	s0,16(sp)
 3b8:	1000                	addi	s0,sp,32
 3ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3be:	4605                	li	a2,1
 3c0:	fef40593          	addi	a1,s0,-17
 3c4:	f67ff0ef          	jal	ra,32a <write>
}
 3c8:	60e2                	ld	ra,24(sp)
 3ca:	6442                	ld	s0,16(sp)
 3cc:	6105                	addi	sp,sp,32
 3ce:	8082                	ret

00000000000003d0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d0:	715d                	addi	sp,sp,-80
 3d2:	e486                	sd	ra,72(sp)
 3d4:	e0a2                	sd	s0,64(sp)
 3d6:	fc26                	sd	s1,56(sp)
 3d8:	f84a                	sd	s2,48(sp)
 3da:	f44e                	sd	s3,40(sp)
 3dc:	0880                	addi	s0,sp,80
 3de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e0:	c299                	beqz	a3,3e6 <printint+0x16>
 3e2:	0805c163          	bltz	a1,464 <printint+0x94>
  neg = 0;
 3e6:	4881                	li	a7,0
 3e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ec:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3ee:	00000517          	auipc	a0,0x0
 3f2:	51250513          	addi	a0,a0,1298 # 900 <digits>
 3f6:	883e                	mv	a6,a5
 3f8:	2785                	addiw	a5,a5,1
 3fa:	02c5f733          	remu	a4,a1,a2
 3fe:	972a                	add	a4,a4,a0
 400:	00074703          	lbu	a4,0(a4)
 404:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 408:	872e                	mv	a4,a1
 40a:	02c5d5b3          	divu	a1,a1,a2
 40e:	0685                	addi	a3,a3,1
 410:	fec773e3          	bgeu	a4,a2,3f6 <printint+0x26>
  if(neg)
 414:	00088b63          	beqz	a7,42a <printint+0x5a>
    buf[i++] = '-';
 418:	fd040713          	addi	a4,s0,-48
 41c:	97ba                	add	a5,a5,a4
 41e:	02d00713          	li	a4,45
 422:	fee78423          	sb	a4,-24(a5)
 426:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42a:	02f05663          	blez	a5,456 <printint+0x86>
 42e:	fb840713          	addi	a4,s0,-72
 432:	00f704b3          	add	s1,a4,a5
 436:	fff70993          	addi	s3,a4,-1
 43a:	99be                	add	s3,s3,a5
 43c:	37fd                	addiw	a5,a5,-1
 43e:	1782                	slli	a5,a5,0x20
 440:	9381                	srli	a5,a5,0x20
 442:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 446:	fff4c583          	lbu	a1,-1(s1)
 44a:	854a                	mv	a0,s2
 44c:	f67ff0ef          	jal	ra,3b2 <putc>
  while(--i >= 0)
 450:	14fd                	addi	s1,s1,-1
 452:	ff349ae3          	bne	s1,s3,446 <printint+0x76>
}
 456:	60a6                	ld	ra,72(sp)
 458:	6406                	ld	s0,64(sp)
 45a:	74e2                	ld	s1,56(sp)
 45c:	7942                	ld	s2,48(sp)
 45e:	79a2                	ld	s3,40(sp)
 460:	6161                	addi	sp,sp,80
 462:	8082                	ret
    x = -xx;
 464:	40b005b3          	neg	a1,a1
    neg = 1;
 468:	4885                	li	a7,1
    x = -xx;
 46a:	bfbd                	j	3e8 <printint+0x18>

000000000000046c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46c:	7119                	addi	sp,sp,-128
 46e:	fc86                	sd	ra,120(sp)
 470:	f8a2                	sd	s0,112(sp)
 472:	f4a6                	sd	s1,104(sp)
 474:	f0ca                	sd	s2,96(sp)
 476:	ecce                	sd	s3,88(sp)
 478:	e8d2                	sd	s4,80(sp)
 47a:	e4d6                	sd	s5,72(sp)
 47c:	e0da                	sd	s6,64(sp)
 47e:	fc5e                	sd	s7,56(sp)
 480:	f862                	sd	s8,48(sp)
 482:	f466                	sd	s9,40(sp)
 484:	f06a                	sd	s10,32(sp)
 486:	ec6e                	sd	s11,24(sp)
 488:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48a:	0005c903          	lbu	s2,0(a1)
 48e:	24090c63          	beqz	s2,6e6 <vprintf+0x27a>
 492:	8b2a                	mv	s6,a0
 494:	8a2e                	mv	s4,a1
 496:	8bb2                	mv	s7,a2
  state = 0;
 498:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49a:	4481                	li	s1,0
 49c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 49e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a6:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4aa:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ae:	00000c97          	auipc	s9,0x0
 4b2:	452c8c93          	addi	s9,s9,1106 # 900 <digits>
 4b6:	a005                	j	4d6 <vprintf+0x6a>
        putc(fd, c0);
 4b8:	85ca                	mv	a1,s2
 4ba:	855a                	mv	a0,s6
 4bc:	ef7ff0ef          	jal	ra,3b2 <putc>
 4c0:	a019                	j	4c6 <vprintf+0x5a>
    } else if(state == '%'){
 4c2:	03598263          	beq	s3,s5,4e6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4c6:	2485                	addiw	s1,s1,1
 4c8:	8726                	mv	a4,s1
 4ca:	009a07b3          	add	a5,s4,s1
 4ce:	0007c903          	lbu	s2,0(a5)
 4d2:	20090a63          	beqz	s2,6e6 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 4d6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4da:	fe0994e3          	bnez	s3,4c2 <vprintf+0x56>
      if(c0 == '%'){
 4de:	fd579de3          	bne	a5,s5,4b8 <vprintf+0x4c>
        state = '%';
 4e2:	89be                	mv	s3,a5
 4e4:	b7cd                	j	4c6 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4e6:	c3c1                	beqz	a5,566 <vprintf+0xfa>
 4e8:	00ea06b3          	add	a3,s4,a4
 4ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4f2:	c681                	beqz	a3,4fa <vprintf+0x8e>
 4f4:	9752                	add	a4,a4,s4
 4f6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4fa:	03878e63          	beq	a5,s8,536 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 4fe:	05a78863          	beq	a5,s10,54e <vprintf+0xe2>
      } else if(c0 == 'u'){
 502:	0db78b63          	beq	a5,s11,5d8 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 506:	07800713          	li	a4,120
 50a:	10e78d63          	beq	a5,a4,624 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 50e:	07000713          	li	a4,112
 512:	14e78263          	beq	a5,a4,656 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 516:	06300713          	li	a4,99
 51a:	16e78f63          	beq	a5,a4,698 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 51e:	07300713          	li	a4,115
 522:	18e78563          	beq	a5,a4,6ac <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 526:	05579063          	bne	a5,s5,566 <vprintf+0xfa>
        putc(fd, '%');
 52a:	85d6                	mv	a1,s5
 52c:	855a                	mv	a0,s6
 52e:	e85ff0ef          	jal	ra,3b2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 532:	4981                	li	s3,0
 534:	bf49                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 536:	008b8913          	addi	s2,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000ba583          	lw	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	e8dff0ef          	jal	ra,3d0 <printint>
 548:	8bca                	mv	s7,s2
      state = 0;
 54a:	4981                	li	s3,0
 54c:	bfad                	j	4c6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 54e:	03868663          	beq	a3,s8,57a <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 552:	05a68163          	beq	a3,s10,594 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 556:	09b68d63          	beq	a3,s11,5f0 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 55a:	03a68f63          	beq	a3,s10,598 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 55e:	07800793          	li	a5,120
 562:	0cf68d63          	beq	a3,a5,63c <vprintf+0x1d0>
        putc(fd, '%');
 566:	85d6                	mv	a1,s5
 568:	855a                	mv	a0,s6
 56a:	e49ff0ef          	jal	ra,3b2 <putc>
        putc(fd, c0);
 56e:	85ca                	mv	a1,s2
 570:	855a                	mv	a0,s6
 572:	e41ff0ef          	jal	ra,3b2 <putc>
      state = 0;
 576:	4981                	li	s3,0
 578:	b7b9                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 57a:	008b8913          	addi	s2,s7,8
 57e:	4685                	li	a3,1
 580:	4629                	li	a2,10
 582:	000bb583          	ld	a1,0(s7)
 586:	855a                	mv	a0,s6
 588:	e49ff0ef          	jal	ra,3d0 <printint>
        i += 1;
 58c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 58e:	8bca                	mv	s7,s2
      state = 0;
 590:	4981                	li	s3,0
        i += 1;
 592:	bf15                	j	4c6 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 594:	03860563          	beq	a2,s8,5be <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 598:	07b60963          	beq	a2,s11,60a <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 59c:	07800793          	li	a5,120
 5a0:	fcf613e3          	bne	a2,a5,566 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a4:	008b8913          	addi	s2,s7,8
 5a8:	4681                	li	a3,0
 5aa:	4641                	li	a2,16
 5ac:	000bb583          	ld	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e1fff0ef          	jal	ra,3d0 <printint>
        i += 2;
 5b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b8:	8bca                	mv	s7,s2
      state = 0;
 5ba:	4981                	li	s3,0
        i += 2;
 5bc:	b729                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5be:	008b8913          	addi	s2,s7,8
 5c2:	4685                	li	a3,1
 5c4:	4629                	li	a2,10
 5c6:	000bb583          	ld	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	e05ff0ef          	jal	ra,3d0 <printint>
        i += 2;
 5d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
        i += 2;
 5d6:	bdc5                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4681                	li	a3,0
 5de:	4629                	li	a2,10
 5e0:	000be583          	lwu	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	debff0ef          	jal	ra,3d0 <printint>
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bde1                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000bb583          	ld	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	dd3ff0ef          	jal	ra,3d0 <printint>
        i += 1;
 602:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	8bca                	mv	s7,s2
      state = 0;
 606:	4981                	li	s3,0
        i += 1;
 608:	bd7d                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	008b8913          	addi	s2,s7,8
 60e:	4681                	li	a3,0
 610:	4629                	li	a2,10
 612:	000bb583          	ld	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	db9ff0ef          	jal	ra,3d0 <printint>
        i += 2;
 61c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
        i += 2;
 622:	b555                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000be583          	lwu	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	d9fff0ef          	jal	ra,3d0 <printint>
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
 63a:	b571                	j	4c6 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	d87ff0ef          	jal	ra,3d0 <printint>
        i += 1;
 64e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
        i += 1;
 654:	bd8d                	j	4c6 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 656:	008b8793          	addi	a5,s7,8
 65a:	f8f43423          	sd	a5,-120(s0)
 65e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	855a                	mv	a0,s6
 668:	d4bff0ef          	jal	ra,3b2 <putc>
  putc(fd, 'x');
 66c:	07800593          	li	a1,120
 670:	855a                	mv	a0,s6
 672:	d41ff0ef          	jal	ra,3b2 <putc>
 676:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 678:	03c9d793          	srli	a5,s3,0x3c
 67c:	97e6                	add	a5,a5,s9
 67e:	0007c583          	lbu	a1,0(a5)
 682:	855a                	mv	a0,s6
 684:	d2fff0ef          	jal	ra,3b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 688:	0992                	slli	s3,s3,0x4
 68a:	397d                	addiw	s2,s2,-1
 68c:	fe0916e3          	bnez	s2,678 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 690:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 694:	4981                	li	s3,0
 696:	bd05                	j	4c6 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 698:	008b8913          	addi	s2,s7,8
 69c:	000bc583          	lbu	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	d11ff0ef          	jal	ra,3b2 <putc>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bd31                	j	4c6 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6ac:	008b8993          	addi	s3,s7,8
 6b0:	000bb903          	ld	s2,0(s7)
 6b4:	00090f63          	beqz	s2,6d2 <vprintf+0x266>
        for(; *s; s++)
 6b8:	00094583          	lbu	a1,0(s2)
 6bc:	c195                	beqz	a1,6e0 <vprintf+0x274>
          putc(fd, *s);
 6be:	855a                	mv	a0,s6
 6c0:	cf3ff0ef          	jal	ra,3b2 <putc>
        for(; *s; s++)
 6c4:	0905                	addi	s2,s2,1
 6c6:	00094583          	lbu	a1,0(s2)
 6ca:	f9f5                	bnez	a1,6be <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6cc:	8bce                	mv	s7,s3
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bbdd                	j	4c6 <vprintf+0x5a>
          s = "(null)";
 6d2:	00000917          	auipc	s2,0x0
 6d6:	22690913          	addi	s2,s2,550 # 8f8 <malloc+0x110>
        for(; *s; s++)
 6da:	02800593          	li	a1,40
 6de:	b7c5                	j	6be <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	8bce                	mv	s7,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b3cd                	j	4c6 <vprintf+0x5a>
    }
  }
}
 6e6:	70e6                	ld	ra,120(sp)
 6e8:	7446                	ld	s0,112(sp)
 6ea:	74a6                	ld	s1,104(sp)
 6ec:	7906                	ld	s2,96(sp)
 6ee:	69e6                	ld	s3,88(sp)
 6f0:	6a46                	ld	s4,80(sp)
 6f2:	6aa6                	ld	s5,72(sp)
 6f4:	6b06                	ld	s6,64(sp)
 6f6:	7be2                	ld	s7,56(sp)
 6f8:	7c42                	ld	s8,48(sp)
 6fa:	7ca2                	ld	s9,40(sp)
 6fc:	7d02                	ld	s10,32(sp)
 6fe:	6de2                	ld	s11,24(sp)
 700:	6109                	addi	sp,sp,128
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	d4bff0ef          	jal	ra,46c <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret

000000000000072e <printf>:

void
printf(const char *fmt, ...)
{
 72e:	711d                	addi	sp,sp,-96
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e40c                	sd	a1,8(s0)
 738:	e810                	sd	a2,16(s0)
 73a:	ec14                	sd	a3,24(s0)
 73c:	f018                	sd	a4,32(s0)
 73e:	f41c                	sd	a5,40(s0)
 740:	03043823          	sd	a6,48(s0)
 744:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	00840613          	addi	a2,s0,8
 74c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 750:	85aa                	mv	a1,a0
 752:	4505                	li	a0,1
 754:	d19ff0ef          	jal	ra,46c <vprintf>
}
 758:	60e2                	ld	ra,24(sp)
 75a:	6442                	ld	s0,16(sp)
 75c:	6125                	addi	sp,sp,96
 75e:	8082                	ret

0000000000000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	1141                	addi	sp,sp,-16
 762:	e422                	sd	s0,8(sp)
 764:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	00001797          	auipc	a5,0x1
 76e:	8967b783          	ld	a5,-1898(a5) # 1000 <freep>
 772:	a805                	j	7a2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 774:	4618                	lw	a4,8(a2)
 776:	9db9                	addw	a1,a1,a4
 778:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77c:	6398                	ld	a4,0(a5)
 77e:	6318                	ld	a4,0(a4)
 780:	fee53823          	sd	a4,-16(a0)
 784:	a091                	j	7c8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 786:	ff852703          	lw	a4,-8(a0)
 78a:	9e39                	addw	a2,a2,a4
 78c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 78e:	ff053703          	ld	a4,-16(a0)
 792:	e398                	sd	a4,0(a5)
 794:	a099                	j	7da <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 796:	6398                	ld	a4,0(a5)
 798:	00e7e463          	bltu	a5,a4,7a0 <free+0x40>
 79c:	00e6ea63          	bltu	a3,a4,7b0 <free+0x50>
{
 7a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	fed7fae3          	bgeu	a5,a3,796 <free+0x36>
 7a6:	6398                	ld	a4,0(a5)
 7a8:	00e6e463          	bltu	a3,a4,7b0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ac:	fee7eae3          	bltu	a5,a4,7a0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7b0:	ff852583          	lw	a1,-8(a0)
 7b4:	6390                	ld	a2,0(a5)
 7b6:	02059713          	slli	a4,a1,0x20
 7ba:	9301                	srli	a4,a4,0x20
 7bc:	0712                	slli	a4,a4,0x4
 7be:	9736                	add	a4,a4,a3
 7c0:	fae60ae3          	beq	a2,a4,774 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c8:	4790                	lw	a2,8(a5)
 7ca:	02061713          	slli	a4,a2,0x20
 7ce:	9301                	srli	a4,a4,0x20
 7d0:	0712                	slli	a4,a4,0x4
 7d2:	973e                	add	a4,a4,a5
 7d4:	fae689e3          	beq	a3,a4,786 <free+0x26>
  } else
    p->s.ptr = bp;
 7d8:	e394                	sd	a3,0(a5)
  freep = p;
 7da:	00001717          	auipc	a4,0x1
 7de:	82f73323          	sd	a5,-2010(a4) # 1000 <freep>
}
 7e2:	6422                	ld	s0,8(sp)
 7e4:	0141                	addi	sp,sp,16
 7e6:	8082                	ret

00000000000007e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e8:	7139                	addi	sp,sp,-64
 7ea:	fc06                	sd	ra,56(sp)
 7ec:	f822                	sd	s0,48(sp)
 7ee:	f426                	sd	s1,40(sp)
 7f0:	f04a                	sd	s2,32(sp)
 7f2:	ec4e                	sd	s3,24(sp)
 7f4:	e852                	sd	s4,16(sp)
 7f6:	e456                	sd	s5,8(sp)
 7f8:	e05a                	sd	s6,0(sp)
 7fa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fc:	02051493          	slli	s1,a0,0x20
 800:	9081                	srli	s1,s1,0x20
 802:	04bd                	addi	s1,s1,15
 804:	8091                	srli	s1,s1,0x4
 806:	0014899b          	addiw	s3,s1,1
 80a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 80c:	00000517          	auipc	a0,0x0
 810:	7f453503          	ld	a0,2036(a0) # 1000 <freep>
 814:	c515                	beqz	a0,840 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 816:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 818:	4798                	lw	a4,8(a5)
 81a:	02977f63          	bgeu	a4,s1,858 <malloc+0x70>
 81e:	8a4e                	mv	s4,s3
 820:	0009871b          	sext.w	a4,s3
 824:	6685                	lui	a3,0x1
 826:	00d77363          	bgeu	a4,a3,82c <malloc+0x44>
 82a:	6a05                	lui	s4,0x1
 82c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 830:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 834:	00000917          	auipc	s2,0x0
 838:	7cc90913          	addi	s2,s2,1996 # 1000 <freep>
  if(p == SBRK_ERROR)
 83c:	5afd                	li	s5,-1
 83e:	a0bd                	j	8ac <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 840:	00000797          	auipc	a5,0x0
 844:	7d078793          	addi	a5,a5,2000 # 1010 <base>
 848:	00000717          	auipc	a4,0x0
 84c:	7af73c23          	sd	a5,1976(a4) # 1000 <freep>
 850:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 852:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 856:	b7e1                	j	81e <malloc+0x36>
      if(p->s.size == nunits)
 858:	02e48b63          	beq	s1,a4,88e <malloc+0xa6>
        p->s.size -= nunits;
 85c:	4137073b          	subw	a4,a4,s3
 860:	c798                	sw	a4,8(a5)
        p += p->s.size;
 862:	1702                	slli	a4,a4,0x20
 864:	9301                	srli	a4,a4,0x20
 866:	0712                	slli	a4,a4,0x4
 868:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86e:	00000717          	auipc	a4,0x0
 872:	78a73923          	sd	a0,1938(a4) # 1000 <freep>
      return (void*)(p + 1);
 876:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87a:	70e2                	ld	ra,56(sp)
 87c:	7442                	ld	s0,48(sp)
 87e:	74a2                	ld	s1,40(sp)
 880:	7902                	ld	s2,32(sp)
 882:	69e2                	ld	s3,24(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	6121                	addi	sp,sp,64
 88c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 88e:	6398                	ld	a4,0(a5)
 890:	e118                	sd	a4,0(a0)
 892:	bff1                	j	86e <malloc+0x86>
  hp->s.size = nu;
 894:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 898:	0541                	addi	a0,a0,16
 89a:	ec7ff0ef          	jal	ra,760 <free>
  return freep;
 89e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a2:	dd61                	beqz	a0,87a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	fa9778e3          	bgeu	a4,s1,858 <malloc+0x70>
    if(p == freep)
 8ac:	00093703          	ld	a4,0(s2)
 8b0:	853e                	mv	a0,a5
 8b2:	fef719e3          	bne	a4,a5,8a4 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 8b6:	8552                	mv	a0,s4
 8b8:	a1fff0ef          	jal	ra,2d6 <sbrk>
  if(p == SBRK_ERROR)
 8bc:	fd551ce3          	bne	a0,s5,894 <malloc+0xac>
        return 0;
 8c0:	4501                	li	a0,0
 8c2:	bf65                	j	87a <malloc+0x92>
