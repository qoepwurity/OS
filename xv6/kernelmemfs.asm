
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
80100010:	66 b8 10 00          	mov    $0x10,%ax
80100014:	8e d8                	mov    %eax,%ds
80100016:	8e c0                	mov    %eax,%es
80100018:	8e d0                	mov    %eax,%ss
8010001a:	66 b8 00 00          	mov    $0x0,%ax
8010001e:	8e e0                	mov    %eax,%fs
80100020:	8e e8                	mov    %eax,%gs
80100022:	0f 20 c0             	mov    %cr0,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
8010002a:	0f 22 c0             	mov    %eax,%cr0
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
80100032:	0f 22 d8             	mov    %eax,%cr3
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
8010003a:	0f 32                	rdmsr  
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
80100041:	0f 30                	wrmsr  
80100043:	0f 20 e0             	mov    %cr4,%eax
80100046:	83 c8 10             	or     $0x10,%eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
8010004c:	0f 22 e0             	mov    %eax,%cr4
8010004f:	0f 20 c0             	mov    %cr0,%eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
80100057:	0f 22 c0             	mov    %eax,%cr0
8010005a:	bc 80 81 19 80       	mov    $0x80198180,%esp
8010005f:	ba 65 33 10 80       	mov    $0x80103365,%edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 60 a0 10 80       	push   $0x8010a060
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 69 46 00 00       	call   801046e7 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 67 a0 10 80       	push   $0x8010a067
801000c2:	50                   	push   %eax
801000c3:	e8 c2 44 00 00       	call   8010458a <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave  
801000f2:	c3                   	ret    

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 03 46 00 00       	call   80104709 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 32 46 00 00       	call   80104777 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 6f 44 00 00       	call   801045c6 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 b1 45 00 00       	call   80104777 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 ee 43 00 00       	call   801045c6 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 6e a0 10 80       	push   $0x8010a06e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave  
80100200:	c3                   	ret    

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 39 9d 00 00       	call   80109f6b <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave  
80100239:	c3                   	ret    

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 29 44 00 00       	call   80104678 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 7f a0 10 80       	push   $0x8010a07f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 ee 9c 00 00       	call   80109f6b <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave  
80100282:	c3                   	ret    

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 e0 43 00 00       	call   80104678 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 86 a0 10 80       	push   $0x8010a086
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 6f 43 00 00       	call   8010462a <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 3e 44 00 00       	call   80104709 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 3c 44 00 00       	call   80104777 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave  
80100340:	c3                   	ret    

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli    
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret    

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8c 03 00 00       	call   8010076f <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave  
801003f3:	c3                   	ret    

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 f4 42 00 00       	call   80104709 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 8d a0 10 80       	push   $0x8010a08d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 20 03 00 00       	call   8010076f <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 96 a0 10 80 	movl   $0x8010a096,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 44 02 00 00       	call   8010076f <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 27 02 00 00       	call   8010076f <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 18 02 00 00       	call   8010076f <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 0a 02 00 00       	call   8010076f <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 d4 41 00 00       	call   80104777 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave  
801005a8:	c3                   	ret    

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 37 25 00 00       	call   80102afa <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 9d a0 10 80       	push   $0x8010a09d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 b1 a0 10 80       	push   $0x8010a0b1
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c6 41 00 00       	call   801047c9 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 b3 a0 10 80       	push   $0x8010a0b3
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	eb fe                	jmp    8010063b <panic+0x92>

8010063d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063d:	55                   	push   %ebp
8010063e:	89 e5                	mov    %esp,%ebp
80100640:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100643:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100647:	75 64                	jne    801006ad <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100649:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010064f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100654:	89 c8                	mov    %ecx,%eax
80100656:	f7 ea                	imul   %edx
80100658:	89 d0                	mov    %edx,%eax
8010065a:	c1 f8 04             	sar    $0x4,%eax
8010065d:	89 ca                	mov    %ecx,%edx
8010065f:	c1 fa 1f             	sar    $0x1f,%edx
80100662:	29 d0                	sub    %edx,%eax
80100664:	6b d0 35             	imul   $0x35,%eax,%edx
80100667:	89 c8                	mov    %ecx,%eax
80100669:	29 d0                	sub    %edx,%eax
8010066b:	ba 35 00 00 00       	mov    $0x35,%edx
80100670:	29 c2                	sub    %eax,%edx
80100672:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100677:	01 d0                	add    %edx,%eax
80100679:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100683:	3d 23 04 00 00       	cmp    $0x423,%eax
80100688:	0f 8e de 00 00 00    	jle    8010076c <graphic_putc+0x12f>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100693:	83 e8 35             	sub    $0x35,%eax
80100696:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069b:	83 ec 0c             	sub    $0xc,%esp
8010069e:	6a 1e                	push   $0x1e
801006a0:	e8 1d 78 00 00       	call   80107ec2 <graphic_scroll_up>
801006a5:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a8:	e9 bf 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
  }else if(c == BACKSPACE){
801006ad:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b4:	75 1f                	jne    801006d5 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bb:	85 c0                	test   %eax,%eax
801006bd:	0f 8e a9 00 00 00    	jle    8010076c <graphic_putc+0x12f>
801006c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c8:	83 e8 01             	sub    $0x1,%eax
801006cb:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d0:	e9 97 00 00 00       	jmp    8010076c <graphic_putc+0x12f>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d5:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006da:	3d 23 04 00 00       	cmp    $0x423,%eax
801006df:	7e 1a                	jle    801006fb <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e1:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e6:	83 e8 35             	sub    $0x35,%eax
801006e9:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ee:	83 ec 0c             	sub    $0xc,%esp
801006f1:	6a 1e                	push   $0x1e
801006f3:	e8 ca 77 00 00       	call   80107ec2 <graphic_scroll_up>
801006f8:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fb:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100701:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100706:	89 c8                	mov    %ecx,%eax
80100708:	f7 ea                	imul   %edx
8010070a:	89 d0                	mov    %edx,%eax
8010070c:	c1 f8 04             	sar    $0x4,%eax
8010070f:	89 ca                	mov    %ecx,%edx
80100711:	c1 fa 1f             	sar    $0x1f,%edx
80100714:	29 d0                	sub    %edx,%eax
80100716:	6b d0 35             	imul   $0x35,%eax,%edx
80100719:	89 c8                	mov    %ecx,%eax
8010071b:	29 d0                	sub    %edx,%eax
8010071d:	89 c2                	mov    %eax,%edx
8010071f:	c1 e2 04             	shl    $0x4,%edx
80100722:	29 c2                	sub    %eax,%edx
80100724:	8d 42 02             	lea    0x2(%edx),%eax
80100727:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100730:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100735:	89 c8                	mov    %ecx,%eax
80100737:	f7 ea                	imul   %edx
80100739:	89 d0                	mov    %edx,%eax
8010073b:	c1 f8 04             	sar    $0x4,%eax
8010073e:	c1 f9 1f             	sar    $0x1f,%ecx
80100741:	89 ca                	mov    %ecx,%edx
80100743:	29 d0                	sub    %edx,%eax
80100745:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074b:	83 ec 04             	sub    $0x4,%esp
8010074e:	ff 75 08             	push   0x8(%ebp)
80100751:	ff 75 f0             	push   -0x10(%ebp)
80100754:	ff 75 f4             	push   -0xc(%ebp)
80100757:	e8 d1 77 00 00       	call   80107f2d <font_render>
8010075c:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100764:	83 c0 01             	add    $0x1,%eax
80100767:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076c:	90                   	nop
8010076d:	c9                   	leave  
8010076e:	c3                   	ret    

8010076f <consputc>:


void
consputc(int c)
{
8010076f:	55                   	push   %ebp
80100770:	89 e5                	mov    %esp,%ebp
80100772:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100775:	a1 ec 19 19 80       	mov    0x801919ec,%eax
8010077a:	85 c0                	test   %eax,%eax
8010077c:	74 07                	je     80100785 <consputc+0x16>
    cli();
8010077e:	e8 be fb ff ff       	call   80100341 <cli>
    for(;;)
80100783:	eb fe                	jmp    80100783 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 a1 5b 00 00       	call   80106339 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 94 5b 00 00       	call   80106339 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 87 5b 00 00       	call   80106339 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x56>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 77 5b 00 00       	call   80106339 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6d fe ff ff       	call   8010063d <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave  
801007d5:	c3                   	ret    

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 19 3f 00 00       	call   80104709 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 50 01 00 00       	jmp    80100948 <consoleintr+0x172>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 10 01 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1d ff ff ff       	call   8010076f <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e0 00 00 00    	je     80100948 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c5 00 00 00       	jmp    80100948 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b2 00 00 00    	je     80100948 <consoleintr+0x172>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 bf fe ff ff       	call   8010076f <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 90 00 00 00       	jmp    80100948 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 85 00 00 00    	je     80100947 <consoleintr+0x171>
801008c2:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008c7:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801008cd:	29 d0                	sub    %edx,%eax
801008cf:	83 f8 7f             	cmp    $0x7f,%eax
801008d2:	77 73                	ja     80100947 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 63 fe ff ff       	call   8010076f <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100920:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100926:	83 ea 80             	sub    $0xffffff80,%edx
80100929:	39 d0                	cmp    %edx,%eax
8010092b:	75 1a                	jne    80100947 <consoleintr+0x171>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 8b 3a 00 00       	call   801043cf <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	90                   	nop
  while((c = getc()) >= 0){
80100948:	8b 45 08             	mov    0x8(%ebp),%eax
8010094b:	ff d0                	call   *%eax
8010094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100954:	0f 89 9e fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010095a:	83 ec 0c             	sub    $0xc,%esp
8010095d:	68 00 1a 19 80       	push   $0x80191a00
80100962:	e8 10 3e 00 00       	call   80104777 <release>
80100967:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010096a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010096e:	74 05                	je     80100975 <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
80100970:	e8 18 3b 00 00       	call   8010448d <procdump>
  }
}
80100975:	90                   	nop
80100976:	c9                   	leave  
80100977:	c3                   	ret    

80100978 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100978:	55                   	push   %ebp
80100979:	89 e5                	mov    %esp,%ebp
8010097b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010097e:	83 ec 0c             	sub    $0xc,%esp
80100981:	ff 75 08             	push   0x8(%ebp)
80100984:	e8 74 11 00 00       	call   80101afd <iunlock>
80100989:	83 c4 10             	add    $0x10,%esp
  target = n;
8010098c:	8b 45 10             	mov    0x10(%ebp),%eax
8010098f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100992:	83 ec 0c             	sub    $0xc,%esp
80100995:	68 00 1a 19 80       	push   $0x80191a00
8010099a:	e8 6a 3d 00 00       	call   80104709 <acquire>
8010099f:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009a2:	e9 ab 00 00 00       	jmp    80100a52 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009a7:	e8 84 30 00 00       	call   80103a30 <myproc>
801009ac:	8b 40 24             	mov    0x24(%eax),%eax
801009af:	85 c0                	test   %eax,%eax
801009b1:	74 28                	je     801009db <consoleread+0x63>
        release(&cons.lock);
801009b3:	83 ec 0c             	sub    $0xc,%esp
801009b6:	68 00 1a 19 80       	push   $0x80191a00
801009bb:	e8 b7 3d 00 00       	call   80104777 <release>
801009c0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009c3:	83 ec 0c             	sub    $0xc,%esp
801009c6:	ff 75 08             	push   0x8(%ebp)
801009c9:	e8 1c 10 00 00       	call   801019ea <ilock>
801009ce:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009d6:	e9 a9 00 00 00       	jmp    80100a84 <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
801009db:	83 ec 08             	sub    $0x8,%esp
801009de:	68 00 1a 19 80       	push   $0x80191a00
801009e3:	68 e0 19 19 80       	push   $0x801919e0
801009e8:	e8 f8 38 00 00       	call   801042e5 <sleep>
801009ed:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f0:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009f6:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801009fb:	39 c2                	cmp    %eax,%edx
801009fd:	74 a8                	je     801009a7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009ff:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a04:	8d 50 01             	lea    0x1(%eax),%edx
80100a07:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a0d:	83 e0 7f             	and    $0x7f,%eax
80100a10:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a17:	0f be c0             	movsbl %al,%eax
80100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a1d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a21:	75 17                	jne    80100a3a <consoleread+0xc2>
      if(n < target){
80100a23:	8b 45 10             	mov    0x10(%ebp),%eax
80100a26:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a29:	76 2f                	jbe    80100a5a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a2b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a30:	83 e8 01             	sub    $0x1,%eax
80100a33:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a38:	eb 20                	jmp    80100a5a <consoleread+0xe2>
    }
    *dst++ = c;
80100a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a3d:	8d 50 01             	lea    0x1(%eax),%edx
80100a40:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a43:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a46:	88 10                	mov    %dl,(%eax)
    --n;
80100a48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a4c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a50:	74 0b                	je     80100a5d <consoleread+0xe5>
  while(n > 0){
80100a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a56:	7f 98                	jg     801009f0 <consoleread+0x78>
80100a58:	eb 04                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5a:	90                   	nop
80100a5b:	eb 01                	jmp    80100a5e <consoleread+0xe6>
      break;
80100a5d:	90                   	nop
  }
  release(&cons.lock);
80100a5e:	83 ec 0c             	sub    $0xc,%esp
80100a61:	68 00 1a 19 80       	push   $0x80191a00
80100a66:	e8 0c 3d 00 00       	call   80104777 <release>
80100a6b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	ff 75 08             	push   0x8(%ebp)
80100a74:	e8 71 0f 00 00       	call   801019ea <ilock>
80100a79:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a7c:	8b 55 10             	mov    0x10(%ebp),%edx
80100a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a82:	29 d0                	sub    %edx,%eax
}
80100a84:	c9                   	leave  
80100a85:	c3                   	ret    

80100a86 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a86:	55                   	push   %ebp
80100a87:	89 e5                	mov    %esp,%ebp
80100a89:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a8c:	83 ec 0c             	sub    $0xc,%esp
80100a8f:	ff 75 08             	push   0x8(%ebp)
80100a92:	e8 66 10 00 00       	call   80101afd <iunlock>
80100a97:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a9a:	83 ec 0c             	sub    $0xc,%esp
80100a9d:	68 00 1a 19 80       	push   $0x80191a00
80100aa2:	e8 62 3c 00 00       	call   80104709 <acquire>
80100aa7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ab1:	eb 21                	jmp    80100ad4 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab9:	01 d0                	add    %edx,%eax
80100abb:	0f b6 00             	movzbl (%eax),%eax
80100abe:	0f be c0             	movsbl %al,%eax
80100ac1:	0f b6 c0             	movzbl %al,%eax
80100ac4:	83 ec 0c             	sub    $0xc,%esp
80100ac7:	50                   	push   %eax
80100ac8:	e8 a2 fc ff ff       	call   8010076f <consputc>
80100acd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ad0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ad7:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ada:	7c d7                	jl     80100ab3 <consolewrite+0x2d>
  release(&cons.lock);
80100adc:	83 ec 0c             	sub    $0xc,%esp
80100adf:	68 00 1a 19 80       	push   $0x80191a00
80100ae4:	e8 8e 3c 00 00       	call   80104777 <release>
80100ae9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aec:	83 ec 0c             	sub    $0xc,%esp
80100aef:	ff 75 08             	push   0x8(%ebp)
80100af2:	e8 f3 0e 00 00       	call   801019ea <ilock>
80100af7:	83 c4 10             	add    $0x10,%esp

  return n;
80100afa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consoleinit>:

void
consoleinit(void)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b05:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b0c:	00 00 00 
  initlock(&cons.lock, "console");
80100b0f:	83 ec 08             	sub    $0x8,%esp
80100b12:	68 b7 a0 10 80       	push   $0x8010a0b7
80100b17:	68 00 1a 19 80       	push   $0x80191a00
80100b1c:	e8 c6 3b 00 00       	call   801046e7 <initlock>
80100b21:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b24:	c7 05 4c 1a 19 80 86 	movl   $0x80100a86,0x80191a4c
80100b2b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b2e:	c7 05 48 1a 19 80 78 	movl   $0x80100978,0x80191a48
80100b35:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b38:	c7 45 f4 bf a0 10 80 	movl   $0x8010a0bf,-0xc(%ebp)
80100b3f:	eb 19                	jmp    80100b5a <consoleinit+0x5b>
    graphic_putc(*p);
80100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b44:	0f b6 00             	movzbl (%eax),%eax
80100b47:	0f be c0             	movsbl %al,%eax
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	50                   	push   %eax
80100b4e:	e8 ea fa ff ff       	call   8010063d <graphic_putc>
80100b53:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b56:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b5d:	0f b6 00             	movzbl (%eax),%eax
80100b60:	84 c0                	test   %al,%al
80100b62:	75 dd                	jne    80100b41 <consoleinit+0x42>
  
  cons.locking = 1;
80100b64:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b6b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b6e:	83 ec 08             	sub    $0x8,%esp
80100b71:	6a 00                	push   $0x0
80100b73:	6a 01                	push   $0x1
80100b75:	e8 b4 1a 00 00       	call   8010262e <ioapicenable>
80100b7a:	83 c4 10             	add    $0x10,%esp
}
80100b7d:	90                   	nop
80100b7e:	c9                   	leave  
80100b7f:	c3                   	ret    

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b89:	e8 a2 2e 00 00       	call   80103a30 <myproc>
80100b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b91:	e8 a6 24 00 00       	call   8010303c <begin_op>

  if((ip = namei(path)) == 0){
80100b96:	83 ec 0c             	sub    $0xc,%esp
80100b99:	ff 75 08             	push   0x8(%ebp)
80100b9c:	e8 7c 19 00 00       	call   8010251d <namei>
80100ba1:	83 c4 10             	add    $0x10,%esp
80100ba4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ba7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bab:	75 1f                	jne    80100bcc <exec+0x4c>
    end_op();
80100bad:	e8 16 25 00 00       	call   801030c8 <end_op>
    cprintf("exec: fail\n");
80100bb2:	83 ec 0c             	sub    $0xc,%esp
80100bb5:	68 d5 a0 10 80       	push   $0x8010a0d5
80100bba:	e8 35 f8 ff ff       	call   801003f4 <cprintf>
80100bbf:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bc7:	e9 f1 03 00 00       	jmp    80100fbd <exec+0x43d>
  }
  ilock(ip);
80100bcc:	83 ec 0c             	sub    $0xc,%esp
80100bcf:	ff 75 d8             	push   -0x28(%ebp)
80100bd2:	e8 13 0e 00 00       	call   801019ea <ilock>
80100bd7:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bda:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100be1:	6a 34                	push   $0x34
80100be3:	6a 00                	push   $0x0
80100be5:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100beb:	50                   	push   %eax
80100bec:	ff 75 d8             	push   -0x28(%ebp)
80100bef:	e8 e2 12 00 00       	call   80101ed6 <readi>
80100bf4:	83 c4 10             	add    $0x10,%esp
80100bf7:	83 f8 34             	cmp    $0x34,%eax
80100bfa:	0f 85 66 03 00 00    	jne    80100f66 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c00:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c06:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c0b:	0f 85 58 03 00 00    	jne    80100f69 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c11:	e8 1f 67 00 00       	call   80107335 <setupkvm>
80100c16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c19:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c1d:	0f 84 49 03 00 00    	je     80100f6c <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c23:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c31:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c37:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c3a:	e9 de 00 00 00       	jmp    80100d1d <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c42:	6a 20                	push   $0x20
80100c44:	50                   	push   %eax
80100c45:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c4b:	50                   	push   %eax
80100c4c:	ff 75 d8             	push   -0x28(%ebp)
80100c4f:	e8 82 12 00 00       	call   80101ed6 <readi>
80100c54:	83 c4 10             	add    $0x10,%esp
80100c57:	83 f8 20             	cmp    $0x20,%eax
80100c5a:	0f 85 0f 03 00 00    	jne    80100f6f <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c60:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c66:	83 f8 01             	cmp    $0x1,%eax
80100c69:	0f 85 a0 00 00 00    	jne    80100d0f <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c6f:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c75:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c7b:	39 c2                	cmp    %eax,%edx
80100c7d:	0f 82 ef 02 00 00    	jb     80100f72 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c83:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c89:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c8f:	01 c2                	add    %eax,%edx
80100c91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c97:	39 c2                	cmp    %eax,%edx
80100c99:	0f 82 d6 02 00 00    	jb     80100f75 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c9f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ca5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cab:	01 d0                	add    %edx,%eax
80100cad:	83 ec 04             	sub    $0x4,%esp
80100cb0:	50                   	push   %eax
80100cb1:	ff 75 e0             	push   -0x20(%ebp)
80100cb4:	ff 75 d4             	push   -0x2c(%ebp)
80100cb7:	e8 72 6a 00 00       	call   8010772e <allocuvm>
80100cbc:	83 c4 10             	add    $0x10,%esp
80100cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc6:	0f 84 ac 02 00 00    	je     80100f78 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100ccc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cd7:	85 c0                	test   %eax,%eax
80100cd9:	0f 85 9c 02 00 00    	jne    80100f7b <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cdf:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100ce5:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ceb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cf1:	83 ec 0c             	sub    $0xc,%esp
80100cf4:	52                   	push   %edx
80100cf5:	50                   	push   %eax
80100cf6:	ff 75 d8             	push   -0x28(%ebp)
80100cf9:	51                   	push   %ecx
80100cfa:	ff 75 d4             	push   -0x2c(%ebp)
80100cfd:	e8 5f 69 00 00       	call   80107661 <loaduvm>
80100d02:	83 c4 20             	add    $0x20,%esp
80100d05:	85 c0                	test   %eax,%eax
80100d07:	0f 88 71 02 00 00    	js     80100f7e <exec+0x3fe>
80100d0d:	eb 01                	jmp    80100d10 <exec+0x190>
      continue;
80100d0f:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d10:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d17:	83 c0 20             	add    $0x20,%eax
80100d1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d1d:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d24:	0f b7 c0             	movzwl %ax,%eax
80100d27:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d2a:	0f 8c 0f ff ff ff    	jl     80100c3f <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d30:	83 ec 0c             	sub    $0xc,%esp
80100d33:	ff 75 d8             	push   -0x28(%ebp)
80100d36:	e8 e0 0e 00 00       	call   80101c1b <iunlockput>
80100d3b:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d3e:	e8 85 23 00 00       	call   801030c8 <end_op>
  ip = 0;
80100d43:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d4d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d57:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5d:	05 00 20 00 00       	add    $0x2000,%eax
80100d62:	83 ec 04             	sub    $0x4,%esp
80100d65:	50                   	push   %eax
80100d66:	ff 75 e0             	push   -0x20(%ebp)
80100d69:	ff 75 d4             	push   -0x2c(%ebp)
80100d6c:	e8 bd 69 00 00       	call   8010772e <allocuvm>
80100d71:	83 c4 10             	add    $0x10,%esp
80100d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7b:	0f 84 00 02 00 00    	je     80100f81 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d84:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d89:	83 ec 08             	sub    $0x8,%esp
80100d8c:	50                   	push   %eax
80100d8d:	ff 75 d4             	push   -0x2c(%ebp)
80100d90:	e8 fb 6b 00 00       	call   80107990 <clearpteu>
80100d95:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100da5:	e9 96 00 00 00       	jmp    80100e40 <exec+0x2c0>
    if(argc >= MAXARG)
80100daa:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dae:	0f 87 d0 01 00 00    	ja     80100f84 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 ff 3d 00 00       	call   80104bcd <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	89 c2                	mov    %eax,%edx
80100dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd6:	29 d0                	sub    %edx,%eax
80100dd8:	83 e8 01             	sub    $0x1,%eax
80100ddb:	83 e0 fc             	and    $0xfffffffc,%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dee:	01 d0                	add    %edx,%eax
80100df0:	8b 00                	mov    (%eax),%eax
80100df2:	83 ec 0c             	sub    $0xc,%esp
80100df5:	50                   	push   %eax
80100df6:	e8 d2 3d 00 00       	call   80104bcd <strlen>
80100dfb:	83 c4 10             	add    $0x10,%esp
80100dfe:	83 c0 01             	add    $0x1,%eax
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e10:	01 c8                	add    %ecx,%eax
80100e12:	8b 00                	mov    (%eax),%eax
80100e14:	52                   	push   %edx
80100e15:	50                   	push   %eax
80100e16:	ff 75 dc             	push   -0x24(%ebp)
80100e19:	ff 75 d4             	push   -0x2c(%ebp)
80100e1c:	e8 0e 6d 00 00       	call   80107b2f <copyout>
80100e21:	83 c4 10             	add    $0x10,%esp
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 88 5b 01 00 00    	js     80100f87 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 50 03             	lea    0x3(%eax),%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e3c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	85 c0                	test   %eax,%eax
80100e53:	0f 85 51 ff ff ff    	jne    80100daa <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	83 c0 03             	add    $0x3,%eax
80100e5f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e66:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e6a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e71:	ff ff ff 
  ustack[1] = argc;
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	83 c0 01             	add    $0x1,%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	29 d0                	sub    %edx,%eax
80100e8f:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	83 c0 04             	add    $0x4,%eax
80100e9b:	c1 e0 02             	shl    $0x2,%eax
80100e9e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea4:	83 c0 04             	add    $0x4,%eax
80100ea7:	c1 e0 02             	shl    $0x2,%eax
80100eaa:	50                   	push   %eax
80100eab:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eb1:	50                   	push   %eax
80100eb2:	ff 75 dc             	push   -0x24(%ebp)
80100eb5:	ff 75 d4             	push   -0x2c(%ebp)
80100eb8:	e8 72 6c 00 00       	call   80107b2f <copyout>
80100ebd:	83 c4 10             	add    $0x10,%esp
80100ec0:	85 c0                	test   %eax,%eax
80100ec2:	0f 88 c2 00 00 00    	js     80100f8a <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ed4:	eb 17                	jmp    80100eed <exec+0x36d>
    if(*s == '/')
80100ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ed9:	0f b6 00             	movzbl (%eax),%eax
80100edc:	3c 2f                	cmp    $0x2f,%al
80100ede:	75 09                	jne    80100ee9 <exec+0x369>
      last = s+1;
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	83 c0 01             	add    $0x1,%eax
80100ee6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ee9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	0f b6 00             	movzbl (%eax),%eax
80100ef3:	84 c0                	test   %al,%al
80100ef5:	75 df                	jne    80100ed6 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ef7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100efa:	83 c0 6c             	add    $0x6c,%eax
80100efd:	83 ec 04             	sub    $0x4,%esp
80100f00:	6a 10                	push   $0x10
80100f02:	ff 75 f0             	push   -0x10(%ebp)
80100f05:	50                   	push   %eax
80100f06:	e8 77 3c 00 00       	call   80104b82 <safestrcpy>
80100f0b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f11:	8b 40 04             	mov    0x4(%eax),%eax
80100f14:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f17:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f1d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f23:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f26:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2b:	8b 40 18             	mov    0x18(%eax),%eax
80100f2e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f34:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3a:	8b 40 18             	mov    0x18(%eax),%eax
80100f3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f40:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f43:	83 ec 0c             	sub    $0xc,%esp
80100f46:	ff 75 d0             	push   -0x30(%ebp)
80100f49:	e8 04 65 00 00       	call   80107452 <switchuvm>
80100f4e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f51:	83 ec 0c             	sub    $0xc,%esp
80100f54:	ff 75 cc             	push   -0x34(%ebp)
80100f57:	e8 9b 69 00 00       	call   801078f7 <freevm>
80100f5c:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f5f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f64:	eb 57                	jmp    80100fbd <exec+0x43d>
    goto bad;
80100f66:	90                   	nop
80100f67:	eb 22                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f69:	90                   	nop
80100f6a:	eb 1f                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f6c:	90                   	nop
80100f6d:	eb 1c                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f6f:	90                   	nop
80100f70:	eb 19                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f72:	90                   	nop
80100f73:	eb 16                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f75:	90                   	nop
80100f76:	eb 13                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f78:	90                   	nop
80100f79:	eb 10                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7b:	90                   	nop
80100f7c:	eb 0d                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f7e:	90                   	nop
80100f7f:	eb 0a                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f81:	90                   	nop
80100f82:	eb 07                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f84:	90                   	nop
80100f85:	eb 04                	jmp    80100f8b <exec+0x40b>
      goto bad;
80100f87:	90                   	nop
80100f88:	eb 01                	jmp    80100f8b <exec+0x40b>
    goto bad;
80100f8a:	90                   	nop

 bad:
  if(pgdir)
80100f8b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f8f:	74 0e                	je     80100f9f <exec+0x41f>
    freevm(pgdir);
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	ff 75 d4             	push   -0x2c(%ebp)
80100f97:	e8 5b 69 00 00       	call   801078f7 <freevm>
80100f9c:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f9f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fa3:	74 13                	je     80100fb8 <exec+0x438>
    iunlockput(ip);
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	ff 75 d8             	push   -0x28(%ebp)
80100fab:	e8 6b 0c 00 00       	call   80101c1b <iunlockput>
80100fb0:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fb3:	e8 10 21 00 00       	call   801030c8 <end_op>
  }
  return -1;
80100fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fbd:	c9                   	leave  
80100fbe:	c3                   	ret    

80100fbf <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fbf:	55                   	push   %ebp
80100fc0:	89 e5                	mov    %esp,%ebp
80100fc2:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fc5:	83 ec 08             	sub    $0x8,%esp
80100fc8:	68 e1 a0 10 80       	push   $0x8010a0e1
80100fcd:	68 a0 1a 19 80       	push   $0x80191aa0
80100fd2:	e8 10 37 00 00       	call   801046e7 <initlock>
80100fd7:	83 c4 10             	add    $0x10,%esp
}
80100fda:	90                   	nop
80100fdb:	c9                   	leave  
80100fdc:	c3                   	ret    

80100fdd <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fdd:	55                   	push   %ebp
80100fde:	89 e5                	mov    %esp,%ebp
80100fe0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	68 a0 1a 19 80       	push   $0x80191aa0
80100feb:	e8 19 37 00 00       	call   80104709 <acquire>
80100ff0:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ff3:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80100ffa:	eb 2d                	jmp    80101029 <filealloc+0x4c>
    if(f->ref == 0){
80100ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fff:	8b 40 04             	mov    0x4(%eax),%eax
80101002:	85 c0                	test   %eax,%eax
80101004:	75 1f                	jne    80101025 <filealloc+0x48>
      f->ref = 1;
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	68 a0 1a 19 80       	push   $0x80191aa0
80101018:	e8 5a 37 00 00       	call   80104777 <release>
8010101d:	83 c4 10             	add    $0x10,%esp
      return f;
80101020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101023:	eb 23                	jmp    80101048 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101025:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101029:	b8 34 24 19 80       	mov    $0x80192434,%eax
8010102e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101031:	72 c9                	jb     80100ffc <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 a0 1a 19 80       	push   $0x80191aa0
8010103b:	e8 37 37 00 00       	call   80104777 <release>
80101040:	83 c4 10             	add    $0x10,%esp
  return 0;
80101043:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101048:	c9                   	leave  
80101049:	c3                   	ret    

8010104a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010104a:	55                   	push   %ebp
8010104b:	89 e5                	mov    %esp,%ebp
8010104d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	68 a0 1a 19 80       	push   $0x80191aa0
80101058:	e8 ac 36 00 00       	call   80104709 <acquire>
8010105d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	8b 40 04             	mov    0x4(%eax),%eax
80101066:	85 c0                	test   %eax,%eax
80101068:	7f 0d                	jg     80101077 <filedup+0x2d>
    panic("filedup");
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 e8 a0 10 80       	push   $0x8010a0e8
80101072:	e8 32 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101077:	8b 45 08             	mov    0x8(%ebp),%eax
8010107a:	8b 40 04             	mov    0x4(%eax),%eax
8010107d:	8d 50 01             	lea    0x1(%eax),%edx
80101080:	8b 45 08             	mov    0x8(%ebp),%eax
80101083:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101086:	83 ec 0c             	sub    $0xc,%esp
80101089:	68 a0 1a 19 80       	push   $0x80191aa0
8010108e:	e8 e4 36 00 00       	call   80104777 <release>
80101093:	83 c4 10             	add    $0x10,%esp
  return f;
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101099:	c9                   	leave  
8010109a:	c3                   	ret    

8010109b <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010109b:	55                   	push   %ebp
8010109c:	89 e5                	mov    %esp,%ebp
8010109e:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010a1:	83 ec 0c             	sub    $0xc,%esp
801010a4:	68 a0 1a 19 80       	push   $0x80191aa0
801010a9:	e8 5b 36 00 00       	call   80104709 <acquire>
801010ae:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010b1:	8b 45 08             	mov    0x8(%ebp),%eax
801010b4:	8b 40 04             	mov    0x4(%eax),%eax
801010b7:	85 c0                	test   %eax,%eax
801010b9:	7f 0d                	jg     801010c8 <fileclose+0x2d>
    panic("fileclose");
801010bb:	83 ec 0c             	sub    $0xc,%esp
801010be:	68 f0 a0 10 80       	push   $0x8010a0f0
801010c3:	e8 e1 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801010d1:	8b 45 08             	mov    0x8(%ebp),%eax
801010d4:	89 50 04             	mov    %edx,0x4(%eax)
801010d7:	8b 45 08             	mov    0x8(%ebp),%eax
801010da:	8b 40 04             	mov    0x4(%eax),%eax
801010dd:	85 c0                	test   %eax,%eax
801010df:	7e 15                	jle    801010f6 <fileclose+0x5b>
    release(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 1a 19 80       	push   $0x80191aa0
801010e9:	e8 89 36 00 00       	call   80104777 <release>
801010ee:	83 c4 10             	add    $0x10,%esp
801010f1:	e9 8b 00 00 00       	jmp    80101181 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010f6:	8b 45 08             	mov    0x8(%ebp),%eax
801010f9:	8b 10                	mov    (%eax),%edx
801010fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010fe:	8b 50 04             	mov    0x4(%eax),%edx
80101101:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101104:	8b 50 08             	mov    0x8(%eax),%edx
80101107:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010110a:	8b 50 0c             	mov    0xc(%eax),%edx
8010110d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101110:	8b 50 10             	mov    0x10(%eax),%edx
80101113:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101116:	8b 40 14             	mov    0x14(%eax),%eax
80101119:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010111c:	8b 45 08             	mov    0x8(%ebp),%eax
8010111f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010112f:	83 ec 0c             	sub    $0xc,%esp
80101132:	68 a0 1a 19 80       	push   $0x80191aa0
80101137:	e8 3b 36 00 00       	call   80104777 <release>
8010113c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101142:	83 f8 01             	cmp    $0x1,%eax
80101145:	75 19                	jne    80101160 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101147:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010114b:	0f be d0             	movsbl %al,%edx
8010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101151:	83 ec 08             	sub    $0x8,%esp
80101154:	52                   	push   %edx
80101155:	50                   	push   %eax
80101156:	e8 64 25 00 00       	call   801036bf <pipeclose>
8010115b:	83 c4 10             	add    $0x10,%esp
8010115e:	eb 21                	jmp    80101181 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101160:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101163:	83 f8 02             	cmp    $0x2,%eax
80101166:	75 19                	jne    80101181 <fileclose+0xe6>
    begin_op();
80101168:	e8 cf 1e 00 00       	call   8010303c <begin_op>
    iput(ff.ip);
8010116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	50                   	push   %eax
80101174:	e8 d2 09 00 00       	call   80101b4b <iput>
80101179:	83 c4 10             	add    $0x10,%esp
    end_op();
8010117c:	e8 47 1f 00 00       	call   801030c8 <end_op>
  }
}
80101181:	c9                   	leave  
80101182:	c3                   	ret    

80101183 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101183:	55                   	push   %ebp
80101184:	89 e5                	mov    %esp,%ebp
80101186:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101189:	8b 45 08             	mov    0x8(%ebp),%eax
8010118c:	8b 00                	mov    (%eax),%eax
8010118e:	83 f8 02             	cmp    $0x2,%eax
80101191:	75 40                	jne    801011d3 <filestat+0x50>
    ilock(f->ip);
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 40 10             	mov    0x10(%eax),%eax
80101199:	83 ec 0c             	sub    $0xc,%esp
8010119c:	50                   	push   %eax
8010119d:	e8 48 08 00 00       	call   801019ea <ilock>
801011a2:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
801011a8:	8b 40 10             	mov    0x10(%eax),%eax
801011ab:	83 ec 08             	sub    $0x8,%esp
801011ae:	ff 75 0c             	push   0xc(%ebp)
801011b1:	50                   	push   %eax
801011b2:	e8 d9 0c 00 00       	call   80101e90 <stati>
801011b7:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 40 10             	mov    0x10(%eax),%eax
801011c0:	83 ec 0c             	sub    $0xc,%esp
801011c3:	50                   	push   %eax
801011c4:	e8 34 09 00 00       	call   80101afd <iunlock>
801011c9:	83 c4 10             	add    $0x10,%esp
    return 0;
801011cc:	b8 00 00 00 00       	mov    $0x0,%eax
801011d1:	eb 05                	jmp    801011d8 <filestat+0x55>
  }
  return -1;
801011d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d8:	c9                   	leave  
801011d9:	c3                   	ret    

801011da <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011da:	55                   	push   %ebp
801011db:	89 e5                	mov    %esp,%ebp
801011dd:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011e7:	84 c0                	test   %al,%al
801011e9:	75 0a                	jne    801011f5 <fileread+0x1b>
    return -1;
801011eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011f0:	e9 9b 00 00 00       	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	8b 00                	mov    (%eax),%eax
801011fa:	83 f8 01             	cmp    $0x1,%eax
801011fd:	75 1a                	jne    80101219 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 40 0c             	mov    0xc(%eax),%eax
80101205:	83 ec 04             	sub    $0x4,%esp
80101208:	ff 75 10             	push   0x10(%ebp)
8010120b:	ff 75 0c             	push   0xc(%ebp)
8010120e:	50                   	push   %eax
8010120f:	e8 58 26 00 00       	call   8010386c <piperead>
80101214:	83 c4 10             	add    $0x10,%esp
80101217:	eb 77                	jmp    80101290 <fileread+0xb6>
  if(f->type == FD_INODE){
80101219:	8b 45 08             	mov    0x8(%ebp),%eax
8010121c:	8b 00                	mov    (%eax),%eax
8010121e:	83 f8 02             	cmp    $0x2,%eax
80101221:	75 60                	jne    80101283 <fileread+0xa9>
    ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	50                   	push   %eax
8010122d:	e8 b8 07 00 00       	call   801019ea <ilock>
80101232:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101235:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 50 14             	mov    0x14(%eax),%edx
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 40 10             	mov    0x10(%eax),%eax
80101244:	51                   	push   %ecx
80101245:	52                   	push   %edx
80101246:	ff 75 0c             	push   0xc(%ebp)
80101249:	50                   	push   %eax
8010124a:	e8 87 0c 00 00       	call   80101ed6 <readi>
8010124f:	83 c4 10             	add    $0x10,%esp
80101252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101259:	7e 11                	jle    8010126c <fileread+0x92>
      f->off += r;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 50 14             	mov    0x14(%eax),%edx
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	01 c2                	add    %eax,%edx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	83 ec 0c             	sub    $0xc,%esp
80101275:	50                   	push   %eax
80101276:	e8 82 08 00 00       	call   80101afd <iunlock>
8010127b:	83 c4 10             	add    $0x10,%esp
    return r;
8010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101281:	eb 0d                	jmp    80101290 <fileread+0xb6>
  }
  panic("fileread");
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	68 fa a0 10 80       	push   $0x8010a0fa
8010128b:	e8 19 f3 ff ff       	call   801005a9 <panic>
}
80101290:	c9                   	leave  
80101291:	c3                   	ret    

80101292 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101292:	55                   	push   %ebp
80101293:	89 e5                	mov    %esp,%ebp
80101295:	53                   	push   %ebx
80101296:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101299:	8b 45 08             	mov    0x8(%ebp),%eax
8010129c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012a0:	84 c0                	test   %al,%al
801012a2:	75 0a                	jne    801012ae <filewrite+0x1c>
    return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a9:	e9 1b 01 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 01             	cmp    $0x1,%eax
801012b6:	75 1d                	jne    801012d5 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 0c             	mov    0xc(%eax),%eax
801012be:	83 ec 04             	sub    $0x4,%esp
801012c1:	ff 75 10             	push   0x10(%ebp)
801012c4:	ff 75 0c             	push   0xc(%ebp)
801012c7:	50                   	push   %eax
801012c8:	e8 9d 24 00 00       	call   8010376a <pipewrite>
801012cd:	83 c4 10             	add    $0x10,%esp
801012d0:	e9 f4 00 00 00       	jmp    801013c9 <filewrite+0x137>
  if(f->type == FD_INODE){
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 00                	mov    (%eax),%eax
801012da:	83 f8 02             	cmp    $0x2,%eax
801012dd:	0f 85 d9 00 00 00    	jne    801013bc <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012e3:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012f1:	e9 a3 00 00 00       	jmp    80101399 <filewrite+0x107>
      int n1 = n - i;
801012f6:	8b 45 10             	mov    0x10(%ebp),%eax
801012f9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101302:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101305:	7e 06                	jle    8010130d <filewrite+0x7b>
        n1 = max;
80101307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010130a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010130d:	e8 2a 1d 00 00       	call   8010303c <begin_op>
      ilock(f->ip);
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 40 10             	mov    0x10(%eax),%eax
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	50                   	push   %eax
8010131c:	e8 c9 06 00 00       	call   801019ea <ilock>
80101321:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101324:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
8010132a:	8b 50 14             	mov    0x14(%eax),%edx
8010132d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101330:	8b 45 0c             	mov    0xc(%ebp),%eax
80101333:	01 c3                	add    %eax,%ebx
80101335:	8b 45 08             	mov    0x8(%ebp),%eax
80101338:	8b 40 10             	mov    0x10(%eax),%eax
8010133b:	51                   	push   %ecx
8010133c:	52                   	push   %edx
8010133d:	53                   	push   %ebx
8010133e:	50                   	push   %eax
8010133f:	e8 e7 0c 00 00       	call   8010202b <writei>
80101344:	83 c4 10             	add    $0x10,%esp
80101347:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010134a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010134e:	7e 11                	jle    80101361 <filewrite+0xcf>
        f->off += r;
80101350:	8b 45 08             	mov    0x8(%ebp),%eax
80101353:	8b 50 14             	mov    0x14(%eax),%edx
80101356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101359:	01 c2                	add    %eax,%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101361:	8b 45 08             	mov    0x8(%ebp),%eax
80101364:	8b 40 10             	mov    0x10(%eax),%eax
80101367:	83 ec 0c             	sub    $0xc,%esp
8010136a:	50                   	push   %eax
8010136b:	e8 8d 07 00 00       	call   80101afd <iunlock>
80101370:	83 c4 10             	add    $0x10,%esp
      end_op();
80101373:	e8 50 1d 00 00       	call   801030c8 <end_op>

      if(r < 0)
80101378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010137c:	78 29                	js     801013a7 <filewrite+0x115>
        break;
      if(r != n1)
8010137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101381:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101384:	74 0d                	je     80101393 <filewrite+0x101>
        panic("short filewrite");
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	68 03 a1 10 80       	push   $0x8010a103
8010138e:	e8 16 f2 ff ff       	call   801005a9 <panic>
      i += r;
80101393:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101396:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010139f:	0f 8c 51 ff ff ff    	jl     801012f6 <filewrite+0x64>
801013a5:	eb 01                	jmp    801013a8 <filewrite+0x116>
        break;
801013a7:	90                   	nop
    }
    return i == n ? n : -1;
801013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ae:	75 05                	jne    801013b5 <filewrite+0x123>
801013b0:	8b 45 10             	mov    0x10(%ebp),%eax
801013b3:	eb 14                	jmp    801013c9 <filewrite+0x137>
801013b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013ba:	eb 0d                	jmp    801013c9 <filewrite+0x137>
  }
  panic("filewrite");
801013bc:	83 ec 0c             	sub    $0xc,%esp
801013bf:	68 13 a1 10 80       	push   $0x8010a113
801013c4:	e8 e0 f1 ff ff       	call   801005a9 <panic>
}
801013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013cc:	c9                   	leave  
801013cd:	c3                   	ret    

801013ce <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013ce:	55                   	push   %ebp
801013cf:	89 e5                	mov    %esp,%ebp
801013d1:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013d4:	8b 45 08             	mov    0x8(%ebp),%eax
801013d7:	83 ec 08             	sub    $0x8,%esp
801013da:	6a 01                	push   $0x1
801013dc:	50                   	push   %eax
801013dd:	e8 1f ee ff ff       	call   80100201 <bread>
801013e2:	83 c4 10             	add    $0x10,%esp
801013e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013eb:	83 c0 5c             	add    $0x5c,%eax
801013ee:	83 ec 04             	sub    $0x4,%esp
801013f1:	6a 1c                	push   $0x1c
801013f3:	50                   	push   %eax
801013f4:	ff 75 0c             	push   0xc(%ebp)
801013f7:	e8 42 36 00 00       	call   80104a3e <memmove>
801013fc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	ff 75 f4             	push   -0xc(%ebp)
80101405:	e8 79 ee ff ff       	call   80100283 <brelse>
8010140a:	83 c4 10             	add    $0x10,%esp
}
8010140d:	90                   	nop
8010140e:	c9                   	leave  
8010140f:	c3                   	ret    

80101410 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101410:	55                   	push   %ebp
80101411:	89 e5                	mov    %esp,%ebp
80101413:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101416:	8b 55 0c             	mov    0xc(%ebp),%edx
80101419:	8b 45 08             	mov    0x8(%ebp),%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	52                   	push   %edx
80101420:	50                   	push   %eax
80101421:	e8 db ed ff ff       	call   80100201 <bread>
80101426:	83 c4 10             	add    $0x10,%esp
80101429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142f:	83 c0 5c             	add    $0x5c,%eax
80101432:	83 ec 04             	sub    $0x4,%esp
80101435:	68 00 02 00 00       	push   $0x200
8010143a:	6a 00                	push   $0x0
8010143c:	50                   	push   %eax
8010143d:	e8 3d 35 00 00       	call   8010497f <memset>
80101442:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	ff 75 f4             	push   -0xc(%ebp)
8010144b:	e8 25 1e 00 00       	call   80103275 <log_write>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	push   -0xc(%ebp)
80101459:	e8 25 ee ff ff       	call   80100283 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010146a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101471:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101478:	e9 0b 01 00 00       	jmp    80101588 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
8010147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101480:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101486:	85 c0                	test   %eax,%eax
80101488:	0f 48 c2             	cmovs  %edx,%eax
8010148b:	c1 f8 0c             	sar    $0xc,%eax
8010148e:	89 c2                	mov    %eax,%edx
80101490:	a1 58 24 19 80       	mov    0x80192458,%eax
80101495:	01 d0                	add    %edx,%eax
80101497:	83 ec 08             	sub    $0x8,%esp
8010149a:	50                   	push   %eax
8010149b:	ff 75 08             	push   0x8(%ebp)
8010149e:	e8 5e ed ff ff       	call   80100201 <bread>
801014a3:	83 c4 10             	add    $0x10,%esp
801014a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014b0:	e9 9e 00 00 00       	jmp    80101553 <balloc+0xef>
      m = 1 << (bi % 8);
801014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b8:	83 e0 07             	and    $0x7,%eax
801014bb:	ba 01 00 00 00       	mov    $0x1,%edx
801014c0:	89 c1                	mov    %eax,%ecx
801014c2:	d3 e2                	shl    %cl,%edx
801014c4:	89 d0                	mov    %edx,%eax
801014c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014cc:	8d 50 07             	lea    0x7(%eax),%edx
801014cf:	85 c0                	test   %eax,%eax
801014d1:	0f 48 c2             	cmovs  %edx,%eax
801014d4:	c1 f8 03             	sar    $0x3,%eax
801014d7:	89 c2                	mov    %eax,%edx
801014d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014dc:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014e1:	0f b6 c0             	movzbl %al,%eax
801014e4:	23 45 e8             	and    -0x18(%ebp),%eax
801014e7:	85 c0                	test   %eax,%eax
801014e9:	75 64                	jne    8010154f <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	8d 50 07             	lea    0x7(%eax),%edx
801014f1:	85 c0                	test   %eax,%eax
801014f3:	0f 48 c2             	cmovs  %edx,%eax
801014f6:	c1 f8 03             	sar    $0x3,%eax
801014f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014fc:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101501:	89 d1                	mov    %edx,%ecx
80101503:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101506:	09 ca                	or     %ecx,%edx
80101508:	89 d1                	mov    %edx,%ecx
8010150a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010150d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101511:	83 ec 0c             	sub    $0xc,%esp
80101514:	ff 75 ec             	push   -0x14(%ebp)
80101517:	e8 59 1d 00 00       	call   80103275 <log_write>
8010151c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	ff 75 ec             	push   -0x14(%ebp)
80101525:	e8 59 ed ff ff       	call   80100283 <brelse>
8010152a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	01 c2                	add    %eax,%edx
80101535:	8b 45 08             	mov    0x8(%ebp),%eax
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	52                   	push   %edx
8010153c:	50                   	push   %eax
8010153d:	e8 ce fe ff ff       	call   80101410 <bzero>
80101542:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154b:	01 d0                	add    %edx,%eax
8010154d:	eb 57                	jmp    801015a6 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101553:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010155a:	7f 17                	jg     80101573 <balloc+0x10f>
8010155c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 c2                	mov    %eax,%edx
80101566:	a1 40 24 19 80       	mov    0x80192440,%eax
8010156b:	39 c2                	cmp    %eax,%edx
8010156d:	0f 82 42 ff ff ff    	jb     801014b5 <balloc+0x51>
      }
    }
    brelse(bp);
80101573:	83 ec 0c             	sub    $0xc,%esp
80101576:	ff 75 ec             	push   -0x14(%ebp)
80101579:	e8 05 ed ff ff       	call   80100283 <brelse>
8010157e:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101581:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101588:	8b 15 40 24 19 80    	mov    0x80192440,%edx
8010158e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101591:	39 c2                	cmp    %eax,%edx
80101593:	0f 87 e4 fe ff ff    	ja     8010147d <balloc+0x19>
  }
  panic("balloc: out of blocks");
80101599:	83 ec 0c             	sub    $0xc,%esp
8010159c:	68 20 a1 10 80       	push   $0x8010a120
801015a1:	e8 03 f0 ff ff       	call   801005a9 <panic>
}
801015a6:	c9                   	leave  
801015a7:	c3                   	ret    

801015a8 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ae:	83 ec 08             	sub    $0x8,%esp
801015b1:	68 40 24 19 80       	push   $0x80192440
801015b6:	ff 75 08             	push   0x8(%ebp)
801015b9:	e8 10 fe ff ff       	call   801013ce <readsb>
801015be:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c4:	c1 e8 0c             	shr    $0xc,%eax
801015c7:	89 c2                	mov    %eax,%edx
801015c9:	a1 58 24 19 80       	mov    0x80192458,%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	83 ec 08             	sub    $0x8,%esp
801015d6:	52                   	push   %edx
801015d7:	50                   	push   %eax
801015d8:	e8 24 ec ff ff       	call   80100201 <bread>
801015dd:	83 c4 10             	add    $0x10,%esp
801015e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e6:	25 ff 0f 00 00       	and    $0xfff,%eax
801015eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	83 e0 07             	and    $0x7,%eax
801015f4:	ba 01 00 00 00       	mov    $0x1,%edx
801015f9:	89 c1                	mov    %eax,%ecx
801015fb:	d3 e2                	shl    %cl,%edx
801015fd:	89 d0                	mov    %edx,%eax
801015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101605:	8d 50 07             	lea    0x7(%eax),%edx
80101608:	85 c0                	test   %eax,%eax
8010160a:	0f 48 c2             	cmovs  %edx,%eax
8010160d:	c1 f8 03             	sar    $0x3,%eax
80101610:	89 c2                	mov    %eax,%edx
80101612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101615:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010161a:	0f b6 c0             	movzbl %al,%eax
8010161d:	23 45 ec             	and    -0x14(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	75 0d                	jne    80101631 <bfree+0x89>
    panic("freeing free block");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 36 a1 10 80       	push   $0x8010a136
8010162c:	e8 78 ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
80101631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101634:	8d 50 07             	lea    0x7(%eax),%edx
80101637:	85 c0                	test   %eax,%eax
80101639:	0f 48 c2             	cmovs  %edx,%eax
8010163c:	c1 f8 03             	sar    $0x3,%eax
8010163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101642:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101647:	89 d1                	mov    %edx,%ecx
80101649:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164c:	f7 d2                	not    %edx
8010164e:	21 ca                	and    %ecx,%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101659:	83 ec 0c             	sub    $0xc,%esp
8010165c:	ff 75 f4             	push   -0xc(%ebp)
8010165f:	e8 11 1c 00 00       	call   80103275 <log_write>
80101664:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101667:	83 ec 0c             	sub    $0xc,%esp
8010166a:	ff 75 f4             	push   -0xc(%ebp)
8010166d:	e8 11 ec ff ff       	call   80100283 <brelse>
80101672:	83 c4 10             	add    $0x10,%esp
}
80101675:	90                   	nop
80101676:	c9                   	leave  
80101677:	c3                   	ret    

80101678 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101678:	55                   	push   %ebp
80101679:	89 e5                	mov    %esp,%ebp
8010167b:	57                   	push   %edi
8010167c:	56                   	push   %esi
8010167d:	53                   	push   %ebx
8010167e:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101681:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101688:	83 ec 08             	sub    $0x8,%esp
8010168b:	68 49 a1 10 80       	push   $0x8010a149
80101690:	68 60 24 19 80       	push   $0x80192460
80101695:	e8 4d 30 00 00       	call   801046e7 <initlock>
8010169a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010169d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016a4:	eb 2d                	jmp    801016d3 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016a9:	89 d0                	mov    %edx,%eax
801016ab:	c1 e0 03             	shl    $0x3,%eax
801016ae:	01 d0                	add    %edx,%eax
801016b0:	c1 e0 04             	shl    $0x4,%eax
801016b3:	83 c0 30             	add    $0x30,%eax
801016b6:	05 60 24 19 80       	add    $0x80192460,%eax
801016bb:	83 c0 10             	add    $0x10,%eax
801016be:	83 ec 08             	sub    $0x8,%esp
801016c1:	68 50 a1 10 80       	push   $0x8010a150
801016c6:	50                   	push   %eax
801016c7:	e8 be 2e 00 00       	call   8010458a <initsleeplock>
801016cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016d3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016d7:	7e cd                	jle    801016a6 <iinit+0x2e>
  }

  readsb(dev, &sb);
801016d9:	83 ec 08             	sub    $0x8,%esp
801016dc:	68 40 24 19 80       	push   $0x80192440
801016e1:	ff 75 08             	push   0x8(%ebp)
801016e4:	e8 e5 fc ff ff       	call   801013ce <readsb>
801016e9:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016ec:	a1 58 24 19 80       	mov    0x80192458,%eax
801016f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016f4:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
801016fa:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101700:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
80101706:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
8010170c:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101712:	a1 40 24 19 80       	mov    0x80192440,%eax
80101717:	ff 75 d4             	push   -0x2c(%ebp)
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	51                   	push   %ecx
8010171e:	52                   	push   %edx
8010171f:	50                   	push   %eax
80101720:	68 58 a1 10 80       	push   $0x8010a158
80101725:	e8 ca ec ff ff       	call   801003f4 <cprintf>
8010172a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010172d:	90                   	nop
8010172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101731:	5b                   	pop    %ebx
80101732:	5e                   	pop    %esi
80101733:	5f                   	pop    %edi
80101734:	5d                   	pop    %ebp
80101735:	c3                   	ret    

80101736 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	83 ec 28             	sub    $0x28,%esp
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101743:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010174a:	e9 9e 00 00 00       	jmp    801017ed <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	c1 e8 03             	shr    $0x3,%eax
80101755:	89 c2                	mov    %eax,%edx
80101757:	a1 54 24 19 80       	mov    0x80192454,%eax
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 ec 08             	sub    $0x8,%esp
80101761:	50                   	push   %eax
80101762:	ff 75 08             	push   0x8(%ebp)
80101765:	e8 97 ea ff ff       	call   80100201 <bread>
8010176a:	83 c4 10             	add    $0x10,%esp
8010176d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101773:	8d 50 5c             	lea    0x5c(%eax),%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	83 e0 07             	and    $0x7,%eax
8010177c:	c1 e0 06             	shl    $0x6,%eax
8010177f:	01 d0                	add    %edx,%eax
80101781:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101787:	0f b7 00             	movzwl (%eax),%eax
8010178a:	66 85 c0             	test   %ax,%ax
8010178d:	75 4c                	jne    801017db <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010178f:	83 ec 04             	sub    $0x4,%esp
80101792:	6a 40                	push   $0x40
80101794:	6a 00                	push   $0x0
80101796:	ff 75 ec             	push   -0x14(%ebp)
80101799:	e8 e1 31 00 00       	call   8010497f <memset>
8010179e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017a8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	ff 75 f0             	push   -0x10(%ebp)
801017b1:	e8 bf 1a 00 00       	call   80103275 <log_write>
801017b6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017b9:	83 ec 0c             	sub    $0xc,%esp
801017bc:	ff 75 f0             	push   -0x10(%ebp)
801017bf:	e8 bf ea ff ff       	call   80100283 <brelse>
801017c4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	50                   	push   %eax
801017ce:	ff 75 08             	push   0x8(%ebp)
801017d1:	e8 f8 00 00 00       	call   801018ce <iget>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	eb 30                	jmp    8010180b <ialloc+0xd5>
    }
    brelse(bp);
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 9d ea ff ff       	call   80100283 <brelse>
801017e6:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017ed:	8b 15 48 24 19 80    	mov    0x80192448,%edx
801017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f6:	39 c2                	cmp    %eax,%edx
801017f8:	0f 87 51 ff ff ff    	ja     8010174f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017fe:	83 ec 0c             	sub    $0xc,%esp
80101801:	68 ab a1 10 80       	push   $0x8010a1ab
80101806:	e8 9e ed ff ff       	call   801005a9 <panic>
}
8010180b:	c9                   	leave  
8010180c:	c3                   	ret    

8010180d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010180d:	55                   	push   %ebp
8010180e:	89 e5                	mov    %esp,%ebp
80101810:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101813:	8b 45 08             	mov    0x8(%ebp),%eax
80101816:	8b 40 04             	mov    0x4(%eax),%eax
80101819:	c1 e8 03             	shr    $0x3,%eax
8010181c:	89 c2                	mov    %eax,%edx
8010181e:	a1 54 24 19 80       	mov    0x80192454,%eax
80101823:	01 c2                	add    %eax,%edx
80101825:	8b 45 08             	mov    0x8(%ebp),%eax
80101828:	8b 00                	mov    (%eax),%eax
8010182a:	83 ec 08             	sub    $0x8,%esp
8010182d:	52                   	push   %edx
8010182e:	50                   	push   %eax
8010182f:	e8 cd e9 ff ff       	call   80100201 <bread>
80101834:	83 c4 10             	add    $0x10,%esp
80101837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 04             	mov    0x4(%eax),%eax
80101846:	83 e0 07             	and    $0x7,%eax
80101849:	c1 e0 06             	shl    $0x6,%eax
8010184c:	01 d0                	add    %edx,%eax
8010184e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101858:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010185e:	8b 45 08             	mov    0x8(%ebp),%eax
80101861:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101868:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101873:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101876:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010187a:	8b 45 08             	mov    0x8(%ebp),%eax
8010187d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101888:	8b 45 08             	mov    0x8(%ebp),%eax
8010188b:	8b 50 58             	mov    0x58(%eax),%edx
8010188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101891:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101894:	8b 45 08             	mov    0x8(%ebp),%eax
80101897:	8d 50 5c             	lea    0x5c(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	83 c0 0c             	add    $0xc,%eax
801018a0:	83 ec 04             	sub    $0x4,%esp
801018a3:	6a 34                	push   $0x34
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 92 31 00 00       	call   80104a3e <memmove>
801018ac:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018af:	83 ec 0c             	sub    $0xc,%esp
801018b2:	ff 75 f4             	push   -0xc(%ebp)
801018b5:	e8 bb 19 00 00       	call   80103275 <log_write>
801018ba:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018bd:	83 ec 0c             	sub    $0xc,%esp
801018c0:	ff 75 f4             	push   -0xc(%ebp)
801018c3:	e8 bb e9 ff ff       	call   80100283 <brelse>
801018c8:	83 c4 10             	add    $0x10,%esp
}
801018cb:	90                   	nop
801018cc:	c9                   	leave  
801018cd:	c3                   	ret    

801018ce <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018ce:	55                   	push   %ebp
801018cf:	89 e5                	mov    %esp,%ebp
801018d1:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	68 60 24 19 80       	push   $0x80192460
801018dc:	e8 28 2e 00 00       	call   80104709 <acquire>
801018e1:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018eb:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018f2:	eb 60                	jmp    80101954 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f7:	8b 40 08             	mov    0x8(%eax),%eax
801018fa:	85 c0                	test   %eax,%eax
801018fc:	7e 39                	jle    80101937 <iget+0x69>
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	39 45 08             	cmp    %eax,0x8(%ebp)
80101906:	75 2f                	jne    80101937 <iget+0x69>
80101908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190b:	8b 40 04             	mov    0x4(%eax),%eax
8010190e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101911:	75 24                	jne    80101937 <iget+0x69>
      ip->ref++;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 40 08             	mov    0x8(%eax),%eax
80101919:	8d 50 01             	lea    0x1(%eax),%edx
8010191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	68 60 24 19 80       	push   $0x80192460
8010192a:	e8 48 2e 00 00       	call   80104777 <release>
8010192f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101935:	eb 77                	jmp    801019ae <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010193b:	75 10                	jne    8010194d <iget+0x7f>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 08             	mov    0x8(%eax),%eax
80101943:	85 c0                	test   %eax,%eax
80101945:	75 06                	jne    8010194d <iget+0x7f>
      empty = ip;
80101947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010194d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101954:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
8010195b:	72 97                	jb     801018f4 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 0d                	jne    80101970 <iget+0xa2>
    panic("iget: no inodes");
80101963:	83 ec 0c             	sub    $0xc,%esp
80101966:	68 bd a1 10 80       	push   $0x8010a1bd
8010196b:	e8 39 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101973:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101979:	8b 55 08             	mov    0x8(%ebp),%edx
8010197c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 0c             	mov    0xc(%ebp),%edx
80101984:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101994:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
8010199b:	83 ec 0c             	sub    $0xc,%esp
8010199e:	68 60 24 19 80       	push   $0x80192460
801019a3:	e8 cf 2d 00 00       	call   80104777 <release>
801019a8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019b6:	83 ec 0c             	sub    $0xc,%esp
801019b9:	68 60 24 19 80       	push   $0x80192460
801019be:	e8 46 2d 00 00       	call   80104709 <acquire>
801019c3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019c6:	8b 45 08             	mov    0x8(%ebp),%eax
801019c9:	8b 40 08             	mov    0x8(%eax),%eax
801019cc:	8d 50 01             	lea    0x1(%eax),%edx
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019d5:	83 ec 0c             	sub    $0xc,%esp
801019d8:	68 60 24 19 80       	push   $0x80192460
801019dd:	e8 95 2d 00 00       	call   80104777 <release>
801019e2:	83 c4 10             	add    $0x10,%esp
  return ip;
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019e8:	c9                   	leave  
801019e9:	c3                   	ret    

801019ea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019ea:	55                   	push   %ebp
801019eb:	89 e5                	mov    %esp,%ebp
801019ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019f4:	74 0a                	je     80101a00 <ilock+0x16>
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	7f 0d                	jg     80101a0d <ilock+0x23>
    panic("ilock");
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 cd a1 10 80       	push   $0x8010a1cd
80101a08:	e8 9c eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a10:	83 c0 0c             	add    $0xc,%eax
80101a13:	83 ec 0c             	sub    $0xc,%esp
80101a16:	50                   	push   %eax
80101a17:	e8 aa 2b 00 00       	call   801045c6 <acquiresleep>
80101a1c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a22:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a25:	85 c0                	test   %eax,%eax
80101a27:	0f 85 cd 00 00 00    	jne    80101afa <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 04             	mov    0x4(%eax),%eax
80101a33:	c1 e8 03             	shr    $0x3,%eax
80101a36:	89 c2                	mov    %eax,%edx
80101a38:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a3d:	01 c2                	add    %eax,%edx
80101a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	83 ec 08             	sub    $0x8,%esp
80101a47:	52                   	push   %edx
80101a48:	50                   	push   %eax
80101a49:	e8 b3 e7 ff ff       	call   80100201 <bread>
80101a4e:	83 c4 10             	add    $0x10,%esp
80101a51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 04             	mov    0x4(%eax),%eax
80101a60:	83 e0 07             	and    $0x7,%eax
80101a63:	c1 e0 06             	shl    $0x6,%eax
80101a66:	01 d0                	add    %edx,%eax
80101a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6e:	0f b7 10             	movzwl (%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a82:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a90:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a97:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa5:	8b 50 08             	mov    0x8(%eax),%edx
80101aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aab:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	83 c0 5c             	add    $0x5c,%eax
80101aba:	83 ec 04             	sub    $0x4,%esp
80101abd:	6a 34                	push   $0x34
80101abf:	52                   	push   %edx
80101ac0:	50                   	push   %eax
80101ac1:	e8 78 2f 00 00       	call   80104a3e <memmove>
80101ac6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ac9:	83 ec 0c             	sub    $0xc,%esp
80101acc:	ff 75 f4             	push   -0xc(%ebp)
80101acf:	e8 af e7 ff ff       	call   80100283 <brelse>
80101ad4:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ae8:	66 85 c0             	test   %ax,%ax
80101aeb:	75 0d                	jne    80101afa <ilock+0x110>
      panic("ilock: no type");
80101aed:	83 ec 0c             	sub    $0xc,%esp
80101af0:	68 d3 a1 10 80       	push   $0x8010a1d3
80101af5:	e8 af ea ff ff       	call   801005a9 <panic>
  }
}
80101afa:	90                   	nop
80101afb:	c9                   	leave  
80101afc:	c3                   	ret    

80101afd <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101afd:	55                   	push   %ebp
80101afe:	89 e5                	mov    %esp,%ebp
80101b00:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b07:	74 20                	je     80101b29 <iunlock+0x2c>
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	83 c0 0c             	add    $0xc,%eax
80101b0f:	83 ec 0c             	sub    $0xc,%esp
80101b12:	50                   	push   %eax
80101b13:	e8 60 2b 00 00       	call   80104678 <holdingsleep>
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 c0                	test   %eax,%eax
80101b1d:	74 0a                	je     80101b29 <iunlock+0x2c>
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	7f 0d                	jg     80101b36 <iunlock+0x39>
    panic("iunlock");
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 e2 a1 10 80       	push   $0x8010a1e2
80101b31:	e8 73 ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b36:	8b 45 08             	mov    0x8(%ebp),%eax
80101b39:	83 c0 0c             	add    $0xc,%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	50                   	push   %eax
80101b40:	e8 e5 2a 00 00       	call   8010462a <releasesleep>
80101b45:	83 c4 10             	add    $0x10,%esp
}
80101b48:	90                   	nop
80101b49:	c9                   	leave  
80101b4a:	c3                   	ret    

80101b4b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b4b:	55                   	push   %ebp
80101b4c:	89 e5                	mov    %esp,%ebp
80101b4e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	83 c0 0c             	add    $0xc,%eax
80101b57:	83 ec 0c             	sub    $0xc,%esp
80101b5a:	50                   	push   %eax
80101b5b:	e8 66 2a 00 00       	call   801045c6 <acquiresleep>
80101b60:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	85 c0                	test   %eax,%eax
80101b6b:	74 6a                	je     80101bd7 <iput+0x8c>
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b74:	66 85 c0             	test   %ax,%ax
80101b77:	75 5e                	jne    80101bd7 <iput+0x8c>
    acquire(&icache.lock);
80101b79:	83 ec 0c             	sub    $0xc,%esp
80101b7c:	68 60 24 19 80       	push   $0x80192460
80101b81:	e8 83 2b 00 00       	call   80104709 <acquire>
80101b86:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b89:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8c:	8b 40 08             	mov    0x8(%eax),%eax
80101b8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b92:	83 ec 0c             	sub    $0xc,%esp
80101b95:	68 60 24 19 80       	push   $0x80192460
80101b9a:	e8 d8 2b 00 00       	call   80104777 <release>
80101b9f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101ba2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101ba6:	75 2f                	jne    80101bd7 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101ba8:	83 ec 0c             	sub    $0xc,%esp
80101bab:	ff 75 08             	push   0x8(%ebp)
80101bae:	e8 ad 01 00 00       	call   80101d60 <itrunc>
80101bb3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bbf:	83 ec 0c             	sub    $0xc,%esp
80101bc2:	ff 75 08             	push   0x8(%ebp)
80101bc5:	e8 43 fc ff ff       	call   8010180d <iupdate>
80101bca:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bda:	83 c0 0c             	add    $0xc,%eax
80101bdd:	83 ec 0c             	sub    $0xc,%esp
80101be0:	50                   	push   %eax
80101be1:	e8 44 2a 00 00       	call   8010462a <releasesleep>
80101be6:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101be9:	83 ec 0c             	sub    $0xc,%esp
80101bec:	68 60 24 19 80       	push   $0x80192460
80101bf1:	e8 13 2b 00 00       	call   80104709 <acquire>
80101bf6:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	8b 40 08             	mov    0x8(%eax),%eax
80101bff:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c08:	83 ec 0c             	sub    $0xc,%esp
80101c0b:	68 60 24 19 80       	push   $0x80192460
80101c10:	e8 62 2b 00 00       	call   80104777 <release>
80101c15:	83 c4 10             	add    $0x10,%esp
}
80101c18:	90                   	nop
80101c19:	c9                   	leave  
80101c1a:	c3                   	ret    

80101c1b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c1b:	55                   	push   %ebp
80101c1c:	89 e5                	mov    %esp,%ebp
80101c1e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	ff 75 08             	push   0x8(%ebp)
80101c27:	e8 d1 fe ff ff       	call   80101afd <iunlock>
80101c2c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c2f:	83 ec 0c             	sub    $0xc,%esp
80101c32:	ff 75 08             	push   0x8(%ebp)
80101c35:	e8 11 ff ff ff       	call   80101b4b <iput>
80101c3a:	83 c4 10             	add    $0x10,%esp
}
80101c3d:	90                   	nop
80101c3e:	c9                   	leave  
80101c3f:	c3                   	ret    

80101c40 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c46:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4a:	77 42                	ja     80101c8e <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c52:	83 c2 14             	add    $0x14,%edx
80101c55:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c60:	75 24                	jne    80101c86 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c62:	8b 45 08             	mov    0x8(%ebp),%eax
80101c65:	8b 00                	mov    (%eax),%eax
80101c67:	83 ec 0c             	sub    $0xc,%esp
80101c6a:	50                   	push   %eax
80101c6b:	e8 f4 f7 ff ff       	call   80101464 <balloc>
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 d0 00 00 00       	jmp    80101d5e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 b5 00 00 00    	ja     80101d51 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 20                	jne    80101cce <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	50                   	push   %eax
80101cb7:	e8 a8 f7 ff ff       	call   80101464 <balloc>
80101cbc:	83 c4 10             	add    $0x10,%esp
80101cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	8b 00                	mov    (%eax),%eax
80101cd3:	83 ec 08             	sub    $0x8,%esp
80101cd6:	ff 75 f4             	push   -0xc(%ebp)
80101cd9:	50                   	push   %eax
80101cda:	e8 22 e5 ff ff       	call   80100201 <bread>
80101cdf:	83 c4 10             	add    $0x10,%esp
80101ce2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce8:	83 c0 5c             	add    $0x5c,%eax
80101ceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfb:	01 d0                	add    %edx,%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 36                	jne    80101d3e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 4e f7 ff ff       	call   80101464 <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d29:	01 c2                	add    %eax,%edx
80101d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	ff 75 f0             	push   -0x10(%ebp)
80101d36:	e8 3a 15 00 00       	call   80103275 <log_write>
80101d3b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 f0             	push   -0x10(%ebp)
80101d44:	e8 3a e5 ff ff       	call   80100283 <brelse>
80101d49:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4f:	eb 0d                	jmp    80101d5e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 ea a1 10 80       	push   $0x8010a1ea
80101d59:	e8 4b e8 ff ff       	call   801005a9 <panic>
}
80101d5e:	c9                   	leave  
80101d5f:	c3                   	ret    

80101d60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d60:	55                   	push   %ebp
80101d61:	89 e5                	mov    %esp,%ebp
80101d63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d6d:	eb 45                	jmp    80101db4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d75:	83 c2 14             	add    $0x14,%edx
80101d78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d7c:	85 c0                	test   %eax,%eax
80101d7e:	74 30                	je     80101db0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d86:	83 c2 14             	add    $0x14,%edx
80101d89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101d90:	8b 12                	mov    (%edx),%edx
80101d92:	83 ec 08             	sub    $0x8,%esp
80101d95:	50                   	push   %eax
80101d96:	52                   	push   %edx
80101d97:	e8 0c f8 ff ff       	call   801015a8 <bfree>
80101d9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101daf:	00 
  for(i = 0; i < NDIRECT; i++){
80101db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101db4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101db8:	7e b5                	jle    80101d6f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dc3:	85 c0                	test   %eax,%eax
80101dc5:	0f 84 aa 00 00 00    	je     80101e75 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 08             	sub    $0x8,%esp
80101ddc:	52                   	push   %edx
80101ddd:	50                   	push   %eax
80101dde:	e8 1e e4 ff ff       	call   80100201 <bread>
80101de3:	83 c4 10             	add    $0x10,%esp
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 5c             	add    $0x5c,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3c                	jmp    80101e37 <itrunc+0xd7>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 23                	je     80101e33 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 00                	mov    (%eax),%eax
80101e21:	8b 55 08             	mov    0x8(%ebp),%edx
80101e24:	8b 12                	mov    (%edx),%edx
80101e26:	83 ec 08             	sub    $0x8,%esp
80101e29:	50                   	push   %eax
80101e2a:	52                   	push   %edx
80101e2b:	e8 78 f7 ff ff       	call   801015a8 <bfree>
80101e30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e3a:	83 f8 7f             	cmp    $0x7f,%eax
80101e3d:	76 bc                	jbe    80101dfb <itrunc+0x9b>
    }
    brelse(bp);
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	ff 75 ec             	push   -0x14(%ebp)
80101e45:	e8 39 e4 ff ff       	call   80100283 <brelse>
80101e4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e56:	8b 55 08             	mov    0x8(%ebp),%edx
80101e59:	8b 12                	mov    (%edx),%edx
80101e5b:	83 ec 08             	sub    $0x8,%esp
80101e5e:	50                   	push   %eax
80101e5f:	52                   	push   %edx
80101e60:	e8 43 f7 ff ff       	call   801015a8 <bfree>
80101e65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e72:	00 00 00 
  }

  ip->size = 0;
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e7f:	83 ec 0c             	sub    $0xc,%esp
80101e82:	ff 75 08             	push   0x8(%ebp)
80101e85:	e8 83 f9 ff ff       	call   8010180d <iupdate>
80101e8a:	83 c4 10             	add    $0x10,%esp
}
80101e8d:	90                   	nop
80101e8e:	c9                   	leave  
80101e8f:	c3                   	ret    

80101e90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e90:	55                   	push   %ebp
80101e91:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 00                	mov    (%eax),%eax
80101e98:	89 c2                	mov    %eax,%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	8b 50 04             	mov    0x4(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eca:	8b 50 58             	mov    0x58(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed3:	90                   	nop
80101ed4:	5d                   	pop    %ebp
80101ed5:	c3                   	ret    

80101ed6 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed6:	55                   	push   %ebp
80101ed7:	89 e5                	mov    %esp,%ebp
80101ed9:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 5c                	jne    80101f45 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <readi+0x3f>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <readi+0x3f>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <readi+0x49>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 0a 01 00 00       	jmp    80102029 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f2e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f31:	83 ec 04             	sub    $0x4,%esp
80101f34:	52                   	push   %edx
80101f35:	ff 75 0c             	push   0xc(%ebp)
80101f38:	ff 75 08             	push   0x8(%ebp)
80101f3b:	ff d0                	call   *%eax
80101f3d:	83 c4 10             	add    $0x10,%esp
80101f40:	e9 e4 00 00 00       	jmp    80102029 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 58             	mov    0x58(%eax),%eax
80101f4b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f4e:	77 0d                	ja     80101f5d <readi+0x87>
80101f50:	8b 55 10             	mov    0x10(%ebp),%edx
80101f53:	8b 45 14             	mov    0x14(%ebp),%eax
80101f56:	01 d0                	add    %edx,%eax
80101f58:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f5b:	76 0a                	jbe    80101f67 <readi+0x91>
    return -1;
80101f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f62:	e9 c2 00 00 00       	jmp    80102029 <readi+0x153>
  if(off + n > ip->size)
80101f67:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	01 c2                	add    %eax,%edx
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 58             	mov    0x58(%eax),%eax
80101f75:	39 c2                	cmp    %eax,%edx
80101f77:	76 0c                	jbe    80101f85 <readi+0xaf>
    n = ip->size - off;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	8b 40 58             	mov    0x58(%eax),%eax
80101f7f:	2b 45 10             	sub    0x10(%ebp),%eax
80101f82:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8c:	e9 89 00 00 00       	jmp    8010201a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f91:	8b 45 10             	mov    0x10(%ebp),%eax
80101f94:	c1 e8 09             	shr    $0x9,%eax
80101f97:	83 ec 08             	sub    $0x8,%esp
80101f9a:	50                   	push   %eax
80101f9b:	ff 75 08             	push   0x8(%ebp)
80101f9e:	e8 9d fc ff ff       	call   80101c40 <bmap>
80101fa3:	83 c4 10             	add    $0x10,%esp
80101fa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa9:	8b 12                	mov    (%edx),%edx
80101fab:	83 ec 08             	sub    $0x8,%esp
80101fae:	50                   	push   %eax
80101faf:	52                   	push   %edx
80101fb0:	e8 4c e2 ff ff       	call   80100201 <bread>
80101fb5:	83 c4 10             	add    $0x10,%esp
80101fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbe:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc3:	ba 00 02 00 00       	mov    $0x200,%edx
80101fc8:	29 c2                	sub    %eax,%edx
80101fca:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd0:	39 c2                	cmp    %eax,%edx
80101fd2:	0f 46 c2             	cmovbe %edx,%eax
80101fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fde:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe1:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe6:	01 d0                	add    %edx,%eax
80101fe8:	83 ec 04             	sub    $0x4,%esp
80101feb:	ff 75 ec             	push   -0x14(%ebp)
80101fee:	50                   	push   %eax
80101fef:	ff 75 0c             	push   0xc(%ebp)
80101ff2:	e8 47 2a 00 00       	call   80104a3e <memmove>
80101ff7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffa:	83 ec 0c             	sub    $0xc,%esp
80101ffd:	ff 75 f0             	push   -0x10(%ebp)
80102000:	e8 7e e2 ff ff       	call   80100283 <brelse>
80102005:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102011:	01 45 10             	add    %eax,0x10(%ebp)
80102014:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102017:	01 45 0c             	add    %eax,0xc(%ebp)
8010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102020:	0f 82 6b ff ff ff    	jb     80101f91 <readi+0xbb>
  }
  return n;
80102026:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102029:	c9                   	leave  
8010202a:	c3                   	ret    

8010202b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202b:	55                   	push   %ebp
8010202c:	89 e5                	mov    %esp,%ebp
8010202e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102038:	66 83 f8 03          	cmp    $0x3,%ax
8010203c:	75 5c                	jne    8010209a <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102045:	66 85 c0             	test   %ax,%ax
80102048:	78 20                	js     8010206a <writei+0x3f>
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102051:	66 83 f8 09          	cmp    $0x9,%ax
80102055:	7f 13                	jg     8010206a <writei+0x3f>
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010205e:	98                   	cwtl   
8010205f:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 0a                	jne    80102074 <writei+0x49>
      return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 3b 01 00 00       	jmp    801021af <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010207b:	98                   	cwtl   
8010207c:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
80102083:	8b 55 14             	mov    0x14(%ebp),%edx
80102086:	83 ec 04             	sub    $0x4,%esp
80102089:	52                   	push   %edx
8010208a:	ff 75 0c             	push   0xc(%ebp)
8010208d:	ff 75 08             	push   0x8(%ebp)
80102090:	ff d0                	call   *%eax
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	e9 15 01 00 00       	jmp    801021af <writei+0x184>
  }

  if(off > ip->size || off + n < off)
8010209a:	8b 45 08             	mov    0x8(%ebp),%eax
8010209d:	8b 40 58             	mov    0x58(%eax),%eax
801020a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020a3:	77 0d                	ja     801020b2 <writei+0x87>
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	39 45 10             	cmp    %eax,0x10(%ebp)
801020b0:	76 0a                	jbe    801020bc <writei+0x91>
    return -1;
801020b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b7:	e9 f3 00 00 00       	jmp    801021af <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	8b 45 14             	mov    0x14(%ebp),%eax
801020c2:	01 d0                	add    %edx,%eax
801020c4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c9:	76 0a                	jbe    801020d5 <writei+0xaa>
    return -1;
801020cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d0:	e9 da 00 00 00       	jmp    801021af <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	e9 97 00 00 00       	jmp    80102178 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e1:	8b 45 10             	mov    0x10(%ebp),%eax
801020e4:	c1 e8 09             	shr    $0x9,%eax
801020e7:	83 ec 08             	sub    $0x8,%esp
801020ea:	50                   	push   %eax
801020eb:	ff 75 08             	push   0x8(%ebp)
801020ee:	e8 4d fb ff ff       	call   80101c40 <bmap>
801020f3:	83 c4 10             	add    $0x10,%esp
801020f6:	8b 55 08             	mov    0x8(%ebp),%edx
801020f9:	8b 12                	mov    (%edx),%edx
801020fb:	83 ec 08             	sub    $0x8,%esp
801020fe:	50                   	push   %eax
801020ff:	52                   	push   %edx
80102100:	e8 fc e0 ff ff       	call   80100201 <bread>
80102105:	83 c4 10             	add    $0x10,%esp
80102108:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210b:	8b 45 10             	mov    0x10(%ebp),%eax
8010210e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102113:	ba 00 02 00 00       	mov    $0x200,%edx
80102118:	29 c2                	sub    %eax,%edx
8010211a:	8b 45 14             	mov    0x14(%ebp),%eax
8010211d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102120:	39 c2                	cmp    %eax,%edx
80102122:	0f 46 c2             	cmovbe %edx,%eax
80102125:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010212b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	25 ff 01 00 00       	and    $0x1ff,%eax
80102136:	01 d0                	add    %edx,%eax
80102138:	83 ec 04             	sub    $0x4,%esp
8010213b:	ff 75 ec             	push   -0x14(%ebp)
8010213e:	ff 75 0c             	push   0xc(%ebp)
80102141:	50                   	push   %eax
80102142:	e8 f7 28 00 00       	call   80104a3e <memmove>
80102147:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010214a:	83 ec 0c             	sub    $0xc,%esp
8010214d:	ff 75 f0             	push   -0x10(%ebp)
80102150:	e8 20 11 00 00       	call   80103275 <log_write>
80102155:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	ff 75 f0             	push   -0x10(%ebp)
8010215e:	e8 20 e1 ff ff       	call   80100283 <brelse>
80102163:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102166:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102169:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 10             	add    %eax,0x10(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 0c             	add    %eax,0xc(%ebp)
80102178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010217e:	0f 82 5d ff ff ff    	jb     801020e1 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
80102184:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102188:	74 22                	je     801021ac <writei+0x181>
8010218a:	8b 45 08             	mov    0x8(%ebp),%eax
8010218d:	8b 40 58             	mov    0x58(%eax),%eax
80102190:	39 45 10             	cmp    %eax,0x10(%ebp)
80102193:	76 17                	jbe    801021ac <writei+0x181>
    ip->size = off;
80102195:	8b 45 08             	mov    0x8(%ebp),%eax
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010219e:	83 ec 0c             	sub    $0xc,%esp
801021a1:	ff 75 08             	push   0x8(%ebp)
801021a4:	e8 64 f6 ff ff       	call   8010180d <iupdate>
801021a9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021ac:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021b7:	83 ec 04             	sub    $0x4,%esp
801021ba:	6a 0e                	push   $0xe
801021bc:	ff 75 0c             	push   0xc(%ebp)
801021bf:	ff 75 08             	push   0x8(%ebp)
801021c2:	e8 0d 29 00 00       	call   80104ad4 <strncmp>
801021c7:	83 c4 10             	add    $0x10,%esp
}
801021ca:	c9                   	leave  
801021cb:	c3                   	ret    

801021cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021cc:	55                   	push   %ebp
801021cd:	89 e5                	mov    %esp,%ebp
801021cf:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021d9:	66 83 f8 01          	cmp    $0x1,%ax
801021dd:	74 0d                	je     801021ec <dirlookup+0x20>
    panic("dirlookup not DIR");
801021df:	83 ec 0c             	sub    $0xc,%esp
801021e2:	68 fd a1 10 80       	push   $0x8010a1fd
801021e7:	e8 bd e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f3:	eb 7b                	jmp    80102270 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f5:	6a 10                	push   $0x10
801021f7:	ff 75 f4             	push   -0xc(%ebp)
801021fa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021fd:	50                   	push   %eax
801021fe:	ff 75 08             	push   0x8(%ebp)
80102201:	e8 d0 fc ff ff       	call   80101ed6 <readi>
80102206:	83 c4 10             	add    $0x10,%esp
80102209:	83 f8 10             	cmp    $0x10,%eax
8010220c:	74 0d                	je     8010221b <dirlookup+0x4f>
      panic("dirlookup read");
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	68 0f a2 10 80       	push   $0x8010a20f
80102216:	e8 8e e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
8010221b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010221f:	66 85 c0             	test   %ax,%ax
80102222:	74 47                	je     8010226b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102224:	83 ec 08             	sub    $0x8,%esp
80102227:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222a:	83 c0 02             	add    $0x2,%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 0c             	push   0xc(%ebp)
80102231:	e8 7b ff ff ff       	call   801021b1 <namecmp>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 2f                	jne    8010226c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010223d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102241:	74 08                	je     8010224b <dirlookup+0x7f>
        *poff = off;
80102243:	8b 45 10             	mov    0x10(%ebp),%eax
80102246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102249:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	0f b7 c0             	movzwl %ax,%eax
80102252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102255:	8b 45 08             	mov    0x8(%ebp),%eax
80102258:	8b 00                	mov    (%eax),%eax
8010225a:	83 ec 08             	sub    $0x8,%esp
8010225d:	ff 75 f0             	push   -0x10(%ebp)
80102260:	50                   	push   %eax
80102261:	e8 68 f6 ff ff       	call   801018ce <iget>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	eb 19                	jmp    80102284 <dirlookup+0xb8>
      continue;
8010226b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010226c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	8b 40 58             	mov    0x58(%eax),%eax
80102276:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102279:	0f 82 76 ff ff ff    	jb     801021f5 <dirlookup+0x29>
    }
  }

  return 0;
8010227f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102286:	55                   	push   %ebp
80102287:	89 e5                	mov    %esp,%ebp
80102289:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	83 ec 04             	sub    $0x4,%esp
8010228f:	6a 00                	push   $0x0
80102291:	ff 75 0c             	push   0xc(%ebp)
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 30 ff ff ff       	call   801021cc <dirlookup>
8010229c:	83 c4 10             	add    $0x10,%esp
8010229f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022a6:	74 18                	je     801022c0 <dirlink+0x3a>
    iput(ip);
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	ff 75 f0             	push   -0x10(%ebp)
801022ae:	e8 98 f8 ff ff       	call   80101b4b <iput>
801022b3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022bb:	e9 9c 00 00 00       	jmp    8010235c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c7:	eb 39                	jmp    80102302 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	6a 10                	push   $0x10
801022ce:	50                   	push   %eax
801022cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d2:	50                   	push   %eax
801022d3:	ff 75 08             	push   0x8(%ebp)
801022d6:	e8 fb fb ff ff       	call   80101ed6 <readi>
801022db:	83 c4 10             	add    $0x10,%esp
801022de:	83 f8 10             	cmp    $0x10,%eax
801022e1:	74 0d                	je     801022f0 <dirlink+0x6a>
      panic("dirlink read");
801022e3:	83 ec 0c             	sub    $0xc,%esp
801022e6:	68 1e a2 10 80       	push   $0x8010a21e
801022eb:	e8 b9 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022f4:	66 85 c0             	test   %ax,%ax
801022f7:	74 18                	je     80102311 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	83 c0 10             	add    $0x10,%eax
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	8b 45 08             	mov    0x8(%ebp),%eax
80102305:	8b 50 58             	mov    0x58(%eax),%edx
80102308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230b:	39 c2                	cmp    %eax,%edx
8010230d:	77 ba                	ja     801022c9 <dirlink+0x43>
8010230f:	eb 01                	jmp    80102312 <dirlink+0x8c>
      break;
80102311:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102312:	83 ec 04             	sub    $0x4,%esp
80102315:	6a 0e                	push   $0xe
80102317:	ff 75 0c             	push   0xc(%ebp)
8010231a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010231d:	83 c0 02             	add    $0x2,%eax
80102320:	50                   	push   %eax
80102321:	e8 04 28 00 00       	call   80104b2a <strncpy>
80102326:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	6a 10                	push   $0x10
80102335:	50                   	push   %eax
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	50                   	push   %eax
8010233a:	ff 75 08             	push   0x8(%ebp)
8010233d:	e8 e9 fc ff ff       	call   8010202b <writei>
80102342:	83 c4 10             	add    $0x10,%esp
80102345:	83 f8 10             	cmp    $0x10,%eax
80102348:	74 0d                	je     80102357 <dirlink+0xd1>
    panic("dirlink");
8010234a:	83 ec 0c             	sub    $0xc,%esp
8010234d:	68 2b a2 10 80       	push   $0x8010a22b
80102352:	e8 52 e2 ff ff       	call   801005a9 <panic>

  return 0;
80102357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010235c:	c9                   	leave  
8010235d:	c3                   	ret    

8010235e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010235e:	55                   	push   %ebp
8010235f:	89 e5                	mov    %esp,%ebp
80102361:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102364:	eb 04                	jmp    8010236a <skipelem+0xc>
    path++;
80102366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010236a:	8b 45 08             	mov    0x8(%ebp),%eax
8010236d:	0f b6 00             	movzbl (%eax),%eax
80102370:	3c 2f                	cmp    $0x2f,%al
80102372:	74 f2                	je     80102366 <skipelem+0x8>
  if(*path == 0)
80102374:	8b 45 08             	mov    0x8(%ebp),%eax
80102377:	0f b6 00             	movzbl (%eax),%eax
8010237a:	84 c0                	test   %al,%al
8010237c:	75 07                	jne    80102385 <skipelem+0x27>
    return 0;
8010237e:	b8 00 00 00 00       	mov    $0x0,%eax
80102383:	eb 77                	jmp    801023fc <skipelem+0x9e>
  s = path;
80102385:	8b 45 08             	mov    0x8(%ebp),%eax
80102388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010238b:	eb 04                	jmp    80102391 <skipelem+0x33>
    path++;
8010238d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102391:	8b 45 08             	mov    0x8(%ebp),%eax
80102394:	0f b6 00             	movzbl (%eax),%eax
80102397:	3c 2f                	cmp    $0x2f,%al
80102399:	74 0a                	je     801023a5 <skipelem+0x47>
8010239b:	8b 45 08             	mov    0x8(%ebp),%eax
8010239e:	0f b6 00             	movzbl (%eax),%eax
801023a1:	84 c0                	test   %al,%al
801023a3:	75 e8                	jne    8010238d <skipelem+0x2f>
  len = path - s;
801023a5:	8b 45 08             	mov    0x8(%ebp),%eax
801023a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023b2:	7e 15                	jle    801023c9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023b4:	83 ec 04             	sub    $0x4,%esp
801023b7:	6a 0e                	push   $0xe
801023b9:	ff 75 f4             	push   -0xc(%ebp)
801023bc:	ff 75 0c             	push   0xc(%ebp)
801023bf:	e8 7a 26 00 00       	call   80104a3e <memmove>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	eb 26                	jmp    801023ef <skipelem+0x91>
  else {
    memmove(name, s, len);
801023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cc:	83 ec 04             	sub    $0x4,%esp
801023cf:	50                   	push   %eax
801023d0:	ff 75 f4             	push   -0xc(%ebp)
801023d3:	ff 75 0c             	push   0xc(%ebp)
801023d6:	e8 63 26 00 00       	call   80104a3e <memmove>
801023db:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e4:	01 d0                	add    %edx,%eax
801023e6:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023e9:	eb 04                	jmp    801023ef <skipelem+0x91>
    path++;
801023eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b6 00             	movzbl (%eax),%eax
801023f5:	3c 2f                	cmp    $0x2f,%al
801023f7:	74 f2                	je     801023eb <skipelem+0x8d>
  return path;
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023fc:	c9                   	leave  
801023fd:	c3                   	ret    

801023fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023fe:	55                   	push   %ebp
801023ff:	89 e5                	mov    %esp,%ebp
80102401:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	75 17                	jne    80102425 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010240e:	83 ec 08             	sub    $0x8,%esp
80102411:	6a 01                	push   $0x1
80102413:	6a 01                	push   $0x1
80102415:	e8 b4 f4 ff ff       	call   801018ce <iget>
8010241a:	83 c4 10             	add    $0x10,%esp
8010241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102420:	e9 ba 00 00 00       	jmp    801024df <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102425:	e8 06 16 00 00       	call   80103a30 <myproc>
8010242a:	8b 40 68             	mov    0x68(%eax),%eax
8010242d:	83 ec 0c             	sub    $0xc,%esp
80102430:	50                   	push   %eax
80102431:	e8 7a f5 ff ff       	call   801019b0 <idup>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010243c:	e9 9e 00 00 00       	jmp    801024df <namex+0xe1>
    ilock(ip);
80102441:	83 ec 0c             	sub    $0xc,%esp
80102444:	ff 75 f4             	push   -0xc(%ebp)
80102447:	e8 9e f5 ff ff       	call   801019ea <ilock>
8010244c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102452:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102456:	66 83 f8 01          	cmp    $0x1,%ax
8010245a:	74 18                	je     80102474 <namex+0x76>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 b4 f7 ff ff       	call   80101c1b <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	e9 a7 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
80102474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102478:	74 20                	je     8010249a <namex+0x9c>
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	0f b6 00             	movzbl (%eax),%eax
80102480:	84 c0                	test   %al,%al
80102482:	75 16                	jne    8010249a <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
80102484:	83 ec 0c             	sub    $0xc,%esp
80102487:	ff 75 f4             	push   -0xc(%ebp)
8010248a:	e8 6e f6 ff ff       	call   80101afd <iunlock>
8010248f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	e9 81 00 00 00       	jmp    8010251b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010249a:	83 ec 04             	sub    $0x4,%esp
8010249d:	6a 00                	push   $0x0
8010249f:	ff 75 10             	push   0x10(%ebp)
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 22 fd ff ff       	call   801021cc <dirlookup>
801024aa:	83 c4 10             	add    $0x10,%esp
801024ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024b4:	75 15                	jne    801024cb <namex+0xcd>
      iunlockput(ip);
801024b6:	83 ec 0c             	sub    $0xc,%esp
801024b9:	ff 75 f4             	push   -0xc(%ebp)
801024bc:	e8 5a f7 ff ff       	call   80101c1b <iunlockput>
801024c1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024c4:	b8 00 00 00 00       	mov    $0x0,%eax
801024c9:	eb 50                	jmp    8010251b <namex+0x11d>
    }
    iunlockput(ip);
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	ff 75 f4             	push   -0xc(%ebp)
801024d1:	e8 45 f7 ff ff       	call   80101c1b <iunlockput>
801024d6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024df:	83 ec 08             	sub    $0x8,%esp
801024e2:	ff 75 10             	push   0x10(%ebp)
801024e5:	ff 75 08             	push   0x8(%ebp)
801024e8:	e8 71 fe ff ff       	call   8010235e <skipelem>
801024ed:	83 c4 10             	add    $0x10,%esp
801024f0:	89 45 08             	mov    %eax,0x8(%ebp)
801024f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024f7:	0f 85 44 ff ff ff    	jne    80102441 <namex+0x43>
  }
  if(nameiparent){
801024fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102501:	74 15                	je     80102518 <namex+0x11a>
    iput(ip);
80102503:	83 ec 0c             	sub    $0xc,%esp
80102506:	ff 75 f4             	push   -0xc(%ebp)
80102509:	e8 3d f6 ff ff       	call   80101b4b <iput>
8010250e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102511:	b8 00 00 00 00       	mov    $0x0,%eax
80102516:	eb 03                	jmp    8010251b <namex+0x11d>
  }
  return ip;
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <namei>:

struct inode*
namei(char *path)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102523:	83 ec 04             	sub    $0x4,%esp
80102526:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102529:	50                   	push   %eax
8010252a:	6a 00                	push   $0x0
8010252c:	ff 75 08             	push   0x8(%ebp)
8010252f:	e8 ca fe ff ff       	call   801023fe <namex>
80102534:	83 c4 10             	add    $0x10,%esp
}
80102537:	c9                   	leave  
80102538:	c3                   	ret    

80102539 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102539:	55                   	push   %ebp
8010253a:	89 e5                	mov    %esp,%ebp
8010253c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010253f:	83 ec 04             	sub    $0x4,%esp
80102542:	ff 75 0c             	push   0xc(%ebp)
80102545:	6a 01                	push   $0x1
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 af fe ff ff       	call   801023fe <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <ioapicread>:
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010255c:	8b 55 08             	mov    0x8(%ebp),%edx
8010255f:	89 10                	mov    %edx,(%eax)
80102561:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102566:	8b 40 10             	mov    0x10(%eax),%eax
80102569:	5d                   	pop    %ebp
8010256a:	c3                   	ret    

8010256b <ioapicwrite>:
8010256b:	55                   	push   %ebp
8010256c:	89 e5                	mov    %esp,%ebp
8010256e:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102573:	8b 55 08             	mov    0x8(%ebp),%edx
80102576:	89 10                	mov    %edx,(%eax)
80102578:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102580:	89 50 10             	mov    %edx,0x10(%eax)
80102583:	90                   	nop
80102584:	5d                   	pop    %ebp
80102585:	c3                   	ret    

80102586 <ioapicinit>:
80102586:	55                   	push   %ebp
80102587:	89 e5                	mov    %esp,%ebp
80102589:	83 ec 18             	sub    $0x18,%esp
8010258c:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
80102593:	00 c0 fe 
80102596:	6a 01                	push   $0x1
80102598:	e8 b7 ff ff ff       	call   80102554 <ioapicread>
8010259d:	83 c4 04             	add    $0x4,%esp
801025a0:	c1 e8 10             	shr    $0x10,%eax
801025a3:	25 ff 00 00 00       	and    $0xff,%eax
801025a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025ab:	6a 00                	push   $0x0
801025ad:	e8 a2 ff ff ff       	call   80102554 <ioapicread>
801025b2:	83 c4 04             	add    $0x4,%esp
801025b5:	c1 e8 18             	shr    $0x18,%eax
801025b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801025bb:	0f b6 05 44 6e 19 80 	movzbl 0x80196e44,%eax
801025c2:	0f b6 c0             	movzbl %al,%eax
801025c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025c8:	74 10                	je     801025da <ioapicinit+0x54>
801025ca:	83 ec 0c             	sub    $0xc,%esp
801025cd:	68 34 a2 10 80       	push   $0x8010a234
801025d2:	e8 1d de ff ff       	call   801003f4 <cprintf>
801025d7:	83 c4 10             	add    $0x10,%esp
801025da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e1:	eb 3f                	jmp    80102622 <ioapicinit+0x9c>
801025e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e6:	83 c0 20             	add    $0x20,%eax
801025e9:	0d 00 00 01 00       	or     $0x10000,%eax
801025ee:	89 c2                	mov    %eax,%edx
801025f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f3:	83 c0 08             	add    $0x8,%eax
801025f6:	01 c0                	add    %eax,%eax
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	52                   	push   %edx
801025fc:	50                   	push   %eax
801025fd:	e8 69 ff ff ff       	call   8010256b <ioapicwrite>
80102602:	83 c4 10             	add    $0x10,%esp
80102605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102608:	83 c0 08             	add    $0x8,%eax
8010260b:	01 c0                	add    %eax,%eax
8010260d:	83 c0 01             	add    $0x1,%eax
80102610:	83 ec 08             	sub    $0x8,%esp
80102613:	6a 00                	push   $0x0
80102615:	50                   	push   %eax
80102616:	e8 50 ff ff ff       	call   8010256b <ioapicwrite>
8010261b:	83 c4 10             	add    $0x10,%esp
8010261e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102625:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102628:	7e b9                	jle    801025e3 <ioapicinit+0x5d>
8010262a:	90                   	nop
8010262b:	90                   	nop
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <ioapicenable>:
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	83 c0 20             	add    $0x20,%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 08             	add    $0x8,%eax
8010263f:	01 c0                	add    %eax,%eax
80102641:	52                   	push   %edx
80102642:	50                   	push   %eax
80102643:	e8 23 ff ff ff       	call   8010256b <ioapicwrite>
80102648:	83 c4 08             	add    $0x8,%esp
8010264b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010264e:	c1 e0 18             	shl    $0x18,%eax
80102651:	89 c2                	mov    %eax,%edx
80102653:	8b 45 08             	mov    0x8(%ebp),%eax
80102656:	83 c0 08             	add    $0x8,%eax
80102659:	01 c0                	add    %eax,%eax
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	52                   	push   %edx
8010265f:	50                   	push   %eax
80102660:	e8 06 ff ff ff       	call   8010256b <ioapicwrite>
80102665:	83 c4 08             	add    $0x8,%esp
80102668:	90                   	nop
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <kinit1>:
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	83 ec 08             	sub    $0x8,%esp
80102674:	68 66 a2 10 80       	push   $0x8010a266
80102679:	68 c0 40 19 80       	push   $0x801940c0
8010267e:	e8 64 20 00 00       	call   801046e7 <initlock>
80102683:	83 c4 10             	add    $0x10,%esp
80102686:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
8010268d:	00 00 00 
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	ff 75 0c             	push   0xc(%ebp)
80102696:	ff 75 08             	push   0x8(%ebp)
80102699:	e8 2a 00 00 00       	call   801026c8 <freerange>
8010269e:	83 c4 10             	add    $0x10,%esp
801026a1:	90                   	nop
801026a2:	c9                   	leave  
801026a3:	c3                   	ret    

801026a4 <kinit2>:
801026a4:	55                   	push   %ebp
801026a5:	89 e5                	mov    %esp,%ebp
801026a7:	83 ec 08             	sub    $0x8,%esp
801026aa:	83 ec 08             	sub    $0x8,%esp
801026ad:	ff 75 0c             	push   0xc(%ebp)
801026b0:	ff 75 08             	push   0x8(%ebp)
801026b3:	e8 10 00 00 00       	call   801026c8 <freerange>
801026b8:	83 c4 10             	add    $0x10,%esp
801026bb:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026c2:	00 00 00 
801026c5:	90                   	nop
801026c6:	c9                   	leave  
801026c7:	c3                   	ret    

801026c8 <freerange>:
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	83 ec 18             	sub    $0x18,%esp
801026ce:	8b 45 08             	mov    0x8(%ebp),%eax
801026d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026de:	eb 15                	jmp    801026f5 <freerange+0x2d>
801026e0:	83 ec 0c             	sub    $0xc,%esp
801026e3:	ff 75 f4             	push   -0xc(%ebp)
801026e6:	e8 1b 00 00 00       	call   80102706 <kfree>
801026eb:	83 c4 10             	add    $0x10,%esp
801026ee:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	05 00 10 00 00       	add    $0x1000,%eax
801026fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102700:	73 de                	jae    801026e0 <freerange+0x18>
80102702:	90                   	nop
80102703:	90                   	nop
80102704:	c9                   	leave  
80102705:	c3                   	ret    

80102706 <kfree>:
80102706:	55                   	push   %ebp
80102707:	89 e5                	mov    %esp,%ebp
80102709:	83 ec 18             	sub    $0x18,%esp
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102714:	85 c0                	test   %eax,%eax
80102716:	75 18                	jne    80102730 <kfree+0x2a>
80102718:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010271f:	72 0f                	jb     80102730 <kfree+0x2a>
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	05 00 00 00 80       	add    $0x80000000,%eax
80102729:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010272e:	76 0d                	jbe    8010273d <kfree+0x37>
80102730:	83 ec 0c             	sub    $0xc,%esp
80102733:	68 6b a2 10 80       	push   $0x8010a26b
80102738:	e8 6c de ff ff       	call   801005a9 <panic>
8010273d:	83 ec 04             	sub    $0x4,%esp
80102740:	68 00 10 00 00       	push   $0x1000
80102745:	6a 01                	push   $0x1
80102747:	ff 75 08             	push   0x8(%ebp)
8010274a:	e8 30 22 00 00       	call   8010497f <memset>
8010274f:	83 c4 10             	add    $0x10,%esp
80102752:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102757:	85 c0                	test   %eax,%eax
80102759:	74 10                	je     8010276b <kfree+0x65>
8010275b:	83 ec 0c             	sub    $0xc,%esp
8010275e:	68 c0 40 19 80       	push   $0x801940c0
80102763:	e8 a1 1f 00 00       	call   80104709 <acquire>
80102768:	83 c4 10             	add    $0x10,%esp
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102771:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
80102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277a:	89 10                	mov    %edx,(%eax)
8010277c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277f:	a3 f8 40 19 80       	mov    %eax,0x801940f8
80102784:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102789:	85 c0                	test   %eax,%eax
8010278b:	74 10                	je     8010279d <kfree+0x97>
8010278d:	83 ec 0c             	sub    $0xc,%esp
80102790:	68 c0 40 19 80       	push   $0x801940c0
80102795:	e8 dd 1f 00 00       	call   80104777 <release>
8010279a:	83 c4 10             	add    $0x10,%esp
8010279d:	90                   	nop
8010279e:	c9                   	leave  
8010279f:	c3                   	ret    

801027a0 <kalloc>:
801027a0:	55                   	push   %ebp
801027a1:	89 e5                	mov    %esp,%ebp
801027a3:	83 ec 18             	sub    $0x18,%esp
801027a6:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ab:	85 c0                	test   %eax,%eax
801027ad:	74 10                	je     801027bf <kalloc+0x1f>
801027af:	83 ec 0c             	sub    $0xc,%esp
801027b2:	68 c0 40 19 80       	push   $0x801940c0
801027b7:	e8 4d 1f 00 00       	call   80104709 <acquire>
801027bc:	83 c4 10             	add    $0x10,%esp
801027bf:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027cb:	74 0a                	je     801027d7 <kalloc+0x37>
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	8b 00                	mov    (%eax),%eax
801027d2:	a3 f8 40 19 80       	mov    %eax,0x801940f8
801027d7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027dc:	85 c0                	test   %eax,%eax
801027de:	74 10                	je     801027f0 <kalloc+0x50>
801027e0:	83 ec 0c             	sub    $0xc,%esp
801027e3:	68 c0 40 19 80       	push   $0x801940c0
801027e8:	e8 8a 1f 00 00       	call   80104777 <release>
801027ed:	83 c4 10             	add    $0x10,%esp
801027f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    

801027f5 <inb>:
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102802:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102806:	89 c2                	mov    %eax,%edx
80102808:	ec                   	in     (%dx),%al
80102809:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010280c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102810:	c9                   	leave  
80102811:	c3                   	ret    

80102812 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102812:	55                   	push   %ebp
80102813:	89 e5                	mov    %esp,%ebp
80102815:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102818:	6a 64                	push   $0x64
8010281a:	e8 d6 ff ff ff       	call   801027f5 <inb>
8010281f:	83 c4 04             	add    $0x4,%esp
80102822:	0f b6 c0             	movzbl %al,%eax
80102825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282b:	83 e0 01             	and    $0x1,%eax
8010282e:	85 c0                	test   %eax,%eax
80102830:	75 0a                	jne    8010283c <kbdgetc+0x2a>
    return -1;
80102832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102837:	e9 23 01 00 00       	jmp    8010295f <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010283c:	6a 60                	push   $0x60
8010283e:	e8 b2 ff ff ff       	call   801027f5 <inb>
80102843:	83 c4 04             	add    $0x4,%esp
80102846:	0f b6 c0             	movzbl %al,%eax
80102849:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010284c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102853:	75 17                	jne    8010286c <kbdgetc+0x5a>
    shift |= E0ESC;
80102855:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010285a:	83 c8 40             	or     $0x40,%eax
8010285d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102862:	b8 00 00 00 00       	mov    $0x0,%eax
80102867:	e9 f3 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(data & 0x80){
8010286c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010286f:	25 80 00 00 00       	and    $0x80,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	74 45                	je     801028bd <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102878:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010287d:	83 e0 40             	and    $0x40,%eax
80102880:	85 c0                	test   %eax,%eax
80102882:	75 08                	jne    8010288c <kbdgetc+0x7a>
80102884:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102887:	83 e0 7f             	and    $0x7f,%eax
8010288a:	eb 03                	jmp    8010288f <kbdgetc+0x7d>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102892:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102895:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010289a:	0f b6 00             	movzbl (%eax),%eax
8010289d:	83 c8 40             	or     $0x40,%eax
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	f7 d0                	not    %eax
801028a5:	89 c2                	mov    %eax,%edx
801028a7:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ac:	21 d0                	and    %edx,%eax
801028ae:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028b3:	b8 00 00 00 00       	mov    $0x0,%eax
801028b8:	e9 a2 00 00 00       	jmp    8010295f <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028bd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028c2:	83 e0 40             	and    $0x40,%eax
801028c5:	85 c0                	test   %eax,%eax
801028c7:	74 14                	je     801028dd <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028c9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d0:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028d5:	83 e0 bf             	and    $0xffffffbf,%eax
801028d8:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e0:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028e5:	0f b6 00             	movzbl (%eax),%eax
801028e8:	0f b6 d0             	movzbl %al,%edx
801028eb:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f0:	09 d0                	or     %edx,%eax
801028f2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d1 10 80       	add    $0x8010d120,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	0f b6 d0             	movzbl %al,%edx
80102905:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010290a:	31 d0                	xor    %edx,%eax
8010290c:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102911:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102916:	83 e0 03             	and    $0x3,%eax
80102919:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102923:	01 d0                	add    %edx,%eax
80102925:	0f b6 00             	movzbl (%eax),%eax
80102928:	0f b6 c0             	movzbl %al,%eax
8010292b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010292e:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102933:	83 e0 08             	and    $0x8,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	74 22                	je     8010295c <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010293a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010293e:	76 0c                	jbe    8010294c <kbdgetc+0x13a>
80102940:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102944:	77 06                	ja     8010294c <kbdgetc+0x13a>
      c += 'A' - 'a';
80102946:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
8010294a:	eb 10                	jmp    8010295c <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
8010294c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102950:	76 0a                	jbe    8010295c <kbdgetc+0x14a>
80102952:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102956:	77 04                	ja     8010295c <kbdgetc+0x14a>
      c += 'a' - 'A';
80102958:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010295c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010295f:	c9                   	leave  
80102960:	c3                   	ret    

80102961 <kbdintr>:

void
kbdintr(void)
{
80102961:	55                   	push   %ebp
80102962:	89 e5                	mov    %esp,%ebp
80102964:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	68 12 28 10 80       	push   $0x80102812
8010296f:	e8 62 de ff ff       	call   801007d6 <consoleintr>
80102974:	83 c4 10             	add    $0x10,%esp
}
80102977:	90                   	nop
80102978:	c9                   	leave  
80102979:	c3                   	ret    

8010297a <inb>:
{
8010297a:	55                   	push   %ebp
8010297b:	89 e5                	mov    %esp,%ebp
8010297d:	83 ec 14             	sub    $0x14,%esp
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102987:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010298b:	89 c2                	mov    %eax,%edx
8010298d:	ec                   	in     (%dx),%al
8010298e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102991:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102995:	c9                   	leave  
80102996:	c3                   	ret    

80102997 <outb>:
{
80102997:	55                   	push   %ebp
80102998:	89 e5                	mov    %esp,%ebp
8010299a:	83 ec 08             	sub    $0x8,%esp
8010299d:	8b 45 08             	mov    0x8(%ebp),%eax
801029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801029a3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801029a7:	89 d0                	mov    %edx,%eax
801029a9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029ac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029b4:	ee                   	out    %al,(%dx)
}
801029b5:	90                   	nop
801029b6:	c9                   	leave  
801029b7:	c3                   	ret    

801029b8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029bb:	8b 15 00 41 19 80    	mov    0x80194100,%edx
801029c1:	8b 45 08             	mov    0x8(%ebp),%eax
801029c4:	c1 e0 02             	shl    $0x2,%eax
801029c7:	01 c2                	add    %eax,%edx
801029c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029cc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d3:	83 c0 20             	add    $0x20,%eax
801029d6:	8b 00                	mov    (%eax),%eax
}
801029d8:	90                   	nop
801029d9:	5d                   	pop    %ebp
801029da:	c3                   	ret    

801029db <lapicinit>:

void
lapicinit(void)
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029de:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e3:	85 c0                	test   %eax,%eax
801029e5:	0f 84 0c 01 00 00    	je     80102af7 <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029eb:	68 3f 01 00 00       	push   $0x13f
801029f0:	6a 3c                	push   $0x3c
801029f2:	e8 c1 ff ff ff       	call   801029b8 <lapicw>
801029f7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029fa:	6a 0b                	push   $0xb
801029fc:	68 f8 00 00 00       	push   $0xf8
80102a01:	e8 b2 ff ff ff       	call   801029b8 <lapicw>
80102a06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a09:	68 20 00 02 00       	push   $0x20020
80102a0e:	68 c8 00 00 00       	push   $0xc8
80102a13:	e8 a0 ff ff ff       	call   801029b8 <lapicw>
80102a18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a1b:	68 80 96 98 00       	push   $0x989680
80102a20:	68 e0 00 00 00       	push   $0xe0
80102a25:	e8 8e ff ff ff       	call   801029b8 <lapicw>
80102a2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a2d:	68 00 00 01 00       	push   $0x10000
80102a32:	68 d4 00 00 00       	push   $0xd4
80102a37:	e8 7c ff ff ff       	call   801029b8 <lapicw>
80102a3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a3f:	68 00 00 01 00       	push   $0x10000
80102a44:	68 d8 00 00 00       	push   $0xd8
80102a49:	e8 6a ff ff ff       	call   801029b8 <lapicw>
80102a4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a51:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a56:	83 c0 30             	add    $0x30,%eax
80102a59:	8b 00                	mov    (%eax),%eax
80102a5b:	c1 e8 10             	shr    $0x10,%eax
80102a5e:	25 fc 00 00 00       	and    $0xfc,%eax
80102a63:	85 c0                	test   %eax,%eax
80102a65:	74 12                	je     80102a79 <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102a67:	68 00 00 01 00       	push   $0x10000
80102a6c:	68 d0 00 00 00       	push   $0xd0
80102a71:	e8 42 ff ff ff       	call   801029b8 <lapicw>
80102a76:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a79:	6a 33                	push   $0x33
80102a7b:	68 dc 00 00 00       	push   $0xdc
80102a80:	e8 33 ff ff ff       	call   801029b8 <lapicw>
80102a85:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a88:	6a 00                	push   $0x0
80102a8a:	68 a0 00 00 00       	push   $0xa0
80102a8f:	e8 24 ff ff ff       	call   801029b8 <lapicw>
80102a94:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a97:	6a 00                	push   $0x0
80102a99:	68 a0 00 00 00       	push   $0xa0
80102a9e:	e8 15 ff ff ff       	call   801029b8 <lapicw>
80102aa3:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa6:	6a 00                	push   $0x0
80102aa8:	6a 2c                	push   $0x2c
80102aaa:	e8 09 ff ff ff       	call   801029b8 <lapicw>
80102aaf:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab2:	6a 00                	push   $0x0
80102ab4:	68 c4 00 00 00       	push   $0xc4
80102ab9:	e8 fa fe ff ff       	call   801029b8 <lapicw>
80102abe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac1:	68 00 85 08 00       	push   $0x88500
80102ac6:	68 c0 00 00 00       	push   $0xc0
80102acb:	e8 e8 fe ff ff       	call   801029b8 <lapicw>
80102ad0:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad3:	90                   	nop
80102ad4:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ad9:	05 00 03 00 00       	add    $0x300,%eax
80102ade:	8b 00                	mov    (%eax),%eax
80102ae0:	25 00 10 00 00       	and    $0x1000,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	75 eb                	jne    80102ad4 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ae9:	6a 00                	push   $0x0
80102aeb:	6a 20                	push   $0x20
80102aed:	e8 c6 fe ff ff       	call   801029b8 <lapicw>
80102af2:	83 c4 08             	add    $0x8,%esp
80102af5:	eb 01                	jmp    80102af8 <lapicinit+0x11d>
    return;
80102af7:	90                   	nop
}
80102af8:	c9                   	leave  
80102af9:	c3                   	ret    

80102afa <lapicid>:

int
lapicid(void)
{
80102afa:	55                   	push   %ebp
80102afb:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102afd:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	75 07                	jne    80102b0d <lapicid+0x13>
    return 0;
80102b06:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0b:	eb 0d                	jmp    80102b1a <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0d:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b12:	83 c0 20             	add    $0x20,%eax
80102b15:	8b 00                	mov    (%eax),%eax
80102b17:	c1 e8 18             	shr    $0x18,%eax
}
80102b1a:	5d                   	pop    %ebp
80102b1b:	c3                   	ret    

80102b1c <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b1f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b24:	85 c0                	test   %eax,%eax
80102b26:	74 0c                	je     80102b34 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b28:	6a 00                	push   $0x0
80102b2a:	6a 2c                	push   $0x2c
80102b2c:	e8 87 fe ff ff       	call   801029b8 <lapicw>
80102b31:	83 c4 08             	add    $0x8,%esp
}
80102b34:	90                   	nop
80102b35:	c9                   	leave  
80102b36:	c3                   	ret    

80102b37 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b37:	55                   	push   %ebp
80102b38:	89 e5                	mov    %esp,%ebp
}
80102b3a:	90                   	nop
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 14             	sub    $0x14,%esp
80102b43:	8b 45 08             	mov    0x8(%ebp),%eax
80102b46:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b49:	6a 0f                	push   $0xf
80102b4b:	6a 70                	push   $0x70
80102b4d:	e8 45 fe ff ff       	call   80102997 <outb>
80102b52:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b55:	6a 0a                	push   $0xa
80102b57:	6a 71                	push   $0x71
80102b59:	e8 39 fe ff ff       	call   80102997 <outb>
80102b5e:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b61:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b73:	c1 e8 04             	shr    $0x4,%eax
80102b76:	89 c2                	mov    %eax,%edx
80102b78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7b:	83 c0 02             	add    $0x2,%eax
80102b7e:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b81:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b85:	c1 e0 18             	shl    $0x18,%eax
80102b88:	50                   	push   %eax
80102b89:	68 c4 00 00 00       	push   $0xc4
80102b8e:	e8 25 fe ff ff       	call   801029b8 <lapicw>
80102b93:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b96:	68 00 c5 00 00       	push   $0xc500
80102b9b:	68 c0 00 00 00       	push   $0xc0
80102ba0:	e8 13 fe ff ff       	call   801029b8 <lapicw>
80102ba5:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ba8:	68 c8 00 00 00       	push   $0xc8
80102bad:	e8 85 ff ff ff       	call   80102b37 <microdelay>
80102bb2:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb5:	68 00 85 00 00       	push   $0x8500
80102bba:	68 c0 00 00 00       	push   $0xc0
80102bbf:	e8 f4 fd ff ff       	call   801029b8 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc7:	6a 64                	push   $0x64
80102bc9:	e8 69 ff ff ff       	call   80102b37 <microdelay>
80102bce:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bd8:	eb 3d                	jmp    80102c17 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bda:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102bde:	c1 e0 18             	shl    $0x18,%eax
80102be1:	50                   	push   %eax
80102be2:	68 c4 00 00 00       	push   $0xc4
80102be7:	e8 cc fd ff ff       	call   801029b8 <lapicw>
80102bec:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bef:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf2:	c1 e8 0c             	shr    $0xc,%eax
80102bf5:	80 cc 06             	or     $0x6,%ah
80102bf8:	50                   	push   %eax
80102bf9:	68 c0 00 00 00       	push   $0xc0
80102bfe:	e8 b5 fd ff ff       	call   801029b8 <lapicw>
80102c03:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c06:	68 c8 00 00 00       	push   $0xc8
80102c0b:	e8 27 ff ff ff       	call   80102b37 <microdelay>
80102c10:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c17:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1b:	7e bd                	jle    80102bda <lapicstartap+0x9d>
  }
}
80102c1d:	90                   	nop
80102c1e:	90                   	nop
80102c1f:	c9                   	leave  
80102c20:	c3                   	ret    

80102c21 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c21:	55                   	push   %ebp
80102c22:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c24:	8b 45 08             	mov    0x8(%ebp),%eax
80102c27:	0f b6 c0             	movzbl %al,%eax
80102c2a:	50                   	push   %eax
80102c2b:	6a 70                	push   $0x70
80102c2d:	e8 65 fd ff ff       	call   80102997 <outb>
80102c32:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c35:	68 c8 00 00 00       	push   $0xc8
80102c3a:	e8 f8 fe ff ff       	call   80102b37 <microdelay>
80102c3f:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c42:	6a 71                	push   $0x71
80102c44:	e8 31 fd ff ff       	call   8010297a <inb>
80102c49:	83 c4 04             	add    $0x4,%esp
80102c4c:	0f b6 c0             	movzbl %al,%eax
}
80102c4f:	c9                   	leave  
80102c50:	c3                   	ret    

80102c51 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c54:	6a 00                	push   $0x0
80102c56:	e8 c6 ff ff ff       	call   80102c21 <cmos_read>
80102c5b:	83 c4 04             	add    $0x4,%esp
80102c5e:	8b 55 08             	mov    0x8(%ebp),%edx
80102c61:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c63:	6a 02                	push   $0x2
80102c65:	e8 b7 ff ff ff       	call   80102c21 <cmos_read>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c70:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c73:	6a 04                	push   $0x4
80102c75:	e8 a7 ff ff ff       	call   80102c21 <cmos_read>
80102c7a:	83 c4 04             	add    $0x4,%esp
80102c7d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c80:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c83:	6a 07                	push   $0x7
80102c85:	e8 97 ff ff ff       	call   80102c21 <cmos_read>
80102c8a:	83 c4 04             	add    $0x4,%esp
80102c8d:	8b 55 08             	mov    0x8(%ebp),%edx
80102c90:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c93:	6a 08                	push   $0x8
80102c95:	e8 87 ff ff ff       	call   80102c21 <cmos_read>
80102c9a:	83 c4 04             	add    $0x4,%esp
80102c9d:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca3:	6a 09                	push   $0x9
80102ca5:	e8 77 ff ff ff       	call   80102c21 <cmos_read>
80102caa:	83 c4 04             	add    $0x4,%esp
80102cad:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb0:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb3:	90                   	nop
80102cb4:	c9                   	leave  
80102cb5:	c3                   	ret    

80102cb6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb6:	55                   	push   %ebp
80102cb7:	89 e5                	mov    %esp,%ebp
80102cb9:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbc:	6a 0b                	push   $0xb
80102cbe:	e8 5e ff ff ff       	call   80102c21 <cmos_read>
80102cc3:	83 c4 04             	add    $0x4,%esp
80102cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	83 e0 04             	and    $0x4,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	0f 94 c0             	sete   %al
80102cd4:	0f b6 c0             	movzbl %al,%eax
80102cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cda:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdd:	50                   	push   %eax
80102cde:	e8 6e ff ff ff       	call   80102c51 <fill_rtcdate>
80102ce3:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce6:	6a 0a                	push   $0xa
80102ce8:	e8 34 ff ff ff       	call   80102c21 <cmos_read>
80102ced:	83 c4 04             	add    $0x4,%esp
80102cf0:	25 80 00 00 00       	and    $0x80,%eax
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	75 27                	jne    80102d20 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cf9:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfc:	50                   	push   %eax
80102cfd:	e8 4f ff ff ff       	call   80102c51 <fill_rtcdate>
80102d02:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d05:	83 ec 04             	sub    $0x4,%esp
80102d08:	6a 18                	push   $0x18
80102d0a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0d:	50                   	push   %eax
80102d0e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d11:	50                   	push   %eax
80102d12:	e8 cf 1c 00 00       	call   801049e6 <memcmp>
80102d17:	83 c4 10             	add    $0x10,%esp
80102d1a:	85 c0                	test   %eax,%eax
80102d1c:	74 05                	je     80102d23 <cmostime+0x6d>
80102d1e:	eb ba                	jmp    80102cda <cmostime+0x24>
        continue;
80102d20:	90                   	nop
    fill_rtcdate(&t1);
80102d21:	eb b7                	jmp    80102cda <cmostime+0x24>
      break;
80102d23:	90                   	nop
  }

  // convert
  if(bcd) {
80102d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d28:	0f 84 b4 00 00 00    	je     80102de2 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d31:	c1 e8 04             	shr    $0x4,%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	89 d0                	mov    %edx,%eax
80102d38:	c1 e0 02             	shl    $0x2,%eax
80102d3b:	01 d0                	add    %edx,%eax
80102d3d:	01 c0                	add    %eax,%eax
80102d3f:	89 c2                	mov    %eax,%edx
80102d41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d44:	83 e0 0f             	and    $0xf,%eax
80102d47:	01 d0                	add    %edx,%eax
80102d49:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d4f:	c1 e8 04             	shr    $0x4,%eax
80102d52:	89 c2                	mov    %eax,%edx
80102d54:	89 d0                	mov    %edx,%eax
80102d56:	c1 e0 02             	shl    $0x2,%eax
80102d59:	01 d0                	add    %edx,%eax
80102d5b:	01 c0                	add    %eax,%eax
80102d5d:	89 c2                	mov    %eax,%edx
80102d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d62:	83 e0 0f             	and    $0xf,%eax
80102d65:	01 d0                	add    %edx,%eax
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6d:	c1 e8 04             	shr    $0x4,%eax
80102d70:	89 c2                	mov    %eax,%edx
80102d72:	89 d0                	mov    %edx,%eax
80102d74:	c1 e0 02             	shl    $0x2,%eax
80102d77:	01 d0                	add    %edx,%eax
80102d79:	01 c0                	add    %eax,%eax
80102d7b:	89 c2                	mov    %eax,%edx
80102d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d80:	83 e0 0f             	and    $0xf,%eax
80102d83:	01 d0                	add    %edx,%eax
80102d85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8b:	c1 e8 04             	shr    $0x4,%eax
80102d8e:	89 c2                	mov    %eax,%edx
80102d90:	89 d0                	mov    %edx,%eax
80102d92:	c1 e0 02             	shl    $0x2,%eax
80102d95:	01 d0                	add    %edx,%eax
80102d97:	01 c0                	add    %eax,%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d9e:	83 e0 0f             	and    $0xf,%eax
80102da1:	01 d0                	add    %edx,%eax
80102da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102da9:	c1 e8 04             	shr    $0x4,%eax
80102dac:	89 c2                	mov    %eax,%edx
80102dae:	89 d0                	mov    %edx,%eax
80102db0:	c1 e0 02             	shl    $0x2,%eax
80102db3:	01 d0                	add    %edx,%eax
80102db5:	01 c0                	add    %eax,%eax
80102db7:	89 c2                	mov    %eax,%edx
80102db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbc:	83 e0 0f             	and    $0xf,%eax
80102dbf:	01 d0                	add    %edx,%eax
80102dc1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc7:	c1 e8 04             	shr    $0x4,%eax
80102dca:	89 c2                	mov    %eax,%edx
80102dcc:	89 d0                	mov    %edx,%eax
80102dce:	c1 e0 02             	shl    $0x2,%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	01 c0                	add    %eax,%eax
80102dd5:	89 c2                	mov    %eax,%edx
80102dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	01 d0                	add    %edx,%eax
80102ddf:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de2:	8b 45 08             	mov    0x8(%ebp),%eax
80102de5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102de8:	89 10                	mov    %edx,(%eax)
80102dea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102ded:	89 50 04             	mov    %edx,0x4(%eax)
80102df0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df3:	89 50 08             	mov    %edx,0x8(%eax)
80102df6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102df9:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102dff:	89 50 10             	mov    %edx,0x10(%eax)
80102e02:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e05:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e08:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0b:	8b 40 14             	mov    0x14(%eax),%eax
80102e0e:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1a:	90                   	nop
80102e1b:	c9                   	leave  
80102e1c:	c3                   	ret    

80102e1d <initlog>:
80102e1d:	55                   	push   %ebp
80102e1e:	89 e5                	mov    %esp,%ebp
80102e20:	83 ec 28             	sub    $0x28,%esp
80102e23:	83 ec 08             	sub    $0x8,%esp
80102e26:	68 71 a2 10 80       	push   $0x8010a271
80102e2b:	68 20 41 19 80       	push   $0x80194120
80102e30:	e8 b2 18 00 00       	call   801046e7 <initlock>
80102e35:	83 c4 10             	add    $0x10,%esp
80102e38:	83 ec 08             	sub    $0x8,%esp
80102e3b:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	ff 75 08             	push   0x8(%ebp)
80102e42:	e8 87 e5 ff ff       	call   801013ce <readsb>
80102e47:	83 c4 10             	add    $0x10,%esp
80102e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4d:	a3 54 41 19 80       	mov    %eax,0x80194154
80102e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e55:	a3 58 41 19 80       	mov    %eax,0x80194158
80102e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5d:	a3 64 41 19 80       	mov    %eax,0x80194164
80102e62:	e8 b3 01 00 00       	call   8010301a <recover_from_log>
80102e67:	90                   	nop
80102e68:	c9                   	leave  
80102e69:	c3                   	ret    

80102e6a <install_trans>:
80102e6a:	55                   	push   %ebp
80102e6b:	89 e5                	mov    %esp,%ebp
80102e6d:	83 ec 18             	sub    $0x18,%esp
80102e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e77:	e9 95 00 00 00       	jmp    80102f11 <install_trans+0xa7>
80102e7c:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e85:	01 d0                	add    %edx,%eax
80102e87:	83 c0 01             	add    $0x1,%eax
80102e8a:	89 c2                	mov    %eax,%edx
80102e8c:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e91:	83 ec 08             	sub    $0x8,%esp
80102e94:	52                   	push   %edx
80102e95:	50                   	push   %eax
80102e96:	e8 66 d3 ff ff       	call   80100201 <bread>
80102e9b:	83 c4 10             	add    $0x10,%esp
80102e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea4:	83 c0 10             	add    $0x10,%eax
80102ea7:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eae:	89 c2                	mov    %eax,%edx
80102eb0:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb5:	83 ec 08             	sub    $0x8,%esp
80102eb8:	52                   	push   %edx
80102eb9:	50                   	push   %eax
80102eba:	e8 42 d3 ff ff       	call   80100201 <bread>
80102ebf:	83 c4 10             	add    $0x10,%esp
80102ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80102ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ec8:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ece:	83 c0 5c             	add    $0x5c,%eax
80102ed1:	83 ec 04             	sub    $0x4,%esp
80102ed4:	68 00 02 00 00       	push   $0x200
80102ed9:	52                   	push   %edx
80102eda:	50                   	push   %eax
80102edb:	e8 5e 1b 00 00       	call   80104a3e <memmove>
80102ee0:	83 c4 10             	add    $0x10,%esp
80102ee3:	83 ec 0c             	sub    $0xc,%esp
80102ee6:	ff 75 ec             	push   -0x14(%ebp)
80102ee9:	e8 4c d3 ff ff       	call   8010023a <bwrite>
80102eee:	83 c4 10             	add    $0x10,%esp
80102ef1:	83 ec 0c             	sub    $0xc,%esp
80102ef4:	ff 75 f0             	push   -0x10(%ebp)
80102ef7:	e8 87 d3 ff ff       	call   80100283 <brelse>
80102efc:	83 c4 10             	add    $0x10,%esp
80102eff:	83 ec 0c             	sub    $0xc,%esp
80102f02:	ff 75 ec             	push   -0x14(%ebp)
80102f05:	e8 79 d3 ff ff       	call   80100283 <brelse>
80102f0a:	83 c4 10             	add    $0x10,%esp
80102f0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f11:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f16:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f19:	0f 8c 5d ff ff ff    	jl     80102e7c <install_trans+0x12>
80102f1f:	90                   	nop
80102f20:	90                   	nop
80102f21:	c9                   	leave  
80102f22:	c3                   	ret    

80102f23 <read_head>:
80102f23:	55                   	push   %ebp
80102f24:	89 e5                	mov    %esp,%ebp
80102f26:	83 ec 18             	sub    $0x18,%esp
80102f29:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f35:	83 ec 08             	sub    $0x8,%esp
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 c2 d2 ff ff       	call   80100201 <bread>
80102f3f:	83 c4 10             	add    $0x10,%esp
80102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f48:	83 c0 5c             	add    $0x5c,%eax
80102f4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	8b 00                	mov    (%eax),%eax
80102f53:	a3 68 41 19 80       	mov    %eax,0x80194168
80102f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f5f:	eb 1b                	jmp    80102f7c <read_head+0x59>
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f67:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f6e:	83 c2 10             	add    $0x10,%edx
80102f71:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
80102f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7c:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f84:	7c db                	jl     80102f61 <read_head+0x3e>
80102f86:	83 ec 0c             	sub    $0xc,%esp
80102f89:	ff 75 f0             	push   -0x10(%ebp)
80102f8c:	e8 f2 d2 ff ff       	call   80100283 <brelse>
80102f91:	83 c4 10             	add    $0x10,%esp
80102f94:	90                   	nop
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <write_head>:
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 18             	sub    $0x18,%esp
80102f9d:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa2:	89 c2                	mov    %eax,%edx
80102fa4:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	52                   	push   %edx
80102fad:	50                   	push   %eax
80102fae:	e8 4e d2 ff ff       	call   80100201 <bread>
80102fb3:	83 c4 10             	add    $0x10,%esp
80102fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbc:	83 c0 5c             	add    $0x5c,%eax
80102fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80102fc2:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcb:	89 10                	mov    %edx,(%eax)
80102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd4:	eb 1b                	jmp    80102ff1 <write_head+0x5a>
80102fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd9:	83 c0 10             	add    $0x10,%eax
80102fdc:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fe9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
80102fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff1:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ff9:	7c db                	jl     80102fd6 <write_head+0x3f>
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	ff 75 f0             	push   -0x10(%ebp)
80103001:	e8 34 d2 ff ff       	call   8010023a <bwrite>
80103006:	83 c4 10             	add    $0x10,%esp
80103009:	83 ec 0c             	sub    $0xc,%esp
8010300c:	ff 75 f0             	push   -0x10(%ebp)
8010300f:	e8 6f d2 ff ff       	call   80100283 <brelse>
80103014:	83 c4 10             	add    $0x10,%esp
80103017:	90                   	nop
80103018:	c9                   	leave  
80103019:	c3                   	ret    

8010301a <recover_from_log>:
8010301a:	55                   	push   %ebp
8010301b:	89 e5                	mov    %esp,%ebp
8010301d:	83 ec 08             	sub    $0x8,%esp
80103020:	e8 fe fe ff ff       	call   80102f23 <read_head>
80103025:	e8 40 fe ff ff       	call   80102e6a <install_trans>
8010302a:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103031:	00 00 00 
80103034:	e8 5e ff ff ff       	call   80102f97 <write_head>
80103039:	90                   	nop
8010303a:	c9                   	leave  
8010303b:	c3                   	ret    

8010303c <begin_op>:
8010303c:	55                   	push   %ebp
8010303d:	89 e5                	mov    %esp,%ebp
8010303f:	83 ec 08             	sub    $0x8,%esp
80103042:	83 ec 0c             	sub    $0xc,%esp
80103045:	68 20 41 19 80       	push   $0x80194120
8010304a:	e8 ba 16 00 00       	call   80104709 <acquire>
8010304f:	83 c4 10             	add    $0x10,%esp
80103052:	a1 60 41 19 80       	mov    0x80194160,%eax
80103057:	85 c0                	test   %eax,%eax
80103059:	74 17                	je     80103072 <begin_op+0x36>
8010305b:	83 ec 08             	sub    $0x8,%esp
8010305e:	68 20 41 19 80       	push   $0x80194120
80103063:	68 20 41 19 80       	push   $0x80194120
80103068:	e8 78 12 00 00       	call   801042e5 <sleep>
8010306d:	83 c4 10             	add    $0x10,%esp
80103070:	eb e0                	jmp    80103052 <begin_op+0x16>
80103072:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
80103078:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307d:	8d 50 01             	lea    0x1(%eax),%edx
80103080:	89 d0                	mov    %edx,%eax
80103082:	c1 e0 02             	shl    $0x2,%eax
80103085:	01 d0                	add    %edx,%eax
80103087:	01 c0                	add    %eax,%eax
80103089:	01 c8                	add    %ecx,%eax
8010308b:	83 f8 1e             	cmp    $0x1e,%eax
8010308e:	7e 17                	jle    801030a7 <begin_op+0x6b>
80103090:	83 ec 08             	sub    $0x8,%esp
80103093:	68 20 41 19 80       	push   $0x80194120
80103098:	68 20 41 19 80       	push   $0x80194120
8010309d:	e8 43 12 00 00       	call   801042e5 <sleep>
801030a2:	83 c4 10             	add    $0x10,%esp
801030a5:	eb ab                	jmp    80103052 <begin_op+0x16>
801030a7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ac:	83 c0 01             	add    $0x1,%eax
801030af:	a3 5c 41 19 80       	mov    %eax,0x8019415c
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 20 41 19 80       	push   $0x80194120
801030bc:	e8 b6 16 00 00       	call   80104777 <release>
801030c1:	83 c4 10             	add    $0x10,%esp
801030c4:	90                   	nop
801030c5:	90                   	nop
801030c6:	c9                   	leave  
801030c7:	c3                   	ret    

801030c8 <end_op>:
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
801030ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030d5:	83 ec 0c             	sub    $0xc,%esp
801030d8:	68 20 41 19 80       	push   $0x80194120
801030dd:	e8 27 16 00 00       	call   80104709 <acquire>
801030e2:	83 c4 10             	add    $0x10,%esp
801030e5:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ea:	83 e8 01             	sub    $0x1,%eax
801030ed:	a3 5c 41 19 80       	mov    %eax,0x8019415c
801030f2:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f7:	85 c0                	test   %eax,%eax
801030f9:	74 0d                	je     80103108 <end_op+0x40>
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	68 75 a2 10 80       	push   $0x8010a275
80103103:	e8 a1 d4 ff ff       	call   801005a9 <panic>
80103108:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 13                	jne    80103124 <end_op+0x5c>
80103111:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80103118:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010311f:	00 00 00 
80103122:	eb 10                	jmp    80103134 <end_op+0x6c>
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 41 19 80       	push   $0x80194120
8010312c:	e8 9e 12 00 00       	call   801043cf <wakeup>
80103131:	83 c4 10             	add    $0x10,%esp
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 36 16 00 00       	call   80104777 <release>
80103141:	83 c4 10             	add    $0x10,%esp
80103144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103148:	74 3f                	je     80103189 <end_op+0xc1>
8010314a:	e8 f6 00 00 00       	call   80103245 <commit>
8010314f:	83 ec 0c             	sub    $0xc,%esp
80103152:	68 20 41 19 80       	push   $0x80194120
80103157:	e8 ad 15 00 00       	call   80104709 <acquire>
8010315c:	83 c4 10             	add    $0x10,%esp
8010315f:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103166:	00 00 00 
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	68 20 41 19 80       	push   $0x80194120
80103171:	e8 59 12 00 00       	call   801043cf <wakeup>
80103176:	83 c4 10             	add    $0x10,%esp
80103179:	83 ec 0c             	sub    $0xc,%esp
8010317c:	68 20 41 19 80       	push   $0x80194120
80103181:	e8 f1 15 00 00       	call   80104777 <release>
80103186:	83 c4 10             	add    $0x10,%esp
80103189:	90                   	nop
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <write_log>:
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 18             	sub    $0x18,%esp
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 95 00 00 00       	jmp    80103233 <write_log+0xa7>
8010319e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b3:	83 ec 08             	sub    $0x8,%esp
801031b6:	52                   	push   %edx
801031b7:	50                   	push   %eax
801031b8:	e8 44 d0 ff ff       	call   80100201 <bread>
801031bd:	83 c4 10             	add    $0x10,%esp
801031c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801031c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c6:	83 c0 10             	add    $0x10,%eax
801031c9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d0:	89 c2                	mov    %eax,%edx
801031d2:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d7:	83 ec 08             	sub    $0x8,%esp
801031da:	52                   	push   %edx
801031db:	50                   	push   %eax
801031dc:	e8 20 d0 ff ff       	call   80100201 <bread>
801031e1:	83 c4 10             	add    $0x10,%esp
801031e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801031e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f0:	83 c0 5c             	add    $0x5c,%eax
801031f3:	83 ec 04             	sub    $0x4,%esp
801031f6:	68 00 02 00 00       	push   $0x200
801031fb:	52                   	push   %edx
801031fc:	50                   	push   %eax
801031fd:	e8 3c 18 00 00       	call   80104a3e <memmove>
80103202:	83 c4 10             	add    $0x10,%esp
80103205:	83 ec 0c             	sub    $0xc,%esp
80103208:	ff 75 f0             	push   -0x10(%ebp)
8010320b:	e8 2a d0 ff ff       	call   8010023a <bwrite>
80103210:	83 c4 10             	add    $0x10,%esp
80103213:	83 ec 0c             	sub    $0xc,%esp
80103216:	ff 75 ec             	push   -0x14(%ebp)
80103219:	e8 65 d0 ff ff       	call   80100283 <brelse>
8010321e:	83 c4 10             	add    $0x10,%esp
80103221:	83 ec 0c             	sub    $0xc,%esp
80103224:	ff 75 f0             	push   -0x10(%ebp)
80103227:	e8 57 d0 ff ff       	call   80100283 <brelse>
8010322c:	83 c4 10             	add    $0x10,%esp
8010322f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103233:	a1 68 41 19 80       	mov    0x80194168,%eax
80103238:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323b:	0f 8c 5d ff ff ff    	jl     8010319e <write_log+0x12>
80103241:	90                   	nop
80103242:	90                   	nop
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <commit>:
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 08             	sub    $0x8,%esp
8010324b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103250:	85 c0                	test   %eax,%eax
80103252:	7e 1e                	jle    80103272 <commit+0x2d>
80103254:	e8 33 ff ff ff       	call   8010318c <write_log>
80103259:	e8 39 fd ff ff       	call   80102f97 <write_head>
8010325e:	e8 07 fc ff ff       	call   80102e6a <install_trans>
80103263:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326a:	00 00 00 
8010326d:	e8 25 fd ff ff       	call   80102f97 <write_head>
80103272:	90                   	nop
80103273:	c9                   	leave  
80103274:	c3                   	ret    

80103275 <log_write>:
80103275:	55                   	push   %ebp
80103276:	89 e5                	mov    %esp,%ebp
80103278:	83 ec 18             	sub    $0x18,%esp
8010327b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103280:	83 f8 1d             	cmp    $0x1d,%eax
80103283:	7f 12                	jg     80103297 <log_write+0x22>
80103285:	a1 68 41 19 80       	mov    0x80194168,%eax
8010328a:	8b 15 58 41 19 80    	mov    0x80194158,%edx
80103290:	83 ea 01             	sub    $0x1,%edx
80103293:	39 d0                	cmp    %edx,%eax
80103295:	7c 0d                	jl     801032a4 <log_write+0x2f>
80103297:	83 ec 0c             	sub    $0xc,%esp
8010329a:	68 84 a2 10 80       	push   $0x8010a284
8010329f:	e8 05 d3 ff ff       	call   801005a9 <panic>
801032a4:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032a9:	85 c0                	test   %eax,%eax
801032ab:	7f 0d                	jg     801032ba <log_write+0x45>
801032ad:	83 ec 0c             	sub    $0xc,%esp
801032b0:	68 9a a2 10 80       	push   $0x8010a29a
801032b5:	e8 ef d2 ff ff       	call   801005a9 <panic>
801032ba:	83 ec 0c             	sub    $0xc,%esp
801032bd:	68 20 41 19 80       	push   $0x80194120
801032c2:	e8 42 14 00 00       	call   80104709 <acquire>
801032c7:	83 c4 10             	add    $0x10,%esp
801032ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d1:	eb 1d                	jmp    801032f0 <log_write+0x7b>
801032d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d6:	83 c0 10             	add    $0x10,%eax
801032d9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	8b 45 08             	mov    0x8(%ebp),%eax
801032e5:	8b 40 08             	mov    0x8(%eax),%eax
801032e8:	39 c2                	cmp    %eax,%edx
801032ea:	74 10                	je     801032fc <log_write+0x87>
801032ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f0:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032f8:	7c d9                	jl     801032d3 <log_write+0x5e>
801032fa:	eb 01                	jmp    801032fd <log_write+0x88>
801032fc:	90                   	nop
801032fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103300:	8b 40 08             	mov    0x8(%eax),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103308:	83 c0 10             	add    $0x10,%eax
8010330b:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
80103312:	a1 68 41 19 80       	mov    0x80194168,%eax
80103317:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331a:	75 0d                	jne    80103329 <log_write+0xb4>
8010331c:	a1 68 41 19 80       	mov    0x80194168,%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	a3 68 41 19 80       	mov    %eax,0x80194168
80103329:	8b 45 08             	mov    0x8(%ebp),%eax
8010332c:	8b 00                	mov    (%eax),%eax
8010332e:	83 c8 04             	or     $0x4,%eax
80103331:	89 c2                	mov    %eax,%edx
80103333:	8b 45 08             	mov    0x8(%ebp),%eax
80103336:	89 10                	mov    %edx,(%eax)
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	68 20 41 19 80       	push   $0x80194120
80103340:	e8 32 14 00 00       	call   80104777 <release>
80103345:	83 c4 10             	add    $0x10,%esp
80103348:	90                   	nop
80103349:	c9                   	leave  
8010334a:	c3                   	ret    

8010334b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334b:	55                   	push   %ebp
8010334c:	89 e5                	mov    %esp,%ebp
8010334e:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103351:	8b 55 08             	mov    0x8(%ebp),%edx
80103354:	8b 45 0c             	mov    0xc(%ebp),%eax
80103357:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335a:	f0 87 02             	lock xchg %eax,(%edx)
8010335d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103360:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103363:	c9                   	leave  
80103364:	c3                   	ret    

80103365 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103365:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103369:	83 e4 f0             	and    $0xfffffff0,%esp
8010336c:	ff 71 fc             	push   -0x4(%ecx)
8010336f:	55                   	push   %ebp
80103370:	89 e5                	mov    %esp,%ebp
80103372:	51                   	push   %ecx
80103373:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103376:	e8 8c 4a 00 00       	call   80107e07 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337b:	83 ec 08             	sub    $0x8,%esp
8010337e:	68 00 00 40 80       	push   $0x80400000
80103383:	68 00 90 19 80       	push   $0x80199000
80103388:	e8 de f2 ff ff       	call   8010266b <kinit1>
8010338d:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103390:	e8 8c 40 00 00       	call   80107421 <kvmalloc>
  mpinit_uefi();
80103395:	e8 33 48 00 00       	call   80107bcd <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339a:	e8 3c f6 ff ff       	call   801029db <lapicinit>
  seginit();       // segment descriptors
8010339f:	e8 15 3b 00 00       	call   80106eb9 <seginit>
  picinit();    // disable pic
801033a4:	e8 9d 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033a9:	e8 d8 f1 ff ff       	call   80102586 <ioapicinit>
  consoleinit();   // console hardware
801033ae:	e8 4c d7 ff ff       	call   80100aff <consoleinit>
  uartinit();      // serial port
801033b3:	e8 9a 2e 00 00       	call   80106252 <uartinit>
  pinit();         // process table
801033b8:	e8 c2 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bd:	e8 0e 2a 00 00       	call   80105dd0 <tvinit>
  binit();         // buffer cache
801033c2:	e8 9f cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c7:	e8 f3 db ff ff       	call   80100fbf <fileinit>
  ideinit();       // disk 
801033cc:	e8 77 6b 00 00       	call   80109f48 <ideinit>
  startothers();   // start other processors
801033d1:	e8 8a 00 00 00       	call   80103460 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d6:	83 ec 08             	sub    $0x8,%esp
801033d9:	68 00 00 00 a0       	push   $0xa0000000
801033de:	68 00 00 40 80       	push   $0x80400000
801033e3:	e8 bc f2 ff ff       	call   801026a4 <kinit2>
801033e8:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033eb:	e8 70 4c 00 00       	call   80108060 <pci_init>
  arp_scan();
801033f0:	e8 a7 59 00 00       	call   80108d9c <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f5:	e8 66 07 00 00       	call   80103b60 <userinit>

  mpmain();        // finish this processor's setup
801033fa:	e8 1a 00 00 00       	call   80103419 <mpmain>

801033ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103405:	e8 2f 40 00 00       	call   80107439 <switchkvm>
  seginit();
8010340a:	e8 aa 3a 00 00       	call   80106eb9 <seginit>
  lapicinit();
8010340f:	e8 c7 f5 ff ff       	call   801029db <lapicinit>
  mpmain();
80103414:	e8 00 00 00 00       	call   80103419 <mpmain>

80103419 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	53                   	push   %ebx
8010341d:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103420:	e8 78 05 00 00       	call   8010399d <cpuid>
80103425:	89 c3                	mov    %eax,%ebx
80103427:	e8 71 05 00 00       	call   8010399d <cpuid>
8010342c:	83 ec 04             	sub    $0x4,%esp
8010342f:	53                   	push   %ebx
80103430:	50                   	push   %eax
80103431:	68 b5 a2 10 80       	push   $0x8010a2b5
80103436:	e8 b9 cf ff ff       	call   801003f4 <cprintf>
8010343b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010343e:	e8 03 2b 00 00       	call   80105f46 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103443:	e8 70 05 00 00       	call   801039b8 <mycpu>
80103448:	05 a0 00 00 00       	add    $0xa0,%eax
8010344d:	83 ec 08             	sub    $0x8,%esp
80103450:	6a 01                	push   $0x1
80103452:	50                   	push   %eax
80103453:	e8 f3 fe ff ff       	call   8010334b <xchg>
80103458:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345b:	e8 91 0c 00 00       	call   801040f1 <scheduler>

80103460 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103466:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103472:	83 ec 04             	sub    $0x4,%esp
80103475:	50                   	push   %eax
80103476:	68 18 f5 10 80       	push   $0x8010f518
8010347b:	ff 75 f0             	push   -0x10(%ebp)
8010347e:	e8 bb 15 00 00       	call   80104a3e <memmove>
80103483:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103486:	c7 45 f4 80 6b 19 80 	movl   $0x80196b80,-0xc(%ebp)
8010348d:	eb 79                	jmp    80103508 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
8010348f:	e8 24 05 00 00       	call   801039b8 <mycpu>
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	74 67                	je     80103500 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103499:	e8 02 f3 ff ff       	call   801027a0 <kalloc>
8010349e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a4:	83 e8 04             	sub    $0x4,%eax
801034a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034aa:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b0:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 e8 08             	sub    $0x8,%eax
801034b8:	c7 00 ff 33 10 80    	movl   $0x801033ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034be:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cc:	83 e8 0c             	sub    $0xc,%eax
801034cf:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	0f b6 00             	movzbl (%eax),%eax
801034e0:	0f b6 c0             	movzbl %al,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 50 f6 ff ff       	call   80102b3d <lapicstartap>
801034ed:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f0:	90                   	nop
801034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fa:	85 c0                	test   %eax,%eax
801034fc:	74 f3                	je     801034f1 <startothers+0x91>
801034fe:	eb 01                	jmp    80103501 <startothers+0xa1>
      continue;
80103500:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103501:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103508:	a1 40 6e 19 80       	mov    0x80196e40,%eax
8010350d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103513:	05 80 6b 19 80       	add    $0x80196b80,%eax
80103518:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351b:	0f 82 6e ff ff ff    	jb     8010348f <startothers+0x2f>
      ;
  }
}
80103521:	90                   	nop
80103522:	90                   	nop
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <outb>:
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 ec 08             	sub    $0x8,%esp
8010352b:	8b 45 08             	mov    0x8(%ebp),%eax
8010352e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103535:	89 d0                	mov    %edx,%eax
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d0 ff ff ff       	call   80103525 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 be ff ff ff       	call   80103525 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave  
8010356c:	c3                   	ret    

8010356d <pipealloc>:
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
8010358d:	e8 4b da ff ff       	call   80100fdd <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 34 da ff ff       	call   80100fdd <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
801035bb:	e8 e0 f1 ff ff       	call   801027a0 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 c9 a2 10 80       	push   $0x8010a2c9
8010360c:	50                   	push   %eax
8010360d:	e8 d5 10 00 00       	call   801046e7 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
8010366f:	90                   	nop
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 85 f0 ff ff       	call   80102706 <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 00 da ff ff       	call   8010109b <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 e6 d9 ff ff       	call   8010109b <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036bd:	c9                   	leave  
801036be:	c3                   	ret    

801036bf <pipeclose>:
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 38 10 00 00       	call   80104709 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 d7 0c 00 00       	call   801043cf <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 b4 0c 00 00       	call   801043cf <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 33 10 00 00       	call   80104777 <release>
80103744:	83 c4 10             	add    $0x10,%esp
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 b4 ef ff ff       	call   80102706 <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 14 10 00 00       	call   80104777 <release>
80103763:	83 c4 10             	add    $0x10,%esp
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <pipewrite>:
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 8c 0f 00 00       	call   80104709 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 c6 0f 00 00       	call   80104777 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 00 0c 00 00       	call   801043cf <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 fd 0a 00 00       	call   801042e5 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 7d 0b 00 00       	call   801043cf <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 16 0f 00 00       	call   80104777 <release>
80103861:	83 c4 10             	add    $0x10,%esp
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <piperead>:
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 8b 0e 00 00       	call   80104709 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 dc 0e 00 00       	call   80104777 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 27 0a 00 00       	call   801042e5 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
8010393f:	90                   	nop
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 7e 0a 00 00       	call   801043cf <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 17 0e 00 00       	call   80104777 <release>
80103960:	83 c4 10             	add    $0x10,%esp
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103966:	c9                   	leave  
80103967:	c3                   	ret    

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf  
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti    
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 d0 a2 10 80       	push   $0x8010a2d0
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 50 0d 00 00       	call   801046e7 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave  
8010399c:	c3                   	ret    

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6b 19 80       	sub    $0x80196b80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave  
801039b7:	c3                   	ret    

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 d8 a2 10 80       	push   $0x8010a2d8
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1c f1 ff ff       	call   80102afa <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6b 19 80       	add    $0x80196b80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6b 19 80       	add    $0x80196b80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 fe a2 10 80       	push   $0x8010a2fe
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave  
80103a2f:	c3                   	ret    

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 39 0e 00 00       	call   80104874 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 6d 0e 00 00       	call   801048c1 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 9d 0c 00 00       	call   80104709 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 11                	jmp    80103a89 <allocproc+0x30>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 2a                	je     80103aac <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103a89:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103a90:	72 e6                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a92:	83 ec 0c             	sub    $0xc,%esp
80103a95:	68 00 42 19 80       	push   $0x80194200
80103a9a:	e8 d8 0c 00 00       	call   80104777 <release>
80103a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103aa2:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa7:	e9 b2 00 00 00       	jmp    80103b5e <allocproc+0x105>
      goto found;
80103aac:	90                   	nop

found:
  p->state = EMBRYO;
80103aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab0:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab7:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103abc:	8d 50 01             	lea    0x1(%eax),%edx
80103abf:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac8:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103acb:	83 ec 0c             	sub    $0xc,%esp
80103ace:	68 00 42 19 80       	push   $0x80194200
80103ad3:	e8 9f 0c 00 00       	call   80104777 <release>
80103ad8:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103adb:	e8 c0 ec ff ff       	call   801027a0 <kalloc>
80103ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae3:	89 42 08             	mov    %eax,0x8(%edx)
80103ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae9:	8b 40 08             	mov    0x8(%eax),%eax
80103aec:	85 c0                	test   %eax,%eax
80103aee:	75 11                	jne    80103b01 <allocproc+0xa8>
    p->state = UNUSED;
80103af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103afa:	b8 00 00 00 00       	mov    $0x0,%eax
80103aff:	eb 5d                	jmp    80103b5e <allocproc+0x105>
  }
  sp = p->kstack + KSTACKSIZE;
80103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b04:	8b 40 08             	mov    0x8(%eax),%eax
80103b07:	05 00 10 00 00       	add    $0x1000,%eax
80103b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0f:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b19:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b1c:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b20:	ba 8a 5d 10 80       	mov    $0x80105d8a,%edx
80103b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b28:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b2a:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b34:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3d:	83 ec 04             	sub    $0x4,%esp
80103b40:	6a 14                	push   $0x14
80103b42:	6a 00                	push   $0x0
80103b44:	50                   	push   %eax
80103b45:	e8 35 0e 00 00       	call   8010497f <memset>
80103b4a:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b53:	ba 9f 42 10 80       	mov    $0x8010429f,%edx
80103b58:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5e:	c9                   	leave  
80103b5f:	c3                   	ret    

80103b60 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b66:	e8 ee fe ff ff       	call   80103a59 <allocproc>
80103b6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	a3 34 63 19 80       	mov    %eax,0x80196334
  if((p->pgdir = setupkvm()) == 0){
80103b76:	e8 ba 37 00 00       	call   80107335 <setupkvm>
80103b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7e:	89 42 04             	mov    %eax,0x4(%edx)
80103b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b84:	8b 40 04             	mov    0x4(%eax),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	75 0d                	jne    80103b98 <userinit+0x38>
    panic("userinit: out of memory?");
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	68 0e a3 10 80       	push   $0x8010a30e
80103b93:	e8 11 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b98:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba0:	8b 40 04             	mov    0x4(%eax),%eax
80103ba3:	83 ec 04             	sub    $0x4,%esp
80103ba6:	52                   	push   %edx
80103ba7:	68 ec f4 10 80       	push   $0x8010f4ec
80103bac:	50                   	push   %eax
80103bad:	e8 3f 3a 00 00       	call   801075f1 <inituvm>
80103bb2:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc1:	8b 40 18             	mov    0x18(%eax),%eax
80103bc4:	83 ec 04             	sub    $0x4,%esp
80103bc7:	6a 4c                	push   $0x4c
80103bc9:	6a 00                	push   $0x0
80103bcb:	50                   	push   %eax
80103bcc:	e8 ae 0d 00 00       	call   8010497f <memset>
80103bd1:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd7:	8b 40 18             	mov    0x18(%eax),%eax
80103bda:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be3:	8b 40 18             	mov    0x18(%eax),%eax
80103be6:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bef:	8b 50 18             	mov    0x18(%eax),%edx
80103bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf5:	8b 40 18             	mov    0x18(%eax),%eax
80103bf8:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bfc:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 50 18             	mov    0x18(%eax),%edx
80103c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c09:	8b 40 18             	mov    0x18(%eax),%eax
80103c0c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c10:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	8b 40 18             	mov    0x18(%eax),%eax
80103c1a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	8b 40 18             	mov    0x18(%eax),%eax
80103c27:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	8b 40 18             	mov    0x18(%eax),%eax
80103c34:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	83 c0 6c             	add    $0x6c,%eax
80103c41:	83 ec 04             	sub    $0x4,%esp
80103c44:	6a 10                	push   $0x10
80103c46:	68 27 a3 10 80       	push   $0x8010a327
80103c4b:	50                   	push   %eax
80103c4c:	e8 31 0f 00 00       	call   80104b82 <safestrcpy>
80103c51:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c54:	83 ec 0c             	sub    $0xc,%esp
80103c57:	68 30 a3 10 80       	push   $0x8010a330
80103c5c:	e8 bc e8 ff ff       	call   8010251d <namei>
80103c61:	83 c4 10             	add    $0x10,%esp
80103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c67:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c6a:	83 ec 0c             	sub    $0xc,%esp
80103c6d:	68 00 42 19 80       	push   $0x80194200
80103c72:	e8 92 0a 00 00       	call   80104709 <acquire>
80103c77:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c84:	83 ec 0c             	sub    $0xc,%esp
80103c87:	68 00 42 19 80       	push   $0x80194200
80103c8c:	e8 e6 0a 00 00       	call   80104777 <release>
80103c91:	83 c4 10             	add    $0x10,%esp
}
80103c94:	90                   	nop
80103c95:	c9                   	leave  
80103c96:	c3                   	ret    

80103c97 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9d:	e8 8e fd ff ff       	call   80103a30 <myproc>
80103ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca8:	8b 00                	mov    (%eax),%eax
80103caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cb1:	7e 2e                	jle    80103ce1 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb9:	01 c2                	add    %eax,%edx
80103cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbe:	8b 40 04             	mov    0x4(%eax),%eax
80103cc1:	83 ec 04             	sub    $0x4,%esp
80103cc4:	52                   	push   %edx
80103cc5:	ff 75 f4             	push   -0xc(%ebp)
80103cc8:	50                   	push   %eax
80103cc9:	e8 60 3a 00 00       	call   8010772e <allocuvm>
80103cce:	83 c4 10             	add    $0x10,%esp
80103cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd8:	75 3b                	jne    80103d15 <growproc+0x7e>
      return -1;
80103cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdf:	eb 4f                	jmp    80103d30 <growproc+0x99>
  } else if(n < 0){
80103ce1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce5:	79 2e                	jns    80103d15 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	01 c2                	add    %eax,%edx
80103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf2:	8b 40 04             	mov    0x4(%eax),%eax
80103cf5:	83 ec 04             	sub    $0x4,%esp
80103cf8:	52                   	push   %edx
80103cf9:	ff 75 f4             	push   -0xc(%ebp)
80103cfc:	50                   	push   %eax
80103cfd:	e8 31 3b 00 00       	call   80107833 <deallocuvm>
80103d02:	83 c4 10             	add    $0x10,%esp
80103d05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0c:	75 07                	jne    80103d15 <growproc+0x7e>
      return -1;
80103d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d13:	eb 1b                	jmp    80103d30 <growproc+0x99>
  }
  curproc->sz = sz;
80103d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d1b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1d:	83 ec 0c             	sub    $0xc,%esp
80103d20:	ff 75 f0             	push   -0x10(%ebp)
80103d23:	e8 2a 37 00 00       	call   80107452 <switchuvm>
80103d28:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d30:	c9                   	leave  
80103d31:	c3                   	ret    

80103d32 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d32:	55                   	push   %ebp
80103d33:	89 e5                	mov    %esp,%ebp
80103d35:	57                   	push   %edi
80103d36:	56                   	push   %esi
80103d37:	53                   	push   %ebx
80103d38:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d3b:	e8 f0 fc ff ff       	call   80103a30 <myproc>
80103d40:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d43:	e8 11 fd ff ff       	call   80103a59 <allocproc>
80103d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d4b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4f:	75 0a                	jne    80103d5b <fork+0x29>
    return -1;
80103d51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d56:	e9 48 01 00 00       	jmp    80103ea3 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5e:	8b 10                	mov    (%eax),%edx
80103d60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d63:	8b 40 04             	mov    0x4(%eax),%eax
80103d66:	83 ec 08             	sub    $0x8,%esp
80103d69:	52                   	push   %edx
80103d6a:	50                   	push   %eax
80103d6b:	e8 61 3c 00 00       	call   801079d1 <copyuvm>
80103d70:	83 c4 10             	add    $0x10,%esp
80103d73:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d76:	89 42 04             	mov    %eax,0x4(%edx)
80103d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d7c:	8b 40 04             	mov    0x4(%eax),%eax
80103d7f:	85 c0                	test   %eax,%eax
80103d81:	75 30                	jne    80103db3 <fork+0x81>
    kfree(np->kstack);
80103d83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d86:	8b 40 08             	mov    0x8(%eax),%eax
80103d89:	83 ec 0c             	sub    $0xc,%esp
80103d8c:	50                   	push   %eax
80103d8d:	e8 74 e9 ff ff       	call   80102706 <kfree>
80103d92:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dae:	e9 f0 00 00 00       	jmp    80103ea3 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db6:	8b 10                	mov    (%eax),%edx
80103db8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbb:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc9:	8b 48 18             	mov    0x18(%eax),%ecx
80103dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcf:	8b 40 18             	mov    0x18(%eax),%eax
80103dd2:	89 c2                	mov    %eax,%edx
80103dd4:	89 cb                	mov    %ecx,%ebx
80103dd6:	b8 13 00 00 00       	mov    $0x13,%eax
80103ddb:	89 d7                	mov    %edx,%edi
80103ddd:	89 de                	mov    %ebx,%esi
80103ddf:	89 c1                	mov    %eax,%ecx
80103de1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de6:	8b 40 18             	mov    0x18(%eax),%eax
80103de9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103df0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df7:	eb 3b                	jmp    80103e34 <fork+0x102>
    if(curproc->ofile[i])
80103df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dff:	83 c2 08             	add    $0x8,%edx
80103e02:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e06:	85 c0                	test   %eax,%eax
80103e08:	74 26                	je     80103e30 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e10:	83 c2 08             	add    $0x8,%edx
80103e13:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e17:	83 ec 0c             	sub    $0xc,%esp
80103e1a:	50                   	push   %eax
80103e1b:	e8 2a d2 ff ff       	call   8010104a <filedup>
80103e20:	83 c4 10             	add    $0x10,%esp
80103e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e29:	83 c1 08             	add    $0x8,%ecx
80103e2c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e30:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e34:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e38:	7e bf                	jle    80103df9 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3d:	8b 40 68             	mov    0x68(%eax),%eax
80103e40:	83 ec 0c             	sub    $0xc,%esp
80103e43:	50                   	push   %eax
80103e44:	e8 67 db ff ff       	call   801019b0 <idup>
80103e49:	83 c4 10             	add    $0x10,%esp
80103e4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e55:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5b:	83 c0 6c             	add    $0x6c,%eax
80103e5e:	83 ec 04             	sub    $0x4,%esp
80103e61:	6a 10                	push   $0x10
80103e63:	52                   	push   %edx
80103e64:	50                   	push   %eax
80103e65:	e8 18 0d 00 00       	call   80104b82 <safestrcpy>
80103e6a:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e70:	8b 40 10             	mov    0x10(%eax),%eax
80103e73:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e76:	83 ec 0c             	sub    $0xc,%esp
80103e79:	68 00 42 19 80       	push   $0x80194200
80103e7e:	e8 86 08 00 00       	call   80104709 <acquire>
80103e83:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e89:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e90:	83 ec 0c             	sub    $0xc,%esp
80103e93:	68 00 42 19 80       	push   $0x80194200
80103e98:	e8 da 08 00 00       	call   80104777 <release>
80103e9d:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ea0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea6:	5b                   	pop    %ebx
80103ea7:	5e                   	pop    %esi
80103ea8:	5f                   	pop    %edi
80103ea9:	5d                   	pop    %ebp
80103eaa:	c3                   	ret    

80103eab <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eab:	55                   	push   %ebp
80103eac:	89 e5                	mov    %esp,%ebp
80103eae:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eb1:	e8 7a fb ff ff       	call   80103a30 <myproc>
80103eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb9:	a1 34 63 19 80       	mov    0x80196334,%eax
80103ebe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ec1:	75 0d                	jne    80103ed0 <exit+0x25>
    panic("init exiting");
80103ec3:	83 ec 0c             	sub    $0xc,%esp
80103ec6:	68 32 a3 10 80       	push   $0x8010a332
80103ecb:	e8 d9 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ed0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed7:	eb 3f                	jmp    80103f18 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edf:	83 c2 08             	add    $0x8,%edx
80103ee2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee6:	85 c0                	test   %eax,%eax
80103ee8:	74 2a                	je     80103f14 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eed:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef0:	83 c2 08             	add    $0x8,%edx
80103ef3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef7:	83 ec 0c             	sub    $0xc,%esp
80103efa:	50                   	push   %eax
80103efb:	e8 9b d1 ff ff       	call   8010109b <fileclose>
80103f00:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f06:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f09:	83 c2 08             	add    $0x8,%edx
80103f0c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f13:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f18:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f1c:	7e bb                	jle    80103ed9 <exit+0x2e>
    }
  }

  begin_op();
80103f1e:	e8 19 f1 ff ff       	call   8010303c <begin_op>
  iput(curproc->cwd);
80103f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f26:	8b 40 68             	mov    0x68(%eax),%eax
80103f29:	83 ec 0c             	sub    $0xc,%esp
80103f2c:	50                   	push   %eax
80103f2d:	e8 19 dc ff ff       	call   80101b4b <iput>
80103f32:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f35:	e8 8e f1 ff ff       	call   801030c8 <end_op>
  curproc->cwd = 0;
80103f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3d:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f44:	83 ec 0c             	sub    $0xc,%esp
80103f47:	68 00 42 19 80       	push   $0x80194200
80103f4c:	e8 b8 07 00 00       	call   80104709 <acquire>
80103f51:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f57:	8b 40 14             	mov    0x14(%eax),%eax
80103f5a:	83 ec 0c             	sub    $0xc,%esp
80103f5d:	50                   	push   %eax
80103f5e:	e8 29 04 00 00       	call   8010438c <wakeup1>
80103f63:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f66:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6d:	eb 3a                	jmp    80103fa9 <exit+0xfe>
    if(p->parent == curproc){
80103f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f72:	8b 40 14             	mov    0x14(%eax),%eax
80103f75:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f78:	75 28                	jne    80103fa2 <exit+0xf7>
      p->parent = initproc;
80103f7a:	8b 15 34 63 19 80    	mov    0x80196334,%edx
80103f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f83:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f89:	8b 40 0c             	mov    0xc(%eax),%eax
80103f8c:	83 f8 05             	cmp    $0x5,%eax
80103f8f:	75 11                	jne    80103fa2 <exit+0xf7>
        wakeup1(initproc);
80103f91:	a1 34 63 19 80       	mov    0x80196334,%eax
80103f96:	83 ec 0c             	sub    $0xc,%esp
80103f99:	50                   	push   %eax
80103f9a:	e8 ed 03 00 00       	call   8010438c <wakeup1>
80103f9f:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103fa9:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80103fb0:	72 bd                	jb     80103f6f <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb5:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fbc:	e8 eb 01 00 00       	call   801041ac <sched>
  panic("zombie exit");
80103fc1:	83 ec 0c             	sub    $0xc,%esp
80103fc4:	68 3f a3 10 80       	push   $0x8010a33f
80103fc9:	e8 db c5 ff ff       	call   801005a9 <panic>

80103fce <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fd4:	e8 57 fa ff ff       	call   80103a30 <myproc>
80103fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fdc:	83 ec 0c             	sub    $0xc,%esp
80103fdf:	68 00 42 19 80       	push   $0x80194200
80103fe4:	e8 20 07 00 00       	call   80104709 <acquire>
80103fe9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ff3:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ffa:	e9 a4 00 00 00       	jmp    801040a3 <wait+0xd5>
      if(p->parent != curproc)
80103fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104002:	8b 40 14             	mov    0x14(%eax),%eax
80104005:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104008:	0f 85 8d 00 00 00    	jne    8010409b <wait+0xcd>
        continue;
      havekids = 1;
8010400e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	8b 40 0c             	mov    0xc(%eax),%eax
8010401b:	83 f8 05             	cmp    $0x5,%eax
8010401e:	75 7c                	jne    8010409c <wait+0xce>
        // Found one.
        pid = p->pid;
80104020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104023:	8b 40 10             	mov    0x10(%eax),%eax
80104026:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402c:	8b 40 08             	mov    0x8(%eax),%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 ce e6 ff ff       	call   80102706 <kfree>
80104038:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010403b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	8b 40 04             	mov    0x4(%eax),%eax
8010404b:	83 ec 0c             	sub    $0xc,%esp
8010404e:	50                   	push   %eax
8010404f:	e8 a3 38 00 00       	call   801078f7 <freevm>
80104054:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104064:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010406b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104086:	83 ec 0c             	sub    $0xc,%esp
80104089:	68 00 42 19 80       	push   $0x80194200
8010408e:	e8 e4 06 00 00       	call   80104777 <release>
80104093:	83 c4 10             	add    $0x10,%esp
        return pid;
80104096:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104099:	eb 54                	jmp    801040ef <wait+0x121>
        continue;
8010409b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010409c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801040a3:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
801040aa:	0f 82 4f ff ff ff    	jb     80103fff <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040b4:	74 0a                	je     801040c0 <wait+0xf2>
801040b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b9:	8b 40 24             	mov    0x24(%eax),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	74 17                	je     801040d7 <wait+0x109>
      release(&ptable.lock);
801040c0:	83 ec 0c             	sub    $0xc,%esp
801040c3:	68 00 42 19 80       	push   $0x80194200
801040c8:	e8 aa 06 00 00       	call   80104777 <release>
801040cd:	83 c4 10             	add    $0x10,%esp
      return -1;
801040d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d5:	eb 18                	jmp    801040ef <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040d7:	83 ec 08             	sub    $0x8,%esp
801040da:	68 00 42 19 80       	push   $0x80194200
801040df:	ff 75 ec             	push   -0x14(%ebp)
801040e2:	e8 fe 01 00 00       	call   801042e5 <sleep>
801040e7:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040ea:	e9 fd fe ff ff       	jmp    80103fec <wait+0x1e>
  }
}
801040ef:	c9                   	leave  
801040f0:	c3                   	ret    

801040f1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040f1:	55                   	push   %ebp
801040f2:	89 e5                	mov    %esp,%ebp
801040f4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040f7:	e8 bc f8 ff ff       	call   801039b8 <mycpu>
801040fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104102:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104109:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010410c:	e8 67 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104111:	83 ec 0c             	sub    $0xc,%esp
80104114:	68 00 42 19 80       	push   $0x80194200
80104119:	e8 eb 05 00 00       	call   80104709 <acquire>
8010411e:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104121:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104128:	eb 64                	jmp    8010418e <scheduler+0x9d>
      if(p->state != RUNNABLE)
8010412a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412d:	8b 40 0c             	mov    0xc(%eax),%eax
80104130:	83 f8 03             	cmp    $0x3,%eax
80104133:	75 51                	jne    80104186 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104138:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104141:	83 ec 0c             	sub    $0xc,%esp
80104144:	ff 75 f4             	push   -0xc(%ebp)
80104147:	e8 06 33 00 00       	call   80107452 <switchuvm>
8010414c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010414f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104152:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010415f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104162:	83 c2 04             	add    $0x4,%edx
80104165:	83 ec 08             	sub    $0x8,%esp
80104168:	50                   	push   %eax
80104169:	52                   	push   %edx
8010416a:	e8 85 0a 00 00       	call   80104bf4 <swtch>
8010416f:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104172:	e8 c2 32 00 00       	call   80107439 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104181:	00 00 00 
80104184:	eb 01                	jmp    80104187 <scheduler+0x96>
        continue;
80104186:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104187:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010418e:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104195:	72 93                	jb     8010412a <scheduler+0x39>
    }
    release(&ptable.lock);
80104197:	83 ec 0c             	sub    $0xc,%esp
8010419a:	68 00 42 19 80       	push   $0x80194200
8010419f:	e8 d3 05 00 00       	call   80104777 <release>
801041a4:	83 c4 10             	add    $0x10,%esp
    sti();
801041a7:	e9 60 ff ff ff       	jmp    8010410c <scheduler+0x1b>

801041ac <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041ac:	55                   	push   %ebp
801041ad:	89 e5                	mov    %esp,%ebp
801041af:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041b2:	e8 79 f8 ff ff       	call   80103a30 <myproc>
801041b7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041ba:	83 ec 0c             	sub    $0xc,%esp
801041bd:	68 00 42 19 80       	push   $0x80194200
801041c2:	e8 7d 06 00 00       	call   80104844 <holding>
801041c7:	83 c4 10             	add    $0x10,%esp
801041ca:	85 c0                	test   %eax,%eax
801041cc:	75 0d                	jne    801041db <sched+0x2f>
    panic("sched ptable.lock");
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	68 4b a3 10 80       	push   $0x8010a34b
801041d6:	e8 ce c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041db:	e8 d8 f7 ff ff       	call   801039b8 <mycpu>
801041e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041e6:	83 f8 01             	cmp    $0x1,%eax
801041e9:	74 0d                	je     801041f8 <sched+0x4c>
    panic("sched locks");
801041eb:	83 ec 0c             	sub    $0xc,%esp
801041ee:	68 5d a3 10 80       	push   $0x8010a35d
801041f3:	e8 b1 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fb:	8b 40 0c             	mov    0xc(%eax),%eax
801041fe:	83 f8 04             	cmp    $0x4,%eax
80104201:	75 0d                	jne    80104210 <sched+0x64>
    panic("sched running");
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	68 69 a3 10 80       	push   $0x8010a369
8010420b:	e8 99 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104210:	e8 53 f7 ff ff       	call   80103968 <readeflags>
80104215:	25 00 02 00 00       	and    $0x200,%eax
8010421a:	85 c0                	test   %eax,%eax
8010421c:	74 0d                	je     8010422b <sched+0x7f>
    panic("sched interruptible");
8010421e:	83 ec 0c             	sub    $0xc,%esp
80104221:	68 77 a3 10 80       	push   $0x8010a377
80104226:	e8 7e c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010422b:	e8 88 f7 ff ff       	call   801039b8 <mycpu>
80104230:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104236:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104239:	e8 7a f7 ff ff       	call   801039b8 <mycpu>
8010423e:	8b 40 04             	mov    0x4(%eax),%eax
80104241:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104244:	83 c2 1c             	add    $0x1c,%edx
80104247:	83 ec 08             	sub    $0x8,%esp
8010424a:	50                   	push   %eax
8010424b:	52                   	push   %edx
8010424c:	e8 a3 09 00 00       	call   80104bf4 <swtch>
80104251:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104254:	e8 5f f7 ff ff       	call   801039b8 <mycpu>
80104259:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010425c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104262:	90                   	nop
80104263:	c9                   	leave  
80104264:	c3                   	ret    

80104265 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104265:	55                   	push   %ebp
80104266:	89 e5                	mov    %esp,%ebp
80104268:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	68 00 42 19 80       	push   $0x80194200
80104273:	e8 91 04 00 00       	call   80104709 <acquire>
80104278:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010427b:	e8 b0 f7 ff ff       	call   80103a30 <myproc>
80104280:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104287:	e8 20 ff ff ff       	call   801041ac <sched>
  release(&ptable.lock);
8010428c:	83 ec 0c             	sub    $0xc,%esp
8010428f:	68 00 42 19 80       	push   $0x80194200
80104294:	e8 de 04 00 00       	call   80104777 <release>
80104299:	83 c4 10             	add    $0x10,%esp
}
8010429c:	90                   	nop
8010429d:	c9                   	leave  
8010429e:	c3                   	ret    

8010429f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010429f:	55                   	push   %ebp
801042a0:	89 e5                	mov    %esp,%ebp
801042a2:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 00 42 19 80       	push   $0x80194200
801042ad:	e8 c5 04 00 00       	call   80104777 <release>
801042b2:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042b5:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042ba:	85 c0                	test   %eax,%eax
801042bc:	74 24                	je     801042e2 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042be:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042c5:	00 00 00 
    iinit(ROOTDEV);
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	6a 01                	push   $0x1
801042cd:	e8 a6 d3 ff ff       	call   80101678 <iinit>
801042d2:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	6a 01                	push   $0x1
801042da:	e8 3e eb ff ff       	call   80102e1d <initlog>
801042df:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042e2:	90                   	nop
801042e3:	c9                   	leave  
801042e4:	c3                   	ret    

801042e5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042e5:	55                   	push   %ebp
801042e6:	89 e5                	mov    %esp,%ebp
801042e8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042eb:	e8 40 f7 ff ff       	call   80103a30 <myproc>
801042f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f7:	75 0d                	jne    80104306 <sleep+0x21>
    panic("sleep");
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	68 8b a3 10 80       	push   $0x8010a38b
80104301:	e8 a3 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104306:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010430a:	75 0d                	jne    80104319 <sleep+0x34>
    panic("sleep without lk");
8010430c:	83 ec 0c             	sub    $0xc,%esp
8010430f:	68 91 a3 10 80       	push   $0x8010a391
80104314:	e8 90 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104319:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104320:	74 1e                	je     80104340 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104322:	83 ec 0c             	sub    $0xc,%esp
80104325:	68 00 42 19 80       	push   $0x80194200
8010432a:	e8 da 03 00 00       	call   80104709 <acquire>
8010432f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	ff 75 0c             	push   0xc(%ebp)
80104338:	e8 3a 04 00 00       	call   80104777 <release>
8010433d:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	8b 55 08             	mov    0x8(%ebp),%edx
80104346:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104353:	e8 54 fe ff ff       	call   801041ac <sched>

  // Tidy up.
  p->chan = 0;
80104358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104362:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104369:	74 1e                	je     80104389 <sleep+0xa4>
    release(&ptable.lock);
8010436b:	83 ec 0c             	sub    $0xc,%esp
8010436e:	68 00 42 19 80       	push   $0x80194200
80104373:	e8 ff 03 00 00       	call   80104777 <release>
80104378:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010437b:	83 ec 0c             	sub    $0xc,%esp
8010437e:	ff 75 0c             	push   0xc(%ebp)
80104381:	e8 83 03 00 00       	call   80104709 <acquire>
80104386:	83 c4 10             	add    $0x10,%esp
  }
}
80104389:	90                   	nop
8010438a:	c9                   	leave  
8010438b:	c3                   	ret    

8010438c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010438c:	55                   	push   %ebp
8010438d:	89 e5                	mov    %esp,%ebp
8010438f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104392:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104399:	eb 27                	jmp    801043c2 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010439b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439e:	8b 40 0c             	mov    0xc(%eax),%eax
801043a1:	83 f8 02             	cmp    $0x2,%eax
801043a4:	75 15                	jne    801043bb <wakeup1+0x2f>
801043a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a9:	8b 40 20             	mov    0x20(%eax),%eax
801043ac:	39 45 08             	cmp    %eax,0x8(%ebp)
801043af:	75 0a                	jne    801043bb <wakeup1+0x2f>
      p->state = RUNNABLE;
801043b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bb:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801043c2:	81 7d fc 34 63 19 80 	cmpl   $0x80196334,-0x4(%ebp)
801043c9:	72 d0                	jb     8010439b <wakeup1+0xf>
}
801043cb:	90                   	nop
801043cc:	90                   	nop
801043cd:	c9                   	leave  
801043ce:	c3                   	ret    

801043cf <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043cf:	55                   	push   %ebp
801043d0:	89 e5                	mov    %esp,%ebp
801043d2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043d5:	83 ec 0c             	sub    $0xc,%esp
801043d8:	68 00 42 19 80       	push   $0x80194200
801043dd:	e8 27 03 00 00       	call   80104709 <acquire>
801043e2:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043e5:	83 ec 0c             	sub    $0xc,%esp
801043e8:	ff 75 08             	push   0x8(%ebp)
801043eb:	e8 9c ff ff ff       	call   8010438c <wakeup1>
801043f0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	68 00 42 19 80       	push   $0x80194200
801043fb:	e8 77 03 00 00       	call   80104777 <release>
80104400:	83 c4 10             	add    $0x10,%esp
}
80104403:	90                   	nop
80104404:	c9                   	leave  
80104405:	c3                   	ret    

80104406 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104406:	55                   	push   %ebp
80104407:	89 e5                	mov    %esp,%ebp
80104409:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010440c:	83 ec 0c             	sub    $0xc,%esp
8010440f:	68 00 42 19 80       	push   $0x80194200
80104414:	e8 f0 02 00 00       	call   80104709 <acquire>
80104419:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010441c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104423:	eb 48                	jmp    8010446d <kill+0x67>
    if(p->pid == pid){
80104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104428:	8b 40 10             	mov    0x10(%eax),%eax
8010442b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010442e:	75 36                	jne    80104466 <kill+0x60>
      p->killed = 1;
80104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104433:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	8b 40 0c             	mov    0xc(%eax),%eax
80104440:	83 f8 02             	cmp    $0x2,%eax
80104443:	75 0a                	jne    8010444f <kill+0x49>
        p->state = RUNNABLE;
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104448:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010444f:	83 ec 0c             	sub    $0xc,%esp
80104452:	68 00 42 19 80       	push   $0x80194200
80104457:	e8 1b 03 00 00       	call   80104777 <release>
8010445c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010445f:	b8 00 00 00 00       	mov    $0x0,%eax
80104464:	eb 25                	jmp    8010448b <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104466:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010446d:	81 7d f4 34 63 19 80 	cmpl   $0x80196334,-0xc(%ebp)
80104474:	72 af                	jb     80104425 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104476:	83 ec 0c             	sub    $0xc,%esp
80104479:	68 00 42 19 80       	push   $0x80194200
8010447e:	e8 f4 02 00 00       	call   80104777 <release>
80104483:	83 c4 10             	add    $0x10,%esp
  return -1;
80104486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010448b:	c9                   	leave  
8010448c:	c3                   	ret    

8010448d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010448d:	55                   	push   %ebp
8010448e:	89 e5                	mov    %esp,%ebp
80104490:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104493:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
8010449a:	e9 da 00 00 00       	jmp    80104579 <procdump+0xec>
    if(p->state == UNUSED)
8010449f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a2:	8b 40 0c             	mov    0xc(%eax),%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	0f 84 c4 00 00 00    	je     80104571 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b0:	8b 40 0c             	mov    0xc(%eax),%eax
801044b3:	83 f8 05             	cmp    $0x5,%eax
801044b6:	77 23                	ja     801044db <procdump+0x4e>
801044b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bb:	8b 40 0c             	mov    0xc(%eax),%eax
801044be:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c5:	85 c0                	test   %eax,%eax
801044c7:	74 12                	je     801044db <procdump+0x4e>
      state = states[p->state];
801044c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044cc:	8b 40 0c             	mov    0xc(%eax),%eax
801044cf:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044d9:	eb 07                	jmp    801044e2 <procdump+0x55>
    else
      state = "???";
801044db:	c7 45 ec a2 a3 10 80 	movl   $0x8010a3a2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e5:	8d 50 6c             	lea    0x6c(%eax),%edx
801044e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044eb:	8b 40 10             	mov    0x10(%eax),%eax
801044ee:	52                   	push   %edx
801044ef:	ff 75 ec             	push   -0x14(%ebp)
801044f2:	50                   	push   %eax
801044f3:	68 a6 a3 10 80       	push   $0x8010a3a6
801044f8:	e8 f7 be ff ff       	call   801003f4 <cprintf>
801044fd:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104503:	8b 40 0c             	mov    0xc(%eax),%eax
80104506:	83 f8 02             	cmp    $0x2,%eax
80104509:	75 54                	jne    8010455f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010450b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104511:	8b 40 0c             	mov    0xc(%eax),%eax
80104514:	83 c0 08             	add    $0x8,%eax
80104517:	89 c2                	mov    %eax,%edx
80104519:	83 ec 08             	sub    $0x8,%esp
8010451c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010451f:	50                   	push   %eax
80104520:	52                   	push   %edx
80104521:	e8 a3 02 00 00       	call   801047c9 <getcallerpcs>
80104526:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104529:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104530:	eb 1c                	jmp    8010454e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104535:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104539:	83 ec 08             	sub    $0x8,%esp
8010453c:	50                   	push   %eax
8010453d:	68 af a3 10 80       	push   $0x8010a3af
80104542:	e8 ad be ff ff       	call   801003f4 <cprintf>
80104547:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010454a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010454e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104552:	7f 0b                	jg     8010455f <procdump+0xd2>
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010455b:	85 c0                	test   %eax,%eax
8010455d:	75 d3                	jne    80104532 <procdump+0xa5>
    }
    cprintf("\n");
8010455f:	83 ec 0c             	sub    $0xc,%esp
80104562:	68 b3 a3 10 80       	push   $0x8010a3b3
80104567:	e8 88 be ff ff       	call   801003f4 <cprintf>
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	eb 01                	jmp    80104572 <procdump+0xe5>
      continue;
80104571:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104572:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104579:	81 7d f0 34 63 19 80 	cmpl   $0x80196334,-0x10(%ebp)
80104580:	0f 82 19 ff ff ff    	jb     8010449f <procdump+0x12>
  }
}
80104586:	90                   	nop
80104587:	90                   	nop
80104588:	c9                   	leave  
80104589:	c3                   	ret    

8010458a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010458a:	55                   	push   %ebp
8010458b:	89 e5                	mov    %esp,%ebp
8010458d:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104590:	8b 45 08             	mov    0x8(%ebp),%eax
80104593:	83 c0 04             	add    $0x4,%eax
80104596:	83 ec 08             	sub    $0x8,%esp
80104599:	68 df a3 10 80       	push   $0x8010a3df
8010459e:	50                   	push   %eax
8010459f:	e8 43 01 00 00       	call   801046e7 <initlock>
801045a4:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045a7:	8b 45 08             	mov    0x8(%ebp),%eax
801045aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801045ad:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045b0:	8b 45 08             	mov    0x8(%ebp),%eax
801045b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045b9:	8b 45 08             	mov    0x8(%ebp),%eax
801045bc:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045c3:	90                   	nop
801045c4:	c9                   	leave  
801045c5:	c3                   	ret    

801045c6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045c6:	55                   	push   %ebp
801045c7:	89 e5                	mov    %esp,%ebp
801045c9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045cc:	8b 45 08             	mov    0x8(%ebp),%eax
801045cf:	83 c0 04             	add    $0x4,%eax
801045d2:	83 ec 0c             	sub    $0xc,%esp
801045d5:	50                   	push   %eax
801045d6:	e8 2e 01 00 00       	call   80104709 <acquire>
801045db:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045de:	eb 15                	jmp    801045f5 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045e0:	8b 45 08             	mov    0x8(%ebp),%eax
801045e3:	83 c0 04             	add    $0x4,%eax
801045e6:	83 ec 08             	sub    $0x8,%esp
801045e9:	50                   	push   %eax
801045ea:	ff 75 08             	push   0x8(%ebp)
801045ed:	e8 f3 fc ff ff       	call   801042e5 <sleep>
801045f2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045f5:	8b 45 08             	mov    0x8(%ebp),%eax
801045f8:	8b 00                	mov    (%eax),%eax
801045fa:	85 c0                	test   %eax,%eax
801045fc:	75 e2                	jne    801045e0 <acquiresleep+0x1a>
  }
  lk->locked = 1;
801045fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104601:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104607:	e8 24 f4 ff ff       	call   80103a30 <myproc>
8010460c:	8b 50 10             	mov    0x10(%eax),%edx
8010460f:	8b 45 08             	mov    0x8(%ebp),%eax
80104612:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104615:	8b 45 08             	mov    0x8(%ebp),%eax
80104618:	83 c0 04             	add    $0x4,%eax
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	50                   	push   %eax
8010461f:	e8 53 01 00 00       	call   80104777 <release>
80104624:	83 c4 10             	add    $0x10,%esp
}
80104627:	90                   	nop
80104628:	c9                   	leave  
80104629:	c3                   	ret    

8010462a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010462a:	55                   	push   %ebp
8010462b:	89 e5                	mov    %esp,%ebp
8010462d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104630:	8b 45 08             	mov    0x8(%ebp),%eax
80104633:	83 c0 04             	add    $0x4,%eax
80104636:	83 ec 0c             	sub    $0xc,%esp
80104639:	50                   	push   %eax
8010463a:	e8 ca 00 00 00       	call   80104709 <acquire>
8010463f:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104642:	8b 45 08             	mov    0x8(%ebp),%eax
80104645:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010464b:	8b 45 08             	mov    0x8(%ebp),%eax
8010464e:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104655:	83 ec 0c             	sub    $0xc,%esp
80104658:	ff 75 08             	push   0x8(%ebp)
8010465b:	e8 6f fd ff ff       	call   801043cf <wakeup>
80104660:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104663:	8b 45 08             	mov    0x8(%ebp),%eax
80104666:	83 c0 04             	add    $0x4,%eax
80104669:	83 ec 0c             	sub    $0xc,%esp
8010466c:	50                   	push   %eax
8010466d:	e8 05 01 00 00       	call   80104777 <release>
80104672:	83 c4 10             	add    $0x10,%esp
}
80104675:	90                   	nop
80104676:	c9                   	leave  
80104677:	c3                   	ret    

80104678 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010467e:	8b 45 08             	mov    0x8(%ebp),%eax
80104681:	83 c0 04             	add    $0x4,%eax
80104684:	83 ec 0c             	sub    $0xc,%esp
80104687:	50                   	push   %eax
80104688:	e8 7c 00 00 00       	call   80104709 <acquire>
8010468d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104690:	8b 45 08             	mov    0x8(%ebp),%eax
80104693:	8b 00                	mov    (%eax),%eax
80104695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104698:	8b 45 08             	mov    0x8(%ebp),%eax
8010469b:	83 c0 04             	add    $0x4,%eax
8010469e:	83 ec 0c             	sub    $0xc,%esp
801046a1:	50                   	push   %eax
801046a2:	e8 d0 00 00 00       	call   80104777 <release>
801046a7:	83 c4 10             	add    $0x10,%esp
  return r;
801046aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ad:	c9                   	leave  
801046ae:	c3                   	ret    

801046af <readeflags>:
{
801046af:	55                   	push   %ebp
801046b0:	89 e5                	mov    %esp,%ebp
801046b2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046b5:	9c                   	pushf  
801046b6:	58                   	pop    %eax
801046b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046bd:	c9                   	leave  
801046be:	c3                   	ret    

801046bf <cli>:
{
801046bf:	55                   	push   %ebp
801046c0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046c2:	fa                   	cli    
}
801046c3:	90                   	nop
801046c4:	5d                   	pop    %ebp
801046c5:	c3                   	ret    

801046c6 <sti>:
{
801046c6:	55                   	push   %ebp
801046c7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046c9:	fb                   	sti    
}
801046ca:	90                   	nop
801046cb:	5d                   	pop    %ebp
801046cc:	c3                   	ret    

801046cd <xchg>:
{
801046cd:	55                   	push   %ebp
801046ce:	89 e5                	mov    %esp,%ebp
801046d0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046d3:	8b 55 08             	mov    0x8(%ebp),%edx
801046d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801046d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046dc:	f0 87 02             	lock xchg %eax,(%edx)
801046df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046e5:	c9                   	leave  
801046e6:	c3                   	ret    

801046e7 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046e7:	55                   	push   %ebp
801046e8:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046ea:	8b 45 08             	mov    0x8(%ebp),%eax
801046ed:	8b 55 0c             	mov    0xc(%ebp),%edx
801046f0:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801046f3:	8b 45 08             	mov    0x8(%ebp),%eax
801046f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801046fc:	8b 45 08             	mov    0x8(%ebp),%eax
801046ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104706:	90                   	nop
80104707:	5d                   	pop    %ebp
80104708:	c3                   	ret    

80104709 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104709:	55                   	push   %ebp
8010470a:	89 e5                	mov    %esp,%ebp
8010470c:	53                   	push   %ebx
8010470d:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104710:	e8 5f 01 00 00       	call   80104874 <pushcli>
  if(holding(lk)){
80104715:	8b 45 08             	mov    0x8(%ebp),%eax
80104718:	83 ec 0c             	sub    $0xc,%esp
8010471b:	50                   	push   %eax
8010471c:	e8 23 01 00 00       	call   80104844 <holding>
80104721:	83 c4 10             	add    $0x10,%esp
80104724:	85 c0                	test   %eax,%eax
80104726:	74 0d                	je     80104735 <acquire+0x2c>
    panic("acquire");
80104728:	83 ec 0c             	sub    $0xc,%esp
8010472b:	68 ea a3 10 80       	push   $0x8010a3ea
80104730:	e8 74 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104735:	90                   	nop
80104736:	8b 45 08             	mov    0x8(%ebp),%eax
80104739:	83 ec 08             	sub    $0x8,%esp
8010473c:	6a 01                	push   $0x1
8010473e:	50                   	push   %eax
8010473f:	e8 89 ff ff ff       	call   801046cd <xchg>
80104744:	83 c4 10             	add    $0x10,%esp
80104747:	85 c0                	test   %eax,%eax
80104749:	75 eb                	jne    80104736 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010474b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104750:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104753:	e8 60 f2 ff ff       	call   801039b8 <mycpu>
80104758:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010475b:	8b 45 08             	mov    0x8(%ebp),%eax
8010475e:	83 c0 0c             	add    $0xc,%eax
80104761:	83 ec 08             	sub    $0x8,%esp
80104764:	50                   	push   %eax
80104765:	8d 45 08             	lea    0x8(%ebp),%eax
80104768:	50                   	push   %eax
80104769:	e8 5b 00 00 00       	call   801047c9 <getcallerpcs>
8010476e:	83 c4 10             	add    $0x10,%esp
}
80104771:	90                   	nop
80104772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104775:	c9                   	leave  
80104776:	c3                   	ret    

80104777 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104777:	55                   	push   %ebp
80104778:	89 e5                	mov    %esp,%ebp
8010477a:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	ff 75 08             	push   0x8(%ebp)
80104783:	e8 bc 00 00 00       	call   80104844 <holding>
80104788:	83 c4 10             	add    $0x10,%esp
8010478b:	85 c0                	test   %eax,%eax
8010478d:	75 0d                	jne    8010479c <release+0x25>
    panic("release");
8010478f:	83 ec 0c             	sub    $0xc,%esp
80104792:	68 f2 a3 10 80       	push   $0x8010a3f2
80104797:	e8 0d be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010479c:	8b 45 08             	mov    0x8(%ebp),%eax
8010479f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047a6:	8b 45 08             	mov    0x8(%ebp),%eax
801047a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047b0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047b5:	8b 45 08             	mov    0x8(%ebp),%eax
801047b8:	8b 55 08             	mov    0x8(%ebp),%edx
801047bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047c1:	e8 fb 00 00 00       	call   801048c1 <popcli>
}
801047c6:	90                   	nop
801047c7:	c9                   	leave  
801047c8:	c3                   	ret    

801047c9 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047c9:	55                   	push   %ebp
801047ca:	89 e5                	mov    %esp,%ebp
801047cc:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047cf:	8b 45 08             	mov    0x8(%ebp),%eax
801047d2:	83 e8 08             	sub    $0x8,%eax
801047d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047d8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047df:	eb 38                	jmp    80104819 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047e1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047e5:	74 53                	je     8010483a <getcallerpcs+0x71>
801047e7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047ee:	76 4a                	jbe    8010483a <getcallerpcs+0x71>
801047f0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801047f4:	74 44                	je     8010483a <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801047f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801047f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104800:	8b 45 0c             	mov    0xc(%ebp),%eax
80104803:	01 c2                	add    %eax,%edx
80104805:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104808:	8b 40 04             	mov    0x4(%eax),%eax
8010480b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010480d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104810:	8b 00                	mov    (%eax),%eax
80104812:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104815:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104819:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010481d:	7e c2                	jle    801047e1 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010481f:	eb 19                	jmp    8010483a <getcallerpcs+0x71>
    pcs[i] = 0;
80104821:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104824:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010482b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010482e:	01 d0                	add    %edx,%eax
80104830:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104836:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010483a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010483e:	7e e1                	jle    80104821 <getcallerpcs+0x58>
}
80104840:	90                   	nop
80104841:	90                   	nop
80104842:	c9                   	leave  
80104843:	c3                   	ret    

80104844 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104844:	55                   	push   %ebp
80104845:	89 e5                	mov    %esp,%ebp
80104847:	53                   	push   %ebx
80104848:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010484b:	8b 45 08             	mov    0x8(%ebp),%eax
8010484e:	8b 00                	mov    (%eax),%eax
80104850:	85 c0                	test   %eax,%eax
80104852:	74 16                	je     8010486a <holding+0x26>
80104854:	8b 45 08             	mov    0x8(%ebp),%eax
80104857:	8b 58 08             	mov    0x8(%eax),%ebx
8010485a:	e8 59 f1 ff ff       	call   801039b8 <mycpu>
8010485f:	39 c3                	cmp    %eax,%ebx
80104861:	75 07                	jne    8010486a <holding+0x26>
80104863:	b8 01 00 00 00       	mov    $0x1,%eax
80104868:	eb 05                	jmp    8010486f <holding+0x2b>
8010486a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010486f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104872:	c9                   	leave  
80104873:	c3                   	ret    

80104874 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104874:	55                   	push   %ebp
80104875:	89 e5                	mov    %esp,%ebp
80104877:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010487a:	e8 30 fe ff ff       	call   801046af <readeflags>
8010487f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104882:	e8 38 fe ff ff       	call   801046bf <cli>
  if(mycpu()->ncli == 0)
80104887:	e8 2c f1 ff ff       	call   801039b8 <mycpu>
8010488c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104892:	85 c0                	test   %eax,%eax
80104894:	75 14                	jne    801048aa <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104896:	e8 1d f1 ff ff       	call   801039b8 <mycpu>
8010489b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010489e:	81 e2 00 02 00 00    	and    $0x200,%edx
801048a4:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048aa:	e8 09 f1 ff ff       	call   801039b8 <mycpu>
801048af:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048b5:	83 c2 01             	add    $0x1,%edx
801048b8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048be:	90                   	nop
801048bf:	c9                   	leave  
801048c0:	c3                   	ret    

801048c1 <popcli>:

void
popcli(void)
{
801048c1:	55                   	push   %ebp
801048c2:	89 e5                	mov    %esp,%ebp
801048c4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048c7:	e8 e3 fd ff ff       	call   801046af <readeflags>
801048cc:	25 00 02 00 00       	and    $0x200,%eax
801048d1:	85 c0                	test   %eax,%eax
801048d3:	74 0d                	je     801048e2 <popcli+0x21>
    panic("popcli - interruptible");
801048d5:	83 ec 0c             	sub    $0xc,%esp
801048d8:	68 fa a3 10 80       	push   $0x8010a3fa
801048dd:	e8 c7 bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048e2:	e8 d1 f0 ff ff       	call   801039b8 <mycpu>
801048e7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048ed:	83 ea 01             	sub    $0x1,%edx
801048f0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801048f6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048fc:	85 c0                	test   %eax,%eax
801048fe:	79 0d                	jns    8010490d <popcli+0x4c>
    panic("popcli");
80104900:	83 ec 0c             	sub    $0xc,%esp
80104903:	68 11 a4 10 80       	push   $0x8010a411
80104908:	e8 9c bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010490d:	e8 a6 f0 ff ff       	call   801039b8 <mycpu>
80104912:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104918:	85 c0                	test   %eax,%eax
8010491a:	75 14                	jne    80104930 <popcli+0x6f>
8010491c:	e8 97 f0 ff ff       	call   801039b8 <mycpu>
80104921:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104927:	85 c0                	test   %eax,%eax
80104929:	74 05                	je     80104930 <popcli+0x6f>
    sti();
8010492b:	e8 96 fd ff ff       	call   801046c6 <sti>
}
80104930:	90                   	nop
80104931:	c9                   	leave  
80104932:	c3                   	ret    

80104933 <stosb>:
{
80104933:	55                   	push   %ebp
80104934:	89 e5                	mov    %esp,%ebp
80104936:	57                   	push   %edi
80104937:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104938:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010493b:	8b 55 10             	mov    0x10(%ebp),%edx
8010493e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104941:	89 cb                	mov    %ecx,%ebx
80104943:	89 df                	mov    %ebx,%edi
80104945:	89 d1                	mov    %edx,%ecx
80104947:	fc                   	cld    
80104948:	f3 aa                	rep stos %al,%es:(%edi)
8010494a:	89 ca                	mov    %ecx,%edx
8010494c:	89 fb                	mov    %edi,%ebx
8010494e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104951:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104954:	90                   	nop
80104955:	5b                   	pop    %ebx
80104956:	5f                   	pop    %edi
80104957:	5d                   	pop    %ebp
80104958:	c3                   	ret    

80104959 <stosl>:
{
80104959:	55                   	push   %ebp
8010495a:	89 e5                	mov    %esp,%ebp
8010495c:	57                   	push   %edi
8010495d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010495e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104961:	8b 55 10             	mov    0x10(%ebp),%edx
80104964:	8b 45 0c             	mov    0xc(%ebp),%eax
80104967:	89 cb                	mov    %ecx,%ebx
80104969:	89 df                	mov    %ebx,%edi
8010496b:	89 d1                	mov    %edx,%ecx
8010496d:	fc                   	cld    
8010496e:	f3 ab                	rep stos %eax,%es:(%edi)
80104970:	89 ca                	mov    %ecx,%edx
80104972:	89 fb                	mov    %edi,%ebx
80104974:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104977:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010497a:	90                   	nop
8010497b:	5b                   	pop    %ebx
8010497c:	5f                   	pop    %edi
8010497d:	5d                   	pop    %ebp
8010497e:	c3                   	ret    

8010497f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010497f:	55                   	push   %ebp
80104980:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104982:	8b 45 08             	mov    0x8(%ebp),%eax
80104985:	83 e0 03             	and    $0x3,%eax
80104988:	85 c0                	test   %eax,%eax
8010498a:	75 43                	jne    801049cf <memset+0x50>
8010498c:	8b 45 10             	mov    0x10(%ebp),%eax
8010498f:	83 e0 03             	and    $0x3,%eax
80104992:	85 c0                	test   %eax,%eax
80104994:	75 39                	jne    801049cf <memset+0x50>
    c &= 0xFF;
80104996:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010499d:	8b 45 10             	mov    0x10(%ebp),%eax
801049a0:	c1 e8 02             	shr    $0x2,%eax
801049a3:	89 c2                	mov    %eax,%edx
801049a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049a8:	c1 e0 18             	shl    $0x18,%eax
801049ab:	89 c1                	mov    %eax,%ecx
801049ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b0:	c1 e0 10             	shl    $0x10,%eax
801049b3:	09 c1                	or     %eax,%ecx
801049b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b8:	c1 e0 08             	shl    $0x8,%eax
801049bb:	09 c8                	or     %ecx,%eax
801049bd:	0b 45 0c             	or     0xc(%ebp),%eax
801049c0:	52                   	push   %edx
801049c1:	50                   	push   %eax
801049c2:	ff 75 08             	push   0x8(%ebp)
801049c5:	e8 8f ff ff ff       	call   80104959 <stosl>
801049ca:	83 c4 0c             	add    $0xc,%esp
801049cd:	eb 12                	jmp    801049e1 <memset+0x62>
  } else
    stosb(dst, c, n);
801049cf:	8b 45 10             	mov    0x10(%ebp),%eax
801049d2:	50                   	push   %eax
801049d3:	ff 75 0c             	push   0xc(%ebp)
801049d6:	ff 75 08             	push   0x8(%ebp)
801049d9:	e8 55 ff ff ff       	call   80104933 <stosb>
801049de:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049e4:	c9                   	leave  
801049e5:	c3                   	ret    

801049e6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049e6:	55                   	push   %ebp
801049e7:	89 e5                	mov    %esp,%ebp
801049e9:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049ec:	8b 45 08             	mov    0x8(%ebp),%eax
801049ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801049f8:	eb 30                	jmp    80104a2a <memcmp+0x44>
    if(*s1 != *s2)
801049fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049fd:	0f b6 10             	movzbl (%eax),%edx
80104a00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a03:	0f b6 00             	movzbl (%eax),%eax
80104a06:	38 c2                	cmp    %al,%dl
80104a08:	74 18                	je     80104a22 <memcmp+0x3c>
      return *s1 - *s2;
80104a0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a0d:	0f b6 00             	movzbl (%eax),%eax
80104a10:	0f b6 d0             	movzbl %al,%edx
80104a13:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a16:	0f b6 00             	movzbl (%eax),%eax
80104a19:	0f b6 c8             	movzbl %al,%ecx
80104a1c:	89 d0                	mov    %edx,%eax
80104a1e:	29 c8                	sub    %ecx,%eax
80104a20:	eb 1a                	jmp    80104a3c <memcmp+0x56>
    s1++, s2++;
80104a22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a26:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104a2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a30:	89 55 10             	mov    %edx,0x10(%ebp)
80104a33:	85 c0                	test   %eax,%eax
80104a35:	75 c3                	jne    801049fa <memcmp+0x14>
  }

  return 0;
80104a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a3c:	c9                   	leave  
80104a3d:	c3                   	ret    

80104a3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a3e:	55                   	push   %ebp
80104a3f:	89 e5                	mov    %esp,%ebp
80104a41:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a44:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a47:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a53:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a56:	73 54                	jae    80104aac <memmove+0x6e>
80104a58:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104a5e:	01 d0                	add    %edx,%eax
80104a60:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a63:	73 47                	jae    80104aac <memmove+0x6e>
    s += n;
80104a65:	8b 45 10             	mov    0x10(%ebp),%eax
80104a68:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a6b:	8b 45 10             	mov    0x10(%ebp),%eax
80104a6e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a71:	eb 13                	jmp    80104a86 <memmove+0x48>
      *--d = *--s;
80104a73:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a77:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a7e:	0f b6 10             	movzbl (%eax),%edx
80104a81:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a84:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a86:	8b 45 10             	mov    0x10(%ebp),%eax
80104a89:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a8c:	89 55 10             	mov    %edx,0x10(%ebp)
80104a8f:	85 c0                	test   %eax,%eax
80104a91:	75 e0                	jne    80104a73 <memmove+0x35>
  if(s < d && s + n > d){
80104a93:	eb 24                	jmp    80104ab9 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104a95:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a98:	8d 42 01             	lea    0x1(%edx),%eax
80104a9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104a9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aa1:	8d 48 01             	lea    0x1(%eax),%ecx
80104aa4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104aa7:	0f b6 12             	movzbl (%edx),%edx
80104aaa:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104aac:	8b 45 10             	mov    0x10(%ebp),%eax
80104aaf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ab2:	89 55 10             	mov    %edx,0x10(%ebp)
80104ab5:	85 c0                	test   %eax,%eax
80104ab7:	75 dc                	jne    80104a95 <memmove+0x57>

  return dst;
80104ab9:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104abc:	c9                   	leave  
80104abd:	c3                   	ret    

80104abe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104abe:	55                   	push   %ebp
80104abf:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ac1:	ff 75 10             	push   0x10(%ebp)
80104ac4:	ff 75 0c             	push   0xc(%ebp)
80104ac7:	ff 75 08             	push   0x8(%ebp)
80104aca:	e8 6f ff ff ff       	call   80104a3e <memmove>
80104acf:	83 c4 0c             	add    $0xc,%esp
}
80104ad2:	c9                   	leave  
80104ad3:	c3                   	ret    

80104ad4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ad4:	55                   	push   %ebp
80104ad5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ad7:	eb 0c                	jmp    80104ae5 <strncmp+0x11>
    n--, p++, q++;
80104ad9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104add:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ae1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ae5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ae9:	74 1a                	je     80104b05 <strncmp+0x31>
80104aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104aee:	0f b6 00             	movzbl (%eax),%eax
80104af1:	84 c0                	test   %al,%al
80104af3:	74 10                	je     80104b05 <strncmp+0x31>
80104af5:	8b 45 08             	mov    0x8(%ebp),%eax
80104af8:	0f b6 10             	movzbl (%eax),%edx
80104afb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afe:	0f b6 00             	movzbl (%eax),%eax
80104b01:	38 c2                	cmp    %al,%dl
80104b03:	74 d4                	je     80104ad9 <strncmp+0x5>
  if(n == 0)
80104b05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b09:	75 07                	jne    80104b12 <strncmp+0x3e>
    return 0;
80104b0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104b10:	eb 16                	jmp    80104b28 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80104b12:	8b 45 08             	mov    0x8(%ebp),%eax
80104b15:	0f b6 00             	movzbl (%eax),%eax
80104b18:	0f b6 d0             	movzbl %al,%edx
80104b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1e:	0f b6 00             	movzbl (%eax),%eax
80104b21:	0f b6 c8             	movzbl %al,%ecx
80104b24:	89 d0                	mov    %edx,%eax
80104b26:	29 c8                	sub    %ecx,%eax
}
80104b28:	5d                   	pop    %ebp
80104b29:	c3                   	ret    

80104b2a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b2a:	55                   	push   %ebp
80104b2b:	89 e5                	mov    %esp,%ebp
80104b2d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b30:	8b 45 08             	mov    0x8(%ebp),%eax
80104b33:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b36:	90                   	nop
80104b37:	8b 45 10             	mov    0x10(%ebp),%eax
80104b3a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b3d:	89 55 10             	mov    %edx,0x10(%ebp)
80104b40:	85 c0                	test   %eax,%eax
80104b42:	7e 2c                	jle    80104b70 <strncpy+0x46>
80104b44:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b47:	8d 42 01             	lea    0x1(%edx),%eax
80104b4a:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b50:	8d 48 01             	lea    0x1(%eax),%ecx
80104b53:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b56:	0f b6 12             	movzbl (%edx),%edx
80104b59:	88 10                	mov    %dl,(%eax)
80104b5b:	0f b6 00             	movzbl (%eax),%eax
80104b5e:	84 c0                	test   %al,%al
80104b60:	75 d5                	jne    80104b37 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b62:	eb 0c                	jmp    80104b70 <strncpy+0x46>
    *s++ = 0;
80104b64:	8b 45 08             	mov    0x8(%ebp),%eax
80104b67:	8d 50 01             	lea    0x1(%eax),%edx
80104b6a:	89 55 08             	mov    %edx,0x8(%ebp)
80104b6d:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b70:	8b 45 10             	mov    0x10(%ebp),%eax
80104b73:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b76:	89 55 10             	mov    %edx,0x10(%ebp)
80104b79:	85 c0                	test   %eax,%eax
80104b7b:	7f e7                	jg     80104b64 <strncpy+0x3a>
  return os;
80104b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b80:	c9                   	leave  
80104b81:	c3                   	ret    

80104b82 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b82:	55                   	push   %ebp
80104b83:	89 e5                	mov    %esp,%ebp
80104b85:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b88:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b92:	7f 05                	jg     80104b99 <safestrcpy+0x17>
    return os;
80104b94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b97:	eb 32                	jmp    80104bcb <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104b99:	90                   	nop
80104b9a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ba2:	7e 1e                	jle    80104bc2 <safestrcpy+0x40>
80104ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ba7:	8d 42 01             	lea    0x1(%edx),%eax
80104baa:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bad:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb0:	8d 48 01             	lea    0x1(%eax),%ecx
80104bb3:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bb6:	0f b6 12             	movzbl (%edx),%edx
80104bb9:	88 10                	mov    %dl,(%eax)
80104bbb:	0f b6 00             	movzbl (%eax),%eax
80104bbe:	84 c0                	test   %al,%al
80104bc0:	75 d8                	jne    80104b9a <safestrcpy+0x18>
    ;
  *s = 0;
80104bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bcb:	c9                   	leave  
80104bcc:	c3                   	ret    

80104bcd <strlen>:

int
strlen(const char *s)
{
80104bcd:	55                   	push   %ebp
80104bce:	89 e5                	mov    %esp,%ebp
80104bd0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bda:	eb 04                	jmp    80104be0 <strlen+0x13>
80104bdc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104be0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104be3:	8b 45 08             	mov    0x8(%ebp),%eax
80104be6:	01 d0                	add    %edx,%eax
80104be8:	0f b6 00             	movzbl (%eax),%eax
80104beb:	84 c0                	test   %al,%al
80104bed:	75 ed                	jne    80104bdc <strlen+0xf>
    ;
  return n;
80104bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bf2:	c9                   	leave  
80104bf3:	c3                   	ret    

80104bf4 <swtch>:
80104bf4:	8b 44 24 04          	mov    0x4(%esp),%eax
80104bf8:	8b 54 24 08          	mov    0x8(%esp),%edx
80104bfc:	55                   	push   %ebp
80104bfd:	53                   	push   %ebx
80104bfe:	56                   	push   %esi
80104bff:	57                   	push   %edi
80104c00:	89 20                	mov    %esp,(%eax)
80104c02:	89 d4                	mov    %edx,%esp
80104c04:	5f                   	pop    %edi
80104c05:	5e                   	pop    %esi
80104c06:	5b                   	pop    %ebx
80104c07:	5d                   	pop    %ebp
80104c08:	c3                   	ret    

80104c09 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c09:	55                   	push   %ebp
80104c0a:	89 e5                	mov    %esp,%ebp
80104c0c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c0f:	e8 1c ee ff ff       	call   80103a30 <myproc>
80104c14:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1a:	8b 00                	mov    (%eax),%eax
80104c1c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c1f:	73 0f                	jae    80104c30 <fetchint+0x27>
80104c21:	8b 45 08             	mov    0x8(%ebp),%eax
80104c24:	8d 50 04             	lea    0x4(%eax),%edx
80104c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2a:	8b 00                	mov    (%eax),%eax
80104c2c:	39 c2                	cmp    %eax,%edx
80104c2e:	76 07                	jbe    80104c37 <fetchint+0x2e>
    return -1;
80104c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c35:	eb 0f                	jmp    80104c46 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c37:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3a:	8b 10                	mov    (%eax),%edx
80104c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3f:	89 10                	mov    %edx,(%eax)
  return 0;
80104c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c46:	c9                   	leave  
80104c47:	c3                   	ret    

80104c48 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c48:	55                   	push   %ebp
80104c49:	89 e5                	mov    %esp,%ebp
80104c4b:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c4e:	e8 dd ed ff ff       	call   80103a30 <myproc>
80104c53:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c59:	8b 00                	mov    (%eax),%eax
80104c5b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c5e:	72 07                	jb     80104c67 <fetchstr+0x1f>
    return -1;
80104c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c65:	eb 41                	jmp    80104ca8 <fetchstr+0x60>
  *pp = (char*)addr;
80104c67:	8b 55 08             	mov    0x8(%ebp),%edx
80104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6d:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c72:	8b 00                	mov    (%eax),%eax
80104c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c7a:	8b 00                	mov    (%eax),%eax
80104c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c7f:	eb 1a                	jmp    80104c9b <fetchstr+0x53>
    if(*s == 0)
80104c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c84:	0f b6 00             	movzbl (%eax),%eax
80104c87:	84 c0                	test   %al,%al
80104c89:	75 0c                	jne    80104c97 <fetchstr+0x4f>
      return s - *pp;
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8e:	8b 10                	mov    (%eax),%edx
80104c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c93:	29 d0                	sub    %edx,%eax
80104c95:	eb 11                	jmp    80104ca8 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104c97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104ca1:	72 de                	jb     80104c81 <fetchstr+0x39>
  }
  return -1;
80104ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ca8:	c9                   	leave  
80104ca9:	c3                   	ret    

80104caa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104caa:	55                   	push   %ebp
80104cab:	89 e5                	mov    %esp,%ebp
80104cad:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cb0:	e8 7b ed ff ff       	call   80103a30 <myproc>
80104cb5:	8b 40 18             	mov    0x18(%eax),%eax
80104cb8:	8b 50 44             	mov    0x44(%eax),%edx
80104cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbe:	c1 e0 02             	shl    $0x2,%eax
80104cc1:	01 d0                	add    %edx,%eax
80104cc3:	83 c0 04             	add    $0x4,%eax
80104cc6:	83 ec 08             	sub    $0x8,%esp
80104cc9:	ff 75 0c             	push   0xc(%ebp)
80104ccc:	50                   	push   %eax
80104ccd:	e8 37 ff ff ff       	call   80104c09 <fetchint>
80104cd2:	83 c4 10             	add    $0x10,%esp
}
80104cd5:	c9                   	leave  
80104cd6:	c3                   	ret    

80104cd7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cd7:	55                   	push   %ebp
80104cd8:	89 e5                	mov    %esp,%ebp
80104cda:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104cdd:	e8 4e ed ff ff       	call   80103a30 <myproc>
80104ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104ce5:	83 ec 08             	sub    $0x8,%esp
80104ce8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ceb:	50                   	push   %eax
80104cec:	ff 75 08             	push   0x8(%ebp)
80104cef:	e8 b6 ff ff ff       	call   80104caa <argint>
80104cf4:	83 c4 10             	add    $0x10,%esp
80104cf7:	85 c0                	test   %eax,%eax
80104cf9:	79 07                	jns    80104d02 <argptr+0x2b>
    return -1;
80104cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d00:	eb 3b                	jmp    80104d3d <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d06:	78 1f                	js     80104d27 <argptr+0x50>
80104d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0b:	8b 00                	mov    (%eax),%eax
80104d0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d10:	39 d0                	cmp    %edx,%eax
80104d12:	76 13                	jbe    80104d27 <argptr+0x50>
80104d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d17:	89 c2                	mov    %eax,%edx
80104d19:	8b 45 10             	mov    0x10(%ebp),%eax
80104d1c:	01 c2                	add    %eax,%edx
80104d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d21:	8b 00                	mov    (%eax),%eax
80104d23:	39 c2                	cmp    %eax,%edx
80104d25:	76 07                	jbe    80104d2e <argptr+0x57>
    return -1;
80104d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2c:	eb 0f                	jmp    80104d3d <argptr+0x66>
  *pp = (char*)i;
80104d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d31:	89 c2                	mov    %eax,%edx
80104d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d36:	89 10                	mov    %edx,(%eax)
  return 0;
80104d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d3d:	c9                   	leave  
80104d3e:	c3                   	ret    

80104d3f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d3f:	55                   	push   %ebp
80104d40:	89 e5                	mov    %esp,%ebp
80104d42:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d45:	83 ec 08             	sub    $0x8,%esp
80104d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4b:	50                   	push   %eax
80104d4c:	ff 75 08             	push   0x8(%ebp)
80104d4f:	e8 56 ff ff ff       	call   80104caa <argint>
80104d54:	83 c4 10             	add    $0x10,%esp
80104d57:	85 c0                	test   %eax,%eax
80104d59:	79 07                	jns    80104d62 <argstr+0x23>
    return -1;
80104d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d60:	eb 12                	jmp    80104d74 <argstr+0x35>
  return fetchstr(addr, pp);
80104d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d65:	83 ec 08             	sub    $0x8,%esp
80104d68:	ff 75 0c             	push   0xc(%ebp)
80104d6b:	50                   	push   %eax
80104d6c:	e8 d7 fe ff ff       	call   80104c48 <fetchstr>
80104d71:	83 c4 10             	add    $0x10,%esp
}
80104d74:	c9                   	leave  
80104d75:	c3                   	ret    

80104d76 <syscall>:
[SYS_check_counter] sys_check_counter,
};

void
syscall(void)
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
80104d79:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d7c:	e8 af ec ff ff       	call   80103a30 <myproc>
80104d81:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d87:	8b 40 18             	mov    0x18(%eax),%eax
80104d8a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d94:	7e 2f                	jle    80104dc5 <syscall+0x4f>
80104d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d99:	83 f8 17             	cmp    $0x17,%eax
80104d9c:	77 27                	ja     80104dc5 <syscall+0x4f>
80104d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da1:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104da8:	85 c0                	test   %eax,%eax
80104daa:	74 19                	je     80104dc5 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daf:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104db6:	ff d0                	call   *%eax
80104db8:	89 c2                	mov    %eax,%edx
80104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbd:	8b 40 18             	mov    0x18(%eax),%eax
80104dc0:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dc3:	eb 2c                	jmp    80104df1 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc8:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dce:	8b 40 10             	mov    0x10(%eax),%eax
80104dd1:	ff 75 f0             	push   -0x10(%ebp)
80104dd4:	52                   	push   %edx
80104dd5:	50                   	push   %eax
80104dd6:	68 18 a4 10 80       	push   $0x8010a418
80104ddb:	e8 14 b6 ff ff       	call   801003f4 <cprintf>
80104de0:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de6:	8b 40 18             	mov    0x18(%eax),%eax
80104de9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104df0:	90                   	nop
80104df1:	90                   	nop
80104df2:	c9                   	leave  
80104df3:	c3                   	ret    

80104df4 <argfd>:
80104df4:	55                   	push   %ebp
80104df5:	89 e5                	mov    %esp,%ebp
80104df7:	83 ec 18             	sub    $0x18,%esp
80104dfa:	83 ec 08             	sub    $0x8,%esp
80104dfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e00:	50                   	push   %eax
80104e01:	ff 75 08             	push   0x8(%ebp)
80104e04:	e8 a1 fe ff ff       	call   80104caa <argint>
80104e09:	83 c4 10             	add    $0x10,%esp
80104e0c:	85 c0                	test   %eax,%eax
80104e0e:	79 07                	jns    80104e17 <argfd+0x23>
80104e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e15:	eb 4f                	jmp    80104e66 <argfd+0x72>
80104e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	78 20                	js     80104e3e <argfd+0x4a>
80104e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e21:	83 f8 0f             	cmp    $0xf,%eax
80104e24:	7f 18                	jg     80104e3e <argfd+0x4a>
80104e26:	e8 05 ec ff ff       	call   80103a30 <myproc>
80104e2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e2e:	83 c2 08             	add    $0x8,%edx
80104e31:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e3c:	75 07                	jne    80104e45 <argfd+0x51>
80104e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e43:	eb 21                	jmp    80104e66 <argfd+0x72>
80104e45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e49:	74 08                	je     80104e53 <argfd+0x5f>
80104e4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e51:	89 10                	mov    %edx,(%eax)
80104e53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e57:	74 08                	je     80104e61 <argfd+0x6d>
80104e59:	8b 45 10             	mov    0x10(%ebp),%eax
80104e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5f:	89 10                	mov    %edx,(%eax)
80104e61:	b8 00 00 00 00       	mov    $0x0,%eax
80104e66:	c9                   	leave  
80104e67:	c3                   	ret    

80104e68 <fdalloc>:
80104e68:	55                   	push   %ebp
80104e69:	89 e5                	mov    %esp,%ebp
80104e6b:	83 ec 18             	sub    $0x18,%esp
80104e6e:	e8 bd eb ff ff       	call   80103a30 <myproc>
80104e73:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104e76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e7d:	eb 2a                	jmp    80104ea9 <fdalloc+0x41>
80104e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e85:	83 c2 08             	add    $0x8,%edx
80104e88:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e8c:	85 c0                	test   %eax,%eax
80104e8e:	75 15                	jne    80104ea5 <fdalloc+0x3d>
80104e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e96:	8d 4a 08             	lea    0x8(%edx),%ecx
80104e99:	8b 55 08             	mov    0x8(%ebp),%edx
80104e9c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
80104ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea3:	eb 0f                	jmp    80104eb4 <fdalloc+0x4c>
80104ea5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104ead:	7e d0                	jle    80104e7f <fdalloc+0x17>
80104eaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb4:	c9                   	leave  
80104eb5:	c3                   	ret    

80104eb6 <sys_dup>:
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 18             	sub    $0x18,%esp
80104ebc:	83 ec 04             	sub    $0x4,%esp
80104ebf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ec2:	50                   	push   %eax
80104ec3:	6a 00                	push   $0x0
80104ec5:	6a 00                	push   $0x0
80104ec7:	e8 28 ff ff ff       	call   80104df4 <argfd>
80104ecc:	83 c4 10             	add    $0x10,%esp
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	79 07                	jns    80104eda <sys_dup+0x24>
80104ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed8:	eb 31                	jmp    80104f0b <sys_dup+0x55>
80104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edd:	83 ec 0c             	sub    $0xc,%esp
80104ee0:	50                   	push   %eax
80104ee1:	e8 82 ff ff ff       	call   80104e68 <fdalloc>
80104ee6:	83 c4 10             	add    $0x10,%esp
80104ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104eec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ef0:	79 07                	jns    80104ef9 <sys_dup+0x43>
80104ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef7:	eb 12                	jmp    80104f0b <sys_dup+0x55>
80104ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104efc:	83 ec 0c             	sub    $0xc,%esp
80104eff:	50                   	push   %eax
80104f00:	e8 45 c1 ff ff       	call   8010104a <filedup>
80104f05:	83 c4 10             	add    $0x10,%esp
80104f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0b:	c9                   	leave  
80104f0c:	c3                   	ret    

80104f0d <sys_read>:
80104f0d:	55                   	push   %ebp
80104f0e:	89 e5                	mov    %esp,%ebp
80104f10:	83 ec 18             	sub    $0x18,%esp
80104f13:	83 ec 04             	sub    $0x4,%esp
80104f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f19:	50                   	push   %eax
80104f1a:	6a 00                	push   $0x0
80104f1c:	6a 00                	push   $0x0
80104f1e:	e8 d1 fe ff ff       	call   80104df4 <argfd>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	85 c0                	test   %eax,%eax
80104f28:	78 2e                	js     80104f58 <sys_read+0x4b>
80104f2a:	83 ec 08             	sub    $0x8,%esp
80104f2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f30:	50                   	push   %eax
80104f31:	6a 02                	push   $0x2
80104f33:	e8 72 fd ff ff       	call   80104caa <argint>
80104f38:	83 c4 10             	add    $0x10,%esp
80104f3b:	85 c0                	test   %eax,%eax
80104f3d:	78 19                	js     80104f58 <sys_read+0x4b>
80104f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f42:	83 ec 04             	sub    $0x4,%esp
80104f45:	50                   	push   %eax
80104f46:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f49:	50                   	push   %eax
80104f4a:	6a 01                	push   $0x1
80104f4c:	e8 86 fd ff ff       	call   80104cd7 <argptr>
80104f51:	83 c4 10             	add    $0x10,%esp
80104f54:	85 c0                	test   %eax,%eax
80104f56:	79 07                	jns    80104f5f <sys_read+0x52>
80104f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f5d:	eb 17                	jmp    80104f76 <sys_read+0x69>
80104f5f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f62:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f68:	83 ec 04             	sub    $0x4,%esp
80104f6b:	51                   	push   %ecx
80104f6c:	52                   	push   %edx
80104f6d:	50                   	push   %eax
80104f6e:	e8 67 c2 ff ff       	call   801011da <fileread>
80104f73:	83 c4 10             	add    $0x10,%esp
80104f76:	c9                   	leave  
80104f77:	c3                   	ret    

80104f78 <sys_write>:
80104f78:	55                   	push   %ebp
80104f79:	89 e5                	mov    %esp,%ebp
80104f7b:	83 ec 18             	sub    $0x18,%esp
80104f7e:	83 ec 04             	sub    $0x4,%esp
80104f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f84:	50                   	push   %eax
80104f85:	6a 00                	push   $0x0
80104f87:	6a 00                	push   $0x0
80104f89:	e8 66 fe ff ff       	call   80104df4 <argfd>
80104f8e:	83 c4 10             	add    $0x10,%esp
80104f91:	85 c0                	test   %eax,%eax
80104f93:	78 2e                	js     80104fc3 <sys_write+0x4b>
80104f95:	83 ec 08             	sub    $0x8,%esp
80104f98:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f9b:	50                   	push   %eax
80104f9c:	6a 02                	push   $0x2
80104f9e:	e8 07 fd ff ff       	call   80104caa <argint>
80104fa3:	83 c4 10             	add    $0x10,%esp
80104fa6:	85 c0                	test   %eax,%eax
80104fa8:	78 19                	js     80104fc3 <sys_write+0x4b>
80104faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fad:	83 ec 04             	sub    $0x4,%esp
80104fb0:	50                   	push   %eax
80104fb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fb4:	50                   	push   %eax
80104fb5:	6a 01                	push   $0x1
80104fb7:	e8 1b fd ff ff       	call   80104cd7 <argptr>
80104fbc:	83 c4 10             	add    $0x10,%esp
80104fbf:	85 c0                	test   %eax,%eax
80104fc1:	79 07                	jns    80104fca <sys_write+0x52>
80104fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc8:	eb 17                	jmp    80104fe1 <sys_write+0x69>
80104fca:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fcd:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd3:	83 ec 04             	sub    $0x4,%esp
80104fd6:	51                   	push   %ecx
80104fd7:	52                   	push   %edx
80104fd8:	50                   	push   %eax
80104fd9:	e8 b4 c2 ff ff       	call   80101292 <filewrite>
80104fde:	83 c4 10             	add    $0x10,%esp
80104fe1:	c9                   	leave  
80104fe2:	c3                   	ret    

80104fe3 <sys_close>:
80104fe3:	55                   	push   %ebp
80104fe4:	89 e5                	mov    %esp,%ebp
80104fe6:	83 ec 18             	sub    $0x18,%esp
80104fe9:	83 ec 04             	sub    $0x4,%esp
80104fec:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fef:	50                   	push   %eax
80104ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff3:	50                   	push   %eax
80104ff4:	6a 00                	push   $0x0
80104ff6:	e8 f9 fd ff ff       	call   80104df4 <argfd>
80104ffb:	83 c4 10             	add    $0x10,%esp
80104ffe:	85 c0                	test   %eax,%eax
80105000:	79 07                	jns    80105009 <sys_close+0x26>
80105002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105007:	eb 27                	jmp    80105030 <sys_close+0x4d>
80105009:	e8 22 ea ff ff       	call   80103a30 <myproc>
8010500e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105011:	83 c2 08             	add    $0x8,%edx
80105014:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010501b:	00 
8010501c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501f:	83 ec 0c             	sub    $0xc,%esp
80105022:	50                   	push   %eax
80105023:	e8 73 c0 ff ff       	call   8010109b <fileclose>
80105028:	83 c4 10             	add    $0x10,%esp
8010502b:	b8 00 00 00 00       	mov    $0x0,%eax
80105030:	c9                   	leave  
80105031:	c3                   	ret    

80105032 <sys_fstat>:
80105032:	55                   	push   %ebp
80105033:	89 e5                	mov    %esp,%ebp
80105035:	83 ec 18             	sub    $0x18,%esp
80105038:	83 ec 04             	sub    $0x4,%esp
8010503b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010503e:	50                   	push   %eax
8010503f:	6a 00                	push   $0x0
80105041:	6a 00                	push   $0x0
80105043:	e8 ac fd ff ff       	call   80104df4 <argfd>
80105048:	83 c4 10             	add    $0x10,%esp
8010504b:	85 c0                	test   %eax,%eax
8010504d:	78 17                	js     80105066 <sys_fstat+0x34>
8010504f:	83 ec 04             	sub    $0x4,%esp
80105052:	6a 14                	push   $0x14
80105054:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105057:	50                   	push   %eax
80105058:	6a 01                	push   $0x1
8010505a:	e8 78 fc ff ff       	call   80104cd7 <argptr>
8010505f:	83 c4 10             	add    $0x10,%esp
80105062:	85 c0                	test   %eax,%eax
80105064:	79 07                	jns    8010506d <sys_fstat+0x3b>
80105066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506b:	eb 13                	jmp    80105080 <sys_fstat+0x4e>
8010506d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105073:	83 ec 08             	sub    $0x8,%esp
80105076:	52                   	push   %edx
80105077:	50                   	push   %eax
80105078:	e8 06 c1 ff ff       	call   80101183 <filestat>
8010507d:	83 c4 10             	add    $0x10,%esp
80105080:	c9                   	leave  
80105081:	c3                   	ret    

80105082 <sys_link>:
80105082:	55                   	push   %ebp
80105083:	89 e5                	mov    %esp,%ebp
80105085:	83 ec 28             	sub    $0x28,%esp
80105088:	83 ec 08             	sub    $0x8,%esp
8010508b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010508e:	50                   	push   %eax
8010508f:	6a 00                	push   $0x0
80105091:	e8 a9 fc ff ff       	call   80104d3f <argstr>
80105096:	83 c4 10             	add    $0x10,%esp
80105099:	85 c0                	test   %eax,%eax
8010509b:	78 15                	js     801050b2 <sys_link+0x30>
8010509d:	83 ec 08             	sub    $0x8,%esp
801050a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050a3:	50                   	push   %eax
801050a4:	6a 01                	push   $0x1
801050a6:	e8 94 fc ff ff       	call   80104d3f <argstr>
801050ab:	83 c4 10             	add    $0x10,%esp
801050ae:	85 c0                	test   %eax,%eax
801050b0:	79 0a                	jns    801050bc <sys_link+0x3a>
801050b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b7:	e9 68 01 00 00       	jmp    80105224 <sys_link+0x1a2>
801050bc:	e8 7b df ff ff       	call   8010303c <begin_op>
801050c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	50                   	push   %eax
801050c8:	e8 50 d4 ff ff       	call   8010251d <namei>
801050cd:	83 c4 10             	add    $0x10,%esp
801050d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050d7:	75 0f                	jne    801050e8 <sys_link+0x66>
801050d9:	e8 ea df ff ff       	call   801030c8 <end_op>
801050de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e3:	e9 3c 01 00 00       	jmp    80105224 <sys_link+0x1a2>
801050e8:	83 ec 0c             	sub    $0xc,%esp
801050eb:	ff 75 f4             	push   -0xc(%ebp)
801050ee:	e8 f7 c8 ff ff       	call   801019ea <ilock>
801050f3:	83 c4 10             	add    $0x10,%esp
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801050fd:	66 83 f8 01          	cmp    $0x1,%ax
80105101:	75 1d                	jne    80105120 <sys_link+0x9e>
80105103:	83 ec 0c             	sub    $0xc,%esp
80105106:	ff 75 f4             	push   -0xc(%ebp)
80105109:	e8 0d cb ff ff       	call   80101c1b <iunlockput>
8010510e:	83 c4 10             	add    $0x10,%esp
80105111:	e8 b2 df ff ff       	call   801030c8 <end_op>
80105116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511b:	e9 04 01 00 00       	jmp    80105224 <sys_link+0x1a2>
80105120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105123:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105127:	83 c0 01             	add    $0x1,%eax
8010512a:	89 c2                	mov    %eax,%edx
8010512c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512f:	66 89 50 56          	mov    %dx,0x56(%eax)
80105133:	83 ec 0c             	sub    $0xc,%esp
80105136:	ff 75 f4             	push   -0xc(%ebp)
80105139:	e8 cf c6 ff ff       	call   8010180d <iupdate>
8010513e:	83 c4 10             	add    $0x10,%esp
80105141:	83 ec 0c             	sub    $0xc,%esp
80105144:	ff 75 f4             	push   -0xc(%ebp)
80105147:	e8 b1 c9 ff ff       	call   80101afd <iunlock>
8010514c:	83 c4 10             	add    $0x10,%esp
8010514f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105152:	83 ec 08             	sub    $0x8,%esp
80105155:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105158:	52                   	push   %edx
80105159:	50                   	push   %eax
8010515a:	e8 da d3 ff ff       	call   80102539 <nameiparent>
8010515f:	83 c4 10             	add    $0x10,%esp
80105162:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105165:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105169:	74 71                	je     801051dc <sys_link+0x15a>
8010516b:	83 ec 0c             	sub    $0xc,%esp
8010516e:	ff 75 f0             	push   -0x10(%ebp)
80105171:	e8 74 c8 ff ff       	call   801019ea <ilock>
80105176:	83 c4 10             	add    $0x10,%esp
80105179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517c:	8b 10                	mov    (%eax),%edx
8010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105181:	8b 00                	mov    (%eax),%eax
80105183:	39 c2                	cmp    %eax,%edx
80105185:	75 1d                	jne    801051a4 <sys_link+0x122>
80105187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518a:	8b 40 04             	mov    0x4(%eax),%eax
8010518d:	83 ec 04             	sub    $0x4,%esp
80105190:	50                   	push   %eax
80105191:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105194:	50                   	push   %eax
80105195:	ff 75 f0             	push   -0x10(%ebp)
80105198:	e8 e9 d0 ff ff       	call   80102286 <dirlink>
8010519d:	83 c4 10             	add    $0x10,%esp
801051a0:	85 c0                	test   %eax,%eax
801051a2:	79 10                	jns    801051b4 <sys_link+0x132>
801051a4:	83 ec 0c             	sub    $0xc,%esp
801051a7:	ff 75 f0             	push   -0x10(%ebp)
801051aa:	e8 6c ca ff ff       	call   80101c1b <iunlockput>
801051af:	83 c4 10             	add    $0x10,%esp
801051b2:	eb 29                	jmp    801051dd <sys_link+0x15b>
801051b4:	83 ec 0c             	sub    $0xc,%esp
801051b7:	ff 75 f0             	push   -0x10(%ebp)
801051ba:	e8 5c ca ff ff       	call   80101c1b <iunlockput>
801051bf:	83 c4 10             	add    $0x10,%esp
801051c2:	83 ec 0c             	sub    $0xc,%esp
801051c5:	ff 75 f4             	push   -0xc(%ebp)
801051c8:	e8 7e c9 ff ff       	call   80101b4b <iput>
801051cd:	83 c4 10             	add    $0x10,%esp
801051d0:	e8 f3 de ff ff       	call   801030c8 <end_op>
801051d5:	b8 00 00 00 00       	mov    $0x0,%eax
801051da:	eb 48                	jmp    80105224 <sys_link+0x1a2>
801051dc:	90                   	nop
801051dd:	83 ec 0c             	sub    $0xc,%esp
801051e0:	ff 75 f4             	push   -0xc(%ebp)
801051e3:	e8 02 c8 ff ff       	call   801019ea <ilock>
801051e8:	83 c4 10             	add    $0x10,%esp
801051eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ee:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051f2:	83 e8 01             	sub    $0x1,%eax
801051f5:	89 c2                	mov    %eax,%edx
801051f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fa:	66 89 50 56          	mov    %dx,0x56(%eax)
801051fe:	83 ec 0c             	sub    $0xc,%esp
80105201:	ff 75 f4             	push   -0xc(%ebp)
80105204:	e8 04 c6 ff ff       	call   8010180d <iupdate>
80105209:	83 c4 10             	add    $0x10,%esp
8010520c:	83 ec 0c             	sub    $0xc,%esp
8010520f:	ff 75 f4             	push   -0xc(%ebp)
80105212:	e8 04 ca ff ff       	call   80101c1b <iunlockput>
80105217:	83 c4 10             	add    $0x10,%esp
8010521a:	e8 a9 de ff ff       	call   801030c8 <end_op>
8010521f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105224:	c9                   	leave  
80105225:	c3                   	ret    

80105226 <isdirempty>:
80105226:	55                   	push   %ebp
80105227:	89 e5                	mov    %esp,%ebp
80105229:	83 ec 28             	sub    $0x28,%esp
8010522c:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105233:	eb 40                	jmp    80105275 <isdirempty+0x4f>
80105235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105238:	6a 10                	push   $0x10
8010523a:	50                   	push   %eax
8010523b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010523e:	50                   	push   %eax
8010523f:	ff 75 08             	push   0x8(%ebp)
80105242:	e8 8f cc ff ff       	call   80101ed6 <readi>
80105247:	83 c4 10             	add    $0x10,%esp
8010524a:	83 f8 10             	cmp    $0x10,%eax
8010524d:	74 0d                	je     8010525c <isdirempty+0x36>
8010524f:	83 ec 0c             	sub    $0xc,%esp
80105252:	68 34 a4 10 80       	push   $0x8010a434
80105257:	e8 4d b3 ff ff       	call   801005a9 <panic>
8010525c:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105260:	66 85 c0             	test   %ax,%ax
80105263:	74 07                	je     8010526c <isdirempty+0x46>
80105265:	b8 00 00 00 00       	mov    $0x0,%eax
8010526a:	eb 1b                	jmp    80105287 <isdirempty+0x61>
8010526c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526f:	83 c0 10             	add    $0x10,%eax
80105272:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105275:	8b 45 08             	mov    0x8(%ebp),%eax
80105278:	8b 50 58             	mov    0x58(%eax),%edx
8010527b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527e:	39 c2                	cmp    %eax,%edx
80105280:	77 b3                	ja     80105235 <isdirempty+0xf>
80105282:	b8 01 00 00 00       	mov    $0x1,%eax
80105287:	c9                   	leave  
80105288:	c3                   	ret    

80105289 <sys_unlink>:
80105289:	55                   	push   %ebp
8010528a:	89 e5                	mov    %esp,%ebp
8010528c:	83 ec 38             	sub    $0x38,%esp
8010528f:	83 ec 08             	sub    $0x8,%esp
80105292:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105295:	50                   	push   %eax
80105296:	6a 00                	push   $0x0
80105298:	e8 a2 fa ff ff       	call   80104d3f <argstr>
8010529d:	83 c4 10             	add    $0x10,%esp
801052a0:	85 c0                	test   %eax,%eax
801052a2:	79 0a                	jns    801052ae <sys_unlink+0x25>
801052a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a9:	e9 bf 01 00 00       	jmp    8010546d <sys_unlink+0x1e4>
801052ae:	e8 89 dd ff ff       	call   8010303c <begin_op>
801052b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052b6:	83 ec 08             	sub    $0x8,%esp
801052b9:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052bc:	52                   	push   %edx
801052bd:	50                   	push   %eax
801052be:	e8 76 d2 ff ff       	call   80102539 <nameiparent>
801052c3:	83 c4 10             	add    $0x10,%esp
801052c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052cd:	75 0f                	jne    801052de <sys_unlink+0x55>
801052cf:	e8 f4 dd ff ff       	call   801030c8 <end_op>
801052d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d9:	e9 8f 01 00 00       	jmp    8010546d <sys_unlink+0x1e4>
801052de:	83 ec 0c             	sub    $0xc,%esp
801052e1:	ff 75 f4             	push   -0xc(%ebp)
801052e4:	e8 01 c7 ff ff       	call   801019ea <ilock>
801052e9:	83 c4 10             	add    $0x10,%esp
801052ec:	83 ec 08             	sub    $0x8,%esp
801052ef:	68 46 a4 10 80       	push   $0x8010a446
801052f4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801052f7:	50                   	push   %eax
801052f8:	e8 b4 ce ff ff       	call   801021b1 <namecmp>
801052fd:	83 c4 10             	add    $0x10,%esp
80105300:	85 c0                	test   %eax,%eax
80105302:	0f 84 49 01 00 00    	je     80105451 <sys_unlink+0x1c8>
80105308:	83 ec 08             	sub    $0x8,%esp
8010530b:	68 48 a4 10 80       	push   $0x8010a448
80105310:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105313:	50                   	push   %eax
80105314:	e8 98 ce ff ff       	call   801021b1 <namecmp>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	0f 84 2d 01 00 00    	je     80105451 <sys_unlink+0x1c8>
80105324:	83 ec 04             	sub    $0x4,%esp
80105327:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010532a:	50                   	push   %eax
8010532b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010532e:	50                   	push   %eax
8010532f:	ff 75 f4             	push   -0xc(%ebp)
80105332:	e8 95 ce ff ff       	call   801021cc <dirlookup>
80105337:	83 c4 10             	add    $0x10,%esp
8010533a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010533d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105341:	0f 84 0d 01 00 00    	je     80105454 <sys_unlink+0x1cb>
80105347:	83 ec 0c             	sub    $0xc,%esp
8010534a:	ff 75 f0             	push   -0x10(%ebp)
8010534d:	e8 98 c6 ff ff       	call   801019ea <ilock>
80105352:	83 c4 10             	add    $0x10,%esp
80105355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105358:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010535c:	66 85 c0             	test   %ax,%ax
8010535f:	7f 0d                	jg     8010536e <sys_unlink+0xe5>
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	68 4b a4 10 80       	push   $0x8010a44b
80105369:	e8 3b b2 ff ff       	call   801005a9 <panic>
8010536e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105371:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105375:	66 83 f8 01          	cmp    $0x1,%ax
80105379:	75 25                	jne    801053a0 <sys_unlink+0x117>
8010537b:	83 ec 0c             	sub    $0xc,%esp
8010537e:	ff 75 f0             	push   -0x10(%ebp)
80105381:	e8 a0 fe ff ff       	call   80105226 <isdirempty>
80105386:	83 c4 10             	add    $0x10,%esp
80105389:	85 c0                	test   %eax,%eax
8010538b:	75 13                	jne    801053a0 <sys_unlink+0x117>
8010538d:	83 ec 0c             	sub    $0xc,%esp
80105390:	ff 75 f0             	push   -0x10(%ebp)
80105393:	e8 83 c8 ff ff       	call   80101c1b <iunlockput>
80105398:	83 c4 10             	add    $0x10,%esp
8010539b:	e9 b5 00 00 00       	jmp    80105455 <sys_unlink+0x1cc>
801053a0:	83 ec 04             	sub    $0x4,%esp
801053a3:	6a 10                	push   $0x10
801053a5:	6a 00                	push   $0x0
801053a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053aa:	50                   	push   %eax
801053ab:	e8 cf f5 ff ff       	call   8010497f <memset>
801053b0:	83 c4 10             	add    $0x10,%esp
801053b3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053b6:	6a 10                	push   $0x10
801053b8:	50                   	push   %eax
801053b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053bc:	50                   	push   %eax
801053bd:	ff 75 f4             	push   -0xc(%ebp)
801053c0:	e8 66 cc ff ff       	call   8010202b <writei>
801053c5:	83 c4 10             	add    $0x10,%esp
801053c8:	83 f8 10             	cmp    $0x10,%eax
801053cb:	74 0d                	je     801053da <sys_unlink+0x151>
801053cd:	83 ec 0c             	sub    $0xc,%esp
801053d0:	68 5d a4 10 80       	push   $0x8010a45d
801053d5:	e8 cf b1 ff ff       	call   801005a9 <panic>
801053da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053e1:	66 83 f8 01          	cmp    $0x1,%ax
801053e5:	75 21                	jne    80105408 <sys_unlink+0x17f>
801053e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ea:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053ee:	83 e8 01             	sub    $0x1,%eax
801053f1:	89 c2                	mov    %eax,%edx
801053f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f6:	66 89 50 56          	mov    %dx,0x56(%eax)
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	ff 75 f4             	push   -0xc(%ebp)
80105400:	e8 08 c4 ff ff       	call   8010180d <iupdate>
80105405:	83 c4 10             	add    $0x10,%esp
80105408:	83 ec 0c             	sub    $0xc,%esp
8010540b:	ff 75 f4             	push   -0xc(%ebp)
8010540e:	e8 08 c8 ff ff       	call   80101c1b <iunlockput>
80105413:	83 c4 10             	add    $0x10,%esp
80105416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105419:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010541d:	83 e8 01             	sub    $0x1,%eax
80105420:	89 c2                	mov    %eax,%edx
80105422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105425:	66 89 50 56          	mov    %dx,0x56(%eax)
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	ff 75 f0             	push   -0x10(%ebp)
8010542f:	e8 d9 c3 ff ff       	call   8010180d <iupdate>
80105434:	83 c4 10             	add    $0x10,%esp
80105437:	83 ec 0c             	sub    $0xc,%esp
8010543a:	ff 75 f0             	push   -0x10(%ebp)
8010543d:	e8 d9 c7 ff ff       	call   80101c1b <iunlockput>
80105442:	83 c4 10             	add    $0x10,%esp
80105445:	e8 7e dc ff ff       	call   801030c8 <end_op>
8010544a:	b8 00 00 00 00       	mov    $0x0,%eax
8010544f:	eb 1c                	jmp    8010546d <sys_unlink+0x1e4>
80105451:	90                   	nop
80105452:	eb 01                	jmp    80105455 <sys_unlink+0x1cc>
80105454:	90                   	nop
80105455:	83 ec 0c             	sub    $0xc,%esp
80105458:	ff 75 f4             	push   -0xc(%ebp)
8010545b:	e8 bb c7 ff ff       	call   80101c1b <iunlockput>
80105460:	83 c4 10             	add    $0x10,%esp
80105463:	e8 60 dc ff ff       	call   801030c8 <end_op>
80105468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546d:	c9                   	leave  
8010546e:	c3                   	ret    

8010546f <create>:
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 38             	sub    $0x38,%esp
80105475:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105478:	8b 55 10             	mov    0x10(%ebp),%edx
8010547b:	8b 45 14             	mov    0x14(%ebp),%eax
8010547e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105482:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105486:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
8010548a:	83 ec 08             	sub    $0x8,%esp
8010548d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105490:	50                   	push   %eax
80105491:	ff 75 08             	push   0x8(%ebp)
80105494:	e8 a0 d0 ff ff       	call   80102539 <nameiparent>
80105499:	83 c4 10             	add    $0x10,%esp
8010549c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010549f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054a3:	75 0a                	jne    801054af <create+0x40>
801054a5:	b8 00 00 00 00       	mov    $0x0,%eax
801054aa:	e9 90 01 00 00       	jmp    8010563f <create+0x1d0>
801054af:	83 ec 0c             	sub    $0xc,%esp
801054b2:	ff 75 f4             	push   -0xc(%ebp)
801054b5:	e8 30 c5 ff ff       	call   801019ea <ilock>
801054ba:	83 c4 10             	add    $0x10,%esp
801054bd:	83 ec 04             	sub    $0x4,%esp
801054c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054c3:	50                   	push   %eax
801054c4:	8d 45 de             	lea    -0x22(%ebp),%eax
801054c7:	50                   	push   %eax
801054c8:	ff 75 f4             	push   -0xc(%ebp)
801054cb:	e8 fc cc ff ff       	call   801021cc <dirlookup>
801054d0:	83 c4 10             	add    $0x10,%esp
801054d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054da:	74 50                	je     8010552c <create+0xbd>
801054dc:	83 ec 0c             	sub    $0xc,%esp
801054df:	ff 75 f4             	push   -0xc(%ebp)
801054e2:	e8 34 c7 ff ff       	call   80101c1b <iunlockput>
801054e7:	83 c4 10             	add    $0x10,%esp
801054ea:	83 ec 0c             	sub    $0xc,%esp
801054ed:	ff 75 f0             	push   -0x10(%ebp)
801054f0:	e8 f5 c4 ff ff       	call   801019ea <ilock>
801054f5:	83 c4 10             	add    $0x10,%esp
801054f8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801054fd:	75 15                	jne    80105514 <create+0xa5>
801054ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105502:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105506:	66 83 f8 02          	cmp    $0x2,%ax
8010550a:	75 08                	jne    80105514 <create+0xa5>
8010550c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550f:	e9 2b 01 00 00       	jmp    8010563f <create+0x1d0>
80105514:	83 ec 0c             	sub    $0xc,%esp
80105517:	ff 75 f0             	push   -0x10(%ebp)
8010551a:	e8 fc c6 ff ff       	call   80101c1b <iunlockput>
8010551f:	83 c4 10             	add    $0x10,%esp
80105522:	b8 00 00 00 00       	mov    $0x0,%eax
80105527:	e9 13 01 00 00       	jmp    8010563f <create+0x1d0>
8010552c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105533:	8b 00                	mov    (%eax),%eax
80105535:	83 ec 08             	sub    $0x8,%esp
80105538:	52                   	push   %edx
80105539:	50                   	push   %eax
8010553a:	e8 f7 c1 ff ff       	call   80101736 <ialloc>
8010553f:	83 c4 10             	add    $0x10,%esp
80105542:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105545:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105549:	75 0d                	jne    80105558 <create+0xe9>
8010554b:	83 ec 0c             	sub    $0xc,%esp
8010554e:	68 6c a4 10 80       	push   $0x8010a46c
80105553:	e8 51 b0 ff ff       	call   801005a9 <panic>
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	ff 75 f0             	push   -0x10(%ebp)
8010555e:	e8 87 c4 ff ff       	call   801019ea <ilock>
80105563:	83 c4 10             	add    $0x10,%esp
80105566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105569:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010556d:	66 89 50 52          	mov    %dx,0x52(%eax)
80105571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105574:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105578:	66 89 50 54          	mov    %dx,0x54(%eax)
8010557c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557f:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
80105585:	83 ec 0c             	sub    $0xc,%esp
80105588:	ff 75 f0             	push   -0x10(%ebp)
8010558b:	e8 7d c2 ff ff       	call   8010180d <iupdate>
80105590:	83 c4 10             	add    $0x10,%esp
80105593:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105598:	75 6a                	jne    80105604 <create+0x195>
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a1:	83 c0 01             	add    $0x1,%eax
801055a4:	89 c2                	mov    %eax,%edx
801055a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a9:	66 89 50 56          	mov    %dx,0x56(%eax)
801055ad:	83 ec 0c             	sub    $0xc,%esp
801055b0:	ff 75 f4             	push   -0xc(%ebp)
801055b3:	e8 55 c2 ff ff       	call   8010180d <iupdate>
801055b8:	83 c4 10             	add    $0x10,%esp
801055bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055be:	8b 40 04             	mov    0x4(%eax),%eax
801055c1:	83 ec 04             	sub    $0x4,%esp
801055c4:	50                   	push   %eax
801055c5:	68 46 a4 10 80       	push   $0x8010a446
801055ca:	ff 75 f0             	push   -0x10(%ebp)
801055cd:	e8 b4 cc ff ff       	call   80102286 <dirlink>
801055d2:	83 c4 10             	add    $0x10,%esp
801055d5:	85 c0                	test   %eax,%eax
801055d7:	78 1e                	js     801055f7 <create+0x188>
801055d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dc:	8b 40 04             	mov    0x4(%eax),%eax
801055df:	83 ec 04             	sub    $0x4,%esp
801055e2:	50                   	push   %eax
801055e3:	68 48 a4 10 80       	push   $0x8010a448
801055e8:	ff 75 f0             	push   -0x10(%ebp)
801055eb:	e8 96 cc ff ff       	call   80102286 <dirlink>
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	85 c0                	test   %eax,%eax
801055f5:	79 0d                	jns    80105604 <create+0x195>
801055f7:	83 ec 0c             	sub    $0xc,%esp
801055fa:	68 7b a4 10 80       	push   $0x8010a47b
801055ff:	e8 a5 af ff ff       	call   801005a9 <panic>
80105604:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105607:	8b 40 04             	mov    0x4(%eax),%eax
8010560a:	83 ec 04             	sub    $0x4,%esp
8010560d:	50                   	push   %eax
8010560e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105611:	50                   	push   %eax
80105612:	ff 75 f4             	push   -0xc(%ebp)
80105615:	e8 6c cc ff ff       	call   80102286 <dirlink>
8010561a:	83 c4 10             	add    $0x10,%esp
8010561d:	85 c0                	test   %eax,%eax
8010561f:	79 0d                	jns    8010562e <create+0x1bf>
80105621:	83 ec 0c             	sub    $0xc,%esp
80105624:	68 87 a4 10 80       	push   $0x8010a487
80105629:	e8 7b af ff ff       	call   801005a9 <panic>
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	ff 75 f4             	push   -0xc(%ebp)
80105634:	e8 e2 c5 ff ff       	call   80101c1b <iunlockput>
80105639:	83 c4 10             	add    $0x10,%esp
8010563c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563f:	c9                   	leave  
80105640:	c3                   	ret    

80105641 <sys_open>:
80105641:	55                   	push   %ebp
80105642:	89 e5                	mov    %esp,%ebp
80105644:	83 ec 28             	sub    $0x28,%esp
80105647:	83 ec 08             	sub    $0x8,%esp
8010564a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010564d:	50                   	push   %eax
8010564e:	6a 00                	push   $0x0
80105650:	e8 ea f6 ff ff       	call   80104d3f <argstr>
80105655:	83 c4 10             	add    $0x10,%esp
80105658:	85 c0                	test   %eax,%eax
8010565a:	78 15                	js     80105671 <sys_open+0x30>
8010565c:	83 ec 08             	sub    $0x8,%esp
8010565f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105662:	50                   	push   %eax
80105663:	6a 01                	push   $0x1
80105665:	e8 40 f6 ff ff       	call   80104caa <argint>
8010566a:	83 c4 10             	add    $0x10,%esp
8010566d:	85 c0                	test   %eax,%eax
8010566f:	79 0a                	jns    8010567b <sys_open+0x3a>
80105671:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105676:	e9 61 01 00 00       	jmp    801057dc <sys_open+0x19b>
8010567b:	e8 bc d9 ff ff       	call   8010303c <begin_op>
80105680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105683:	25 00 02 00 00       	and    $0x200,%eax
80105688:	85 c0                	test   %eax,%eax
8010568a:	74 2a                	je     801056b6 <sys_open+0x75>
8010568c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010568f:	6a 00                	push   $0x0
80105691:	6a 00                	push   $0x0
80105693:	6a 02                	push   $0x2
80105695:	50                   	push   %eax
80105696:	e8 d4 fd ff ff       	call   8010546f <create>
8010569b:	83 c4 10             	add    $0x10,%esp
8010569e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056a5:	75 75                	jne    8010571c <sys_open+0xdb>
801056a7:	e8 1c da ff ff       	call   801030c8 <end_op>
801056ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b1:	e9 26 01 00 00       	jmp    801057dc <sys_open+0x19b>
801056b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056b9:	83 ec 0c             	sub    $0xc,%esp
801056bc:	50                   	push   %eax
801056bd:	e8 5b ce ff ff       	call   8010251d <namei>
801056c2:	83 c4 10             	add    $0x10,%esp
801056c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056cc:	75 0f                	jne    801056dd <sys_open+0x9c>
801056ce:	e8 f5 d9 ff ff       	call   801030c8 <end_op>
801056d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d8:	e9 ff 00 00 00       	jmp    801057dc <sys_open+0x19b>
801056dd:	83 ec 0c             	sub    $0xc,%esp
801056e0:	ff 75 f4             	push   -0xc(%ebp)
801056e3:	e8 02 c3 ff ff       	call   801019ea <ilock>
801056e8:	83 c4 10             	add    $0x10,%esp
801056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ee:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056f2:	66 83 f8 01          	cmp    $0x1,%ax
801056f6:	75 24                	jne    8010571c <sys_open+0xdb>
801056f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056fb:	85 c0                	test   %eax,%eax
801056fd:	74 1d                	je     8010571c <sys_open+0xdb>
801056ff:	83 ec 0c             	sub    $0xc,%esp
80105702:	ff 75 f4             	push   -0xc(%ebp)
80105705:	e8 11 c5 ff ff       	call   80101c1b <iunlockput>
8010570a:	83 c4 10             	add    $0x10,%esp
8010570d:	e8 b6 d9 ff ff       	call   801030c8 <end_op>
80105712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105717:	e9 c0 00 00 00       	jmp    801057dc <sys_open+0x19b>
8010571c:	e8 bc b8 ff ff       	call   80100fdd <filealloc>
80105721:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105724:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105728:	74 17                	je     80105741 <sys_open+0x100>
8010572a:	83 ec 0c             	sub    $0xc,%esp
8010572d:	ff 75 f0             	push   -0x10(%ebp)
80105730:	e8 33 f7 ff ff       	call   80104e68 <fdalloc>
80105735:	83 c4 10             	add    $0x10,%esp
80105738:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010573b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010573f:	79 2e                	jns    8010576f <sys_open+0x12e>
80105741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105745:	74 0e                	je     80105755 <sys_open+0x114>
80105747:	83 ec 0c             	sub    $0xc,%esp
8010574a:	ff 75 f0             	push   -0x10(%ebp)
8010574d:	e8 49 b9 ff ff       	call   8010109b <fileclose>
80105752:	83 c4 10             	add    $0x10,%esp
80105755:	83 ec 0c             	sub    $0xc,%esp
80105758:	ff 75 f4             	push   -0xc(%ebp)
8010575b:	e8 bb c4 ff ff       	call   80101c1b <iunlockput>
80105760:	83 c4 10             	add    $0x10,%esp
80105763:	e8 60 d9 ff ff       	call   801030c8 <end_op>
80105768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576d:	eb 6d                	jmp    801057dc <sys_open+0x19b>
8010576f:	83 ec 0c             	sub    $0xc,%esp
80105772:	ff 75 f4             	push   -0xc(%ebp)
80105775:	e8 83 c3 ff ff       	call   80101afd <iunlock>
8010577a:	83 c4 10             	add    $0x10,%esp
8010577d:	e8 46 d9 ff ff       	call   801030c8 <end_op>
80105782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105785:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105791:	89 50 10             	mov    %edx,0x10(%eax)
80105794:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105797:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
8010579e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057a1:	83 e0 01             	and    $0x1,%eax
801057a4:	85 c0                	test   %eax,%eax
801057a6:	0f 94 c0             	sete   %al
801057a9:	89 c2                	mov    %eax,%edx
801057ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ae:	88 50 08             	mov    %dl,0x8(%eax)
801057b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057b4:	83 e0 01             	and    $0x1,%eax
801057b7:	85 c0                	test   %eax,%eax
801057b9:	75 0a                	jne    801057c5 <sys_open+0x184>
801057bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057be:	83 e0 02             	and    $0x2,%eax
801057c1:	85 c0                	test   %eax,%eax
801057c3:	74 07                	je     801057cc <sys_open+0x18b>
801057c5:	b8 01 00 00 00       	mov    $0x1,%eax
801057ca:	eb 05                	jmp    801057d1 <sys_open+0x190>
801057cc:	b8 00 00 00 00       	mov    $0x0,%eax
801057d1:	89 c2                	mov    %eax,%edx
801057d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d6:	88 50 09             	mov    %dl,0x9(%eax)
801057d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801057dc:	c9                   	leave  
801057dd:	c3                   	ret    

801057de <sys_mkdir>:
801057de:	55                   	push   %ebp
801057df:	89 e5                	mov    %esp,%ebp
801057e1:	83 ec 18             	sub    $0x18,%esp
801057e4:	e8 53 d8 ff ff       	call   8010303c <begin_op>
801057e9:	83 ec 08             	sub    $0x8,%esp
801057ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057ef:	50                   	push   %eax
801057f0:	6a 00                	push   $0x0
801057f2:	e8 48 f5 ff ff       	call   80104d3f <argstr>
801057f7:	83 c4 10             	add    $0x10,%esp
801057fa:	85 c0                	test   %eax,%eax
801057fc:	78 1b                	js     80105819 <sys_mkdir+0x3b>
801057fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105801:	6a 00                	push   $0x0
80105803:	6a 00                	push   $0x0
80105805:	6a 01                	push   $0x1
80105807:	50                   	push   %eax
80105808:	e8 62 fc ff ff       	call   8010546f <create>
8010580d:	83 c4 10             	add    $0x10,%esp
80105810:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105813:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105817:	75 0c                	jne    80105825 <sys_mkdir+0x47>
80105819:	e8 aa d8 ff ff       	call   801030c8 <end_op>
8010581e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105823:	eb 18                	jmp    8010583d <sys_mkdir+0x5f>
80105825:	83 ec 0c             	sub    $0xc,%esp
80105828:	ff 75 f4             	push   -0xc(%ebp)
8010582b:	e8 eb c3 ff ff       	call   80101c1b <iunlockput>
80105830:	83 c4 10             	add    $0x10,%esp
80105833:	e8 90 d8 ff ff       	call   801030c8 <end_op>
80105838:	b8 00 00 00 00       	mov    $0x0,%eax
8010583d:	c9                   	leave  
8010583e:	c3                   	ret    

8010583f <sys_mknod>:
8010583f:	55                   	push   %ebp
80105840:	89 e5                	mov    %esp,%ebp
80105842:	83 ec 18             	sub    $0x18,%esp
80105845:	e8 f2 d7 ff ff       	call   8010303c <begin_op>
8010584a:	83 ec 08             	sub    $0x8,%esp
8010584d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105850:	50                   	push   %eax
80105851:	6a 00                	push   $0x0
80105853:	e8 e7 f4 ff ff       	call   80104d3f <argstr>
80105858:	83 c4 10             	add    $0x10,%esp
8010585b:	85 c0                	test   %eax,%eax
8010585d:	78 4f                	js     801058ae <sys_mknod+0x6f>
8010585f:	83 ec 08             	sub    $0x8,%esp
80105862:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105865:	50                   	push   %eax
80105866:	6a 01                	push   $0x1
80105868:	e8 3d f4 ff ff       	call   80104caa <argint>
8010586d:	83 c4 10             	add    $0x10,%esp
80105870:	85 c0                	test   %eax,%eax
80105872:	78 3a                	js     801058ae <sys_mknod+0x6f>
80105874:	83 ec 08             	sub    $0x8,%esp
80105877:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010587a:	50                   	push   %eax
8010587b:	6a 02                	push   $0x2
8010587d:	e8 28 f4 ff ff       	call   80104caa <argint>
80105882:	83 c4 10             	add    $0x10,%esp
80105885:	85 c0                	test   %eax,%eax
80105887:	78 25                	js     801058ae <sys_mknod+0x6f>
80105889:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010588c:	0f bf c8             	movswl %ax,%ecx
8010588f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105892:	0f bf d0             	movswl %ax,%edx
80105895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105898:	51                   	push   %ecx
80105899:	52                   	push   %edx
8010589a:	6a 03                	push   $0x3
8010589c:	50                   	push   %eax
8010589d:	e8 cd fb ff ff       	call   8010546f <create>
801058a2:	83 c4 10             	add    $0x10,%esp
801058a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ac:	75 0c                	jne    801058ba <sys_mknod+0x7b>
801058ae:	e8 15 d8 ff ff       	call   801030c8 <end_op>
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	eb 18                	jmp    801058d2 <sys_mknod+0x93>
801058ba:	83 ec 0c             	sub    $0xc,%esp
801058bd:	ff 75 f4             	push   -0xc(%ebp)
801058c0:	e8 56 c3 ff ff       	call   80101c1b <iunlockput>
801058c5:	83 c4 10             	add    $0x10,%esp
801058c8:	e8 fb d7 ff ff       	call   801030c8 <end_op>
801058cd:	b8 00 00 00 00       	mov    $0x0,%eax
801058d2:	c9                   	leave  
801058d3:	c3                   	ret    

801058d4 <sys_chdir>:
801058d4:	55                   	push   %ebp
801058d5:	89 e5                	mov    %esp,%ebp
801058d7:	83 ec 18             	sub    $0x18,%esp
801058da:	e8 51 e1 ff ff       	call   80103a30 <myproc>
801058df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058e2:	e8 55 d7 ff ff       	call   8010303c <begin_op>
801058e7:	83 ec 08             	sub    $0x8,%esp
801058ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ed:	50                   	push   %eax
801058ee:	6a 00                	push   $0x0
801058f0:	e8 4a f4 ff ff       	call   80104d3f <argstr>
801058f5:	83 c4 10             	add    $0x10,%esp
801058f8:	85 c0                	test   %eax,%eax
801058fa:	78 18                	js     80105914 <sys_chdir+0x40>
801058fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	50                   	push   %eax
80105903:	e8 15 cc ff ff       	call   8010251d <namei>
80105908:	83 c4 10             	add    $0x10,%esp
8010590b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010590e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105912:	75 0c                	jne    80105920 <sys_chdir+0x4c>
80105914:	e8 af d7 ff ff       	call   801030c8 <end_op>
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	eb 68                	jmp    80105988 <sys_chdir+0xb4>
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	ff 75 f0             	push   -0x10(%ebp)
80105926:	e8 bf c0 ff ff       	call   801019ea <ilock>
8010592b:	83 c4 10             	add    $0x10,%esp
8010592e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105931:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105935:	66 83 f8 01          	cmp    $0x1,%ax
80105939:	74 1a                	je     80105955 <sys_chdir+0x81>
8010593b:	83 ec 0c             	sub    $0xc,%esp
8010593e:	ff 75 f0             	push   -0x10(%ebp)
80105941:	e8 d5 c2 ff ff       	call   80101c1b <iunlockput>
80105946:	83 c4 10             	add    $0x10,%esp
80105949:	e8 7a d7 ff ff       	call   801030c8 <end_op>
8010594e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105953:	eb 33                	jmp    80105988 <sys_chdir+0xb4>
80105955:	83 ec 0c             	sub    $0xc,%esp
80105958:	ff 75 f0             	push   -0x10(%ebp)
8010595b:	e8 9d c1 ff ff       	call   80101afd <iunlock>
80105960:	83 c4 10             	add    $0x10,%esp
80105963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105966:	8b 40 68             	mov    0x68(%eax),%eax
80105969:	83 ec 0c             	sub    $0xc,%esp
8010596c:	50                   	push   %eax
8010596d:	e8 d9 c1 ff ff       	call   80101b4b <iput>
80105972:	83 c4 10             	add    $0x10,%esp
80105975:	e8 4e d7 ff ff       	call   801030c8 <end_op>
8010597a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105980:	89 50 68             	mov    %edx,0x68(%eax)
80105983:	b8 00 00 00 00       	mov    $0x0,%eax
80105988:	c9                   	leave  
80105989:	c3                   	ret    

8010598a <sys_exec>:
8010598a:	55                   	push   %ebp
8010598b:	89 e5                	mov    %esp,%ebp
8010598d:	81 ec 98 00 00 00    	sub    $0x98,%esp
80105993:	83 ec 08             	sub    $0x8,%esp
80105996:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105999:	50                   	push   %eax
8010599a:	6a 00                	push   $0x0
8010599c:	e8 9e f3 ff ff       	call   80104d3f <argstr>
801059a1:	83 c4 10             	add    $0x10,%esp
801059a4:	85 c0                	test   %eax,%eax
801059a6:	78 18                	js     801059c0 <sys_exec+0x36>
801059a8:	83 ec 08             	sub    $0x8,%esp
801059ab:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059b1:	50                   	push   %eax
801059b2:	6a 01                	push   $0x1
801059b4:	e8 f1 f2 ff ff       	call   80104caa <argint>
801059b9:	83 c4 10             	add    $0x10,%esp
801059bc:	85 c0                	test   %eax,%eax
801059be:	79 0a                	jns    801059ca <sys_exec+0x40>
801059c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c5:	e9 c6 00 00 00       	jmp    80105a90 <sys_exec+0x106>
801059ca:	83 ec 04             	sub    $0x4,%esp
801059cd:	68 80 00 00 00       	push   $0x80
801059d2:	6a 00                	push   $0x0
801059d4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059da:	50                   	push   %eax
801059db:	e8 9f ef ff ff       	call   8010497f <memset>
801059e0:	83 c4 10             	add    $0x10,%esp
801059e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ed:	83 f8 1f             	cmp    $0x1f,%eax
801059f0:	76 0a                	jbe    801059fc <sys_exec+0x72>
801059f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f7:	e9 94 00 00 00       	jmp    80105a90 <sys_exec+0x106>
801059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ff:	c1 e0 02             	shl    $0x2,%eax
80105a02:	89 c2                	mov    %eax,%edx
80105a04:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a0a:	01 c2                	add    %eax,%edx
80105a0c:	83 ec 08             	sub    $0x8,%esp
80105a0f:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a15:	50                   	push   %eax
80105a16:	52                   	push   %edx
80105a17:	e8 ed f1 ff ff       	call   80104c09 <fetchint>
80105a1c:	83 c4 10             	add    $0x10,%esp
80105a1f:	85 c0                	test   %eax,%eax
80105a21:	79 07                	jns    80105a2a <sys_exec+0xa0>
80105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a28:	eb 66                	jmp    80105a90 <sys_exec+0x106>
80105a2a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a30:	85 c0                	test   %eax,%eax
80105a32:	75 27                	jne    80105a5b <sys_exec+0xd1>
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a3e:	00 00 00 00 
80105a42:	90                   	nop
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	83 ec 08             	sub    $0x8,%esp
80105a49:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a4f:	52                   	push   %edx
80105a50:	50                   	push   %eax
80105a51:	e8 2a b1 ff ff       	call   80100b80 <exec>
80105a56:	83 c4 10             	add    $0x10,%esp
80105a59:	eb 35                	jmp    80105a90 <sys_exec+0x106>
80105a5b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a64:	c1 e0 02             	shl    $0x2,%eax
80105a67:	01 c2                	add    %eax,%edx
80105a69:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a6f:	83 ec 08             	sub    $0x8,%esp
80105a72:	52                   	push   %edx
80105a73:	50                   	push   %eax
80105a74:	e8 cf f1 ff ff       	call   80104c48 <fetchstr>
80105a79:	83 c4 10             	add    $0x10,%esp
80105a7c:	85 c0                	test   %eax,%eax
80105a7e:	79 07                	jns    80105a87 <sys_exec+0xfd>
80105a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a85:	eb 09                	jmp    80105a90 <sys_exec+0x106>
80105a87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a8b:	e9 5a ff ff ff       	jmp    801059ea <sys_exec+0x60>
80105a90:	c9                   	leave  
80105a91:	c3                   	ret    

80105a92 <sys_pipe>:
80105a92:	55                   	push   %ebp
80105a93:	89 e5                	mov    %esp,%ebp
80105a95:	83 ec 28             	sub    $0x28,%esp
80105a98:	83 ec 04             	sub    $0x4,%esp
80105a9b:	6a 08                	push   $0x8
80105a9d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aa0:	50                   	push   %eax
80105aa1:	6a 00                	push   $0x0
80105aa3:	e8 2f f2 ff ff       	call   80104cd7 <argptr>
80105aa8:	83 c4 10             	add    $0x10,%esp
80105aab:	85 c0                	test   %eax,%eax
80105aad:	79 0a                	jns    80105ab9 <sys_pipe+0x27>
80105aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab4:	e9 ae 00 00 00       	jmp    80105b67 <sys_pipe+0xd5>
80105ab9:	83 ec 08             	sub    $0x8,%esp
80105abc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105abf:	50                   	push   %eax
80105ac0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ac3:	50                   	push   %eax
80105ac4:	e8 a4 da ff ff       	call   8010356d <pipealloc>
80105ac9:	83 c4 10             	add    $0x10,%esp
80105acc:	85 c0                	test   %eax,%eax
80105ace:	79 0a                	jns    80105ada <sys_pipe+0x48>
80105ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad5:	e9 8d 00 00 00       	jmp    80105b67 <sys_pipe+0xd5>
80105ada:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
80105ae1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae4:	83 ec 0c             	sub    $0xc,%esp
80105ae7:	50                   	push   %eax
80105ae8:	e8 7b f3 ff ff       	call   80104e68 <fdalloc>
80105aed:	83 c4 10             	add    $0x10,%esp
80105af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af7:	78 18                	js     80105b11 <sys_pipe+0x7f>
80105af9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105afc:	83 ec 0c             	sub    $0xc,%esp
80105aff:	50                   	push   %eax
80105b00:	e8 63 f3 ff ff       	call   80104e68 <fdalloc>
80105b05:	83 c4 10             	add    $0x10,%esp
80105b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b0f:	79 3e                	jns    80105b4f <sys_pipe+0xbd>
80105b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b15:	78 13                	js     80105b2a <sys_pipe+0x98>
80105b17:	e8 14 df ff ff       	call   80103a30 <myproc>
80105b1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b1f:	83 c2 08             	add    $0x8,%edx
80105b22:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b29:	00 
80105b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b2d:	83 ec 0c             	sub    $0xc,%esp
80105b30:	50                   	push   %eax
80105b31:	e8 65 b5 ff ff       	call   8010109b <fileclose>
80105b36:	83 c4 10             	add    $0x10,%esp
80105b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b3c:	83 ec 0c             	sub    $0xc,%esp
80105b3f:	50                   	push   %eax
80105b40:	e8 56 b5 ff ff       	call   8010109b <fileclose>
80105b45:	83 c4 10             	add    $0x10,%esp
80105b48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4d:	eb 18                	jmp    80105b67 <sys_pipe+0xd5>
80105b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b55:	89 10                	mov    %edx,(%eax)
80105b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5a:	8d 50 04             	lea    0x4(%eax),%edx
80105b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b60:	89 02                	mov    %eax,(%edx)
80105b62:	b8 00 00 00 00       	mov    $0x0,%eax
80105b67:	c9                   	leave  
80105b68:	c3                   	ret    

80105b69 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b69:	55                   	push   %ebp
80105b6a:	89 e5                	mov    %esp,%ebp
80105b6c:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b6f:	e8 be e1 ff ff       	call   80103d32 <fork>
}
80105b74:	c9                   	leave  
80105b75:	c3                   	ret    

80105b76 <sys_exit>:

int
sys_exit(void)
{
80105b76:	55                   	push   %ebp
80105b77:	89 e5                	mov    %esp,%ebp
80105b79:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b7c:	e8 2a e3 ff ff       	call   80103eab <exit>
  return 0;  // not reached
80105b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b86:	c9                   	leave  
80105b87:	c3                   	ret    

80105b88 <sys_wait>:

int
sys_wait(void)
{
80105b88:	55                   	push   %ebp
80105b89:	89 e5                	mov    %esp,%ebp
80105b8b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b8e:	e8 3b e4 ff ff       	call   80103fce <wait>
}
80105b93:	c9                   	leave  
80105b94:	c3                   	ret    

80105b95 <sys_kill>:

int
sys_kill(void)
{
80105b95:	55                   	push   %ebp
80105b96:	89 e5                	mov    %esp,%ebp
80105b98:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105b9b:	83 ec 08             	sub    $0x8,%esp
80105b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba1:	50                   	push   %eax
80105ba2:	6a 00                	push   $0x0
80105ba4:	e8 01 f1 ff ff       	call   80104caa <argint>
80105ba9:	83 c4 10             	add    $0x10,%esp
80105bac:	85 c0                	test   %eax,%eax
80105bae:	79 07                	jns    80105bb7 <sys_kill+0x22>
    return -1;
80105bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb5:	eb 0f                	jmp    80105bc6 <sys_kill+0x31>
  return kill(pid);
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	83 ec 0c             	sub    $0xc,%esp
80105bbd:	50                   	push   %eax
80105bbe:	e8 43 e8 ff ff       	call   80104406 <kill>
80105bc3:	83 c4 10             	add    $0x10,%esp
}
80105bc6:	c9                   	leave  
80105bc7:	c3                   	ret    

80105bc8 <sys_getpid>:

int
sys_getpid(void)
{
80105bc8:	55                   	push   %ebp
80105bc9:	89 e5                	mov    %esp,%ebp
80105bcb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bce:	e8 5d de ff ff       	call   80103a30 <myproc>
80105bd3:	8b 40 10             	mov    0x10(%eax),%eax
}
80105bd6:	c9                   	leave  
80105bd7:	c3                   	ret    

80105bd8 <sys_sbrk>:

int
sys_sbrk(void)
{
80105bd8:	55                   	push   %ebp
80105bd9:	89 e5                	mov    %esp,%ebp
80105bdb:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105bde:	83 ec 08             	sub    $0x8,%esp
80105be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be4:	50                   	push   %eax
80105be5:	6a 00                	push   $0x0
80105be7:	e8 be f0 ff ff       	call   80104caa <argint>
80105bec:	83 c4 10             	add    $0x10,%esp
80105bef:	85 c0                	test   %eax,%eax
80105bf1:	79 07                	jns    80105bfa <sys_sbrk+0x22>
    return -1;
80105bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf8:	eb 27                	jmp    80105c21 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105bfa:	e8 31 de ff ff       	call   80103a30 <myproc>
80105bff:	8b 00                	mov    (%eax),%eax
80105c01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	50                   	push   %eax
80105c0b:	e8 87 e0 ff ff       	call   80103c97 <growproc>
80105c10:	83 c4 10             	add    $0x10,%esp
80105c13:	85 c0                	test   %eax,%eax
80105c15:	79 07                	jns    80105c1e <sys_sbrk+0x46>
    return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	eb 03                	jmp    80105c21 <sys_sbrk+0x49>
  return addr;
80105c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c21:	c9                   	leave  
80105c22:	c3                   	ret    

80105c23 <sys_sleep>:

int
sys_sleep(void)
{
80105c23:	55                   	push   %ebp
80105c24:	89 e5                	mov    %esp,%ebp
80105c26:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c29:	83 ec 08             	sub    $0x8,%esp
80105c2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c2f:	50                   	push   %eax
80105c30:	6a 00                	push   $0x0
80105c32:	e8 73 f0 ff ff       	call   80104caa <argint>
80105c37:	83 c4 10             	add    $0x10,%esp
80105c3a:	85 c0                	test   %eax,%eax
80105c3c:	79 07                	jns    80105c45 <sys_sleep+0x22>
    return -1;
80105c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c43:	eb 76                	jmp    80105cbb <sys_sleep+0x98>
  acquire(&tickslock);
80105c45:	83 ec 0c             	sub    $0xc,%esp
80105c48:	68 40 6b 19 80       	push   $0x80196b40
80105c4d:	e8 b7 ea ff ff       	call   80104709 <acquire>
80105c52:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c55:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c5d:	eb 38                	jmp    80105c97 <sys_sleep+0x74>
    if(myproc()->killed){
80105c5f:	e8 cc dd ff ff       	call   80103a30 <myproc>
80105c64:	8b 40 24             	mov    0x24(%eax),%eax
80105c67:	85 c0                	test   %eax,%eax
80105c69:	74 17                	je     80105c82 <sys_sleep+0x5f>
      release(&tickslock);
80105c6b:	83 ec 0c             	sub    $0xc,%esp
80105c6e:	68 40 6b 19 80       	push   $0x80196b40
80105c73:	e8 ff ea ff ff       	call   80104777 <release>
80105c78:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c80:	eb 39                	jmp    80105cbb <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c82:	83 ec 08             	sub    $0x8,%esp
80105c85:	68 40 6b 19 80       	push   $0x80196b40
80105c8a:	68 74 6b 19 80       	push   $0x80196b74
80105c8f:	e8 51 e6 ff ff       	call   801042e5 <sleep>
80105c94:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105c97:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105c9c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105c9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ca2:	39 d0                	cmp    %edx,%eax
80105ca4:	72 b9                	jb     80105c5f <sys_sleep+0x3c>
  }
  release(&tickslock);
80105ca6:	83 ec 0c             	sub    $0xc,%esp
80105ca9:	68 40 6b 19 80       	push   $0x80196b40
80105cae:	e8 c4 ea ff ff       	call   80104777 <release>
80105cb3:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbb:	c9                   	leave  
80105cbc:	c3                   	ret    

80105cbd <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cbd:	55                   	push   %ebp
80105cbe:	89 e5                	mov    %esp,%ebp
80105cc0:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	68 40 6b 19 80       	push   $0x80196b40
80105ccb:	e8 39 ea ff ff       	call   80104709 <acquire>
80105cd0:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105cd3:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105cdb:	83 ec 0c             	sub    $0xc,%esp
80105cde:	68 40 6b 19 80       	push   $0x80196b40
80105ce3:	e8 8f ea ff ff       	call   80104777 <release>
80105ce8:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <sys_uthread_init>:

// 이거 추가
int
sys_uthread_init(void)
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	53                   	push   %ebx
80105cf4:	83 ec 14             	sub    $0x14,%esp
  int addr;
  if (argint(0, &addr) < 0)
80105cf7:	83 ec 08             	sub    $0x8,%esp
80105cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cfd:	50                   	push   %eax
80105cfe:	6a 00                	push   $0x0
80105d00:	e8 a5 ef ff ff       	call   80104caa <argint>
80105d05:	83 c4 10             	add    $0x10,%esp
80105d08:	85 c0                	test   %eax,%eax
80105d0a:	79 07                	jns    80105d13 <sys_uthread_init+0x23>
    return -1;
80105d0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d11:	eb 12                	jmp    80105d25 <sys_uthread_init+0x35>
  myproc()->scheduler = addr;
80105d13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80105d16:	e8 15 dd ff ff       	call   80103a30 <myproc>
80105d1b:	89 da                	mov    %ebx,%edx
80105d1d:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80105d20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d28:	c9                   	leave  
80105d29:	c3                   	ret    

80105d2a <sys_check_counter>:



int sys_check_counter(void) {
80105d2a:	55                   	push   %ebp
80105d2b:	89 e5                	mov    %esp,%ebp
80105d2d:	83 ec 18             	sub    $0x18,%esp
  int op;
  if (argint(0, &op) < 0)  // 사용자로부터 인자 하나 받음
80105d30:	83 ec 08             	sub    $0x8,%esp
80105d33:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d36:	50                   	push   %eax
80105d37:	6a 00                	push   $0x0
80105d39:	e8 6c ef ff ff       	call   80104caa <argint>
80105d3e:	83 c4 10             	add    $0x10,%esp
80105d41:	85 c0                	test   %eax,%eax
80105d43:	79 07                	jns    80105d4c <sys_check_counter+0x22>
    return -1;
80105d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4a:	eb 24                	jmp    80105d70 <sys_check_counter+0x46>

  struct proc* p = myproc();
80105d4c:	e8 df dc ff ff       	call   80103a30 <myproc>
80105d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->check_counter += op;  // +1 또는 -1
80105d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d57:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d60:	01 c2                	add    %eax,%edx
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80105d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d70:	c9                   	leave  
80105d71:	c3                   	ret    

80105d72 <alltraps>:
80105d72:	1e                   	push   %ds
80105d73:	06                   	push   %es
80105d74:	0f a0                	push   %fs
80105d76:	0f a8                	push   %gs
80105d78:	60                   	pusha  
80105d79:	66 b8 10 00          	mov    $0x10,%ax
80105d7d:	8e d8                	mov    %eax,%ds
80105d7f:	8e c0                	mov    %eax,%es
80105d81:	54                   	push   %esp
80105d82:	e8 d7 01 00 00       	call   80105f5e <trap>
80105d87:	83 c4 04             	add    $0x4,%esp

80105d8a <trapret>:
80105d8a:	61                   	popa   
80105d8b:	0f a9                	pop    %gs
80105d8d:	0f a1                	pop    %fs
80105d8f:	07                   	pop    %es
80105d90:	1f                   	pop    %ds
80105d91:	83 c4 08             	add    $0x8,%esp
80105d94:	cf                   	iret   

80105d95 <lidt>:
{
80105d95:	55                   	push   %ebp
80105d96:	89 e5                	mov    %esp,%ebp
80105d98:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d9e:	83 e8 01             	sub    $0x1,%eax
80105da1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105da5:	8b 45 08             	mov    0x8(%ebp),%eax
80105da8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105dac:	8b 45 08             	mov    0x8(%ebp),%eax
80105daf:	c1 e8 10             	shr    $0x10,%eax
80105db2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105db6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105db9:	0f 01 18             	lidtl  (%eax)
}
80105dbc:	90                   	nop
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <rcr2>:

static inline uint
rcr2(void)
{
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105dc5:	0f 20 d0             	mov    %cr2,%eax
80105dc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dce:	c9                   	leave  
80105dcf:	c3                   	ret    

80105dd0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105dd0:	55                   	push   %ebp
80105dd1:	89 e5                	mov    %esp,%ebp
80105dd3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105dd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ddd:	e9 c3 00 00 00       	jmp    80105ea5 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de5:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80105dec:	89 c2                	mov    %eax,%edx
80105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df1:	66 89 14 c5 40 63 19 	mov    %dx,-0x7fe69cc0(,%eax,8)
80105df8:	80 
80105df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfc:	66 c7 04 c5 42 63 19 	movw   $0x8,-0x7fe69cbe(,%eax,8)
80105e03:	80 08 00 
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105e10:	80 
80105e11:	83 e2 e0             	and    $0xffffffe0,%edx
80105e14:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1e:	0f b6 14 c5 44 63 19 	movzbl -0x7fe69cbc(,%eax,8),%edx
80105e25:	80 
80105e26:	83 e2 1f             	and    $0x1f,%edx
80105e29:	88 14 c5 44 63 19 80 	mov    %dl,-0x7fe69cbc(,%eax,8)
80105e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e33:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e3a:	80 
80105e3b:	83 e2 f0             	and    $0xfffffff0,%edx
80105e3e:	83 ca 0e             	or     $0xe,%edx
80105e41:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4b:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e52:	80 
80105e53:	83 e2 ef             	and    $0xffffffef,%edx
80105e56:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e60:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e67:	80 
80105e68:	83 e2 9f             	and    $0xffffff9f,%edx
80105e6b:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e75:	0f b6 14 c5 45 63 19 	movzbl -0x7fe69cbb(,%eax,8),%edx
80105e7c:	80 
80105e7d:	83 ca 80             	or     $0xffffff80,%edx
80105e80:	88 14 c5 45 63 19 80 	mov    %dl,-0x7fe69cbb(,%eax,8)
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80105e91:	c1 e8 10             	shr    $0x10,%eax
80105e94:	89 c2                	mov    %eax,%edx
80105e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e99:	66 89 14 c5 46 63 19 	mov    %dx,-0x7fe69cba(,%eax,8)
80105ea0:	80 
  for(i = 0; i < 256; i++)
80105ea1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105ea5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105eac:	0f 8e 30 ff ff ff    	jle    80105de2 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105eb2:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80105eb7:	66 a3 40 65 19 80    	mov    %ax,0x80196540
80105ebd:	66 c7 05 42 65 19 80 	movw   $0x8,0x80196542
80105ec4:	08 00 
80105ec6:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105ecd:	83 e0 e0             	and    $0xffffffe0,%eax
80105ed0:	a2 44 65 19 80       	mov    %al,0x80196544
80105ed5:	0f b6 05 44 65 19 80 	movzbl 0x80196544,%eax
80105edc:	83 e0 1f             	and    $0x1f,%eax
80105edf:	a2 44 65 19 80       	mov    %al,0x80196544
80105ee4:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105eeb:	83 c8 0f             	or     $0xf,%eax
80105eee:	a2 45 65 19 80       	mov    %al,0x80196545
80105ef3:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105efa:	83 e0 ef             	and    $0xffffffef,%eax
80105efd:	a2 45 65 19 80       	mov    %al,0x80196545
80105f02:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105f09:	83 c8 60             	or     $0x60,%eax
80105f0c:	a2 45 65 19 80       	mov    %al,0x80196545
80105f11:	0f b6 05 45 65 19 80 	movzbl 0x80196545,%eax
80105f18:	83 c8 80             	or     $0xffffff80,%eax
80105f1b:	a2 45 65 19 80       	mov    %al,0x80196545
80105f20:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80105f25:	c1 e8 10             	shr    $0x10,%eax
80105f28:	66 a3 46 65 19 80    	mov    %ax,0x80196546

  initlock(&tickslock, "time");
80105f2e:	83 ec 08             	sub    $0x8,%esp
80105f31:	68 98 a4 10 80       	push   $0x8010a498
80105f36:	68 40 6b 19 80       	push   $0x80196b40
80105f3b:	e8 a7 e7 ff ff       	call   801046e7 <initlock>
80105f40:	83 c4 10             	add    $0x10,%esp
}
80105f43:	90                   	nop
80105f44:	c9                   	leave  
80105f45:	c3                   	ret    

80105f46 <idtinit>:

void
idtinit(void)
{
80105f46:	55                   	push   %ebp
80105f47:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f49:	68 00 08 00 00       	push   $0x800
80105f4e:	68 40 63 19 80       	push   $0x80196340
80105f53:	e8 3d fe ff ff       	call   80105d95 <lidt>
80105f58:	83 c4 08             	add    $0x8,%esp
}
80105f5b:	90                   	nop
80105f5c:	c9                   	leave  
80105f5d:	c3                   	ret    

80105f5e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f5e:	55                   	push   %ebp
80105f5f:	89 e5                	mov    %esp,%ebp
80105f61:	57                   	push   %edi
80105f62:	56                   	push   %esi
80105f63:	53                   	push   %ebx
80105f64:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f67:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6a:	8b 40 30             	mov    0x30(%eax),%eax
80105f6d:	83 f8 40             	cmp    $0x40,%eax
80105f70:	75 3b                	jne    80105fad <trap+0x4f>
    if(myproc()->killed)
80105f72:	e8 b9 da ff ff       	call   80103a30 <myproc>
80105f77:	8b 40 24             	mov    0x24(%eax),%eax
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	74 05                	je     80105f83 <trap+0x25>
      exit();
80105f7e:	e8 28 df ff ff       	call   80103eab <exit>
    myproc()->tf = tf;
80105f83:	e8 a8 da ff ff       	call   80103a30 <myproc>
80105f88:	8b 55 08             	mov    0x8(%ebp),%edx
80105f8b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f8e:	e8 e3 ed ff ff       	call   80104d76 <syscall>
    if(myproc()->killed)
80105f93:	e8 98 da ff ff       	call   80103a30 <myproc>
80105f98:	8b 40 24             	mov    0x24(%eax),%eax
80105f9b:	85 c0                	test   %eax,%eax
80105f9d:	0f 84 68 02 00 00    	je     8010620b <trap+0x2ad>
      exit();
80105fa3:	e8 03 df ff ff       	call   80103eab <exit>
    return;
80105fa8:	e9 5e 02 00 00       	jmp    8010620b <trap+0x2ad>
  }

  switch(tf->trapno){
80105fad:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb0:	8b 40 30             	mov    0x30(%eax),%eax
80105fb3:	83 e8 20             	sub    $0x20,%eax
80105fb6:	83 f8 1f             	cmp    $0x1f,%eax
80105fb9:	0f 87 14 01 00 00    	ja     801060d3 <trap+0x175>
80105fbf:	8b 04 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%eax
80105fc6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105fc8:	e8 d0 d9 ff ff       	call   8010399d <cpuid>
80105fcd:	85 c0                	test   %eax,%eax
80105fcf:	75 3d                	jne    8010600e <trap+0xb0>
      acquire(&tickslock);
80105fd1:	83 ec 0c             	sub    $0xc,%esp
80105fd4:	68 40 6b 19 80       	push   $0x80196b40
80105fd9:	e8 2b e7 ff ff       	call   80104709 <acquire>
80105fde:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105fe1:	a1 74 6b 19 80       	mov    0x80196b74,%eax
80105fe6:	83 c0 01             	add    $0x1,%eax
80105fe9:	a3 74 6b 19 80       	mov    %eax,0x80196b74
      wakeup(&ticks);
80105fee:	83 ec 0c             	sub    $0xc,%esp
80105ff1:	68 74 6b 19 80       	push   $0x80196b74
80105ff6:	e8 d4 e3 ff ff       	call   801043cf <wakeup>
80105ffb:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105ffe:	83 ec 0c             	sub    $0xc,%esp
80106001:	68 40 6b 19 80       	push   $0x80196b40
80106006:	e8 6c e7 ff ff       	call   80104777 <release>
8010600b:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010600e:	e8 09 cb ff ff       	call   80102b1c <lapiceoi>

    // 🔥 유저모드 + scheduler 설정된 경우만 실행
    struct proc *p = myproc();
80106013:	e8 18 da ff ff       	call   80103a30 <myproc>
80106018:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p && p->state == RUNNING && p->scheduler /*&& (tf->cs & 3) == DPL_USER*/) {
8010601b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010601f:	0f 84 65 01 00 00    	je     8010618a <trap+0x22c>
80106025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106028:	8b 40 0c             	mov    0xc(%eax),%eax
8010602b:	83 f8 04             	cmp    $0x4,%eax
8010602e:	0f 85 56 01 00 00    	jne    8010618a <trap+0x22c>
80106034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106037:	8b 40 7c             	mov    0x7c(%eax),%eax
8010603a:	85 c0                	test   %eax,%eax
8010603c:	0f 84 48 01 00 00    	je     8010618a <trap+0x22c>
      if(p->check_counter >= 2){
80106042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106045:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010604b:	83 f8 01             	cmp    $0x1,%eax
8010604e:	0f 8e 36 01 00 00    	jle    8010618a <trap+0x22c>
        p->tf->eip = p->scheduler;
80106054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106057:	8b 40 18             	mov    0x18(%eax),%eax
8010605a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010605d:	8b 52 7c             	mov    0x7c(%edx),%edx
80106060:	89 50 38             	mov    %edx,0x38(%eax)
      }
    }
    

    break;
80106063:	e9 22 01 00 00       	jmp    8010618a <trap+0x22c>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106068:	e8 f8 3e 00 00       	call   80109f65 <ideintr>
    lapiceoi();
8010606d:	e8 aa ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106072:	e9 14 01 00 00       	jmp    8010618b <trap+0x22d>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106077:	e8 e5 c8 ff ff       	call   80102961 <kbdintr>
    lapiceoi();
8010607c:	e8 9b ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106081:	e9 05 01 00 00       	jmp    8010618b <trap+0x22d>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106086:	e8 56 03 00 00       	call   801063e1 <uartintr>
    lapiceoi();
8010608b:	e8 8c ca ff ff       	call   80102b1c <lapiceoi>
    break;
80106090:	e9 f6 00 00 00       	jmp    8010618b <trap+0x22d>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106095:	e8 7e 2b 00 00       	call   80108c18 <i8254_intr>
    lapiceoi();
8010609a:	e8 7d ca ff ff       	call   80102b1c <lapiceoi>
    break;
8010609f:	e9 e7 00 00 00       	jmp    8010618b <trap+0x22d>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060a4:	8b 45 08             	mov    0x8(%ebp),%eax
801060a7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801060aa:	8b 45 08             	mov    0x8(%ebp),%eax
801060ad:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060b1:	0f b7 d8             	movzwl %ax,%ebx
801060b4:	e8 e4 d8 ff ff       	call   8010399d <cpuid>
801060b9:	56                   	push   %esi
801060ba:	53                   	push   %ebx
801060bb:	50                   	push   %eax
801060bc:	68 a0 a4 10 80       	push   $0x8010a4a0
801060c1:	e8 2e a3 ff ff       	call   801003f4 <cprintf>
801060c6:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801060c9:	e8 4e ca ff ff       	call   80102b1c <lapiceoi>
    break;
801060ce:	e9 b8 00 00 00       	jmp    8010618b <trap+0x22d>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801060d3:	e8 58 d9 ff ff       	call   80103a30 <myproc>
801060d8:	85 c0                	test   %eax,%eax
801060da:	74 11                	je     801060ed <trap+0x18f>
801060dc:	8b 45 08             	mov    0x8(%ebp),%eax
801060df:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801060e3:	0f b7 c0             	movzwl %ax,%eax
801060e6:	83 e0 03             	and    $0x3,%eax
801060e9:	85 c0                	test   %eax,%eax
801060eb:	75 39                	jne    80106126 <trap+0x1c8>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801060ed:	e8 cd fc ff ff       	call   80105dbf <rcr2>
801060f2:	89 c3                	mov    %eax,%ebx
801060f4:	8b 45 08             	mov    0x8(%ebp),%eax
801060f7:	8b 70 38             	mov    0x38(%eax),%esi
801060fa:	e8 9e d8 ff ff       	call   8010399d <cpuid>
801060ff:	8b 55 08             	mov    0x8(%ebp),%edx
80106102:	8b 52 30             	mov    0x30(%edx),%edx
80106105:	83 ec 0c             	sub    $0xc,%esp
80106108:	53                   	push   %ebx
80106109:	56                   	push   %esi
8010610a:	50                   	push   %eax
8010610b:	52                   	push   %edx
8010610c:	68 c4 a4 10 80       	push   $0x8010a4c4
80106111:	e8 de a2 ff ff       	call   801003f4 <cprintf>
80106116:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106119:	83 ec 0c             	sub    $0xc,%esp
8010611c:	68 f6 a4 10 80       	push   $0x8010a4f6
80106121:	e8 83 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106126:	e8 94 fc ff ff       	call   80105dbf <rcr2>
8010612b:	89 c6                	mov    %eax,%esi
8010612d:	8b 45 08             	mov    0x8(%ebp),%eax
80106130:	8b 40 38             	mov    0x38(%eax),%eax
80106133:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106136:	e8 62 d8 ff ff       	call   8010399d <cpuid>
8010613b:	89 c3                	mov    %eax,%ebx
8010613d:	8b 45 08             	mov    0x8(%ebp),%eax
80106140:	8b 48 34             	mov    0x34(%eax),%ecx
80106143:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106146:	8b 45 08             	mov    0x8(%ebp),%eax
80106149:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010614c:	e8 df d8 ff ff       	call   80103a30 <myproc>
80106151:	8d 50 6c             	lea    0x6c(%eax),%edx
80106154:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106157:	e8 d4 d8 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010615c:	8b 40 10             	mov    0x10(%eax),%eax
8010615f:	56                   	push   %esi
80106160:	ff 75 d4             	push   -0x2c(%ebp)
80106163:	53                   	push   %ebx
80106164:	ff 75 d0             	push   -0x30(%ebp)
80106167:	57                   	push   %edi
80106168:	ff 75 cc             	push   -0x34(%ebp)
8010616b:	50                   	push   %eax
8010616c:	68 fc a4 10 80       	push   $0x8010a4fc
80106171:	e8 7e a2 ff ff       	call   801003f4 <cprintf>
80106176:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106179:	e8 b2 d8 ff ff       	call   80103a30 <myproc>
8010617e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106185:	eb 04                	jmp    8010618b <trap+0x22d>
    break;
80106187:	90                   	nop
80106188:	eb 01                	jmp    8010618b <trap+0x22d>
    break;
8010618a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010618b:	e8 a0 d8 ff ff       	call   80103a30 <myproc>
80106190:	85 c0                	test   %eax,%eax
80106192:	74 23                	je     801061b7 <trap+0x259>
80106194:	e8 97 d8 ff ff       	call   80103a30 <myproc>
80106199:	8b 40 24             	mov    0x24(%eax),%eax
8010619c:	85 c0                	test   %eax,%eax
8010619e:	74 17                	je     801061b7 <trap+0x259>
801061a0:	8b 45 08             	mov    0x8(%ebp),%eax
801061a3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061a7:	0f b7 c0             	movzwl %ax,%eax
801061aa:	83 e0 03             	and    $0x3,%eax
801061ad:	83 f8 03             	cmp    $0x3,%eax
801061b0:	75 05                	jne    801061b7 <trap+0x259>
    exit();
801061b2:	e8 f4 dc ff ff       	call   80103eab <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801061b7:	e8 74 d8 ff ff       	call   80103a30 <myproc>
801061bc:	85 c0                	test   %eax,%eax
801061be:	74 1d                	je     801061dd <trap+0x27f>
801061c0:	e8 6b d8 ff ff       	call   80103a30 <myproc>
801061c5:	8b 40 0c             	mov    0xc(%eax),%eax
801061c8:	83 f8 04             	cmp    $0x4,%eax
801061cb:	75 10                	jne    801061dd <trap+0x27f>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801061cd:	8b 45 08             	mov    0x8(%ebp),%eax
801061d0:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801061d3:	83 f8 20             	cmp    $0x20,%eax
801061d6:	75 05                	jne    801061dd <trap+0x27f>
    yield();
801061d8:	e8 88 e0 ff ff       	call   80104265 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801061dd:	e8 4e d8 ff ff       	call   80103a30 <myproc>
801061e2:	85 c0                	test   %eax,%eax
801061e4:	74 26                	je     8010620c <trap+0x2ae>
801061e6:	e8 45 d8 ff ff       	call   80103a30 <myproc>
801061eb:	8b 40 24             	mov    0x24(%eax),%eax
801061ee:	85 c0                	test   %eax,%eax
801061f0:	74 1a                	je     8010620c <trap+0x2ae>
801061f2:	8b 45 08             	mov    0x8(%ebp),%eax
801061f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061f9:	0f b7 c0             	movzwl %ax,%eax
801061fc:	83 e0 03             	and    $0x3,%eax
801061ff:	83 f8 03             	cmp    $0x3,%eax
80106202:	75 08                	jne    8010620c <trap+0x2ae>
    exit();
80106204:	e8 a2 dc ff ff       	call   80103eab <exit>
80106209:	eb 01                	jmp    8010620c <trap+0x2ae>
    return;
8010620b:	90                   	nop
}
8010620c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010620f:	5b                   	pop    %ebx
80106210:	5e                   	pop    %esi
80106211:	5f                   	pop    %edi
80106212:	5d                   	pop    %ebp
80106213:	c3                   	ret    

80106214 <inb>:
{
80106214:	55                   	push   %ebp
80106215:	89 e5                	mov    %esp,%ebp
80106217:	83 ec 14             	sub    $0x14,%esp
8010621a:	8b 45 08             	mov    0x8(%ebp),%eax
8010621d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106221:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106225:	89 c2                	mov    %eax,%edx
80106227:	ec                   	in     (%dx),%al
80106228:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010622b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010622f:	c9                   	leave  
80106230:	c3                   	ret    

80106231 <outb>:
{
80106231:	55                   	push   %ebp
80106232:	89 e5                	mov    %esp,%ebp
80106234:	83 ec 08             	sub    $0x8,%esp
80106237:	8b 45 08             	mov    0x8(%ebp),%eax
8010623a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010623d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106241:	89 d0                	mov    %edx,%eax
80106243:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106246:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010624a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010624e:	ee                   	out    %al,(%dx)
}
8010624f:	90                   	nop
80106250:	c9                   	leave  
80106251:	c3                   	ret    

80106252 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106252:	55                   	push   %ebp
80106253:	89 e5                	mov    %esp,%ebp
80106255:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106258:	6a 00                	push   $0x0
8010625a:	68 fa 03 00 00       	push   $0x3fa
8010625f:	e8 cd ff ff ff       	call   80106231 <outb>
80106264:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106267:	68 80 00 00 00       	push   $0x80
8010626c:	68 fb 03 00 00       	push   $0x3fb
80106271:	e8 bb ff ff ff       	call   80106231 <outb>
80106276:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106279:	6a 0c                	push   $0xc
8010627b:	68 f8 03 00 00       	push   $0x3f8
80106280:	e8 ac ff ff ff       	call   80106231 <outb>
80106285:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106288:	6a 00                	push   $0x0
8010628a:	68 f9 03 00 00       	push   $0x3f9
8010628f:	e8 9d ff ff ff       	call   80106231 <outb>
80106294:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106297:	6a 03                	push   $0x3
80106299:	68 fb 03 00 00       	push   $0x3fb
8010629e:	e8 8e ff ff ff       	call   80106231 <outb>
801062a3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801062a6:	6a 00                	push   $0x0
801062a8:	68 fc 03 00 00       	push   $0x3fc
801062ad:	e8 7f ff ff ff       	call   80106231 <outb>
801062b2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801062b5:	6a 01                	push   $0x1
801062b7:	68 f9 03 00 00       	push   $0x3f9
801062bc:	e8 70 ff ff ff       	call   80106231 <outb>
801062c1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801062c4:	68 fd 03 00 00       	push   $0x3fd
801062c9:	e8 46 ff ff ff       	call   80106214 <inb>
801062ce:	83 c4 04             	add    $0x4,%esp
801062d1:	3c ff                	cmp    $0xff,%al
801062d3:	74 61                	je     80106336 <uartinit+0xe4>
    return;
  uart = 1;
801062d5:	c7 05 78 6b 19 80 01 	movl   $0x1,0x80196b78
801062dc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801062df:	68 fa 03 00 00       	push   $0x3fa
801062e4:	e8 2b ff ff ff       	call   80106214 <inb>
801062e9:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801062ec:	68 f8 03 00 00       	push   $0x3f8
801062f1:	e8 1e ff ff ff       	call   80106214 <inb>
801062f6:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801062f9:	83 ec 08             	sub    $0x8,%esp
801062fc:	6a 00                	push   $0x0
801062fe:	6a 04                	push   $0x4
80106300:	e8 29 c3 ff ff       	call   8010262e <ioapicenable>
80106305:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106308:	c7 45 f4 c0 a5 10 80 	movl   $0x8010a5c0,-0xc(%ebp)
8010630f:	eb 19                	jmp    8010632a <uartinit+0xd8>
    uartputc(*p);
80106311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106314:	0f b6 00             	movzbl (%eax),%eax
80106317:	0f be c0             	movsbl %al,%eax
8010631a:	83 ec 0c             	sub    $0xc,%esp
8010631d:	50                   	push   %eax
8010631e:	e8 16 00 00 00       	call   80106339 <uartputc>
80106323:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106326:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010632a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632d:	0f b6 00             	movzbl (%eax),%eax
80106330:	84 c0                	test   %al,%al
80106332:	75 dd                	jne    80106311 <uartinit+0xbf>
80106334:	eb 01                	jmp    80106337 <uartinit+0xe5>
    return;
80106336:	90                   	nop
}
80106337:	c9                   	leave  
80106338:	c3                   	ret    

80106339 <uartputc>:

void
uartputc(int c)
{
80106339:	55                   	push   %ebp
8010633a:	89 e5                	mov    %esp,%ebp
8010633c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010633f:	a1 78 6b 19 80       	mov    0x80196b78,%eax
80106344:	85 c0                	test   %eax,%eax
80106346:	74 53                	je     8010639b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010634f:	eb 11                	jmp    80106362 <uartputc+0x29>
    microdelay(10);
80106351:	83 ec 0c             	sub    $0xc,%esp
80106354:	6a 0a                	push   $0xa
80106356:	e8 dc c7 ff ff       	call   80102b37 <microdelay>
8010635b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010635e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106362:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106366:	7f 1a                	jg     80106382 <uartputc+0x49>
80106368:	83 ec 0c             	sub    $0xc,%esp
8010636b:	68 fd 03 00 00       	push   $0x3fd
80106370:	e8 9f fe ff ff       	call   80106214 <inb>
80106375:	83 c4 10             	add    $0x10,%esp
80106378:	0f b6 c0             	movzbl %al,%eax
8010637b:	83 e0 20             	and    $0x20,%eax
8010637e:	85 c0                	test   %eax,%eax
80106380:	74 cf                	je     80106351 <uartputc+0x18>
  outb(COM1+0, c);
80106382:	8b 45 08             	mov    0x8(%ebp),%eax
80106385:	0f b6 c0             	movzbl %al,%eax
80106388:	83 ec 08             	sub    $0x8,%esp
8010638b:	50                   	push   %eax
8010638c:	68 f8 03 00 00       	push   $0x3f8
80106391:	e8 9b fe ff ff       	call   80106231 <outb>
80106396:	83 c4 10             	add    $0x10,%esp
80106399:	eb 01                	jmp    8010639c <uartputc+0x63>
    return;
8010639b:	90                   	nop
}
8010639c:	c9                   	leave  
8010639d:	c3                   	ret    

8010639e <uartgetc>:

static int
uartgetc(void)
{
8010639e:	55                   	push   %ebp
8010639f:	89 e5                	mov    %esp,%ebp
  if(!uart)
801063a1:	a1 78 6b 19 80       	mov    0x80196b78,%eax
801063a6:	85 c0                	test   %eax,%eax
801063a8:	75 07                	jne    801063b1 <uartgetc+0x13>
    return -1;
801063aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063af:	eb 2e                	jmp    801063df <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801063b1:	68 fd 03 00 00       	push   $0x3fd
801063b6:	e8 59 fe ff ff       	call   80106214 <inb>
801063bb:	83 c4 04             	add    $0x4,%esp
801063be:	0f b6 c0             	movzbl %al,%eax
801063c1:	83 e0 01             	and    $0x1,%eax
801063c4:	85 c0                	test   %eax,%eax
801063c6:	75 07                	jne    801063cf <uartgetc+0x31>
    return -1;
801063c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cd:	eb 10                	jmp    801063df <uartgetc+0x41>
  return inb(COM1+0);
801063cf:	68 f8 03 00 00       	push   $0x3f8
801063d4:	e8 3b fe ff ff       	call   80106214 <inb>
801063d9:	83 c4 04             	add    $0x4,%esp
801063dc:	0f b6 c0             	movzbl %al,%eax
}
801063df:	c9                   	leave  
801063e0:	c3                   	ret    

801063e1 <uartintr>:

void
uartintr(void)
{
801063e1:	55                   	push   %ebp
801063e2:	89 e5                	mov    %esp,%ebp
801063e4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801063e7:	83 ec 0c             	sub    $0xc,%esp
801063ea:	68 9e 63 10 80       	push   $0x8010639e
801063ef:	e8 e2 a3 ff ff       	call   801007d6 <consoleintr>
801063f4:	83 c4 10             	add    $0x10,%esp
}
801063f7:	90                   	nop
801063f8:	c9                   	leave  
801063f9:	c3                   	ret    

801063fa <vector0>:
801063fa:	6a 00                	push   $0x0
801063fc:	6a 00                	push   $0x0
801063fe:	e9 6f f9 ff ff       	jmp    80105d72 <alltraps>

80106403 <vector1>:
80106403:	6a 00                	push   $0x0
80106405:	6a 01                	push   $0x1
80106407:	e9 66 f9 ff ff       	jmp    80105d72 <alltraps>

8010640c <vector2>:
8010640c:	6a 00                	push   $0x0
8010640e:	6a 02                	push   $0x2
80106410:	e9 5d f9 ff ff       	jmp    80105d72 <alltraps>

80106415 <vector3>:
80106415:	6a 00                	push   $0x0
80106417:	6a 03                	push   $0x3
80106419:	e9 54 f9 ff ff       	jmp    80105d72 <alltraps>

8010641e <vector4>:
8010641e:	6a 00                	push   $0x0
80106420:	6a 04                	push   $0x4
80106422:	e9 4b f9 ff ff       	jmp    80105d72 <alltraps>

80106427 <vector5>:
80106427:	6a 00                	push   $0x0
80106429:	6a 05                	push   $0x5
8010642b:	e9 42 f9 ff ff       	jmp    80105d72 <alltraps>

80106430 <vector6>:
80106430:	6a 00                	push   $0x0
80106432:	6a 06                	push   $0x6
80106434:	e9 39 f9 ff ff       	jmp    80105d72 <alltraps>

80106439 <vector7>:
80106439:	6a 00                	push   $0x0
8010643b:	6a 07                	push   $0x7
8010643d:	e9 30 f9 ff ff       	jmp    80105d72 <alltraps>

80106442 <vector8>:
80106442:	6a 08                	push   $0x8
80106444:	e9 29 f9 ff ff       	jmp    80105d72 <alltraps>

80106449 <vector9>:
80106449:	6a 00                	push   $0x0
8010644b:	6a 09                	push   $0x9
8010644d:	e9 20 f9 ff ff       	jmp    80105d72 <alltraps>

80106452 <vector10>:
80106452:	6a 0a                	push   $0xa
80106454:	e9 19 f9 ff ff       	jmp    80105d72 <alltraps>

80106459 <vector11>:
80106459:	6a 0b                	push   $0xb
8010645b:	e9 12 f9 ff ff       	jmp    80105d72 <alltraps>

80106460 <vector12>:
80106460:	6a 0c                	push   $0xc
80106462:	e9 0b f9 ff ff       	jmp    80105d72 <alltraps>

80106467 <vector13>:
80106467:	6a 0d                	push   $0xd
80106469:	e9 04 f9 ff ff       	jmp    80105d72 <alltraps>

8010646e <vector14>:
8010646e:	6a 0e                	push   $0xe
80106470:	e9 fd f8 ff ff       	jmp    80105d72 <alltraps>

80106475 <vector15>:
80106475:	6a 00                	push   $0x0
80106477:	6a 0f                	push   $0xf
80106479:	e9 f4 f8 ff ff       	jmp    80105d72 <alltraps>

8010647e <vector16>:
8010647e:	6a 00                	push   $0x0
80106480:	6a 10                	push   $0x10
80106482:	e9 eb f8 ff ff       	jmp    80105d72 <alltraps>

80106487 <vector17>:
80106487:	6a 11                	push   $0x11
80106489:	e9 e4 f8 ff ff       	jmp    80105d72 <alltraps>

8010648e <vector18>:
8010648e:	6a 00                	push   $0x0
80106490:	6a 12                	push   $0x12
80106492:	e9 db f8 ff ff       	jmp    80105d72 <alltraps>

80106497 <vector19>:
80106497:	6a 00                	push   $0x0
80106499:	6a 13                	push   $0x13
8010649b:	e9 d2 f8 ff ff       	jmp    80105d72 <alltraps>

801064a0 <vector20>:
801064a0:	6a 00                	push   $0x0
801064a2:	6a 14                	push   $0x14
801064a4:	e9 c9 f8 ff ff       	jmp    80105d72 <alltraps>

801064a9 <vector21>:
801064a9:	6a 00                	push   $0x0
801064ab:	6a 15                	push   $0x15
801064ad:	e9 c0 f8 ff ff       	jmp    80105d72 <alltraps>

801064b2 <vector22>:
801064b2:	6a 00                	push   $0x0
801064b4:	6a 16                	push   $0x16
801064b6:	e9 b7 f8 ff ff       	jmp    80105d72 <alltraps>

801064bb <vector23>:
801064bb:	6a 00                	push   $0x0
801064bd:	6a 17                	push   $0x17
801064bf:	e9 ae f8 ff ff       	jmp    80105d72 <alltraps>

801064c4 <vector24>:
801064c4:	6a 00                	push   $0x0
801064c6:	6a 18                	push   $0x18
801064c8:	e9 a5 f8 ff ff       	jmp    80105d72 <alltraps>

801064cd <vector25>:
801064cd:	6a 00                	push   $0x0
801064cf:	6a 19                	push   $0x19
801064d1:	e9 9c f8 ff ff       	jmp    80105d72 <alltraps>

801064d6 <vector26>:
801064d6:	6a 00                	push   $0x0
801064d8:	6a 1a                	push   $0x1a
801064da:	e9 93 f8 ff ff       	jmp    80105d72 <alltraps>

801064df <vector27>:
801064df:	6a 00                	push   $0x0
801064e1:	6a 1b                	push   $0x1b
801064e3:	e9 8a f8 ff ff       	jmp    80105d72 <alltraps>

801064e8 <vector28>:
801064e8:	6a 00                	push   $0x0
801064ea:	6a 1c                	push   $0x1c
801064ec:	e9 81 f8 ff ff       	jmp    80105d72 <alltraps>

801064f1 <vector29>:
801064f1:	6a 00                	push   $0x0
801064f3:	6a 1d                	push   $0x1d
801064f5:	e9 78 f8 ff ff       	jmp    80105d72 <alltraps>

801064fa <vector30>:
801064fa:	6a 00                	push   $0x0
801064fc:	6a 1e                	push   $0x1e
801064fe:	e9 6f f8 ff ff       	jmp    80105d72 <alltraps>

80106503 <vector31>:
80106503:	6a 00                	push   $0x0
80106505:	6a 1f                	push   $0x1f
80106507:	e9 66 f8 ff ff       	jmp    80105d72 <alltraps>

8010650c <vector32>:
8010650c:	6a 00                	push   $0x0
8010650e:	6a 20                	push   $0x20
80106510:	e9 5d f8 ff ff       	jmp    80105d72 <alltraps>

80106515 <vector33>:
80106515:	6a 00                	push   $0x0
80106517:	6a 21                	push   $0x21
80106519:	e9 54 f8 ff ff       	jmp    80105d72 <alltraps>

8010651e <vector34>:
8010651e:	6a 00                	push   $0x0
80106520:	6a 22                	push   $0x22
80106522:	e9 4b f8 ff ff       	jmp    80105d72 <alltraps>

80106527 <vector35>:
80106527:	6a 00                	push   $0x0
80106529:	6a 23                	push   $0x23
8010652b:	e9 42 f8 ff ff       	jmp    80105d72 <alltraps>

80106530 <vector36>:
80106530:	6a 00                	push   $0x0
80106532:	6a 24                	push   $0x24
80106534:	e9 39 f8 ff ff       	jmp    80105d72 <alltraps>

80106539 <vector37>:
80106539:	6a 00                	push   $0x0
8010653b:	6a 25                	push   $0x25
8010653d:	e9 30 f8 ff ff       	jmp    80105d72 <alltraps>

80106542 <vector38>:
80106542:	6a 00                	push   $0x0
80106544:	6a 26                	push   $0x26
80106546:	e9 27 f8 ff ff       	jmp    80105d72 <alltraps>

8010654b <vector39>:
8010654b:	6a 00                	push   $0x0
8010654d:	6a 27                	push   $0x27
8010654f:	e9 1e f8 ff ff       	jmp    80105d72 <alltraps>

80106554 <vector40>:
80106554:	6a 00                	push   $0x0
80106556:	6a 28                	push   $0x28
80106558:	e9 15 f8 ff ff       	jmp    80105d72 <alltraps>

8010655d <vector41>:
8010655d:	6a 00                	push   $0x0
8010655f:	6a 29                	push   $0x29
80106561:	e9 0c f8 ff ff       	jmp    80105d72 <alltraps>

80106566 <vector42>:
80106566:	6a 00                	push   $0x0
80106568:	6a 2a                	push   $0x2a
8010656a:	e9 03 f8 ff ff       	jmp    80105d72 <alltraps>

8010656f <vector43>:
8010656f:	6a 00                	push   $0x0
80106571:	6a 2b                	push   $0x2b
80106573:	e9 fa f7 ff ff       	jmp    80105d72 <alltraps>

80106578 <vector44>:
80106578:	6a 00                	push   $0x0
8010657a:	6a 2c                	push   $0x2c
8010657c:	e9 f1 f7 ff ff       	jmp    80105d72 <alltraps>

80106581 <vector45>:
80106581:	6a 00                	push   $0x0
80106583:	6a 2d                	push   $0x2d
80106585:	e9 e8 f7 ff ff       	jmp    80105d72 <alltraps>

8010658a <vector46>:
8010658a:	6a 00                	push   $0x0
8010658c:	6a 2e                	push   $0x2e
8010658e:	e9 df f7 ff ff       	jmp    80105d72 <alltraps>

80106593 <vector47>:
80106593:	6a 00                	push   $0x0
80106595:	6a 2f                	push   $0x2f
80106597:	e9 d6 f7 ff ff       	jmp    80105d72 <alltraps>

8010659c <vector48>:
8010659c:	6a 00                	push   $0x0
8010659e:	6a 30                	push   $0x30
801065a0:	e9 cd f7 ff ff       	jmp    80105d72 <alltraps>

801065a5 <vector49>:
801065a5:	6a 00                	push   $0x0
801065a7:	6a 31                	push   $0x31
801065a9:	e9 c4 f7 ff ff       	jmp    80105d72 <alltraps>

801065ae <vector50>:
801065ae:	6a 00                	push   $0x0
801065b0:	6a 32                	push   $0x32
801065b2:	e9 bb f7 ff ff       	jmp    80105d72 <alltraps>

801065b7 <vector51>:
801065b7:	6a 00                	push   $0x0
801065b9:	6a 33                	push   $0x33
801065bb:	e9 b2 f7 ff ff       	jmp    80105d72 <alltraps>

801065c0 <vector52>:
801065c0:	6a 00                	push   $0x0
801065c2:	6a 34                	push   $0x34
801065c4:	e9 a9 f7 ff ff       	jmp    80105d72 <alltraps>

801065c9 <vector53>:
801065c9:	6a 00                	push   $0x0
801065cb:	6a 35                	push   $0x35
801065cd:	e9 a0 f7 ff ff       	jmp    80105d72 <alltraps>

801065d2 <vector54>:
801065d2:	6a 00                	push   $0x0
801065d4:	6a 36                	push   $0x36
801065d6:	e9 97 f7 ff ff       	jmp    80105d72 <alltraps>

801065db <vector55>:
801065db:	6a 00                	push   $0x0
801065dd:	6a 37                	push   $0x37
801065df:	e9 8e f7 ff ff       	jmp    80105d72 <alltraps>

801065e4 <vector56>:
801065e4:	6a 00                	push   $0x0
801065e6:	6a 38                	push   $0x38
801065e8:	e9 85 f7 ff ff       	jmp    80105d72 <alltraps>

801065ed <vector57>:
801065ed:	6a 00                	push   $0x0
801065ef:	6a 39                	push   $0x39
801065f1:	e9 7c f7 ff ff       	jmp    80105d72 <alltraps>

801065f6 <vector58>:
801065f6:	6a 00                	push   $0x0
801065f8:	6a 3a                	push   $0x3a
801065fa:	e9 73 f7 ff ff       	jmp    80105d72 <alltraps>

801065ff <vector59>:
801065ff:	6a 00                	push   $0x0
80106601:	6a 3b                	push   $0x3b
80106603:	e9 6a f7 ff ff       	jmp    80105d72 <alltraps>

80106608 <vector60>:
80106608:	6a 00                	push   $0x0
8010660a:	6a 3c                	push   $0x3c
8010660c:	e9 61 f7 ff ff       	jmp    80105d72 <alltraps>

80106611 <vector61>:
80106611:	6a 00                	push   $0x0
80106613:	6a 3d                	push   $0x3d
80106615:	e9 58 f7 ff ff       	jmp    80105d72 <alltraps>

8010661a <vector62>:
8010661a:	6a 00                	push   $0x0
8010661c:	6a 3e                	push   $0x3e
8010661e:	e9 4f f7 ff ff       	jmp    80105d72 <alltraps>

80106623 <vector63>:
80106623:	6a 00                	push   $0x0
80106625:	6a 3f                	push   $0x3f
80106627:	e9 46 f7 ff ff       	jmp    80105d72 <alltraps>

8010662c <vector64>:
8010662c:	6a 00                	push   $0x0
8010662e:	6a 40                	push   $0x40
80106630:	e9 3d f7 ff ff       	jmp    80105d72 <alltraps>

80106635 <vector65>:
80106635:	6a 00                	push   $0x0
80106637:	6a 41                	push   $0x41
80106639:	e9 34 f7 ff ff       	jmp    80105d72 <alltraps>

8010663e <vector66>:
8010663e:	6a 00                	push   $0x0
80106640:	6a 42                	push   $0x42
80106642:	e9 2b f7 ff ff       	jmp    80105d72 <alltraps>

80106647 <vector67>:
80106647:	6a 00                	push   $0x0
80106649:	6a 43                	push   $0x43
8010664b:	e9 22 f7 ff ff       	jmp    80105d72 <alltraps>

80106650 <vector68>:
80106650:	6a 00                	push   $0x0
80106652:	6a 44                	push   $0x44
80106654:	e9 19 f7 ff ff       	jmp    80105d72 <alltraps>

80106659 <vector69>:
80106659:	6a 00                	push   $0x0
8010665b:	6a 45                	push   $0x45
8010665d:	e9 10 f7 ff ff       	jmp    80105d72 <alltraps>

80106662 <vector70>:
80106662:	6a 00                	push   $0x0
80106664:	6a 46                	push   $0x46
80106666:	e9 07 f7 ff ff       	jmp    80105d72 <alltraps>

8010666b <vector71>:
8010666b:	6a 00                	push   $0x0
8010666d:	6a 47                	push   $0x47
8010666f:	e9 fe f6 ff ff       	jmp    80105d72 <alltraps>

80106674 <vector72>:
80106674:	6a 00                	push   $0x0
80106676:	6a 48                	push   $0x48
80106678:	e9 f5 f6 ff ff       	jmp    80105d72 <alltraps>

8010667d <vector73>:
8010667d:	6a 00                	push   $0x0
8010667f:	6a 49                	push   $0x49
80106681:	e9 ec f6 ff ff       	jmp    80105d72 <alltraps>

80106686 <vector74>:
80106686:	6a 00                	push   $0x0
80106688:	6a 4a                	push   $0x4a
8010668a:	e9 e3 f6 ff ff       	jmp    80105d72 <alltraps>

8010668f <vector75>:
8010668f:	6a 00                	push   $0x0
80106691:	6a 4b                	push   $0x4b
80106693:	e9 da f6 ff ff       	jmp    80105d72 <alltraps>

80106698 <vector76>:
80106698:	6a 00                	push   $0x0
8010669a:	6a 4c                	push   $0x4c
8010669c:	e9 d1 f6 ff ff       	jmp    80105d72 <alltraps>

801066a1 <vector77>:
801066a1:	6a 00                	push   $0x0
801066a3:	6a 4d                	push   $0x4d
801066a5:	e9 c8 f6 ff ff       	jmp    80105d72 <alltraps>

801066aa <vector78>:
801066aa:	6a 00                	push   $0x0
801066ac:	6a 4e                	push   $0x4e
801066ae:	e9 bf f6 ff ff       	jmp    80105d72 <alltraps>

801066b3 <vector79>:
801066b3:	6a 00                	push   $0x0
801066b5:	6a 4f                	push   $0x4f
801066b7:	e9 b6 f6 ff ff       	jmp    80105d72 <alltraps>

801066bc <vector80>:
801066bc:	6a 00                	push   $0x0
801066be:	6a 50                	push   $0x50
801066c0:	e9 ad f6 ff ff       	jmp    80105d72 <alltraps>

801066c5 <vector81>:
801066c5:	6a 00                	push   $0x0
801066c7:	6a 51                	push   $0x51
801066c9:	e9 a4 f6 ff ff       	jmp    80105d72 <alltraps>

801066ce <vector82>:
801066ce:	6a 00                	push   $0x0
801066d0:	6a 52                	push   $0x52
801066d2:	e9 9b f6 ff ff       	jmp    80105d72 <alltraps>

801066d7 <vector83>:
801066d7:	6a 00                	push   $0x0
801066d9:	6a 53                	push   $0x53
801066db:	e9 92 f6 ff ff       	jmp    80105d72 <alltraps>

801066e0 <vector84>:
801066e0:	6a 00                	push   $0x0
801066e2:	6a 54                	push   $0x54
801066e4:	e9 89 f6 ff ff       	jmp    80105d72 <alltraps>

801066e9 <vector85>:
801066e9:	6a 00                	push   $0x0
801066eb:	6a 55                	push   $0x55
801066ed:	e9 80 f6 ff ff       	jmp    80105d72 <alltraps>

801066f2 <vector86>:
801066f2:	6a 00                	push   $0x0
801066f4:	6a 56                	push   $0x56
801066f6:	e9 77 f6 ff ff       	jmp    80105d72 <alltraps>

801066fb <vector87>:
801066fb:	6a 00                	push   $0x0
801066fd:	6a 57                	push   $0x57
801066ff:	e9 6e f6 ff ff       	jmp    80105d72 <alltraps>

80106704 <vector88>:
80106704:	6a 00                	push   $0x0
80106706:	6a 58                	push   $0x58
80106708:	e9 65 f6 ff ff       	jmp    80105d72 <alltraps>

8010670d <vector89>:
8010670d:	6a 00                	push   $0x0
8010670f:	6a 59                	push   $0x59
80106711:	e9 5c f6 ff ff       	jmp    80105d72 <alltraps>

80106716 <vector90>:
80106716:	6a 00                	push   $0x0
80106718:	6a 5a                	push   $0x5a
8010671a:	e9 53 f6 ff ff       	jmp    80105d72 <alltraps>

8010671f <vector91>:
8010671f:	6a 00                	push   $0x0
80106721:	6a 5b                	push   $0x5b
80106723:	e9 4a f6 ff ff       	jmp    80105d72 <alltraps>

80106728 <vector92>:
80106728:	6a 00                	push   $0x0
8010672a:	6a 5c                	push   $0x5c
8010672c:	e9 41 f6 ff ff       	jmp    80105d72 <alltraps>

80106731 <vector93>:
80106731:	6a 00                	push   $0x0
80106733:	6a 5d                	push   $0x5d
80106735:	e9 38 f6 ff ff       	jmp    80105d72 <alltraps>

8010673a <vector94>:
8010673a:	6a 00                	push   $0x0
8010673c:	6a 5e                	push   $0x5e
8010673e:	e9 2f f6 ff ff       	jmp    80105d72 <alltraps>

80106743 <vector95>:
80106743:	6a 00                	push   $0x0
80106745:	6a 5f                	push   $0x5f
80106747:	e9 26 f6 ff ff       	jmp    80105d72 <alltraps>

8010674c <vector96>:
8010674c:	6a 00                	push   $0x0
8010674e:	6a 60                	push   $0x60
80106750:	e9 1d f6 ff ff       	jmp    80105d72 <alltraps>

80106755 <vector97>:
80106755:	6a 00                	push   $0x0
80106757:	6a 61                	push   $0x61
80106759:	e9 14 f6 ff ff       	jmp    80105d72 <alltraps>

8010675e <vector98>:
8010675e:	6a 00                	push   $0x0
80106760:	6a 62                	push   $0x62
80106762:	e9 0b f6 ff ff       	jmp    80105d72 <alltraps>

80106767 <vector99>:
80106767:	6a 00                	push   $0x0
80106769:	6a 63                	push   $0x63
8010676b:	e9 02 f6 ff ff       	jmp    80105d72 <alltraps>

80106770 <vector100>:
80106770:	6a 00                	push   $0x0
80106772:	6a 64                	push   $0x64
80106774:	e9 f9 f5 ff ff       	jmp    80105d72 <alltraps>

80106779 <vector101>:
80106779:	6a 00                	push   $0x0
8010677b:	6a 65                	push   $0x65
8010677d:	e9 f0 f5 ff ff       	jmp    80105d72 <alltraps>

80106782 <vector102>:
80106782:	6a 00                	push   $0x0
80106784:	6a 66                	push   $0x66
80106786:	e9 e7 f5 ff ff       	jmp    80105d72 <alltraps>

8010678b <vector103>:
8010678b:	6a 00                	push   $0x0
8010678d:	6a 67                	push   $0x67
8010678f:	e9 de f5 ff ff       	jmp    80105d72 <alltraps>

80106794 <vector104>:
80106794:	6a 00                	push   $0x0
80106796:	6a 68                	push   $0x68
80106798:	e9 d5 f5 ff ff       	jmp    80105d72 <alltraps>

8010679d <vector105>:
8010679d:	6a 00                	push   $0x0
8010679f:	6a 69                	push   $0x69
801067a1:	e9 cc f5 ff ff       	jmp    80105d72 <alltraps>

801067a6 <vector106>:
801067a6:	6a 00                	push   $0x0
801067a8:	6a 6a                	push   $0x6a
801067aa:	e9 c3 f5 ff ff       	jmp    80105d72 <alltraps>

801067af <vector107>:
801067af:	6a 00                	push   $0x0
801067b1:	6a 6b                	push   $0x6b
801067b3:	e9 ba f5 ff ff       	jmp    80105d72 <alltraps>

801067b8 <vector108>:
801067b8:	6a 00                	push   $0x0
801067ba:	6a 6c                	push   $0x6c
801067bc:	e9 b1 f5 ff ff       	jmp    80105d72 <alltraps>

801067c1 <vector109>:
801067c1:	6a 00                	push   $0x0
801067c3:	6a 6d                	push   $0x6d
801067c5:	e9 a8 f5 ff ff       	jmp    80105d72 <alltraps>

801067ca <vector110>:
801067ca:	6a 00                	push   $0x0
801067cc:	6a 6e                	push   $0x6e
801067ce:	e9 9f f5 ff ff       	jmp    80105d72 <alltraps>

801067d3 <vector111>:
801067d3:	6a 00                	push   $0x0
801067d5:	6a 6f                	push   $0x6f
801067d7:	e9 96 f5 ff ff       	jmp    80105d72 <alltraps>

801067dc <vector112>:
801067dc:	6a 00                	push   $0x0
801067de:	6a 70                	push   $0x70
801067e0:	e9 8d f5 ff ff       	jmp    80105d72 <alltraps>

801067e5 <vector113>:
801067e5:	6a 00                	push   $0x0
801067e7:	6a 71                	push   $0x71
801067e9:	e9 84 f5 ff ff       	jmp    80105d72 <alltraps>

801067ee <vector114>:
801067ee:	6a 00                	push   $0x0
801067f0:	6a 72                	push   $0x72
801067f2:	e9 7b f5 ff ff       	jmp    80105d72 <alltraps>

801067f7 <vector115>:
801067f7:	6a 00                	push   $0x0
801067f9:	6a 73                	push   $0x73
801067fb:	e9 72 f5 ff ff       	jmp    80105d72 <alltraps>

80106800 <vector116>:
80106800:	6a 00                	push   $0x0
80106802:	6a 74                	push   $0x74
80106804:	e9 69 f5 ff ff       	jmp    80105d72 <alltraps>

80106809 <vector117>:
80106809:	6a 00                	push   $0x0
8010680b:	6a 75                	push   $0x75
8010680d:	e9 60 f5 ff ff       	jmp    80105d72 <alltraps>

80106812 <vector118>:
80106812:	6a 00                	push   $0x0
80106814:	6a 76                	push   $0x76
80106816:	e9 57 f5 ff ff       	jmp    80105d72 <alltraps>

8010681b <vector119>:
8010681b:	6a 00                	push   $0x0
8010681d:	6a 77                	push   $0x77
8010681f:	e9 4e f5 ff ff       	jmp    80105d72 <alltraps>

80106824 <vector120>:
80106824:	6a 00                	push   $0x0
80106826:	6a 78                	push   $0x78
80106828:	e9 45 f5 ff ff       	jmp    80105d72 <alltraps>

8010682d <vector121>:
8010682d:	6a 00                	push   $0x0
8010682f:	6a 79                	push   $0x79
80106831:	e9 3c f5 ff ff       	jmp    80105d72 <alltraps>

80106836 <vector122>:
80106836:	6a 00                	push   $0x0
80106838:	6a 7a                	push   $0x7a
8010683a:	e9 33 f5 ff ff       	jmp    80105d72 <alltraps>

8010683f <vector123>:
8010683f:	6a 00                	push   $0x0
80106841:	6a 7b                	push   $0x7b
80106843:	e9 2a f5 ff ff       	jmp    80105d72 <alltraps>

80106848 <vector124>:
80106848:	6a 00                	push   $0x0
8010684a:	6a 7c                	push   $0x7c
8010684c:	e9 21 f5 ff ff       	jmp    80105d72 <alltraps>

80106851 <vector125>:
80106851:	6a 00                	push   $0x0
80106853:	6a 7d                	push   $0x7d
80106855:	e9 18 f5 ff ff       	jmp    80105d72 <alltraps>

8010685a <vector126>:
8010685a:	6a 00                	push   $0x0
8010685c:	6a 7e                	push   $0x7e
8010685e:	e9 0f f5 ff ff       	jmp    80105d72 <alltraps>

80106863 <vector127>:
80106863:	6a 00                	push   $0x0
80106865:	6a 7f                	push   $0x7f
80106867:	e9 06 f5 ff ff       	jmp    80105d72 <alltraps>

8010686c <vector128>:
8010686c:	6a 00                	push   $0x0
8010686e:	68 80 00 00 00       	push   $0x80
80106873:	e9 fa f4 ff ff       	jmp    80105d72 <alltraps>

80106878 <vector129>:
80106878:	6a 00                	push   $0x0
8010687a:	68 81 00 00 00       	push   $0x81
8010687f:	e9 ee f4 ff ff       	jmp    80105d72 <alltraps>

80106884 <vector130>:
80106884:	6a 00                	push   $0x0
80106886:	68 82 00 00 00       	push   $0x82
8010688b:	e9 e2 f4 ff ff       	jmp    80105d72 <alltraps>

80106890 <vector131>:
80106890:	6a 00                	push   $0x0
80106892:	68 83 00 00 00       	push   $0x83
80106897:	e9 d6 f4 ff ff       	jmp    80105d72 <alltraps>

8010689c <vector132>:
8010689c:	6a 00                	push   $0x0
8010689e:	68 84 00 00 00       	push   $0x84
801068a3:	e9 ca f4 ff ff       	jmp    80105d72 <alltraps>

801068a8 <vector133>:
801068a8:	6a 00                	push   $0x0
801068aa:	68 85 00 00 00       	push   $0x85
801068af:	e9 be f4 ff ff       	jmp    80105d72 <alltraps>

801068b4 <vector134>:
801068b4:	6a 00                	push   $0x0
801068b6:	68 86 00 00 00       	push   $0x86
801068bb:	e9 b2 f4 ff ff       	jmp    80105d72 <alltraps>

801068c0 <vector135>:
801068c0:	6a 00                	push   $0x0
801068c2:	68 87 00 00 00       	push   $0x87
801068c7:	e9 a6 f4 ff ff       	jmp    80105d72 <alltraps>

801068cc <vector136>:
801068cc:	6a 00                	push   $0x0
801068ce:	68 88 00 00 00       	push   $0x88
801068d3:	e9 9a f4 ff ff       	jmp    80105d72 <alltraps>

801068d8 <vector137>:
801068d8:	6a 00                	push   $0x0
801068da:	68 89 00 00 00       	push   $0x89
801068df:	e9 8e f4 ff ff       	jmp    80105d72 <alltraps>

801068e4 <vector138>:
801068e4:	6a 00                	push   $0x0
801068e6:	68 8a 00 00 00       	push   $0x8a
801068eb:	e9 82 f4 ff ff       	jmp    80105d72 <alltraps>

801068f0 <vector139>:
801068f0:	6a 00                	push   $0x0
801068f2:	68 8b 00 00 00       	push   $0x8b
801068f7:	e9 76 f4 ff ff       	jmp    80105d72 <alltraps>

801068fc <vector140>:
801068fc:	6a 00                	push   $0x0
801068fe:	68 8c 00 00 00       	push   $0x8c
80106903:	e9 6a f4 ff ff       	jmp    80105d72 <alltraps>

80106908 <vector141>:
80106908:	6a 00                	push   $0x0
8010690a:	68 8d 00 00 00       	push   $0x8d
8010690f:	e9 5e f4 ff ff       	jmp    80105d72 <alltraps>

80106914 <vector142>:
80106914:	6a 00                	push   $0x0
80106916:	68 8e 00 00 00       	push   $0x8e
8010691b:	e9 52 f4 ff ff       	jmp    80105d72 <alltraps>

80106920 <vector143>:
80106920:	6a 00                	push   $0x0
80106922:	68 8f 00 00 00       	push   $0x8f
80106927:	e9 46 f4 ff ff       	jmp    80105d72 <alltraps>

8010692c <vector144>:
8010692c:	6a 00                	push   $0x0
8010692e:	68 90 00 00 00       	push   $0x90
80106933:	e9 3a f4 ff ff       	jmp    80105d72 <alltraps>

80106938 <vector145>:
80106938:	6a 00                	push   $0x0
8010693a:	68 91 00 00 00       	push   $0x91
8010693f:	e9 2e f4 ff ff       	jmp    80105d72 <alltraps>

80106944 <vector146>:
80106944:	6a 00                	push   $0x0
80106946:	68 92 00 00 00       	push   $0x92
8010694b:	e9 22 f4 ff ff       	jmp    80105d72 <alltraps>

80106950 <vector147>:
80106950:	6a 00                	push   $0x0
80106952:	68 93 00 00 00       	push   $0x93
80106957:	e9 16 f4 ff ff       	jmp    80105d72 <alltraps>

8010695c <vector148>:
8010695c:	6a 00                	push   $0x0
8010695e:	68 94 00 00 00       	push   $0x94
80106963:	e9 0a f4 ff ff       	jmp    80105d72 <alltraps>

80106968 <vector149>:
80106968:	6a 00                	push   $0x0
8010696a:	68 95 00 00 00       	push   $0x95
8010696f:	e9 fe f3 ff ff       	jmp    80105d72 <alltraps>

80106974 <vector150>:
80106974:	6a 00                	push   $0x0
80106976:	68 96 00 00 00       	push   $0x96
8010697b:	e9 f2 f3 ff ff       	jmp    80105d72 <alltraps>

80106980 <vector151>:
80106980:	6a 00                	push   $0x0
80106982:	68 97 00 00 00       	push   $0x97
80106987:	e9 e6 f3 ff ff       	jmp    80105d72 <alltraps>

8010698c <vector152>:
8010698c:	6a 00                	push   $0x0
8010698e:	68 98 00 00 00       	push   $0x98
80106993:	e9 da f3 ff ff       	jmp    80105d72 <alltraps>

80106998 <vector153>:
80106998:	6a 00                	push   $0x0
8010699a:	68 99 00 00 00       	push   $0x99
8010699f:	e9 ce f3 ff ff       	jmp    80105d72 <alltraps>

801069a4 <vector154>:
801069a4:	6a 00                	push   $0x0
801069a6:	68 9a 00 00 00       	push   $0x9a
801069ab:	e9 c2 f3 ff ff       	jmp    80105d72 <alltraps>

801069b0 <vector155>:
801069b0:	6a 00                	push   $0x0
801069b2:	68 9b 00 00 00       	push   $0x9b
801069b7:	e9 b6 f3 ff ff       	jmp    80105d72 <alltraps>

801069bc <vector156>:
801069bc:	6a 00                	push   $0x0
801069be:	68 9c 00 00 00       	push   $0x9c
801069c3:	e9 aa f3 ff ff       	jmp    80105d72 <alltraps>

801069c8 <vector157>:
801069c8:	6a 00                	push   $0x0
801069ca:	68 9d 00 00 00       	push   $0x9d
801069cf:	e9 9e f3 ff ff       	jmp    80105d72 <alltraps>

801069d4 <vector158>:
801069d4:	6a 00                	push   $0x0
801069d6:	68 9e 00 00 00       	push   $0x9e
801069db:	e9 92 f3 ff ff       	jmp    80105d72 <alltraps>

801069e0 <vector159>:
801069e0:	6a 00                	push   $0x0
801069e2:	68 9f 00 00 00       	push   $0x9f
801069e7:	e9 86 f3 ff ff       	jmp    80105d72 <alltraps>

801069ec <vector160>:
801069ec:	6a 00                	push   $0x0
801069ee:	68 a0 00 00 00       	push   $0xa0
801069f3:	e9 7a f3 ff ff       	jmp    80105d72 <alltraps>

801069f8 <vector161>:
801069f8:	6a 00                	push   $0x0
801069fa:	68 a1 00 00 00       	push   $0xa1
801069ff:	e9 6e f3 ff ff       	jmp    80105d72 <alltraps>

80106a04 <vector162>:
80106a04:	6a 00                	push   $0x0
80106a06:	68 a2 00 00 00       	push   $0xa2
80106a0b:	e9 62 f3 ff ff       	jmp    80105d72 <alltraps>

80106a10 <vector163>:
80106a10:	6a 00                	push   $0x0
80106a12:	68 a3 00 00 00       	push   $0xa3
80106a17:	e9 56 f3 ff ff       	jmp    80105d72 <alltraps>

80106a1c <vector164>:
80106a1c:	6a 00                	push   $0x0
80106a1e:	68 a4 00 00 00       	push   $0xa4
80106a23:	e9 4a f3 ff ff       	jmp    80105d72 <alltraps>

80106a28 <vector165>:
80106a28:	6a 00                	push   $0x0
80106a2a:	68 a5 00 00 00       	push   $0xa5
80106a2f:	e9 3e f3 ff ff       	jmp    80105d72 <alltraps>

80106a34 <vector166>:
80106a34:	6a 00                	push   $0x0
80106a36:	68 a6 00 00 00       	push   $0xa6
80106a3b:	e9 32 f3 ff ff       	jmp    80105d72 <alltraps>

80106a40 <vector167>:
80106a40:	6a 00                	push   $0x0
80106a42:	68 a7 00 00 00       	push   $0xa7
80106a47:	e9 26 f3 ff ff       	jmp    80105d72 <alltraps>

80106a4c <vector168>:
80106a4c:	6a 00                	push   $0x0
80106a4e:	68 a8 00 00 00       	push   $0xa8
80106a53:	e9 1a f3 ff ff       	jmp    80105d72 <alltraps>

80106a58 <vector169>:
80106a58:	6a 00                	push   $0x0
80106a5a:	68 a9 00 00 00       	push   $0xa9
80106a5f:	e9 0e f3 ff ff       	jmp    80105d72 <alltraps>

80106a64 <vector170>:
80106a64:	6a 00                	push   $0x0
80106a66:	68 aa 00 00 00       	push   $0xaa
80106a6b:	e9 02 f3 ff ff       	jmp    80105d72 <alltraps>

80106a70 <vector171>:
80106a70:	6a 00                	push   $0x0
80106a72:	68 ab 00 00 00       	push   $0xab
80106a77:	e9 f6 f2 ff ff       	jmp    80105d72 <alltraps>

80106a7c <vector172>:
80106a7c:	6a 00                	push   $0x0
80106a7e:	68 ac 00 00 00       	push   $0xac
80106a83:	e9 ea f2 ff ff       	jmp    80105d72 <alltraps>

80106a88 <vector173>:
80106a88:	6a 00                	push   $0x0
80106a8a:	68 ad 00 00 00       	push   $0xad
80106a8f:	e9 de f2 ff ff       	jmp    80105d72 <alltraps>

80106a94 <vector174>:
80106a94:	6a 00                	push   $0x0
80106a96:	68 ae 00 00 00       	push   $0xae
80106a9b:	e9 d2 f2 ff ff       	jmp    80105d72 <alltraps>

80106aa0 <vector175>:
80106aa0:	6a 00                	push   $0x0
80106aa2:	68 af 00 00 00       	push   $0xaf
80106aa7:	e9 c6 f2 ff ff       	jmp    80105d72 <alltraps>

80106aac <vector176>:
80106aac:	6a 00                	push   $0x0
80106aae:	68 b0 00 00 00       	push   $0xb0
80106ab3:	e9 ba f2 ff ff       	jmp    80105d72 <alltraps>

80106ab8 <vector177>:
80106ab8:	6a 00                	push   $0x0
80106aba:	68 b1 00 00 00       	push   $0xb1
80106abf:	e9 ae f2 ff ff       	jmp    80105d72 <alltraps>

80106ac4 <vector178>:
80106ac4:	6a 00                	push   $0x0
80106ac6:	68 b2 00 00 00       	push   $0xb2
80106acb:	e9 a2 f2 ff ff       	jmp    80105d72 <alltraps>

80106ad0 <vector179>:
80106ad0:	6a 00                	push   $0x0
80106ad2:	68 b3 00 00 00       	push   $0xb3
80106ad7:	e9 96 f2 ff ff       	jmp    80105d72 <alltraps>

80106adc <vector180>:
80106adc:	6a 00                	push   $0x0
80106ade:	68 b4 00 00 00       	push   $0xb4
80106ae3:	e9 8a f2 ff ff       	jmp    80105d72 <alltraps>

80106ae8 <vector181>:
80106ae8:	6a 00                	push   $0x0
80106aea:	68 b5 00 00 00       	push   $0xb5
80106aef:	e9 7e f2 ff ff       	jmp    80105d72 <alltraps>

80106af4 <vector182>:
80106af4:	6a 00                	push   $0x0
80106af6:	68 b6 00 00 00       	push   $0xb6
80106afb:	e9 72 f2 ff ff       	jmp    80105d72 <alltraps>

80106b00 <vector183>:
80106b00:	6a 00                	push   $0x0
80106b02:	68 b7 00 00 00       	push   $0xb7
80106b07:	e9 66 f2 ff ff       	jmp    80105d72 <alltraps>

80106b0c <vector184>:
80106b0c:	6a 00                	push   $0x0
80106b0e:	68 b8 00 00 00       	push   $0xb8
80106b13:	e9 5a f2 ff ff       	jmp    80105d72 <alltraps>

80106b18 <vector185>:
80106b18:	6a 00                	push   $0x0
80106b1a:	68 b9 00 00 00       	push   $0xb9
80106b1f:	e9 4e f2 ff ff       	jmp    80105d72 <alltraps>

80106b24 <vector186>:
80106b24:	6a 00                	push   $0x0
80106b26:	68 ba 00 00 00       	push   $0xba
80106b2b:	e9 42 f2 ff ff       	jmp    80105d72 <alltraps>

80106b30 <vector187>:
80106b30:	6a 00                	push   $0x0
80106b32:	68 bb 00 00 00       	push   $0xbb
80106b37:	e9 36 f2 ff ff       	jmp    80105d72 <alltraps>

80106b3c <vector188>:
80106b3c:	6a 00                	push   $0x0
80106b3e:	68 bc 00 00 00       	push   $0xbc
80106b43:	e9 2a f2 ff ff       	jmp    80105d72 <alltraps>

80106b48 <vector189>:
80106b48:	6a 00                	push   $0x0
80106b4a:	68 bd 00 00 00       	push   $0xbd
80106b4f:	e9 1e f2 ff ff       	jmp    80105d72 <alltraps>

80106b54 <vector190>:
80106b54:	6a 00                	push   $0x0
80106b56:	68 be 00 00 00       	push   $0xbe
80106b5b:	e9 12 f2 ff ff       	jmp    80105d72 <alltraps>

80106b60 <vector191>:
80106b60:	6a 00                	push   $0x0
80106b62:	68 bf 00 00 00       	push   $0xbf
80106b67:	e9 06 f2 ff ff       	jmp    80105d72 <alltraps>

80106b6c <vector192>:
80106b6c:	6a 00                	push   $0x0
80106b6e:	68 c0 00 00 00       	push   $0xc0
80106b73:	e9 fa f1 ff ff       	jmp    80105d72 <alltraps>

80106b78 <vector193>:
80106b78:	6a 00                	push   $0x0
80106b7a:	68 c1 00 00 00       	push   $0xc1
80106b7f:	e9 ee f1 ff ff       	jmp    80105d72 <alltraps>

80106b84 <vector194>:
80106b84:	6a 00                	push   $0x0
80106b86:	68 c2 00 00 00       	push   $0xc2
80106b8b:	e9 e2 f1 ff ff       	jmp    80105d72 <alltraps>

80106b90 <vector195>:
80106b90:	6a 00                	push   $0x0
80106b92:	68 c3 00 00 00       	push   $0xc3
80106b97:	e9 d6 f1 ff ff       	jmp    80105d72 <alltraps>

80106b9c <vector196>:
80106b9c:	6a 00                	push   $0x0
80106b9e:	68 c4 00 00 00       	push   $0xc4
80106ba3:	e9 ca f1 ff ff       	jmp    80105d72 <alltraps>

80106ba8 <vector197>:
80106ba8:	6a 00                	push   $0x0
80106baa:	68 c5 00 00 00       	push   $0xc5
80106baf:	e9 be f1 ff ff       	jmp    80105d72 <alltraps>

80106bb4 <vector198>:
80106bb4:	6a 00                	push   $0x0
80106bb6:	68 c6 00 00 00       	push   $0xc6
80106bbb:	e9 b2 f1 ff ff       	jmp    80105d72 <alltraps>

80106bc0 <vector199>:
80106bc0:	6a 00                	push   $0x0
80106bc2:	68 c7 00 00 00       	push   $0xc7
80106bc7:	e9 a6 f1 ff ff       	jmp    80105d72 <alltraps>

80106bcc <vector200>:
80106bcc:	6a 00                	push   $0x0
80106bce:	68 c8 00 00 00       	push   $0xc8
80106bd3:	e9 9a f1 ff ff       	jmp    80105d72 <alltraps>

80106bd8 <vector201>:
80106bd8:	6a 00                	push   $0x0
80106bda:	68 c9 00 00 00       	push   $0xc9
80106bdf:	e9 8e f1 ff ff       	jmp    80105d72 <alltraps>

80106be4 <vector202>:
80106be4:	6a 00                	push   $0x0
80106be6:	68 ca 00 00 00       	push   $0xca
80106beb:	e9 82 f1 ff ff       	jmp    80105d72 <alltraps>

80106bf0 <vector203>:
80106bf0:	6a 00                	push   $0x0
80106bf2:	68 cb 00 00 00       	push   $0xcb
80106bf7:	e9 76 f1 ff ff       	jmp    80105d72 <alltraps>

80106bfc <vector204>:
80106bfc:	6a 00                	push   $0x0
80106bfe:	68 cc 00 00 00       	push   $0xcc
80106c03:	e9 6a f1 ff ff       	jmp    80105d72 <alltraps>

80106c08 <vector205>:
80106c08:	6a 00                	push   $0x0
80106c0a:	68 cd 00 00 00       	push   $0xcd
80106c0f:	e9 5e f1 ff ff       	jmp    80105d72 <alltraps>

80106c14 <vector206>:
80106c14:	6a 00                	push   $0x0
80106c16:	68 ce 00 00 00       	push   $0xce
80106c1b:	e9 52 f1 ff ff       	jmp    80105d72 <alltraps>

80106c20 <vector207>:
80106c20:	6a 00                	push   $0x0
80106c22:	68 cf 00 00 00       	push   $0xcf
80106c27:	e9 46 f1 ff ff       	jmp    80105d72 <alltraps>

80106c2c <vector208>:
80106c2c:	6a 00                	push   $0x0
80106c2e:	68 d0 00 00 00       	push   $0xd0
80106c33:	e9 3a f1 ff ff       	jmp    80105d72 <alltraps>

80106c38 <vector209>:
80106c38:	6a 00                	push   $0x0
80106c3a:	68 d1 00 00 00       	push   $0xd1
80106c3f:	e9 2e f1 ff ff       	jmp    80105d72 <alltraps>

80106c44 <vector210>:
80106c44:	6a 00                	push   $0x0
80106c46:	68 d2 00 00 00       	push   $0xd2
80106c4b:	e9 22 f1 ff ff       	jmp    80105d72 <alltraps>

80106c50 <vector211>:
80106c50:	6a 00                	push   $0x0
80106c52:	68 d3 00 00 00       	push   $0xd3
80106c57:	e9 16 f1 ff ff       	jmp    80105d72 <alltraps>

80106c5c <vector212>:
80106c5c:	6a 00                	push   $0x0
80106c5e:	68 d4 00 00 00       	push   $0xd4
80106c63:	e9 0a f1 ff ff       	jmp    80105d72 <alltraps>

80106c68 <vector213>:
80106c68:	6a 00                	push   $0x0
80106c6a:	68 d5 00 00 00       	push   $0xd5
80106c6f:	e9 fe f0 ff ff       	jmp    80105d72 <alltraps>

80106c74 <vector214>:
80106c74:	6a 00                	push   $0x0
80106c76:	68 d6 00 00 00       	push   $0xd6
80106c7b:	e9 f2 f0 ff ff       	jmp    80105d72 <alltraps>

80106c80 <vector215>:
80106c80:	6a 00                	push   $0x0
80106c82:	68 d7 00 00 00       	push   $0xd7
80106c87:	e9 e6 f0 ff ff       	jmp    80105d72 <alltraps>

80106c8c <vector216>:
80106c8c:	6a 00                	push   $0x0
80106c8e:	68 d8 00 00 00       	push   $0xd8
80106c93:	e9 da f0 ff ff       	jmp    80105d72 <alltraps>

80106c98 <vector217>:
80106c98:	6a 00                	push   $0x0
80106c9a:	68 d9 00 00 00       	push   $0xd9
80106c9f:	e9 ce f0 ff ff       	jmp    80105d72 <alltraps>

80106ca4 <vector218>:
80106ca4:	6a 00                	push   $0x0
80106ca6:	68 da 00 00 00       	push   $0xda
80106cab:	e9 c2 f0 ff ff       	jmp    80105d72 <alltraps>

80106cb0 <vector219>:
80106cb0:	6a 00                	push   $0x0
80106cb2:	68 db 00 00 00       	push   $0xdb
80106cb7:	e9 b6 f0 ff ff       	jmp    80105d72 <alltraps>

80106cbc <vector220>:
80106cbc:	6a 00                	push   $0x0
80106cbe:	68 dc 00 00 00       	push   $0xdc
80106cc3:	e9 aa f0 ff ff       	jmp    80105d72 <alltraps>

80106cc8 <vector221>:
80106cc8:	6a 00                	push   $0x0
80106cca:	68 dd 00 00 00       	push   $0xdd
80106ccf:	e9 9e f0 ff ff       	jmp    80105d72 <alltraps>

80106cd4 <vector222>:
80106cd4:	6a 00                	push   $0x0
80106cd6:	68 de 00 00 00       	push   $0xde
80106cdb:	e9 92 f0 ff ff       	jmp    80105d72 <alltraps>

80106ce0 <vector223>:
80106ce0:	6a 00                	push   $0x0
80106ce2:	68 df 00 00 00       	push   $0xdf
80106ce7:	e9 86 f0 ff ff       	jmp    80105d72 <alltraps>

80106cec <vector224>:
80106cec:	6a 00                	push   $0x0
80106cee:	68 e0 00 00 00       	push   $0xe0
80106cf3:	e9 7a f0 ff ff       	jmp    80105d72 <alltraps>

80106cf8 <vector225>:
80106cf8:	6a 00                	push   $0x0
80106cfa:	68 e1 00 00 00       	push   $0xe1
80106cff:	e9 6e f0 ff ff       	jmp    80105d72 <alltraps>

80106d04 <vector226>:
80106d04:	6a 00                	push   $0x0
80106d06:	68 e2 00 00 00       	push   $0xe2
80106d0b:	e9 62 f0 ff ff       	jmp    80105d72 <alltraps>

80106d10 <vector227>:
80106d10:	6a 00                	push   $0x0
80106d12:	68 e3 00 00 00       	push   $0xe3
80106d17:	e9 56 f0 ff ff       	jmp    80105d72 <alltraps>

80106d1c <vector228>:
80106d1c:	6a 00                	push   $0x0
80106d1e:	68 e4 00 00 00       	push   $0xe4
80106d23:	e9 4a f0 ff ff       	jmp    80105d72 <alltraps>

80106d28 <vector229>:
80106d28:	6a 00                	push   $0x0
80106d2a:	68 e5 00 00 00       	push   $0xe5
80106d2f:	e9 3e f0 ff ff       	jmp    80105d72 <alltraps>

80106d34 <vector230>:
80106d34:	6a 00                	push   $0x0
80106d36:	68 e6 00 00 00       	push   $0xe6
80106d3b:	e9 32 f0 ff ff       	jmp    80105d72 <alltraps>

80106d40 <vector231>:
80106d40:	6a 00                	push   $0x0
80106d42:	68 e7 00 00 00       	push   $0xe7
80106d47:	e9 26 f0 ff ff       	jmp    80105d72 <alltraps>

80106d4c <vector232>:
80106d4c:	6a 00                	push   $0x0
80106d4e:	68 e8 00 00 00       	push   $0xe8
80106d53:	e9 1a f0 ff ff       	jmp    80105d72 <alltraps>

80106d58 <vector233>:
80106d58:	6a 00                	push   $0x0
80106d5a:	68 e9 00 00 00       	push   $0xe9
80106d5f:	e9 0e f0 ff ff       	jmp    80105d72 <alltraps>

80106d64 <vector234>:
80106d64:	6a 00                	push   $0x0
80106d66:	68 ea 00 00 00       	push   $0xea
80106d6b:	e9 02 f0 ff ff       	jmp    80105d72 <alltraps>

80106d70 <vector235>:
80106d70:	6a 00                	push   $0x0
80106d72:	68 eb 00 00 00       	push   $0xeb
80106d77:	e9 f6 ef ff ff       	jmp    80105d72 <alltraps>

80106d7c <vector236>:
80106d7c:	6a 00                	push   $0x0
80106d7e:	68 ec 00 00 00       	push   $0xec
80106d83:	e9 ea ef ff ff       	jmp    80105d72 <alltraps>

80106d88 <vector237>:
80106d88:	6a 00                	push   $0x0
80106d8a:	68 ed 00 00 00       	push   $0xed
80106d8f:	e9 de ef ff ff       	jmp    80105d72 <alltraps>

80106d94 <vector238>:
80106d94:	6a 00                	push   $0x0
80106d96:	68 ee 00 00 00       	push   $0xee
80106d9b:	e9 d2 ef ff ff       	jmp    80105d72 <alltraps>

80106da0 <vector239>:
80106da0:	6a 00                	push   $0x0
80106da2:	68 ef 00 00 00       	push   $0xef
80106da7:	e9 c6 ef ff ff       	jmp    80105d72 <alltraps>

80106dac <vector240>:
80106dac:	6a 00                	push   $0x0
80106dae:	68 f0 00 00 00       	push   $0xf0
80106db3:	e9 ba ef ff ff       	jmp    80105d72 <alltraps>

80106db8 <vector241>:
80106db8:	6a 00                	push   $0x0
80106dba:	68 f1 00 00 00       	push   $0xf1
80106dbf:	e9 ae ef ff ff       	jmp    80105d72 <alltraps>

80106dc4 <vector242>:
80106dc4:	6a 00                	push   $0x0
80106dc6:	68 f2 00 00 00       	push   $0xf2
80106dcb:	e9 a2 ef ff ff       	jmp    80105d72 <alltraps>

80106dd0 <vector243>:
80106dd0:	6a 00                	push   $0x0
80106dd2:	68 f3 00 00 00       	push   $0xf3
80106dd7:	e9 96 ef ff ff       	jmp    80105d72 <alltraps>

80106ddc <vector244>:
80106ddc:	6a 00                	push   $0x0
80106dde:	68 f4 00 00 00       	push   $0xf4
80106de3:	e9 8a ef ff ff       	jmp    80105d72 <alltraps>

80106de8 <vector245>:
80106de8:	6a 00                	push   $0x0
80106dea:	68 f5 00 00 00       	push   $0xf5
80106def:	e9 7e ef ff ff       	jmp    80105d72 <alltraps>

80106df4 <vector246>:
80106df4:	6a 00                	push   $0x0
80106df6:	68 f6 00 00 00       	push   $0xf6
80106dfb:	e9 72 ef ff ff       	jmp    80105d72 <alltraps>

80106e00 <vector247>:
80106e00:	6a 00                	push   $0x0
80106e02:	68 f7 00 00 00       	push   $0xf7
80106e07:	e9 66 ef ff ff       	jmp    80105d72 <alltraps>

80106e0c <vector248>:
80106e0c:	6a 00                	push   $0x0
80106e0e:	68 f8 00 00 00       	push   $0xf8
80106e13:	e9 5a ef ff ff       	jmp    80105d72 <alltraps>

80106e18 <vector249>:
80106e18:	6a 00                	push   $0x0
80106e1a:	68 f9 00 00 00       	push   $0xf9
80106e1f:	e9 4e ef ff ff       	jmp    80105d72 <alltraps>

80106e24 <vector250>:
80106e24:	6a 00                	push   $0x0
80106e26:	68 fa 00 00 00       	push   $0xfa
80106e2b:	e9 42 ef ff ff       	jmp    80105d72 <alltraps>

80106e30 <vector251>:
80106e30:	6a 00                	push   $0x0
80106e32:	68 fb 00 00 00       	push   $0xfb
80106e37:	e9 36 ef ff ff       	jmp    80105d72 <alltraps>

80106e3c <vector252>:
80106e3c:	6a 00                	push   $0x0
80106e3e:	68 fc 00 00 00       	push   $0xfc
80106e43:	e9 2a ef ff ff       	jmp    80105d72 <alltraps>

80106e48 <vector253>:
80106e48:	6a 00                	push   $0x0
80106e4a:	68 fd 00 00 00       	push   $0xfd
80106e4f:	e9 1e ef ff ff       	jmp    80105d72 <alltraps>

80106e54 <vector254>:
80106e54:	6a 00                	push   $0x0
80106e56:	68 fe 00 00 00       	push   $0xfe
80106e5b:	e9 12 ef ff ff       	jmp    80105d72 <alltraps>

80106e60 <vector255>:
80106e60:	6a 00                	push   $0x0
80106e62:	68 ff 00 00 00       	push   $0xff
80106e67:	e9 06 ef ff ff       	jmp    80105d72 <alltraps>

80106e6c <lgdt>:
80106e6c:	55                   	push   %ebp
80106e6d:	89 e5                	mov    %esp,%ebp
80106e6f:	83 ec 10             	sub    $0x10,%esp
80106e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e75:	83 e8 01             	sub    $0x1,%eax
80106e78:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
80106e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e83:	8b 45 08             	mov    0x8(%ebp),%eax
80106e86:	c1 e8 10             	shr    $0x10,%eax
80106e89:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
80106e8d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e90:	0f 01 10             	lgdtl  (%eax)
80106e93:	90                   	nop
80106e94:	c9                   	leave  
80106e95:	c3                   	ret    

80106e96 <ltr>:
80106e96:	55                   	push   %ebp
80106e97:	89 e5                	mov    %esp,%ebp
80106e99:	83 ec 04             	sub    $0x4,%esp
80106e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106ea3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106ea7:	0f 00 d8             	ltr    %ax
80106eaa:	90                   	nop
80106eab:	c9                   	leave  
80106eac:	c3                   	ret    

80106ead <lcr3>:
80106ead:	55                   	push   %ebp
80106eae:	89 e5                	mov    %esp,%ebp
80106eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb3:	0f 22 d8             	mov    %eax,%cr3
80106eb6:	90                   	nop
80106eb7:	5d                   	pop    %ebp
80106eb8:	c3                   	ret    

80106eb9 <seginit>:
80106eb9:	55                   	push   %ebp
80106eba:	89 e5                	mov    %esp,%ebp
80106ebc:	83 ec 18             	sub    $0x18,%esp
80106ebf:	e8 d9 ca ff ff       	call   8010399d <cpuid>
80106ec4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106eca:	05 80 6b 19 80       	add    $0x80196b80,%eax
80106ecf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed5:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ede:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee7:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eee:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ef2:	83 e2 f0             	and    $0xfffffff0,%edx
80106ef5:	83 ca 0a             	or     $0xa,%edx
80106ef8:	88 50 7d             	mov    %dl,0x7d(%eax)
80106efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efe:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f02:	83 ca 10             	or     $0x10,%edx
80106f05:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f0f:	83 e2 9f             	and    $0xffffff9f,%edx
80106f12:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f18:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f1c:	83 ca 80             	or     $0xffffff80,%edx
80106f1f:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f25:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f29:	83 ca 0f             	or     $0xf,%edx
80106f2c:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f32:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f36:	83 e2 ef             	and    $0xffffffef,%edx
80106f39:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f43:	83 e2 df             	and    $0xffffffdf,%edx
80106f46:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f4c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f50:	83 ca 40             	or     $0x40,%edx
80106f53:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f59:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f5d:	83 ca 80             	or     $0xffffff80,%edx
80106f60:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f66:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
80106f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f74:	ff ff 
80106f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f79:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f80:	00 00 
80106f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f85:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f96:	83 e2 f0             	and    $0xfffffff0,%edx
80106f99:	83 ca 02             	or     $0x2,%edx
80106f9c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fac:	83 ca 10             	or     $0x10,%edx
80106faf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fbf:	83 e2 9f             	and    $0xffffff9f,%edx
80106fc2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fcb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fd2:	83 ca 80             	or     $0xffffff80,%edx
80106fd5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fde:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fe5:	83 ca 0f             	or     $0xf,%edx
80106fe8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106ff8:	83 e2 ef             	and    $0xffffffef,%edx
80106ffb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107004:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010700b:	83 e2 df             	and    $0xffffffdf,%edx
8010700e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107017:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010701e:	83 ca 40             	or     $0x40,%edx
80107021:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010702a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107031:	83 ca 80             	or     $0xffffff80,%edx
80107034:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010703a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
80107044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107047:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010704e:	ff ff 
80107050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107053:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010705a:	00 00 
8010705c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107069:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107070:	83 e2 f0             	and    $0xfffffff0,%edx
80107073:	83 ca 0a             	or     $0xa,%edx
80107076:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010707c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107086:	83 ca 10             	or     $0x10,%edx
80107089:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010708f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107092:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107099:	83 ca 60             	or     $0x60,%edx
8010709c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801070a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801070ac:	83 ca 80             	or     $0xffffff80,%edx
801070af:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801070b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070bf:	83 ca 0f             	or     $0xf,%edx
801070c2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070cb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070d2:	83 e2 ef             	and    $0xffffffef,%edx
801070d5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070de:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070e5:	83 e2 df             	and    $0xffffffdf,%edx
801070e8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070f8:	83 ca 40             	or     $0x40,%edx
801070fb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107104:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010710b:	83 ca 80             	or     $0xffffff80,%edx
8010710e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107117:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
8010711e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107121:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107128:	ff ff 
8010712a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107134:	00 00 
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107143:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010714a:	83 e2 f0             	and    $0xfffffff0,%edx
8010714d:	83 ca 02             	or     $0x2,%edx
80107150:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107159:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107160:	83 ca 10             	or     $0x10,%edx
80107163:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010716c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107173:	83 ca 60             	or     $0x60,%edx
80107176:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010717c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107186:	83 ca 80             	or     $0xffffff80,%edx
80107189:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010718f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107192:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107199:	83 ca 0f             	or     $0xf,%edx
8010719c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071ac:	83 e2 ef             	and    $0xffffffef,%edx
801071af:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071bf:	83 e2 df             	and    $0xffffffdf,%edx
801071c2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071cb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071d2:	83 ca 40             	or     $0x40,%edx
801071d5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071de:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071e5:	83 ca 80             	or     $0xffffff80,%edx
801071e8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
801071f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fb:	83 c0 70             	add    $0x70,%eax
801071fe:	83 ec 08             	sub    $0x8,%esp
80107201:	6a 30                	push   $0x30
80107203:	50                   	push   %eax
80107204:	e8 63 fc ff ff       	call   80106e6c <lgdt>
80107209:	83 c4 10             	add    $0x10,%esp
8010720c:	90                   	nop
8010720d:	c9                   	leave  
8010720e:	c3                   	ret    

8010720f <walkpgdir>:
8010720f:	55                   	push   %ebp
80107210:	89 e5                	mov    %esp,%ebp
80107212:	83 ec 18             	sub    $0x18,%esp
80107215:	8b 45 0c             	mov    0xc(%ebp),%eax
80107218:	c1 e8 16             	shr    $0x16,%eax
8010721b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107222:	8b 45 08             	mov    0x8(%ebp),%eax
80107225:	01 d0                	add    %edx,%eax
80107227:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010722a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010722d:	8b 00                	mov    (%eax),%eax
8010722f:	83 e0 01             	and    $0x1,%eax
80107232:	85 c0                	test   %eax,%eax
80107234:	74 14                	je     8010724a <walkpgdir+0x3b>
80107236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107239:	8b 00                	mov    (%eax),%eax
8010723b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107240:	05 00 00 00 80       	add    $0x80000000,%eax
80107245:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107248:	eb 42                	jmp    8010728c <walkpgdir+0x7d>
8010724a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010724e:	74 0e                	je     8010725e <walkpgdir+0x4f>
80107250:	e8 4b b5 ff ff       	call   801027a0 <kalloc>
80107255:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107258:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010725c:	75 07                	jne    80107265 <walkpgdir+0x56>
8010725e:	b8 00 00 00 00       	mov    $0x0,%eax
80107263:	eb 3e                	jmp    801072a3 <walkpgdir+0x94>
80107265:	83 ec 04             	sub    $0x4,%esp
80107268:	68 00 10 00 00       	push   $0x1000
8010726d:	6a 00                	push   $0x0
8010726f:	ff 75 f4             	push   -0xc(%ebp)
80107272:	e8 08 d7 ff ff       	call   8010497f <memset>
80107277:	83 c4 10             	add    $0x10,%esp
8010727a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727d:	05 00 00 00 80       	add    $0x80000000,%eax
80107282:	83 c8 07             	or     $0x7,%eax
80107285:	89 c2                	mov    %eax,%edx
80107287:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010728a:	89 10                	mov    %edx,(%eax)
8010728c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010728f:	c1 e8 0c             	shr    $0xc,%eax
80107292:	25 ff 03 00 00       	and    $0x3ff,%eax
80107297:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010729e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a1:	01 d0                	add    %edx,%eax
801072a3:	c9                   	leave  
801072a4:	c3                   	ret    

801072a5 <mappages>:
801072a5:	55                   	push   %ebp
801072a6:	89 e5                	mov    %esp,%ebp
801072a8:	83 ec 18             	sub    $0x18,%esp
801072ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801072ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072b6:	8b 55 0c             	mov    0xc(%ebp),%edx
801072b9:	8b 45 10             	mov    0x10(%ebp),%eax
801072bc:	01 d0                	add    %edx,%eax
801072be:	83 e8 01             	sub    $0x1,%eax
801072c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801072c9:	83 ec 04             	sub    $0x4,%esp
801072cc:	6a 01                	push   $0x1
801072ce:	ff 75 f4             	push   -0xc(%ebp)
801072d1:	ff 75 08             	push   0x8(%ebp)
801072d4:	e8 36 ff ff ff       	call   8010720f <walkpgdir>
801072d9:	83 c4 10             	add    $0x10,%esp
801072dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801072df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801072e3:	75 07                	jne    801072ec <mappages+0x47>
801072e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072ea:	eb 47                	jmp    80107333 <mappages+0x8e>
801072ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ef:	8b 00                	mov    (%eax),%eax
801072f1:	83 e0 01             	and    $0x1,%eax
801072f4:	85 c0                	test   %eax,%eax
801072f6:	74 0d                	je     80107305 <mappages+0x60>
801072f8:	83 ec 0c             	sub    $0xc,%esp
801072fb:	68 c8 a5 10 80       	push   $0x8010a5c8
80107300:	e8 a4 92 ff ff       	call   801005a9 <panic>
80107305:	8b 45 18             	mov    0x18(%ebp),%eax
80107308:	0b 45 14             	or     0x14(%ebp),%eax
8010730b:	83 c8 01             	or     $0x1,%eax
8010730e:	89 c2                	mov    %eax,%edx
80107310:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107313:	89 10                	mov    %edx,(%eax)
80107315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107318:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010731b:	74 10                	je     8010732d <mappages+0x88>
8010731d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107324:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
8010732b:	eb 9c                	jmp    801072c9 <mappages+0x24>
8010732d:	90                   	nop
8010732e:	b8 00 00 00 00       	mov    $0x0,%eax
80107333:	c9                   	leave  
80107334:	c3                   	ret    

80107335 <setupkvm>:
80107335:	55                   	push   %ebp
80107336:	89 e5                	mov    %esp,%ebp
80107338:	53                   	push   %ebx
80107339:	83 ec 24             	sub    $0x24,%esp
8010733c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107343:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107349:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
8010734e:	29 d0                	sub    %edx,%eax
80107350:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107353:	a1 48 6e 19 80       	mov    0x80196e48,%eax
80107358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010735b:	8b 15 48 6e 19 80    	mov    0x80196e48,%edx
80107361:	a1 50 6e 19 80       	mov    0x80196e50,%eax
80107366:	01 d0                	add    %edx,%eax
80107368:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010736b:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
80107372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107375:	83 c0 30             	add    $0x30,%eax
80107378:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010737b:	89 10                	mov    %edx,(%eax)
8010737d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107380:	89 50 04             	mov    %edx,0x4(%eax)
80107383:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107386:	89 50 08             	mov    %edx,0x8(%eax)
80107389:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010738c:	89 50 0c             	mov    %edx,0xc(%eax)
8010738f:	e8 0c b4 ff ff       	call   801027a0 <kalloc>
80107394:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107397:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010739b:	75 07                	jne    801073a4 <setupkvm+0x6f>
8010739d:	b8 00 00 00 00       	mov    $0x0,%eax
801073a2:	eb 78                	jmp    8010741c <setupkvm+0xe7>
801073a4:	83 ec 04             	sub    $0x4,%esp
801073a7:	68 00 10 00 00       	push   $0x1000
801073ac:	6a 00                	push   $0x0
801073ae:	ff 75 f0             	push   -0x10(%ebp)
801073b1:	e8 c9 d5 ff ff       	call   8010497f <memset>
801073b6:	83 c4 10             	add    $0x10,%esp
801073b9:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801073c0:	eb 4e                	jmp    80107410 <setupkvm+0xdb>
801073c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c5:	8b 48 0c             	mov    0xc(%eax),%ecx
801073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cb:	8b 50 04             	mov    0x4(%eax),%edx
801073ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d1:	8b 58 08             	mov    0x8(%eax),%ebx
801073d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d7:	8b 40 04             	mov    0x4(%eax),%eax
801073da:	29 c3                	sub    %eax,%ebx
801073dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073df:	8b 00                	mov    (%eax),%eax
801073e1:	83 ec 0c             	sub    $0xc,%esp
801073e4:	51                   	push   %ecx
801073e5:	52                   	push   %edx
801073e6:	53                   	push   %ebx
801073e7:	50                   	push   %eax
801073e8:	ff 75 f0             	push   -0x10(%ebp)
801073eb:	e8 b5 fe ff ff       	call   801072a5 <mappages>
801073f0:	83 c4 20             	add    $0x20,%esp
801073f3:	85 c0                	test   %eax,%eax
801073f5:	79 15                	jns    8010740c <setupkvm+0xd7>
801073f7:	83 ec 0c             	sub    $0xc,%esp
801073fa:	ff 75 f0             	push   -0x10(%ebp)
801073fd:	e8 f5 04 00 00       	call   801078f7 <freevm>
80107402:	83 c4 10             	add    $0x10,%esp
80107405:	b8 00 00 00 00       	mov    $0x0,%eax
8010740a:	eb 10                	jmp    8010741c <setupkvm+0xe7>
8010740c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107410:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107417:	72 a9                	jb     801073c2 <setupkvm+0x8d>
80107419:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010741c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010741f:	c9                   	leave  
80107420:	c3                   	ret    

80107421 <kvmalloc>:
80107421:	55                   	push   %ebp
80107422:	89 e5                	mov    %esp,%ebp
80107424:	83 ec 08             	sub    $0x8,%esp
80107427:	e8 09 ff ff ff       	call   80107335 <setupkvm>
8010742c:	a3 7c 6b 19 80       	mov    %eax,0x80196b7c
80107431:	e8 03 00 00 00       	call   80107439 <switchkvm>
80107436:	90                   	nop
80107437:	c9                   	leave  
80107438:	c3                   	ret    

80107439 <switchkvm>:
80107439:	55                   	push   %ebp
8010743a:	89 e5                	mov    %esp,%ebp
8010743c:	a1 7c 6b 19 80       	mov    0x80196b7c,%eax
80107441:	05 00 00 00 80       	add    $0x80000000,%eax
80107446:	50                   	push   %eax
80107447:	e8 61 fa ff ff       	call   80106ead <lcr3>
8010744c:	83 c4 04             	add    $0x4,%esp
8010744f:	90                   	nop
80107450:	c9                   	leave  
80107451:	c3                   	ret    

80107452 <switchuvm>:
80107452:	55                   	push   %ebp
80107453:	89 e5                	mov    %esp,%ebp
80107455:	56                   	push   %esi
80107456:	53                   	push   %ebx
80107457:	83 ec 10             	sub    $0x10,%esp
8010745a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010745e:	75 0d                	jne    8010746d <switchuvm+0x1b>
80107460:	83 ec 0c             	sub    $0xc,%esp
80107463:	68 ce a5 10 80       	push   $0x8010a5ce
80107468:	e8 3c 91 ff ff       	call   801005a9 <panic>
8010746d:	8b 45 08             	mov    0x8(%ebp),%eax
80107470:	8b 40 08             	mov    0x8(%eax),%eax
80107473:	85 c0                	test   %eax,%eax
80107475:	75 0d                	jne    80107484 <switchuvm+0x32>
80107477:	83 ec 0c             	sub    $0xc,%esp
8010747a:	68 e4 a5 10 80       	push   $0x8010a5e4
8010747f:	e8 25 91 ff ff       	call   801005a9 <panic>
80107484:	8b 45 08             	mov    0x8(%ebp),%eax
80107487:	8b 40 04             	mov    0x4(%eax),%eax
8010748a:	85 c0                	test   %eax,%eax
8010748c:	75 0d                	jne    8010749b <switchuvm+0x49>
8010748e:	83 ec 0c             	sub    $0xc,%esp
80107491:	68 f9 a5 10 80       	push   $0x8010a5f9
80107496:	e8 0e 91 ff ff       	call   801005a9 <panic>
8010749b:	e8 d4 d3 ff ff       	call   80104874 <pushcli>
801074a0:	e8 13 c5 ff ff       	call   801039b8 <mycpu>
801074a5:	89 c3                	mov    %eax,%ebx
801074a7:	e8 0c c5 ff ff       	call   801039b8 <mycpu>
801074ac:	83 c0 08             	add    $0x8,%eax
801074af:	89 c6                	mov    %eax,%esi
801074b1:	e8 02 c5 ff ff       	call   801039b8 <mycpu>
801074b6:	83 c0 08             	add    $0x8,%eax
801074b9:	c1 e8 10             	shr    $0x10,%eax
801074bc:	88 45 f7             	mov    %al,-0x9(%ebp)
801074bf:	e8 f4 c4 ff ff       	call   801039b8 <mycpu>
801074c4:	83 c0 08             	add    $0x8,%eax
801074c7:	c1 e8 18             	shr    $0x18,%eax
801074ca:	89 c2                	mov    %eax,%edx
801074cc:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801074d3:	67 00 
801074d5:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801074dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801074e0:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801074e6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074ed:	83 e0 f0             	and    $0xfffffff0,%eax
801074f0:	83 c8 09             	or     $0x9,%eax
801074f3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074f9:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107500:	83 c8 10             	or     $0x10,%eax
80107503:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107509:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107510:	83 e0 9f             	and    $0xffffff9f,%eax
80107513:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107519:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107520:	83 c8 80             	or     $0xffffff80,%eax
80107523:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107529:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107530:	83 e0 f0             	and    $0xfffffff0,%eax
80107533:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107539:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107540:	83 e0 ef             	and    $0xffffffef,%eax
80107543:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107549:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107550:	83 e0 df             	and    $0xffffffdf,%eax
80107553:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107559:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107560:	83 c8 40             	or     $0x40,%eax
80107563:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107569:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107570:	83 e0 7f             	and    $0x7f,%eax
80107573:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107579:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
8010757f:	e8 34 c4 ff ff       	call   801039b8 <mycpu>
80107584:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010758b:	83 e2 ef             	and    $0xffffffef,%edx
8010758e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107594:	e8 1f c4 ff ff       	call   801039b8 <mycpu>
80107599:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
8010759f:	8b 45 08             	mov    0x8(%ebp),%eax
801075a2:	8b 40 08             	mov    0x8(%eax),%eax
801075a5:	89 c3                	mov    %eax,%ebx
801075a7:	e8 0c c4 ff ff       	call   801039b8 <mycpu>
801075ac:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801075b2:	89 50 0c             	mov    %edx,0xc(%eax)
801075b5:	e8 fe c3 ff ff       	call   801039b8 <mycpu>
801075ba:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
801075c0:	83 ec 0c             	sub    $0xc,%esp
801075c3:	6a 28                	push   $0x28
801075c5:	e8 cc f8 ff ff       	call   80106e96 <ltr>
801075ca:	83 c4 10             	add    $0x10,%esp
801075cd:	8b 45 08             	mov    0x8(%ebp),%eax
801075d0:	8b 40 04             	mov    0x4(%eax),%eax
801075d3:	05 00 00 00 80       	add    $0x80000000,%eax
801075d8:	83 ec 0c             	sub    $0xc,%esp
801075db:	50                   	push   %eax
801075dc:	e8 cc f8 ff ff       	call   80106ead <lcr3>
801075e1:	83 c4 10             	add    $0x10,%esp
801075e4:	e8 d8 d2 ff ff       	call   801048c1 <popcli>
801075e9:	90                   	nop
801075ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
801075ed:	5b                   	pop    %ebx
801075ee:	5e                   	pop    %esi
801075ef:	5d                   	pop    %ebp
801075f0:	c3                   	ret    

801075f1 <inituvm>:
801075f1:	55                   	push   %ebp
801075f2:	89 e5                	mov    %esp,%ebp
801075f4:	83 ec 18             	sub    $0x18,%esp
801075f7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801075fe:	76 0d                	jbe    8010760d <inituvm+0x1c>
80107600:	83 ec 0c             	sub    $0xc,%esp
80107603:	68 0d a6 10 80       	push   $0x8010a60d
80107608:	e8 9c 8f ff ff       	call   801005a9 <panic>
8010760d:	e8 8e b1 ff ff       	call   801027a0 <kalloc>
80107612:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107615:	83 ec 04             	sub    $0x4,%esp
80107618:	68 00 10 00 00       	push   $0x1000
8010761d:	6a 00                	push   $0x0
8010761f:	ff 75 f4             	push   -0xc(%ebp)
80107622:	e8 58 d3 ff ff       	call   8010497f <memset>
80107627:	83 c4 10             	add    $0x10,%esp
8010762a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762d:	05 00 00 00 80       	add    $0x80000000,%eax
80107632:	83 ec 0c             	sub    $0xc,%esp
80107635:	6a 06                	push   $0x6
80107637:	50                   	push   %eax
80107638:	68 00 10 00 00       	push   $0x1000
8010763d:	6a 00                	push   $0x0
8010763f:	ff 75 08             	push   0x8(%ebp)
80107642:	e8 5e fc ff ff       	call   801072a5 <mappages>
80107647:	83 c4 20             	add    $0x20,%esp
8010764a:	83 ec 04             	sub    $0x4,%esp
8010764d:	ff 75 10             	push   0x10(%ebp)
80107650:	ff 75 0c             	push   0xc(%ebp)
80107653:	ff 75 f4             	push   -0xc(%ebp)
80107656:	e8 e3 d3 ff ff       	call   80104a3e <memmove>
8010765b:	83 c4 10             	add    $0x10,%esp
8010765e:	90                   	nop
8010765f:	c9                   	leave  
80107660:	c3                   	ret    

80107661 <loaduvm>:
80107661:	55                   	push   %ebp
80107662:	89 e5                	mov    %esp,%ebp
80107664:	83 ec 18             	sub    $0x18,%esp
80107667:	8b 45 0c             	mov    0xc(%ebp),%eax
8010766a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010766f:	85 c0                	test   %eax,%eax
80107671:	74 0d                	je     80107680 <loaduvm+0x1f>
80107673:	83 ec 0c             	sub    $0xc,%esp
80107676:	68 28 a6 10 80       	push   $0x8010a628
8010767b:	e8 29 8f ff ff       	call   801005a9 <panic>
80107680:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107687:	e9 8f 00 00 00       	jmp    8010771b <loaduvm+0xba>
8010768c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010768f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107692:	01 d0                	add    %edx,%eax
80107694:	83 ec 04             	sub    $0x4,%esp
80107697:	6a 00                	push   $0x0
80107699:	50                   	push   %eax
8010769a:	ff 75 08             	push   0x8(%ebp)
8010769d:	e8 6d fb ff ff       	call   8010720f <walkpgdir>
801076a2:	83 c4 10             	add    $0x10,%esp
801076a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801076a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801076ac:	75 0d                	jne    801076bb <loaduvm+0x5a>
801076ae:	83 ec 0c             	sub    $0xc,%esp
801076b1:	68 4b a6 10 80       	push   $0x8010a64b
801076b6:	e8 ee 8e ff ff       	call   801005a9 <panic>
801076bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801076be:	8b 00                	mov    (%eax),%eax
801076c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801076c8:	8b 45 18             	mov    0x18(%ebp),%eax
801076cb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801076ce:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801076d3:	77 0b                	ja     801076e0 <loaduvm+0x7f>
801076d5:	8b 45 18             	mov    0x18(%ebp),%eax
801076d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801076db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076de:	eb 07                	jmp    801076e7 <loaduvm+0x86>
801076e0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
801076e7:	8b 55 14             	mov    0x14(%ebp),%edx
801076ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ed:	01 d0                	add    %edx,%eax
801076ef:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076f2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801076f8:	ff 75 f0             	push   -0x10(%ebp)
801076fb:	50                   	push   %eax
801076fc:	52                   	push   %edx
801076fd:	ff 75 10             	push   0x10(%ebp)
80107700:	e8 d1 a7 ff ff       	call   80101ed6 <readi>
80107705:	83 c4 10             	add    $0x10,%esp
80107708:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010770b:	74 07                	je     80107714 <loaduvm+0xb3>
8010770d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107712:	eb 18                	jmp    8010772c <loaduvm+0xcb>
80107714:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010771b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771e:	3b 45 18             	cmp    0x18(%ebp),%eax
80107721:	0f 82 65 ff ff ff    	jb     8010768c <loaduvm+0x2b>
80107727:	b8 00 00 00 00       	mov    $0x0,%eax
8010772c:	c9                   	leave  
8010772d:	c3                   	ret    

8010772e <allocuvm>:
8010772e:	55                   	push   %ebp
8010772f:	89 e5                	mov    %esp,%ebp
80107731:	83 ec 18             	sub    $0x18,%esp
80107734:	8b 45 10             	mov    0x10(%ebp),%eax
80107737:	85 c0                	test   %eax,%eax
80107739:	79 0a                	jns    80107745 <allocuvm+0x17>
8010773b:	b8 00 00 00 00       	mov    $0x0,%eax
80107740:	e9 ec 00 00 00       	jmp    80107831 <allocuvm+0x103>
80107745:	8b 45 10             	mov    0x10(%ebp),%eax
80107748:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010774b:	73 08                	jae    80107755 <allocuvm+0x27>
8010774d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107750:	e9 dc 00 00 00       	jmp    80107831 <allocuvm+0x103>
80107755:	8b 45 0c             	mov    0xc(%ebp),%eax
80107758:	05 ff 0f 00 00       	add    $0xfff,%eax
8010775d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107762:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107765:	e9 b8 00 00 00       	jmp    80107822 <allocuvm+0xf4>
8010776a:	e8 31 b0 ff ff       	call   801027a0 <kalloc>
8010776f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107772:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107776:	75 2e                	jne    801077a6 <allocuvm+0x78>
80107778:	83 ec 0c             	sub    $0xc,%esp
8010777b:	68 69 a6 10 80       	push   $0x8010a669
80107780:	e8 6f 8c ff ff       	call   801003f4 <cprintf>
80107785:	83 c4 10             	add    $0x10,%esp
80107788:	83 ec 04             	sub    $0x4,%esp
8010778b:	ff 75 0c             	push   0xc(%ebp)
8010778e:	ff 75 10             	push   0x10(%ebp)
80107791:	ff 75 08             	push   0x8(%ebp)
80107794:	e8 9a 00 00 00       	call   80107833 <deallocuvm>
80107799:	83 c4 10             	add    $0x10,%esp
8010779c:	b8 00 00 00 00       	mov    $0x0,%eax
801077a1:	e9 8b 00 00 00       	jmp    80107831 <allocuvm+0x103>
801077a6:	83 ec 04             	sub    $0x4,%esp
801077a9:	68 00 10 00 00       	push   $0x1000
801077ae:	6a 00                	push   $0x0
801077b0:	ff 75 f0             	push   -0x10(%ebp)
801077b3:	e8 c7 d1 ff ff       	call   8010497f <memset>
801077b8:	83 c4 10             	add    $0x10,%esp
801077bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077be:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801077c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c7:	83 ec 0c             	sub    $0xc,%esp
801077ca:	6a 06                	push   $0x6
801077cc:	52                   	push   %edx
801077cd:	68 00 10 00 00       	push   $0x1000
801077d2:	50                   	push   %eax
801077d3:	ff 75 08             	push   0x8(%ebp)
801077d6:	e8 ca fa ff ff       	call   801072a5 <mappages>
801077db:	83 c4 20             	add    $0x20,%esp
801077de:	85 c0                	test   %eax,%eax
801077e0:	79 39                	jns    8010781b <allocuvm+0xed>
801077e2:	83 ec 0c             	sub    $0xc,%esp
801077e5:	68 81 a6 10 80       	push   $0x8010a681
801077ea:	e8 05 8c ff ff       	call   801003f4 <cprintf>
801077ef:	83 c4 10             	add    $0x10,%esp
801077f2:	83 ec 04             	sub    $0x4,%esp
801077f5:	ff 75 0c             	push   0xc(%ebp)
801077f8:	ff 75 10             	push   0x10(%ebp)
801077fb:	ff 75 08             	push   0x8(%ebp)
801077fe:	e8 30 00 00 00       	call   80107833 <deallocuvm>
80107803:	83 c4 10             	add    $0x10,%esp
80107806:	83 ec 0c             	sub    $0xc,%esp
80107809:	ff 75 f0             	push   -0x10(%ebp)
8010780c:	e8 f5 ae ff ff       	call   80102706 <kfree>
80107811:	83 c4 10             	add    $0x10,%esp
80107814:	b8 00 00 00 00       	mov    $0x0,%eax
80107819:	eb 16                	jmp    80107831 <allocuvm+0x103>
8010781b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	3b 45 10             	cmp    0x10(%ebp),%eax
80107828:	0f 82 3c ff ff ff    	jb     8010776a <allocuvm+0x3c>
8010782e:	8b 45 10             	mov    0x10(%ebp),%eax
80107831:	c9                   	leave  
80107832:	c3                   	ret    

80107833 <deallocuvm>:
80107833:	55                   	push   %ebp
80107834:	89 e5                	mov    %esp,%ebp
80107836:	83 ec 18             	sub    $0x18,%esp
80107839:	8b 45 10             	mov    0x10(%ebp),%eax
8010783c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010783f:	72 08                	jb     80107849 <deallocuvm+0x16>
80107841:	8b 45 0c             	mov    0xc(%ebp),%eax
80107844:	e9 ac 00 00 00       	jmp    801078f5 <deallocuvm+0xc2>
80107849:	8b 45 10             	mov    0x10(%ebp),%eax
8010784c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107851:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107856:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107859:	e9 88 00 00 00       	jmp    801078e6 <deallocuvm+0xb3>
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	83 ec 04             	sub    $0x4,%esp
80107864:	6a 00                	push   $0x0
80107866:	50                   	push   %eax
80107867:	ff 75 08             	push   0x8(%ebp)
8010786a:	e8 a0 f9 ff ff       	call   8010720f <walkpgdir>
8010786f:	83 c4 10             	add    $0x10,%esp
80107872:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107875:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107879:	75 16                	jne    80107891 <deallocuvm+0x5e>
8010787b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787e:	c1 e8 16             	shr    $0x16,%eax
80107881:	83 c0 01             	add    $0x1,%eax
80107884:	c1 e0 16             	shl    $0x16,%eax
80107887:	2d 00 10 00 00       	sub    $0x1000,%eax
8010788c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010788f:	eb 4e                	jmp    801078df <deallocuvm+0xac>
80107891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107894:	8b 00                	mov    (%eax),%eax
80107896:	83 e0 01             	and    $0x1,%eax
80107899:	85 c0                	test   %eax,%eax
8010789b:	74 42                	je     801078df <deallocuvm+0xac>
8010789d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078a0:	8b 00                	mov    (%eax),%eax
801078a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078ae:	75 0d                	jne    801078bd <deallocuvm+0x8a>
801078b0:	83 ec 0c             	sub    $0xc,%esp
801078b3:	68 9d a6 10 80       	push   $0x8010a69d
801078b8:	e8 ec 8c ff ff       	call   801005a9 <panic>
801078bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078c0:	05 00 00 00 80       	add    $0x80000000,%eax
801078c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801078c8:	83 ec 0c             	sub    $0xc,%esp
801078cb:	ff 75 e8             	push   -0x18(%ebp)
801078ce:	e8 33 ae ff ff       	call   80102706 <kfree>
801078d3:	83 c4 10             	add    $0x10,%esp
801078d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801078df:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078ec:	0f 82 6c ff ff ff    	jb     8010785e <deallocuvm+0x2b>
801078f2:	8b 45 10             	mov    0x10(%ebp),%eax
801078f5:	c9                   	leave  
801078f6:	c3                   	ret    

801078f7 <freevm>:
801078f7:	55                   	push   %ebp
801078f8:	89 e5                	mov    %esp,%ebp
801078fa:	83 ec 18             	sub    $0x18,%esp
801078fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107901:	75 0d                	jne    80107910 <freevm+0x19>
80107903:	83 ec 0c             	sub    $0xc,%esp
80107906:	68 a3 a6 10 80       	push   $0x8010a6a3
8010790b:	e8 99 8c ff ff       	call   801005a9 <panic>
80107910:	83 ec 04             	sub    $0x4,%esp
80107913:	6a 00                	push   $0x0
80107915:	68 00 00 00 80       	push   $0x80000000
8010791a:	ff 75 08             	push   0x8(%ebp)
8010791d:	e8 11 ff ff ff       	call   80107833 <deallocuvm>
80107922:	83 c4 10             	add    $0x10,%esp
80107925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010792c:	eb 48                	jmp    80107976 <freevm+0x7f>
8010792e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107931:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107938:	8b 45 08             	mov    0x8(%ebp),%eax
8010793b:	01 d0                	add    %edx,%eax
8010793d:	8b 00                	mov    (%eax),%eax
8010793f:	83 e0 01             	and    $0x1,%eax
80107942:	85 c0                	test   %eax,%eax
80107944:	74 2c                	je     80107972 <freevm+0x7b>
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107950:	8b 45 08             	mov    0x8(%ebp),%eax
80107953:	01 d0                	add    %edx,%eax
80107955:	8b 00                	mov    (%eax),%eax
80107957:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010795c:	05 00 00 00 80       	add    $0x80000000,%eax
80107961:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107964:	83 ec 0c             	sub    $0xc,%esp
80107967:	ff 75 f0             	push   -0x10(%ebp)
8010796a:	e8 97 ad ff ff       	call   80102706 <kfree>
8010796f:	83 c4 10             	add    $0x10,%esp
80107972:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107976:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010797d:	76 af                	jbe    8010792e <freevm+0x37>
8010797f:	83 ec 0c             	sub    $0xc,%esp
80107982:	ff 75 08             	push   0x8(%ebp)
80107985:	e8 7c ad ff ff       	call   80102706 <kfree>
8010798a:	83 c4 10             	add    $0x10,%esp
8010798d:	90                   	nop
8010798e:	c9                   	leave  
8010798f:	c3                   	ret    

80107990 <clearpteu>:
80107990:	55                   	push   %ebp
80107991:	89 e5                	mov    %esp,%ebp
80107993:	83 ec 18             	sub    $0x18,%esp
80107996:	83 ec 04             	sub    $0x4,%esp
80107999:	6a 00                	push   $0x0
8010799b:	ff 75 0c             	push   0xc(%ebp)
8010799e:	ff 75 08             	push   0x8(%ebp)
801079a1:	e8 69 f8 ff ff       	call   8010720f <walkpgdir>
801079a6:	83 c4 10             	add    $0x10,%esp
801079a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079b0:	75 0d                	jne    801079bf <clearpteu+0x2f>
801079b2:	83 ec 0c             	sub    $0xc,%esp
801079b5:	68 b4 a6 10 80       	push   $0x8010a6b4
801079ba:	e8 ea 8b ff ff       	call   801005a9 <panic>
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	8b 00                	mov    (%eax),%eax
801079c4:	83 e0 fb             	and    $0xfffffffb,%eax
801079c7:	89 c2                	mov    %eax,%edx
801079c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cc:	89 10                	mov    %edx,(%eax)
801079ce:	90                   	nop
801079cf:	c9                   	leave  
801079d0:	c3                   	ret    

801079d1 <copyuvm>:
801079d1:	55                   	push   %ebp
801079d2:	89 e5                	mov    %esp,%ebp
801079d4:	83 ec 28             	sub    $0x28,%esp
801079d7:	e8 59 f9 ff ff       	call   80107335 <setupkvm>
801079dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079e3:	75 0a                	jne    801079ef <copyuvm+0x1e>
801079e5:	b8 00 00 00 00       	mov    $0x0,%eax
801079ea:	e9 eb 00 00 00       	jmp    80107ada <copyuvm+0x109>
801079ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079f6:	e9 b7 00 00 00       	jmp    80107ab2 <copyuvm+0xe1>
801079fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fe:	83 ec 04             	sub    $0x4,%esp
80107a01:	6a 00                	push   $0x0
80107a03:	50                   	push   %eax
80107a04:	ff 75 08             	push   0x8(%ebp)
80107a07:	e8 03 f8 ff ff       	call   8010720f <walkpgdir>
80107a0c:	83 c4 10             	add    $0x10,%esp
80107a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a12:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a16:	75 0d                	jne    80107a25 <copyuvm+0x54>
80107a18:	83 ec 0c             	sub    $0xc,%esp
80107a1b:	68 be a6 10 80       	push   $0x8010a6be
80107a20:	e8 84 8b ff ff       	call   801005a9 <panic>
80107a25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a28:	8b 00                	mov    (%eax),%eax
80107a2a:	83 e0 01             	and    $0x1,%eax
80107a2d:	85 c0                	test   %eax,%eax
80107a2f:	75 0d                	jne    80107a3e <copyuvm+0x6d>
80107a31:	83 ec 0c             	sub    $0xc,%esp
80107a34:	68 d8 a6 10 80       	push   $0x8010a6d8
80107a39:	e8 6b 8b ff ff       	call   801005a9 <panic>
80107a3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a41:	8b 00                	mov    (%eax),%eax
80107a43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a48:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a4e:	8b 00                	mov    (%eax),%eax
80107a50:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a58:	e8 43 ad ff ff       	call   801027a0 <kalloc>
80107a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107a64:	74 5d                	je     80107ac3 <copyuvm+0xf2>
80107a66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a69:	05 00 00 00 80       	add    $0x80000000,%eax
80107a6e:	83 ec 04             	sub    $0x4,%esp
80107a71:	68 00 10 00 00       	push   $0x1000
80107a76:	50                   	push   %eax
80107a77:	ff 75 e0             	push   -0x20(%ebp)
80107a7a:	e8 bf cf ff ff       	call   80104a3e <memmove>
80107a7f:	83 c4 10             	add    $0x10,%esp
80107a82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a88:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a91:	83 ec 0c             	sub    $0xc,%esp
80107a94:	52                   	push   %edx
80107a95:	51                   	push   %ecx
80107a96:	68 00 10 00 00       	push   $0x1000
80107a9b:	50                   	push   %eax
80107a9c:	ff 75 f0             	push   -0x10(%ebp)
80107a9f:	e8 01 f8 ff ff       	call   801072a5 <mappages>
80107aa4:	83 c4 20             	add    $0x20,%esp
80107aa7:	85 c0                	test   %eax,%eax
80107aa9:	78 1b                	js     80107ac6 <copyuvm+0xf5>
80107aab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ab8:	0f 82 3d ff ff ff    	jb     801079fb <copyuvm+0x2a>
80107abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac1:	eb 17                	jmp    80107ada <copyuvm+0x109>
80107ac3:	90                   	nop
80107ac4:	eb 01                	jmp    80107ac7 <copyuvm+0xf6>
80107ac6:	90                   	nop
80107ac7:	83 ec 0c             	sub    $0xc,%esp
80107aca:	ff 75 f0             	push   -0x10(%ebp)
80107acd:	e8 25 fe ff ff       	call   801078f7 <freevm>
80107ad2:	83 c4 10             	add    $0x10,%esp
80107ad5:	b8 00 00 00 00       	mov    $0x0,%eax
80107ada:	c9                   	leave  
80107adb:	c3                   	ret    

80107adc <uva2ka>:
80107adc:	55                   	push   %ebp
80107add:	89 e5                	mov    %esp,%ebp
80107adf:	83 ec 18             	sub    $0x18,%esp
80107ae2:	83 ec 04             	sub    $0x4,%esp
80107ae5:	6a 00                	push   $0x0
80107ae7:	ff 75 0c             	push   0xc(%ebp)
80107aea:	ff 75 08             	push   0x8(%ebp)
80107aed:	e8 1d f7 ff ff       	call   8010720f <walkpgdir>
80107af2:	83 c4 10             	add    $0x10,%esp
80107af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	8b 00                	mov    (%eax),%eax
80107afd:	83 e0 01             	and    $0x1,%eax
80107b00:	85 c0                	test   %eax,%eax
80107b02:	75 07                	jne    80107b0b <uva2ka+0x2f>
80107b04:	b8 00 00 00 00       	mov    $0x0,%eax
80107b09:	eb 22                	jmp    80107b2d <uva2ka+0x51>
80107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0e:	8b 00                	mov    (%eax),%eax
80107b10:	83 e0 04             	and    $0x4,%eax
80107b13:	85 c0                	test   %eax,%eax
80107b15:	75 07                	jne    80107b1e <uva2ka+0x42>
80107b17:	b8 00 00 00 00       	mov    $0x0,%eax
80107b1c:	eb 0f                	jmp    80107b2d <uva2ka+0x51>
80107b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b21:	8b 00                	mov    (%eax),%eax
80107b23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b28:	05 00 00 00 80       	add    $0x80000000,%eax
80107b2d:	c9                   	leave  
80107b2e:	c3                   	ret    

80107b2f <copyout>:
80107b2f:	55                   	push   %ebp
80107b30:	89 e5                	mov    %esp,%ebp
80107b32:	83 ec 18             	sub    $0x18,%esp
80107b35:	8b 45 10             	mov    0x10(%ebp),%eax
80107b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b3b:	eb 7f                	jmp    80107bbc <copyout+0x8d>
80107b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b4b:	83 ec 08             	sub    $0x8,%esp
80107b4e:	50                   	push   %eax
80107b4f:	ff 75 08             	push   0x8(%ebp)
80107b52:	e8 85 ff ff ff       	call   80107adc <uva2ka>
80107b57:	83 c4 10             	add    $0x10,%esp
80107b5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107b5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107b61:	75 07                	jne    80107b6a <copyout+0x3b>
80107b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b68:	eb 61                	jmp    80107bcb <copyout+0x9c>
80107b6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b6d:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b70:	05 00 10 00 00       	add    $0x1000,%eax
80107b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7b:	3b 45 14             	cmp    0x14(%ebp),%eax
80107b7e:	76 06                	jbe    80107b86 <copyout+0x57>
80107b80:	8b 45 14             	mov    0x14(%ebp),%eax
80107b83:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b86:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b89:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b8c:	89 c2                	mov    %eax,%edx
80107b8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b91:	01 d0                	add    %edx,%eax
80107b93:	83 ec 04             	sub    $0x4,%esp
80107b96:	ff 75 f0             	push   -0x10(%ebp)
80107b99:	ff 75 f4             	push   -0xc(%ebp)
80107b9c:	50                   	push   %eax
80107b9d:	e8 9c ce ff ff       	call   80104a3e <memmove>
80107ba2:	83 c4 10             	add    $0x10,%esp
80107ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ba8:	29 45 14             	sub    %eax,0x14(%ebp)
80107bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bae:	01 45 f4             	add    %eax,-0xc(%ebp)
80107bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bb4:	05 00 10 00 00       	add    $0x1000,%eax
80107bb9:	89 45 0c             	mov    %eax,0xc(%ebp)
80107bbc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107bc0:	0f 85 77 ff ff ff    	jne    80107b3d <copyout+0xe>
80107bc6:	b8 00 00 00 00       	mov    $0x0,%eax
80107bcb:	c9                   	leave  
80107bcc:	c3                   	ret    

80107bcd <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107bcd:	55                   	push   %ebp
80107bce:	89 e5                	mov    %esp,%ebp
80107bd0:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107bd3:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107bda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107bdd:	8b 40 08             	mov    0x8(%eax),%eax
80107be0:	05 00 00 00 80       	add    $0x80000000,%eax
80107be5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107be8:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	8b 40 24             	mov    0x24(%eax),%eax
80107bf5:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107bfa:	c7 05 40 6e 19 80 00 	movl   $0x0,0x80196e40
80107c01:	00 00 00 

  while(i<madt->len){
80107c04:	90                   	nop
80107c05:	e9 bd 00 00 00       	jmp    80107cc7 <mpinit_uefi+0xfa>
    uchar *entry_type = ((uchar *)madt)+i;
80107c0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107c10:	01 d0                	add    %edx,%eax
80107c12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c18:	0f b6 00             	movzbl (%eax),%eax
80107c1b:	0f b6 c0             	movzbl %al,%eax
80107c1e:	83 f8 05             	cmp    $0x5,%eax
80107c21:	0f 87 a0 00 00 00    	ja     80107cc7 <mpinit_uefi+0xfa>
80107c27:	8b 04 85 f4 a6 10 80 	mov    -0x7fef590c(,%eax,4),%eax
80107c2e:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c33:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107c36:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107c3b:	83 f8 03             	cmp    $0x3,%eax
80107c3e:	7f 28                	jg     80107c68 <mpinit_uefi+0x9b>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107c40:	8b 15 40 6e 19 80    	mov    0x80196e40,%edx
80107c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c49:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107c4d:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107c53:	81 c2 80 6b 19 80    	add    $0x80196b80,%edx
80107c59:	88 02                	mov    %al,(%edx)
          ncpu++;
80107c5b:	a1 40 6e 19 80       	mov    0x80196e40,%eax
80107c60:	83 c0 01             	add    $0x1,%eax
80107c63:	a3 40 6e 19 80       	mov    %eax,0x80196e40
        }
        i += lapic_entry->record_len;
80107c68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c6b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c6f:	0f b6 c0             	movzbl %al,%eax
80107c72:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c75:	eb 50                	jmp    80107cc7 <mpinit_uefi+0xfa>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c80:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c84:	a2 44 6e 19 80       	mov    %al,0x80196e44
        i += ioapic->record_len;
80107c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c8c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c90:	0f b6 c0             	movzbl %al,%eax
80107c93:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c96:	eb 2f                	jmp    80107cc7 <mpinit_uefi+0xfa>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ca1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ca5:	0f b6 c0             	movzbl %al,%eax
80107ca8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107cab:	eb 1a                	jmp    80107cc7 <mpinit_uefi+0xfa>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107cb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cb6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107cba:	0f b6 c0             	movzbl %al,%eax
80107cbd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107cc0:	eb 05                	jmp    80107cc7 <mpinit_uefi+0xfa>

      case 5:
        i = i + 0xC;
80107cc2:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107cc6:	90                   	nop
  while(i<madt->len){
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	8b 40 04             	mov    0x4(%eax),%eax
80107ccd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107cd0:	0f 82 34 ff ff ff    	jb     80107c0a <mpinit_uefi+0x3d>
    }
  }

}
80107cd6:	90                   	nop
80107cd7:	90                   	nop
80107cd8:	c9                   	leave  
80107cd9:	c3                   	ret    

80107cda <inb>:
{
80107cda:	55                   	push   %ebp
80107cdb:	89 e5                	mov    %esp,%ebp
80107cdd:	83 ec 14             	sub    $0x14,%esp
80107ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ce7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107ceb:	89 c2                	mov    %eax,%edx
80107ced:	ec                   	in     (%dx),%al
80107cee:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107cf1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107cf5:	c9                   	leave  
80107cf6:	c3                   	ret    

80107cf7 <outb>:
{
80107cf7:	55                   	push   %ebp
80107cf8:	89 e5                	mov    %esp,%ebp
80107cfa:	83 ec 08             	sub    $0x8,%esp
80107cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80107d00:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d03:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107d07:	89 d0                	mov    %edx,%eax
80107d09:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107d0c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107d10:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107d14:	ee                   	out    %al,(%dx)
}
80107d15:	90                   	nop
80107d16:	c9                   	leave  
80107d17:	c3                   	ret    

80107d18 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107d18:	55                   	push   %ebp
80107d19:	89 e5                	mov    %esp,%ebp
80107d1b:	83 ec 28             	sub    $0x28,%esp
80107d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d21:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107d24:	6a 00                	push   $0x0
80107d26:	68 fa 03 00 00       	push   $0x3fa
80107d2b:	e8 c7 ff ff ff       	call   80107cf7 <outb>
80107d30:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107d33:	68 80 00 00 00       	push   $0x80
80107d38:	68 fb 03 00 00       	push   $0x3fb
80107d3d:	e8 b5 ff ff ff       	call   80107cf7 <outb>
80107d42:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107d45:	6a 0c                	push   $0xc
80107d47:	68 f8 03 00 00       	push   $0x3f8
80107d4c:	e8 a6 ff ff ff       	call   80107cf7 <outb>
80107d51:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107d54:	6a 00                	push   $0x0
80107d56:	68 f9 03 00 00       	push   $0x3f9
80107d5b:	e8 97 ff ff ff       	call   80107cf7 <outb>
80107d60:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d63:	6a 03                	push   $0x3
80107d65:	68 fb 03 00 00       	push   $0x3fb
80107d6a:	e8 88 ff ff ff       	call   80107cf7 <outb>
80107d6f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d72:	6a 00                	push   $0x0
80107d74:	68 fc 03 00 00       	push   $0x3fc
80107d79:	e8 79 ff ff ff       	call   80107cf7 <outb>
80107d7e:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d88:	eb 11                	jmp    80107d9b <uart_debug+0x83>
80107d8a:	83 ec 0c             	sub    $0xc,%esp
80107d8d:	6a 0a                	push   $0xa
80107d8f:	e8 a3 ad ff ff       	call   80102b37 <microdelay>
80107d94:	83 c4 10             	add    $0x10,%esp
80107d97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d9b:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d9f:	7f 1a                	jg     80107dbb <uart_debug+0xa3>
80107da1:	83 ec 0c             	sub    $0xc,%esp
80107da4:	68 fd 03 00 00       	push   $0x3fd
80107da9:	e8 2c ff ff ff       	call   80107cda <inb>
80107dae:	83 c4 10             	add    $0x10,%esp
80107db1:	0f b6 c0             	movzbl %al,%eax
80107db4:	83 e0 20             	and    $0x20,%eax
80107db7:	85 c0                	test   %eax,%eax
80107db9:	74 cf                	je     80107d8a <uart_debug+0x72>
  outb(COM1+0, p);
80107dbb:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107dbf:	0f b6 c0             	movzbl %al,%eax
80107dc2:	83 ec 08             	sub    $0x8,%esp
80107dc5:	50                   	push   %eax
80107dc6:	68 f8 03 00 00       	push   $0x3f8
80107dcb:	e8 27 ff ff ff       	call   80107cf7 <outb>
80107dd0:	83 c4 10             	add    $0x10,%esp
}
80107dd3:	90                   	nop
80107dd4:	c9                   	leave  
80107dd5:	c3                   	ret    

80107dd6 <uart_debugs>:

void uart_debugs(char *p){
80107dd6:	55                   	push   %ebp
80107dd7:	89 e5                	mov    %esp,%ebp
80107dd9:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107ddc:	eb 1b                	jmp    80107df9 <uart_debugs+0x23>
    uart_debug(*p++);
80107dde:	8b 45 08             	mov    0x8(%ebp),%eax
80107de1:	8d 50 01             	lea    0x1(%eax),%edx
80107de4:	89 55 08             	mov    %edx,0x8(%ebp)
80107de7:	0f b6 00             	movzbl (%eax),%eax
80107dea:	0f be c0             	movsbl %al,%eax
80107ded:	83 ec 0c             	sub    $0xc,%esp
80107df0:	50                   	push   %eax
80107df1:	e8 22 ff ff ff       	call   80107d18 <uart_debug>
80107df6:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107df9:	8b 45 08             	mov    0x8(%ebp),%eax
80107dfc:	0f b6 00             	movzbl (%eax),%eax
80107dff:	84 c0                	test   %al,%al
80107e01:	75 db                	jne    80107dde <uart_debugs+0x8>
  }
}
80107e03:	90                   	nop
80107e04:	90                   	nop
80107e05:	c9                   	leave  
80107e06:	c3                   	ret    

80107e07 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107e07:	55                   	push   %ebp
80107e08:	89 e5                	mov    %esp,%ebp
80107e0a:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e0d:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e17:	8b 50 14             	mov    0x14(%eax),%edx
80107e1a:	8b 40 10             	mov    0x10(%eax),%eax
80107e1d:	a3 48 6e 19 80       	mov    %eax,0x80196e48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107e22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e25:	8b 50 1c             	mov    0x1c(%eax),%edx
80107e28:	8b 40 18             	mov    0x18(%eax),%eax
80107e2b:	a3 50 6e 19 80       	mov    %eax,0x80196e50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107e30:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107e36:	b8 00 00 00 fe       	mov    $0xfe000000,%eax
80107e3b:	29 d0                	sub    %edx,%eax
80107e3d:	a3 4c 6e 19 80       	mov    %eax,0x80196e4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e45:	8b 50 24             	mov    0x24(%eax),%edx
80107e48:	8b 40 20             	mov    0x20(%eax),%eax
80107e4b:	a3 54 6e 19 80       	mov    %eax,0x80196e54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e53:	8b 50 2c             	mov    0x2c(%eax),%edx
80107e56:	8b 40 28             	mov    0x28(%eax),%eax
80107e59:	a3 58 6e 19 80       	mov    %eax,0x80196e58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107e5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e61:	8b 50 34             	mov    0x34(%eax),%edx
80107e64:	8b 40 30             	mov    0x30(%eax),%eax
80107e67:	a3 5c 6e 19 80       	mov    %eax,0x80196e5c
}
80107e6c:	90                   	nop
80107e6d:	c9                   	leave  
80107e6e:	c3                   	ret    

80107e6f <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e6f:	55                   	push   %ebp
80107e70:	89 e5                	mov    %esp,%ebp
80107e72:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e75:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e7e:	0f af d0             	imul   %eax,%edx
80107e81:	8b 45 08             	mov    0x8(%ebp),%eax
80107e84:	01 d0                	add    %edx,%eax
80107e86:	c1 e0 02             	shl    $0x2,%eax
80107e89:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e8c:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
80107e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e95:	01 d0                	add    %edx,%eax
80107e97:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e9a:	8b 45 10             	mov    0x10(%ebp),%eax
80107e9d:	0f b6 10             	movzbl (%eax),%edx
80107ea0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ea3:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107ea5:	8b 45 10             	mov    0x10(%ebp),%eax
80107ea8:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107eac:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107eaf:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107eb2:	8b 45 10             	mov    0x10(%ebp),%eax
80107eb5:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107eb9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ebc:	88 50 02             	mov    %dl,0x2(%eax)
}
80107ebf:	90                   	nop
80107ec0:	c9                   	leave  
80107ec1:	c3                   	ret    

80107ec2 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107ec2:	55                   	push   %ebp
80107ec3:	89 e5                	mov    %esp,%ebp
80107ec5:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107ec8:	8b 15 5c 6e 19 80    	mov    0x80196e5c,%edx
80107ece:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed1:	0f af c2             	imul   %edx,%eax
80107ed4:	c1 e0 02             	shl    $0x2,%eax
80107ed7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107eda:	a1 50 6e 19 80       	mov    0x80196e50,%eax
80107edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ee2:	29 d0                	sub    %edx,%eax
80107ee4:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107eea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107eed:	01 ca                	add    %ecx,%edx
80107eef:	89 d1                	mov    %edx,%ecx
80107ef1:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
80107ef7:	83 ec 04             	sub    $0x4,%esp
80107efa:	50                   	push   %eax
80107efb:	51                   	push   %ecx
80107efc:	52                   	push   %edx
80107efd:	e8 3c cb ff ff       	call   80104a3e <memmove>
80107f02:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	8b 0d 4c 6e 19 80    	mov    0x80196e4c,%ecx
80107f0e:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
80107f14:	01 ca                	add    %ecx,%edx
80107f16:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80107f19:	29 ca                	sub    %ecx,%edx
80107f1b:	83 ec 04             	sub    $0x4,%esp
80107f1e:	50                   	push   %eax
80107f1f:	6a 00                	push   $0x0
80107f21:	52                   	push   %edx
80107f22:	e8 58 ca ff ff       	call   8010497f <memset>
80107f27:	83 c4 10             	add    $0x10,%esp
}
80107f2a:	90                   	nop
80107f2b:	c9                   	leave  
80107f2c:	c3                   	ret    

80107f2d <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107f2d:	55                   	push   %ebp
80107f2e:	89 e5                	mov    %esp,%ebp
80107f30:	53                   	push   %ebx
80107f31:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107f34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f3b:	e9 b1 00 00 00       	jmp    80107ff1 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107f40:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107f47:	e9 97 00 00 00       	jmp    80107fe3 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107f4c:	8b 45 10             	mov    0x10(%ebp),%eax
80107f4f:	83 e8 20             	sub    $0x20,%eax
80107f52:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	01 d0                	add    %edx,%eax
80107f5a:	0f b7 84 00 20 a7 10 	movzwl -0x7fef58e0(%eax,%eax,1),%eax
80107f61:	80 
80107f62:	0f b7 d0             	movzwl %ax,%edx
80107f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f68:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f6d:	89 c1                	mov    %eax,%ecx
80107f6f:	d3 e3                	shl    %cl,%ebx
80107f71:	89 d8                	mov    %ebx,%eax
80107f73:	21 d0                	and    %edx,%eax
80107f75:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7b:	ba 01 00 00 00       	mov    $0x1,%edx
80107f80:	89 c1                	mov    %eax,%ecx
80107f82:	d3 e2                	shl    %cl,%edx
80107f84:	89 d0                	mov    %edx,%eax
80107f86:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f89:	75 2b                	jne    80107fb6 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f91:	01 c2                	add    %eax,%edx
80107f93:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f98:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f9b:	89 c1                	mov    %eax,%ecx
80107f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa0:	01 c8                	add    %ecx,%eax
80107fa2:	83 ec 04             	sub    $0x4,%esp
80107fa5:	68 e0 f4 10 80       	push   $0x8010f4e0
80107faa:	52                   	push   %edx
80107fab:	50                   	push   %eax
80107fac:	e8 be fe ff ff       	call   80107e6f <graphic_draw_pixel>
80107fb1:	83 c4 10             	add    $0x10,%esp
80107fb4:	eb 29                	jmp    80107fdf <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107fb6:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	01 c2                	add    %eax,%edx
80107fbe:	b8 0e 00 00 00       	mov    $0xe,%eax
80107fc3:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107fc6:	89 c1                	mov    %eax,%ecx
80107fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80107fcb:	01 c8                	add    %ecx,%eax
80107fcd:	83 ec 04             	sub    $0x4,%esp
80107fd0:	68 60 6e 19 80       	push   $0x80196e60
80107fd5:	52                   	push   %edx
80107fd6:	50                   	push   %eax
80107fd7:	e8 93 fe ff ff       	call   80107e6f <graphic_draw_pixel>
80107fdc:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107fdf:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107fe3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fe7:	0f 89 5f ff ff ff    	jns    80107f4c <font_render+0x1f>
  for(int i=0;i<30;i++){
80107fed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ff1:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107ff5:	0f 8e 45 ff ff ff    	jle    80107f40 <font_render+0x13>
      }
    }
  }
}
80107ffb:	90                   	nop
80107ffc:	90                   	nop
80107ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108000:	c9                   	leave  
80108001:	c3                   	ret    

80108002 <font_render_string>:

void font_render_string(char *string,int row){
80108002:	55                   	push   %ebp
80108003:	89 e5                	mov    %esp,%ebp
80108005:	53                   	push   %ebx
80108006:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108009:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108010:	eb 33                	jmp    80108045 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108012:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108015:	8b 45 08             	mov    0x8(%ebp),%eax
80108018:	01 d0                	add    %edx,%eax
8010801a:	0f b6 00             	movzbl (%eax),%eax
8010801d:	0f be c8             	movsbl %al,%ecx
80108020:	8b 45 0c             	mov    0xc(%ebp),%eax
80108023:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108026:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80108029:	89 d8                	mov    %ebx,%eax
8010802b:	c1 e0 04             	shl    $0x4,%eax
8010802e:	29 d8                	sub    %ebx,%eax
80108030:	83 c0 02             	add    $0x2,%eax
80108033:	83 ec 04             	sub    $0x4,%esp
80108036:	51                   	push   %ecx
80108037:	52                   	push   %edx
80108038:	50                   	push   %eax
80108039:	e8 ef fe ff ff       	call   80107f2d <font_render>
8010803e:	83 c4 10             	add    $0x10,%esp
    i++;
80108041:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108045:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108048:	8b 45 08             	mov    0x8(%ebp),%eax
8010804b:	01 d0                	add    %edx,%eax
8010804d:	0f b6 00             	movzbl (%eax),%eax
80108050:	84 c0                	test   %al,%al
80108052:	74 06                	je     8010805a <font_render_string+0x58>
80108054:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108058:	7e b8                	jle    80108012 <font_render_string+0x10>
  }
}
8010805a:	90                   	nop
8010805b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010805e:	c9                   	leave  
8010805f:	c3                   	ret    

80108060 <pci_init>:
80108060:	55                   	push   %ebp
80108061:	89 e5                	mov    %esp,%ebp
80108063:	53                   	push   %ebx
80108064:	83 ec 14             	sub    $0x14,%esp
80108067:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010806e:	eb 6b                	jmp    801080db <pci_init+0x7b>
80108070:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108077:	eb 58                	jmp    801080d1 <pci_init+0x71>
80108079:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108080:	eb 45                	jmp    801080c7 <pci_init+0x67>
80108082:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108085:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808b:	83 ec 0c             	sub    $0xc,%esp
8010808e:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108091:	53                   	push   %ebx
80108092:	6a 00                	push   $0x0
80108094:	51                   	push   %ecx
80108095:	52                   	push   %edx
80108096:	50                   	push   %eax
80108097:	e8 b0 00 00 00       	call   8010814c <pci_access_config>
8010809c:	83 c4 20             	add    $0x20,%esp
8010809f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080a2:	0f b7 c0             	movzwl %ax,%eax
801080a5:	3d ff ff 00 00       	cmp    $0xffff,%eax
801080aa:	74 17                	je     801080c3 <pci_init+0x63>
801080ac:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801080af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801080b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b5:	83 ec 04             	sub    $0x4,%esp
801080b8:	51                   	push   %ecx
801080b9:	52                   	push   %edx
801080ba:	50                   	push   %eax
801080bb:	e8 37 01 00 00       	call   801081f7 <pci_init_device>
801080c0:	83 c4 10             	add    $0x10,%esp
801080c3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801080c7:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801080cb:	7e b5                	jle    80108082 <pci_init+0x22>
801080cd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801080d1:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801080d5:	7e a2                	jle    80108079 <pci_init+0x19>
801080d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080db:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801080e2:	7e 8c                	jle    80108070 <pci_init+0x10>
801080e4:	90                   	nop
801080e5:	90                   	nop
801080e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080e9:	c9                   	leave  
801080ea:	c3                   	ret    

801080eb <pci_write_config>:
801080eb:	55                   	push   %ebp
801080ec:	89 e5                	mov    %esp,%ebp
801080ee:	8b 45 08             	mov    0x8(%ebp),%eax
801080f1:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801080f6:	89 c0                	mov    %eax,%eax
801080f8:	ef                   	out    %eax,(%dx)
801080f9:	90                   	nop
801080fa:	5d                   	pop    %ebp
801080fb:	c3                   	ret    

801080fc <pci_write_data>:
801080fc:	55                   	push   %ebp
801080fd:	89 e5                	mov    %esp,%ebp
801080ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108102:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108107:	89 c0                	mov    %eax,%eax
80108109:	ef                   	out    %eax,(%dx)
8010810a:	90                   	nop
8010810b:	5d                   	pop    %ebp
8010810c:	c3                   	ret    

8010810d <pci_read_config>:
8010810d:	55                   	push   %ebp
8010810e:	89 e5                	mov    %esp,%ebp
80108110:	83 ec 18             	sub    $0x18,%esp
80108113:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108118:	ed                   	in     (%dx),%eax
80108119:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010811c:	83 ec 0c             	sub    $0xc,%esp
8010811f:	68 c8 00 00 00       	push   $0xc8
80108124:	e8 0e aa ff ff       	call   80102b37 <microdelay>
80108129:	83 c4 10             	add    $0x10,%esp
8010812c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812f:	c9                   	leave  
80108130:	c3                   	ret    

80108131 <pci_test>:
80108131:	55                   	push   %ebp
80108132:	89 e5                	mov    %esp,%ebp
80108134:	83 ec 10             	sub    $0x10,%esp
80108137:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
8010813e:	ff 75 fc             	push   -0x4(%ebp)
80108141:	e8 a5 ff ff ff       	call   801080eb <pci_write_config>
80108146:	83 c4 04             	add    $0x4,%esp
80108149:	90                   	nop
8010814a:	c9                   	leave  
8010814b:	c3                   	ret    

8010814c <pci_access_config>:
8010814c:	55                   	push   %ebp
8010814d:	89 e5                	mov    %esp,%ebp
8010814f:	83 ec 18             	sub    $0x18,%esp
80108152:	8b 45 08             	mov    0x8(%ebp),%eax
80108155:	c1 e0 10             	shl    $0x10,%eax
80108158:	25 00 00 ff 00       	and    $0xff0000,%eax
8010815d:	89 c2                	mov    %eax,%edx
8010815f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108162:	c1 e0 0b             	shl    $0xb,%eax
80108165:	0f b7 c0             	movzwl %ax,%eax
80108168:	09 c2                	or     %eax,%edx
8010816a:	8b 45 10             	mov    0x10(%ebp),%eax
8010816d:	c1 e0 08             	shl    $0x8,%eax
80108170:	25 00 07 00 00       	and    $0x700,%eax
80108175:	09 c2                	or     %eax,%edx
80108177:	8b 45 14             	mov    0x14(%ebp),%eax
8010817a:	25 fc 00 00 00       	and    $0xfc,%eax
8010817f:	09 d0                	or     %edx,%eax
80108181:	0d 00 00 00 80       	or     $0x80000000,%eax
80108186:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108189:	ff 75 f4             	push   -0xc(%ebp)
8010818c:	e8 5a ff ff ff       	call   801080eb <pci_write_config>
80108191:	83 c4 04             	add    $0x4,%esp
80108194:	e8 74 ff ff ff       	call   8010810d <pci_read_config>
80108199:	8b 55 18             	mov    0x18(%ebp),%edx
8010819c:	89 02                	mov    %eax,(%edx)
8010819e:	90                   	nop
8010819f:	c9                   	leave  
801081a0:	c3                   	ret    

801081a1 <pci_write_config_register>:
801081a1:	55                   	push   %ebp
801081a2:	89 e5                	mov    %esp,%ebp
801081a4:	83 ec 10             	sub    $0x10,%esp
801081a7:	8b 45 08             	mov    0x8(%ebp),%eax
801081aa:	c1 e0 10             	shl    $0x10,%eax
801081ad:	25 00 00 ff 00       	and    $0xff0000,%eax
801081b2:	89 c2                	mov    %eax,%edx
801081b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b7:	c1 e0 0b             	shl    $0xb,%eax
801081ba:	0f b7 c0             	movzwl %ax,%eax
801081bd:	09 c2                	or     %eax,%edx
801081bf:	8b 45 10             	mov    0x10(%ebp),%eax
801081c2:	c1 e0 08             	shl    $0x8,%eax
801081c5:	25 00 07 00 00       	and    $0x700,%eax
801081ca:	09 c2                	or     %eax,%edx
801081cc:	8b 45 14             	mov    0x14(%ebp),%eax
801081cf:	25 fc 00 00 00       	and    $0xfc,%eax
801081d4:	09 d0                	or     %edx,%eax
801081d6:	0d 00 00 00 80       	or     $0x80000000,%eax
801081db:	89 45 fc             	mov    %eax,-0x4(%ebp)
801081de:	ff 75 fc             	push   -0x4(%ebp)
801081e1:	e8 05 ff ff ff       	call   801080eb <pci_write_config>
801081e6:	83 c4 04             	add    $0x4,%esp
801081e9:	ff 75 18             	push   0x18(%ebp)
801081ec:	e8 0b ff ff ff       	call   801080fc <pci_write_data>
801081f1:	83 c4 04             	add    $0x4,%esp
801081f4:	90                   	nop
801081f5:	c9                   	leave  
801081f6:	c3                   	ret    

801081f7 <pci_init_device>:
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	53                   	push   %ebx
801081fb:	83 ec 14             	sub    $0x14,%esp
801081fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108201:	a2 64 6e 19 80       	mov    %al,0x80196e64
80108206:	8b 45 0c             	mov    0xc(%ebp),%eax
80108209:	a2 65 6e 19 80       	mov    %al,0x80196e65
8010820e:	8b 45 10             	mov    0x10(%ebp),%eax
80108211:	a2 66 6e 19 80       	mov    %al,0x80196e66
80108216:	ff 75 10             	push   0x10(%ebp)
80108219:	ff 75 0c             	push   0xc(%ebp)
8010821c:	ff 75 08             	push   0x8(%ebp)
8010821f:	68 64 bd 10 80       	push   $0x8010bd64
80108224:	e8 cb 81 ff ff       	call   801003f4 <cprintf>
80108229:	83 c4 10             	add    $0x10,%esp
8010822c:	83 ec 0c             	sub    $0xc,%esp
8010822f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108232:	50                   	push   %eax
80108233:	6a 00                	push   $0x0
80108235:	ff 75 10             	push   0x10(%ebp)
80108238:	ff 75 0c             	push   0xc(%ebp)
8010823b:	ff 75 08             	push   0x8(%ebp)
8010823e:	e8 09 ff ff ff       	call   8010814c <pci_access_config>
80108243:	83 c4 20             	add    $0x20,%esp
80108246:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108249:	c1 e8 10             	shr    $0x10,%eax
8010824c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010824f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108252:	25 ff ff 00 00       	and    $0xffff,%eax
80108257:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010825a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825d:	a3 68 6e 19 80       	mov    %eax,0x80196e68
80108262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108265:	a3 6c 6e 19 80       	mov    %eax,0x80196e6c
8010826a:	83 ec 04             	sub    $0x4,%esp
8010826d:	ff 75 f0             	push   -0x10(%ebp)
80108270:	ff 75 f4             	push   -0xc(%ebp)
80108273:	68 98 bd 10 80       	push   $0x8010bd98
80108278:	e8 77 81 ff ff       	call   801003f4 <cprintf>
8010827d:	83 c4 10             	add    $0x10,%esp
80108280:	83 ec 0c             	sub    $0xc,%esp
80108283:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108286:	50                   	push   %eax
80108287:	6a 08                	push   $0x8
80108289:	ff 75 10             	push   0x10(%ebp)
8010828c:	ff 75 0c             	push   0xc(%ebp)
8010828f:	ff 75 08             	push   0x8(%ebp)
80108292:	e8 b5 fe ff ff       	call   8010814c <pci_access_config>
80108297:	83 c4 20             	add    $0x20,%esp
8010829a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010829d:	0f b6 c8             	movzbl %al,%ecx
801082a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a3:	c1 e8 08             	shr    $0x8,%eax
801082a6:	0f b6 d0             	movzbl %al,%edx
801082a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ac:	c1 e8 10             	shr    $0x10,%eax
801082af:	0f b6 c0             	movzbl %al,%eax
801082b2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801082b5:	c1 eb 18             	shr    $0x18,%ebx
801082b8:	83 ec 0c             	sub    $0xc,%esp
801082bb:	51                   	push   %ecx
801082bc:	52                   	push   %edx
801082bd:	50                   	push   %eax
801082be:	53                   	push   %ebx
801082bf:	68 bc bd 10 80       	push   $0x8010bdbc
801082c4:	e8 2b 81 ff ff       	call   801003f4 <cprintf>
801082c9:	83 c4 20             	add    $0x20,%esp
801082cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082cf:	c1 e8 18             	shr    $0x18,%eax
801082d2:	a2 70 6e 19 80       	mov    %al,0x80196e70
801082d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082da:	c1 e8 10             	shr    $0x10,%eax
801082dd:	a2 71 6e 19 80       	mov    %al,0x80196e71
801082e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e5:	c1 e8 08             	shr    $0x8,%eax
801082e8:	a2 72 6e 19 80       	mov    %al,0x80196e72
801082ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f0:	a2 73 6e 19 80       	mov    %al,0x80196e73
801082f5:	83 ec 0c             	sub    $0xc,%esp
801082f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082fb:	50                   	push   %eax
801082fc:	6a 10                	push   $0x10
801082fe:	ff 75 10             	push   0x10(%ebp)
80108301:	ff 75 0c             	push   0xc(%ebp)
80108304:	ff 75 08             	push   0x8(%ebp)
80108307:	e8 40 fe ff ff       	call   8010814c <pci_access_config>
8010830c:	83 c4 20             	add    $0x20,%esp
8010830f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108312:	a3 74 6e 19 80       	mov    %eax,0x80196e74
80108317:	83 ec 0c             	sub    $0xc,%esp
8010831a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010831d:	50                   	push   %eax
8010831e:	6a 14                	push   $0x14
80108320:	ff 75 10             	push   0x10(%ebp)
80108323:	ff 75 0c             	push   0xc(%ebp)
80108326:	ff 75 08             	push   0x8(%ebp)
80108329:	e8 1e fe ff ff       	call   8010814c <pci_access_config>
8010832e:	83 c4 20             	add    $0x20,%esp
80108331:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108334:	a3 78 6e 19 80       	mov    %eax,0x80196e78
80108339:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108340:	75 5a                	jne    8010839c <pci_init_device+0x1a5>
80108342:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108349:	75 51                	jne    8010839c <pci_init_device+0x1a5>
8010834b:	83 ec 0c             	sub    $0xc,%esp
8010834e:	68 01 be 10 80       	push   $0x8010be01
80108353:	e8 9c 80 ff ff       	call   801003f4 <cprintf>
80108358:	83 c4 10             	add    $0x10,%esp
8010835b:	83 ec 0c             	sub    $0xc,%esp
8010835e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108361:	50                   	push   %eax
80108362:	68 f0 00 00 00       	push   $0xf0
80108367:	ff 75 10             	push   0x10(%ebp)
8010836a:	ff 75 0c             	push   0xc(%ebp)
8010836d:	ff 75 08             	push   0x8(%ebp)
80108370:	e8 d7 fd ff ff       	call   8010814c <pci_access_config>
80108375:	83 c4 20             	add    $0x20,%esp
80108378:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010837b:	83 ec 08             	sub    $0x8,%esp
8010837e:	50                   	push   %eax
8010837f:	68 1b be 10 80       	push   $0x8010be1b
80108384:	e8 6b 80 ff ff       	call   801003f4 <cprintf>
80108389:	83 c4 10             	add    $0x10,%esp
8010838c:	83 ec 0c             	sub    $0xc,%esp
8010838f:	68 64 6e 19 80       	push   $0x80196e64
80108394:	e8 09 00 00 00       	call   801083a2 <i8254_init>
80108399:	83 c4 10             	add    $0x10,%esp
8010839c:	90                   	nop
8010839d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801083a0:	c9                   	leave  
801083a1:	c3                   	ret    

801083a2 <i8254_init>:
801083a2:	55                   	push   %ebp
801083a3:	89 e5                	mov    %esp,%ebp
801083a5:	53                   	push   %ebx
801083a6:	83 ec 14             	sub    $0x14,%esp
801083a9:	8b 45 08             	mov    0x8(%ebp),%eax
801083ac:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083b0:	0f b6 c8             	movzbl %al,%ecx
801083b3:	8b 45 08             	mov    0x8(%ebp),%eax
801083b6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083ba:	0f b6 d0             	movzbl %al,%edx
801083bd:	8b 45 08             	mov    0x8(%ebp),%eax
801083c0:	0f b6 00             	movzbl (%eax),%eax
801083c3:	0f b6 c0             	movzbl %al,%eax
801083c6:	83 ec 0c             	sub    $0xc,%esp
801083c9:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801083cc:	53                   	push   %ebx
801083cd:	6a 04                	push   $0x4
801083cf:	51                   	push   %ecx
801083d0:	52                   	push   %edx
801083d1:	50                   	push   %eax
801083d2:	e8 75 fd ff ff       	call   8010814c <pci_access_config>
801083d7:	83 c4 20             	add    $0x20,%esp
801083da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083dd:	83 c8 04             	or     $0x4,%eax
801083e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083e3:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801083e6:	8b 45 08             	mov    0x8(%ebp),%eax
801083e9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083ed:	0f b6 c8             	movzbl %al,%ecx
801083f0:	8b 45 08             	mov    0x8(%ebp),%eax
801083f3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083f7:	0f b6 d0             	movzbl %al,%edx
801083fa:	8b 45 08             	mov    0x8(%ebp),%eax
801083fd:	0f b6 00             	movzbl (%eax),%eax
80108400:	0f b6 c0             	movzbl %al,%eax
80108403:	83 ec 0c             	sub    $0xc,%esp
80108406:	53                   	push   %ebx
80108407:	6a 04                	push   $0x4
80108409:	51                   	push   %ecx
8010840a:	52                   	push   %edx
8010840b:	50                   	push   %eax
8010840c:	e8 90 fd ff ff       	call   801081a1 <pci_write_config_register>
80108411:	83 c4 20             	add    $0x20,%esp
80108414:	8b 45 08             	mov    0x8(%ebp),%eax
80108417:	8b 40 10             	mov    0x10(%eax),%eax
8010841a:	05 00 00 00 40       	add    $0x40000000,%eax
8010841f:	a3 7c 6e 19 80       	mov    %eax,0x80196e7c
80108424:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108429:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010842c:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108431:	05 d8 00 00 00       	add    $0xd8,%eax
80108436:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010843c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
80108442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108445:	8b 00                	mov    (%eax),%eax
80108447:	0d 00 00 00 04       	or     $0x4000000,%eax
8010844c:	89 c2                	mov    %eax,%edx
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	89 10                	mov    %edx,(%eax)
80108453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108456:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
8010845c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845f:	8b 00                	mov    (%eax),%eax
80108461:	83 c8 40             	or     $0x40,%eax
80108464:	89 c2                	mov    %eax,%edx
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	89 10                	mov    %edx,(%eax)
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	8b 10                	mov    (%eax),%edx
80108470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108473:	89 10                	mov    %edx,(%eax)
80108475:	83 ec 0c             	sub    $0xc,%esp
80108478:	68 30 be 10 80       	push   $0x8010be30
8010847d:	e8 72 7f ff ff       	call   801003f4 <cprintf>
80108482:	83 c4 10             	add    $0x10,%esp
80108485:	e8 16 a3 ff ff       	call   801027a0 <kalloc>
8010848a:	a3 88 6e 19 80       	mov    %eax,0x80196e88
8010848f:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010849a:	a1 88 6e 19 80       	mov    0x80196e88,%eax
8010849f:	83 ec 08             	sub    $0x8,%esp
801084a2:	50                   	push   %eax
801084a3:	68 52 be 10 80       	push   $0x8010be52
801084a8:	e8 47 7f ff ff       	call   801003f4 <cprintf>
801084ad:	83 c4 10             	add    $0x10,%esp
801084b0:	e8 50 00 00 00       	call   80108505 <i8254_init_recv>
801084b5:	e8 69 03 00 00       	call   80108823 <i8254_init_send>
801084ba:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
801084c1:	0f b6 d8             	movzbl %al,%ebx
801084c4:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
801084cb:	0f b6 c8             	movzbl %al,%ecx
801084ce:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
801084d5:	0f b6 d0             	movzbl %al,%edx
801084d8:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
801084df:	0f b6 c0             	movzbl %al,%eax
801084e2:	83 ec 0c             	sub    $0xc,%esp
801084e5:	53                   	push   %ebx
801084e6:	51                   	push   %ecx
801084e7:	52                   	push   %edx
801084e8:	50                   	push   %eax
801084e9:	68 60 be 10 80       	push   $0x8010be60
801084ee:	e8 01 7f ff ff       	call   801003f4 <cprintf>
801084f3:	83 c4 20             	add    $0x20,%esp
801084f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801084ff:	90                   	nop
80108500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108503:	c9                   	leave  
80108504:	c3                   	ret    

80108505 <i8254_init_recv>:
80108505:	55                   	push   %ebp
80108506:	89 e5                	mov    %esp,%ebp
80108508:	57                   	push   %edi
80108509:	56                   	push   %esi
8010850a:	53                   	push   %ebx
8010850b:	83 ec 6c             	sub    $0x6c,%esp
8010850e:	83 ec 0c             	sub    $0xc,%esp
80108511:	6a 00                	push   $0x0
80108513:	e8 e8 04 00 00       	call   80108a00 <i8254_read_eeprom>
80108518:	83 c4 10             	add    $0x10,%esp
8010851b:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010851e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108521:	a2 80 6e 19 80       	mov    %al,0x80196e80
80108526:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108529:	c1 e8 08             	shr    $0x8,%eax
8010852c:	a2 81 6e 19 80       	mov    %al,0x80196e81
80108531:	83 ec 0c             	sub    $0xc,%esp
80108534:	6a 01                	push   $0x1
80108536:	e8 c5 04 00 00       	call   80108a00 <i8254_read_eeprom>
8010853b:	83 c4 10             	add    $0x10,%esp
8010853e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80108541:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108544:	a2 82 6e 19 80       	mov    %al,0x80196e82
80108549:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010854c:	c1 e8 08             	shr    $0x8,%eax
8010854f:	a2 83 6e 19 80       	mov    %al,0x80196e83
80108554:	83 ec 0c             	sub    $0xc,%esp
80108557:	6a 02                	push   $0x2
80108559:	e8 a2 04 00 00       	call   80108a00 <i8254_read_eeprom>
8010855e:	83 c4 10             	add    $0x10,%esp
80108561:	89 45 d0             	mov    %eax,-0x30(%ebp)
80108564:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108567:	a2 84 6e 19 80       	mov    %al,0x80196e84
8010856c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010856f:	c1 e8 08             	shr    $0x8,%eax
80108572:	a2 85 6e 19 80       	mov    %al,0x80196e85
80108577:	0f b6 05 85 6e 19 80 	movzbl 0x80196e85,%eax
8010857e:	0f b6 f8             	movzbl %al,%edi
80108581:	0f b6 05 84 6e 19 80 	movzbl 0x80196e84,%eax
80108588:	0f b6 f0             	movzbl %al,%esi
8010858b:	0f b6 05 83 6e 19 80 	movzbl 0x80196e83,%eax
80108592:	0f b6 d8             	movzbl %al,%ebx
80108595:	0f b6 05 82 6e 19 80 	movzbl 0x80196e82,%eax
8010859c:	0f b6 c8             	movzbl %al,%ecx
8010859f:	0f b6 05 81 6e 19 80 	movzbl 0x80196e81,%eax
801085a6:	0f b6 d0             	movzbl %al,%edx
801085a9:	0f b6 05 80 6e 19 80 	movzbl 0x80196e80,%eax
801085b0:	0f b6 c0             	movzbl %al,%eax
801085b3:	83 ec 04             	sub    $0x4,%esp
801085b6:	57                   	push   %edi
801085b7:	56                   	push   %esi
801085b8:	53                   	push   %ebx
801085b9:	51                   	push   %ecx
801085ba:	52                   	push   %edx
801085bb:	50                   	push   %eax
801085bc:	68 78 be 10 80       	push   $0x8010be78
801085c1:	e8 2e 7e ff ff       	call   801003f4 <cprintf>
801085c6:	83 c4 20             	add    $0x20,%esp
801085c9:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801085ce:	05 00 54 00 00       	add    $0x5400,%eax
801085d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
801085d6:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801085db:	05 04 54 00 00       	add    $0x5404,%eax
801085e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
801085e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085e6:	c1 e0 10             	shl    $0x10,%eax
801085e9:	0b 45 d8             	or     -0x28(%ebp),%eax
801085ec:	89 c2                	mov    %eax,%edx
801085ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
801085f1:	89 10                	mov    %edx,(%eax)
801085f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085f6:	0d 00 00 00 80       	or     $0x80000000,%eax
801085fb:	89 c2                	mov    %eax,%edx
801085fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108600:	89 10                	mov    %edx,(%eax)
80108602:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108607:	05 00 52 00 00       	add    $0x5200,%eax
8010860c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
8010860f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108616:	eb 19                	jmp    80108631 <i8254_init_recv+0x12c>
80108618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010861b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108622:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108625:	01 d0                	add    %edx,%eax
80108627:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010862d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108631:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108635:	7e e1                	jle    80108618 <i8254_init_recv+0x113>
80108637:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010863c:	05 d0 00 00 00       	add    $0xd0,%eax
80108641:	89 45 c0             	mov    %eax,-0x40(%ebp)
80108644:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108647:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
8010864d:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108652:	05 c8 00 00 00       	add    $0xc8,%eax
80108657:	89 45 bc             	mov    %eax,-0x44(%ebp)
8010865a:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010865d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
80108663:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108668:	05 28 28 00 00       	add    $0x2828,%eax
8010866d:	89 45 b8             	mov    %eax,-0x48(%ebp)
80108670:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108673:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80108679:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010867e:	05 00 01 00 00       	add    $0x100,%eax
80108683:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80108686:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108689:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)
8010868f:	e8 0c a1 ff ff       	call   801027a0 <kalloc>
80108694:	89 45 b0             	mov    %eax,-0x50(%ebp)
80108697:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010869c:	05 00 28 00 00       	add    $0x2800,%eax
801086a1:	89 45 ac             	mov    %eax,-0x54(%ebp)
801086a4:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086a9:	05 04 28 00 00       	add    $0x2804,%eax
801086ae:	89 45 a8             	mov    %eax,-0x58(%ebp)
801086b1:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086b6:	05 08 28 00 00       	add    $0x2808,%eax
801086bb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
801086be:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086c3:	05 10 28 00 00       	add    $0x2810,%eax
801086c8:	89 45 a0             	mov    %eax,-0x60(%ebp)
801086cb:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801086d0:	05 18 28 00 00       	add    $0x2818,%eax
801086d5:	89 45 9c             	mov    %eax,-0x64(%ebp)
801086d8:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086db:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801086e1:	8b 45 ac             	mov    -0x54(%ebp),%eax
801086e4:	89 10                	mov    %edx,(%eax)
801086e6:	8b 45 a8             	mov    -0x58(%ebp),%eax
801086e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801086ef:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801086f2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
801086f8:	8b 45 a0             	mov    -0x60(%ebp),%eax
801086fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80108701:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108704:	c7 00 00 01 00 00    	movl   $0x100,(%eax)
8010870a:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010870d:	89 45 98             	mov    %eax,-0x68(%ebp)
80108710:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108717:	eb 73                	jmp    8010878c <i8254_init_recv+0x287>
80108719:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010871c:	c1 e0 04             	shl    $0x4,%eax
8010871f:	89 c2                	mov    %eax,%edx
80108721:	8b 45 98             	mov    -0x68(%ebp),%eax
80108724:	01 d0                	add    %edx,%eax
80108726:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
8010872d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108730:	c1 e0 04             	shl    $0x4,%eax
80108733:	89 c2                	mov    %eax,%edx
80108735:	8b 45 98             	mov    -0x68(%ebp),%eax
80108738:	01 d0                	add    %edx,%eax
8010873a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
80108740:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108743:	c1 e0 04             	shl    $0x4,%eax
80108746:	89 c2                	mov    %eax,%edx
80108748:	8b 45 98             	mov    -0x68(%ebp),%eax
8010874b:	01 d0                	add    %edx,%eax
8010874d:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
80108753:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108756:	c1 e0 04             	shl    $0x4,%eax
80108759:	89 c2                	mov    %eax,%edx
8010875b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010875e:	01 d0                	add    %edx,%eax
80108760:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80108764:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108767:	c1 e0 04             	shl    $0x4,%eax
8010876a:	89 c2                	mov    %eax,%edx
8010876c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010876f:	01 d0                	add    %edx,%eax
80108771:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
80108775:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108778:	c1 e0 04             	shl    $0x4,%eax
8010877b:	89 c2                	mov    %eax,%edx
8010877d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108780:	01 d0                	add    %edx,%eax
80108782:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
80108788:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010878c:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108793:	7e 84                	jle    80108719 <i8254_init_recv+0x214>
80108795:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010879c:	eb 57                	jmp    801087f5 <i8254_init_recv+0x2f0>
8010879e:	e8 fd 9f ff ff       	call   801027a0 <kalloc>
801087a3:	89 45 94             	mov    %eax,-0x6c(%ebp)
801087a6:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801087aa:	75 12                	jne    801087be <i8254_init_recv+0x2b9>
801087ac:	83 ec 0c             	sub    $0xc,%esp
801087af:	68 98 be 10 80       	push   $0x8010be98
801087b4:	e8 3b 7c ff ff       	call   801003f4 <cprintf>
801087b9:	83 c4 10             	add    $0x10,%esp
801087bc:	eb 3d                	jmp    801087fb <i8254_init_recv+0x2f6>
801087be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087c1:	c1 e0 04             	shl    $0x4,%eax
801087c4:	89 c2                	mov    %eax,%edx
801087c6:	8b 45 98             	mov    -0x68(%ebp),%eax
801087c9:	01 d0                	add    %edx,%eax
801087cb:	8b 55 94             	mov    -0x6c(%ebp),%edx
801087ce:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801087d4:	89 10                	mov    %edx,(%eax)
801087d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087d9:	83 c0 01             	add    $0x1,%eax
801087dc:	c1 e0 04             	shl    $0x4,%eax
801087df:	89 c2                	mov    %eax,%edx
801087e1:	8b 45 98             	mov    -0x68(%ebp),%eax
801087e4:	01 d0                	add    %edx,%eax
801087e6:	8b 55 94             	mov    -0x6c(%ebp),%edx
801087e9:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801087ef:	89 10                	mov    %edx,(%eax)
801087f1:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801087f5:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801087f9:	7e a3                	jle    8010879e <i8254_init_recv+0x299>
801087fb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087fe:	8b 00                	mov    (%eax),%eax
80108800:	83 c8 02             	or     $0x2,%eax
80108803:	89 c2                	mov    %eax,%edx
80108805:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108808:	89 10                	mov    %edx,(%eax)
8010880a:	83 ec 0c             	sub    $0xc,%esp
8010880d:	68 b8 be 10 80       	push   $0x8010beb8
80108812:	e8 dd 7b ff ff       	call   801003f4 <cprintf>
80108817:	83 c4 10             	add    $0x10,%esp
8010881a:	90                   	nop
8010881b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010881e:	5b                   	pop    %ebx
8010881f:	5e                   	pop    %esi
80108820:	5f                   	pop    %edi
80108821:	5d                   	pop    %ebp
80108822:	c3                   	ret    

80108823 <i8254_init_send>:
80108823:	55                   	push   %ebp
80108824:	89 e5                	mov    %esp,%ebp
80108826:	83 ec 48             	sub    $0x48,%esp
80108829:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010882e:	05 28 38 00 00       	add    $0x3828,%eax
80108833:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108836:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108839:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)
8010883f:	e8 5c 9f ff ff       	call   801027a0 <kalloc>
80108844:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108847:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
8010884c:	05 00 38 00 00       	add    $0x3800,%eax
80108851:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108854:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108859:	05 04 38 00 00       	add    $0x3804,%eax
8010885e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108861:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108866:	05 08 38 00 00       	add    $0x3808,%eax
8010886b:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010886e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108871:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108877:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010887a:	89 10                	mov    %edx,(%eax)
8010887c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010887f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80108885:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108888:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
8010888e:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108893:	05 10 38 00 00       	add    $0x3810,%eax
80108898:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010889b:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801088a0:	05 18 38 00 00       	add    $0x3818,%eax
801088a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801088a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801088b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801088ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
801088c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088c7:	e9 82 00 00 00       	jmp    8010894e <i8254_init_send+0x12b>
801088cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cf:	c1 e0 04             	shl    $0x4,%eax
801088d2:	89 c2                	mov    %eax,%edx
801088d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088d7:	01 d0                	add    %edx,%eax
801088d9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
801088e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e3:	c1 e0 04             	shl    $0x4,%eax
801088e6:	89 c2                	mov    %eax,%edx
801088e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088eb:	01 d0                	add    %edx,%eax
801088ed:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	c1 e0 04             	shl    $0x4,%eax
801088f9:	89 c2                	mov    %eax,%edx
801088fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088fe:	01 d0                	add    %edx,%eax
80108900:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
80108904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108907:	c1 e0 04             	shl    $0x4,%eax
8010890a:	89 c2                	mov    %eax,%edx
8010890c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010890f:	01 d0                	add    %edx,%eax
80108911:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
80108915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108918:	c1 e0 04             	shl    $0x4,%eax
8010891b:	89 c2                	mov    %eax,%edx
8010891d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108920:	01 d0                	add    %edx,%eax
80108922:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80108926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108929:	c1 e0 04             	shl    $0x4,%eax
8010892c:	89 c2                	mov    %eax,%edx
8010892e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108931:	01 d0                	add    %edx,%eax
80108933:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
80108937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893a:	c1 e0 04             	shl    $0x4,%eax
8010893d:	89 c2                	mov    %eax,%edx
8010893f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108942:	01 d0                	add    %edx,%eax
80108944:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
8010894a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010894e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108955:	0f 8e 71 ff ff ff    	jle    801088cc <i8254_init_send+0xa9>
8010895b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108962:	eb 57                	jmp    801089bb <i8254_init_send+0x198>
80108964:	e8 37 9e ff ff       	call   801027a0 <kalloc>
80108969:	89 45 cc             	mov    %eax,-0x34(%ebp)
8010896c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108970:	75 12                	jne    80108984 <i8254_init_send+0x161>
80108972:	83 ec 0c             	sub    $0xc,%esp
80108975:	68 98 be 10 80       	push   $0x8010be98
8010897a:	e8 75 7a ff ff       	call   801003f4 <cprintf>
8010897f:	83 c4 10             	add    $0x10,%esp
80108982:	eb 3d                	jmp    801089c1 <i8254_init_send+0x19e>
80108984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108987:	c1 e0 04             	shl    $0x4,%eax
8010898a:	89 c2                	mov    %eax,%edx
8010898c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010898f:	01 d0                	add    %edx,%eax
80108991:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108994:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010899a:	89 10                	mov    %edx,(%eax)
8010899c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899f:	83 c0 01             	add    $0x1,%eax
801089a2:	c1 e0 04             	shl    $0x4,%eax
801089a5:	89 c2                	mov    %eax,%edx
801089a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089aa:	01 d0                	add    %edx,%eax
801089ac:	8b 55 cc             	mov    -0x34(%ebp),%edx
801089af:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801089b5:	89 10                	mov    %edx,(%eax)
801089b7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089bb:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801089bf:	7e a3                	jle    80108964 <i8254_init_send+0x141>
801089c1:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801089c6:	05 00 04 00 00       	add    $0x400,%eax
801089cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
801089ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
801089d1:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)
801089d7:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
801089dc:	05 10 04 00 00       	add    $0x410,%eax
801089e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801089e4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089e7:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
801089ed:	83 ec 0c             	sub    $0xc,%esp
801089f0:	68 d8 be 10 80       	push   $0x8010bed8
801089f5:	e8 fa 79 ff ff       	call   801003f4 <cprintf>
801089fa:	83 c4 10             	add    $0x10,%esp
801089fd:	90                   	nop
801089fe:	c9                   	leave  
801089ff:	c3                   	ret    

80108a00 <i8254_read_eeprom>:
80108a00:	55                   	push   %ebp
80108a01:	89 e5                	mov    %esp,%ebp
80108a03:	83 ec 18             	sub    $0x18,%esp
80108a06:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a0b:	83 c0 14             	add    $0x14,%eax
80108a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a11:	8b 45 08             	mov    0x8(%ebp),%eax
80108a14:	c1 e0 08             	shl    $0x8,%eax
80108a17:	0f b7 c0             	movzwl %ax,%eax
80108a1a:	83 c8 01             	or     $0x1,%eax
80108a1d:	89 c2                	mov    %eax,%edx
80108a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a22:	89 10                	mov    %edx,(%eax)
80108a24:	83 ec 0c             	sub    $0xc,%esp
80108a27:	68 f8 be 10 80       	push   $0x8010bef8
80108a2c:	e8 c3 79 ff ff       	call   801003f4 <cprintf>
80108a31:	83 c4 10             	add    $0x10,%esp
80108a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a37:	8b 00                	mov    (%eax),%eax
80108a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a3f:	83 e0 10             	and    $0x10,%eax
80108a42:	85 c0                	test   %eax,%eax
80108a44:	75 02                	jne    80108a48 <i8254_read_eeprom+0x48>
80108a46:	eb dc                	jmp    80108a24 <i8254_read_eeprom+0x24>
80108a48:	90                   	nop
80108a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4c:	8b 00                	mov    (%eax),%eax
80108a4e:	c1 e8 10             	shr    $0x10,%eax
80108a51:	c9                   	leave  
80108a52:	c3                   	ret    

80108a53 <i8254_recv>:
80108a53:	55                   	push   %ebp
80108a54:	89 e5                	mov    %esp,%ebp
80108a56:	83 ec 28             	sub    $0x28,%esp
80108a59:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a5e:	05 10 28 00 00       	add    $0x2810,%eax
80108a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a66:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a6b:	05 18 28 00 00       	add    $0x2818,%eax
80108a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a73:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108a78:	05 00 28 00 00       	add    $0x2800,%eax
80108a7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a83:	8b 00                	mov    (%eax),%eax
80108a85:	05 00 00 00 80       	add    $0x80000000,%eax
80108a8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a90:	8b 10                	mov    (%eax),%edx
80108a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a95:	8b 08                	mov    (%eax),%ecx
80108a97:	89 d0                	mov    %edx,%eax
80108a99:	29 c8                	sub    %ecx,%eax
80108a9b:	25 ff 00 00 00       	and    $0xff,%eax
80108aa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108aa3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108aa7:	7e 37                	jle    80108ae0 <i8254_recv+0x8d>
80108aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aac:	8b 00                	mov    (%eax),%eax
80108aae:	c1 e0 04             	shl    $0x4,%eax
80108ab1:	89 c2                	mov    %eax,%edx
80108ab3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ab6:	01 d0                	add    %edx,%eax
80108ab8:	8b 00                	mov    (%eax),%eax
80108aba:	05 00 00 00 80       	add    $0x80000000,%eax
80108abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac5:	8b 00                	mov    (%eax),%eax
80108ac7:	83 c0 01             	add    $0x1,%eax
80108aca:	0f b6 d0             	movzbl %al,%edx
80108acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad0:	89 10                	mov    %edx,(%eax)
80108ad2:	83 ec 0c             	sub    $0xc,%esp
80108ad5:	ff 75 e0             	push   -0x20(%ebp)
80108ad8:	e8 15 09 00 00       	call   801093f2 <eth_proc>
80108add:	83 c4 10             	add    $0x10,%esp
80108ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae3:	8b 10                	mov    (%eax),%edx
80108ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae8:	8b 00                	mov    (%eax),%eax
80108aea:	39 c2                	cmp    %eax,%edx
80108aec:	75 9f                	jne    80108a8d <i8254_recv+0x3a>
80108aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af1:	8b 00                	mov    (%eax),%eax
80108af3:	8d 50 ff             	lea    -0x1(%eax),%edx
80108af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af9:	89 10                	mov    %edx,(%eax)
80108afb:	eb 90                	jmp    80108a8d <i8254_recv+0x3a>

80108afd <i8254_send>:
80108afd:	55                   	push   %ebp
80108afe:	89 e5                	mov    %esp,%ebp
80108b00:	83 ec 28             	sub    $0x28,%esp
80108b03:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108b08:	05 10 38 00 00       	add    $0x3810,%eax
80108b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b10:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108b15:	05 18 38 00 00       	add    $0x3818,%eax
80108b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b1d:	a1 7c 6e 19 80       	mov    0x80196e7c,%eax
80108b22:	05 00 38 00 00       	add    $0x3800,%eax
80108b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2d:	8b 00                	mov    (%eax),%eax
80108b2f:	05 00 00 00 80       	add    $0x80000000,%eax
80108b34:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b3a:	8b 10                	mov    (%eax),%edx
80108b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3f:	8b 08                	mov    (%eax),%ecx
80108b41:	89 d0                	mov    %edx,%eax
80108b43:	29 c8                	sub    %ecx,%eax
80108b45:	0f b6 d0             	movzbl %al,%edx
80108b48:	b8 00 01 00 00       	mov    $0x100,%eax
80108b4d:	29 d0                	sub    %edx,%eax
80108b4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b55:	8b 00                	mov    (%eax),%eax
80108b57:	25 ff 00 00 00       	and    $0xff,%eax
80108b5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108b5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b63:	0f 8e a8 00 00 00    	jle    80108c11 <i8254_send+0x114>
80108b69:	8b 45 08             	mov    0x8(%ebp),%eax
80108b6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b6f:	89 d1                	mov    %edx,%ecx
80108b71:	c1 e1 04             	shl    $0x4,%ecx
80108b74:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b77:	01 ca                	add    %ecx,%edx
80108b79:	8b 12                	mov    (%edx),%edx
80108b7b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b81:	83 ec 04             	sub    $0x4,%esp
80108b84:	ff 75 0c             	push   0xc(%ebp)
80108b87:	50                   	push   %eax
80108b88:	52                   	push   %edx
80108b89:	e8 b0 be ff ff       	call   80104a3e <memmove>
80108b8e:	83 c4 10             	add    $0x10,%esp
80108b91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b94:	c1 e0 04             	shl    $0x4,%eax
80108b97:	89 c2                	mov    %eax,%edx
80108b99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b9c:	01 d0                	add    %edx,%eax
80108b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ba1:	66 89 50 08          	mov    %dx,0x8(%eax)
80108ba5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba8:	c1 e0 04             	shl    $0x4,%eax
80108bab:	89 c2                	mov    %eax,%edx
80108bad:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bb0:	01 d0                	add    %edx,%eax
80108bb2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80108bb6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bb9:	c1 e0 04             	shl    $0x4,%eax
80108bbc:	89 c2                	mov    %eax,%edx
80108bbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bc1:	01 d0                	add    %edx,%eax
80108bc3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
80108bc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bca:	c1 e0 04             	shl    $0x4,%eax
80108bcd:	89 c2                	mov    %eax,%edx
80108bcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bd2:	01 d0                	add    %edx,%eax
80108bd4:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
80108bd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bdb:	c1 e0 04             	shl    $0x4,%eax
80108bde:	89 c2                	mov    %eax,%edx
80108be0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108be3:	01 d0                	add    %edx,%eax
80108be5:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
80108beb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bee:	c1 e0 04             	shl    $0x4,%eax
80108bf1:	89 c2                	mov    %eax,%edx
80108bf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bf6:	01 d0                	add    %edx,%eax
80108bf8:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
80108bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bff:	8b 00                	mov    (%eax),%eax
80108c01:	83 c0 01             	add    $0x1,%eax
80108c04:	0f b6 d0             	movzbl %al,%edx
80108c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0a:	89 10                	mov    %edx,(%eax)
80108c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c0f:	eb 05                	jmp    80108c16 <i8254_send+0x119>
80108c11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c16:	c9                   	leave  
80108c17:	c3                   	ret    

80108c18 <i8254_intr>:
80108c18:	55                   	push   %ebp
80108c19:	89 e5                	mov    %esp,%ebp
80108c1b:	a1 88 6e 19 80       	mov    0x80196e88,%eax
80108c20:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
80108c26:	90                   	nop
80108c27:	5d                   	pop    %ebp
80108c28:	c3                   	ret    

80108c29 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108c29:	55                   	push   %ebp
80108c2a:	89 e5                	mov    %esp,%ebp
80108c2c:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c38:	0f b7 00             	movzwl (%eax),%eax
80108c3b:	66 3d 00 01          	cmp    $0x100,%ax
80108c3f:	74 0a                	je     80108c4b <arp_proc+0x22>
80108c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c46:	e9 4f 01 00 00       	jmp    80108d9a <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4e:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108c52:	66 83 f8 08          	cmp    $0x8,%ax
80108c56:	74 0a                	je     80108c62 <arp_proc+0x39>
80108c58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c5d:	e9 38 01 00 00       	jmp    80108d9a <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c65:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c69:	3c 06                	cmp    $0x6,%al
80108c6b:	74 0a                	je     80108c77 <arp_proc+0x4e>
80108c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c72:	e9 23 01 00 00       	jmp    80108d9a <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7a:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c7e:	3c 04                	cmp    $0x4,%al
80108c80:	74 0a                	je     80108c8c <arp_proc+0x63>
80108c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c87:	e9 0e 01 00 00       	jmp    80108d9a <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8f:	83 c0 18             	add    $0x18,%eax
80108c92:	83 ec 04             	sub    $0x4,%esp
80108c95:	6a 04                	push   $0x4
80108c97:	50                   	push   %eax
80108c98:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c9d:	e8 44 bd ff ff       	call   801049e6 <memcmp>
80108ca2:	83 c4 10             	add    $0x10,%esp
80108ca5:	85 c0                	test   %eax,%eax
80108ca7:	74 27                	je     80108cd0 <arp_proc+0xa7>
80108ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cac:	83 c0 0e             	add    $0xe,%eax
80108caf:	83 ec 04             	sub    $0x4,%esp
80108cb2:	6a 04                	push   $0x4
80108cb4:	50                   	push   %eax
80108cb5:	68 e4 f4 10 80       	push   $0x8010f4e4
80108cba:	e8 27 bd ff ff       	call   801049e6 <memcmp>
80108cbf:	83 c4 10             	add    $0x10,%esp
80108cc2:	85 c0                	test   %eax,%eax
80108cc4:	74 0a                	je     80108cd0 <arp_proc+0xa7>
80108cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ccb:	e9 ca 00 00 00       	jmp    80108d9a <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108cd7:	66 3d 00 01          	cmp    $0x100,%ax
80108cdb:	75 69                	jne    80108d46 <arp_proc+0x11d>
80108cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce0:	83 c0 18             	add    $0x18,%eax
80108ce3:	83 ec 04             	sub    $0x4,%esp
80108ce6:	6a 04                	push   $0x4
80108ce8:	50                   	push   %eax
80108ce9:	68 e4 f4 10 80       	push   $0x8010f4e4
80108cee:	e8 f3 bc ff ff       	call   801049e6 <memcmp>
80108cf3:	83 c4 10             	add    $0x10,%esp
80108cf6:	85 c0                	test   %eax,%eax
80108cf8:	75 4c                	jne    80108d46 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108cfa:	e8 a1 9a ff ff       	call   801027a0 <kalloc>
80108cff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108d02:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108d09:	83 ec 04             	sub    $0x4,%esp
80108d0c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d0f:	50                   	push   %eax
80108d10:	ff 75 f0             	push   -0x10(%ebp)
80108d13:	ff 75 f4             	push   -0xc(%ebp)
80108d16:	e8 1f 04 00 00       	call   8010913a <arp_reply_pkt_create>
80108d1b:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d21:	83 ec 08             	sub    $0x8,%esp
80108d24:	50                   	push   %eax
80108d25:	ff 75 f0             	push   -0x10(%ebp)
80108d28:	e8 d0 fd ff ff       	call   80108afd <i8254_send>
80108d2d:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d33:	83 ec 0c             	sub    $0xc,%esp
80108d36:	50                   	push   %eax
80108d37:	e8 ca 99 ff ff       	call   80102706 <kfree>
80108d3c:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108d3f:	b8 02 00 00 00       	mov    $0x2,%eax
80108d44:	eb 54                	jmp    80108d9a <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d49:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d4d:	66 3d 00 02          	cmp    $0x200,%ax
80108d51:	75 42                	jne    80108d95 <arp_proc+0x16c>
80108d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d56:	83 c0 18             	add    $0x18,%eax
80108d59:	83 ec 04             	sub    $0x4,%esp
80108d5c:	6a 04                	push   $0x4
80108d5e:	50                   	push   %eax
80108d5f:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d64:	e8 7d bc ff ff       	call   801049e6 <memcmp>
80108d69:	83 c4 10             	add    $0x10,%esp
80108d6c:	85 c0                	test   %eax,%eax
80108d6e:	75 25                	jne    80108d95 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d70:	83 ec 0c             	sub    $0xc,%esp
80108d73:	68 fc be 10 80       	push   $0x8010befc
80108d78:	e8 77 76 ff ff       	call   801003f4 <cprintf>
80108d7d:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d80:	83 ec 0c             	sub    $0xc,%esp
80108d83:	ff 75 f4             	push   -0xc(%ebp)
80108d86:	e8 af 01 00 00       	call   80108f3a <arp_table_update>
80108d8b:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d8e:	b8 01 00 00 00       	mov    $0x1,%eax
80108d93:	eb 05                	jmp    80108d9a <arp_proc+0x171>
  }else{
    return -1;
80108d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d9a:	c9                   	leave  
80108d9b:	c3                   	ret    

80108d9c <arp_scan>:

void arp_scan(){
80108d9c:	55                   	push   %ebp
80108d9d:	89 e5                	mov    %esp,%ebp
80108d9f:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108da2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108da9:	eb 6f                	jmp    80108e1a <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108dab:	e8 f0 99 ff ff       	call   801027a0 <kalloc>
80108db0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108db3:	83 ec 04             	sub    $0x4,%esp
80108db6:	ff 75 f4             	push   -0xc(%ebp)
80108db9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108dbc:	50                   	push   %eax
80108dbd:	ff 75 ec             	push   -0x14(%ebp)
80108dc0:	e8 62 00 00 00       	call   80108e27 <arp_broadcast>
80108dc5:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dcb:	83 ec 08             	sub    $0x8,%esp
80108dce:	50                   	push   %eax
80108dcf:	ff 75 ec             	push   -0x14(%ebp)
80108dd2:	e8 26 fd ff ff       	call   80108afd <i8254_send>
80108dd7:	83 c4 10             	add    $0x10,%esp
80108dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108ddd:	eb 22                	jmp    80108e01 <arp_scan+0x65>
      microdelay(1);
80108ddf:	83 ec 0c             	sub    $0xc,%esp
80108de2:	6a 01                	push   $0x1
80108de4:	e8 4e 9d ff ff       	call   80102b37 <microdelay>
80108de9:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108dec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108def:	83 ec 08             	sub    $0x8,%esp
80108df2:	50                   	push   %eax
80108df3:	ff 75 ec             	push   -0x14(%ebp)
80108df6:	e8 02 fd ff ff       	call   80108afd <i8254_send>
80108dfb:	83 c4 10             	add    $0x10,%esp
80108dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e01:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108e05:	74 d8                	je     80108ddf <arp_scan+0x43>
    }
    kfree((char *)send);
80108e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e0a:	83 ec 0c             	sub    $0xc,%esp
80108e0d:	50                   	push   %eax
80108e0e:	e8 f3 98 ff ff       	call   80102706 <kfree>
80108e13:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108e16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e1a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e21:	7e 88                	jle    80108dab <arp_scan+0xf>
  }
}
80108e23:	90                   	nop
80108e24:	90                   	nop
80108e25:	c9                   	leave  
80108e26:	c3                   	ret    

80108e27 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108e27:	55                   	push   %ebp
80108e28:	89 e5                	mov    %esp,%ebp
80108e2a:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108e2d:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108e31:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108e35:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108e39:	8b 45 10             	mov    0x10(%ebp),%eax
80108e3c:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108e3f:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108e46:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108e4c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e53:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e5c:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108e62:	8b 45 08             	mov    0x8(%ebp),%eax
80108e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e68:	8b 45 08             	mov    0x8(%ebp),%eax
80108e6b:	83 c0 0e             	add    $0xe,%eax
80108e6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e74:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e82:	83 ec 04             	sub    $0x4,%esp
80108e85:	6a 06                	push   $0x6
80108e87:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e8a:	52                   	push   %edx
80108e8b:	50                   	push   %eax
80108e8c:	e8 ad bb ff ff       	call   80104a3e <memmove>
80108e91:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e97:	83 c0 06             	add    $0x6,%eax
80108e9a:	83 ec 04             	sub    $0x4,%esp
80108e9d:	6a 06                	push   $0x6
80108e9f:	68 80 6e 19 80       	push   $0x80196e80
80108ea4:	50                   	push   %eax
80108ea5:	e8 94 bb ff ff       	call   80104a3e <memmove>
80108eaa:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb0:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb8:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec1:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec8:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecf:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ed8:	8d 50 12             	lea    0x12(%eax),%edx
80108edb:	83 ec 04             	sub    $0x4,%esp
80108ede:	6a 06                	push   $0x6
80108ee0:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108ee3:	50                   	push   %eax
80108ee4:	52                   	push   %edx
80108ee5:	e8 54 bb ff ff       	call   80104a3e <memmove>
80108eea:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ef0:	8d 50 18             	lea    0x18(%eax),%edx
80108ef3:	83 ec 04             	sub    $0x4,%esp
80108ef6:	6a 04                	push   $0x4
80108ef8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108efb:	50                   	push   %eax
80108efc:	52                   	push   %edx
80108efd:	e8 3c bb ff ff       	call   80104a3e <memmove>
80108f02:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f08:	83 c0 08             	add    $0x8,%eax
80108f0b:	83 ec 04             	sub    $0x4,%esp
80108f0e:	6a 06                	push   $0x6
80108f10:	68 80 6e 19 80       	push   $0x80196e80
80108f15:	50                   	push   %eax
80108f16:	e8 23 bb ff ff       	call   80104a3e <memmove>
80108f1b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f21:	83 c0 0e             	add    $0xe,%eax
80108f24:	83 ec 04             	sub    $0x4,%esp
80108f27:	6a 04                	push   $0x4
80108f29:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f2e:	50                   	push   %eax
80108f2f:	e8 0a bb ff ff       	call   80104a3e <memmove>
80108f34:	83 c4 10             	add    $0x10,%esp
}
80108f37:	90                   	nop
80108f38:	c9                   	leave  
80108f39:	c3                   	ret    

80108f3a <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108f3a:	55                   	push   %ebp
80108f3b:	89 e5                	mov    %esp,%ebp
80108f3d:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108f40:	8b 45 08             	mov    0x8(%ebp),%eax
80108f43:	83 c0 0e             	add    $0xe,%eax
80108f46:	83 ec 0c             	sub    $0xc,%esp
80108f49:	50                   	push   %eax
80108f4a:	e8 bc 00 00 00       	call   8010900b <arp_table_search>
80108f4f:	83 c4 10             	add    $0x10,%esp
80108f52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108f55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f59:	78 2d                	js     80108f88 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5e:	8d 48 08             	lea    0x8(%eax),%ecx
80108f61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f64:	89 d0                	mov    %edx,%eax
80108f66:	c1 e0 02             	shl    $0x2,%eax
80108f69:	01 d0                	add    %edx,%eax
80108f6b:	01 c0                	add    %eax,%eax
80108f6d:	01 d0                	add    %edx,%eax
80108f6f:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108f74:	83 c0 04             	add    $0x4,%eax
80108f77:	83 ec 04             	sub    $0x4,%esp
80108f7a:	6a 06                	push   $0x6
80108f7c:	51                   	push   %ecx
80108f7d:	50                   	push   %eax
80108f7e:	e8 bb ba ff ff       	call   80104a3e <memmove>
80108f83:	83 c4 10             	add    $0x10,%esp
80108f86:	eb 70                	jmp    80108ff8 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f8c:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f92:	8d 48 08             	lea    0x8(%eax),%ecx
80108f95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f98:	89 d0                	mov    %edx,%eax
80108f9a:	c1 e0 02             	shl    $0x2,%eax
80108f9d:	01 d0                	add    %edx,%eax
80108f9f:	01 c0                	add    %eax,%eax
80108fa1:	01 d0                	add    %edx,%eax
80108fa3:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108fa8:	83 c0 04             	add    $0x4,%eax
80108fab:	83 ec 04             	sub    $0x4,%esp
80108fae:	6a 06                	push   $0x6
80108fb0:	51                   	push   %ecx
80108fb1:	50                   	push   %eax
80108fb2:	e8 87 ba ff ff       	call   80104a3e <memmove>
80108fb7:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108fba:	8b 45 08             	mov    0x8(%ebp),%eax
80108fbd:	8d 48 0e             	lea    0xe(%eax),%ecx
80108fc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fc3:	89 d0                	mov    %edx,%eax
80108fc5:	c1 e0 02             	shl    $0x2,%eax
80108fc8:	01 d0                	add    %edx,%eax
80108fca:	01 c0                	add    %eax,%eax
80108fcc:	01 d0                	add    %edx,%eax
80108fce:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80108fd3:	83 ec 04             	sub    $0x4,%esp
80108fd6:	6a 04                	push   $0x4
80108fd8:	51                   	push   %ecx
80108fd9:	50                   	push   %eax
80108fda:	e8 5f ba ff ff       	call   80104a3e <memmove>
80108fdf:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108fe2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fe5:	89 d0                	mov    %edx,%eax
80108fe7:	c1 e0 02             	shl    $0x2,%eax
80108fea:	01 d0                	add    %edx,%eax
80108fec:	01 c0                	add    %eax,%eax
80108fee:	01 d0                	add    %edx,%eax
80108ff0:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
80108ff5:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108ff8:	83 ec 0c             	sub    $0xc,%esp
80108ffb:	68 a0 6e 19 80       	push   $0x80196ea0
80109000:	e8 83 00 00 00       	call   80109088 <print_arp_table>
80109005:	83 c4 10             	add    $0x10,%esp
}
80109008:	90                   	nop
80109009:	c9                   	leave  
8010900a:	c3                   	ret    

8010900b <arp_table_search>:

int arp_table_search(uchar *ip){
8010900b:	55                   	push   %ebp
8010900c:	89 e5                	mov    %esp,%ebp
8010900e:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109011:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109018:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010901f:	eb 59                	jmp    8010907a <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109021:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109024:	89 d0                	mov    %edx,%eax
80109026:	c1 e0 02             	shl    $0x2,%eax
80109029:	01 d0                	add    %edx,%eax
8010902b:	01 c0                	add    %eax,%eax
8010902d:	01 d0                	add    %edx,%eax
8010902f:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80109034:	83 ec 04             	sub    $0x4,%esp
80109037:	6a 04                	push   $0x4
80109039:	ff 75 08             	push   0x8(%ebp)
8010903c:	50                   	push   %eax
8010903d:	e8 a4 b9 ff ff       	call   801049e6 <memcmp>
80109042:	83 c4 10             	add    $0x10,%esp
80109045:	85 c0                	test   %eax,%eax
80109047:	75 05                	jne    8010904e <arp_table_search+0x43>
      return i;
80109049:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904c:	eb 38                	jmp    80109086 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010904e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109051:	89 d0                	mov    %edx,%eax
80109053:	c1 e0 02             	shl    $0x2,%eax
80109056:	01 d0                	add    %edx,%eax
80109058:	01 c0                	add    %eax,%eax
8010905a:	01 d0                	add    %edx,%eax
8010905c:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
80109061:	0f b6 00             	movzbl (%eax),%eax
80109064:	84 c0                	test   %al,%al
80109066:	75 0e                	jne    80109076 <arp_table_search+0x6b>
80109068:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010906c:	75 08                	jne    80109076 <arp_table_search+0x6b>
      empty = -i;
8010906e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109071:	f7 d8                	neg    %eax
80109073:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109076:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010907a:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010907e:	7e a1                	jle    80109021 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109083:	83 e8 01             	sub    $0x1,%eax
}
80109086:	c9                   	leave  
80109087:	c3                   	ret    

80109088 <print_arp_table>:

void print_arp_table(){
80109088:	55                   	push   %ebp
80109089:	89 e5                	mov    %esp,%ebp
8010908b:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010908e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109095:	e9 92 00 00 00       	jmp    8010912c <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
8010909a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010909d:	89 d0                	mov    %edx,%eax
8010909f:	c1 e0 02             	shl    $0x2,%eax
801090a2:	01 d0                	add    %edx,%eax
801090a4:	01 c0                	add    %eax,%eax
801090a6:	01 d0                	add    %edx,%eax
801090a8:	05 aa 6e 19 80       	add    $0x80196eaa,%eax
801090ad:	0f b6 00             	movzbl (%eax),%eax
801090b0:	84 c0                	test   %al,%al
801090b2:	74 74                	je     80109128 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801090b4:	83 ec 08             	sub    $0x8,%esp
801090b7:	ff 75 f4             	push   -0xc(%ebp)
801090ba:	68 0f bf 10 80       	push   $0x8010bf0f
801090bf:	e8 30 73 ff ff       	call   801003f4 <cprintf>
801090c4:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801090c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090ca:	89 d0                	mov    %edx,%eax
801090cc:	c1 e0 02             	shl    $0x2,%eax
801090cf:	01 d0                	add    %edx,%eax
801090d1:	01 c0                	add    %eax,%eax
801090d3:	01 d0                	add    %edx,%eax
801090d5:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
801090da:	83 ec 0c             	sub    $0xc,%esp
801090dd:	50                   	push   %eax
801090de:	e8 54 02 00 00       	call   80109337 <print_ipv4>
801090e3:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801090e6:	83 ec 0c             	sub    $0xc,%esp
801090e9:	68 1e bf 10 80       	push   $0x8010bf1e
801090ee:	e8 01 73 ff ff       	call   801003f4 <cprintf>
801090f3:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801090f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090f9:	89 d0                	mov    %edx,%eax
801090fb:	c1 e0 02             	shl    $0x2,%eax
801090fe:	01 d0                	add    %edx,%eax
80109100:	01 c0                	add    %eax,%eax
80109102:	01 d0                	add    %edx,%eax
80109104:	05 a0 6e 19 80       	add    $0x80196ea0,%eax
80109109:	83 c0 04             	add    $0x4,%eax
8010910c:	83 ec 0c             	sub    $0xc,%esp
8010910f:	50                   	push   %eax
80109110:	e8 70 02 00 00       	call   80109385 <print_mac>
80109115:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109118:	83 ec 0c             	sub    $0xc,%esp
8010911b:	68 20 bf 10 80       	push   $0x8010bf20
80109120:	e8 cf 72 ff ff       	call   801003f4 <cprintf>
80109125:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109128:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010912c:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109130:	0f 8e 64 ff ff ff    	jle    8010909a <print_arp_table+0x12>
    }
  }
}
80109136:	90                   	nop
80109137:	90                   	nop
80109138:	c9                   	leave  
80109139:	c3                   	ret    

8010913a <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010913a:	55                   	push   %ebp
8010913b:	89 e5                	mov    %esp,%ebp
8010913d:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109140:	8b 45 10             	mov    0x10(%ebp),%eax
80109143:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010914c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010914f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109152:	83 c0 0e             	add    $0xe,%eax
80109155:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915b:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010915f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109162:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109166:	8b 45 08             	mov    0x8(%ebp),%eax
80109169:	8d 50 08             	lea    0x8(%eax),%edx
8010916c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916f:	83 ec 04             	sub    $0x4,%esp
80109172:	6a 06                	push   $0x6
80109174:	52                   	push   %edx
80109175:	50                   	push   %eax
80109176:	e8 c3 b8 ff ff       	call   80104a3e <memmove>
8010917b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010917e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109181:	83 c0 06             	add    $0x6,%eax
80109184:	83 ec 04             	sub    $0x4,%esp
80109187:	6a 06                	push   $0x6
80109189:	68 80 6e 19 80       	push   $0x80196e80
8010918e:	50                   	push   %eax
8010918f:	e8 aa b8 ff ff       	call   80104a3e <memmove>
80109194:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109197:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010919a:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010919f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a2:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801091a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ab:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801091af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b2:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801091b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b9:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801091bf:	8b 45 08             	mov    0x8(%ebp),%eax
801091c2:	8d 50 08             	lea    0x8(%eax),%edx
801091c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c8:	83 c0 12             	add    $0x12,%eax
801091cb:	83 ec 04             	sub    $0x4,%esp
801091ce:	6a 06                	push   $0x6
801091d0:	52                   	push   %edx
801091d1:	50                   	push   %eax
801091d2:	e8 67 b8 ff ff       	call   80104a3e <memmove>
801091d7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801091da:	8b 45 08             	mov    0x8(%ebp),%eax
801091dd:	8d 50 0e             	lea    0xe(%eax),%edx
801091e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e3:	83 c0 18             	add    $0x18,%eax
801091e6:	83 ec 04             	sub    $0x4,%esp
801091e9:	6a 04                	push   $0x4
801091eb:	52                   	push   %edx
801091ec:	50                   	push   %eax
801091ed:	e8 4c b8 ff ff       	call   80104a3e <memmove>
801091f2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f8:	83 c0 08             	add    $0x8,%eax
801091fb:	83 ec 04             	sub    $0x4,%esp
801091fe:	6a 06                	push   $0x6
80109200:	68 80 6e 19 80       	push   $0x80196e80
80109205:	50                   	push   %eax
80109206:	e8 33 b8 ff ff       	call   80104a3e <memmove>
8010920b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010920e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109211:	83 c0 0e             	add    $0xe,%eax
80109214:	83 ec 04             	sub    $0x4,%esp
80109217:	6a 04                	push   $0x4
80109219:	68 e4 f4 10 80       	push   $0x8010f4e4
8010921e:	50                   	push   %eax
8010921f:	e8 1a b8 ff ff       	call   80104a3e <memmove>
80109224:	83 c4 10             	add    $0x10,%esp
}
80109227:	90                   	nop
80109228:	c9                   	leave  
80109229:	c3                   	ret    

8010922a <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010922a:	55                   	push   %ebp
8010922b:	89 e5                	mov    %esp,%ebp
8010922d:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109230:	83 ec 0c             	sub    $0xc,%esp
80109233:	68 22 bf 10 80       	push   $0x8010bf22
80109238:	e8 b7 71 ff ff       	call   801003f4 <cprintf>
8010923d:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109240:	8b 45 08             	mov    0x8(%ebp),%eax
80109243:	83 c0 0e             	add    $0xe,%eax
80109246:	83 ec 0c             	sub    $0xc,%esp
80109249:	50                   	push   %eax
8010924a:	e8 e8 00 00 00       	call   80109337 <print_ipv4>
8010924f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109252:	83 ec 0c             	sub    $0xc,%esp
80109255:	68 20 bf 10 80       	push   $0x8010bf20
8010925a:	e8 95 71 ff ff       	call   801003f4 <cprintf>
8010925f:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109262:	8b 45 08             	mov    0x8(%ebp),%eax
80109265:	83 c0 08             	add    $0x8,%eax
80109268:	83 ec 0c             	sub    $0xc,%esp
8010926b:	50                   	push   %eax
8010926c:	e8 14 01 00 00       	call   80109385 <print_mac>
80109271:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109274:	83 ec 0c             	sub    $0xc,%esp
80109277:	68 20 bf 10 80       	push   $0x8010bf20
8010927c:	e8 73 71 ff ff       	call   801003f4 <cprintf>
80109281:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109284:	83 ec 0c             	sub    $0xc,%esp
80109287:	68 39 bf 10 80       	push   $0x8010bf39
8010928c:	e8 63 71 ff ff       	call   801003f4 <cprintf>
80109291:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109294:	8b 45 08             	mov    0x8(%ebp),%eax
80109297:	83 c0 18             	add    $0x18,%eax
8010929a:	83 ec 0c             	sub    $0xc,%esp
8010929d:	50                   	push   %eax
8010929e:	e8 94 00 00 00       	call   80109337 <print_ipv4>
801092a3:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092a6:	83 ec 0c             	sub    $0xc,%esp
801092a9:	68 20 bf 10 80       	push   $0x8010bf20
801092ae:	e8 41 71 ff ff       	call   801003f4 <cprintf>
801092b3:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801092b6:	8b 45 08             	mov    0x8(%ebp),%eax
801092b9:	83 c0 12             	add    $0x12,%eax
801092bc:	83 ec 0c             	sub    $0xc,%esp
801092bf:	50                   	push   %eax
801092c0:	e8 c0 00 00 00       	call   80109385 <print_mac>
801092c5:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092c8:	83 ec 0c             	sub    $0xc,%esp
801092cb:	68 20 bf 10 80       	push   $0x8010bf20
801092d0:	e8 1f 71 ff ff       	call   801003f4 <cprintf>
801092d5:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801092d8:	83 ec 0c             	sub    $0xc,%esp
801092db:	68 50 bf 10 80       	push   $0x8010bf50
801092e0:	e8 0f 71 ff ff       	call   801003f4 <cprintf>
801092e5:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801092e8:	8b 45 08             	mov    0x8(%ebp),%eax
801092eb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092ef:	66 3d 00 01          	cmp    $0x100,%ax
801092f3:	75 12                	jne    80109307 <print_arp_info+0xdd>
801092f5:	83 ec 0c             	sub    $0xc,%esp
801092f8:	68 5c bf 10 80       	push   $0x8010bf5c
801092fd:	e8 f2 70 ff ff       	call   801003f4 <cprintf>
80109302:	83 c4 10             	add    $0x10,%esp
80109305:	eb 1d                	jmp    80109324 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109307:	8b 45 08             	mov    0x8(%ebp),%eax
8010930a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010930e:	66 3d 00 02          	cmp    $0x200,%ax
80109312:	75 10                	jne    80109324 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109314:	83 ec 0c             	sub    $0xc,%esp
80109317:	68 65 bf 10 80       	push   $0x8010bf65
8010931c:	e8 d3 70 ff ff       	call   801003f4 <cprintf>
80109321:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109324:	83 ec 0c             	sub    $0xc,%esp
80109327:	68 20 bf 10 80       	push   $0x8010bf20
8010932c:	e8 c3 70 ff ff       	call   801003f4 <cprintf>
80109331:	83 c4 10             	add    $0x10,%esp
}
80109334:	90                   	nop
80109335:	c9                   	leave  
80109336:	c3                   	ret    

80109337 <print_ipv4>:

void print_ipv4(uchar *ip){
80109337:	55                   	push   %ebp
80109338:	89 e5                	mov    %esp,%ebp
8010933a:	53                   	push   %ebx
8010933b:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010933e:	8b 45 08             	mov    0x8(%ebp),%eax
80109341:	83 c0 03             	add    $0x3,%eax
80109344:	0f b6 00             	movzbl (%eax),%eax
80109347:	0f b6 d8             	movzbl %al,%ebx
8010934a:	8b 45 08             	mov    0x8(%ebp),%eax
8010934d:	83 c0 02             	add    $0x2,%eax
80109350:	0f b6 00             	movzbl (%eax),%eax
80109353:	0f b6 c8             	movzbl %al,%ecx
80109356:	8b 45 08             	mov    0x8(%ebp),%eax
80109359:	83 c0 01             	add    $0x1,%eax
8010935c:	0f b6 00             	movzbl (%eax),%eax
8010935f:	0f b6 d0             	movzbl %al,%edx
80109362:	8b 45 08             	mov    0x8(%ebp),%eax
80109365:	0f b6 00             	movzbl (%eax),%eax
80109368:	0f b6 c0             	movzbl %al,%eax
8010936b:	83 ec 0c             	sub    $0xc,%esp
8010936e:	53                   	push   %ebx
8010936f:	51                   	push   %ecx
80109370:	52                   	push   %edx
80109371:	50                   	push   %eax
80109372:	68 6c bf 10 80       	push   $0x8010bf6c
80109377:	e8 78 70 ff ff       	call   801003f4 <cprintf>
8010937c:	83 c4 20             	add    $0x20,%esp
}
8010937f:	90                   	nop
80109380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109383:	c9                   	leave  
80109384:	c3                   	ret    

80109385 <print_mac>:

void print_mac(uchar *mac){
80109385:	55                   	push   %ebp
80109386:	89 e5                	mov    %esp,%ebp
80109388:	57                   	push   %edi
80109389:	56                   	push   %esi
8010938a:	53                   	push   %ebx
8010938b:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010938e:	8b 45 08             	mov    0x8(%ebp),%eax
80109391:	83 c0 05             	add    $0x5,%eax
80109394:	0f b6 00             	movzbl (%eax),%eax
80109397:	0f b6 f8             	movzbl %al,%edi
8010939a:	8b 45 08             	mov    0x8(%ebp),%eax
8010939d:	83 c0 04             	add    $0x4,%eax
801093a0:	0f b6 00             	movzbl (%eax),%eax
801093a3:	0f b6 f0             	movzbl %al,%esi
801093a6:	8b 45 08             	mov    0x8(%ebp),%eax
801093a9:	83 c0 03             	add    $0x3,%eax
801093ac:	0f b6 00             	movzbl (%eax),%eax
801093af:	0f b6 d8             	movzbl %al,%ebx
801093b2:	8b 45 08             	mov    0x8(%ebp),%eax
801093b5:	83 c0 02             	add    $0x2,%eax
801093b8:	0f b6 00             	movzbl (%eax),%eax
801093bb:	0f b6 c8             	movzbl %al,%ecx
801093be:	8b 45 08             	mov    0x8(%ebp),%eax
801093c1:	83 c0 01             	add    $0x1,%eax
801093c4:	0f b6 00             	movzbl (%eax),%eax
801093c7:	0f b6 d0             	movzbl %al,%edx
801093ca:	8b 45 08             	mov    0x8(%ebp),%eax
801093cd:	0f b6 00             	movzbl (%eax),%eax
801093d0:	0f b6 c0             	movzbl %al,%eax
801093d3:	83 ec 04             	sub    $0x4,%esp
801093d6:	57                   	push   %edi
801093d7:	56                   	push   %esi
801093d8:	53                   	push   %ebx
801093d9:	51                   	push   %ecx
801093da:	52                   	push   %edx
801093db:	50                   	push   %eax
801093dc:	68 84 bf 10 80       	push   $0x8010bf84
801093e1:	e8 0e 70 ff ff       	call   801003f4 <cprintf>
801093e6:	83 c4 20             	add    $0x20,%esp
}
801093e9:	90                   	nop
801093ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801093ed:	5b                   	pop    %ebx
801093ee:	5e                   	pop    %esi
801093ef:	5f                   	pop    %edi
801093f0:	5d                   	pop    %ebp
801093f1:	c3                   	ret    

801093f2 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801093f2:	55                   	push   %ebp
801093f3:	89 e5                	mov    %esp,%ebp
801093f5:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801093f8:	8b 45 08             	mov    0x8(%ebp),%eax
801093fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801093fe:	8b 45 08             	mov    0x8(%ebp),%eax
80109401:	83 c0 0e             	add    $0xe,%eax
80109404:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010940e:	3c 08                	cmp    $0x8,%al
80109410:	75 1b                	jne    8010942d <eth_proc+0x3b>
80109412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109415:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109419:	3c 06                	cmp    $0x6,%al
8010941b:	75 10                	jne    8010942d <eth_proc+0x3b>
    arp_proc(pkt_addr);
8010941d:	83 ec 0c             	sub    $0xc,%esp
80109420:	ff 75 f0             	push   -0x10(%ebp)
80109423:	e8 01 f8 ff ff       	call   80108c29 <arp_proc>
80109428:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010942b:	eb 24                	jmp    80109451 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010942d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109430:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109434:	3c 08                	cmp    $0x8,%al
80109436:	75 19                	jne    80109451 <eth_proc+0x5f>
80109438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010943f:	84 c0                	test   %al,%al
80109441:	75 0e                	jne    80109451 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109443:	83 ec 0c             	sub    $0xc,%esp
80109446:	ff 75 08             	push   0x8(%ebp)
80109449:	e8 a3 00 00 00       	call   801094f1 <ipv4_proc>
8010944e:	83 c4 10             	add    $0x10,%esp
}
80109451:	90                   	nop
80109452:	c9                   	leave  
80109453:	c3                   	ret    

80109454 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109454:	55                   	push   %ebp
80109455:	89 e5                	mov    %esp,%ebp
80109457:	83 ec 04             	sub    $0x4,%esp
8010945a:	8b 45 08             	mov    0x8(%ebp),%eax
8010945d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109461:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109465:	c1 e0 08             	shl    $0x8,%eax
80109468:	89 c2                	mov    %eax,%edx
8010946a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010946e:	66 c1 e8 08          	shr    $0x8,%ax
80109472:	01 d0                	add    %edx,%eax
}
80109474:	c9                   	leave  
80109475:	c3                   	ret    

80109476 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109476:	55                   	push   %ebp
80109477:	89 e5                	mov    %esp,%ebp
80109479:	83 ec 04             	sub    $0x4,%esp
8010947c:	8b 45 08             	mov    0x8(%ebp),%eax
8010947f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109483:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109487:	c1 e0 08             	shl    $0x8,%eax
8010948a:	89 c2                	mov    %eax,%edx
8010948c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109490:	66 c1 e8 08          	shr    $0x8,%ax
80109494:	01 d0                	add    %edx,%eax
}
80109496:	c9                   	leave  
80109497:	c3                   	ret    

80109498 <H2N_uint>:

uint H2N_uint(uint value){
80109498:	55                   	push   %ebp
80109499:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010949b:	8b 45 08             	mov    0x8(%ebp),%eax
8010949e:	c1 e0 18             	shl    $0x18,%eax
801094a1:	25 00 00 00 0f       	and    $0xf000000,%eax
801094a6:	89 c2                	mov    %eax,%edx
801094a8:	8b 45 08             	mov    0x8(%ebp),%eax
801094ab:	c1 e0 08             	shl    $0x8,%eax
801094ae:	25 00 f0 00 00       	and    $0xf000,%eax
801094b3:	09 c2                	or     %eax,%edx
801094b5:	8b 45 08             	mov    0x8(%ebp),%eax
801094b8:	c1 e8 08             	shr    $0x8,%eax
801094bb:	83 e0 0f             	and    $0xf,%eax
801094be:	01 d0                	add    %edx,%eax
}
801094c0:	5d                   	pop    %ebp
801094c1:	c3                   	ret    

801094c2 <N2H_uint>:

uint N2H_uint(uint value){
801094c2:	55                   	push   %ebp
801094c3:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801094c5:	8b 45 08             	mov    0x8(%ebp),%eax
801094c8:	c1 e0 18             	shl    $0x18,%eax
801094cb:	89 c2                	mov    %eax,%edx
801094cd:	8b 45 08             	mov    0x8(%ebp),%eax
801094d0:	c1 e0 08             	shl    $0x8,%eax
801094d3:	25 00 00 ff 00       	and    $0xff0000,%eax
801094d8:	01 c2                	add    %eax,%edx
801094da:	8b 45 08             	mov    0x8(%ebp),%eax
801094dd:	c1 e8 08             	shr    $0x8,%eax
801094e0:	25 00 ff 00 00       	and    $0xff00,%eax
801094e5:	01 c2                	add    %eax,%edx
801094e7:	8b 45 08             	mov    0x8(%ebp),%eax
801094ea:	c1 e8 18             	shr    $0x18,%eax
801094ed:	01 d0                	add    %edx,%eax
}
801094ef:	5d                   	pop    %ebp
801094f0:	c3                   	ret    

801094f1 <ipv4_proc>:
801094f1:	55                   	push   %ebp
801094f2:	89 e5                	mov    %esp,%ebp
801094f4:	83 ec 18             	sub    $0x18,%esp
801094f7:	8b 45 08             	mov    0x8(%ebp),%eax
801094fa:	83 c0 0e             	add    $0xe,%eax
801094fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109503:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109507:	0f b7 d0             	movzwl %ax,%edx
8010950a:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
8010950f:	39 c2                	cmp    %eax,%edx
80109511:	74 60                	je     80109573 <ipv4_proc+0x82>
80109513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109516:	83 c0 0c             	add    $0xc,%eax
80109519:	83 ec 04             	sub    $0x4,%esp
8010951c:	6a 04                	push   $0x4
8010951e:	50                   	push   %eax
8010951f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109524:	e8 bd b4 ff ff       	call   801049e6 <memcmp>
80109529:	83 c4 10             	add    $0x10,%esp
8010952c:	85 c0                	test   %eax,%eax
8010952e:	74 43                	je     80109573 <ipv4_proc+0x82>
80109530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109533:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109537:	0f b7 c0             	movzwl %ax,%eax
8010953a:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
8010953f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109542:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109546:	3c 01                	cmp    $0x1,%al
80109548:	75 10                	jne    8010955a <ipv4_proc+0x69>
8010954a:	83 ec 0c             	sub    $0xc,%esp
8010954d:	ff 75 08             	push   0x8(%ebp)
80109550:	e8 a3 00 00 00       	call   801095f8 <icmp_proc>
80109555:	83 c4 10             	add    $0x10,%esp
80109558:	eb 19                	jmp    80109573 <ipv4_proc+0x82>
8010955a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109561:	3c 06                	cmp    $0x6,%al
80109563:	75 0e                	jne    80109573 <ipv4_proc+0x82>
80109565:	83 ec 0c             	sub    $0xc,%esp
80109568:	ff 75 08             	push   0x8(%ebp)
8010956b:	e8 b3 03 00 00       	call   80109923 <tcp_proc>
80109570:	83 c4 10             	add    $0x10,%esp
80109573:	90                   	nop
80109574:	c9                   	leave  
80109575:	c3                   	ret    

80109576 <ipv4_chksum>:
80109576:	55                   	push   %ebp
80109577:	89 e5                	mov    %esp,%ebp
80109579:	83 ec 10             	sub    $0x10,%esp
8010957c:	8b 45 08             	mov    0x8(%ebp),%eax
8010957f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109585:	0f b6 00             	movzbl (%eax),%eax
80109588:	83 e0 0f             	and    $0xf,%eax
8010958b:	01 c0                	add    %eax,%eax
8010958d:	88 45 f3             	mov    %al,-0xd(%ebp)
80109590:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109597:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010959e:	eb 48                	jmp    801095e8 <ipv4_chksum+0x72>
801095a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801095a3:	01 c0                	add    %eax,%eax
801095a5:	89 c2                	mov    %eax,%edx
801095a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095aa:	01 d0                	add    %edx,%eax
801095ac:	0f b6 00             	movzbl (%eax),%eax
801095af:	0f b6 c0             	movzbl %al,%eax
801095b2:	c1 e0 08             	shl    $0x8,%eax
801095b5:	89 c2                	mov    %eax,%edx
801095b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801095ba:	01 c0                	add    %eax,%eax
801095bc:	8d 48 01             	lea    0x1(%eax),%ecx
801095bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c2:	01 c8                	add    %ecx,%eax
801095c4:	0f b6 00             	movzbl (%eax),%eax
801095c7:	0f b6 c0             	movzbl %al,%eax
801095ca:	01 d0                	add    %edx,%eax
801095cc:	01 45 fc             	add    %eax,-0x4(%ebp)
801095cf:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801095d6:	76 0c                	jbe    801095e4 <ipv4_chksum+0x6e>
801095d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095db:	0f b7 c0             	movzwl %ax,%eax
801095de:	83 c0 01             	add    $0x1,%eax
801095e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801095e4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801095e8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801095ec:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801095ef:	7c af                	jl     801095a0 <ipv4_chksum+0x2a>
801095f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095f4:	f7 d0                	not    %eax
801095f6:	c9                   	leave  
801095f7:	c3                   	ret    

801095f8 <icmp_proc>:
801095f8:	55                   	push   %ebp
801095f9:	89 e5                	mov    %esp,%ebp
801095fb:	83 ec 18             	sub    $0x18,%esp
801095fe:	8b 45 08             	mov    0x8(%ebp),%eax
80109601:	83 c0 0e             	add    $0xe,%eax
80109604:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010960a:	0f b6 00             	movzbl (%eax),%eax
8010960d:	0f b6 c0             	movzbl %al,%eax
80109610:	83 e0 0f             	and    $0xf,%eax
80109613:	c1 e0 02             	shl    $0x2,%eax
80109616:	89 c2                	mov    %eax,%edx
80109618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961b:	01 d0                	add    %edx,%eax
8010961d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109623:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109627:	84 c0                	test   %al,%al
80109629:	75 4f                	jne    8010967a <icmp_proc+0x82>
8010962b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962e:	0f b6 00             	movzbl (%eax),%eax
80109631:	3c 08                	cmp    $0x8,%al
80109633:	75 45                	jne    8010967a <icmp_proc+0x82>
80109635:	e8 66 91 ff ff       	call   801027a0 <kalloc>
8010963a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010963d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109644:	83 ec 04             	sub    $0x4,%esp
80109647:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010964a:	50                   	push   %eax
8010964b:	ff 75 ec             	push   -0x14(%ebp)
8010964e:	ff 75 08             	push   0x8(%ebp)
80109651:	e8 78 00 00 00       	call   801096ce <icmp_reply_pkt_create>
80109656:	83 c4 10             	add    $0x10,%esp
80109659:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010965c:	83 ec 08             	sub    $0x8,%esp
8010965f:	50                   	push   %eax
80109660:	ff 75 ec             	push   -0x14(%ebp)
80109663:	e8 95 f4 ff ff       	call   80108afd <i8254_send>
80109668:	83 c4 10             	add    $0x10,%esp
8010966b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010966e:	83 ec 0c             	sub    $0xc,%esp
80109671:	50                   	push   %eax
80109672:	e8 8f 90 ff ff       	call   80102706 <kfree>
80109677:	83 c4 10             	add    $0x10,%esp
8010967a:	90                   	nop
8010967b:	c9                   	leave  
8010967c:	c3                   	ret    

8010967d <icmp_proc_req>:
8010967d:	55                   	push   %ebp
8010967e:	89 e5                	mov    %esp,%ebp
80109680:	53                   	push   %ebx
80109681:	83 ec 04             	sub    $0x4,%esp
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010968b:	0f b7 c0             	movzwl %ax,%eax
8010968e:	83 ec 0c             	sub    $0xc,%esp
80109691:	50                   	push   %eax
80109692:	e8 bd fd ff ff       	call   80109454 <N2H_ushort>
80109697:	83 c4 10             	add    $0x10,%esp
8010969a:	0f b7 d8             	movzwl %ax,%ebx
8010969d:	8b 45 08             	mov    0x8(%ebp),%eax
801096a0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801096a4:	0f b7 c0             	movzwl %ax,%eax
801096a7:	83 ec 0c             	sub    $0xc,%esp
801096aa:	50                   	push   %eax
801096ab:	e8 a4 fd ff ff       	call   80109454 <N2H_ushort>
801096b0:	83 c4 10             	add    $0x10,%esp
801096b3:	0f b7 c0             	movzwl %ax,%eax
801096b6:	83 ec 04             	sub    $0x4,%esp
801096b9:	53                   	push   %ebx
801096ba:	50                   	push   %eax
801096bb:	68 a3 bf 10 80       	push   $0x8010bfa3
801096c0:	e8 2f 6d ff ff       	call   801003f4 <cprintf>
801096c5:	83 c4 10             	add    $0x10,%esp
801096c8:	90                   	nop
801096c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801096cc:	c9                   	leave  
801096cd:	c3                   	ret    

801096ce <icmp_reply_pkt_create>:
801096ce:	55                   	push   %ebp
801096cf:	89 e5                	mov    %esp,%ebp
801096d1:	83 ec 28             	sub    $0x28,%esp
801096d4:	8b 45 08             	mov    0x8(%ebp),%eax
801096d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801096da:	8b 45 08             	mov    0x8(%ebp),%eax
801096dd:	83 c0 0e             	add    $0xe,%eax
801096e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801096e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e6:	0f b6 00             	movzbl (%eax),%eax
801096e9:	0f b6 c0             	movzbl %al,%eax
801096ec:	83 e0 0f             	and    $0xf,%eax
801096ef:	c1 e0 02             	shl    $0x2,%eax
801096f2:	89 c2                	mov    %eax,%edx
801096f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f7:	01 d0                	add    %edx,%eax
801096f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801096fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80109702:	8b 45 0c             	mov    0xc(%ebp),%eax
80109705:	83 c0 0e             	add    $0xe,%eax
80109708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010970b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010970e:	83 c0 14             	add    $0x14,%eax
80109711:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109714:	8b 45 10             	mov    0x10(%ebp),%eax
80109717:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
8010971d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109720:	8d 50 06             	lea    0x6(%eax),%edx
80109723:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109726:	83 ec 04             	sub    $0x4,%esp
80109729:	6a 06                	push   $0x6
8010972b:	52                   	push   %edx
8010972c:	50                   	push   %eax
8010972d:	e8 0c b3 ff ff       	call   80104a3e <memmove>
80109732:	83 c4 10             	add    $0x10,%esp
80109735:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109738:	83 c0 06             	add    $0x6,%eax
8010973b:	83 ec 04             	sub    $0x4,%esp
8010973e:	6a 06                	push   $0x6
80109740:	68 80 6e 19 80       	push   $0x80196e80
80109745:	50                   	push   %eax
80109746:	e8 f3 b2 ff ff       	call   80104a3e <memmove>
8010974b:	83 c4 10             	add    $0x10,%esp
8010974e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109751:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
80109755:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109758:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
8010975c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010975f:	c6 00 45             	movb   $0x45,(%eax)
80109762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109765:	c6 40 01 00          	movb   $0x0,0x1(%eax)
80109769:	83 ec 0c             	sub    $0xc,%esp
8010976c:	6a 54                	push   $0x54
8010976e:	e8 03 fd ff ff       	call   80109476 <H2N_ushort>
80109773:	83 c4 10             	add    $0x10,%esp
80109776:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109779:	66 89 42 02          	mov    %ax,0x2(%edx)
8010977d:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
80109784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109787:	66 89 50 04          	mov    %dx,0x4(%eax)
8010978b:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
80109792:	83 c0 01             	add    $0x1,%eax
80109795:	66 a3 60 71 19 80    	mov    %ax,0x80197160
8010979b:	83 ec 0c             	sub    $0xc,%esp
8010979e:	68 00 40 00 00       	push   $0x4000
801097a3:	e8 ce fc ff ff       	call   80109476 <H2N_ushort>
801097a8:	83 c4 10             	add    $0x10,%esp
801097ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097ae:	66 89 42 06          	mov    %ax,0x6(%edx)
801097b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097b5:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
801097b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097bc:	c6 40 09 01          	movb   $0x1,0x9(%eax)
801097c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097c3:	83 c0 0c             	add    $0xc,%eax
801097c6:	83 ec 04             	sub    $0x4,%esp
801097c9:	6a 04                	push   $0x4
801097cb:	68 e4 f4 10 80       	push   $0x8010f4e4
801097d0:	50                   	push   %eax
801097d1:	e8 68 b2 ff ff       	call   80104a3e <memmove>
801097d6:	83 c4 10             	add    $0x10,%esp
801097d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097dc:	8d 50 0c             	lea    0xc(%eax),%edx
801097df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097e2:	83 c0 10             	add    $0x10,%eax
801097e5:	83 ec 04             	sub    $0x4,%esp
801097e8:	6a 04                	push   $0x4
801097ea:	52                   	push   %edx
801097eb:	50                   	push   %eax
801097ec:	e8 4d b2 ff ff       	call   80104a3e <memmove>
801097f1:	83 c4 10             	add    $0x10,%esp
801097f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097f7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
801097fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109800:	83 ec 0c             	sub    $0xc,%esp
80109803:	50                   	push   %eax
80109804:	e8 6d fd ff ff       	call   80109576 <ipv4_chksum>
80109809:	83 c4 10             	add    $0x10,%esp
8010980c:	0f b7 c0             	movzwl %ax,%eax
8010980f:	83 ec 0c             	sub    $0xc,%esp
80109812:	50                   	push   %eax
80109813:	e8 5e fc ff ff       	call   80109476 <H2N_ushort>
80109818:	83 c4 10             	add    $0x10,%esp
8010981b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010981e:	66 89 42 0a          	mov    %ax,0xa(%edx)
80109822:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109825:	c6 00 00             	movb   $0x0,(%eax)
80109828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010982b:	c6 40 01 00          	movb   $0x0,0x1(%eax)
8010982f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109832:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109836:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109839:	66 89 50 04          	mov    %dx,0x4(%eax)
8010983d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109840:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109844:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109847:	66 89 50 06          	mov    %dx,0x6(%eax)
8010984b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010984e:	8d 50 08             	lea    0x8(%eax),%edx
80109851:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109854:	83 c0 08             	add    $0x8,%eax
80109857:	83 ec 04             	sub    $0x4,%esp
8010985a:	6a 08                	push   $0x8
8010985c:	52                   	push   %edx
8010985d:	50                   	push   %eax
8010985e:	e8 db b1 ff ff       	call   80104a3e <memmove>
80109863:	83 c4 10             	add    $0x10,%esp
80109866:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109869:	8d 50 10             	lea    0x10(%eax),%edx
8010986c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010986f:	83 c0 10             	add    $0x10,%eax
80109872:	83 ec 04             	sub    $0x4,%esp
80109875:	6a 30                	push   $0x30
80109877:	52                   	push   %edx
80109878:	50                   	push   %eax
80109879:	e8 c0 b1 ff ff       	call   80104a3e <memmove>
8010987e:	83 c4 10             	add    $0x10,%esp
80109881:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109884:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
8010988a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010988d:	83 ec 0c             	sub    $0xc,%esp
80109890:	50                   	push   %eax
80109891:	e8 1c 00 00 00       	call   801098b2 <icmp_chksum>
80109896:	83 c4 10             	add    $0x10,%esp
80109899:	0f b7 c0             	movzwl %ax,%eax
8010989c:	83 ec 0c             	sub    $0xc,%esp
8010989f:	50                   	push   %eax
801098a0:	e8 d1 fb ff ff       	call   80109476 <H2N_ushort>
801098a5:	83 c4 10             	add    $0x10,%esp
801098a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801098ab:	66 89 42 02          	mov    %ax,0x2(%edx)
801098af:	90                   	nop
801098b0:	c9                   	leave  
801098b1:	c3                   	ret    

801098b2 <icmp_chksum>:
801098b2:	55                   	push   %ebp
801098b3:	89 e5                	mov    %esp,%ebp
801098b5:	83 ec 10             	sub    $0x10,%esp
801098b8:	8b 45 08             	mov    0x8(%ebp),%eax
801098bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801098be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801098c5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801098cc:	eb 48                	jmp    80109916 <icmp_chksum+0x64>
801098ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098d1:	01 c0                	add    %eax,%eax
801098d3:	89 c2                	mov    %eax,%edx
801098d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d8:	01 d0                	add    %edx,%eax
801098da:	0f b6 00             	movzbl (%eax),%eax
801098dd:	0f b6 c0             	movzbl %al,%eax
801098e0:	c1 e0 08             	shl    $0x8,%eax
801098e3:	89 c2                	mov    %eax,%edx
801098e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098e8:	01 c0                	add    %eax,%eax
801098ea:	8d 48 01             	lea    0x1(%eax),%ecx
801098ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f0:	01 c8                	add    %ecx,%eax
801098f2:	0f b6 00             	movzbl (%eax),%eax
801098f5:	0f b6 c0             	movzbl %al,%eax
801098f8:	01 d0                	add    %edx,%eax
801098fa:	01 45 fc             	add    %eax,-0x4(%ebp)
801098fd:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109904:	76 0c                	jbe    80109912 <icmp_chksum+0x60>
80109906:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109909:	0f b7 c0             	movzwl %ax,%eax
8010990c:	83 c0 01             	add    $0x1,%eax
8010990f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80109912:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109916:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010991a:	7e b2                	jle    801098ce <icmp_chksum+0x1c>
8010991c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010991f:	f7 d0                	not    %eax
80109921:	c9                   	leave  
80109922:	c3                   	ret    

80109923 <tcp_proc>:
80109923:	55                   	push   %ebp
80109924:	89 e5                	mov    %esp,%ebp
80109926:	83 ec 38             	sub    $0x38,%esp
80109929:	8b 45 08             	mov    0x8(%ebp),%eax
8010992c:	83 c0 0e             	add    $0xe,%eax
8010992f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109935:	0f b6 00             	movzbl (%eax),%eax
80109938:	0f b6 c0             	movzbl %al,%eax
8010993b:	83 e0 0f             	and    $0xf,%eax
8010993e:	c1 e0 02             	shl    $0x2,%eax
80109941:	89 c2                	mov    %eax,%edx
80109943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109946:	01 d0                	add    %edx,%eax
80109948:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010994b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010994e:	83 c0 14             	add    $0x14,%eax
80109951:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109954:	e8 47 8e ff ff       	call   801027a0 <kalloc>
80109959:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010995c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109966:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010996a:	0f b6 c0             	movzbl %al,%eax
8010996d:	83 e0 02             	and    $0x2,%eax
80109970:	85 c0                	test   %eax,%eax
80109972:	74 3d                	je     801099b1 <tcp_proc+0x8e>
80109974:	83 ec 0c             	sub    $0xc,%esp
80109977:	6a 00                	push   $0x0
80109979:	6a 12                	push   $0x12
8010997b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010997e:	50                   	push   %eax
8010997f:	ff 75 e8             	push   -0x18(%ebp)
80109982:	ff 75 08             	push   0x8(%ebp)
80109985:	e8 a2 01 00 00       	call   80109b2c <tcp_pkt_create>
8010998a:	83 c4 20             	add    $0x20,%esp
8010998d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109990:	83 ec 08             	sub    $0x8,%esp
80109993:	50                   	push   %eax
80109994:	ff 75 e8             	push   -0x18(%ebp)
80109997:	e8 61 f1 ff ff       	call   80108afd <i8254_send>
8010999c:	83 c4 10             	add    $0x10,%esp
8010999f:	a1 64 71 19 80       	mov    0x80197164,%eax
801099a4:	83 c0 01             	add    $0x1,%eax
801099a7:	a3 64 71 19 80       	mov    %eax,0x80197164
801099ac:	e9 69 01 00 00       	jmp    80109b1a <tcp_proc+0x1f7>
801099b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099b4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099b8:	3c 18                	cmp    $0x18,%al
801099ba:	0f 85 10 01 00 00    	jne    80109ad0 <tcp_proc+0x1ad>
801099c0:	83 ec 04             	sub    $0x4,%esp
801099c3:	6a 03                	push   $0x3
801099c5:	68 be bf 10 80       	push   $0x8010bfbe
801099ca:	ff 75 ec             	push   -0x14(%ebp)
801099cd:	e8 14 b0 ff ff       	call   801049e6 <memcmp>
801099d2:	83 c4 10             	add    $0x10,%esp
801099d5:	85 c0                	test   %eax,%eax
801099d7:	74 74                	je     80109a4d <tcp_proc+0x12a>
801099d9:	83 ec 0c             	sub    $0xc,%esp
801099dc:	68 c2 bf 10 80       	push   $0x8010bfc2
801099e1:	e8 0e 6a ff ff       	call   801003f4 <cprintf>
801099e6:	83 c4 10             	add    $0x10,%esp
801099e9:	83 ec 0c             	sub    $0xc,%esp
801099ec:	6a 00                	push   $0x0
801099ee:	6a 10                	push   $0x10
801099f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099f3:	50                   	push   %eax
801099f4:	ff 75 e8             	push   -0x18(%ebp)
801099f7:	ff 75 08             	push   0x8(%ebp)
801099fa:	e8 2d 01 00 00       	call   80109b2c <tcp_pkt_create>
801099ff:	83 c4 20             	add    $0x20,%esp
80109a02:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a05:	83 ec 08             	sub    $0x8,%esp
80109a08:	50                   	push   %eax
80109a09:	ff 75 e8             	push   -0x18(%ebp)
80109a0c:	e8 ec f0 ff ff       	call   80108afd <i8254_send>
80109a11:	83 c4 10             	add    $0x10,%esp
80109a14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a17:	83 c0 36             	add    $0x36,%eax
80109a1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109a1d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109a20:	50                   	push   %eax
80109a21:	ff 75 e0             	push   -0x20(%ebp)
80109a24:	6a 00                	push   $0x0
80109a26:	6a 00                	push   $0x0
80109a28:	e8 5a 04 00 00       	call   80109e87 <http_proc>
80109a2d:	83 c4 10             	add    $0x10,%esp
80109a30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109a33:	83 ec 0c             	sub    $0xc,%esp
80109a36:	50                   	push   %eax
80109a37:	6a 18                	push   $0x18
80109a39:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a3c:	50                   	push   %eax
80109a3d:	ff 75 e8             	push   -0x18(%ebp)
80109a40:	ff 75 08             	push   0x8(%ebp)
80109a43:	e8 e4 00 00 00       	call   80109b2c <tcp_pkt_create>
80109a48:	83 c4 20             	add    $0x20,%esp
80109a4b:	eb 62                	jmp    80109aaf <tcp_proc+0x18c>
80109a4d:	83 ec 0c             	sub    $0xc,%esp
80109a50:	6a 00                	push   $0x0
80109a52:	6a 10                	push   $0x10
80109a54:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a57:	50                   	push   %eax
80109a58:	ff 75 e8             	push   -0x18(%ebp)
80109a5b:	ff 75 08             	push   0x8(%ebp)
80109a5e:	e8 c9 00 00 00       	call   80109b2c <tcp_pkt_create>
80109a63:	83 c4 20             	add    $0x20,%esp
80109a66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a69:	83 ec 08             	sub    $0x8,%esp
80109a6c:	50                   	push   %eax
80109a6d:	ff 75 e8             	push   -0x18(%ebp)
80109a70:	e8 88 f0 ff ff       	call   80108afd <i8254_send>
80109a75:	83 c4 10             	add    $0x10,%esp
80109a78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a7b:	83 c0 36             	add    $0x36,%eax
80109a7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109a81:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a84:	50                   	push   %eax
80109a85:	ff 75 e4             	push   -0x1c(%ebp)
80109a88:	6a 00                	push   $0x0
80109a8a:	6a 00                	push   $0x0
80109a8c:	e8 f6 03 00 00       	call   80109e87 <http_proc>
80109a91:	83 c4 10             	add    $0x10,%esp
80109a94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a97:	83 ec 0c             	sub    $0xc,%esp
80109a9a:	50                   	push   %eax
80109a9b:	6a 18                	push   $0x18
80109a9d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109aa0:	50                   	push   %eax
80109aa1:	ff 75 e8             	push   -0x18(%ebp)
80109aa4:	ff 75 08             	push   0x8(%ebp)
80109aa7:	e8 80 00 00 00       	call   80109b2c <tcp_pkt_create>
80109aac:	83 c4 20             	add    $0x20,%esp
80109aaf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ab2:	83 ec 08             	sub    $0x8,%esp
80109ab5:	50                   	push   %eax
80109ab6:	ff 75 e8             	push   -0x18(%ebp)
80109ab9:	e8 3f f0 ff ff       	call   80108afd <i8254_send>
80109abe:	83 c4 10             	add    $0x10,%esp
80109ac1:	a1 64 71 19 80       	mov    0x80197164,%eax
80109ac6:	83 c0 01             	add    $0x1,%eax
80109ac9:	a3 64 71 19 80       	mov    %eax,0x80197164
80109ace:	eb 4a                	jmp    80109b1a <tcp_proc+0x1f7>
80109ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ad7:	3c 10                	cmp    $0x10,%al
80109ad9:	75 3f                	jne    80109b1a <tcp_proc+0x1f7>
80109adb:	a1 68 71 19 80       	mov    0x80197168,%eax
80109ae0:	83 f8 01             	cmp    $0x1,%eax
80109ae3:	75 35                	jne    80109b1a <tcp_proc+0x1f7>
80109ae5:	83 ec 0c             	sub    $0xc,%esp
80109ae8:	6a 00                	push   $0x0
80109aea:	6a 01                	push   $0x1
80109aec:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109aef:	50                   	push   %eax
80109af0:	ff 75 e8             	push   -0x18(%ebp)
80109af3:	ff 75 08             	push   0x8(%ebp)
80109af6:	e8 31 00 00 00       	call   80109b2c <tcp_pkt_create>
80109afb:	83 c4 20             	add    $0x20,%esp
80109afe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b01:	83 ec 08             	sub    $0x8,%esp
80109b04:	50                   	push   %eax
80109b05:	ff 75 e8             	push   -0x18(%ebp)
80109b08:	e8 f0 ef ff ff       	call   80108afd <i8254_send>
80109b0d:	83 c4 10             	add    $0x10,%esp
80109b10:	c7 05 68 71 19 80 00 	movl   $0x0,0x80197168
80109b17:	00 00 00 
80109b1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b1d:	83 ec 0c             	sub    $0xc,%esp
80109b20:	50                   	push   %eax
80109b21:	e8 e0 8b ff ff       	call   80102706 <kfree>
80109b26:	83 c4 10             	add    $0x10,%esp
80109b29:	90                   	nop
80109b2a:	c9                   	leave  
80109b2b:	c3                   	ret    

80109b2c <tcp_pkt_create>:
80109b2c:	55                   	push   %ebp
80109b2d:	89 e5                	mov    %esp,%ebp
80109b2f:	83 ec 28             	sub    $0x28,%esp
80109b32:	8b 45 08             	mov    0x8(%ebp),%eax
80109b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109b38:	8b 45 08             	mov    0x8(%ebp),%eax
80109b3b:	83 c0 0e             	add    $0xe,%eax
80109b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b44:	0f b6 00             	movzbl (%eax),%eax
80109b47:	0f b6 c0             	movzbl %al,%eax
80109b4a:	83 e0 0f             	and    $0xf,%eax
80109b4d:	c1 e0 02             	shl    $0x2,%eax
80109b50:	89 c2                	mov    %eax,%edx
80109b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b55:	01 d0                	add    %edx,%eax
80109b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80109b60:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b63:	83 c0 0e             	add    $0xe,%eax
80109b66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109b69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6c:	83 c0 14             	add    $0x14,%eax
80109b6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109b72:	8b 45 18             	mov    0x18(%ebp),%eax
80109b75:	8d 50 36             	lea    0x36(%eax),%edx
80109b78:	8b 45 10             	mov    0x10(%ebp),%eax
80109b7b:	89 10                	mov    %edx,(%eax)
80109b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b80:	8d 50 06             	lea    0x6(%eax),%edx
80109b83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b86:	83 ec 04             	sub    $0x4,%esp
80109b89:	6a 06                	push   $0x6
80109b8b:	52                   	push   %edx
80109b8c:	50                   	push   %eax
80109b8d:	e8 ac ae ff ff       	call   80104a3e <memmove>
80109b92:	83 c4 10             	add    $0x10,%esp
80109b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b98:	83 c0 06             	add    $0x6,%eax
80109b9b:	83 ec 04             	sub    $0x4,%esp
80109b9e:	6a 06                	push   $0x6
80109ba0:	68 80 6e 19 80       	push   $0x80196e80
80109ba5:	50                   	push   %eax
80109ba6:	e8 93 ae ff ff       	call   80104a3e <memmove>
80109bab:	83 c4 10             	add    $0x10,%esp
80109bae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bb1:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
80109bb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bb8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
80109bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bbf:	c6 00 45             	movb   $0x45,(%eax)
80109bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc5:	c6 40 01 00          	movb   $0x0,0x1(%eax)
80109bc9:	8b 45 18             	mov    0x18(%ebp),%eax
80109bcc:	83 c0 28             	add    $0x28,%eax
80109bcf:	0f b7 c0             	movzwl %ax,%eax
80109bd2:	83 ec 0c             	sub    $0xc,%esp
80109bd5:	50                   	push   %eax
80109bd6:	e8 9b f8 ff ff       	call   80109476 <H2N_ushort>
80109bdb:	83 c4 10             	add    $0x10,%esp
80109bde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109be1:	66 89 42 02          	mov    %ax,0x2(%edx)
80109be5:	0f b7 15 60 71 19 80 	movzwl 0x80197160,%edx
80109bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bef:	66 89 50 04          	mov    %dx,0x4(%eax)
80109bf3:	0f b7 05 60 71 19 80 	movzwl 0x80197160,%eax
80109bfa:	83 c0 01             	add    $0x1,%eax
80109bfd:	66 a3 60 71 19 80    	mov    %ax,0x80197160
80109c03:	83 ec 0c             	sub    $0xc,%esp
80109c06:	6a 00                	push   $0x0
80109c08:	e8 69 f8 ff ff       	call   80109476 <H2N_ushort>
80109c0d:	83 c4 10             	add    $0x10,%esp
80109c10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c13:	66 89 42 06          	mov    %ax,0x6(%edx)
80109c17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c1a:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
80109c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c21:	c6 40 09 06          	movb   $0x6,0x9(%eax)
80109c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c28:	83 c0 0c             	add    $0xc,%eax
80109c2b:	83 ec 04             	sub    $0x4,%esp
80109c2e:	6a 04                	push   $0x4
80109c30:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c35:	50                   	push   %eax
80109c36:	e8 03 ae ff ff       	call   80104a3e <memmove>
80109c3b:	83 c4 10             	add    $0x10,%esp
80109c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c41:	8d 50 0c             	lea    0xc(%eax),%edx
80109c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c47:	83 c0 10             	add    $0x10,%eax
80109c4a:	83 ec 04             	sub    $0x4,%esp
80109c4d:	6a 04                	push   $0x4
80109c4f:	52                   	push   %edx
80109c50:	50                   	push   %eax
80109c51:	e8 e8 ad ff ff       	call   80104a3e <memmove>
80109c56:	83 c4 10             	add    $0x10,%esp
80109c59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c5c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
80109c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c65:	83 ec 0c             	sub    $0xc,%esp
80109c68:	50                   	push   %eax
80109c69:	e8 08 f9 ff ff       	call   80109576 <ipv4_chksum>
80109c6e:	83 c4 10             	add    $0x10,%esp
80109c71:	0f b7 c0             	movzwl %ax,%eax
80109c74:	83 ec 0c             	sub    $0xc,%esp
80109c77:	50                   	push   %eax
80109c78:	e8 f9 f7 ff ff       	call   80109476 <H2N_ushort>
80109c7d:	83 c4 10             	add    $0x10,%esp
80109c80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c83:	66 89 42 0a          	mov    %ax,0xa(%edx)
80109c87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c8a:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c91:	66 89 10             	mov    %dx,(%eax)
80109c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c97:	0f b7 10             	movzwl (%eax),%edx
80109c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c9d:	66 89 50 02          	mov    %dx,0x2(%eax)
80109ca1:	a1 64 71 19 80       	mov    0x80197164,%eax
80109ca6:	83 ec 0c             	sub    $0xc,%esp
80109ca9:	50                   	push   %eax
80109caa:	e8 e9 f7 ff ff       	call   80109498 <H2N_uint>
80109caf:	83 c4 10             	add    $0x10,%esp
80109cb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109cb5:	89 42 04             	mov    %eax,0x4(%edx)
80109cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cbb:	8b 40 04             	mov    0x4(%eax),%eax
80109cbe:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cc7:	89 50 08             	mov    %edx,0x8(%eax)
80109cca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ccd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
80109cd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cd4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
80109cd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cdb:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
80109cdf:	8b 45 14             	mov    0x14(%ebp),%eax
80109ce2:	89 c2                	mov    %eax,%edx
80109ce4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ce7:	88 50 0d             	mov    %dl,0xd(%eax)
80109cea:	83 ec 0c             	sub    $0xc,%esp
80109ced:	68 90 38 00 00       	push   $0x3890
80109cf2:	e8 7f f7 ff ff       	call   80109476 <H2N_ushort>
80109cf7:	83 c4 10             	add    $0x10,%esp
80109cfa:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109cfd:	66 89 42 0e          	mov    %ax,0xe(%edx)
80109d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d04:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
80109d0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d0d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
80109d13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d16:	83 ec 0c             	sub    $0xc,%esp
80109d19:	50                   	push   %eax
80109d1a:	e8 1f 00 00 00       	call   80109d3e <tcp_chksum>
80109d1f:	83 c4 10             	add    $0x10,%esp
80109d22:	83 c0 08             	add    $0x8,%eax
80109d25:	0f b7 c0             	movzwl %ax,%eax
80109d28:	83 ec 0c             	sub    $0xc,%esp
80109d2b:	50                   	push   %eax
80109d2c:	e8 45 f7 ff ff       	call   80109476 <H2N_ushort>
80109d31:	83 c4 10             	add    $0x10,%esp
80109d34:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d37:	66 89 42 10          	mov    %ax,0x10(%edx)
80109d3b:	90                   	nop
80109d3c:	c9                   	leave  
80109d3d:	c3                   	ret    

80109d3e <tcp_chksum>:
80109d3e:	55                   	push   %ebp
80109d3f:	89 e5                	mov    %esp,%ebp
80109d41:	83 ec 38             	sub    $0x38,%esp
80109d44:	8b 45 08             	mov    0x8(%ebp),%eax
80109d47:	89 45 e8             	mov    %eax,-0x18(%ebp)
80109d4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d4d:	83 c0 14             	add    $0x14,%eax
80109d50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80109d53:	83 ec 04             	sub    $0x4,%esp
80109d56:	6a 04                	push   $0x4
80109d58:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d5d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d60:	50                   	push   %eax
80109d61:	e8 d8 ac ff ff       	call   80104a3e <memmove>
80109d66:	83 c4 10             	add    $0x10,%esp
80109d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d6c:	83 c0 0c             	add    $0xc,%eax
80109d6f:	83 ec 04             	sub    $0x4,%esp
80109d72:	6a 04                	push   $0x4
80109d74:	50                   	push   %eax
80109d75:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d78:	83 c0 04             	add    $0x4,%eax
80109d7b:	50                   	push   %eax
80109d7c:	e8 bd ac ff ff       	call   80104a3e <memmove>
80109d81:	83 c4 10             	add    $0x10,%esp
80109d84:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
80109d88:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
80109d8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d8f:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d93:	0f b7 c0             	movzwl %ax,%eax
80109d96:	83 ec 0c             	sub    $0xc,%esp
80109d99:	50                   	push   %eax
80109d9a:	e8 b5 f6 ff ff       	call   80109454 <N2H_ushort>
80109d9f:	83 c4 10             	add    $0x10,%esp
80109da2:	83 e8 14             	sub    $0x14,%eax
80109da5:	0f b7 c0             	movzwl %ax,%eax
80109da8:	83 ec 0c             	sub    $0xc,%esp
80109dab:	50                   	push   %eax
80109dac:	e8 c5 f6 ff ff       	call   80109476 <H2N_ushort>
80109db1:	83 c4 10             	add    $0x10,%esp
80109db4:	66 89 45 de          	mov    %ax,-0x22(%ebp)
80109db8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109dbf:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109dc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109dc5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109dcc:	eb 33                	jmp    80109e01 <tcp_chksum+0xc3>
80109dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dd1:	01 c0                	add    %eax,%eax
80109dd3:	89 c2                	mov    %eax,%edx
80109dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd8:	01 d0                	add    %edx,%eax
80109dda:	0f b6 00             	movzbl (%eax),%eax
80109ddd:	0f b6 c0             	movzbl %al,%eax
80109de0:	c1 e0 08             	shl    $0x8,%eax
80109de3:	89 c2                	mov    %eax,%edx
80109de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de8:	01 c0                	add    %eax,%eax
80109dea:	8d 48 01             	lea    0x1(%eax),%ecx
80109ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df0:	01 c8                	add    %ecx,%eax
80109df2:	0f b6 00             	movzbl (%eax),%eax
80109df5:	0f b6 c0             	movzbl %al,%eax
80109df8:	01 d0                	add    %edx,%eax
80109dfa:	01 45 f4             	add    %eax,-0xc(%ebp)
80109dfd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e01:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109e05:	7e c7                	jle    80109dce <tcp_chksum+0x90>
80109e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109e0d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109e14:	eb 33                	jmp    80109e49 <tcp_chksum+0x10b>
80109e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e19:	01 c0                	add    %eax,%eax
80109e1b:	89 c2                	mov    %eax,%edx
80109e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e20:	01 d0                	add    %edx,%eax
80109e22:	0f b6 00             	movzbl (%eax),%eax
80109e25:	0f b6 c0             	movzbl %al,%eax
80109e28:	c1 e0 08             	shl    $0x8,%eax
80109e2b:	89 c2                	mov    %eax,%edx
80109e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e30:	01 c0                	add    %eax,%eax
80109e32:	8d 48 01             	lea    0x1(%eax),%ecx
80109e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e38:	01 c8                	add    %ecx,%eax
80109e3a:	0f b6 00             	movzbl (%eax),%eax
80109e3d:	0f b6 c0             	movzbl %al,%eax
80109e40:	01 d0                	add    %edx,%eax
80109e42:	01 45 f4             	add    %eax,-0xc(%ebp)
80109e45:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109e49:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109e4d:	0f b7 c0             	movzwl %ax,%eax
80109e50:	83 ec 0c             	sub    $0xc,%esp
80109e53:	50                   	push   %eax
80109e54:	e8 fb f5 ff ff       	call   80109454 <N2H_ushort>
80109e59:	83 c4 10             	add    $0x10,%esp
80109e5c:	66 d1 e8             	shr    %ax
80109e5f:	0f b7 c0             	movzwl %ax,%eax
80109e62:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109e65:	7c af                	jl     80109e16 <tcp_chksum+0xd8>
80109e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e6a:	c1 e8 10             	shr    $0x10,%eax
80109e6d:	01 45 f4             	add    %eax,-0xc(%ebp)
80109e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e73:	f7 d0                	not    %eax
80109e75:	c9                   	leave  
80109e76:	c3                   	ret    

80109e77 <tcp_fin>:
80109e77:	55                   	push   %ebp
80109e78:	89 e5                	mov    %esp,%ebp
80109e7a:	c7 05 68 71 19 80 01 	movl   $0x1,0x80197168
80109e81:	00 00 00 
80109e84:	90                   	nop
80109e85:	5d                   	pop    %ebp
80109e86:	c3                   	ret    

80109e87 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e87:	55                   	push   %ebp
80109e88:	89 e5                	mov    %esp,%ebp
80109e8a:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e8d:	8b 45 10             	mov    0x10(%ebp),%eax
80109e90:	83 ec 04             	sub    $0x4,%esp
80109e93:	6a 00                	push   $0x0
80109e95:	68 cb bf 10 80       	push   $0x8010bfcb
80109e9a:	50                   	push   %eax
80109e9b:	e8 65 00 00 00       	call   80109f05 <http_strcpy>
80109ea0:	83 c4 10             	add    $0x10,%esp
80109ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109ea6:	8b 45 10             	mov    0x10(%ebp),%eax
80109ea9:	83 ec 04             	sub    $0x4,%esp
80109eac:	ff 75 f4             	push   -0xc(%ebp)
80109eaf:	68 de bf 10 80       	push   $0x8010bfde
80109eb4:	50                   	push   %eax
80109eb5:	e8 4b 00 00 00       	call   80109f05 <http_strcpy>
80109eba:	83 c4 10             	add    $0x10,%esp
80109ebd:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109ec0:	8b 45 10             	mov    0x10(%ebp),%eax
80109ec3:	83 ec 04             	sub    $0x4,%esp
80109ec6:	ff 75 f4             	push   -0xc(%ebp)
80109ec9:	68 f9 bf 10 80       	push   $0x8010bff9
80109ece:	50                   	push   %eax
80109ecf:	e8 31 00 00 00       	call   80109f05 <http_strcpy>
80109ed4:	83 c4 10             	add    $0x10,%esp
80109ed7:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109edd:	83 e0 01             	and    $0x1,%eax
80109ee0:	85 c0                	test   %eax,%eax
80109ee2:	74 11                	je     80109ef5 <http_proc+0x6e>
    char *payload = (char *)send;
80109ee4:	8b 45 10             	mov    0x10(%ebp),%eax
80109ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109eea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef0:	01 d0                	add    %edx,%eax
80109ef2:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ef8:	8b 45 14             	mov    0x14(%ebp),%eax
80109efb:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109efd:	e8 75 ff ff ff       	call   80109e77 <tcp_fin>
}
80109f02:	90                   	nop
80109f03:	c9                   	leave  
80109f04:	c3                   	ret    

80109f05 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109f05:	55                   	push   %ebp
80109f06:	89 e5                	mov    %esp,%ebp
80109f08:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109f0b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109f12:	eb 20                	jmp    80109f34 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109f14:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f17:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f1a:	01 d0                	add    %edx,%eax
80109f1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109f1f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f22:	01 ca                	add    %ecx,%edx
80109f24:	89 d1                	mov    %edx,%ecx
80109f26:	8b 55 08             	mov    0x8(%ebp),%edx
80109f29:	01 ca                	add    %ecx,%edx
80109f2b:	0f b6 00             	movzbl (%eax),%eax
80109f2e:	88 02                	mov    %al,(%edx)
    i++;
80109f30:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109f34:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f3a:	01 d0                	add    %edx,%eax
80109f3c:	0f b6 00             	movzbl (%eax),%eax
80109f3f:	84 c0                	test   %al,%al
80109f41:	75 d1                	jne    80109f14 <http_strcpy+0xf>
  }
  return i;
80109f43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109f46:	c9                   	leave  
80109f47:	c3                   	ret    

80109f48 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109f48:	55                   	push   %ebp
80109f49:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109f4b:	c7 05 70 71 19 80 a2 	movl   $0x8010f5a2,0x80197170
80109f52:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109f55:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109f5a:	c1 e8 09             	shr    $0x9,%eax
80109f5d:	a3 6c 71 19 80       	mov    %eax,0x8019716c
}
80109f62:	90                   	nop
80109f63:	5d                   	pop    %ebp
80109f64:	c3                   	ret    

80109f65 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109f65:	55                   	push   %ebp
80109f66:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f68:	90                   	nop
80109f69:	5d                   	pop    %ebp
80109f6a:	c3                   	ret    

80109f6b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f6b:	55                   	push   %ebp
80109f6c:	89 e5                	mov    %esp,%ebp
80109f6e:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f71:	8b 45 08             	mov    0x8(%ebp),%eax
80109f74:	83 c0 0c             	add    $0xc,%eax
80109f77:	83 ec 0c             	sub    $0xc,%esp
80109f7a:	50                   	push   %eax
80109f7b:	e8 f8 a6 ff ff       	call   80104678 <holdingsleep>
80109f80:	83 c4 10             	add    $0x10,%esp
80109f83:	85 c0                	test   %eax,%eax
80109f85:	75 0d                	jne    80109f94 <iderw+0x29>
    panic("iderw: buf not locked");
80109f87:	83 ec 0c             	sub    $0xc,%esp
80109f8a:	68 0a c0 10 80       	push   $0x8010c00a
80109f8f:	e8 15 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f94:	8b 45 08             	mov    0x8(%ebp),%eax
80109f97:	8b 00                	mov    (%eax),%eax
80109f99:	83 e0 06             	and    $0x6,%eax
80109f9c:	83 f8 02             	cmp    $0x2,%eax
80109f9f:	75 0d                	jne    80109fae <iderw+0x43>
    panic("iderw: nothing to do");
80109fa1:	83 ec 0c             	sub    $0xc,%esp
80109fa4:	68 20 c0 10 80       	push   $0x8010c020
80109fa9:	e8 fb 65 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109fae:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb1:	8b 40 04             	mov    0x4(%eax),%eax
80109fb4:	83 f8 01             	cmp    $0x1,%eax
80109fb7:	74 0d                	je     80109fc6 <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109fb9:	83 ec 0c             	sub    $0xc,%esp
80109fbc:	68 35 c0 10 80       	push   $0x8010c035
80109fc1:	e8 e3 65 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc9:	8b 40 08             	mov    0x8(%eax),%eax
80109fcc:	8b 15 6c 71 19 80    	mov    0x8019716c,%edx
80109fd2:	39 d0                	cmp    %edx,%eax
80109fd4:	72 0d                	jb     80109fe3 <iderw+0x78>
    panic("iderw: block out of range");
80109fd6:	83 ec 0c             	sub    $0xc,%esp
80109fd9:	68 53 c0 10 80       	push   $0x8010c053
80109fde:	e8 c6 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109fe3:	8b 15 70 71 19 80    	mov    0x80197170,%edx
80109fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fec:	8b 40 08             	mov    0x8(%eax),%eax
80109fef:	c1 e0 09             	shl    $0x9,%eax
80109ff2:	01 d0                	add    %edx,%eax
80109ff4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80109ffa:	8b 00                	mov    (%eax),%eax
80109ffc:	83 e0 04             	and    $0x4,%eax
80109fff:	85 c0                	test   %eax,%eax
8010a001:	74 2b                	je     8010a02e <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a003:	8b 45 08             	mov    0x8(%ebp),%eax
8010a006:	8b 00                	mov    (%eax),%eax
8010a008:	83 e0 fb             	and    $0xfffffffb,%eax
8010a00b:	89 c2                	mov    %eax,%edx
8010a00d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a010:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a012:	8b 45 08             	mov    0x8(%ebp),%eax
8010a015:	83 c0 5c             	add    $0x5c,%eax
8010a018:	83 ec 04             	sub    $0x4,%esp
8010a01b:	68 00 02 00 00       	push   $0x200
8010a020:	50                   	push   %eax
8010a021:	ff 75 f4             	push   -0xc(%ebp)
8010a024:	e8 15 aa ff ff       	call   80104a3e <memmove>
8010a029:	83 c4 10             	add    $0x10,%esp
8010a02c:	eb 1a                	jmp    8010a048 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a02e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a031:	83 c0 5c             	add    $0x5c,%eax
8010a034:	83 ec 04             	sub    $0x4,%esp
8010a037:	68 00 02 00 00       	push   $0x200
8010a03c:	ff 75 f4             	push   -0xc(%ebp)
8010a03f:	50                   	push   %eax
8010a040:	e8 f9 a9 ff ff       	call   80104a3e <memmove>
8010a045:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a048:	8b 45 08             	mov    0x8(%ebp),%eax
8010a04b:	8b 00                	mov    (%eax),%eax
8010a04d:	83 c8 02             	or     $0x2,%eax
8010a050:	89 c2                	mov    %eax,%edx
8010a052:	8b 45 08             	mov    0x8(%ebp),%eax
8010a055:	89 10                	mov    %edx,(%eax)
}
8010a057:	90                   	nop
8010a058:	c9                   	leave  
8010a059:	c3                   	ret    
