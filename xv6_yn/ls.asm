
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	83 ec 0c             	sub    $0xc,%esp
   a:	ff 75 08             	push   0x8(%ebp)
   d:	e8 c5 03 00 00       	call   3d7 <strlen>
  12:	83 c4 10             	add    $0x10,%esp
  15:	8b 55 08             	mov    0x8(%ebp),%edx
  18:	01 d0                	add    %edx,%eax
  1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1d:	eb 04                	jmp    23 <fmtname+0x23>
  1f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  26:	3b 45 08             	cmp    0x8(%ebp),%eax
  29:	72 0a                	jb     35 <fmtname+0x35>
  2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2e:	0f b6 00             	movzbl (%eax),%eax
  31:	3c 2f                	cmp    $0x2f,%al
  33:	75 ea                	jne    1f <fmtname+0x1f>
    ;
  p++;
  35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  39:	83 ec 0c             	sub    $0xc,%esp
  3c:	ff 75 f4             	push   -0xc(%ebp)
  3f:	e8 93 03 00 00       	call   3d7 <strlen>
  44:	83 c4 10             	add    $0x10,%esp
  47:	83 f8 0d             	cmp    $0xd,%eax
  4a:	76 05                	jbe    51 <fmtname+0x51>
    return p;
  4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4f:	eb 60                	jmp    b1 <fmtname+0xb1>
  memmove(buf, p, strlen(p));
  51:	83 ec 0c             	sub    $0xc,%esp
  54:	ff 75 f4             	push   -0xc(%ebp)
  57:	e8 7b 03 00 00       	call   3d7 <strlen>
  5c:	83 c4 10             	add    $0x10,%esp
  5f:	83 ec 04             	sub    $0x4,%esp
  62:	50                   	push   %eax
  63:	ff 75 f4             	push   -0xc(%ebp)
  66:	68 e0 0d 00 00       	push   $0xde0
  6b:	e8 e4 04 00 00       	call   554 <memmove>
  70:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  73:	83 ec 0c             	sub    $0xc,%esp
  76:	ff 75 f4             	push   -0xc(%ebp)
  79:	e8 59 03 00 00       	call   3d7 <strlen>
  7e:	83 c4 10             	add    $0x10,%esp
  81:	ba 0e 00 00 00       	mov    $0xe,%edx
  86:	89 d3                	mov    %edx,%ebx
  88:	29 c3                	sub    %eax,%ebx
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	ff 75 f4             	push   -0xc(%ebp)
  90:	e8 42 03 00 00       	call   3d7 <strlen>
  95:	83 c4 10             	add    $0x10,%esp
  98:	05 e0 0d 00 00       	add    $0xde0,%eax
  9d:	83 ec 04             	sub    $0x4,%esp
  a0:	53                   	push   %ebx
  a1:	6a 20                	push   $0x20
  a3:	50                   	push   %eax
  a4:	e8 55 03 00 00       	call   3fe <memset>
  a9:	83 c4 10             	add    $0x10,%esp
  return buf;
  ac:	b8 e0 0d 00 00       	mov    $0xde0,%eax
}
  b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b4:	c9                   	leave  
  b5:	c3                   	ret    

000000b6 <ls>:

void
ls(char *path)
{
  b6:	55                   	push   %ebp
  b7:	89 e5                	mov    %esp,%ebp
  b9:	57                   	push   %edi
  ba:	56                   	push   %esi
  bb:	53                   	push   %ebx
  bc:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  c2:	83 ec 08             	sub    $0x8,%esp
  c5:	6a 00                	push   $0x0
  c7:	ff 75 08             	push   0x8(%ebp)
  ca:	e8 0a 05 00 00       	call   5d9 <open>
  cf:	83 c4 10             	add    $0x10,%esp
  d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d9:	79 1a                	jns    f5 <ls+0x3f>
    printf(2, "ls: cannot open %s\n", path);
  db:	83 ec 04             	sub    $0x4,%esp
  de:	ff 75 08             	push   0x8(%ebp)
  e1:	68 dc 0a 00 00       	push   $0xadc
  e6:	6a 02                	push   $0x2
  e8:	e8 38 06 00 00       	call   725 <printf>
  ed:	83 c4 10             	add    $0x10,%esp
    return;
  f0:	e9 e1 01 00 00       	jmp    2d6 <ls+0x220>
  }

  if(fstat(fd, &st) < 0){
  f5:	83 ec 08             	sub    $0x8,%esp
  f8:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fe:	50                   	push   %eax
  ff:	ff 75 e4             	push   -0x1c(%ebp)
 102:	e8 ea 04 00 00       	call   5f1 <fstat>
 107:	83 c4 10             	add    $0x10,%esp
 10a:	85 c0                	test   %eax,%eax
 10c:	79 28                	jns    136 <ls+0x80>
    printf(2, "ls: cannot stat %s\n", path);
 10e:	83 ec 04             	sub    $0x4,%esp
 111:	ff 75 08             	push   0x8(%ebp)
 114:	68 f0 0a 00 00       	push   $0xaf0
 119:	6a 02                	push   $0x2
 11b:	e8 05 06 00 00       	call   725 <printf>
 120:	83 c4 10             	add    $0x10,%esp
    close(fd);
 123:	83 ec 0c             	sub    $0xc,%esp
 126:	ff 75 e4             	push   -0x1c(%ebp)
 129:	e8 93 04 00 00       	call   5c1 <close>
 12e:	83 c4 10             	add    $0x10,%esp
    return;
 131:	e9 a0 01 00 00       	jmp    2d6 <ls+0x220>
  }

  switch(st.type){
 136:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 13d:	98                   	cwtl   
 13e:	83 f8 01             	cmp    $0x1,%eax
 141:	74 48                	je     18b <ls+0xd5>
 143:	83 f8 02             	cmp    $0x2,%eax
 146:	0f 85 7c 01 00 00    	jne    2c8 <ls+0x212>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 14c:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 152:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 158:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 15f:	0f bf d8             	movswl %ax,%ebx
 162:	83 ec 0c             	sub    $0xc,%esp
 165:	ff 75 08             	push   0x8(%ebp)
 168:	e8 93 fe ff ff       	call   0 <fmtname>
 16d:	83 c4 10             	add    $0x10,%esp
 170:	83 ec 08             	sub    $0x8,%esp
 173:	57                   	push   %edi
 174:	56                   	push   %esi
 175:	53                   	push   %ebx
 176:	50                   	push   %eax
 177:	68 04 0b 00 00       	push   $0xb04
 17c:	6a 01                	push   $0x1
 17e:	e8 a2 05 00 00       	call   725 <printf>
 183:	83 c4 20             	add    $0x20,%esp
    break;
 186:	e9 3d 01 00 00       	jmp    2c8 <ls+0x212>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 18b:	83 ec 0c             	sub    $0xc,%esp
 18e:	ff 75 08             	push   0x8(%ebp)
 191:	e8 41 02 00 00       	call   3d7 <strlen>
 196:	83 c4 10             	add    $0x10,%esp
 199:	83 c0 10             	add    $0x10,%eax
 19c:	3d 00 02 00 00       	cmp    $0x200,%eax
 1a1:	76 17                	jbe    1ba <ls+0x104>
      printf(1, "ls: path too long\n");
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	68 11 0b 00 00       	push   $0xb11
 1ab:	6a 01                	push   $0x1
 1ad:	e8 73 05 00 00       	call   725 <printf>
 1b2:	83 c4 10             	add    $0x10,%esp
      break;
 1b5:	e9 0e 01 00 00       	jmp    2c8 <ls+0x212>
    }
    strcpy(buf, path);
 1ba:	83 ec 08             	sub    $0x8,%esp
 1bd:	ff 75 08             	push   0x8(%ebp)
 1c0:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1c6:	50                   	push   %eax
 1c7:	e8 9c 01 00 00       	call   368 <strcpy>
 1cc:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1cf:	83 ec 0c             	sub    $0xc,%esp
 1d2:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d8:	50                   	push   %eax
 1d9:	e8 f9 01 00 00       	call   3d7 <strlen>
 1de:	83 c4 10             	add    $0x10,%esp
 1e1:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1e7:	01 d0                	add    %edx,%eax
 1e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1ef:	8d 50 01             	lea    0x1(%eax),%edx
 1f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1f5:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1f8:	e9 aa 00 00 00       	jmp    2a7 <ls+0x1f1>
      if(de.inum == 0)
 1fd:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 204:	66 85 c0             	test   %ax,%ax
 207:	75 05                	jne    20e <ls+0x158>
        continue;
 209:	e9 99 00 00 00       	jmp    2a7 <ls+0x1f1>
      memmove(p, de.name, DIRSIZ);
 20e:	83 ec 04             	sub    $0x4,%esp
 211:	6a 0e                	push   $0xe
 213:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 219:	83 c0 02             	add    $0x2,%eax
 21c:	50                   	push   %eax
 21d:	ff 75 e0             	push   -0x20(%ebp)
 220:	e8 2f 03 00 00       	call   554 <memmove>
 225:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 228:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22b:	83 c0 0e             	add    $0xe,%eax
 22e:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 231:	83 ec 08             	sub    $0x8,%esp
 234:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 23a:	50                   	push   %eax
 23b:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 241:	50                   	push   %eax
 242:	e8 73 02 00 00       	call   4ba <stat>
 247:	83 c4 10             	add    $0x10,%esp
 24a:	85 c0                	test   %eax,%eax
 24c:	79 1b                	jns    269 <ls+0x1b3>
        printf(1, "ls: cannot stat %s\n", buf);
 24e:	83 ec 04             	sub    $0x4,%esp
 251:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 257:	50                   	push   %eax
 258:	68 f0 0a 00 00       	push   $0xaf0
 25d:	6a 01                	push   $0x1
 25f:	e8 c1 04 00 00       	call   725 <printf>
 264:	83 c4 10             	add    $0x10,%esp
        continue;
 267:	eb 3e                	jmp    2a7 <ls+0x1f1>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 269:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 26f:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 275:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 27c:	0f bf d8             	movswl %ax,%ebx
 27f:	83 ec 0c             	sub    $0xc,%esp
 282:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 288:	50                   	push   %eax
 289:	e8 72 fd ff ff       	call   0 <fmtname>
 28e:	83 c4 10             	add    $0x10,%esp
 291:	83 ec 08             	sub    $0x8,%esp
 294:	57                   	push   %edi
 295:	56                   	push   %esi
 296:	53                   	push   %ebx
 297:	50                   	push   %eax
 298:	68 04 0b 00 00       	push   $0xb04
 29d:	6a 01                	push   $0x1
 29f:	e8 81 04 00 00       	call   725 <printf>
 2a4:	83 c4 20             	add    $0x20,%esp
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2a7:	83 ec 04             	sub    $0x4,%esp
 2aa:	6a 10                	push   $0x10
 2ac:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2b2:	50                   	push   %eax
 2b3:	ff 75 e4             	push   -0x1c(%ebp)
 2b6:	e8 f6 02 00 00       	call   5b1 <read>
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	83 f8 10             	cmp    $0x10,%eax
 2c1:	0f 84 36 ff ff ff    	je     1fd <ls+0x147>
    }
    break;
 2c7:	90                   	nop
  }
  close(fd);
 2c8:	83 ec 0c             	sub    $0xc,%esp
 2cb:	ff 75 e4             	push   -0x1c(%ebp)
 2ce:	e8 ee 02 00 00       	call   5c1 <close>
 2d3:	83 c4 10             	add    $0x10,%esp
}
 2d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2d9:	5b                   	pop    %ebx
 2da:	5e                   	pop    %esi
 2db:	5f                   	pop    %edi
 2dc:	5d                   	pop    %ebp
 2dd:	c3                   	ret    

000002de <main>:

int
main(int argc, char *argv[])
{
 2de:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2e2:	83 e4 f0             	and    $0xfffffff0,%esp
 2e5:	ff 71 fc             	push   -0x4(%ecx)
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	53                   	push   %ebx
 2ec:	51                   	push   %ecx
 2ed:	83 ec 10             	sub    $0x10,%esp
 2f0:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 2f2:	83 3b 01             	cmpl   $0x1,(%ebx)
 2f5:	7f 15                	jg     30c <main+0x2e>
    ls(".");
 2f7:	83 ec 0c             	sub    $0xc,%esp
 2fa:	68 24 0b 00 00       	push   $0xb24
 2ff:	e8 b2 fd ff ff       	call   b6 <ls>
 304:	83 c4 10             	add    $0x10,%esp
    exit();
 307:	e8 8d 02 00 00       	call   599 <exit>
  }
  for(i=1; i<argc; i++)
 30c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 313:	eb 21                	jmp    336 <main+0x58>
    ls(argv[i]);
 315:	8b 45 f4             	mov    -0xc(%ebp),%eax
 318:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 31f:	8b 43 04             	mov    0x4(%ebx),%eax
 322:	01 d0                	add    %edx,%eax
 324:	8b 00                	mov    (%eax),%eax
 326:	83 ec 0c             	sub    $0xc,%esp
 329:	50                   	push   %eax
 32a:	e8 87 fd ff ff       	call   b6 <ls>
 32f:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
 332:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 336:	8b 45 f4             	mov    -0xc(%ebp),%eax
 339:	3b 03                	cmp    (%ebx),%eax
 33b:	7c d8                	jl     315 <main+0x37>
  exit();
 33d:	e8 57 02 00 00       	call   599 <exit>

00000342 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	57                   	push   %edi
 346:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 347:	8b 4d 08             	mov    0x8(%ebp),%ecx
 34a:	8b 55 10             	mov    0x10(%ebp),%edx
 34d:	8b 45 0c             	mov    0xc(%ebp),%eax
 350:	89 cb                	mov    %ecx,%ebx
 352:	89 df                	mov    %ebx,%edi
 354:	89 d1                	mov    %edx,%ecx
 356:	fc                   	cld    
 357:	f3 aa                	rep stos %al,%es:(%edi)
 359:	89 ca                	mov    %ecx,%edx
 35b:	89 fb                	mov    %edi,%ebx
 35d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 360:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 363:	90                   	nop
 364:	5b                   	pop    %ebx
 365:	5f                   	pop    %edi
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    

00000368 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 374:	90                   	nop
 375:	8b 55 0c             	mov    0xc(%ebp),%edx
 378:	8d 42 01             	lea    0x1(%edx),%eax
 37b:	89 45 0c             	mov    %eax,0xc(%ebp)
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	8d 48 01             	lea    0x1(%eax),%ecx
 384:	89 4d 08             	mov    %ecx,0x8(%ebp)
 387:	0f b6 12             	movzbl (%edx),%edx
 38a:	88 10                	mov    %dl,(%eax)
 38c:	0f b6 00             	movzbl (%eax),%eax
 38f:	84 c0                	test   %al,%al
 391:	75 e2                	jne    375 <strcpy+0xd>
    ;
  return os;
 393:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 396:	c9                   	leave  
 397:	c3                   	ret    

00000398 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 39b:	eb 08                	jmp    3a5 <strcmp+0xd>
    p++, q++;
 39d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3a5:	8b 45 08             	mov    0x8(%ebp),%eax
 3a8:	0f b6 00             	movzbl (%eax),%eax
 3ab:	84 c0                	test   %al,%al
 3ad:	74 10                	je     3bf <strcmp+0x27>
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	0f b6 10             	movzbl (%eax),%edx
 3b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	38 c2                	cmp    %al,%dl
 3bd:	74 de                	je     39d <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	0f b6 d0             	movzbl %al,%edx
 3c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f b6 c8             	movzbl %al,%ecx
 3d1:	89 d0                	mov    %edx,%eax
 3d3:	29 c8                	sub    %ecx,%eax
}
 3d5:	5d                   	pop    %ebp
 3d6:	c3                   	ret    

000003d7 <strlen>:

uint
strlen(char *s)
{
 3d7:	55                   	push   %ebp
 3d8:	89 e5                	mov    %esp,%ebp
 3da:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3e4:	eb 04                	jmp    3ea <strlen+0x13>
 3e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	01 d0                	add    %edx,%eax
 3f2:	0f b6 00             	movzbl (%eax),%eax
 3f5:	84 c0                	test   %al,%al
 3f7:	75 ed                	jne    3e6 <strlen+0xf>
    ;
  return n;
 3f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3fc:	c9                   	leave  
 3fd:	c3                   	ret    

000003fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 3fe:	55                   	push   %ebp
 3ff:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 401:	8b 45 10             	mov    0x10(%ebp),%eax
 404:	50                   	push   %eax
 405:	ff 75 0c             	push   0xc(%ebp)
 408:	ff 75 08             	push   0x8(%ebp)
 40b:	e8 32 ff ff ff       	call   342 <stosb>
 410:	83 c4 0c             	add    $0xc,%esp
  return dst;
 413:	8b 45 08             	mov    0x8(%ebp),%eax
}
 416:	c9                   	leave  
 417:	c3                   	ret    

00000418 <strchr>:

char*
strchr(const char *s, char c)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 04             	sub    $0x4,%esp
 41e:	8b 45 0c             	mov    0xc(%ebp),%eax
 421:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 424:	eb 14                	jmp    43a <strchr+0x22>
    if(*s == c)
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	0f b6 00             	movzbl (%eax),%eax
 42c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 42f:	75 05                	jne    436 <strchr+0x1e>
      return (char*)s;
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	eb 13                	jmp    449 <strchr+0x31>
  for(; *s; s++)
 436:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
 43d:	0f b6 00             	movzbl (%eax),%eax
 440:	84 c0                	test   %al,%al
 442:	75 e2                	jne    426 <strchr+0xe>
  return 0;
 444:	b8 00 00 00 00       	mov    $0x0,%eax
}
 449:	c9                   	leave  
 44a:	c3                   	ret    

0000044b <gets>:

char*
gets(char *buf, int max)
{
 44b:	55                   	push   %ebp
 44c:	89 e5                	mov    %esp,%ebp
 44e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 458:	eb 42                	jmp    49c <gets+0x51>
    cc = read(0, &c, 1);
 45a:	83 ec 04             	sub    $0x4,%esp
 45d:	6a 01                	push   $0x1
 45f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 462:	50                   	push   %eax
 463:	6a 00                	push   $0x0
 465:	e8 47 01 00 00       	call   5b1 <read>
 46a:	83 c4 10             	add    $0x10,%esp
 46d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 470:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 474:	7e 33                	jle    4a9 <gets+0x5e>
      break;
    buf[i++] = c;
 476:	8b 45 f4             	mov    -0xc(%ebp),%eax
 479:	8d 50 01             	lea    0x1(%eax),%edx
 47c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 47f:	89 c2                	mov    %eax,%edx
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	01 c2                	add    %eax,%edx
 486:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 48a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 48c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 490:	3c 0a                	cmp    $0xa,%al
 492:	74 16                	je     4aa <gets+0x5f>
 494:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 498:	3c 0d                	cmp    $0xd,%al
 49a:	74 0e                	je     4aa <gets+0x5f>
  for(i=0; i+1 < max; ){
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	83 c0 01             	add    $0x1,%eax
 4a2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4a5:	7f b3                	jg     45a <gets+0xf>
 4a7:	eb 01                	jmp    4aa <gets+0x5f>
      break;
 4a9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4ad:	8b 45 08             	mov    0x8(%ebp),%eax
 4b0:	01 d0                	add    %edx,%eax
 4b2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <stat>:

int
stat(char *n, struct stat *st)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
 4bd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4c0:	83 ec 08             	sub    $0x8,%esp
 4c3:	6a 00                	push   $0x0
 4c5:	ff 75 08             	push   0x8(%ebp)
 4c8:	e8 0c 01 00 00       	call   5d9 <open>
 4cd:	83 c4 10             	add    $0x10,%esp
 4d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d7:	79 07                	jns    4e0 <stat+0x26>
    return -1;
 4d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4de:	eb 25                	jmp    505 <stat+0x4b>
  r = fstat(fd, st);
 4e0:	83 ec 08             	sub    $0x8,%esp
 4e3:	ff 75 0c             	push   0xc(%ebp)
 4e6:	ff 75 f4             	push   -0xc(%ebp)
 4e9:	e8 03 01 00 00       	call   5f1 <fstat>
 4ee:	83 c4 10             	add    $0x10,%esp
 4f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4f4:	83 ec 0c             	sub    $0xc,%esp
 4f7:	ff 75 f4             	push   -0xc(%ebp)
 4fa:	e8 c2 00 00 00       	call   5c1 <close>
 4ff:	83 c4 10             	add    $0x10,%esp
  return r;
 502:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 505:	c9                   	leave  
 506:	c3                   	ret    

00000507 <atoi>:

int
atoi(const char *s)
{
 507:	55                   	push   %ebp
 508:	89 e5                	mov    %esp,%ebp
 50a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 50d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 514:	eb 25                	jmp    53b <atoi+0x34>
    n = n*10 + *s++ - '0';
 516:	8b 55 fc             	mov    -0x4(%ebp),%edx
 519:	89 d0                	mov    %edx,%eax
 51b:	c1 e0 02             	shl    $0x2,%eax
 51e:	01 d0                	add    %edx,%eax
 520:	01 c0                	add    %eax,%eax
 522:	89 c1                	mov    %eax,%ecx
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	8d 50 01             	lea    0x1(%eax),%edx
 52a:	89 55 08             	mov    %edx,0x8(%ebp)
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	01 c8                	add    %ecx,%eax
 535:	83 e8 30             	sub    $0x30,%eax
 538:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	0f b6 00             	movzbl (%eax),%eax
 541:	3c 2f                	cmp    $0x2f,%al
 543:	7e 0a                	jle    54f <atoi+0x48>
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	0f b6 00             	movzbl (%eax),%eax
 54b:	3c 39                	cmp    $0x39,%al
 54d:	7e c7                	jle    516 <atoi+0xf>
  return n;
 54f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 552:	c9                   	leave  
 553:	c3                   	ret    

00000554 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 554:	55                   	push   %ebp
 555:	89 e5                	mov    %esp,%ebp
 557:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 55a:	8b 45 08             	mov    0x8(%ebp),%eax
 55d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 560:	8b 45 0c             	mov    0xc(%ebp),%eax
 563:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 566:	eb 17                	jmp    57f <memmove+0x2b>
    *dst++ = *src++;
 568:	8b 55 f8             	mov    -0x8(%ebp),%edx
 56b:	8d 42 01             	lea    0x1(%edx),%eax
 56e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 571:	8b 45 fc             	mov    -0x4(%ebp),%eax
 574:	8d 48 01             	lea    0x1(%eax),%ecx
 577:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 57a:	0f b6 12             	movzbl (%edx),%edx
 57d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 57f:	8b 45 10             	mov    0x10(%ebp),%eax
 582:	8d 50 ff             	lea    -0x1(%eax),%edx
 585:	89 55 10             	mov    %edx,0x10(%ebp)
 588:	85 c0                	test   %eax,%eax
 58a:	7f dc                	jg     568 <memmove+0x14>
  return vdst;
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 58f:	c9                   	leave  
 590:	c3                   	ret    

00000591 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 591:	b8 01 00 00 00       	mov    $0x1,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <exit>:
SYSCALL(exit)
 599:	b8 02 00 00 00       	mov    $0x2,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <wait>:
SYSCALL(wait)
 5a1:	b8 03 00 00 00       	mov    $0x3,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <pipe>:
SYSCALL(pipe)
 5a9:	b8 04 00 00 00       	mov    $0x4,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret    

000005b1 <read>:
SYSCALL(read)
 5b1:	b8 05 00 00 00       	mov    $0x5,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret    

000005b9 <write>:
SYSCALL(write)
 5b9:	b8 10 00 00 00       	mov    $0x10,%eax
 5be:	cd 40                	int    $0x40
 5c0:	c3                   	ret    

000005c1 <close>:
SYSCALL(close)
 5c1:	b8 15 00 00 00       	mov    $0x15,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret    

000005c9 <kill>:
SYSCALL(kill)
 5c9:	b8 06 00 00 00       	mov    $0x6,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret    

000005d1 <exec>:
SYSCALL(exec)
 5d1:	b8 07 00 00 00       	mov    $0x7,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret    

000005d9 <open>:
SYSCALL(open)
 5d9:	b8 0f 00 00 00       	mov    $0xf,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <mknod>:
SYSCALL(mknod)
 5e1:	b8 11 00 00 00       	mov    $0x11,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <unlink>:
SYSCALL(unlink)
 5e9:	b8 12 00 00 00       	mov    $0x12,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <fstat>:
SYSCALL(fstat)
 5f1:	b8 08 00 00 00       	mov    $0x8,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <link>:
SYSCALL(link)
 5f9:	b8 13 00 00 00       	mov    $0x13,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <mkdir>:
SYSCALL(mkdir)
 601:	b8 14 00 00 00       	mov    $0x14,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <chdir>:
SYSCALL(chdir)
 609:	b8 09 00 00 00       	mov    $0x9,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <dup>:
SYSCALL(dup)
 611:	b8 0a 00 00 00       	mov    $0xa,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <getpid>:
SYSCALL(getpid)
 619:	b8 0b 00 00 00       	mov    $0xb,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <sbrk>:
SYSCALL(sbrk)
 621:	b8 0c 00 00 00       	mov    $0xc,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <sleep>:
SYSCALL(sleep)
 629:	b8 0d 00 00 00       	mov    $0xd,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <uptime>:
SYSCALL(uptime)
 631:	b8 0e 00 00 00       	mov    $0xe,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <uthread_init>:
SYSCALL(uthread_init)
 639:	b8 16 00 00 00       	mov    $0x16,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret    

00000641 <thread_inc>:
SYSCALL(thread_inc)
 641:	b8 17 00 00 00       	mov    $0x17,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret    

00000649 <thread_dec>:
SYSCALL(thread_dec)
 649:	b8 18 00 00 00       	mov    $0x18,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret    

00000651 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 651:	55                   	push   %ebp
 652:	89 e5                	mov    %esp,%ebp
 654:	83 ec 18             	sub    $0x18,%esp
 657:	8b 45 0c             	mov    0xc(%ebp),%eax
 65a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 65d:	83 ec 04             	sub    $0x4,%esp
 660:	6a 01                	push   $0x1
 662:	8d 45 f4             	lea    -0xc(%ebp),%eax
 665:	50                   	push   %eax
 666:	ff 75 08             	push   0x8(%ebp)
 669:	e8 4b ff ff ff       	call   5b9 <write>
 66e:	83 c4 10             	add    $0x10,%esp
}
 671:	90                   	nop
 672:	c9                   	leave  
 673:	c3                   	ret    

00000674 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 674:	55                   	push   %ebp
 675:	89 e5                	mov    %esp,%ebp
 677:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 67a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 681:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 685:	74 17                	je     69e <printint+0x2a>
 687:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 68b:	79 11                	jns    69e <printint+0x2a>
    neg = 1;
 68d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 694:	8b 45 0c             	mov    0xc(%ebp),%eax
 697:	f7 d8                	neg    %eax
 699:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69c:	eb 06                	jmp    6a4 <printint+0x30>
  } else {
    x = xx;
 69e:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b1:	ba 00 00 00 00       	mov    $0x0,%edx
 6b6:	f7 f1                	div    %ecx
 6b8:	89 d1                	mov    %edx,%ecx
 6ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6bd:	8d 50 01             	lea    0x1(%eax),%edx
 6c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6c3:	0f b6 91 cc 0d 00 00 	movzbl 0xdcc(%ecx),%edx
 6ca:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d4:	ba 00 00 00 00       	mov    $0x0,%edx
 6d9:	f7 f1                	div    %ecx
 6db:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e2:	75 c7                	jne    6ab <printint+0x37>
  if(neg)
 6e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e8:	74 2d                	je     717 <printint+0xa3>
    buf[i++] = '-';
 6ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ed:	8d 50 01             	lea    0x1(%eax),%edx
 6f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6f8:	eb 1d                	jmp    717 <printint+0xa3>
    putc(fd, buf[i]);
 6fa:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 700:	01 d0                	add    %edx,%eax
 702:	0f b6 00             	movzbl (%eax),%eax
 705:	0f be c0             	movsbl %al,%eax
 708:	83 ec 08             	sub    $0x8,%esp
 70b:	50                   	push   %eax
 70c:	ff 75 08             	push   0x8(%ebp)
 70f:	e8 3d ff ff ff       	call   651 <putc>
 714:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 717:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 71b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 71f:	79 d9                	jns    6fa <printint+0x86>
}
 721:	90                   	nop
 722:	90                   	nop
 723:	c9                   	leave  
 724:	c3                   	ret    

00000725 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 725:	55                   	push   %ebp
 726:	89 e5                	mov    %esp,%ebp
 728:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 72b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 732:	8d 45 0c             	lea    0xc(%ebp),%eax
 735:	83 c0 04             	add    $0x4,%eax
 738:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 73b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 742:	e9 59 01 00 00       	jmp    8a0 <printf+0x17b>
    c = fmt[i] & 0xff;
 747:	8b 55 0c             	mov    0xc(%ebp),%edx
 74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74d:	01 d0                	add    %edx,%eax
 74f:	0f b6 00             	movzbl (%eax),%eax
 752:	0f be c0             	movsbl %al,%eax
 755:	25 ff 00 00 00       	and    $0xff,%eax
 75a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 75d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 761:	75 2c                	jne    78f <printf+0x6a>
      if(c == '%'){
 763:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 767:	75 0c                	jne    775 <printf+0x50>
        state = '%';
 769:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 770:	e9 27 01 00 00       	jmp    89c <printf+0x177>
      } else {
        putc(fd, c);
 775:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 778:	0f be c0             	movsbl %al,%eax
 77b:	83 ec 08             	sub    $0x8,%esp
 77e:	50                   	push   %eax
 77f:	ff 75 08             	push   0x8(%ebp)
 782:	e8 ca fe ff ff       	call   651 <putc>
 787:	83 c4 10             	add    $0x10,%esp
 78a:	e9 0d 01 00 00       	jmp    89c <printf+0x177>
      }
    } else if(state == '%'){
 78f:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 793:	0f 85 03 01 00 00    	jne    89c <printf+0x177>
      if(c == 'd'){
 799:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 79d:	75 1e                	jne    7bd <printf+0x98>
        printint(fd, *ap, 10, 1);
 79f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	6a 01                	push   $0x1
 7a6:	6a 0a                	push   $0xa
 7a8:	50                   	push   %eax
 7a9:	ff 75 08             	push   0x8(%ebp)
 7ac:	e8 c3 fe ff ff       	call   674 <printint>
 7b1:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b8:	e9 d8 00 00 00       	jmp    895 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7bd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7c1:	74 06                	je     7c9 <printf+0xa4>
 7c3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7c7:	75 1e                	jne    7e7 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	6a 00                	push   $0x0
 7d0:	6a 10                	push   $0x10
 7d2:	50                   	push   %eax
 7d3:	ff 75 08             	push   0x8(%ebp)
 7d6:	e8 99 fe ff ff       	call   674 <printint>
 7db:	83 c4 10             	add    $0x10,%esp
        ap++;
 7de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e2:	e9 ae 00 00 00       	jmp    895 <printf+0x170>
      } else if(c == 's'){
 7e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7eb:	75 43                	jne    830 <printf+0x10b>
        s = (char*)*ap;
 7ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fd:	75 25                	jne    824 <printf+0xff>
          s = "(null)";
 7ff:	c7 45 f4 26 0b 00 00 	movl   $0xb26,-0xc(%ebp)
        while(*s != 0){
 806:	eb 1c                	jmp    824 <printf+0xff>
          putc(fd, *s);
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	0f b6 00             	movzbl (%eax),%eax
 80e:	0f be c0             	movsbl %al,%eax
 811:	83 ec 08             	sub    $0x8,%esp
 814:	50                   	push   %eax
 815:	ff 75 08             	push   0x8(%ebp)
 818:	e8 34 fe ff ff       	call   651 <putc>
 81d:	83 c4 10             	add    $0x10,%esp
          s++;
 820:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 824:	8b 45 f4             	mov    -0xc(%ebp),%eax
 827:	0f b6 00             	movzbl (%eax),%eax
 82a:	84 c0                	test   %al,%al
 82c:	75 da                	jne    808 <printf+0xe3>
 82e:	eb 65                	jmp    895 <printf+0x170>
        }
      } else if(c == 'c'){
 830:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 834:	75 1d                	jne    853 <printf+0x12e>
        putc(fd, *ap);
 836:	8b 45 e8             	mov    -0x18(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	0f be c0             	movsbl %al,%eax
 83e:	83 ec 08             	sub    $0x8,%esp
 841:	50                   	push   %eax
 842:	ff 75 08             	push   0x8(%ebp)
 845:	e8 07 fe ff ff       	call   651 <putc>
 84a:	83 c4 10             	add    $0x10,%esp
        ap++;
 84d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 851:	eb 42                	jmp    895 <printf+0x170>
      } else if(c == '%'){
 853:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 857:	75 17                	jne    870 <printf+0x14b>
        putc(fd, c);
 859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85c:	0f be c0             	movsbl %al,%eax
 85f:	83 ec 08             	sub    $0x8,%esp
 862:	50                   	push   %eax
 863:	ff 75 08             	push   0x8(%ebp)
 866:	e8 e6 fd ff ff       	call   651 <putc>
 86b:	83 c4 10             	add    $0x10,%esp
 86e:	eb 25                	jmp    895 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 870:	83 ec 08             	sub    $0x8,%esp
 873:	6a 25                	push   $0x25
 875:	ff 75 08             	push   0x8(%ebp)
 878:	e8 d4 fd ff ff       	call   651 <putc>
 87d:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 883:	0f be c0             	movsbl %al,%eax
 886:	83 ec 08             	sub    $0x8,%esp
 889:	50                   	push   %eax
 88a:	ff 75 08             	push   0x8(%ebp)
 88d:	e8 bf fd ff ff       	call   651 <putc>
 892:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 895:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 89c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a0:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a6:	01 d0                	add    %edx,%eax
 8a8:	0f b6 00             	movzbl (%eax),%eax
 8ab:	84 c0                	test   %al,%al
 8ad:	0f 85 94 fe ff ff    	jne    747 <printf+0x22>
    }
  }
}
 8b3:	90                   	nop
 8b4:	90                   	nop
 8b5:	c9                   	leave  
 8b6:	c3                   	ret    

000008b7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b7:	55                   	push   %ebp
 8b8:	89 e5                	mov    %esp,%ebp
 8ba:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8bd:	8b 45 08             	mov    0x8(%ebp),%eax
 8c0:	83 e8 08             	sub    $0x8,%eax
 8c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c6:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 8cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ce:	eb 24                	jmp    8f4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d3:	8b 00                	mov    (%eax),%eax
 8d5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8d8:	72 12                	jb     8ec <free+0x35>
 8da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e0:	77 24                	ja     906 <free+0x4f>
 8e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e5:	8b 00                	mov    (%eax),%eax
 8e7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ea:	72 1a                	jb     906 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ef:	8b 00                	mov    (%eax),%eax
 8f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fa:	76 d4                	jbe    8d0 <free+0x19>
 8fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 904:	73 ca                	jae    8d0 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	8b 40 04             	mov    0x4(%eax),%eax
 90c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	01 c2                	add    %eax,%edx
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	39 c2                	cmp    %eax,%edx
 91f:	75 24                	jne    945 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 921:	8b 45 f8             	mov    -0x8(%ebp),%eax
 924:	8b 50 04             	mov    0x4(%eax),%edx
 927:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92a:	8b 00                	mov    (%eax),%eax
 92c:	8b 40 04             	mov    0x4(%eax),%eax
 92f:	01 c2                	add    %eax,%edx
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	8b 00                	mov    (%eax),%eax
 93c:	8b 10                	mov    (%eax),%edx
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	89 10                	mov    %edx,(%eax)
 943:	eb 0a                	jmp    94f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 10                	mov    (%eax),%edx
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	01 d0                	add    %edx,%eax
 961:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 964:	75 20                	jne    986 <free+0xcf>
    p->s.size += bp->s.size;
 966:	8b 45 fc             	mov    -0x4(%ebp),%eax
 969:	8b 50 04             	mov    0x4(%eax),%edx
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	8b 40 04             	mov    0x4(%eax),%eax
 972:	01 c2                	add    %eax,%edx
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97d:	8b 10                	mov    (%eax),%edx
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	89 10                	mov    %edx,(%eax)
 984:	eb 08                	jmp    98e <free+0xd7>
  } else
    p->s.ptr = bp;
 986:	8b 45 fc             	mov    -0x4(%ebp),%eax
 989:	8b 55 f8             	mov    -0x8(%ebp),%edx
 98c:	89 10                	mov    %edx,(%eax)
  freep = p;
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	a3 f8 0d 00 00       	mov    %eax,0xdf8
}
 996:	90                   	nop
 997:	c9                   	leave  
 998:	c3                   	ret    

00000999 <morecore>:

static Header*
morecore(uint nu)
{
 999:	55                   	push   %ebp
 99a:	89 e5                	mov    %esp,%ebp
 99c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 99f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9a6:	77 07                	ja     9af <morecore+0x16>
    nu = 4096;
 9a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9af:	8b 45 08             	mov    0x8(%ebp),%eax
 9b2:	c1 e0 03             	shl    $0x3,%eax
 9b5:	83 ec 0c             	sub    $0xc,%esp
 9b8:	50                   	push   %eax
 9b9:	e8 63 fc ff ff       	call   621 <sbrk>
 9be:	83 c4 10             	add    $0x10,%esp
 9c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9c8:	75 07                	jne    9d1 <morecore+0x38>
    return 0;
 9ca:	b8 00 00 00 00       	mov    $0x0,%eax
 9cf:	eb 26                	jmp    9f7 <morecore+0x5e>
  hp = (Header*)p;
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9da:	8b 55 08             	mov    0x8(%ebp),%edx
 9dd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e3:	83 c0 08             	add    $0x8,%eax
 9e6:	83 ec 0c             	sub    $0xc,%esp
 9e9:	50                   	push   %eax
 9ea:	e8 c8 fe ff ff       	call   8b7 <free>
 9ef:	83 c4 10             	add    $0x10,%esp
  return freep;
 9f2:	a1 f8 0d 00 00       	mov    0xdf8,%eax
}
 9f7:	c9                   	leave  
 9f8:	c3                   	ret    

000009f9 <malloc>:

void*
malloc(uint nbytes)
{
 9f9:	55                   	push   %ebp
 9fa:	89 e5                	mov    %esp,%ebp
 9fc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ff:	8b 45 08             	mov    0x8(%ebp),%eax
 a02:	83 c0 07             	add    $0x7,%eax
 a05:	c1 e8 03             	shr    $0x3,%eax
 a08:	83 c0 01             	add    $0x1,%eax
 a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a0e:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a1a:	75 23                	jne    a3f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a1c:	c7 45 f0 f0 0d 00 00 	movl   $0xdf0,-0x10(%ebp)
 a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a26:	a3 f8 0d 00 00       	mov    %eax,0xdf8
 a2b:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 a30:	a3 f0 0d 00 00       	mov    %eax,0xdf0
    base.s.size = 0;
 a35:	c7 05 f4 0d 00 00 00 	movl   $0x0,0xdf4
 a3c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a42:	8b 00                	mov    (%eax),%eax
 a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4a:	8b 40 04             	mov    0x4(%eax),%eax
 a4d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a50:	77 4d                	ja     a9f <malloc+0xa6>
      if(p->s.size == nunits)
 a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a55:	8b 40 04             	mov    0x4(%eax),%eax
 a58:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a5b:	75 0c                	jne    a69 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a60:	8b 10                	mov    (%eax),%edx
 a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a65:	89 10                	mov    %edx,(%eax)
 a67:	eb 26                	jmp    a8f <malloc+0x96>
      else {
        p->s.size -= nunits;
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	8b 40 04             	mov    0x4(%eax),%eax
 a6f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a72:	89 c2                	mov    %eax,%edx
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7d:	8b 40 04             	mov    0x4(%eax),%eax
 a80:	c1 e0 03             	shl    $0x3,%eax
 a83:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a89:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a8c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a92:	a3 f8 0d 00 00       	mov    %eax,0xdf8
      return (void*)(p + 1);
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	83 c0 08             	add    $0x8,%eax
 a9d:	eb 3b                	jmp    ada <malloc+0xe1>
    }
    if(p == freep)
 a9f:	a1 f8 0d 00 00       	mov    0xdf8,%eax
 aa4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aa7:	75 1e                	jne    ac7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 aa9:	83 ec 0c             	sub    $0xc,%esp
 aac:	ff 75 ec             	push   -0x14(%ebp)
 aaf:	e8 e5 fe ff ff       	call   999 <morecore>
 ab4:	83 c4 10             	add    $0x10,%esp
 ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 abe:	75 07                	jne    ac7 <malloc+0xce>
        return 0;
 ac0:	b8 00 00 00 00       	mov    $0x0,%eax
 ac5:	eb 13                	jmp    ada <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
 acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad0:	8b 00                	mov    (%eax),%eax
 ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ad5:	e9 6d ff ff ff       	jmp    a47 <malloc+0x4e>
  }
}
 ada:	c9                   	leave  
 adb:	c3                   	ret    
