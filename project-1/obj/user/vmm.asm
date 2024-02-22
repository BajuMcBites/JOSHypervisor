
obj/user/vmm:     file format elf64-x86-64


Disassembly of section .text:

0000000000800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	movabs $USTACKTOP, %rax
  800020:	48 b8 00 e0 7f ef 00 	movabs $0xef7fe000,%rax
  800027:	00 00 00 
	cmpq %rax,%rsp
  80002a:	48 39 c4             	cmp    %rax,%rsp
	jne args_exist
  80002d:	75 04                	jne    800033 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushq $0
  80002f:	6a 00                	pushq  $0x0
	pushq $0
  800031:	6a 00                	pushq  $0x0

0000000000800033 <args_exist>:

args_exist:
	movq 8(%rsp), %rsi
  800033:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
	movq (%rsp), %rdi
  800038:	48 8b 3c 24          	mov    (%rsp),%rdi
	call libmain
  80003c:	e8 4d 06 00 00       	callq  80068e <libmain>
1:	jmp 1b
  800041:	eb fe                	jmp    800041 <args_exist+0xe>

0000000000800043 <map_in_guest>:
// Return 0 on success, <0 on failure.
//
// Hint: Call sys_ept_map() for mapping page. 
static int
map_in_guest( envid_t guest, uintptr_t gpa, size_t memsz, 
	      int fd, size_t filesz, off_t fileoffset ) {
  800043:	55                   	push   %rbp
  800044:	48 89 e5             	mov    %rsp,%rbp
  800047:	48 83 ec 60          	sub    $0x60,%rsp
  80004b:	89 7d cc             	mov    %edi,-0x34(%rbp)
  80004e:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800052:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800056:	89 4d c8             	mov    %ecx,-0x38(%rbp)
  800059:	4c 89 45 b0          	mov    %r8,-0x50(%rbp)
  80005d:	44 89 4d ac          	mov    %r9d,-0x54(%rbp)
		
	if (PGOFF(gpa) != 0) ROUNDDOWN(gpa, PGSIZE);
  800061:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800065:	25 ff 0f 00 00       	and    $0xfff,%eax
  80006a:	48 85 c0             	test   %rax,%rax
  80006d:	74 08                	je     800077 <map_in_guest+0x34>
  80006f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800073:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	int i;
    for (i = 0; i < memsz; i += PGSIZE) 
  800077:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80007e:	e9 8f 01 00 00       	jmpq   800212 <map_in_guest+0x1cf>
    {
    	if (i < filesz)
  800083:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800086:	48 98                	cltq   
  800088:	48 3b 45 b0          	cmp    -0x50(%rbp),%rax
  80008c:	0f 83 bc 00 00 00    	jae    80014e <map_in_guest+0x10b>
    	{
		    int err = sys_page_alloc(thisenv->env_id, (void*) UTEMP, PTE_U | PTE_W | PTE_P);
  800092:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  800099:	00 00 00 
  80009c:	48 8b 00             	mov    (%rax),%rax
  80009f:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8000a5:	ba 07 00 00 00       	mov    $0x7,%edx
  8000aa:	be 00 00 40 00       	mov    $0x400000,%esi
  8000af:	89 c7                	mov    %eax,%edi
  8000b1:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  8000b8:	00 00 00 
  8000bb:	ff d0                	callq  *%rax
  8000bd:	89 45 ec             	mov    %eax,-0x14(%rbp)
			if (err < 0) return err;
  8000c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  8000c4:	79 08                	jns    8000ce <map_in_guest+0x8b>
  8000c6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8000c9:	e9 58 01 00 00       	jmpq   800226 <map_in_guest+0x1e3>

		    err = seek(fd, fileoffset + i);
  8000ce:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8000d1:	8b 55 ac             	mov    -0x54(%rbp),%edx
  8000d4:	01 c2                	add    %eax,%edx
  8000d6:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	48 b8 51 29 80 00 00 	movabs $0x802951,%rax
  8000e4:	00 00 00 
  8000e7:	ff d0                	callq  *%rax
  8000e9:	89 45 ec             	mov    %eax,-0x14(%rbp)
			if (err < 0) return err;
  8000ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  8000f0:	79 08                	jns    8000fa <map_in_guest+0xb7>
  8000f2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8000f5:	e9 2c 01 00 00       	jmpq   800226 <map_in_guest+0x1e3>

		    err = readn(fd, UTEMP, MIN(PGSIZE, filesz-i));
  8000fa:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%rbp)
  800101:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800104:	48 98                	cltq   
  800106:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80010a:	48 29 c2             	sub    %rax,%rdx
  80010d:	48 89 d0             	mov    %rdx,%rax
  800110:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  800114:	8b 45 e8             	mov    -0x18(%rbp),%eax
  800117:	48 63 d0             	movslq %eax,%rdx
  80011a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80011e:	48 39 c2             	cmp    %rax,%rdx
  800121:	48 0f 47 d0          	cmova  %rax,%rdx
  800125:	8b 45 c8             	mov    -0x38(%rbp),%eax
  800128:	be 00 00 40 00       	mov    $0x400000,%esi
  80012d:	89 c7                	mov    %eax,%edi
  80012f:	48 b8 08 28 80 00 00 	movabs $0x802808,%rax
  800136:	00 00 00 
  800139:	ff d0                	callq  *%rax
  80013b:	89 45 ec             	mov    %eax,-0x14(%rbp)
			if (err < 0) return err; 
  80013e:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  800142:	79 08                	jns    80014c <map_in_guest+0x109>
  800144:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800147:	e9 da 00 00 00       	jmpq   800226 <map_in_guest+0x1e3>
  80014c:	eb 3c                	jmp    80018a <map_in_guest+0x147>
    	}
    	else
    	{
			int err = sys_page_alloc(thisenv->env_id, (void*) UTEMP, __EPTE_FULL);
  80014e:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  800155:	00 00 00 
  800158:	48 8b 00             	mov    (%rax),%rax
  80015b:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  800161:	ba 07 00 00 00       	mov    $0x7,%edx
  800166:	be 00 00 40 00       	mov    $0x400000,%esi
  80016b:	89 c7                	mov    %eax,%edi
  80016d:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  800174:	00 00 00 
  800177:	ff d0                	callq  *%rax
  800179:	89 45 dc             	mov    %eax,-0x24(%rbp)
			if (err < 0) return err;
  80017c:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800180:	79 08                	jns    80018a <map_in_guest+0x147>
  800182:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800185:	e9 9c 00 00 00       	jmpq   800226 <map_in_guest+0x1e3>
    	}

		int err = sys_ept_map(thisenv->env_id, UTEMP, guest, (void *)(gpa + i), __EPTE_FULL);
  80018a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80018d:	48 63 d0             	movslq %eax,%rdx
  800190:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800194:	48 01 d0             	add    %rdx,%rax
  800197:	48 89 c1             	mov    %rax,%rcx
  80019a:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8001a1:	00 00 00 
  8001a4:	48 8b 00             	mov    (%rax),%rax
  8001a7:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8001ad:	8b 55 cc             	mov    -0x34(%rbp),%edx
  8001b0:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  8001b6:	be 00 00 40 00       	mov    $0x400000,%esi
  8001bb:	89 c7                	mov    %eax,%edi
  8001bd:	48 b8 78 20 80 00 00 	movabs $0x802078,%rax
  8001c4:	00 00 00 
  8001c7:	ff d0                	callq  *%rax
  8001c9:	89 45 d8             	mov    %eax,-0x28(%rbp)
		if (err < 0) return err;
  8001cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  8001d0:	79 05                	jns    8001d7 <map_in_guest+0x194>
  8001d2:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8001d5:	eb 4f                	jmp    800226 <map_in_guest+0x1e3>
		
		err = sys_page_unmap(thisenv->env_id, UTEMP);
  8001d7:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8001de:	00 00 00 
  8001e1:	48 8b 00             	mov    (%rax),%rax
  8001e4:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8001ea:	be 00 00 40 00       	mov    $0x400000,%esi
  8001ef:	89 c7                	mov    %eax,%edi
  8001f1:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  8001f8:	00 00 00 
  8001fb:	ff d0                	callq  *%rax
  8001fd:	89 45 d8             	mov    %eax,-0x28(%rbp)
		if (err < 0) return err; 
  800200:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800204:	79 05                	jns    80020b <map_in_guest+0x1c8>
  800206:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800209:	eb 1b                	jmp    800226 <map_in_guest+0x1e3>
	      int fd, size_t filesz, off_t fileoffset ) {
		
	if (PGOFF(gpa) != 0) ROUNDDOWN(gpa, PGSIZE);

	int i;
    for (i = 0; i < memsz; i += PGSIZE) 
  80020b:	81 45 fc 00 10 00 00 	addl   $0x1000,-0x4(%rbp)
  800212:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800215:	48 98                	cltq   
  800217:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  80021b:	0f 82 62 fe ff ff    	jb     800083 <map_in_guest+0x40>
		if (err < 0) return err;
		
		err = sys_page_unmap(thisenv->env_id, UTEMP);
		if (err < 0) return err; 
	}
	return 0;
  800221:	b8 00 00 00 00       	mov    $0x0,%eax

} 
  800226:	c9                   	leaveq 
  800227:	c3                   	retq   

0000000000800228 <copy_guest_kern_gpa>:
//
// Return 0 on success, <0 on error
//
// Hint: compare with ELF parsing in env.c, and use map_in_guest for each segment.
static int
copy_guest_kern_gpa( envid_t guest, char* fname ) {
  800228:	55                   	push   %rbp
  800229:	48 89 e5             	mov    %rsp,%rbp
  80022c:	41 57                	push   %r15
  80022e:	41 56                	push   %r14
  800230:	41 55                	push   %r13
  800232:	41 54                	push   %r12
  800234:	53                   	push   %rbx
  800235:	48 83 ec 58          	sub    $0x58,%rsp
  800239:	89 7d 8c             	mov    %edi,-0x74(%rbp)
  80023c:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
  800240:	48 89 e0             	mov    %rsp,%rax
  800243:	48 89 c3             	mov    %rax,%rbx
	/* Your code here */
	// return -E_NO_SYS;
	int fd = open(fname, O_RDONLY);
  800246:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  80024a:	be 00 00 00 00       	mov    $0x0,%esi
  80024f:	48 89 c7             	mov    %rax,%rdi
  800252:	48 b8 09 2c 80 00 00 	movabs $0x802c09,%rax
  800259:	00 00 00 
  80025c:	ff d0                	callq  *%rax
  80025e:	89 45 c4             	mov    %eax,-0x3c(%rbp)
	if (fd < 0) return fd; 
  800261:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800265:	79 08                	jns    80026f <copy_guest_kern_gpa+0x47>
  800267:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  80026a:	e9 9a 01 00 00       	jmpq   800409 <copy_guest_kern_gpa+0x1e1>
	
	const int BUFFER_SIZE = 512;
  80026f:	c7 45 c0 00 02 00 00 	movl   $0x200,-0x40(%rbp)
	char buffer[BUFFER_SIZE];
  800276:	8b 45 c0             	mov    -0x40(%rbp),%eax
  800279:	48 98                	cltq   
  80027b:	48 83 e8 01          	sub    $0x1,%rax
  80027f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  800283:	8b 45 c0             	mov    -0x40(%rbp),%eax
  800286:	48 98                	cltq   
  800288:	49 89 c6             	mov    %rax,%r14
  80028b:	41 bf 00 00 00 00    	mov    $0x0,%r15d
  800291:	8b 45 c0             	mov    -0x40(%rbp),%eax
  800294:	48 98                	cltq   
  800296:	49 89 c4             	mov    %rax,%r12
  800299:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  80029f:	8b 45 c0             	mov    -0x40(%rbp),%eax
  8002a2:	48 98                	cltq   
  8002a4:	ba 10 00 00 00       	mov    $0x10,%edx
  8002a9:	48 83 ea 01          	sub    $0x1,%rdx
  8002ad:	48 01 d0             	add    %rdx,%rax
  8002b0:	b9 10 00 00 00       	mov    $0x10,%ecx
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	48 f7 f1             	div    %rcx
  8002bd:	48 6b c0 10          	imul   $0x10,%rax,%rax
  8002c1:	48 29 c4             	sub    %rax,%rsp
  8002c4:	48 89 e0             	mov    %rsp,%rax
  8002c7:	48 83 c0 00          	add    $0x0,%rax
  8002cb:	48 89 45 b0          	mov    %rax,-0x50(%rbp)

	int len = readn(fd, buffer, BUFFER_SIZE);
  8002cf:	8b 45 c0             	mov    -0x40(%rbp),%eax
  8002d2:	48 63 d0             	movslq %eax,%rdx
  8002d5:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8002d9:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8002dc:	48 89 ce             	mov    %rcx,%rsi
  8002df:	89 c7                	mov    %eax,%edi
  8002e1:	48 b8 08 28 80 00 00 	movabs $0x802808,%rax
  8002e8:	00 00 00 
  8002eb:	ff d0                	callq  *%rax
  8002ed:	89 45 ac             	mov    %eax,-0x54(%rbp)
	if (len != BUFFER_SIZE) {
  8002f0:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8002f3:	3b 45 c0             	cmp    -0x40(%rbp),%eax
  8002f6:	74 1b                	je     800313 <copy_guest_kern_gpa+0xeb>
		close(fd);
  8002f8:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8002fb:	89 c7                	mov    %eax,%edi
  8002fd:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  800304:	00 00 00 
  800307:	ff d0                	callq  *%rax
		return -1;
  800309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80030e:	e9 f6 00 00 00       	jmpq   800409 <copy_guest_kern_gpa+0x1e1>
	}

	struct Elf* elf = (struct Elf*) buffer;
  800313:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800317:	48 89 45 a0          	mov    %rax,-0x60(%rbp)

	if (elf->e_magic != ELF_MAGIC) {
  80031b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80031f:	8b 00                	mov    (%rax),%eax
  800321:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
  800326:	74 1b                	je     800343 <copy_guest_kern_gpa+0x11b>
		close(fd);
  800328:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  80032b:	89 c7                	mov    %eax,%edi
  80032d:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  800334:	00 00 00 
  800337:	ff d0                	callq  *%rax
		return -1;
  800339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80033e:	e9 c6 00 00 00       	jmpq   800409 <copy_guest_kern_gpa+0x1e1>
	}

	struct Proghdr* ph = (struct Proghdr *) ((uint8_t *)elf + elf->e_phoff);
  800343:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800347:	48 8b 50 20          	mov    0x20(%rax),%rdx
  80034b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80034f:	48 01 d0             	add    %rdx,%rax
  800352:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
	struct Proghdr* eph = ph + elf->e_phnum;
  800356:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80035a:	0f b7 40 38          	movzwl 0x38(%rax),%eax
  80035e:	0f b7 c0             	movzwl %ax,%eax
  800361:	48 c1 e0 03          	shl    $0x3,%rax
  800365:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80036c:	00 
  80036d:	48 29 c2             	sub    %rax,%rdx
  800370:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800374:	48 01 d0             	add    %rdx,%rax
  800377:	48 89 45 98          	mov    %rax,-0x68(%rbp)


	for(;ph < eph; ph++) {
  80037b:	eb 6c                	jmp    8003e9 <copy_guest_kern_gpa+0x1c1>
		if (ph->p_type == ELF_PROG_LOAD) {
  80037d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800381:	8b 00                	mov    (%rax),%eax
  800383:	83 f8 01             	cmp    $0x1,%eax
  800386:	75 5c                	jne    8003e4 <copy_guest_kern_gpa+0x1bc>
			int err = map_in_guest(guest, ph->p_pa, ph->p_memsz, fd, ph->p_filesz, ph->p_offset);
  800388:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80038c:	48 8b 40 08          	mov    0x8(%rax),%rax
  800390:	41 89 c0             	mov    %eax,%r8d
  800393:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800397:	48 8b 78 20          	mov    0x20(%rax),%rdi
  80039b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80039f:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8003a3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003a7:	48 8b 70 18          	mov    0x18(%rax),%rsi
  8003ab:	8b 4d c4             	mov    -0x3c(%rbp),%ecx
  8003ae:	8b 45 8c             	mov    -0x74(%rbp),%eax
  8003b1:	45 89 c1             	mov    %r8d,%r9d
  8003b4:	49 89 f8             	mov    %rdi,%r8
  8003b7:	89 c7                	mov    %eax,%edi
  8003b9:	48 b8 43 00 80 00 00 	movabs $0x800043,%rax
  8003c0:	00 00 00 
  8003c3:	ff d0                	callq  *%rax
  8003c5:	89 45 94             	mov    %eax,-0x6c(%rbp)
			if (err < 0) {
  8003c8:	83 7d 94 00          	cmpl   $0x0,-0x6c(%rbp)
  8003cc:	79 16                	jns    8003e4 <copy_guest_kern_gpa+0x1bc>
				close(fd);
  8003ce:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8003d1:	89 c7                	mov    %eax,%edi
  8003d3:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  8003da:	00 00 00 
  8003dd:	ff d0                	callq  *%rax
				return err;
  8003df:	8b 45 94             	mov    -0x6c(%rbp),%eax
  8003e2:	eb 25                	jmp    800409 <copy_guest_kern_gpa+0x1e1>

	struct Proghdr* ph = (struct Proghdr *) ((uint8_t *)elf + elf->e_phoff);
	struct Proghdr* eph = ph + elf->e_phnum;


	for(;ph < eph; ph++) {
  8003e4:	48 83 45 c8 38       	addq   $0x38,-0x38(%rbp)
  8003e9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8003ed:	48 3b 45 98          	cmp    -0x68(%rbp),%rax
  8003f1:	72 8a                	jb     80037d <copy_guest_kern_gpa+0x155>
				return err;
			}
		}
	}
	
	close(fd);
  8003f3:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8003f6:	89 c7                	mov    %eax,%edi
  8003f8:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  8003ff:	00 00 00 
  800402:	ff d0                	callq  *%rax
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	48 89 dc             	mov    %rbx,%rsp
}
  80040c:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
  800410:	5b                   	pop    %rbx
  800411:	41 5c                	pop    %r12
  800413:	41 5d                	pop    %r13
  800415:	41 5e                	pop    %r14
  800417:	41 5f                	pop    %r15
  800419:	5d                   	pop    %rbp
  80041a:	c3                   	retq   

000000000080041b <umain>:


void
umain(int argc, char **argv) {
  80041b:	55                   	push   %rbp
  80041c:	48 89 e5             	mov    %rsp,%rbp
  80041f:	48 83 ec 60          	sub    $0x60,%rsp
  800423:	89 7d ac             	mov    %edi,-0x54(%rbp)
  800426:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
	int ret;
	envid_t guest;
	char filename_buffer[50];	//buffer to save the path 
	int vmdisk_number;
	int r;
	if ((ret = sys_env_mkguest( GUEST_MEM_SZ, JOS_ENTRY )) < 0) {
  80042a:	be 00 70 00 00       	mov    $0x7000,%esi
  80042f:	bf 00 00 00 01       	mov    $0x1000000,%edi
  800434:	48 b8 d3 20 80 00 00 	movabs $0x8020d3,%rax
  80043b:	00 00 00 
  80043e:	ff d0                	callq  *%rax
  800440:	89 45 fc             	mov    %eax,-0x4(%rbp)
  800443:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800447:	79 2c                	jns    800475 <umain+0x5a>
		cprintf("Error creating a guest OS env: %e\n", ret );
  800449:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80044c:	89 c6                	mov    %eax,%esi
  80044e:	48 bf e0 46 80 00 00 	movabs $0x8046e0,%rdi
  800455:	00 00 00 
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  800464:	00 00 00 
  800467:	ff d2                	callq  *%rdx
		exit();
  800469:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  800470:	00 00 00 
  800473:	ff d0                	callq  *%rax
	}
	guest = ret;
  800475:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800478:	89 45 f8             	mov    %eax,-0x8(%rbp)

	// Copy the guest kernel code into guest phys mem.
	if((ret = copy_guest_kern_gpa(guest, GUEST_KERN)) < 0) {
  80047b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80047e:	48 be 03 47 80 00 00 	movabs $0x804703,%rsi
  800485:	00 00 00 
  800488:	89 c7                	mov    %eax,%edi
  80048a:	48 b8 28 02 80 00 00 	movabs $0x800228,%rax
  800491:	00 00 00 
  800494:	ff d0                	callq  *%rax
  800496:	89 45 fc             	mov    %eax,-0x4(%rbp)
  800499:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80049d:	79 2c                	jns    8004cb <umain+0xb0>
		cprintf("Error copying page into the guest - %d\n.", ret);
  80049f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004a2:	89 c6                	mov    %eax,%esi
  8004a4:	48 bf 10 47 80 00 00 	movabs $0x804710,%rdi
  8004ab:	00 00 00 
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  8004ba:	00 00 00 
  8004bd:	ff d2                	callq  *%rdx
		exit();
  8004bf:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  8004c6:	00 00 00 
  8004c9:	ff d0                	callq  *%rax
	}

	// Now copy the bootloader.
	int fd;
	if ((fd = open( GUEST_BOOT, O_RDONLY)) < 0 ) {
  8004cb:	be 00 00 00 00       	mov    $0x0,%esi
  8004d0:	48 bf 39 47 80 00 00 	movabs $0x804739,%rdi
  8004d7:	00 00 00 
  8004da:	48 b8 09 2c 80 00 00 	movabs $0x802c09,%rax
  8004e1:	00 00 00 
  8004e4:	ff d0                	callq  *%rax
  8004e6:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8004ed:	79 36                	jns    800525 <umain+0x10a>
		cprintf("open %s for read: %e\n", GUEST_BOOT, fd );
  8004ef:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004f2:	89 c2                	mov    %eax,%edx
  8004f4:	48 be 39 47 80 00 00 	movabs $0x804739,%rsi
  8004fb:	00 00 00 
  8004fe:	48 bf 43 47 80 00 00 	movabs $0x804743,%rdi
  800505:	00 00 00 
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	48 b9 59 08 80 00 00 	movabs $0x800859,%rcx
  800514:	00 00 00 
  800517:	ff d1                	callq  *%rcx
		exit();
  800519:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  800520:	00 00 00 
  800523:	ff d0                	callq  *%rax
	}

	// sizeof(bootloader) < 512.
	if ((ret = map_in_guest(guest, JOS_ENTRY, 512, fd, 512, 0)) < 0) {
  800525:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800528:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80052b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800531:	41 b8 00 02 00 00    	mov    $0x200,%r8d
  800537:	89 d1                	mov    %edx,%ecx
  800539:	ba 00 02 00 00       	mov    $0x200,%edx
  80053e:	be 00 70 00 00       	mov    $0x7000,%esi
  800543:	89 c7                	mov    %eax,%edi
  800545:	48 b8 43 00 80 00 00 	movabs $0x800043,%rax
  80054c:	00 00 00 
  80054f:	ff d0                	callq  *%rax
  800551:	89 45 fc             	mov    %eax,-0x4(%rbp)
  800554:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800558:	79 2c                	jns    800586 <umain+0x16b>
		cprintf("Error mapping bootloader into the guest - %d\n.", ret);
  80055a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80055d:	89 c6                	mov    %eax,%esi
  80055f:	48 bf 60 47 80 00 00 	movabs $0x804760,%rdi
  800566:	00 00 00 
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  800575:	00 00 00 
  800578:	ff d2                	callq  *%rdx
		exit();
  80057a:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  800581:	00 00 00 
  800584:	ff d0                	callq  *%rax
	}
#ifndef VMM_GUEST	
	sys_vmx_incr_vmdisk_number();	//increase the vmdisk number
  800586:	b8 00 00 00 00       	mov    $0x0,%eax
  80058b:	48 ba dd 21 80 00 00 	movabs $0x8021dd,%rdx
  800592:	00 00 00 
  800595:	ff d2                	callq  *%rdx
	//create a new guest disk image
	
	vmdisk_number = sys_vmx_get_vmdisk_number();
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	48 ba 9f 21 80 00 00 	movabs $0x80219f,%rdx
  8005a3:	00 00 00 
  8005a6:	ff d2                	callq  *%rdx
  8005a8:	89 45 f0             	mov    %eax,-0x10(%rbp)
	snprintf(filename_buffer, 50, "/vmm/fs%d.img", vmdisk_number);
  8005ab:	8b 55 f0             	mov    -0x10(%rbp),%edx
  8005ae:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
  8005b2:	89 d1                	mov    %edx,%ecx
  8005b4:	48 ba 8f 47 80 00 00 	movabs $0x80478f,%rdx
  8005bb:	00 00 00 
  8005be:	be 32 00 00 00       	mov    $0x32,%esi
  8005c3:	48 89 c7             	mov    %rax,%rdi
  8005c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cb:	49 b8 c1 12 80 00 00 	movabs $0x8012c1,%r8
  8005d2:	00 00 00 
  8005d5:	41 ff d0             	callq  *%r8
	
	cprintf("Creating a new virtual HDD at /vmm/fs%d.img\n", vmdisk_number);
  8005d8:	8b 45 f0             	mov    -0x10(%rbp),%eax
  8005db:	89 c6                	mov    %eax,%esi
  8005dd:	48 bf a0 47 80 00 00 	movabs $0x8047a0,%rdi
  8005e4:	00 00 00 
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  8005f3:	00 00 00 
  8005f6:	ff d2                	callq  *%rdx
        r = copy("vmm/clean-fs.img", filename_buffer);
  8005f8:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
  8005fc:	48 89 c6             	mov    %rax,%rsi
  8005ff:	48 bf cd 47 80 00 00 	movabs $0x8047cd,%rdi
  800606:	00 00 00 
  800609:	48 b8 6b 30 80 00 00 	movabs $0x80306b,%rax
  800610:	00 00 00 
  800613:	ff d0                	callq  *%rax
  800615:	89 45 ec             	mov    %eax,-0x14(%rbp)
        
        if (r < 0) {
  800618:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80061c:	79 2c                	jns    80064a <umain+0x22f>
        	cprintf("Create new virtual HDD failed: %e\n", r);
  80061e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800621:	89 c6                	mov    %eax,%esi
  800623:	48 bf e0 47 80 00 00 	movabs $0x8047e0,%rdi
  80062a:	00 00 00 
  80062d:	b8 00 00 00 00       	mov    $0x0,%eax
  800632:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  800639:	00 00 00 
  80063c:	ff d2                	callq  *%rdx
        	exit();
  80063e:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  800645:	00 00 00 
  800648:	ff d0                	callq  *%rax
        }
        
        cprintf("Create VHD finished\n");
  80064a:	48 bf 03 48 80 00 00 	movabs $0x804803,%rdi
  800651:	00 00 00 
  800654:	b8 00 00 00 00       	mov    $0x0,%eax
  800659:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  800660:	00 00 00 
  800663:	ff d2                	callq  *%rdx
#endif
	// Mark the guest as runnable.
	sys_env_set_status(guest, ENV_RUNNABLE);
  800665:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800668:	be 02 00 00 00       	mov    $0x2,%esi
  80066d:	89 c7                	mov    %eax,%edi
  80066f:	48 b8 32 1e 80 00 00 	movabs $0x801e32,%rax
  800676:	00 00 00 
  800679:	ff d0                	callq  *%rax
	wait(guest);
  80067b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80067e:	89 c7                	mov    %eax,%edi
  800680:	48 b8 1b 40 80 00 00 	movabs $0x80401b,%rax
  800687:	00 00 00 
  80068a:	ff d0                	callq  *%rax
}
  80068c:	c9                   	leaveq 
  80068d:	c3                   	retq   

000000000080068e <libmain>:
  80068e:	55                   	push   %rbp
  80068f:	48 89 e5             	mov    %rsp,%rbp
  800692:	48 83 ec 10          	sub    $0x10,%rsp
  800696:	89 7d fc             	mov    %edi,-0x4(%rbp)
  800699:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80069d:	48 b8 c1 1c 80 00 00 	movabs $0x801cc1,%rax
  8006a4:	00 00 00 
  8006a7:	ff d0                	callq  *%rax
  8006a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006ae:	48 98                	cltq   
  8006b0:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  8006b7:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8006be:	00 00 00 
  8006c1:	48 01 c2             	add    %rax,%rdx
  8006c4:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8006cb:	00 00 00 
  8006ce:	48 89 10             	mov    %rdx,(%rax)
  8006d1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8006d5:	7e 14                	jle    8006eb <libmain+0x5d>
  8006d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8006db:	48 8b 10             	mov    (%rax),%rdx
  8006de:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  8006e5:	00 00 00 
  8006e8:	48 89 10             	mov    %rdx,(%rax)
  8006eb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8006ef:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8006f2:	48 89 d6             	mov    %rdx,%rsi
  8006f5:	89 c7                	mov    %eax,%edi
  8006f7:	48 b8 1b 04 80 00 00 	movabs $0x80041b,%rax
  8006fe:	00 00 00 
  800701:	ff d0                	callq  *%rax
  800703:	48 b8 11 07 80 00 00 	movabs $0x800711,%rax
  80070a:	00 00 00 
  80070d:	ff d0                	callq  *%rax
  80070f:	c9                   	leaveq 
  800710:	c3                   	retq   

0000000000800711 <exit>:
  800711:	55                   	push   %rbp
  800712:	48 89 e5             	mov    %rsp,%rbp
  800715:	48 b8 5c 25 80 00 00 	movabs $0x80255c,%rax
  80071c:	00 00 00 
  80071f:	ff d0                	callq  *%rax
  800721:	bf 00 00 00 00       	mov    $0x0,%edi
  800726:	48 b8 7d 1c 80 00 00 	movabs $0x801c7d,%rax
  80072d:	00 00 00 
  800730:	ff d0                	callq  *%rax
  800732:	5d                   	pop    %rbp
  800733:	c3                   	retq   

0000000000800734 <putch>:
  800734:	55                   	push   %rbp
  800735:	48 89 e5             	mov    %rsp,%rbp
  800738:	48 83 ec 10          	sub    $0x10,%rsp
  80073c:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80073f:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  800743:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800747:	8b 00                	mov    (%rax),%eax
  800749:	8d 48 01             	lea    0x1(%rax),%ecx
  80074c:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800750:	89 0a                	mov    %ecx,(%rdx)
  800752:	8b 55 fc             	mov    -0x4(%rbp),%edx
  800755:	89 d1                	mov    %edx,%ecx
  800757:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80075b:	48 98                	cltq   
  80075d:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  800761:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800765:	8b 00                	mov    (%rax),%eax
  800767:	3d ff 00 00 00       	cmp    $0xff,%eax
  80076c:	75 2c                	jne    80079a <putch+0x66>
  80076e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800772:	8b 00                	mov    (%rax),%eax
  800774:	48 98                	cltq   
  800776:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80077a:	48 83 c2 08          	add    $0x8,%rdx
  80077e:	48 89 c6             	mov    %rax,%rsi
  800781:	48 89 d7             	mov    %rdx,%rdi
  800784:	48 b8 f5 1b 80 00 00 	movabs $0x801bf5,%rax
  80078b:	00 00 00 
  80078e:	ff d0                	callq  *%rax
  800790:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800794:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  80079a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80079e:	8b 40 04             	mov    0x4(%rax),%eax
  8007a1:	8d 50 01             	lea    0x1(%rax),%edx
  8007a4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8007a8:	89 50 04             	mov    %edx,0x4(%rax)
  8007ab:	c9                   	leaveq 
  8007ac:	c3                   	retq   

00000000008007ad <vcprintf>:
  8007ad:	55                   	push   %rbp
  8007ae:	48 89 e5             	mov    %rsp,%rbp
  8007b1:	48 81 ec 40 01 00 00 	sub    $0x140,%rsp
  8007b8:	48 89 bd c8 fe ff ff 	mov    %rdi,-0x138(%rbp)
  8007bf:	48 89 b5 c0 fe ff ff 	mov    %rsi,-0x140(%rbp)
  8007c6:	48 8d 85 d8 fe ff ff 	lea    -0x128(%rbp),%rax
  8007cd:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  8007d4:	48 8b 0a             	mov    (%rdx),%rcx
  8007d7:	48 89 08             	mov    %rcx,(%rax)
  8007da:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8007de:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8007e2:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8007e6:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8007ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8007f1:	00 00 00 
  8007f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8007fb:	00 00 00 
  8007fe:	48 8d 8d d8 fe ff ff 	lea    -0x128(%rbp),%rcx
  800805:	48 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%rdx
  80080c:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800813:	48 89 c6             	mov    %rax,%rsi
  800816:	48 bf 34 07 80 00 00 	movabs $0x800734,%rdi
  80081d:	00 00 00 
  800820:	48 b8 0c 0c 80 00 00 	movabs $0x800c0c,%rax
  800827:	00 00 00 
  80082a:	ff d0                	callq  *%rax
  80082c:	8b 85 f0 fe ff ff    	mov    -0x110(%rbp),%eax
  800832:	48 98                	cltq   
  800834:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
  80083b:	48 83 c2 08          	add    $0x8,%rdx
  80083f:	48 89 c6             	mov    %rax,%rsi
  800842:	48 89 d7             	mov    %rdx,%rdi
  800845:	48 b8 f5 1b 80 00 00 	movabs $0x801bf5,%rax
  80084c:	00 00 00 
  80084f:	ff d0                	callq  *%rax
  800851:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800857:	c9                   	leaveq 
  800858:	c3                   	retq   

0000000000800859 <cprintf>:
  800859:	55                   	push   %rbp
  80085a:	48 89 e5             	mov    %rsp,%rbp
  80085d:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  800864:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80086b:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800872:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800879:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800880:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800887:	84 c0                	test   %al,%al
  800889:	74 20                	je     8008ab <cprintf+0x52>
  80088b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80088f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800893:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800897:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80089b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80089f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8008a3:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8008a7:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8008ab:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  8008b2:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  8008b9:	00 00 00 
  8008bc:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  8008c3:	00 00 00 
  8008c6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8008ca:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8008d1:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8008d8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8008df:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8008e6:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  8008ed:	48 8b 0a             	mov    (%rdx),%rcx
  8008f0:	48 89 08             	mov    %rcx,(%rax)
  8008f3:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8008f7:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8008fb:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8008ff:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800903:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  80090a:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800911:	48 89 d6             	mov    %rdx,%rsi
  800914:	48 89 c7             	mov    %rax,%rdi
  800917:	48 b8 ad 07 80 00 00 	movabs $0x8007ad,%rax
  80091e:	00 00 00 
  800921:	ff d0                	callq  *%rax
  800923:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  800929:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  80092f:	c9                   	leaveq 
  800930:	c3                   	retq   

0000000000800931 <printnum>:
  800931:	55                   	push   %rbp
  800932:	48 89 e5             	mov    %rsp,%rbp
  800935:	53                   	push   %rbx
  800936:	48 83 ec 38          	sub    $0x38,%rsp
  80093a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80093e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800942:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800946:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  800949:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  80094d:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
  800951:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  800954:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  800958:	77 3b                	ja     800995 <printnum+0x64>
  80095a:	8b 45 d0             	mov    -0x30(%rbp),%eax
  80095d:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  800961:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  800964:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
  80096d:	48 f7 f3             	div    %rbx
  800970:	48 89 c2             	mov    %rax,%rdx
  800973:	8b 7d cc             	mov    -0x34(%rbp),%edi
  800976:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800979:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  80097d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800981:	41 89 f9             	mov    %edi,%r9d
  800984:	48 89 c7             	mov    %rax,%rdi
  800987:	48 b8 31 09 80 00 00 	movabs $0x800931,%rax
  80098e:	00 00 00 
  800991:	ff d0                	callq  *%rax
  800993:	eb 1e                	jmp    8009b3 <printnum+0x82>
  800995:	eb 12                	jmp    8009a9 <printnum+0x78>
  800997:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  80099b:	8b 55 cc             	mov    -0x34(%rbp),%edx
  80099e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8009a2:	48 89 ce             	mov    %rcx,%rsi
  8009a5:	89 d7                	mov    %edx,%edi
  8009a7:	ff d0                	callq  *%rax
  8009a9:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  8009ad:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  8009b1:	7f e4                	jg     800997 <printnum+0x66>
  8009b3:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8009b6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	48 f7 f1             	div    %rcx
  8009c2:	48 89 d0             	mov    %rdx,%rax
  8009c5:	48 ba 30 4a 80 00 00 	movabs $0x804a30,%rdx
  8009cc:	00 00 00 
  8009cf:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8009d3:	0f be d0             	movsbl %al,%edx
  8009d6:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8009da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8009de:	48 89 ce             	mov    %rcx,%rsi
  8009e1:	89 d7                	mov    %edx,%edi
  8009e3:	ff d0                	callq  *%rax
  8009e5:	48 83 c4 38          	add    $0x38,%rsp
  8009e9:	5b                   	pop    %rbx
  8009ea:	5d                   	pop    %rbp
  8009eb:	c3                   	retq   

00000000008009ec <getuint>:
  8009ec:	55                   	push   %rbp
  8009ed:	48 89 e5             	mov    %rsp,%rbp
  8009f0:	48 83 ec 1c          	sub    $0x1c,%rsp
  8009f4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8009f8:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  8009fb:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  8009ff:	7e 52                	jle    800a53 <getuint+0x67>
  800a01:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a05:	8b 00                	mov    (%rax),%eax
  800a07:	83 f8 30             	cmp    $0x30,%eax
  800a0a:	73 24                	jae    800a30 <getuint+0x44>
  800a0c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a10:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800a14:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a18:	8b 00                	mov    (%rax),%eax
  800a1a:	89 c0                	mov    %eax,%eax
  800a1c:	48 01 d0             	add    %rdx,%rax
  800a1f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a23:	8b 12                	mov    (%rdx),%edx
  800a25:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800a28:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a2c:	89 0a                	mov    %ecx,(%rdx)
  800a2e:	eb 17                	jmp    800a47 <getuint+0x5b>
  800a30:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a34:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800a38:	48 89 d0             	mov    %rdx,%rax
  800a3b:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800a3f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a43:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800a47:	48 8b 00             	mov    (%rax),%rax
  800a4a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800a4e:	e9 a3 00 00 00       	jmpq   800af6 <getuint+0x10a>
  800a53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800a57:	74 4f                	je     800aa8 <getuint+0xbc>
  800a59:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a5d:	8b 00                	mov    (%rax),%eax
  800a5f:	83 f8 30             	cmp    $0x30,%eax
  800a62:	73 24                	jae    800a88 <getuint+0x9c>
  800a64:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a68:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800a6c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a70:	8b 00                	mov    (%rax),%eax
  800a72:	89 c0                	mov    %eax,%eax
  800a74:	48 01 d0             	add    %rdx,%rax
  800a77:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a7b:	8b 12                	mov    (%rdx),%edx
  800a7d:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800a80:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a84:	89 0a                	mov    %ecx,(%rdx)
  800a86:	eb 17                	jmp    800a9f <getuint+0xb3>
  800a88:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a8c:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800a90:	48 89 d0             	mov    %rdx,%rax
  800a93:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800a97:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800a9b:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800a9f:	48 8b 00             	mov    (%rax),%rax
  800aa2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800aa6:	eb 4e                	jmp    800af6 <getuint+0x10a>
  800aa8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800aac:	8b 00                	mov    (%rax),%eax
  800aae:	83 f8 30             	cmp    $0x30,%eax
  800ab1:	73 24                	jae    800ad7 <getuint+0xeb>
  800ab3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ab7:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800abb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800abf:	8b 00                	mov    (%rax),%eax
  800ac1:	89 c0                	mov    %eax,%eax
  800ac3:	48 01 d0             	add    %rdx,%rax
  800ac6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800aca:	8b 12                	mov    (%rdx),%edx
  800acc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800acf:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800ad3:	89 0a                	mov    %ecx,(%rdx)
  800ad5:	eb 17                	jmp    800aee <getuint+0x102>
  800ad7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800adb:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800adf:	48 89 d0             	mov    %rdx,%rax
  800ae2:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800ae6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800aea:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800aee:	8b 00                	mov    (%rax),%eax
  800af0:	89 c0                	mov    %eax,%eax
  800af2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800af6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800afa:	c9                   	leaveq 
  800afb:	c3                   	retq   

0000000000800afc <getint>:
  800afc:	55                   	push   %rbp
  800afd:	48 89 e5             	mov    %rsp,%rbp
  800b00:	48 83 ec 1c          	sub    $0x1c,%rsp
  800b04:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800b08:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800b0b:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  800b0f:	7e 52                	jle    800b63 <getint+0x67>
  800b11:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b15:	8b 00                	mov    (%rax),%eax
  800b17:	83 f8 30             	cmp    $0x30,%eax
  800b1a:	73 24                	jae    800b40 <getint+0x44>
  800b1c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b20:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800b24:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b28:	8b 00                	mov    (%rax),%eax
  800b2a:	89 c0                	mov    %eax,%eax
  800b2c:	48 01 d0             	add    %rdx,%rax
  800b2f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b33:	8b 12                	mov    (%rdx),%edx
  800b35:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800b38:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b3c:	89 0a                	mov    %ecx,(%rdx)
  800b3e:	eb 17                	jmp    800b57 <getint+0x5b>
  800b40:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b44:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800b48:	48 89 d0             	mov    %rdx,%rax
  800b4b:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800b4f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b53:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800b57:	48 8b 00             	mov    (%rax),%rax
  800b5a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800b5e:	e9 a3 00 00 00       	jmpq   800c06 <getint+0x10a>
  800b63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800b67:	74 4f                	je     800bb8 <getint+0xbc>
  800b69:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b6d:	8b 00                	mov    (%rax),%eax
  800b6f:	83 f8 30             	cmp    $0x30,%eax
  800b72:	73 24                	jae    800b98 <getint+0x9c>
  800b74:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b78:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800b7c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b80:	8b 00                	mov    (%rax),%eax
  800b82:	89 c0                	mov    %eax,%eax
  800b84:	48 01 d0             	add    %rdx,%rax
  800b87:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b8b:	8b 12                	mov    (%rdx),%edx
  800b8d:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800b90:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b94:	89 0a                	mov    %ecx,(%rdx)
  800b96:	eb 17                	jmp    800baf <getint+0xb3>
  800b98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b9c:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800ba0:	48 89 d0             	mov    %rdx,%rax
  800ba3:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800ba7:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bab:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800baf:	48 8b 00             	mov    (%rax),%rax
  800bb2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800bb6:	eb 4e                	jmp    800c06 <getint+0x10a>
  800bb8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bbc:	8b 00                	mov    (%rax),%eax
  800bbe:	83 f8 30             	cmp    $0x30,%eax
  800bc1:	73 24                	jae    800be7 <getint+0xeb>
  800bc3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bc7:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800bcb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bcf:	8b 00                	mov    (%rax),%eax
  800bd1:	89 c0                	mov    %eax,%eax
  800bd3:	48 01 d0             	add    %rdx,%rax
  800bd6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bda:	8b 12                	mov    (%rdx),%edx
  800bdc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800bdf:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800be3:	89 0a                	mov    %ecx,(%rdx)
  800be5:	eb 17                	jmp    800bfe <getint+0x102>
  800be7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800beb:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800bef:	48 89 d0             	mov    %rdx,%rax
  800bf2:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800bf6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bfa:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800bfe:	8b 00                	mov    (%rax),%eax
  800c00:	48 98                	cltq   
  800c02:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800c06:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800c0a:	c9                   	leaveq 
  800c0b:	c3                   	retq   

0000000000800c0c <vprintfmt>:
  800c0c:	55                   	push   %rbp
  800c0d:	48 89 e5             	mov    %rsp,%rbp
  800c10:	41 54                	push   %r12
  800c12:	53                   	push   %rbx
  800c13:	48 83 ec 60          	sub    $0x60,%rsp
  800c17:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  800c1b:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  800c1f:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800c23:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  800c27:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800c2b:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  800c2f:	48 8b 0a             	mov    (%rdx),%rcx
  800c32:	48 89 08             	mov    %rcx,(%rax)
  800c35:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800c39:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800c3d:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800c41:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800c45:	eb 17                	jmp    800c5e <vprintfmt+0x52>
  800c47:	85 db                	test   %ebx,%ebx
  800c49:	0f 84 cc 04 00 00    	je     80111b <vprintfmt+0x50f>
  800c4f:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800c53:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800c57:	48 89 d6             	mov    %rdx,%rsi
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	ff d0                	callq  *%rax
  800c5e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800c62:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800c66:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800c6a:	0f b6 00             	movzbl (%rax),%eax
  800c6d:	0f b6 d8             	movzbl %al,%ebx
  800c70:	83 fb 25             	cmp    $0x25,%ebx
  800c73:	75 d2                	jne    800c47 <vprintfmt+0x3b>
  800c75:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
  800c79:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
  800c80:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800c87:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  800c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
  800c95:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800c99:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800c9d:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800ca1:	0f b6 00             	movzbl (%rax),%eax
  800ca4:	0f b6 d8             	movzbl %al,%ebx
  800ca7:	8d 43 dd             	lea    -0x23(%rbx),%eax
  800caa:	83 f8 55             	cmp    $0x55,%eax
  800cad:	0f 87 34 04 00 00    	ja     8010e7 <vprintfmt+0x4db>
  800cb3:	89 c0                	mov    %eax,%eax
  800cb5:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800cbc:	00 
  800cbd:	48 b8 58 4a 80 00 00 	movabs $0x804a58,%rax
  800cc4:	00 00 00 
  800cc7:	48 01 d0             	add    %rdx,%rax
  800cca:	48 8b 00             	mov    (%rax),%rax
  800ccd:	ff e0                	jmpq   *%rax
  800ccf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
  800cd3:	eb c0                	jmp    800c95 <vprintfmt+0x89>
  800cd5:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
  800cd9:	eb ba                	jmp    800c95 <vprintfmt+0x89>
  800cdb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
  800ce2:	8b 55 d8             	mov    -0x28(%rbp),%edx
  800ce5:	89 d0                	mov    %edx,%eax
  800ce7:	c1 e0 02             	shl    $0x2,%eax
  800cea:	01 d0                	add    %edx,%eax
  800cec:	01 c0                	add    %eax,%eax
  800cee:	01 d8                	add    %ebx,%eax
  800cf0:	83 e8 30             	sub    $0x30,%eax
  800cf3:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800cf6:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800cfa:	0f b6 00             	movzbl (%rax),%eax
  800cfd:	0f be d8             	movsbl %al,%ebx
  800d00:	83 fb 2f             	cmp    $0x2f,%ebx
  800d03:	7e 0c                	jle    800d11 <vprintfmt+0x105>
  800d05:	83 fb 39             	cmp    $0x39,%ebx
  800d08:	7f 07                	jg     800d11 <vprintfmt+0x105>
  800d0a:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
  800d0f:	eb d1                	jmp    800ce2 <vprintfmt+0xd6>
  800d11:	eb 58                	jmp    800d6b <vprintfmt+0x15f>
  800d13:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d16:	83 f8 30             	cmp    $0x30,%eax
  800d19:	73 17                	jae    800d32 <vprintfmt+0x126>
  800d1b:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800d1f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d22:	89 c0                	mov    %eax,%eax
  800d24:	48 01 d0             	add    %rdx,%rax
  800d27:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800d2a:	83 c2 08             	add    $0x8,%edx
  800d2d:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800d30:	eb 0f                	jmp    800d41 <vprintfmt+0x135>
  800d32:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d36:	48 89 d0             	mov    %rdx,%rax
  800d39:	48 83 c2 08          	add    $0x8,%rdx
  800d3d:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800d41:	8b 00                	mov    (%rax),%eax
  800d43:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800d46:	eb 23                	jmp    800d6b <vprintfmt+0x15f>
  800d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800d4c:	79 0c                	jns    800d5a <vprintfmt+0x14e>
  800d4e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
  800d55:	e9 3b ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d5a:	e9 36 ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d5f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
  800d66:	e9 2a ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d6b:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800d6f:	79 12                	jns    800d83 <vprintfmt+0x177>
  800d71:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800d74:	89 45 dc             	mov    %eax,-0x24(%rbp)
  800d77:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800d7e:	e9 12 ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d83:	e9 0d ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d88:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
  800d8c:	e9 04 ff ff ff       	jmpq   800c95 <vprintfmt+0x89>
  800d91:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d94:	83 f8 30             	cmp    $0x30,%eax
  800d97:	73 17                	jae    800db0 <vprintfmt+0x1a4>
  800d99:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800d9d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800da0:	89 c0                	mov    %eax,%eax
  800da2:	48 01 d0             	add    %rdx,%rax
  800da5:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800da8:	83 c2 08             	add    $0x8,%edx
  800dab:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800dae:	eb 0f                	jmp    800dbf <vprintfmt+0x1b3>
  800db0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800db4:	48 89 d0             	mov    %rdx,%rax
  800db7:	48 83 c2 08          	add    $0x8,%rdx
  800dbb:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800dbf:	8b 10                	mov    (%rax),%edx
  800dc1:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800dc5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800dc9:	48 89 ce             	mov    %rcx,%rsi
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	ff d0                	callq  *%rax
  800dd0:	e9 40 03 00 00       	jmpq   801115 <vprintfmt+0x509>
  800dd5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800dd8:	83 f8 30             	cmp    $0x30,%eax
  800ddb:	73 17                	jae    800df4 <vprintfmt+0x1e8>
  800ddd:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800de1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800de4:	89 c0                	mov    %eax,%eax
  800de6:	48 01 d0             	add    %rdx,%rax
  800de9:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800dec:	83 c2 08             	add    $0x8,%edx
  800def:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800df2:	eb 0f                	jmp    800e03 <vprintfmt+0x1f7>
  800df4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800df8:	48 89 d0             	mov    %rdx,%rax
  800dfb:	48 83 c2 08          	add    $0x8,%rdx
  800dff:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800e03:	8b 18                	mov    (%rax),%ebx
  800e05:	85 db                	test   %ebx,%ebx
  800e07:	79 02                	jns    800e0b <vprintfmt+0x1ff>
  800e09:	f7 db                	neg    %ebx
  800e0b:	83 fb 15             	cmp    $0x15,%ebx
  800e0e:	7f 16                	jg     800e26 <vprintfmt+0x21a>
  800e10:	48 b8 80 49 80 00 00 	movabs $0x804980,%rax
  800e17:	00 00 00 
  800e1a:	48 63 d3             	movslq %ebx,%rdx
  800e1d:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  800e21:	4d 85 e4             	test   %r12,%r12
  800e24:	75 2e                	jne    800e54 <vprintfmt+0x248>
  800e26:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800e2a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800e2e:	89 d9                	mov    %ebx,%ecx
  800e30:	48 ba 41 4a 80 00 00 	movabs $0x804a41,%rdx
  800e37:	00 00 00 
  800e3a:	48 89 c7             	mov    %rax,%rdi
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	49 b8 24 11 80 00 00 	movabs $0x801124,%r8
  800e49:	00 00 00 
  800e4c:	41 ff d0             	callq  *%r8
  800e4f:	e9 c1 02 00 00       	jmpq   801115 <vprintfmt+0x509>
  800e54:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800e58:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800e5c:	4c 89 e1             	mov    %r12,%rcx
  800e5f:	48 ba 4a 4a 80 00 00 	movabs $0x804a4a,%rdx
  800e66:	00 00 00 
  800e69:	48 89 c7             	mov    %rax,%rdi
  800e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e71:	49 b8 24 11 80 00 00 	movabs $0x801124,%r8
  800e78:	00 00 00 
  800e7b:	41 ff d0             	callq  *%r8
  800e7e:	e9 92 02 00 00       	jmpq   801115 <vprintfmt+0x509>
  800e83:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e86:	83 f8 30             	cmp    $0x30,%eax
  800e89:	73 17                	jae    800ea2 <vprintfmt+0x296>
  800e8b:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800e8f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e92:	89 c0                	mov    %eax,%eax
  800e94:	48 01 d0             	add    %rdx,%rax
  800e97:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800e9a:	83 c2 08             	add    $0x8,%edx
  800e9d:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800ea0:	eb 0f                	jmp    800eb1 <vprintfmt+0x2a5>
  800ea2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ea6:	48 89 d0             	mov    %rdx,%rax
  800ea9:	48 83 c2 08          	add    $0x8,%rdx
  800ead:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800eb1:	4c 8b 20             	mov    (%rax),%r12
  800eb4:	4d 85 e4             	test   %r12,%r12
  800eb7:	75 0a                	jne    800ec3 <vprintfmt+0x2b7>
  800eb9:	49 bc 4d 4a 80 00 00 	movabs $0x804a4d,%r12
  800ec0:	00 00 00 
  800ec3:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800ec7:	7e 3f                	jle    800f08 <vprintfmt+0x2fc>
  800ec9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  800ecd:	74 39                	je     800f08 <vprintfmt+0x2fc>
  800ecf:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800ed2:	48 98                	cltq   
  800ed4:	48 89 c6             	mov    %rax,%rsi
  800ed7:	4c 89 e7             	mov    %r12,%rdi
  800eda:	48 b8 d0 13 80 00 00 	movabs $0x8013d0,%rax
  800ee1:	00 00 00 
  800ee4:	ff d0                	callq  *%rax
  800ee6:	29 45 dc             	sub    %eax,-0x24(%rbp)
  800ee9:	eb 17                	jmp    800f02 <vprintfmt+0x2f6>
  800eeb:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  800eef:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800ef3:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800ef7:	48 89 ce             	mov    %rcx,%rsi
  800efa:	89 d7                	mov    %edx,%edi
  800efc:	ff d0                	callq  *%rax
  800efe:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800f02:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800f06:	7f e3                	jg     800eeb <vprintfmt+0x2df>
  800f08:	eb 37                	jmp    800f41 <vprintfmt+0x335>
  800f0a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  800f0e:	74 1e                	je     800f2e <vprintfmt+0x322>
  800f10:	83 fb 1f             	cmp    $0x1f,%ebx
  800f13:	7e 05                	jle    800f1a <vprintfmt+0x30e>
  800f15:	83 fb 7e             	cmp    $0x7e,%ebx
  800f18:	7e 14                	jle    800f2e <vprintfmt+0x322>
  800f1a:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800f1e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f22:	48 89 d6             	mov    %rdx,%rsi
  800f25:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800f2a:	ff d0                	callq  *%rax
  800f2c:	eb 0f                	jmp    800f3d <vprintfmt+0x331>
  800f2e:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800f32:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f36:	48 89 d6             	mov    %rdx,%rsi
  800f39:	89 df                	mov    %ebx,%edi
  800f3b:	ff d0                	callq  *%rax
  800f3d:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800f41:	4c 89 e0             	mov    %r12,%rax
  800f44:	4c 8d 60 01          	lea    0x1(%rax),%r12
  800f48:	0f b6 00             	movzbl (%rax),%eax
  800f4b:	0f be d8             	movsbl %al,%ebx
  800f4e:	85 db                	test   %ebx,%ebx
  800f50:	74 10                	je     800f62 <vprintfmt+0x356>
  800f52:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800f56:	78 b2                	js     800f0a <vprintfmt+0x2fe>
  800f58:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  800f5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800f60:	79 a8                	jns    800f0a <vprintfmt+0x2fe>
  800f62:	eb 16                	jmp    800f7a <vprintfmt+0x36e>
  800f64:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800f68:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f6c:	48 89 d6             	mov    %rdx,%rsi
  800f6f:	bf 20 00 00 00       	mov    $0x20,%edi
  800f74:	ff d0                	callq  *%rax
  800f76:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800f7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800f7e:	7f e4                	jg     800f64 <vprintfmt+0x358>
  800f80:	e9 90 01 00 00       	jmpq   801115 <vprintfmt+0x509>
  800f85:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800f89:	be 03 00 00 00       	mov    $0x3,%esi
  800f8e:	48 89 c7             	mov    %rax,%rdi
  800f91:	48 b8 fc 0a 80 00 00 	movabs $0x800afc,%rax
  800f98:	00 00 00 
  800f9b:	ff d0                	callq  *%rax
  800f9d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800fa1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800fa5:	48 85 c0             	test   %rax,%rax
  800fa8:	79 1d                	jns    800fc7 <vprintfmt+0x3bb>
  800faa:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800fae:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800fb2:	48 89 d6             	mov    %rdx,%rsi
  800fb5:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800fba:	ff d0                	callq  *%rax
  800fbc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800fc0:	48 f7 d8             	neg    %rax
  800fc3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800fc7:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  800fce:	e9 d5 00 00 00       	jmpq   8010a8 <vprintfmt+0x49c>
  800fd3:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800fd7:	be 03 00 00 00       	mov    $0x3,%esi
  800fdc:	48 89 c7             	mov    %rax,%rdi
  800fdf:	48 b8 ec 09 80 00 00 	movabs $0x8009ec,%rax
  800fe6:	00 00 00 
  800fe9:	ff d0                	callq  *%rax
  800feb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800fef:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  800ff6:	e9 ad 00 00 00       	jmpq   8010a8 <vprintfmt+0x49c>
  800ffb:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800fff:	be 03 00 00 00       	mov    $0x3,%esi
  801004:	48 89 c7             	mov    %rax,%rdi
  801007:	48 b8 ec 09 80 00 00 	movabs $0x8009ec,%rax
  80100e:	00 00 00 
  801011:	ff d0                	callq  *%rax
  801013:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801017:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
  80101e:	e9 85 00 00 00       	jmpq   8010a8 <vprintfmt+0x49c>
  801023:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801027:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80102b:	48 89 d6             	mov    %rdx,%rsi
  80102e:	bf 30 00 00 00       	mov    $0x30,%edi
  801033:	ff d0                	callq  *%rax
  801035:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801039:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80103d:	48 89 d6             	mov    %rdx,%rsi
  801040:	bf 78 00 00 00       	mov    $0x78,%edi
  801045:	ff d0                	callq  *%rax
  801047:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80104a:	83 f8 30             	cmp    $0x30,%eax
  80104d:	73 17                	jae    801066 <vprintfmt+0x45a>
  80104f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  801053:	8b 45 b8             	mov    -0x48(%rbp),%eax
  801056:	89 c0                	mov    %eax,%eax
  801058:	48 01 d0             	add    %rdx,%rax
  80105b:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80105e:	83 c2 08             	add    $0x8,%edx
  801061:	89 55 b8             	mov    %edx,-0x48(%rbp)
  801064:	eb 0f                	jmp    801075 <vprintfmt+0x469>
  801066:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80106a:	48 89 d0             	mov    %rdx,%rax
  80106d:	48 83 c2 08          	add    $0x8,%rdx
  801071:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  801075:	48 8b 00             	mov    (%rax),%rax
  801078:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80107c:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  801083:	eb 23                	jmp    8010a8 <vprintfmt+0x49c>
  801085:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  801089:	be 03 00 00 00       	mov    $0x3,%esi
  80108e:	48 89 c7             	mov    %rax,%rdi
  801091:	48 b8 ec 09 80 00 00 	movabs $0x8009ec,%rax
  801098:	00 00 00 
  80109b:	ff d0                	callq  *%rax
  80109d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8010a1:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  8010a8:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  8010ad:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  8010b0:	8b 7d dc             	mov    -0x24(%rbp),%edi
  8010b3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8010b7:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8010bb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010bf:	45 89 c1             	mov    %r8d,%r9d
  8010c2:	41 89 f8             	mov    %edi,%r8d
  8010c5:	48 89 c7             	mov    %rax,%rdi
  8010c8:	48 b8 31 09 80 00 00 	movabs $0x800931,%rax
  8010cf:	00 00 00 
  8010d2:	ff d0                	callq  *%rax
  8010d4:	eb 3f                	jmp    801115 <vprintfmt+0x509>
  8010d6:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8010da:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010de:	48 89 d6             	mov    %rdx,%rsi
  8010e1:	89 df                	mov    %ebx,%edi
  8010e3:	ff d0                	callq  *%rax
  8010e5:	eb 2e                	jmp    801115 <vprintfmt+0x509>
  8010e7:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8010eb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010ef:	48 89 d6             	mov    %rdx,%rsi
  8010f2:	bf 25 00 00 00       	mov    $0x25,%edi
  8010f7:	ff d0                	callq  *%rax
  8010f9:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  8010fe:	eb 05                	jmp    801105 <vprintfmt+0x4f9>
  801100:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  801105:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  801109:	48 83 e8 01          	sub    $0x1,%rax
  80110d:	0f b6 00             	movzbl (%rax),%eax
  801110:	3c 25                	cmp    $0x25,%al
  801112:	75 ec                	jne    801100 <vprintfmt+0x4f4>
  801114:	90                   	nop
  801115:	90                   	nop
  801116:	e9 43 fb ff ff       	jmpq   800c5e <vprintfmt+0x52>
  80111b:	48 83 c4 60          	add    $0x60,%rsp
  80111f:	5b                   	pop    %rbx
  801120:	41 5c                	pop    %r12
  801122:	5d                   	pop    %rbp
  801123:	c3                   	retq   

0000000000801124 <printfmt>:
  801124:	55                   	push   %rbp
  801125:	48 89 e5             	mov    %rsp,%rbp
  801128:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  80112f:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  801136:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  80113d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  801144:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80114b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  801152:	84 c0                	test   %al,%al
  801154:	74 20                	je     801176 <printfmt+0x52>
  801156:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80115a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80115e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  801162:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  801166:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80116a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80116e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  801172:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  801176:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
  80117d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  801184:	00 00 00 
  801187:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80118e:	00 00 00 
  801191:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801195:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80119c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8011a3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  8011aa:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8011b1:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  8011b8:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  8011bf:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8011c6:	48 89 c7             	mov    %rax,%rdi
  8011c9:	48 b8 0c 0c 80 00 00 	movabs $0x800c0c,%rax
  8011d0:	00 00 00 
  8011d3:	ff d0                	callq  *%rax
  8011d5:	c9                   	leaveq 
  8011d6:	c3                   	retq   

00000000008011d7 <sprintputch>:
  8011d7:	55                   	push   %rbp
  8011d8:	48 89 e5             	mov    %rsp,%rbp
  8011db:	48 83 ec 10          	sub    $0x10,%rsp
  8011df:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8011e2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8011e6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8011ea:	8b 40 10             	mov    0x10(%rax),%eax
  8011ed:	8d 50 01             	lea    0x1(%rax),%edx
  8011f0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8011f4:	89 50 10             	mov    %edx,0x10(%rax)
  8011f7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8011fb:	48 8b 10             	mov    (%rax),%rdx
  8011fe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801202:	48 8b 40 08          	mov    0x8(%rax),%rax
  801206:	48 39 c2             	cmp    %rax,%rdx
  801209:	73 17                	jae    801222 <sprintputch+0x4b>
  80120b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80120f:	48 8b 00             	mov    (%rax),%rax
  801212:	48 8d 48 01          	lea    0x1(%rax),%rcx
  801216:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80121a:	48 89 0a             	mov    %rcx,(%rdx)
  80121d:	8b 55 fc             	mov    -0x4(%rbp),%edx
  801220:	88 10                	mov    %dl,(%rax)
  801222:	c9                   	leaveq 
  801223:	c3                   	retq   

0000000000801224 <vsnprintf>:
  801224:	55                   	push   %rbp
  801225:	48 89 e5             	mov    %rsp,%rbp
  801228:	48 83 ec 50          	sub    $0x50,%rsp
  80122c:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  801230:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  801233:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  801237:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  80123b:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  80123f:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  801243:	48 8b 0a             	mov    (%rdx),%rcx
  801246:	48 89 08             	mov    %rcx,(%rax)
  801249:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80124d:	48 89 48 08          	mov    %rcx,0x8(%rax)
  801251:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  801255:	48 89 50 10          	mov    %rdx,0x10(%rax)
  801259:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80125d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  801261:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  801264:	48 98                	cltq   
  801266:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80126a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80126e:	48 01 d0             	add    %rdx,%rax
  801271:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  801275:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  80127c:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  801281:	74 06                	je     801289 <vsnprintf+0x65>
  801283:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  801287:	7f 07                	jg     801290 <vsnprintf+0x6c>
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128e:	eb 2f                	jmp    8012bf <vsnprintf+0x9b>
  801290:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  801294:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  801298:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  80129c:	48 89 c6             	mov    %rax,%rsi
  80129f:	48 bf d7 11 80 00 00 	movabs $0x8011d7,%rdi
  8012a6:	00 00 00 
  8012a9:	48 b8 0c 0c 80 00 00 	movabs $0x800c0c,%rax
  8012b0:	00 00 00 
  8012b3:	ff d0                	callq  *%rax
  8012b5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8012b9:	c6 00 00             	movb   $0x0,(%rax)
  8012bc:	8b 45 e0             	mov    -0x20(%rbp),%eax
  8012bf:	c9                   	leaveq 
  8012c0:	c3                   	retq   

00000000008012c1 <snprintf>:
  8012c1:	55                   	push   %rbp
  8012c2:	48 89 e5             	mov    %rsp,%rbp
  8012c5:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8012cc:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  8012d3:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  8012d9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8012e0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8012e7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8012ee:	84 c0                	test   %al,%al
  8012f0:	74 20                	je     801312 <snprintf+0x51>
  8012f2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8012f6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8012fa:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8012fe:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  801302:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  801306:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80130a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80130e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  801312:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
  801319:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  801320:	00 00 00 
  801323:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  80132a:	00 00 00 
  80132d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801331:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  801338:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80133f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  801346:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  80134d:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  801354:	48 8b 0a             	mov    (%rdx),%rcx
  801357:	48 89 08             	mov    %rcx,(%rax)
  80135a:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80135e:	48 89 48 08          	mov    %rcx,0x8(%rax)
  801362:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  801366:	48 89 50 10          	mov    %rdx,0x10(%rax)
  80136a:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  801371:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  801378:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  80137e:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  801385:	48 89 c7             	mov    %rax,%rdi
  801388:	48 b8 24 12 80 00 00 	movabs $0x801224,%rax
  80138f:	00 00 00 
  801392:	ff d0                	callq  *%rax
  801394:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  80139a:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  8013a0:	c9                   	leaveq 
  8013a1:	c3                   	retq   

00000000008013a2 <strlen>:
  8013a2:	55                   	push   %rbp
  8013a3:	48 89 e5             	mov    %rsp,%rbp
  8013a6:	48 83 ec 18          	sub    $0x18,%rsp
  8013aa:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8013ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8013b5:	eb 09                	jmp    8013c0 <strlen+0x1e>
  8013b7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8013bb:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8013c0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8013c4:	0f b6 00             	movzbl (%rax),%eax
  8013c7:	84 c0                	test   %al,%al
  8013c9:	75 ec                	jne    8013b7 <strlen+0x15>
  8013cb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8013ce:	c9                   	leaveq 
  8013cf:	c3                   	retq   

00000000008013d0 <strnlen>:
  8013d0:	55                   	push   %rbp
  8013d1:	48 89 e5             	mov    %rsp,%rbp
  8013d4:	48 83 ec 20          	sub    $0x20,%rsp
  8013d8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8013dc:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8013e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8013e7:	eb 0e                	jmp    8013f7 <strnlen+0x27>
  8013e9:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8013ed:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8013f2:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  8013f7:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8013fc:	74 0b                	je     801409 <strnlen+0x39>
  8013fe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801402:	0f b6 00             	movzbl (%rax),%eax
  801405:	84 c0                	test   %al,%al
  801407:	75 e0                	jne    8013e9 <strnlen+0x19>
  801409:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80140c:	c9                   	leaveq 
  80140d:	c3                   	retq   

000000000080140e <strcpy>:
  80140e:	55                   	push   %rbp
  80140f:	48 89 e5             	mov    %rsp,%rbp
  801412:	48 83 ec 20          	sub    $0x20,%rsp
  801416:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80141a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80141e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801422:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801426:	90                   	nop
  801427:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80142b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80142f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801433:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801437:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  80143b:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  80143f:	0f b6 12             	movzbl (%rdx),%edx
  801442:	88 10                	mov    %dl,(%rax)
  801444:	0f b6 00             	movzbl (%rax),%eax
  801447:	84 c0                	test   %al,%al
  801449:	75 dc                	jne    801427 <strcpy+0x19>
  80144b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80144f:	c9                   	leaveq 
  801450:	c3                   	retq   

0000000000801451 <strcat>:
  801451:	55                   	push   %rbp
  801452:	48 89 e5             	mov    %rsp,%rbp
  801455:	48 83 ec 20          	sub    $0x20,%rsp
  801459:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80145d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801461:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801465:	48 89 c7             	mov    %rax,%rdi
  801468:	48 b8 a2 13 80 00 00 	movabs $0x8013a2,%rax
  80146f:	00 00 00 
  801472:	ff d0                	callq  *%rax
  801474:	89 45 fc             	mov    %eax,-0x4(%rbp)
  801477:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80147a:	48 63 d0             	movslq %eax,%rdx
  80147d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801481:	48 01 c2             	add    %rax,%rdx
  801484:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801488:	48 89 c6             	mov    %rax,%rsi
  80148b:	48 89 d7             	mov    %rdx,%rdi
  80148e:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  801495:	00 00 00 
  801498:	ff d0                	callq  *%rax
  80149a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80149e:	c9                   	leaveq 
  80149f:	c3                   	retq   

00000000008014a0 <strncpy>:
  8014a0:	55                   	push   %rbp
  8014a1:	48 89 e5             	mov    %rsp,%rbp
  8014a4:	48 83 ec 28          	sub    $0x28,%rsp
  8014a8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8014ac:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8014b0:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8014b4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014b8:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8014bc:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8014c3:	00 
  8014c4:	eb 2a                	jmp    8014f0 <strncpy+0x50>
  8014c6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014ca:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8014ce:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8014d2:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8014d6:	0f b6 12             	movzbl (%rdx),%edx
  8014d9:	88 10                	mov    %dl,(%rax)
  8014db:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8014df:	0f b6 00             	movzbl (%rax),%eax
  8014e2:	84 c0                	test   %al,%al
  8014e4:	74 05                	je     8014eb <strncpy+0x4b>
  8014e6:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
  8014eb:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8014f0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8014f4:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8014f8:	72 cc                	jb     8014c6 <strncpy+0x26>
  8014fa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8014fe:	c9                   	leaveq 
  8014ff:	c3                   	retq   

0000000000801500 <strlcpy>:
  801500:	55                   	push   %rbp
  801501:	48 89 e5             	mov    %rsp,%rbp
  801504:	48 83 ec 28          	sub    $0x28,%rsp
  801508:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80150c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801510:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801514:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801518:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80151c:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  801521:	74 3d                	je     801560 <strlcpy+0x60>
  801523:	eb 1d                	jmp    801542 <strlcpy+0x42>
  801525:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801529:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80152d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801531:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801535:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  801539:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  80153d:	0f b6 12             	movzbl (%rdx),%edx
  801540:	88 10                	mov    %dl,(%rax)
  801542:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  801547:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80154c:	74 0b                	je     801559 <strlcpy+0x59>
  80154e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801552:	0f b6 00             	movzbl (%rax),%eax
  801555:	84 c0                	test   %al,%al
  801557:	75 cc                	jne    801525 <strlcpy+0x25>
  801559:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80155d:	c6 00 00             	movb   $0x0,(%rax)
  801560:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801564:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801568:	48 29 c2             	sub    %rax,%rdx
  80156b:	48 89 d0             	mov    %rdx,%rax
  80156e:	c9                   	leaveq 
  80156f:	c3                   	retq   

0000000000801570 <strcmp>:
  801570:	55                   	push   %rbp
  801571:	48 89 e5             	mov    %rsp,%rbp
  801574:	48 83 ec 10          	sub    $0x10,%rsp
  801578:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80157c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801580:	eb 0a                	jmp    80158c <strcmp+0x1c>
  801582:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801587:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  80158c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801590:	0f b6 00             	movzbl (%rax),%eax
  801593:	84 c0                	test   %al,%al
  801595:	74 12                	je     8015a9 <strcmp+0x39>
  801597:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80159b:	0f b6 10             	movzbl (%rax),%edx
  80159e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8015a2:	0f b6 00             	movzbl (%rax),%eax
  8015a5:	38 c2                	cmp    %al,%dl
  8015a7:	74 d9                	je     801582 <strcmp+0x12>
  8015a9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8015ad:	0f b6 00             	movzbl (%rax),%eax
  8015b0:	0f b6 d0             	movzbl %al,%edx
  8015b3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8015b7:	0f b6 00             	movzbl (%rax),%eax
  8015ba:	0f b6 c0             	movzbl %al,%eax
  8015bd:	29 c2                	sub    %eax,%edx
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	c9                   	leaveq 
  8015c2:	c3                   	retq   

00000000008015c3 <strncmp>:
  8015c3:	55                   	push   %rbp
  8015c4:	48 89 e5             	mov    %rsp,%rbp
  8015c7:	48 83 ec 18          	sub    $0x18,%rsp
  8015cb:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8015cf:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8015d3:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8015d7:	eb 0f                	jmp    8015e8 <strncmp+0x25>
  8015d9:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  8015de:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8015e3:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  8015e8:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8015ed:	74 1d                	je     80160c <strncmp+0x49>
  8015ef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8015f3:	0f b6 00             	movzbl (%rax),%eax
  8015f6:	84 c0                	test   %al,%al
  8015f8:	74 12                	je     80160c <strncmp+0x49>
  8015fa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8015fe:	0f b6 10             	movzbl (%rax),%edx
  801601:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801605:	0f b6 00             	movzbl (%rax),%eax
  801608:	38 c2                	cmp    %al,%dl
  80160a:	74 cd                	je     8015d9 <strncmp+0x16>
  80160c:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801611:	75 07                	jne    80161a <strncmp+0x57>
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
  801618:	eb 18                	jmp    801632 <strncmp+0x6f>
  80161a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80161e:	0f b6 00             	movzbl (%rax),%eax
  801621:	0f b6 d0             	movzbl %al,%edx
  801624:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801628:	0f b6 00             	movzbl (%rax),%eax
  80162b:	0f b6 c0             	movzbl %al,%eax
  80162e:	29 c2                	sub    %eax,%edx
  801630:	89 d0                	mov    %edx,%eax
  801632:	c9                   	leaveq 
  801633:	c3                   	retq   

0000000000801634 <strchr>:
  801634:	55                   	push   %rbp
  801635:	48 89 e5             	mov    %rsp,%rbp
  801638:	48 83 ec 0c          	sub    $0xc,%rsp
  80163c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801640:	89 f0                	mov    %esi,%eax
  801642:	88 45 f4             	mov    %al,-0xc(%rbp)
  801645:	eb 17                	jmp    80165e <strchr+0x2a>
  801647:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80164b:	0f b6 00             	movzbl (%rax),%eax
  80164e:	3a 45 f4             	cmp    -0xc(%rbp),%al
  801651:	75 06                	jne    801659 <strchr+0x25>
  801653:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801657:	eb 15                	jmp    80166e <strchr+0x3a>
  801659:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80165e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801662:	0f b6 00             	movzbl (%rax),%eax
  801665:	84 c0                	test   %al,%al
  801667:	75 de                	jne    801647 <strchr+0x13>
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
  80166e:	c9                   	leaveq 
  80166f:	c3                   	retq   

0000000000801670 <strfind>:
  801670:	55                   	push   %rbp
  801671:	48 89 e5             	mov    %rsp,%rbp
  801674:	48 83 ec 0c          	sub    $0xc,%rsp
  801678:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80167c:	89 f0                	mov    %esi,%eax
  80167e:	88 45 f4             	mov    %al,-0xc(%rbp)
  801681:	eb 13                	jmp    801696 <strfind+0x26>
  801683:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801687:	0f b6 00             	movzbl (%rax),%eax
  80168a:	3a 45 f4             	cmp    -0xc(%rbp),%al
  80168d:	75 02                	jne    801691 <strfind+0x21>
  80168f:	eb 10                	jmp    8016a1 <strfind+0x31>
  801691:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801696:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80169a:	0f b6 00             	movzbl (%rax),%eax
  80169d:	84 c0                	test   %al,%al
  80169f:	75 e2                	jne    801683 <strfind+0x13>
  8016a1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016a5:	c9                   	leaveq 
  8016a6:	c3                   	retq   

00000000008016a7 <memset>:
  8016a7:	55                   	push   %rbp
  8016a8:	48 89 e5             	mov    %rsp,%rbp
  8016ab:	48 83 ec 18          	sub    $0x18,%rsp
  8016af:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8016b3:	89 75 f4             	mov    %esi,-0xc(%rbp)
  8016b6:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8016ba:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8016bf:	75 06                	jne    8016c7 <memset+0x20>
  8016c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016c5:	eb 69                	jmp    801730 <memset+0x89>
  8016c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016cb:	83 e0 03             	and    $0x3,%eax
  8016ce:	48 85 c0             	test   %rax,%rax
  8016d1:	75 48                	jne    80171b <memset+0x74>
  8016d3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8016d7:	83 e0 03             	and    $0x3,%eax
  8016da:	48 85 c0             	test   %rax,%rax
  8016dd:	75 3c                	jne    80171b <memset+0x74>
  8016df:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
  8016e6:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8016e9:	c1 e0 18             	shl    $0x18,%eax
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8016f1:	c1 e0 10             	shl    $0x10,%eax
  8016f4:	09 c2                	or     %eax,%edx
  8016f6:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8016f9:	c1 e0 08             	shl    $0x8,%eax
  8016fc:	09 d0                	or     %edx,%eax
  8016fe:	09 45 f4             	or     %eax,-0xc(%rbp)
  801701:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801705:	48 c1 e8 02          	shr    $0x2,%rax
  801709:	48 89 c1             	mov    %rax,%rcx
  80170c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801710:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801713:	48 89 d7             	mov    %rdx,%rdi
  801716:	fc                   	cld    
  801717:	f3 ab                	rep stos %eax,%es:(%rdi)
  801719:	eb 11                	jmp    80172c <memset+0x85>
  80171b:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80171f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801722:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801726:	48 89 d7             	mov    %rdx,%rdi
  801729:	fc                   	cld    
  80172a:	f3 aa                	rep stos %al,%es:(%rdi)
  80172c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801730:	c9                   	leaveq 
  801731:	c3                   	retq   

0000000000801732 <memmove>:
  801732:	55                   	push   %rbp
  801733:	48 89 e5             	mov    %rsp,%rbp
  801736:	48 83 ec 28          	sub    $0x28,%rsp
  80173a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80173e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801742:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801746:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80174a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80174e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801752:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801756:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80175a:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  80175e:	0f 83 88 00 00 00    	jae    8017ec <memmove+0xba>
  801764:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801768:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80176c:	48 01 d0             	add    %rdx,%rax
  80176f:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  801773:	76 77                	jbe    8017ec <memmove+0xba>
  801775:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801779:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  80177d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801781:	48 01 45 f0          	add    %rax,-0x10(%rbp)
  801785:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801789:	83 e0 03             	and    $0x3,%eax
  80178c:	48 85 c0             	test   %rax,%rax
  80178f:	75 3b                	jne    8017cc <memmove+0x9a>
  801791:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801795:	83 e0 03             	and    $0x3,%eax
  801798:	48 85 c0             	test   %rax,%rax
  80179b:	75 2f                	jne    8017cc <memmove+0x9a>
  80179d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017a1:	83 e0 03             	and    $0x3,%eax
  8017a4:	48 85 c0             	test   %rax,%rax
  8017a7:	75 23                	jne    8017cc <memmove+0x9a>
  8017a9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8017ad:	48 83 e8 04          	sub    $0x4,%rax
  8017b1:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8017b5:	48 83 ea 04          	sub    $0x4,%rdx
  8017b9:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8017bd:	48 c1 e9 02          	shr    $0x2,%rcx
  8017c1:	48 89 c7             	mov    %rax,%rdi
  8017c4:	48 89 d6             	mov    %rdx,%rsi
  8017c7:	fd                   	std    
  8017c8:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8017ca:	eb 1d                	jmp    8017e9 <memmove+0xb7>
  8017cc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8017d0:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8017d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017d8:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
  8017dc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017e0:	48 89 d7             	mov    %rdx,%rdi
  8017e3:	48 89 c1             	mov    %rax,%rcx
  8017e6:	fd                   	std    
  8017e7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  8017e9:	fc                   	cld    
  8017ea:	eb 57                	jmp    801843 <memmove+0x111>
  8017ec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017f0:	83 e0 03             	and    $0x3,%eax
  8017f3:	48 85 c0             	test   %rax,%rax
  8017f6:	75 36                	jne    80182e <memmove+0xfc>
  8017f8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8017fc:	83 e0 03             	and    $0x3,%eax
  8017ff:	48 85 c0             	test   %rax,%rax
  801802:	75 2a                	jne    80182e <memmove+0xfc>
  801804:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801808:	83 e0 03             	and    $0x3,%eax
  80180b:	48 85 c0             	test   %rax,%rax
  80180e:	75 1e                	jne    80182e <memmove+0xfc>
  801810:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801814:	48 c1 e8 02          	shr    $0x2,%rax
  801818:	48 89 c1             	mov    %rax,%rcx
  80181b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80181f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801823:	48 89 c7             	mov    %rax,%rdi
  801826:	48 89 d6             	mov    %rdx,%rsi
  801829:	fc                   	cld    
  80182a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80182c:	eb 15                	jmp    801843 <memmove+0x111>
  80182e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801832:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801836:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  80183a:	48 89 c7             	mov    %rax,%rdi
  80183d:	48 89 d6             	mov    %rdx,%rsi
  801840:	fc                   	cld    
  801841:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  801843:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801847:	c9                   	leaveq 
  801848:	c3                   	retq   

0000000000801849 <memcpy>:
  801849:	55                   	push   %rbp
  80184a:	48 89 e5             	mov    %rsp,%rbp
  80184d:	48 83 ec 18          	sub    $0x18,%rsp
  801851:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801855:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801859:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80185d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801861:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  801865:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801869:	48 89 ce             	mov    %rcx,%rsi
  80186c:	48 89 c7             	mov    %rax,%rdi
  80186f:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  801876:	00 00 00 
  801879:	ff d0                	callq  *%rax
  80187b:	c9                   	leaveq 
  80187c:	c3                   	retq   

000000000080187d <memcmp>:
  80187d:	55                   	push   %rbp
  80187e:	48 89 e5             	mov    %rsp,%rbp
  801881:	48 83 ec 28          	sub    $0x28,%rsp
  801885:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801889:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80188d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801891:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801895:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801899:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80189d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8018a1:	eb 36                	jmp    8018d9 <memcmp+0x5c>
  8018a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8018a7:	0f b6 10             	movzbl (%rax),%edx
  8018aa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8018ae:	0f b6 00             	movzbl (%rax),%eax
  8018b1:	38 c2                	cmp    %al,%dl
  8018b3:	74 1a                	je     8018cf <memcmp+0x52>
  8018b5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8018b9:	0f b6 00             	movzbl (%rax),%eax
  8018bc:	0f b6 d0             	movzbl %al,%edx
  8018bf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8018c3:	0f b6 00             	movzbl (%rax),%eax
  8018c6:	0f b6 c0             	movzbl %al,%eax
  8018c9:	29 c2                	sub    %eax,%edx
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	eb 20                	jmp    8018ef <memcmp+0x72>
  8018cf:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8018d4:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  8018d9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8018dd:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8018e1:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8018e5:	48 85 c0             	test   %rax,%rax
  8018e8:	75 b9                	jne    8018a3 <memcmp+0x26>
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ef:	c9                   	leaveq 
  8018f0:	c3                   	retq   

00000000008018f1 <memfind>:
  8018f1:	55                   	push   %rbp
  8018f2:	48 89 e5             	mov    %rsp,%rbp
  8018f5:	48 83 ec 28          	sub    $0x28,%rsp
  8018f9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8018fd:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  801900:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801904:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801908:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80190c:	48 01 d0             	add    %rdx,%rax
  80190f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801913:	eb 15                	jmp    80192a <memfind+0x39>
  801915:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801919:	0f b6 10             	movzbl (%rax),%edx
  80191c:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80191f:	38 c2                	cmp    %al,%dl
  801921:	75 02                	jne    801925 <memfind+0x34>
  801923:	eb 0f                	jmp    801934 <memfind+0x43>
  801925:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  80192a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80192e:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  801932:	72 e1                	jb     801915 <memfind+0x24>
  801934:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801938:	c9                   	leaveq 
  801939:	c3                   	retq   

000000000080193a <strtol>:
  80193a:	55                   	push   %rbp
  80193b:	48 89 e5             	mov    %rsp,%rbp
  80193e:	48 83 ec 34          	sub    $0x34,%rsp
  801942:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801946:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  80194a:	89 55 cc             	mov    %edx,-0x34(%rbp)
  80194d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801954:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  80195b:	00 
  80195c:	eb 05                	jmp    801963 <strtol+0x29>
  80195e:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801963:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801967:	0f b6 00             	movzbl (%rax),%eax
  80196a:	3c 20                	cmp    $0x20,%al
  80196c:	74 f0                	je     80195e <strtol+0x24>
  80196e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801972:	0f b6 00             	movzbl (%rax),%eax
  801975:	3c 09                	cmp    $0x9,%al
  801977:	74 e5                	je     80195e <strtol+0x24>
  801979:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80197d:	0f b6 00             	movzbl (%rax),%eax
  801980:	3c 2b                	cmp    $0x2b,%al
  801982:	75 07                	jne    80198b <strtol+0x51>
  801984:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801989:	eb 17                	jmp    8019a2 <strtol+0x68>
  80198b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80198f:	0f b6 00             	movzbl (%rax),%eax
  801992:	3c 2d                	cmp    $0x2d,%al
  801994:	75 0c                	jne    8019a2 <strtol+0x68>
  801996:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  80199b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  8019a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8019a6:	74 06                	je     8019ae <strtol+0x74>
  8019a8:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  8019ac:	75 28                	jne    8019d6 <strtol+0x9c>
  8019ae:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8019b2:	0f b6 00             	movzbl (%rax),%eax
  8019b5:	3c 30                	cmp    $0x30,%al
  8019b7:	75 1d                	jne    8019d6 <strtol+0x9c>
  8019b9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8019bd:	48 83 c0 01          	add    $0x1,%rax
  8019c1:	0f b6 00             	movzbl (%rax),%eax
  8019c4:	3c 78                	cmp    $0x78,%al
  8019c6:	75 0e                	jne    8019d6 <strtol+0x9c>
  8019c8:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  8019cd:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  8019d4:	eb 2c                	jmp    801a02 <strtol+0xc8>
  8019d6:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8019da:	75 19                	jne    8019f5 <strtol+0xbb>
  8019dc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8019e0:	0f b6 00             	movzbl (%rax),%eax
  8019e3:	3c 30                	cmp    $0x30,%al
  8019e5:	75 0e                	jne    8019f5 <strtol+0xbb>
  8019e7:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8019ec:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  8019f3:	eb 0d                	jmp    801a02 <strtol+0xc8>
  8019f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8019f9:	75 07                	jne    801a02 <strtol+0xc8>
  8019fb:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)
  801a02:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a06:	0f b6 00             	movzbl (%rax),%eax
  801a09:	3c 2f                	cmp    $0x2f,%al
  801a0b:	7e 1d                	jle    801a2a <strtol+0xf0>
  801a0d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a11:	0f b6 00             	movzbl (%rax),%eax
  801a14:	3c 39                	cmp    $0x39,%al
  801a16:	7f 12                	jg     801a2a <strtol+0xf0>
  801a18:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a1c:	0f b6 00             	movzbl (%rax),%eax
  801a1f:	0f be c0             	movsbl %al,%eax
  801a22:	83 e8 30             	sub    $0x30,%eax
  801a25:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801a28:	eb 4e                	jmp    801a78 <strtol+0x13e>
  801a2a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a2e:	0f b6 00             	movzbl (%rax),%eax
  801a31:	3c 60                	cmp    $0x60,%al
  801a33:	7e 1d                	jle    801a52 <strtol+0x118>
  801a35:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a39:	0f b6 00             	movzbl (%rax),%eax
  801a3c:	3c 7a                	cmp    $0x7a,%al
  801a3e:	7f 12                	jg     801a52 <strtol+0x118>
  801a40:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a44:	0f b6 00             	movzbl (%rax),%eax
  801a47:	0f be c0             	movsbl %al,%eax
  801a4a:	83 e8 57             	sub    $0x57,%eax
  801a4d:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801a50:	eb 26                	jmp    801a78 <strtol+0x13e>
  801a52:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a56:	0f b6 00             	movzbl (%rax),%eax
  801a59:	3c 40                	cmp    $0x40,%al
  801a5b:	7e 48                	jle    801aa5 <strtol+0x16b>
  801a5d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a61:	0f b6 00             	movzbl (%rax),%eax
  801a64:	3c 5a                	cmp    $0x5a,%al
  801a66:	7f 3d                	jg     801aa5 <strtol+0x16b>
  801a68:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a6c:	0f b6 00             	movzbl (%rax),%eax
  801a6f:	0f be c0             	movsbl %al,%eax
  801a72:	83 e8 37             	sub    $0x37,%eax
  801a75:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801a78:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801a7b:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  801a7e:	7c 02                	jl     801a82 <strtol+0x148>
  801a80:	eb 23                	jmp    801aa5 <strtol+0x16b>
  801a82:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801a87:	8b 45 cc             	mov    -0x34(%rbp),%eax
  801a8a:	48 98                	cltq   
  801a8c:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  801a91:	48 89 c2             	mov    %rax,%rdx
  801a94:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801a97:	48 98                	cltq   
  801a99:	48 01 d0             	add    %rdx,%rax
  801a9c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801aa0:	e9 5d ff ff ff       	jmpq   801a02 <strtol+0xc8>
  801aa5:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  801aaa:	74 0b                	je     801ab7 <strtol+0x17d>
  801aac:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801ab0:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  801ab4:	48 89 10             	mov    %rdx,(%rax)
  801ab7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  801abb:	74 09                	je     801ac6 <strtol+0x18c>
  801abd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801ac1:	48 f7 d8             	neg    %rax
  801ac4:	eb 04                	jmp    801aca <strtol+0x190>
  801ac6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801aca:	c9                   	leaveq 
  801acb:	c3                   	retq   

0000000000801acc <strstr>:
  801acc:	55                   	push   %rbp
  801acd:	48 89 e5             	mov    %rsp,%rbp
  801ad0:	48 83 ec 30          	sub    $0x30,%rsp
  801ad4:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801ad8:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  801adc:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801ae0:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801ae4:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801ae8:	0f b6 00             	movzbl (%rax),%eax
  801aeb:	88 45 ff             	mov    %al,-0x1(%rbp)
  801aee:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  801af2:	75 06                	jne    801afa <strstr+0x2e>
  801af4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801af8:	eb 6b                	jmp    801b65 <strstr+0x99>
  801afa:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801afe:	48 89 c7             	mov    %rax,%rdi
  801b01:	48 b8 a2 13 80 00 00 	movabs $0x8013a2,%rax
  801b08:	00 00 00 
  801b0b:	ff d0                	callq  *%rax
  801b0d:	48 98                	cltq   
  801b0f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801b13:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b17:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801b1b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801b1f:	0f b6 00             	movzbl (%rax),%eax
  801b22:	88 45 ef             	mov    %al,-0x11(%rbp)
  801b25:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  801b29:	75 07                	jne    801b32 <strstr+0x66>
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b30:	eb 33                	jmp    801b65 <strstr+0x99>
  801b32:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  801b36:	3a 45 ff             	cmp    -0x1(%rbp),%al
  801b39:	75 d8                	jne    801b13 <strstr+0x47>
  801b3b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801b3f:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  801b43:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b47:	48 89 ce             	mov    %rcx,%rsi
  801b4a:	48 89 c7             	mov    %rax,%rdi
  801b4d:	48 b8 c3 15 80 00 00 	movabs $0x8015c3,%rax
  801b54:	00 00 00 
  801b57:	ff d0                	callq  *%rax
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	75 b6                	jne    801b13 <strstr+0x47>
  801b5d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b61:	48 83 e8 01          	sub    $0x1,%rax
  801b65:	c9                   	leaveq 
  801b66:	c3                   	retq   

0000000000801b67 <syscall>:
  801b67:	55                   	push   %rbp
  801b68:	48 89 e5             	mov    %rsp,%rbp
  801b6b:	53                   	push   %rbx
  801b6c:	48 83 ec 48          	sub    $0x48,%rsp
  801b70:	89 7d dc             	mov    %edi,-0x24(%rbp)
  801b73:	89 75 d8             	mov    %esi,-0x28(%rbp)
  801b76:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801b7a:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  801b7e:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  801b82:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
  801b86:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801b89:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  801b8d:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  801b91:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  801b95:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  801b99:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  801b9d:	4c 89 c3             	mov    %r8,%rbx
  801ba0:	cd 30                	int    $0x30
  801ba2:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801ba6:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  801baa:	74 3e                	je     801bea <syscall+0x83>
  801bac:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801bb1:	7e 37                	jle    801bea <syscall+0x83>
  801bb3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801bb7:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801bba:	49 89 d0             	mov    %rdx,%r8
  801bbd:	89 c1                	mov    %eax,%ecx
  801bbf:	48 ba 08 4d 80 00 00 	movabs $0x804d08,%rdx
  801bc6:	00 00 00 
  801bc9:	be 24 00 00 00       	mov    $0x24,%esi
  801bce:	48 bf 25 4d 80 00 00 	movabs $0x804d25,%rdi
  801bd5:	00 00 00 
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdd:	49 b9 63 43 80 00 00 	movabs $0x804363,%r9
  801be4:	00 00 00 
  801be7:	41 ff d1             	callq  *%r9
  801bea:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801bee:	48 83 c4 48          	add    $0x48,%rsp
  801bf2:	5b                   	pop    %rbx
  801bf3:	5d                   	pop    %rbp
  801bf4:	c3                   	retq   

0000000000801bf5 <sys_cputs>:
  801bf5:	55                   	push   %rbp
  801bf6:	48 89 e5             	mov    %rsp,%rbp
  801bf9:	48 83 ec 20          	sub    $0x20,%rsp
  801bfd:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801c01:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801c05:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801c09:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801c0d:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c14:	00 
  801c15:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c1b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801c21:	48 89 d1             	mov    %rdx,%rcx
  801c24:	48 89 c2             	mov    %rax,%rdx
  801c27:	be 00 00 00 00       	mov    $0x0,%esi
  801c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801c31:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801c38:	00 00 00 
  801c3b:	ff d0                	callq  *%rax
  801c3d:	c9                   	leaveq 
  801c3e:	c3                   	retq   

0000000000801c3f <sys_cgetc>:
  801c3f:	55                   	push   %rbp
  801c40:	48 89 e5             	mov    %rsp,%rbp
  801c43:	48 83 ec 10          	sub    $0x10,%rsp
  801c47:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c4e:	00 
  801c4f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c55:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c60:	ba 00 00 00 00       	mov    $0x0,%edx
  801c65:	be 00 00 00 00       	mov    $0x0,%esi
  801c6a:	bf 01 00 00 00       	mov    $0x1,%edi
  801c6f:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801c76:	00 00 00 
  801c79:	ff d0                	callq  *%rax
  801c7b:	c9                   	leaveq 
  801c7c:	c3                   	retq   

0000000000801c7d <sys_env_destroy>:
  801c7d:	55                   	push   %rbp
  801c7e:	48 89 e5             	mov    %rsp,%rbp
  801c81:	48 83 ec 10          	sub    $0x10,%rsp
  801c85:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801c88:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801c8b:	48 98                	cltq   
  801c8d:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c94:	00 
  801c95:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c9b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ca6:	48 89 c2             	mov    %rax,%rdx
  801ca9:	be 01 00 00 00       	mov    $0x1,%esi
  801cae:	bf 03 00 00 00       	mov    $0x3,%edi
  801cb3:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801cba:	00 00 00 
  801cbd:	ff d0                	callq  *%rax
  801cbf:	c9                   	leaveq 
  801cc0:	c3                   	retq   

0000000000801cc1 <sys_getenvid>:
  801cc1:	55                   	push   %rbp
  801cc2:	48 89 e5             	mov    %rsp,%rbp
  801cc5:	48 83 ec 10          	sub    $0x10,%rsp
  801cc9:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801cd0:	00 
  801cd1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801cd7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce7:	be 00 00 00 00       	mov    $0x0,%esi
  801cec:	bf 02 00 00 00       	mov    $0x2,%edi
  801cf1:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801cf8:	00 00 00 
  801cfb:	ff d0                	callq  *%rax
  801cfd:	c9                   	leaveq 
  801cfe:	c3                   	retq   

0000000000801cff <sys_yield>:
  801cff:	55                   	push   %rbp
  801d00:	48 89 e5             	mov    %rsp,%rbp
  801d03:	48 83 ec 10          	sub    $0x10,%rsp
  801d07:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d0e:	00 
  801d0f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d15:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801d1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d20:	ba 00 00 00 00       	mov    $0x0,%edx
  801d25:	be 00 00 00 00       	mov    $0x0,%esi
  801d2a:	bf 0b 00 00 00       	mov    $0xb,%edi
  801d2f:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801d36:	00 00 00 
  801d39:	ff d0                	callq  *%rax
  801d3b:	c9                   	leaveq 
  801d3c:	c3                   	retq   

0000000000801d3d <sys_page_alloc>:
  801d3d:	55                   	push   %rbp
  801d3e:	48 89 e5             	mov    %rsp,%rbp
  801d41:	48 83 ec 20          	sub    $0x20,%rsp
  801d45:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801d48:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801d4c:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801d4f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801d52:	48 63 c8             	movslq %eax,%rcx
  801d55:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801d59:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801d5c:	48 98                	cltq   
  801d5e:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d65:	00 
  801d66:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d6c:	49 89 c8             	mov    %rcx,%r8
  801d6f:	48 89 d1             	mov    %rdx,%rcx
  801d72:	48 89 c2             	mov    %rax,%rdx
  801d75:	be 01 00 00 00       	mov    $0x1,%esi
  801d7a:	bf 04 00 00 00       	mov    $0x4,%edi
  801d7f:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801d86:	00 00 00 
  801d89:	ff d0                	callq  *%rax
  801d8b:	c9                   	leaveq 
  801d8c:	c3                   	retq   

0000000000801d8d <sys_page_map>:
  801d8d:	55                   	push   %rbp
  801d8e:	48 89 e5             	mov    %rsp,%rbp
  801d91:	48 83 ec 30          	sub    $0x30,%rsp
  801d95:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801d98:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801d9c:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801d9f:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  801da3:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  801da7:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  801daa:	48 63 c8             	movslq %eax,%rcx
  801dad:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  801db1:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801db4:	48 63 f0             	movslq %eax,%rsi
  801db7:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801dbb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801dbe:	48 98                	cltq   
  801dc0:	48 89 0c 24          	mov    %rcx,(%rsp)
  801dc4:	49 89 f9             	mov    %rdi,%r9
  801dc7:	49 89 f0             	mov    %rsi,%r8
  801dca:	48 89 d1             	mov    %rdx,%rcx
  801dcd:	48 89 c2             	mov    %rax,%rdx
  801dd0:	be 01 00 00 00       	mov    $0x1,%esi
  801dd5:	bf 05 00 00 00       	mov    $0x5,%edi
  801dda:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801de1:	00 00 00 
  801de4:	ff d0                	callq  *%rax
  801de6:	c9                   	leaveq 
  801de7:	c3                   	retq   

0000000000801de8 <sys_page_unmap>:
  801de8:	55                   	push   %rbp
  801de9:	48 89 e5             	mov    %rsp,%rbp
  801dec:	48 83 ec 20          	sub    $0x20,%rsp
  801df0:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801df3:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801df7:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801dfb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801dfe:	48 98                	cltq   
  801e00:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e07:	00 
  801e08:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801e0e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e14:	48 89 d1             	mov    %rdx,%rcx
  801e17:	48 89 c2             	mov    %rax,%rdx
  801e1a:	be 01 00 00 00       	mov    $0x1,%esi
  801e1f:	bf 06 00 00 00       	mov    $0x6,%edi
  801e24:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801e2b:	00 00 00 
  801e2e:	ff d0                	callq  *%rax
  801e30:	c9                   	leaveq 
  801e31:	c3                   	retq   

0000000000801e32 <sys_env_set_status>:
  801e32:	55                   	push   %rbp
  801e33:	48 89 e5             	mov    %rsp,%rbp
  801e36:	48 83 ec 10          	sub    $0x10,%rsp
  801e3a:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801e3d:	89 75 f8             	mov    %esi,-0x8(%rbp)
  801e40:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801e43:	48 63 d0             	movslq %eax,%rdx
  801e46:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801e49:	48 98                	cltq   
  801e4b:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e52:	00 
  801e53:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801e59:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e5f:	48 89 d1             	mov    %rdx,%rcx
  801e62:	48 89 c2             	mov    %rax,%rdx
  801e65:	be 01 00 00 00       	mov    $0x1,%esi
  801e6a:	bf 08 00 00 00       	mov    $0x8,%edi
  801e6f:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801e76:	00 00 00 
  801e79:	ff d0                	callq  *%rax
  801e7b:	c9                   	leaveq 
  801e7c:	c3                   	retq   

0000000000801e7d <sys_env_set_trapframe>:
  801e7d:	55                   	push   %rbp
  801e7e:	48 89 e5             	mov    %rsp,%rbp
  801e81:	48 83 ec 20          	sub    $0x20,%rsp
  801e85:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801e88:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801e8c:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801e90:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801e93:	48 98                	cltq   
  801e95:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e9c:	00 
  801e9d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801ea3:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801ea9:	48 89 d1             	mov    %rdx,%rcx
  801eac:	48 89 c2             	mov    %rax,%rdx
  801eaf:	be 01 00 00 00       	mov    $0x1,%esi
  801eb4:	bf 09 00 00 00       	mov    $0x9,%edi
  801eb9:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801ec0:	00 00 00 
  801ec3:	ff d0                	callq  *%rax
  801ec5:	c9                   	leaveq 
  801ec6:	c3                   	retq   

0000000000801ec7 <sys_env_set_pgfault_upcall>:
  801ec7:	55                   	push   %rbp
  801ec8:	48 89 e5             	mov    %rsp,%rbp
  801ecb:	48 83 ec 20          	sub    $0x20,%rsp
  801ecf:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801ed2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801ed6:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801eda:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801edd:	48 98                	cltq   
  801edf:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801ee6:	00 
  801ee7:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801eed:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801ef3:	48 89 d1             	mov    %rdx,%rcx
  801ef6:	48 89 c2             	mov    %rax,%rdx
  801ef9:	be 01 00 00 00       	mov    $0x1,%esi
  801efe:	bf 0a 00 00 00       	mov    $0xa,%edi
  801f03:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801f0a:	00 00 00 
  801f0d:	ff d0                	callq  *%rax
  801f0f:	c9                   	leaveq 
  801f10:	c3                   	retq   

0000000000801f11 <sys_ipc_try_send>:
  801f11:	55                   	push   %rbp
  801f12:	48 89 e5             	mov    %rsp,%rbp
  801f15:	48 83 ec 20          	sub    $0x20,%rsp
  801f19:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801f1c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801f20:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801f24:	89 4d f8             	mov    %ecx,-0x8(%rbp)
  801f27:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801f2a:	48 63 f0             	movslq %eax,%rsi
  801f2d:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801f31:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f34:	48 98                	cltq   
  801f36:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801f3a:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801f41:	00 
  801f42:	49 89 f1             	mov    %rsi,%r9
  801f45:	49 89 c8             	mov    %rcx,%r8
  801f48:	48 89 d1             	mov    %rdx,%rcx
  801f4b:	48 89 c2             	mov    %rax,%rdx
  801f4e:	be 00 00 00 00       	mov    $0x0,%esi
  801f53:	bf 0c 00 00 00       	mov    $0xc,%edi
  801f58:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801f5f:	00 00 00 
  801f62:	ff d0                	callq  *%rax
  801f64:	c9                   	leaveq 
  801f65:	c3                   	retq   

0000000000801f66 <sys_ipc_recv>:
  801f66:	55                   	push   %rbp
  801f67:	48 89 e5             	mov    %rsp,%rbp
  801f6a:	48 83 ec 10          	sub    $0x10,%rsp
  801f6e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801f72:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801f76:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801f7d:	00 
  801f7e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801f84:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801f8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f8f:	48 89 c2             	mov    %rax,%rdx
  801f92:	be 01 00 00 00       	mov    $0x1,%esi
  801f97:	bf 0d 00 00 00       	mov    $0xd,%edi
  801f9c:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801fa3:	00 00 00 
  801fa6:	ff d0                	callq  *%rax
  801fa8:	c9                   	leaveq 
  801fa9:	c3                   	retq   

0000000000801faa <sys_time_msec>:
  801faa:	55                   	push   %rbp
  801fab:	48 89 e5             	mov    %rsp,%rbp
  801fae:	48 83 ec 10          	sub    $0x10,%rsp
  801fb2:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801fb9:	00 
  801fba:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801fc0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801fc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801fcb:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd0:	be 00 00 00 00       	mov    $0x0,%esi
  801fd5:	bf 0e 00 00 00       	mov    $0xe,%edi
  801fda:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  801fe1:	00 00 00 
  801fe4:	ff d0                	callq  *%rax
  801fe6:	c9                   	leaveq 
  801fe7:	c3                   	retq   

0000000000801fe8 <sys_net_transmit>:
  801fe8:	55                   	push   %rbp
  801fe9:	48 89 e5             	mov    %rsp,%rbp
  801fec:	48 83 ec 20          	sub    $0x20,%rsp
  801ff0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801ff4:	89 75 f4             	mov    %esi,-0xc(%rbp)
  801ff7:	8b 55 f4             	mov    -0xc(%rbp),%edx
  801ffa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801ffe:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802005:	00 
  802006:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80200c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802012:	48 89 d1             	mov    %rdx,%rcx
  802015:	48 89 c2             	mov    %rax,%rdx
  802018:	be 00 00 00 00       	mov    $0x0,%esi
  80201d:	bf 0f 00 00 00       	mov    $0xf,%edi
  802022:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802029:	00 00 00 
  80202c:	ff d0                	callq  *%rax
  80202e:	c9                   	leaveq 
  80202f:	c3                   	retq   

0000000000802030 <sys_net_receive>:
  802030:	55                   	push   %rbp
  802031:	48 89 e5             	mov    %rsp,%rbp
  802034:	48 83 ec 20          	sub    $0x20,%rsp
  802038:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80203c:	89 75 f4             	mov    %esi,-0xc(%rbp)
  80203f:	8b 55 f4             	mov    -0xc(%rbp),%edx
  802042:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802046:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80204d:	00 
  80204e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802054:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80205a:	48 89 d1             	mov    %rdx,%rcx
  80205d:	48 89 c2             	mov    %rax,%rdx
  802060:	be 00 00 00 00       	mov    $0x0,%esi
  802065:	bf 10 00 00 00       	mov    $0x10,%edi
  80206a:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802071:	00 00 00 
  802074:	ff d0                	callq  *%rax
  802076:	c9                   	leaveq 
  802077:	c3                   	retq   

0000000000802078 <sys_ept_map>:
  802078:	55                   	push   %rbp
  802079:	48 89 e5             	mov    %rsp,%rbp
  80207c:	48 83 ec 30          	sub    $0x30,%rsp
  802080:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802083:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802087:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80208a:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  80208e:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  802092:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  802095:	48 63 c8             	movslq %eax,%rcx
  802098:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  80209c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80209f:	48 63 f0             	movslq %eax,%rsi
  8020a2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8020a6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8020a9:	48 98                	cltq   
  8020ab:	48 89 0c 24          	mov    %rcx,(%rsp)
  8020af:	49 89 f9             	mov    %rdi,%r9
  8020b2:	49 89 f0             	mov    %rsi,%r8
  8020b5:	48 89 d1             	mov    %rdx,%rcx
  8020b8:	48 89 c2             	mov    %rax,%rdx
  8020bb:	be 00 00 00 00       	mov    $0x0,%esi
  8020c0:	bf 11 00 00 00       	mov    $0x11,%edi
  8020c5:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  8020cc:	00 00 00 
  8020cf:	ff d0                	callq  *%rax
  8020d1:	c9                   	leaveq 
  8020d2:	c3                   	retq   

00000000008020d3 <sys_env_mkguest>:
  8020d3:	55                   	push   %rbp
  8020d4:	48 89 e5             	mov    %rsp,%rbp
  8020d7:	48 83 ec 20          	sub    $0x20,%rsp
  8020db:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8020df:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8020e3:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8020e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8020eb:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8020f2:	00 
  8020f3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8020f9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8020ff:	48 89 d1             	mov    %rdx,%rcx
  802102:	48 89 c2             	mov    %rax,%rdx
  802105:	be 00 00 00 00       	mov    $0x0,%esi
  80210a:	bf 12 00 00 00       	mov    $0x12,%edi
  80210f:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802116:	00 00 00 
  802119:	ff d0                	callq  *%rax
  80211b:	c9                   	leaveq 
  80211c:	c3                   	retq   

000000000080211d <sys_vmx_list_vms>:
  80211d:	55                   	push   %rbp
  80211e:	48 89 e5             	mov    %rsp,%rbp
  802121:	48 83 ec 10          	sub    $0x10,%rsp
  802125:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80212c:	00 
  80212d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802133:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802139:	b9 00 00 00 00       	mov    $0x0,%ecx
  80213e:	ba 00 00 00 00       	mov    $0x0,%edx
  802143:	be 00 00 00 00       	mov    $0x0,%esi
  802148:	bf 13 00 00 00       	mov    $0x13,%edi
  80214d:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802154:	00 00 00 
  802157:	ff d0                	callq  *%rax
  802159:	c9                   	leaveq 
  80215a:	c3                   	retq   

000000000080215b <sys_vmx_sel_resume>:
  80215b:	55                   	push   %rbp
  80215c:	48 89 e5             	mov    %rsp,%rbp
  80215f:	48 83 ec 10          	sub    $0x10,%rsp
  802163:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802166:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802169:	48 98                	cltq   
  80216b:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802172:	00 
  802173:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802179:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80217f:	b9 00 00 00 00       	mov    $0x0,%ecx
  802184:	48 89 c2             	mov    %rax,%rdx
  802187:	be 00 00 00 00       	mov    $0x0,%esi
  80218c:	bf 14 00 00 00       	mov    $0x14,%edi
  802191:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802198:	00 00 00 
  80219b:	ff d0                	callq  *%rax
  80219d:	c9                   	leaveq 
  80219e:	c3                   	retq   

000000000080219f <sys_vmx_get_vmdisk_number>:
  80219f:	55                   	push   %rbp
  8021a0:	48 89 e5             	mov    %rsp,%rbp
  8021a3:	48 83 ec 10          	sub    $0x10,%rsp
  8021a7:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8021ae:	00 
  8021af:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8021b5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8021bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8021c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c5:	be 00 00 00 00       	mov    $0x0,%esi
  8021ca:	bf 15 00 00 00       	mov    $0x15,%edi
  8021cf:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  8021d6:	00 00 00 
  8021d9:	ff d0                	callq  *%rax
  8021db:	c9                   	leaveq 
  8021dc:	c3                   	retq   

00000000008021dd <sys_vmx_incr_vmdisk_number>:
  8021dd:	55                   	push   %rbp
  8021de:	48 89 e5             	mov    %rsp,%rbp
  8021e1:	48 83 ec 10          	sub    $0x10,%rsp
  8021e5:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8021ec:	00 
  8021ed:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8021f3:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8021f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8021fe:	ba 00 00 00 00       	mov    $0x0,%edx
  802203:	be 00 00 00 00       	mov    $0x0,%esi
  802208:	bf 16 00 00 00       	mov    $0x16,%edi
  80220d:	48 b8 67 1b 80 00 00 	movabs $0x801b67,%rax
  802214:	00 00 00 
  802217:	ff d0                	callq  *%rax
  802219:	c9                   	leaveq 
  80221a:	c3                   	retq   

000000000080221b <fd2num>:
  80221b:	55                   	push   %rbp
  80221c:	48 89 e5             	mov    %rsp,%rbp
  80221f:	48 83 ec 08          	sub    $0x8,%rsp
  802223:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802227:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80222b:	48 b8 00 00 00 30 ff 	movabs $0xffffffff30000000,%rax
  802232:	ff ff ff 
  802235:	48 01 d0             	add    %rdx,%rax
  802238:	48 c1 e8 0c          	shr    $0xc,%rax
  80223c:	c9                   	leaveq 
  80223d:	c3                   	retq   

000000000080223e <fd2data>:
  80223e:	55                   	push   %rbp
  80223f:	48 89 e5             	mov    %rsp,%rbp
  802242:	48 83 ec 08          	sub    $0x8,%rsp
  802246:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80224a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80224e:	48 89 c7             	mov    %rax,%rdi
  802251:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  802258:	00 00 00 
  80225b:	ff d0                	callq  *%rax
  80225d:	48 05 20 00 0d 00    	add    $0xd0020,%rax
  802263:	48 c1 e0 0c          	shl    $0xc,%rax
  802267:	c9                   	leaveq 
  802268:	c3                   	retq   

0000000000802269 <fd_alloc>:
  802269:	55                   	push   %rbp
  80226a:	48 89 e5             	mov    %rsp,%rbp
  80226d:	48 83 ec 18          	sub    $0x18,%rsp
  802271:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802275:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80227c:	eb 6b                	jmp    8022e9 <fd_alloc+0x80>
  80227e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802281:	48 98                	cltq   
  802283:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802289:	48 c1 e0 0c          	shl    $0xc,%rax
  80228d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  802291:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802295:	48 c1 e8 15          	shr    $0x15,%rax
  802299:	48 89 c2             	mov    %rax,%rdx
  80229c:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8022a3:	01 00 00 
  8022a6:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8022aa:	83 e0 01             	and    $0x1,%eax
  8022ad:	48 85 c0             	test   %rax,%rax
  8022b0:	74 21                	je     8022d3 <fd_alloc+0x6a>
  8022b2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8022b6:	48 c1 e8 0c          	shr    $0xc,%rax
  8022ba:	48 89 c2             	mov    %rax,%rdx
  8022bd:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8022c4:	01 00 00 
  8022c7:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8022cb:	83 e0 01             	and    $0x1,%eax
  8022ce:	48 85 c0             	test   %rax,%rax
  8022d1:	75 12                	jne    8022e5 <fd_alloc+0x7c>
  8022d3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8022d7:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8022db:	48 89 10             	mov    %rdx,(%rax)
  8022de:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e3:	eb 1a                	jmp    8022ff <fd_alloc+0x96>
  8022e5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8022e9:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  8022ed:	7e 8f                	jle    80227e <fd_alloc+0x15>
  8022ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8022f3:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8022fa:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8022ff:	c9                   	leaveq 
  802300:	c3                   	retq   

0000000000802301 <fd_lookup>:
  802301:	55                   	push   %rbp
  802302:	48 89 e5             	mov    %rsp,%rbp
  802305:	48 83 ec 20          	sub    $0x20,%rsp
  802309:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80230c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802310:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  802314:	78 06                	js     80231c <fd_lookup+0x1b>
  802316:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%rbp)
  80231a:	7e 07                	jle    802323 <fd_lookup+0x22>
  80231c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802321:	eb 6c                	jmp    80238f <fd_lookup+0x8e>
  802323:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802326:	48 98                	cltq   
  802328:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  80232e:	48 c1 e0 0c          	shl    $0xc,%rax
  802332:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  802336:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80233a:	48 c1 e8 15          	shr    $0x15,%rax
  80233e:	48 89 c2             	mov    %rax,%rdx
  802341:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802348:	01 00 00 
  80234b:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80234f:	83 e0 01             	and    $0x1,%eax
  802352:	48 85 c0             	test   %rax,%rax
  802355:	74 21                	je     802378 <fd_lookup+0x77>
  802357:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80235b:	48 c1 e8 0c          	shr    $0xc,%rax
  80235f:	48 89 c2             	mov    %rax,%rdx
  802362:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  802369:	01 00 00 
  80236c:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802370:	83 e0 01             	and    $0x1,%eax
  802373:	48 85 c0             	test   %rax,%rax
  802376:	75 07                	jne    80237f <fd_lookup+0x7e>
  802378:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80237d:	eb 10                	jmp    80238f <fd_lookup+0x8e>
  80237f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802383:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  802387:	48 89 10             	mov    %rdx,(%rax)
  80238a:	b8 00 00 00 00       	mov    $0x0,%eax
  80238f:	c9                   	leaveq 
  802390:	c3                   	retq   

0000000000802391 <fd_close>:
  802391:	55                   	push   %rbp
  802392:	48 89 e5             	mov    %rsp,%rbp
  802395:	48 83 ec 30          	sub    $0x30,%rsp
  802399:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80239d:	89 f0                	mov    %esi,%eax
  80239f:	88 45 d4             	mov    %al,-0x2c(%rbp)
  8023a2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8023a6:	48 89 c7             	mov    %rax,%rdi
  8023a9:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  8023b0:	00 00 00 
  8023b3:	ff d0                	callq  *%rax
  8023b5:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8023b9:	48 89 d6             	mov    %rdx,%rsi
  8023bc:	89 c7                	mov    %eax,%edi
  8023be:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  8023c5:	00 00 00 
  8023c8:	ff d0                	callq  *%rax
  8023ca:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8023cd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8023d1:	78 0a                	js     8023dd <fd_close+0x4c>
  8023d3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8023d7:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
  8023db:	74 12                	je     8023ef <fd_close+0x5e>
  8023dd:	80 7d d4 00          	cmpb   $0x0,-0x2c(%rbp)
  8023e1:	74 05                	je     8023e8 <fd_close+0x57>
  8023e3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8023e6:	eb 05                	jmp    8023ed <fd_close+0x5c>
  8023e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ed:	eb 69                	jmp    802458 <fd_close+0xc7>
  8023ef:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8023f3:	8b 00                	mov    (%rax),%eax
  8023f5:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8023f9:	48 89 d6             	mov    %rdx,%rsi
  8023fc:	89 c7                	mov    %eax,%edi
  8023fe:	48 b8 5a 24 80 00 00 	movabs $0x80245a,%rax
  802405:	00 00 00 
  802408:	ff d0                	callq  *%rax
  80240a:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80240d:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802411:	78 2a                	js     80243d <fd_close+0xac>
  802413:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802417:	48 8b 40 20          	mov    0x20(%rax),%rax
  80241b:	48 85 c0             	test   %rax,%rax
  80241e:	74 16                	je     802436 <fd_close+0xa5>
  802420:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802424:	48 8b 40 20          	mov    0x20(%rax),%rax
  802428:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80242c:	48 89 d7             	mov    %rdx,%rdi
  80242f:	ff d0                	callq  *%rax
  802431:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802434:	eb 07                	jmp    80243d <fd_close+0xac>
  802436:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80243d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802441:	48 89 c6             	mov    %rax,%rsi
  802444:	bf 00 00 00 00       	mov    $0x0,%edi
  802449:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  802450:	00 00 00 
  802453:	ff d0                	callq  *%rax
  802455:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802458:	c9                   	leaveq 
  802459:	c3                   	retq   

000000000080245a <dev_lookup>:
  80245a:	55                   	push   %rbp
  80245b:	48 89 e5             	mov    %rsp,%rbp
  80245e:	48 83 ec 20          	sub    $0x20,%rsp
  802462:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802465:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802469:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  802470:	eb 41                	jmp    8024b3 <dev_lookup+0x59>
  802472:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  802479:	00 00 00 
  80247c:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80247f:	48 63 d2             	movslq %edx,%rdx
  802482:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802486:	8b 00                	mov    (%rax),%eax
  802488:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  80248b:	75 22                	jne    8024af <dev_lookup+0x55>
  80248d:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  802494:	00 00 00 
  802497:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80249a:	48 63 d2             	movslq %edx,%rdx
  80249d:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  8024a1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8024a5:	48 89 10             	mov    %rdx,(%rax)
  8024a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ad:	eb 60                	jmp    80250f <dev_lookup+0xb5>
  8024af:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8024b3:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8024ba:	00 00 00 
  8024bd:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8024c0:	48 63 d2             	movslq %edx,%rdx
  8024c3:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8024c7:	48 85 c0             	test   %rax,%rax
  8024ca:	75 a6                	jne    802472 <dev_lookup+0x18>
  8024cc:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8024d3:	00 00 00 
  8024d6:	48 8b 00             	mov    (%rax),%rax
  8024d9:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8024df:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8024e2:	89 c6                	mov    %eax,%esi
  8024e4:	48 bf 38 4d 80 00 00 	movabs $0x804d38,%rdi
  8024eb:	00 00 00 
  8024ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f3:	48 b9 59 08 80 00 00 	movabs $0x800859,%rcx
  8024fa:	00 00 00 
  8024fd:	ff d1                	callq  *%rcx
  8024ff:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802503:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  80250a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80250f:	c9                   	leaveq 
  802510:	c3                   	retq   

0000000000802511 <close>:
  802511:	55                   	push   %rbp
  802512:	48 89 e5             	mov    %rsp,%rbp
  802515:	48 83 ec 20          	sub    $0x20,%rsp
  802519:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80251c:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802520:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802523:	48 89 d6             	mov    %rdx,%rsi
  802526:	89 c7                	mov    %eax,%edi
  802528:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  80252f:	00 00 00 
  802532:	ff d0                	callq  *%rax
  802534:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802537:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80253b:	79 05                	jns    802542 <close+0x31>
  80253d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802540:	eb 18                	jmp    80255a <close+0x49>
  802542:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802546:	be 01 00 00 00       	mov    $0x1,%esi
  80254b:	48 89 c7             	mov    %rax,%rdi
  80254e:	48 b8 91 23 80 00 00 	movabs $0x802391,%rax
  802555:	00 00 00 
  802558:	ff d0                	callq  *%rax
  80255a:	c9                   	leaveq 
  80255b:	c3                   	retq   

000000000080255c <close_all>:
  80255c:	55                   	push   %rbp
  80255d:	48 89 e5             	mov    %rsp,%rbp
  802560:	48 83 ec 10          	sub    $0x10,%rsp
  802564:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80256b:	eb 15                	jmp    802582 <close_all+0x26>
  80256d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802570:	89 c7                	mov    %eax,%edi
  802572:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  802579:	00 00 00 
  80257c:	ff d0                	callq  *%rax
  80257e:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802582:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  802586:	7e e5                	jle    80256d <close_all+0x11>
  802588:	c9                   	leaveq 
  802589:	c3                   	retq   

000000000080258a <dup>:
  80258a:	55                   	push   %rbp
  80258b:	48 89 e5             	mov    %rsp,%rbp
  80258e:	48 83 ec 40          	sub    $0x40,%rsp
  802592:	89 7d cc             	mov    %edi,-0x34(%rbp)
  802595:	89 75 c8             	mov    %esi,-0x38(%rbp)
  802598:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  80259c:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80259f:	48 89 d6             	mov    %rdx,%rsi
  8025a2:	89 c7                	mov    %eax,%edi
  8025a4:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  8025ab:	00 00 00 
  8025ae:	ff d0                	callq  *%rax
  8025b0:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8025b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8025b7:	79 08                	jns    8025c1 <dup+0x37>
  8025b9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8025bc:	e9 70 01 00 00       	jmpq   802731 <dup+0x1a7>
  8025c1:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8025c4:	89 c7                	mov    %eax,%edi
  8025c6:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  8025cd:	00 00 00 
  8025d0:	ff d0                	callq  *%rax
  8025d2:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8025d5:	48 98                	cltq   
  8025d7:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  8025dd:	48 c1 e0 0c          	shl    $0xc,%rax
  8025e1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8025e5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8025e9:	48 89 c7             	mov    %rax,%rdi
  8025ec:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  8025f3:	00 00 00 
  8025f6:	ff d0                	callq  *%rax
  8025f8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8025fc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802600:	48 89 c7             	mov    %rax,%rdi
  802603:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  80260a:	00 00 00 
  80260d:	ff d0                	callq  *%rax
  80260f:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  802613:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802617:	48 c1 e8 15          	shr    $0x15,%rax
  80261b:	48 89 c2             	mov    %rax,%rdx
  80261e:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802625:	01 00 00 
  802628:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80262c:	83 e0 01             	and    $0x1,%eax
  80262f:	48 85 c0             	test   %rax,%rax
  802632:	74 73                	je     8026a7 <dup+0x11d>
  802634:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802638:	48 c1 e8 0c          	shr    $0xc,%rax
  80263c:	48 89 c2             	mov    %rax,%rdx
  80263f:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  802646:	01 00 00 
  802649:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80264d:	83 e0 01             	and    $0x1,%eax
  802650:	48 85 c0             	test   %rax,%rax
  802653:	74 52                	je     8026a7 <dup+0x11d>
  802655:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802659:	48 c1 e8 0c          	shr    $0xc,%rax
  80265d:	48 89 c2             	mov    %rax,%rdx
  802660:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  802667:	01 00 00 
  80266a:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80266e:	25 07 0e 00 00       	and    $0xe07,%eax
  802673:	89 c1                	mov    %eax,%ecx
  802675:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  802679:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80267d:	41 89 c8             	mov    %ecx,%r8d
  802680:	48 89 d1             	mov    %rdx,%rcx
  802683:	ba 00 00 00 00       	mov    $0x0,%edx
  802688:	48 89 c6             	mov    %rax,%rsi
  80268b:	bf 00 00 00 00       	mov    $0x0,%edi
  802690:	48 b8 8d 1d 80 00 00 	movabs $0x801d8d,%rax
  802697:	00 00 00 
  80269a:	ff d0                	callq  *%rax
  80269c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80269f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8026a3:	79 02                	jns    8026a7 <dup+0x11d>
  8026a5:	eb 57                	jmp    8026fe <dup+0x174>
  8026a7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8026ab:	48 c1 e8 0c          	shr    $0xc,%rax
  8026af:	48 89 c2             	mov    %rax,%rdx
  8026b2:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8026b9:	01 00 00 
  8026bc:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8026c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8026c5:	89 c1                	mov    %eax,%ecx
  8026c7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8026cb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8026cf:	41 89 c8             	mov    %ecx,%r8d
  8026d2:	48 89 d1             	mov    %rdx,%rcx
  8026d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8026da:	48 89 c6             	mov    %rax,%rsi
  8026dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8026e2:	48 b8 8d 1d 80 00 00 	movabs $0x801d8d,%rax
  8026e9:	00 00 00 
  8026ec:	ff d0                	callq  *%rax
  8026ee:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8026f1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8026f5:	79 02                	jns    8026f9 <dup+0x16f>
  8026f7:	eb 05                	jmp    8026fe <dup+0x174>
  8026f9:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8026fc:	eb 33                	jmp    802731 <dup+0x1a7>
  8026fe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802702:	48 89 c6             	mov    %rax,%rsi
  802705:	bf 00 00 00 00       	mov    $0x0,%edi
  80270a:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  802711:	00 00 00 
  802714:	ff d0                	callq  *%rax
  802716:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80271a:	48 89 c6             	mov    %rax,%rsi
  80271d:	bf 00 00 00 00       	mov    $0x0,%edi
  802722:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  802729:	00 00 00 
  80272c:	ff d0                	callq  *%rax
  80272e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802731:	c9                   	leaveq 
  802732:	c3                   	retq   

0000000000802733 <read>:
  802733:	55                   	push   %rbp
  802734:	48 89 e5             	mov    %rsp,%rbp
  802737:	48 83 ec 40          	sub    $0x40,%rsp
  80273b:	89 7d dc             	mov    %edi,-0x24(%rbp)
  80273e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802742:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802746:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80274a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80274d:	48 89 d6             	mov    %rdx,%rsi
  802750:	89 c7                	mov    %eax,%edi
  802752:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  802759:	00 00 00 
  80275c:	ff d0                	callq  *%rax
  80275e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802761:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802765:	78 24                	js     80278b <read+0x58>
  802767:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80276b:	8b 00                	mov    (%rax),%eax
  80276d:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802771:	48 89 d6             	mov    %rdx,%rsi
  802774:	89 c7                	mov    %eax,%edi
  802776:	48 b8 5a 24 80 00 00 	movabs $0x80245a,%rax
  80277d:	00 00 00 
  802780:	ff d0                	callq  *%rax
  802782:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802785:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802789:	79 05                	jns    802790 <read+0x5d>
  80278b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80278e:	eb 76                	jmp    802806 <read+0xd3>
  802790:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802794:	8b 40 08             	mov    0x8(%rax),%eax
  802797:	83 e0 03             	and    $0x3,%eax
  80279a:	83 f8 01             	cmp    $0x1,%eax
  80279d:	75 3a                	jne    8027d9 <read+0xa6>
  80279f:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8027a6:	00 00 00 
  8027a9:	48 8b 00             	mov    (%rax),%rax
  8027ac:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8027b2:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8027b5:	89 c6                	mov    %eax,%esi
  8027b7:	48 bf 57 4d 80 00 00 	movabs $0x804d57,%rdi
  8027be:	00 00 00 
  8027c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c6:	48 b9 59 08 80 00 00 	movabs $0x800859,%rcx
  8027cd:	00 00 00 
  8027d0:	ff d1                	callq  *%rcx
  8027d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8027d7:	eb 2d                	jmp    802806 <read+0xd3>
  8027d9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8027dd:	48 8b 40 10          	mov    0x10(%rax),%rax
  8027e1:	48 85 c0             	test   %rax,%rax
  8027e4:	75 07                	jne    8027ed <read+0xba>
  8027e6:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8027eb:	eb 19                	jmp    802806 <read+0xd3>
  8027ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8027f1:	48 8b 40 10          	mov    0x10(%rax),%rax
  8027f5:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8027f9:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8027fd:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802801:	48 89 cf             	mov    %rcx,%rdi
  802804:	ff d0                	callq  *%rax
  802806:	c9                   	leaveq 
  802807:	c3                   	retq   

0000000000802808 <readn>:
  802808:	55                   	push   %rbp
  802809:	48 89 e5             	mov    %rsp,%rbp
  80280c:	48 83 ec 30          	sub    $0x30,%rsp
  802810:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802813:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802817:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80281b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  802822:	eb 49                	jmp    80286d <readn+0x65>
  802824:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802827:	48 98                	cltq   
  802829:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80282d:	48 29 c2             	sub    %rax,%rdx
  802830:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802833:	48 63 c8             	movslq %eax,%rcx
  802836:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80283a:	48 01 c1             	add    %rax,%rcx
  80283d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802840:	48 89 ce             	mov    %rcx,%rsi
  802843:	89 c7                	mov    %eax,%edi
  802845:	48 b8 33 27 80 00 00 	movabs $0x802733,%rax
  80284c:	00 00 00 
  80284f:	ff d0                	callq  *%rax
  802851:	89 45 f8             	mov    %eax,-0x8(%rbp)
  802854:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  802858:	79 05                	jns    80285f <readn+0x57>
  80285a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80285d:	eb 1c                	jmp    80287b <readn+0x73>
  80285f:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  802863:	75 02                	jne    802867 <readn+0x5f>
  802865:	eb 11                	jmp    802878 <readn+0x70>
  802867:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80286a:	01 45 fc             	add    %eax,-0x4(%rbp)
  80286d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802870:	48 98                	cltq   
  802872:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  802876:	72 ac                	jb     802824 <readn+0x1c>
  802878:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80287b:	c9                   	leaveq 
  80287c:	c3                   	retq   

000000000080287d <write>:
  80287d:	55                   	push   %rbp
  80287e:	48 89 e5             	mov    %rsp,%rbp
  802881:	48 83 ec 40          	sub    $0x40,%rsp
  802885:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802888:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  80288c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802890:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802894:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802897:	48 89 d6             	mov    %rdx,%rsi
  80289a:	89 c7                	mov    %eax,%edi
  80289c:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  8028a3:	00 00 00 
  8028a6:	ff d0                	callq  *%rax
  8028a8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8028ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8028af:	78 24                	js     8028d5 <write+0x58>
  8028b1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8028b5:	8b 00                	mov    (%rax),%eax
  8028b7:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8028bb:	48 89 d6             	mov    %rdx,%rsi
  8028be:	89 c7                	mov    %eax,%edi
  8028c0:	48 b8 5a 24 80 00 00 	movabs $0x80245a,%rax
  8028c7:	00 00 00 
  8028ca:	ff d0                	callq  *%rax
  8028cc:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8028cf:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8028d3:	79 05                	jns    8028da <write+0x5d>
  8028d5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8028d8:	eb 75                	jmp    80294f <write+0xd2>
  8028da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8028de:	8b 40 08             	mov    0x8(%rax),%eax
  8028e1:	83 e0 03             	and    $0x3,%eax
  8028e4:	85 c0                	test   %eax,%eax
  8028e6:	75 3a                	jne    802922 <write+0xa5>
  8028e8:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8028ef:	00 00 00 
  8028f2:	48 8b 00             	mov    (%rax),%rax
  8028f5:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8028fb:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8028fe:	89 c6                	mov    %eax,%esi
  802900:	48 bf 73 4d 80 00 00 	movabs $0x804d73,%rdi
  802907:	00 00 00 
  80290a:	b8 00 00 00 00       	mov    $0x0,%eax
  80290f:	48 b9 59 08 80 00 00 	movabs $0x800859,%rcx
  802916:	00 00 00 
  802919:	ff d1                	callq  *%rcx
  80291b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802920:	eb 2d                	jmp    80294f <write+0xd2>
  802922:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802926:	48 8b 40 18          	mov    0x18(%rax),%rax
  80292a:	48 85 c0             	test   %rax,%rax
  80292d:	75 07                	jne    802936 <write+0xb9>
  80292f:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802934:	eb 19                	jmp    80294f <write+0xd2>
  802936:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80293a:	48 8b 40 18          	mov    0x18(%rax),%rax
  80293e:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  802942:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802946:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  80294a:	48 89 cf             	mov    %rcx,%rdi
  80294d:	ff d0                	callq  *%rax
  80294f:	c9                   	leaveq 
  802950:	c3                   	retq   

0000000000802951 <seek>:
  802951:	55                   	push   %rbp
  802952:	48 89 e5             	mov    %rsp,%rbp
  802955:	48 83 ec 18          	sub    $0x18,%rsp
  802959:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80295c:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80295f:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802963:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802966:	48 89 d6             	mov    %rdx,%rsi
  802969:	89 c7                	mov    %eax,%edi
  80296b:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  802972:	00 00 00 
  802975:	ff d0                	callq  *%rax
  802977:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80297a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80297e:	79 05                	jns    802985 <seek+0x34>
  802980:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802983:	eb 0f                	jmp    802994 <seek+0x43>
  802985:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802989:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80298c:	89 50 04             	mov    %edx,0x4(%rax)
  80298f:	b8 00 00 00 00       	mov    $0x0,%eax
  802994:	c9                   	leaveq 
  802995:	c3                   	retq   

0000000000802996 <ftruncate>:
  802996:	55                   	push   %rbp
  802997:	48 89 e5             	mov    %rsp,%rbp
  80299a:	48 83 ec 30          	sub    $0x30,%rsp
  80299e:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8029a1:	89 75 d8             	mov    %esi,-0x28(%rbp)
  8029a4:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8029a8:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8029ab:	48 89 d6             	mov    %rdx,%rsi
  8029ae:	89 c7                	mov    %eax,%edi
  8029b0:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  8029b7:	00 00 00 
  8029ba:	ff d0                	callq  *%rax
  8029bc:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8029bf:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8029c3:	78 24                	js     8029e9 <ftruncate+0x53>
  8029c5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8029c9:	8b 00                	mov    (%rax),%eax
  8029cb:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8029cf:	48 89 d6             	mov    %rdx,%rsi
  8029d2:	89 c7                	mov    %eax,%edi
  8029d4:	48 b8 5a 24 80 00 00 	movabs $0x80245a,%rax
  8029db:	00 00 00 
  8029de:	ff d0                	callq  *%rax
  8029e0:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8029e3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8029e7:	79 05                	jns    8029ee <ftruncate+0x58>
  8029e9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8029ec:	eb 72                	jmp    802a60 <ftruncate+0xca>
  8029ee:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8029f2:	8b 40 08             	mov    0x8(%rax),%eax
  8029f5:	83 e0 03             	and    $0x3,%eax
  8029f8:	85 c0                	test   %eax,%eax
  8029fa:	75 3a                	jne    802a36 <ftruncate+0xa0>
  8029fc:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802a03:	00 00 00 
  802a06:	48 8b 00             	mov    (%rax),%rax
  802a09:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802a0f:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802a12:	89 c6                	mov    %eax,%esi
  802a14:	48 bf 90 4d 80 00 00 	movabs $0x804d90,%rdi
  802a1b:	00 00 00 
  802a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  802a23:	48 b9 59 08 80 00 00 	movabs $0x800859,%rcx
  802a2a:	00 00 00 
  802a2d:	ff d1                	callq  *%rcx
  802a2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a34:	eb 2a                	jmp    802a60 <ftruncate+0xca>
  802a36:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a3a:	48 8b 40 30          	mov    0x30(%rax),%rax
  802a3e:	48 85 c0             	test   %rax,%rax
  802a41:	75 07                	jne    802a4a <ftruncate+0xb4>
  802a43:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802a48:	eb 16                	jmp    802a60 <ftruncate+0xca>
  802a4a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a4e:	48 8b 40 30          	mov    0x30(%rax),%rax
  802a52:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802a56:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  802a59:	89 ce                	mov    %ecx,%esi
  802a5b:	48 89 d7             	mov    %rdx,%rdi
  802a5e:	ff d0                	callq  *%rax
  802a60:	c9                   	leaveq 
  802a61:	c3                   	retq   

0000000000802a62 <fstat>:
  802a62:	55                   	push   %rbp
  802a63:	48 89 e5             	mov    %rsp,%rbp
  802a66:	48 83 ec 30          	sub    $0x30,%rsp
  802a6a:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802a6d:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802a71:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802a75:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802a78:	48 89 d6             	mov    %rdx,%rsi
  802a7b:	89 c7                	mov    %eax,%edi
  802a7d:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  802a84:	00 00 00 
  802a87:	ff d0                	callq  *%rax
  802a89:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a8c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a90:	78 24                	js     802ab6 <fstat+0x54>
  802a92:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802a96:	8b 00                	mov    (%rax),%eax
  802a98:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802a9c:	48 89 d6             	mov    %rdx,%rsi
  802a9f:	89 c7                	mov    %eax,%edi
  802aa1:	48 b8 5a 24 80 00 00 	movabs $0x80245a,%rax
  802aa8:	00 00 00 
  802aab:	ff d0                	callq  *%rax
  802aad:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802ab0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802ab4:	79 05                	jns    802abb <fstat+0x59>
  802ab6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ab9:	eb 5e                	jmp    802b19 <fstat+0xb7>
  802abb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802abf:	48 8b 40 28          	mov    0x28(%rax),%rax
  802ac3:	48 85 c0             	test   %rax,%rax
  802ac6:	75 07                	jne    802acf <fstat+0x6d>
  802ac8:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802acd:	eb 4a                	jmp    802b19 <fstat+0xb7>
  802acf:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802ad3:	c6 00 00             	movb   $0x0,(%rax)
  802ad6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802ada:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%rax)
  802ae1:	00 00 00 
  802ae4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802ae8:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  802aef:	00 00 00 
  802af2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802af6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802afa:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
  802b01:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802b05:	48 8b 40 28          	mov    0x28(%rax),%rax
  802b09:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802b0d:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  802b11:	48 89 ce             	mov    %rcx,%rsi
  802b14:	48 89 d7             	mov    %rdx,%rdi
  802b17:	ff d0                	callq  *%rax
  802b19:	c9                   	leaveq 
  802b1a:	c3                   	retq   

0000000000802b1b <stat>:
  802b1b:	55                   	push   %rbp
  802b1c:	48 89 e5             	mov    %rsp,%rbp
  802b1f:	48 83 ec 20          	sub    $0x20,%rsp
  802b23:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802b27:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802b2b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802b2f:	be 00 00 00 00       	mov    $0x0,%esi
  802b34:	48 89 c7             	mov    %rax,%rdi
  802b37:	48 b8 09 2c 80 00 00 	movabs $0x802c09,%rax
  802b3e:	00 00 00 
  802b41:	ff d0                	callq  *%rax
  802b43:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802b46:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802b4a:	79 05                	jns    802b51 <stat+0x36>
  802b4c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b4f:	eb 2f                	jmp    802b80 <stat+0x65>
  802b51:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  802b55:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b58:	48 89 d6             	mov    %rdx,%rsi
  802b5b:	89 c7                	mov    %eax,%edi
  802b5d:	48 b8 62 2a 80 00 00 	movabs $0x802a62,%rax
  802b64:	00 00 00 
  802b67:	ff d0                	callq  *%rax
  802b69:	89 45 f8             	mov    %eax,-0x8(%rbp)
  802b6c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b6f:	89 c7                	mov    %eax,%edi
  802b71:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  802b78:	00 00 00 
  802b7b:	ff d0                	callq  *%rax
  802b7d:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802b80:	c9                   	leaveq 
  802b81:	c3                   	retq   

0000000000802b82 <fsipc>:
  802b82:	55                   	push   %rbp
  802b83:	48 89 e5             	mov    %rsp,%rbp
  802b86:	48 83 ec 10          	sub    $0x10,%rsp
  802b8a:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802b8d:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802b91:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802b98:	00 00 00 
  802b9b:	8b 00                	mov    (%rax),%eax
  802b9d:	85 c0                	test   %eax,%eax
  802b9f:	75 1d                	jne    802bbe <fsipc+0x3c>
  802ba1:	bf 01 00 00 00       	mov    $0x1,%edi
  802ba6:	48 b8 ce 45 80 00 00 	movabs $0x8045ce,%rax
  802bad:	00 00 00 
  802bb0:	ff d0                	callq  *%rax
  802bb2:	48 ba 00 70 80 00 00 	movabs $0x807000,%rdx
  802bb9:	00 00 00 
  802bbc:	89 02                	mov    %eax,(%rdx)
  802bbe:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802bc5:	00 00 00 
  802bc8:	8b 00                	mov    (%rax),%eax
  802bca:	8b 75 fc             	mov    -0x4(%rbp),%esi
  802bcd:	b9 07 00 00 00       	mov    $0x7,%ecx
  802bd2:	48 ba 00 80 80 00 00 	movabs $0x808000,%rdx
  802bd9:	00 00 00 
  802bdc:	89 c7                	mov    %eax,%edi
  802bde:	48 b8 38 45 80 00 00 	movabs $0x804538,%rax
  802be5:	00 00 00 
  802be8:	ff d0                	callq  *%rax
  802bea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802bee:	ba 00 00 00 00       	mov    $0x0,%edx
  802bf3:	48 89 c6             	mov    %rax,%rsi
  802bf6:	bf 00 00 00 00       	mov    $0x0,%edi
  802bfb:	48 b8 77 44 80 00 00 	movabs $0x804477,%rax
  802c02:	00 00 00 
  802c05:	ff d0                	callq  *%rax
  802c07:	c9                   	leaveq 
  802c08:	c3                   	retq   

0000000000802c09 <open>:
  802c09:	55                   	push   %rbp
  802c0a:	48 89 e5             	mov    %rsp,%rbp
  802c0d:	48 83 ec 20          	sub    $0x20,%rsp
  802c11:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802c15:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  802c18:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802c1c:	48 89 c7             	mov    %rax,%rdi
  802c1f:	48 b8 a2 13 80 00 00 	movabs $0x8013a2,%rax
  802c26:	00 00 00 
  802c29:	ff d0                	callq  *%rax
  802c2b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802c30:	7e 0a                	jle    802c3c <open+0x33>
  802c32:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  802c37:	e9 a5 00 00 00       	jmpq   802ce1 <open+0xd8>
  802c3c:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  802c40:	48 89 c7             	mov    %rax,%rdi
  802c43:	48 b8 69 22 80 00 00 	movabs $0x802269,%rax
  802c4a:	00 00 00 
  802c4d:	ff d0                	callq  *%rax
  802c4f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802c52:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802c56:	79 08                	jns    802c60 <open+0x57>
  802c58:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802c5b:	e9 81 00 00 00       	jmpq   802ce1 <open+0xd8>
  802c60:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802c64:	48 89 c6             	mov    %rax,%rsi
  802c67:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  802c6e:	00 00 00 
  802c71:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  802c78:	00 00 00 
  802c7b:	ff d0                	callq  *%rax
  802c7d:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802c84:	00 00 00 
  802c87:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  802c8a:	89 90 00 04 00 00    	mov    %edx,0x400(%rax)
  802c90:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c94:	48 89 c6             	mov    %rax,%rsi
  802c97:	bf 01 00 00 00       	mov    $0x1,%edi
  802c9c:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802ca3:	00 00 00 
  802ca6:	ff d0                	callq  *%rax
  802ca8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802cab:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802caf:	79 1d                	jns    802cce <open+0xc5>
  802cb1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802cb5:	be 00 00 00 00       	mov    $0x0,%esi
  802cba:	48 89 c7             	mov    %rax,%rdi
  802cbd:	48 b8 91 23 80 00 00 	movabs $0x802391,%rax
  802cc4:	00 00 00 
  802cc7:	ff d0                	callq  *%rax
  802cc9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ccc:	eb 13                	jmp    802ce1 <open+0xd8>
  802cce:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802cd2:	48 89 c7             	mov    %rax,%rdi
  802cd5:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  802cdc:	00 00 00 
  802cdf:	ff d0                	callq  *%rax
  802ce1:	c9                   	leaveq 
  802ce2:	c3                   	retq   

0000000000802ce3 <devfile_flush>:
  802ce3:	55                   	push   %rbp
  802ce4:	48 89 e5             	mov    %rsp,%rbp
  802ce7:	48 83 ec 10          	sub    $0x10,%rsp
  802ceb:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802cef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802cf3:	8b 50 0c             	mov    0xc(%rax),%edx
  802cf6:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802cfd:	00 00 00 
  802d00:	89 10                	mov    %edx,(%rax)
  802d02:	be 00 00 00 00       	mov    $0x0,%esi
  802d07:	bf 06 00 00 00       	mov    $0x6,%edi
  802d0c:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802d13:	00 00 00 
  802d16:	ff d0                	callq  *%rax
  802d18:	c9                   	leaveq 
  802d19:	c3                   	retq   

0000000000802d1a <devfile_read>:
  802d1a:	55                   	push   %rbp
  802d1b:	48 89 e5             	mov    %rsp,%rbp
  802d1e:	48 83 ec 30          	sub    $0x30,%rsp
  802d22:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802d26:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802d2a:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  802d2e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802d32:	8b 50 0c             	mov    0xc(%rax),%edx
  802d35:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802d3c:	00 00 00 
  802d3f:	89 10                	mov    %edx,(%rax)
  802d41:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802d48:	00 00 00 
  802d4b:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802d4f:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802d53:	be 00 00 00 00       	mov    $0x0,%esi
  802d58:	bf 03 00 00 00       	mov    $0x3,%edi
  802d5d:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802d64:	00 00 00 
  802d67:	ff d0                	callq  *%rax
  802d69:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802d6c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802d70:	79 08                	jns    802d7a <devfile_read+0x60>
  802d72:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802d75:	e9 a4 00 00 00       	jmpq   802e1e <devfile_read+0x104>
  802d7a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802d7d:	48 98                	cltq   
  802d7f:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  802d83:	76 35                	jbe    802dba <devfile_read+0xa0>
  802d85:	48 b9 b6 4d 80 00 00 	movabs $0x804db6,%rcx
  802d8c:	00 00 00 
  802d8f:	48 ba bd 4d 80 00 00 	movabs $0x804dbd,%rdx
  802d96:	00 00 00 
  802d99:	be 89 00 00 00       	mov    $0x89,%esi
  802d9e:	48 bf d2 4d 80 00 00 	movabs $0x804dd2,%rdi
  802da5:	00 00 00 
  802da8:	b8 00 00 00 00       	mov    $0x0,%eax
  802dad:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  802db4:	00 00 00 
  802db7:	41 ff d0             	callq  *%r8
  802dba:	81 7d fc 00 10 00 00 	cmpl   $0x1000,-0x4(%rbp)
  802dc1:	7e 35                	jle    802df8 <devfile_read+0xde>
  802dc3:	48 b9 e0 4d 80 00 00 	movabs $0x804de0,%rcx
  802dca:	00 00 00 
  802dcd:	48 ba bd 4d 80 00 00 	movabs $0x804dbd,%rdx
  802dd4:	00 00 00 
  802dd7:	be 8a 00 00 00       	mov    $0x8a,%esi
  802ddc:	48 bf d2 4d 80 00 00 	movabs $0x804dd2,%rdi
  802de3:	00 00 00 
  802de6:	b8 00 00 00 00       	mov    $0x0,%eax
  802deb:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  802df2:	00 00 00 
  802df5:	41 ff d0             	callq  *%r8
  802df8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802dfb:	48 63 d0             	movslq %eax,%rdx
  802dfe:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802e02:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  802e09:	00 00 00 
  802e0c:	48 89 c7             	mov    %rax,%rdi
  802e0f:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  802e16:	00 00 00 
  802e19:	ff d0                	callq  *%rax
  802e1b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802e1e:	c9                   	leaveq 
  802e1f:	c3                   	retq   

0000000000802e20 <devfile_write>:
  802e20:	55                   	push   %rbp
  802e21:	48 89 e5             	mov    %rsp,%rbp
  802e24:	48 83 ec 40          	sub    $0x40,%rsp
  802e28:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802e2c:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802e30:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802e34:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  802e38:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  802e3c:	48 c7 45 f0 f4 0f 00 	movq   $0xff4,-0x10(%rbp)
  802e43:	00 
  802e44:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802e48:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  802e4c:	48 0f 46 45 f8       	cmovbe -0x8(%rbp),%rax
  802e51:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  802e55:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802e59:	8b 50 0c             	mov    0xc(%rax),%edx
  802e5c:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802e63:	00 00 00 
  802e66:	89 10                	mov    %edx,(%rax)
  802e68:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802e6f:	00 00 00 
  802e72:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802e76:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802e7a:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802e7e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e82:	48 89 c6             	mov    %rax,%rsi
  802e85:	48 bf 10 80 80 00 00 	movabs $0x808010,%rdi
  802e8c:	00 00 00 
  802e8f:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  802e96:	00 00 00 
  802e99:	ff d0                	callq  *%rax
  802e9b:	be 00 00 00 00       	mov    $0x0,%esi
  802ea0:	bf 04 00 00 00       	mov    $0x4,%edi
  802ea5:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802eac:	00 00 00 
  802eaf:	ff d0                	callq  *%rax
  802eb1:	89 45 ec             	mov    %eax,-0x14(%rbp)
  802eb4:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  802eb8:	79 05                	jns    802ebf <devfile_write+0x9f>
  802eba:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802ebd:	eb 43                	jmp    802f02 <devfile_write+0xe2>
  802ebf:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802ec2:	48 98                	cltq   
  802ec4:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  802ec8:	76 35                	jbe    802eff <devfile_write+0xdf>
  802eca:	48 b9 b6 4d 80 00 00 	movabs $0x804db6,%rcx
  802ed1:	00 00 00 
  802ed4:	48 ba bd 4d 80 00 00 	movabs $0x804dbd,%rdx
  802edb:	00 00 00 
  802ede:	be a8 00 00 00       	mov    $0xa8,%esi
  802ee3:	48 bf d2 4d 80 00 00 	movabs $0x804dd2,%rdi
  802eea:	00 00 00 
  802eed:	b8 00 00 00 00       	mov    $0x0,%eax
  802ef2:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  802ef9:	00 00 00 
  802efc:	41 ff d0             	callq  *%r8
  802eff:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802f02:	c9                   	leaveq 
  802f03:	c3                   	retq   

0000000000802f04 <devfile_stat>:
  802f04:	55                   	push   %rbp
  802f05:	48 89 e5             	mov    %rsp,%rbp
  802f08:	48 83 ec 20          	sub    $0x20,%rsp
  802f0c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802f10:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802f14:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802f18:	8b 50 0c             	mov    0xc(%rax),%edx
  802f1b:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f22:	00 00 00 
  802f25:	89 10                	mov    %edx,(%rax)
  802f27:	be 00 00 00 00       	mov    $0x0,%esi
  802f2c:	bf 05 00 00 00       	mov    $0x5,%edi
  802f31:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802f38:	00 00 00 
  802f3b:	ff d0                	callq  *%rax
  802f3d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802f40:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802f44:	79 05                	jns    802f4b <devfile_stat+0x47>
  802f46:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802f49:	eb 56                	jmp    802fa1 <devfile_stat+0x9d>
  802f4b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f4f:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  802f56:	00 00 00 
  802f59:	48 89 c7             	mov    %rax,%rdi
  802f5c:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  802f63:	00 00 00 
  802f66:	ff d0                	callq  *%rax
  802f68:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f6f:	00 00 00 
  802f72:	8b 90 80 00 00 00    	mov    0x80(%rax),%edx
  802f78:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f7c:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  802f82:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f89:	00 00 00 
  802f8c:	8b 90 84 00 00 00    	mov    0x84(%rax),%edx
  802f92:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f96:	89 90 84 00 00 00    	mov    %edx,0x84(%rax)
  802f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  802fa1:	c9                   	leaveq 
  802fa2:	c3                   	retq   

0000000000802fa3 <devfile_trunc>:
  802fa3:	55                   	push   %rbp
  802fa4:	48 89 e5             	mov    %rsp,%rbp
  802fa7:	48 83 ec 10          	sub    $0x10,%rsp
  802fab:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802faf:	89 75 f4             	mov    %esi,-0xc(%rbp)
  802fb2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802fb6:	8b 50 0c             	mov    0xc(%rax),%edx
  802fb9:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802fc0:	00 00 00 
  802fc3:	89 10                	mov    %edx,(%rax)
  802fc5:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802fcc:	00 00 00 
  802fcf:	8b 55 f4             	mov    -0xc(%rbp),%edx
  802fd2:	89 50 04             	mov    %edx,0x4(%rax)
  802fd5:	be 00 00 00 00       	mov    $0x0,%esi
  802fda:	bf 02 00 00 00       	mov    $0x2,%edi
  802fdf:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  802fe6:	00 00 00 
  802fe9:	ff d0                	callq  *%rax
  802feb:	c9                   	leaveq 
  802fec:	c3                   	retq   

0000000000802fed <remove>:
  802fed:	55                   	push   %rbp
  802fee:	48 89 e5             	mov    %rsp,%rbp
  802ff1:	48 83 ec 10          	sub    $0x10,%rsp
  802ff5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802ff9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802ffd:	48 89 c7             	mov    %rax,%rdi
  803000:	48 b8 a2 13 80 00 00 	movabs $0x8013a2,%rax
  803007:	00 00 00 
  80300a:	ff d0                	callq  *%rax
  80300c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803011:	7e 07                	jle    80301a <remove+0x2d>
  803013:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  803018:	eb 33                	jmp    80304d <remove+0x60>
  80301a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80301e:	48 89 c6             	mov    %rax,%rsi
  803021:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  803028:	00 00 00 
  80302b:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  803032:	00 00 00 
  803035:	ff d0                	callq  *%rax
  803037:	be 00 00 00 00       	mov    $0x0,%esi
  80303c:	bf 07 00 00 00       	mov    $0x7,%edi
  803041:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  803048:	00 00 00 
  80304b:	ff d0                	callq  *%rax
  80304d:	c9                   	leaveq 
  80304e:	c3                   	retq   

000000000080304f <sync>:
  80304f:	55                   	push   %rbp
  803050:	48 89 e5             	mov    %rsp,%rbp
  803053:	be 00 00 00 00       	mov    $0x0,%esi
  803058:	bf 08 00 00 00       	mov    $0x8,%edi
  80305d:	48 b8 82 2b 80 00 00 	movabs $0x802b82,%rax
  803064:	00 00 00 
  803067:	ff d0                	callq  *%rax
  803069:	5d                   	pop    %rbp
  80306a:	c3                   	retq   

000000000080306b <copy>:
  80306b:	55                   	push   %rbp
  80306c:	48 89 e5             	mov    %rsp,%rbp
  80306f:	48 81 ec 20 02 00 00 	sub    $0x220,%rsp
  803076:	48 89 bd e8 fd ff ff 	mov    %rdi,-0x218(%rbp)
  80307d:	48 89 b5 e0 fd ff ff 	mov    %rsi,-0x220(%rbp)
  803084:	48 8b 85 e8 fd ff ff 	mov    -0x218(%rbp),%rax
  80308b:	be 00 00 00 00       	mov    $0x0,%esi
  803090:	48 89 c7             	mov    %rax,%rdi
  803093:	48 b8 09 2c 80 00 00 	movabs $0x802c09,%rax
  80309a:	00 00 00 
  80309d:	ff d0                	callq  *%rax
  80309f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8030a2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8030a6:	79 28                	jns    8030d0 <copy+0x65>
  8030a8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8030ab:	89 c6                	mov    %eax,%esi
  8030ad:	48 bf ec 4d 80 00 00 	movabs $0x804dec,%rdi
  8030b4:	00 00 00 
  8030b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8030bc:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  8030c3:	00 00 00 
  8030c6:	ff d2                	callq  *%rdx
  8030c8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8030cb:	e9 74 01 00 00       	jmpq   803244 <copy+0x1d9>
  8030d0:	48 8b 85 e0 fd ff ff 	mov    -0x220(%rbp),%rax
  8030d7:	be 01 01 00 00       	mov    $0x101,%esi
  8030dc:	48 89 c7             	mov    %rax,%rdi
  8030df:	48 b8 09 2c 80 00 00 	movabs $0x802c09,%rax
  8030e6:	00 00 00 
  8030e9:	ff d0                	callq  *%rax
  8030eb:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8030ee:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8030f2:	79 39                	jns    80312d <copy+0xc2>
  8030f4:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8030f7:	89 c6                	mov    %eax,%esi
  8030f9:	48 bf 02 4e 80 00 00 	movabs $0x804e02,%rdi
  803100:	00 00 00 
  803103:	b8 00 00 00 00       	mov    $0x0,%eax
  803108:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  80310f:	00 00 00 
  803112:	ff d2                	callq  *%rdx
  803114:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803117:	89 c7                	mov    %eax,%edi
  803119:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803120:	00 00 00 
  803123:	ff d0                	callq  *%rax
  803125:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803128:	e9 17 01 00 00       	jmpq   803244 <copy+0x1d9>
  80312d:	eb 74                	jmp    8031a3 <copy+0x138>
  80312f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  803132:	48 63 d0             	movslq %eax,%rdx
  803135:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  80313c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80313f:	48 89 ce             	mov    %rcx,%rsi
  803142:	89 c7                	mov    %eax,%edi
  803144:	48 b8 7d 28 80 00 00 	movabs $0x80287d,%rax
  80314b:	00 00 00 
  80314e:	ff d0                	callq  *%rax
  803150:	89 45 f0             	mov    %eax,-0x10(%rbp)
  803153:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  803157:	79 4a                	jns    8031a3 <copy+0x138>
  803159:	8b 45 f0             	mov    -0x10(%rbp),%eax
  80315c:	89 c6                	mov    %eax,%esi
  80315e:	48 bf 1c 4e 80 00 00 	movabs $0x804e1c,%rdi
  803165:	00 00 00 
  803168:	b8 00 00 00 00       	mov    $0x0,%eax
  80316d:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  803174:	00 00 00 
  803177:	ff d2                	callq  *%rdx
  803179:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80317c:	89 c7                	mov    %eax,%edi
  80317e:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803185:	00 00 00 
  803188:	ff d0                	callq  *%rax
  80318a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80318d:	89 c7                	mov    %eax,%edi
  80318f:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803196:	00 00 00 
  803199:	ff d0                	callq  *%rax
  80319b:	8b 45 f0             	mov    -0x10(%rbp),%eax
  80319e:	e9 a1 00 00 00       	jmpq   803244 <copy+0x1d9>
  8031a3:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  8031aa:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8031ad:	ba 00 02 00 00       	mov    $0x200,%edx
  8031b2:	48 89 ce             	mov    %rcx,%rsi
  8031b5:	89 c7                	mov    %eax,%edi
  8031b7:	48 b8 33 27 80 00 00 	movabs $0x802733,%rax
  8031be:	00 00 00 
  8031c1:	ff d0                	callq  *%rax
  8031c3:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8031c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8031ca:	0f 8f 5f ff ff ff    	jg     80312f <copy+0xc4>
  8031d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8031d4:	79 47                	jns    80321d <copy+0x1b2>
  8031d6:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8031d9:	89 c6                	mov    %eax,%esi
  8031db:	48 bf 2f 4e 80 00 00 	movabs $0x804e2f,%rdi
  8031e2:	00 00 00 
  8031e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8031ea:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  8031f1:	00 00 00 
  8031f4:	ff d2                	callq  *%rdx
  8031f6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8031f9:	89 c7                	mov    %eax,%edi
  8031fb:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803202:	00 00 00 
  803205:	ff d0                	callq  *%rax
  803207:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80320a:	89 c7                	mov    %eax,%edi
  80320c:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803213:	00 00 00 
  803216:	ff d0                	callq  *%rax
  803218:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80321b:	eb 27                	jmp    803244 <copy+0x1d9>
  80321d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803220:	89 c7                	mov    %eax,%edi
  803222:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  803229:	00 00 00 
  80322c:	ff d0                	callq  *%rax
  80322e:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803231:	89 c7                	mov    %eax,%edi
  803233:	48 b8 11 25 80 00 00 	movabs $0x802511,%rax
  80323a:	00 00 00 
  80323d:	ff d0                	callq  *%rax
  80323f:	b8 00 00 00 00       	mov    $0x0,%eax
  803244:	c9                   	leaveq 
  803245:	c3                   	retq   

0000000000803246 <fd2sockid>:
  803246:	55                   	push   %rbp
  803247:	48 89 e5             	mov    %rsp,%rbp
  80324a:	48 83 ec 20          	sub    $0x20,%rsp
  80324e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803251:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  803255:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803258:	48 89 d6             	mov    %rdx,%rsi
  80325b:	89 c7                	mov    %eax,%edi
  80325d:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  803264:	00 00 00 
  803267:	ff d0                	callq  *%rax
  803269:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80326c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803270:	79 05                	jns    803277 <fd2sockid+0x31>
  803272:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803275:	eb 24                	jmp    80329b <fd2sockid+0x55>
  803277:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80327b:	8b 10                	mov    (%rax),%edx
  80327d:	48 b8 a0 60 80 00 00 	movabs $0x8060a0,%rax
  803284:	00 00 00 
  803287:	8b 00                	mov    (%rax),%eax
  803289:	39 c2                	cmp    %eax,%edx
  80328b:	74 07                	je     803294 <fd2sockid+0x4e>
  80328d:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  803292:	eb 07                	jmp    80329b <fd2sockid+0x55>
  803294:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803298:	8b 40 0c             	mov    0xc(%rax),%eax
  80329b:	c9                   	leaveq 
  80329c:	c3                   	retq   

000000000080329d <alloc_sockfd>:
  80329d:	55                   	push   %rbp
  80329e:	48 89 e5             	mov    %rsp,%rbp
  8032a1:	48 83 ec 20          	sub    $0x20,%rsp
  8032a5:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8032a8:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  8032ac:	48 89 c7             	mov    %rax,%rdi
  8032af:	48 b8 69 22 80 00 00 	movabs $0x802269,%rax
  8032b6:	00 00 00 
  8032b9:	ff d0                	callq  *%rax
  8032bb:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8032be:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8032c2:	78 26                	js     8032ea <alloc_sockfd+0x4d>
  8032c4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8032c8:	ba 07 04 00 00       	mov    $0x407,%edx
  8032cd:	48 89 c6             	mov    %rax,%rsi
  8032d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8032d5:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  8032dc:	00 00 00 
  8032df:	ff d0                	callq  *%rax
  8032e1:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8032e4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8032e8:	79 16                	jns    803300 <alloc_sockfd+0x63>
  8032ea:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8032ed:	89 c7                	mov    %eax,%edi
  8032ef:	48 b8 aa 37 80 00 00 	movabs $0x8037aa,%rax
  8032f6:	00 00 00 
  8032f9:	ff d0                	callq  *%rax
  8032fb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8032fe:	eb 3a                	jmp    80333a <alloc_sockfd+0x9d>
  803300:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803304:	48 ba a0 60 80 00 00 	movabs $0x8060a0,%rdx
  80330b:	00 00 00 
  80330e:	8b 12                	mov    (%rdx),%edx
  803310:	89 10                	mov    %edx,(%rax)
  803312:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803316:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  80331d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803321:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803324:	89 50 0c             	mov    %edx,0xc(%rax)
  803327:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80332b:	48 89 c7             	mov    %rax,%rdi
  80332e:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  803335:	00 00 00 
  803338:	ff d0                	callq  *%rax
  80333a:	c9                   	leaveq 
  80333b:	c3                   	retq   

000000000080333c <accept>:
  80333c:	55                   	push   %rbp
  80333d:	48 89 e5             	mov    %rsp,%rbp
  803340:	48 83 ec 30          	sub    $0x30,%rsp
  803344:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803347:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80334b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80334f:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803352:	89 c7                	mov    %eax,%edi
  803354:	48 b8 46 32 80 00 00 	movabs $0x803246,%rax
  80335b:	00 00 00 
  80335e:	ff d0                	callq  *%rax
  803360:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803363:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803367:	79 05                	jns    80336e <accept+0x32>
  803369:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80336c:	eb 3b                	jmp    8033a9 <accept+0x6d>
  80336e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  803372:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  803376:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803379:	48 89 ce             	mov    %rcx,%rsi
  80337c:	89 c7                	mov    %eax,%edi
  80337e:	48 b8 87 36 80 00 00 	movabs $0x803687,%rax
  803385:	00 00 00 
  803388:	ff d0                	callq  *%rax
  80338a:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80338d:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803391:	79 05                	jns    803398 <accept+0x5c>
  803393:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803396:	eb 11                	jmp    8033a9 <accept+0x6d>
  803398:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80339b:	89 c7                	mov    %eax,%edi
  80339d:	48 b8 9d 32 80 00 00 	movabs $0x80329d,%rax
  8033a4:	00 00 00 
  8033a7:	ff d0                	callq  *%rax
  8033a9:	c9                   	leaveq 
  8033aa:	c3                   	retq   

00000000008033ab <bind>:
  8033ab:	55                   	push   %rbp
  8033ac:	48 89 e5             	mov    %rsp,%rbp
  8033af:	48 83 ec 20          	sub    $0x20,%rsp
  8033b3:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8033b6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8033ba:	89 55 e8             	mov    %edx,-0x18(%rbp)
  8033bd:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8033c0:	89 c7                	mov    %eax,%edi
  8033c2:	48 b8 46 32 80 00 00 	movabs $0x803246,%rax
  8033c9:	00 00 00 
  8033cc:	ff d0                	callq  *%rax
  8033ce:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8033d1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8033d5:	79 05                	jns    8033dc <bind+0x31>
  8033d7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033da:	eb 1b                	jmp    8033f7 <bind+0x4c>
  8033dc:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8033df:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8033e3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033e6:	48 89 ce             	mov    %rcx,%rsi
  8033e9:	89 c7                	mov    %eax,%edi
  8033eb:	48 b8 06 37 80 00 00 	movabs $0x803706,%rax
  8033f2:	00 00 00 
  8033f5:	ff d0                	callq  *%rax
  8033f7:	c9                   	leaveq 
  8033f8:	c3                   	retq   

00000000008033f9 <shutdown>:
  8033f9:	55                   	push   %rbp
  8033fa:	48 89 e5             	mov    %rsp,%rbp
  8033fd:	48 83 ec 20          	sub    $0x20,%rsp
  803401:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803404:	89 75 e8             	mov    %esi,-0x18(%rbp)
  803407:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80340a:	89 c7                	mov    %eax,%edi
  80340c:	48 b8 46 32 80 00 00 	movabs $0x803246,%rax
  803413:	00 00 00 
  803416:	ff d0                	callq  *%rax
  803418:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80341b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80341f:	79 05                	jns    803426 <shutdown+0x2d>
  803421:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803424:	eb 16                	jmp    80343c <shutdown+0x43>
  803426:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803429:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80342c:	89 d6                	mov    %edx,%esi
  80342e:	89 c7                	mov    %eax,%edi
  803430:	48 b8 6a 37 80 00 00 	movabs $0x80376a,%rax
  803437:	00 00 00 
  80343a:	ff d0                	callq  *%rax
  80343c:	c9                   	leaveq 
  80343d:	c3                   	retq   

000000000080343e <devsock_close>:
  80343e:	55                   	push   %rbp
  80343f:	48 89 e5             	mov    %rsp,%rbp
  803442:	48 83 ec 10          	sub    $0x10,%rsp
  803446:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80344a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80344e:	48 89 c7             	mov    %rax,%rdi
  803451:	48 b8 40 46 80 00 00 	movabs $0x804640,%rax
  803458:	00 00 00 
  80345b:	ff d0                	callq  *%rax
  80345d:	83 f8 01             	cmp    $0x1,%eax
  803460:	75 17                	jne    803479 <devsock_close+0x3b>
  803462:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803466:	8b 40 0c             	mov    0xc(%rax),%eax
  803469:	89 c7                	mov    %eax,%edi
  80346b:	48 b8 aa 37 80 00 00 	movabs $0x8037aa,%rax
  803472:	00 00 00 
  803475:	ff d0                	callq  *%rax
  803477:	eb 05                	jmp    80347e <devsock_close+0x40>
  803479:	b8 00 00 00 00       	mov    $0x0,%eax
  80347e:	c9                   	leaveq 
  80347f:	c3                   	retq   

0000000000803480 <connect>:
  803480:	55                   	push   %rbp
  803481:	48 89 e5             	mov    %rsp,%rbp
  803484:	48 83 ec 20          	sub    $0x20,%rsp
  803488:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80348b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80348f:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803492:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803495:	89 c7                	mov    %eax,%edi
  803497:	48 b8 46 32 80 00 00 	movabs $0x803246,%rax
  80349e:	00 00 00 
  8034a1:	ff d0                	callq  *%rax
  8034a3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8034a6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8034aa:	79 05                	jns    8034b1 <connect+0x31>
  8034ac:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034af:	eb 1b                	jmp    8034cc <connect+0x4c>
  8034b1:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8034b4:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8034b8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034bb:	48 89 ce             	mov    %rcx,%rsi
  8034be:	89 c7                	mov    %eax,%edi
  8034c0:	48 b8 d7 37 80 00 00 	movabs $0x8037d7,%rax
  8034c7:	00 00 00 
  8034ca:	ff d0                	callq  *%rax
  8034cc:	c9                   	leaveq 
  8034cd:	c3                   	retq   

00000000008034ce <listen>:
  8034ce:	55                   	push   %rbp
  8034cf:	48 89 e5             	mov    %rsp,%rbp
  8034d2:	48 83 ec 20          	sub    $0x20,%rsp
  8034d6:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8034d9:	89 75 e8             	mov    %esi,-0x18(%rbp)
  8034dc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8034df:	89 c7                	mov    %eax,%edi
  8034e1:	48 b8 46 32 80 00 00 	movabs $0x803246,%rax
  8034e8:	00 00 00 
  8034eb:	ff d0                	callq  *%rax
  8034ed:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8034f0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8034f4:	79 05                	jns    8034fb <listen+0x2d>
  8034f6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034f9:	eb 16                	jmp    803511 <listen+0x43>
  8034fb:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8034fe:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803501:	89 d6                	mov    %edx,%esi
  803503:	89 c7                	mov    %eax,%edi
  803505:	48 b8 3b 38 80 00 00 	movabs $0x80383b,%rax
  80350c:	00 00 00 
  80350f:	ff d0                	callq  *%rax
  803511:	c9                   	leaveq 
  803512:	c3                   	retq   

0000000000803513 <devsock_read>:
  803513:	55                   	push   %rbp
  803514:	48 89 e5             	mov    %rsp,%rbp
  803517:	48 83 ec 20          	sub    $0x20,%rsp
  80351b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80351f:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803523:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  803527:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80352b:	89 c2                	mov    %eax,%edx
  80352d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803531:	8b 40 0c             	mov    0xc(%rax),%eax
  803534:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  803538:	b9 00 00 00 00       	mov    $0x0,%ecx
  80353d:	89 c7                	mov    %eax,%edi
  80353f:	48 b8 7b 38 80 00 00 	movabs $0x80387b,%rax
  803546:	00 00 00 
  803549:	ff d0                	callq  *%rax
  80354b:	c9                   	leaveq 
  80354c:	c3                   	retq   

000000000080354d <devsock_write>:
  80354d:	55                   	push   %rbp
  80354e:	48 89 e5             	mov    %rsp,%rbp
  803551:	48 83 ec 20          	sub    $0x20,%rsp
  803555:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803559:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80355d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  803561:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803565:	89 c2                	mov    %eax,%edx
  803567:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80356b:	8b 40 0c             	mov    0xc(%rax),%eax
  80356e:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  803572:	b9 00 00 00 00       	mov    $0x0,%ecx
  803577:	89 c7                	mov    %eax,%edi
  803579:	48 b8 47 39 80 00 00 	movabs $0x803947,%rax
  803580:	00 00 00 
  803583:	ff d0                	callq  *%rax
  803585:	c9                   	leaveq 
  803586:	c3                   	retq   

0000000000803587 <devsock_stat>:
  803587:	55                   	push   %rbp
  803588:	48 89 e5             	mov    %rsp,%rbp
  80358b:	48 83 ec 10          	sub    $0x10,%rsp
  80358f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803593:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803597:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80359b:	48 be 4a 4e 80 00 00 	movabs $0x804e4a,%rsi
  8035a2:	00 00 00 
  8035a5:	48 89 c7             	mov    %rax,%rdi
  8035a8:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  8035af:	00 00 00 
  8035b2:	ff d0                	callq  *%rax
  8035b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8035b9:	c9                   	leaveq 
  8035ba:	c3                   	retq   

00000000008035bb <socket>:
  8035bb:	55                   	push   %rbp
  8035bc:	48 89 e5             	mov    %rsp,%rbp
  8035bf:	48 83 ec 20          	sub    $0x20,%rsp
  8035c3:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8035c6:	89 75 e8             	mov    %esi,-0x18(%rbp)
  8035c9:	89 55 e4             	mov    %edx,-0x1c(%rbp)
  8035cc:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8035cf:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  8035d2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8035d5:	89 ce                	mov    %ecx,%esi
  8035d7:	89 c7                	mov    %eax,%edi
  8035d9:	48 b8 ff 39 80 00 00 	movabs $0x8039ff,%rax
  8035e0:	00 00 00 
  8035e3:	ff d0                	callq  *%rax
  8035e5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8035e8:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8035ec:	79 05                	jns    8035f3 <socket+0x38>
  8035ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8035f1:	eb 11                	jmp    803604 <socket+0x49>
  8035f3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8035f6:	89 c7                	mov    %eax,%edi
  8035f8:	48 b8 9d 32 80 00 00 	movabs $0x80329d,%rax
  8035ff:	00 00 00 
  803602:	ff d0                	callq  *%rax
  803604:	c9                   	leaveq 
  803605:	c3                   	retq   

0000000000803606 <nsipc>:
  803606:	55                   	push   %rbp
  803607:	48 89 e5             	mov    %rsp,%rbp
  80360a:	48 83 ec 10          	sub    $0x10,%rsp
  80360e:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803611:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  803618:	00 00 00 
  80361b:	8b 00                	mov    (%rax),%eax
  80361d:	85 c0                	test   %eax,%eax
  80361f:	75 1d                	jne    80363e <nsipc+0x38>
  803621:	bf 02 00 00 00       	mov    $0x2,%edi
  803626:	48 b8 ce 45 80 00 00 	movabs $0x8045ce,%rax
  80362d:	00 00 00 
  803630:	ff d0                	callq  *%rax
  803632:	48 ba 04 70 80 00 00 	movabs $0x807004,%rdx
  803639:	00 00 00 
  80363c:	89 02                	mov    %eax,(%rdx)
  80363e:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  803645:	00 00 00 
  803648:	8b 00                	mov    (%rax),%eax
  80364a:	8b 75 fc             	mov    -0x4(%rbp),%esi
  80364d:	b9 07 00 00 00       	mov    $0x7,%ecx
  803652:	48 ba 00 a0 80 00 00 	movabs $0x80a000,%rdx
  803659:	00 00 00 
  80365c:	89 c7                	mov    %eax,%edi
  80365e:	48 b8 38 45 80 00 00 	movabs $0x804538,%rax
  803665:	00 00 00 
  803668:	ff d0                	callq  *%rax
  80366a:	ba 00 00 00 00       	mov    $0x0,%edx
  80366f:	be 00 00 00 00       	mov    $0x0,%esi
  803674:	bf 00 00 00 00       	mov    $0x0,%edi
  803679:	48 b8 77 44 80 00 00 	movabs $0x804477,%rax
  803680:	00 00 00 
  803683:	ff d0                	callq  *%rax
  803685:	c9                   	leaveq 
  803686:	c3                   	retq   

0000000000803687 <nsipc_accept>:
  803687:	55                   	push   %rbp
  803688:	48 89 e5             	mov    %rsp,%rbp
  80368b:	48 83 ec 30          	sub    $0x30,%rsp
  80368f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803692:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803696:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80369a:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8036a1:	00 00 00 
  8036a4:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8036a7:	89 10                	mov    %edx,(%rax)
  8036a9:	bf 01 00 00 00       	mov    $0x1,%edi
  8036ae:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  8036b5:	00 00 00 
  8036b8:	ff d0                	callq  *%rax
  8036ba:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8036bd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8036c1:	78 3e                	js     803701 <nsipc_accept+0x7a>
  8036c3:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8036ca:	00 00 00 
  8036cd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8036d1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8036d5:	8b 40 10             	mov    0x10(%rax),%eax
  8036d8:	89 c2                	mov    %eax,%edx
  8036da:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8036de:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8036e2:	48 89 ce             	mov    %rcx,%rsi
  8036e5:	48 89 c7             	mov    %rax,%rdi
  8036e8:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  8036ef:	00 00 00 
  8036f2:	ff d0                	callq  *%rax
  8036f4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8036f8:	8b 50 10             	mov    0x10(%rax),%edx
  8036fb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8036ff:	89 10                	mov    %edx,(%rax)
  803701:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803704:	c9                   	leaveq 
  803705:	c3                   	retq   

0000000000803706 <nsipc_bind>:
  803706:	55                   	push   %rbp
  803707:	48 89 e5             	mov    %rsp,%rbp
  80370a:	48 83 ec 10          	sub    $0x10,%rsp
  80370e:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803711:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803715:	89 55 f8             	mov    %edx,-0x8(%rbp)
  803718:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80371f:	00 00 00 
  803722:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803725:	89 10                	mov    %edx,(%rax)
  803727:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80372a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80372e:	48 89 c6             	mov    %rax,%rsi
  803731:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  803738:	00 00 00 
  80373b:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  803742:	00 00 00 
  803745:	ff d0                	callq  *%rax
  803747:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80374e:	00 00 00 
  803751:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803754:	89 50 14             	mov    %edx,0x14(%rax)
  803757:	bf 02 00 00 00       	mov    $0x2,%edi
  80375c:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  803763:	00 00 00 
  803766:	ff d0                	callq  *%rax
  803768:	c9                   	leaveq 
  803769:	c3                   	retq   

000000000080376a <nsipc_shutdown>:
  80376a:	55                   	push   %rbp
  80376b:	48 89 e5             	mov    %rsp,%rbp
  80376e:	48 83 ec 10          	sub    $0x10,%rsp
  803772:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803775:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803778:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80377f:	00 00 00 
  803782:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803785:	89 10                	mov    %edx,(%rax)
  803787:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80378e:	00 00 00 
  803791:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803794:	89 50 04             	mov    %edx,0x4(%rax)
  803797:	bf 03 00 00 00       	mov    $0x3,%edi
  80379c:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  8037a3:	00 00 00 
  8037a6:	ff d0                	callq  *%rax
  8037a8:	c9                   	leaveq 
  8037a9:	c3                   	retq   

00000000008037aa <nsipc_close>:
  8037aa:	55                   	push   %rbp
  8037ab:	48 89 e5             	mov    %rsp,%rbp
  8037ae:	48 83 ec 10          	sub    $0x10,%rsp
  8037b2:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8037b5:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8037bc:	00 00 00 
  8037bf:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8037c2:	89 10                	mov    %edx,(%rax)
  8037c4:	bf 04 00 00 00       	mov    $0x4,%edi
  8037c9:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  8037d0:	00 00 00 
  8037d3:	ff d0                	callq  *%rax
  8037d5:	c9                   	leaveq 
  8037d6:	c3                   	retq   

00000000008037d7 <nsipc_connect>:
  8037d7:	55                   	push   %rbp
  8037d8:	48 89 e5             	mov    %rsp,%rbp
  8037db:	48 83 ec 10          	sub    $0x10,%rsp
  8037df:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8037e2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8037e6:	89 55 f8             	mov    %edx,-0x8(%rbp)
  8037e9:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8037f0:	00 00 00 
  8037f3:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8037f6:	89 10                	mov    %edx,(%rax)
  8037f8:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8037fb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8037ff:	48 89 c6             	mov    %rax,%rsi
  803802:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  803809:	00 00 00 
  80380c:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  803813:	00 00 00 
  803816:	ff d0                	callq  *%rax
  803818:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80381f:	00 00 00 
  803822:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803825:	89 50 14             	mov    %edx,0x14(%rax)
  803828:	bf 05 00 00 00       	mov    $0x5,%edi
  80382d:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  803834:	00 00 00 
  803837:	ff d0                	callq  *%rax
  803839:	c9                   	leaveq 
  80383a:	c3                   	retq   

000000000080383b <nsipc_listen>:
  80383b:	55                   	push   %rbp
  80383c:	48 89 e5             	mov    %rsp,%rbp
  80383f:	48 83 ec 10          	sub    $0x10,%rsp
  803843:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803846:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803849:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803850:	00 00 00 
  803853:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803856:	89 10                	mov    %edx,(%rax)
  803858:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80385f:	00 00 00 
  803862:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803865:	89 50 04             	mov    %edx,0x4(%rax)
  803868:	bf 06 00 00 00       	mov    $0x6,%edi
  80386d:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  803874:	00 00 00 
  803877:	ff d0                	callq  *%rax
  803879:	c9                   	leaveq 
  80387a:	c3                   	retq   

000000000080387b <nsipc_recv>:
  80387b:	55                   	push   %rbp
  80387c:	48 89 e5             	mov    %rsp,%rbp
  80387f:	48 83 ec 30          	sub    $0x30,%rsp
  803883:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803886:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80388a:	89 55 e8             	mov    %edx,-0x18(%rbp)
  80388d:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  803890:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803897:	00 00 00 
  80389a:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80389d:	89 10                	mov    %edx,(%rax)
  80389f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038a6:	00 00 00 
  8038a9:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8038ac:	89 50 04             	mov    %edx,0x4(%rax)
  8038af:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038b6:	00 00 00 
  8038b9:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8038bc:	89 50 08             	mov    %edx,0x8(%rax)
  8038bf:	bf 07 00 00 00       	mov    $0x7,%edi
  8038c4:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  8038cb:	00 00 00 
  8038ce:	ff d0                	callq  *%rax
  8038d0:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8038d3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8038d7:	78 69                	js     803942 <nsipc_recv+0xc7>
  8038d9:	81 7d fc 3f 06 00 00 	cmpl   $0x63f,-0x4(%rbp)
  8038e0:	7f 08                	jg     8038ea <nsipc_recv+0x6f>
  8038e2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8038e5:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  8038e8:	7e 35                	jle    80391f <nsipc_recv+0xa4>
  8038ea:	48 b9 51 4e 80 00 00 	movabs $0x804e51,%rcx
  8038f1:	00 00 00 
  8038f4:	48 ba 66 4e 80 00 00 	movabs $0x804e66,%rdx
  8038fb:	00 00 00 
  8038fe:	be 62 00 00 00       	mov    $0x62,%esi
  803903:	48 bf 7b 4e 80 00 00 	movabs $0x804e7b,%rdi
  80390a:	00 00 00 
  80390d:	b8 00 00 00 00       	mov    $0x0,%eax
  803912:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  803919:	00 00 00 
  80391c:	41 ff d0             	callq  *%r8
  80391f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803922:	48 63 d0             	movslq %eax,%rdx
  803925:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803929:	48 be 00 a0 80 00 00 	movabs $0x80a000,%rsi
  803930:	00 00 00 
  803933:	48 89 c7             	mov    %rax,%rdi
  803936:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  80393d:	00 00 00 
  803940:	ff d0                	callq  *%rax
  803942:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803945:	c9                   	leaveq 
  803946:	c3                   	retq   

0000000000803947 <nsipc_send>:
  803947:	55                   	push   %rbp
  803948:	48 89 e5             	mov    %rsp,%rbp
  80394b:	48 83 ec 20          	sub    $0x20,%rsp
  80394f:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803952:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803956:	89 55 f8             	mov    %edx,-0x8(%rbp)
  803959:	89 4d ec             	mov    %ecx,-0x14(%rbp)
  80395c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803963:	00 00 00 
  803966:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803969:	89 10                	mov    %edx,(%rax)
  80396b:	81 7d f8 3f 06 00 00 	cmpl   $0x63f,-0x8(%rbp)
  803972:	7e 35                	jle    8039a9 <nsipc_send+0x62>
  803974:	48 b9 8a 4e 80 00 00 	movabs $0x804e8a,%rcx
  80397b:	00 00 00 
  80397e:	48 ba 66 4e 80 00 00 	movabs $0x804e66,%rdx
  803985:	00 00 00 
  803988:	be 6d 00 00 00       	mov    $0x6d,%esi
  80398d:	48 bf 7b 4e 80 00 00 	movabs $0x804e7b,%rdi
  803994:	00 00 00 
  803997:	b8 00 00 00 00       	mov    $0x0,%eax
  80399c:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  8039a3:	00 00 00 
  8039a6:	41 ff d0             	callq  *%r8
  8039a9:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8039ac:	48 63 d0             	movslq %eax,%rdx
  8039af:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8039b3:	48 89 c6             	mov    %rax,%rsi
  8039b6:	48 bf 0c a0 80 00 00 	movabs $0x80a00c,%rdi
  8039bd:	00 00 00 
  8039c0:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  8039c7:	00 00 00 
  8039ca:	ff d0                	callq  *%rax
  8039cc:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039d3:	00 00 00 
  8039d6:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8039d9:	89 50 04             	mov    %edx,0x4(%rax)
  8039dc:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039e3:	00 00 00 
  8039e6:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8039e9:	89 50 08             	mov    %edx,0x8(%rax)
  8039ec:	bf 08 00 00 00       	mov    $0x8,%edi
  8039f1:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  8039f8:	00 00 00 
  8039fb:	ff d0                	callq  *%rax
  8039fd:	c9                   	leaveq 
  8039fe:	c3                   	retq   

00000000008039ff <nsipc_socket>:
  8039ff:	55                   	push   %rbp
  803a00:	48 89 e5             	mov    %rsp,%rbp
  803a03:	48 83 ec 10          	sub    $0x10,%rsp
  803a07:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803a0a:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803a0d:	89 55 f4             	mov    %edx,-0xc(%rbp)
  803a10:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a17:	00 00 00 
  803a1a:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803a1d:	89 10                	mov    %edx,(%rax)
  803a1f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a26:	00 00 00 
  803a29:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803a2c:	89 50 04             	mov    %edx,0x4(%rax)
  803a2f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a36:	00 00 00 
  803a39:	8b 55 f4             	mov    -0xc(%rbp),%edx
  803a3c:	89 50 08             	mov    %edx,0x8(%rax)
  803a3f:	bf 09 00 00 00       	mov    $0x9,%edi
  803a44:	48 b8 06 36 80 00 00 	movabs $0x803606,%rax
  803a4b:	00 00 00 
  803a4e:	ff d0                	callq  *%rax
  803a50:	c9                   	leaveq 
  803a51:	c3                   	retq   

0000000000803a52 <pipe>:
  803a52:	55                   	push   %rbp
  803a53:	48 89 e5             	mov    %rsp,%rbp
  803a56:	53                   	push   %rbx
  803a57:	48 83 ec 38          	sub    $0x38,%rsp
  803a5b:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  803a5f:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
  803a63:	48 89 c7             	mov    %rax,%rdi
  803a66:	48 b8 69 22 80 00 00 	movabs $0x802269,%rax
  803a6d:	00 00 00 
  803a70:	ff d0                	callq  *%rax
  803a72:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803a75:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803a79:	0f 88 bf 01 00 00    	js     803c3e <pipe+0x1ec>
  803a7f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803a83:	ba 07 04 00 00       	mov    $0x407,%edx
  803a88:	48 89 c6             	mov    %rax,%rsi
  803a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  803a90:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  803a97:	00 00 00 
  803a9a:	ff d0                	callq  *%rax
  803a9c:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803a9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803aa3:	0f 88 95 01 00 00    	js     803c3e <pipe+0x1ec>
  803aa9:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  803aad:	48 89 c7             	mov    %rax,%rdi
  803ab0:	48 b8 69 22 80 00 00 	movabs $0x802269,%rax
  803ab7:	00 00 00 
  803aba:	ff d0                	callq  *%rax
  803abc:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803abf:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803ac3:	0f 88 5d 01 00 00    	js     803c26 <pipe+0x1d4>
  803ac9:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803acd:	ba 07 04 00 00       	mov    $0x407,%edx
  803ad2:	48 89 c6             	mov    %rax,%rsi
  803ad5:	bf 00 00 00 00       	mov    $0x0,%edi
  803ada:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  803ae1:	00 00 00 
  803ae4:	ff d0                	callq  *%rax
  803ae6:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803ae9:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803aed:	0f 88 33 01 00 00    	js     803c26 <pipe+0x1d4>
  803af3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803af7:	48 89 c7             	mov    %rax,%rdi
  803afa:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803b01:	00 00 00 
  803b04:	ff d0                	callq  *%rax
  803b06:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  803b0a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803b0e:	ba 07 04 00 00       	mov    $0x407,%edx
  803b13:	48 89 c6             	mov    %rax,%rsi
  803b16:	bf 00 00 00 00       	mov    $0x0,%edi
  803b1b:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  803b22:	00 00 00 
  803b25:	ff d0                	callq  *%rax
  803b27:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803b2a:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803b2e:	79 05                	jns    803b35 <pipe+0xe3>
  803b30:	e9 d9 00 00 00       	jmpq   803c0e <pipe+0x1bc>
  803b35:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803b39:	48 89 c7             	mov    %rax,%rdi
  803b3c:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803b43:	00 00 00 
  803b46:	ff d0                	callq  *%rax
  803b48:	48 89 c2             	mov    %rax,%rdx
  803b4b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803b4f:	41 b8 07 04 00 00    	mov    $0x407,%r8d
  803b55:	48 89 d1             	mov    %rdx,%rcx
  803b58:	ba 00 00 00 00       	mov    $0x0,%edx
  803b5d:	48 89 c6             	mov    %rax,%rsi
  803b60:	bf 00 00 00 00       	mov    $0x0,%edi
  803b65:	48 b8 8d 1d 80 00 00 	movabs $0x801d8d,%rax
  803b6c:	00 00 00 
  803b6f:	ff d0                	callq  *%rax
  803b71:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803b74:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803b78:	79 1b                	jns    803b95 <pipe+0x143>
  803b7a:	90                   	nop
  803b7b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803b7f:	48 89 c6             	mov    %rax,%rsi
  803b82:	bf 00 00 00 00       	mov    $0x0,%edi
  803b87:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  803b8e:	00 00 00 
  803b91:	ff d0                	callq  *%rax
  803b93:	eb 79                	jmp    803c0e <pipe+0x1bc>
  803b95:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803b99:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803ba0:	00 00 00 
  803ba3:	8b 12                	mov    (%rdx),%edx
  803ba5:	89 10                	mov    %edx,(%rax)
  803ba7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803bab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)
  803bb2:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803bb6:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803bbd:	00 00 00 
  803bc0:	8b 12                	mov    (%rdx),%edx
  803bc2:	89 10                	mov    %edx,(%rax)
  803bc4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803bc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%rax)
  803bcf:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803bd3:	48 89 c7             	mov    %rax,%rdi
  803bd6:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  803bdd:	00 00 00 
  803be0:	ff d0                	callq  *%rax
  803be2:	89 c2                	mov    %eax,%edx
  803be4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803be8:	89 10                	mov    %edx,(%rax)
  803bea:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803bee:	48 8d 58 04          	lea    0x4(%rax),%rbx
  803bf2:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803bf6:	48 89 c7             	mov    %rax,%rdi
  803bf9:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  803c00:	00 00 00 
  803c03:	ff d0                	callq  *%rax
  803c05:	89 03                	mov    %eax,(%rbx)
  803c07:	b8 00 00 00 00       	mov    $0x0,%eax
  803c0c:	eb 33                	jmp    803c41 <pipe+0x1ef>
  803c0e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803c12:	48 89 c6             	mov    %rax,%rsi
  803c15:	bf 00 00 00 00       	mov    $0x0,%edi
  803c1a:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  803c21:	00 00 00 
  803c24:	ff d0                	callq  *%rax
  803c26:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803c2a:	48 89 c6             	mov    %rax,%rsi
  803c2d:	bf 00 00 00 00       	mov    $0x0,%edi
  803c32:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  803c39:	00 00 00 
  803c3c:	ff d0                	callq  *%rax
  803c3e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803c41:	48 83 c4 38          	add    $0x38,%rsp
  803c45:	5b                   	pop    %rbx
  803c46:	5d                   	pop    %rbp
  803c47:	c3                   	retq   

0000000000803c48 <_pipeisclosed>:
  803c48:	55                   	push   %rbp
  803c49:	48 89 e5             	mov    %rsp,%rbp
  803c4c:	53                   	push   %rbx
  803c4d:	48 83 ec 28          	sub    $0x28,%rsp
  803c51:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803c55:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803c59:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803c60:	00 00 00 
  803c63:	48 8b 00             	mov    (%rax),%rax
  803c66:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  803c6c:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803c6f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803c73:	48 89 c7             	mov    %rax,%rdi
  803c76:	48 b8 40 46 80 00 00 	movabs $0x804640,%rax
  803c7d:	00 00 00 
  803c80:	ff d0                	callq  *%rax
  803c82:	89 c3                	mov    %eax,%ebx
  803c84:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803c88:	48 89 c7             	mov    %rax,%rdi
  803c8b:	48 b8 40 46 80 00 00 	movabs $0x804640,%rax
  803c92:	00 00 00 
  803c95:	ff d0                	callq  *%rax
  803c97:	39 c3                	cmp    %eax,%ebx
  803c99:	0f 94 c0             	sete   %al
  803c9c:	0f b6 c0             	movzbl %al,%eax
  803c9f:	89 45 e8             	mov    %eax,-0x18(%rbp)
  803ca2:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803ca9:	00 00 00 
  803cac:	48 8b 00             	mov    (%rax),%rax
  803caf:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  803cb5:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  803cb8:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803cbb:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803cbe:	75 05                	jne    803cc5 <_pipeisclosed+0x7d>
  803cc0:	8b 45 e8             	mov    -0x18(%rbp),%eax
  803cc3:	eb 4f                	jmp    803d14 <_pipeisclosed+0xcc>
  803cc5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803cc8:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803ccb:	74 42                	je     803d0f <_pipeisclosed+0xc7>
  803ccd:	83 7d e8 01          	cmpl   $0x1,-0x18(%rbp)
  803cd1:	75 3c                	jne    803d0f <_pipeisclosed+0xc7>
  803cd3:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803cda:	00 00 00 
  803cdd:	48 8b 00             	mov    (%rax),%rax
  803ce0:	8b 90 d8 00 00 00    	mov    0xd8(%rax),%edx
  803ce6:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803ce9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803cec:	89 c6                	mov    %eax,%esi
  803cee:	48 bf 9b 4e 80 00 00 	movabs $0x804e9b,%rdi
  803cf5:	00 00 00 
  803cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  803cfd:	49 b8 59 08 80 00 00 	movabs $0x800859,%r8
  803d04:	00 00 00 
  803d07:	41 ff d0             	callq  *%r8
  803d0a:	e9 4a ff ff ff       	jmpq   803c59 <_pipeisclosed+0x11>
  803d0f:	e9 45 ff ff ff       	jmpq   803c59 <_pipeisclosed+0x11>
  803d14:	48 83 c4 28          	add    $0x28,%rsp
  803d18:	5b                   	pop    %rbx
  803d19:	5d                   	pop    %rbp
  803d1a:	c3                   	retq   

0000000000803d1b <pipeisclosed>:
  803d1b:	55                   	push   %rbp
  803d1c:	48 89 e5             	mov    %rsp,%rbp
  803d1f:	48 83 ec 30          	sub    $0x30,%rsp
  803d23:	89 7d dc             	mov    %edi,-0x24(%rbp)
  803d26:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  803d2a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  803d2d:	48 89 d6             	mov    %rdx,%rsi
  803d30:	89 c7                	mov    %eax,%edi
  803d32:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  803d39:	00 00 00 
  803d3c:	ff d0                	callq  *%rax
  803d3e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803d41:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803d45:	79 05                	jns    803d4c <pipeisclosed+0x31>
  803d47:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803d4a:	eb 31                	jmp    803d7d <pipeisclosed+0x62>
  803d4c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803d50:	48 89 c7             	mov    %rax,%rdi
  803d53:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803d5a:	00 00 00 
  803d5d:	ff d0                	callq  *%rax
  803d5f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803d63:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803d67:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803d6b:	48 89 d6             	mov    %rdx,%rsi
  803d6e:	48 89 c7             	mov    %rax,%rdi
  803d71:	48 b8 48 3c 80 00 00 	movabs $0x803c48,%rax
  803d78:	00 00 00 
  803d7b:	ff d0                	callq  *%rax
  803d7d:	c9                   	leaveq 
  803d7e:	c3                   	retq   

0000000000803d7f <devpipe_read>:
  803d7f:	55                   	push   %rbp
  803d80:	48 89 e5             	mov    %rsp,%rbp
  803d83:	48 83 ec 40          	sub    $0x40,%rsp
  803d87:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803d8b:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803d8f:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803d93:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d97:	48 89 c7             	mov    %rax,%rdi
  803d9a:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803da1:	00 00 00 
  803da4:	ff d0                	callq  *%rax
  803da6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803daa:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803dae:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803db2:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  803db9:	00 
  803dba:	e9 92 00 00 00       	jmpq   803e51 <devpipe_read+0xd2>
  803dbf:	eb 41                	jmp    803e02 <devpipe_read+0x83>
  803dc1:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  803dc6:	74 09                	je     803dd1 <devpipe_read+0x52>
  803dc8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803dcc:	e9 92 00 00 00       	jmpq   803e63 <devpipe_read+0xe4>
  803dd1:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803dd5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803dd9:	48 89 d6             	mov    %rdx,%rsi
  803ddc:	48 89 c7             	mov    %rax,%rdi
  803ddf:	48 b8 48 3c 80 00 00 	movabs $0x803c48,%rax
  803de6:	00 00 00 
  803de9:	ff d0                	callq  *%rax
  803deb:	85 c0                	test   %eax,%eax
  803ded:	74 07                	je     803df6 <devpipe_read+0x77>
  803def:	b8 00 00 00 00       	mov    $0x0,%eax
  803df4:	eb 6d                	jmp    803e63 <devpipe_read+0xe4>
  803df6:	48 b8 ff 1c 80 00 00 	movabs $0x801cff,%rax
  803dfd:	00 00 00 
  803e00:	ff d0                	callq  *%rax
  803e02:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e06:	8b 10                	mov    (%rax),%edx
  803e08:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e0c:	8b 40 04             	mov    0x4(%rax),%eax
  803e0f:	39 c2                	cmp    %eax,%edx
  803e11:	74 ae                	je     803dc1 <devpipe_read+0x42>
  803e13:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803e17:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  803e1b:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  803e1f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e23:	8b 00                	mov    (%rax),%eax
  803e25:	99                   	cltd   
  803e26:	c1 ea 1b             	shr    $0x1b,%edx
  803e29:	01 d0                	add    %edx,%eax
  803e2b:	83 e0 1f             	and    $0x1f,%eax
  803e2e:	29 d0                	sub    %edx,%eax
  803e30:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803e34:	48 98                	cltq   
  803e36:	0f b6 44 02 08       	movzbl 0x8(%rdx,%rax,1),%eax
  803e3b:	88 01                	mov    %al,(%rcx)
  803e3d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e41:	8b 00                	mov    (%rax),%eax
  803e43:	8d 50 01             	lea    0x1(%rax),%edx
  803e46:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e4a:	89 10                	mov    %edx,(%rax)
  803e4c:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  803e51:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803e55:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  803e59:	0f 82 60 ff ff ff    	jb     803dbf <devpipe_read+0x40>
  803e5f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803e63:	c9                   	leaveq 
  803e64:	c3                   	retq   

0000000000803e65 <devpipe_write>:
  803e65:	55                   	push   %rbp
  803e66:	48 89 e5             	mov    %rsp,%rbp
  803e69:	48 83 ec 40          	sub    $0x40,%rsp
  803e6d:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803e71:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803e75:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803e79:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803e7d:	48 89 c7             	mov    %rax,%rdi
  803e80:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803e87:	00 00 00 
  803e8a:	ff d0                	callq  *%rax
  803e8c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803e90:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803e94:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803e98:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  803e9f:	00 
  803ea0:	e9 8e 00 00 00       	jmpq   803f33 <devpipe_write+0xce>
  803ea5:	eb 31                	jmp    803ed8 <devpipe_write+0x73>
  803ea7:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803eab:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803eaf:	48 89 d6             	mov    %rdx,%rsi
  803eb2:	48 89 c7             	mov    %rax,%rdi
  803eb5:	48 b8 48 3c 80 00 00 	movabs $0x803c48,%rax
  803ebc:	00 00 00 
  803ebf:	ff d0                	callq  *%rax
  803ec1:	85 c0                	test   %eax,%eax
  803ec3:	74 07                	je     803ecc <devpipe_write+0x67>
  803ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  803eca:	eb 79                	jmp    803f45 <devpipe_write+0xe0>
  803ecc:	48 b8 ff 1c 80 00 00 	movabs $0x801cff,%rax
  803ed3:	00 00 00 
  803ed6:	ff d0                	callq  *%rax
  803ed8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803edc:	8b 40 04             	mov    0x4(%rax),%eax
  803edf:	48 63 d0             	movslq %eax,%rdx
  803ee2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803ee6:	8b 00                	mov    (%rax),%eax
  803ee8:	48 98                	cltq   
  803eea:	48 83 c0 20          	add    $0x20,%rax
  803eee:	48 39 c2             	cmp    %rax,%rdx
  803ef1:	73 b4                	jae    803ea7 <devpipe_write+0x42>
  803ef3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803ef7:	8b 40 04             	mov    0x4(%rax),%eax
  803efa:	99                   	cltd   
  803efb:	c1 ea 1b             	shr    $0x1b,%edx
  803efe:	01 d0                	add    %edx,%eax
  803f00:	83 e0 1f             	and    $0x1f,%eax
  803f03:	29 d0                	sub    %edx,%eax
  803f05:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  803f09:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  803f0d:	48 01 ca             	add    %rcx,%rdx
  803f10:	0f b6 0a             	movzbl (%rdx),%ecx
  803f13:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803f17:	48 98                	cltq   
  803f19:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  803f1d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803f21:	8b 40 04             	mov    0x4(%rax),%eax
  803f24:	8d 50 01             	lea    0x1(%rax),%edx
  803f27:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803f2b:	89 50 04             	mov    %edx,0x4(%rax)
  803f2e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  803f33:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f37:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  803f3b:	0f 82 64 ff ff ff    	jb     803ea5 <devpipe_write+0x40>
  803f41:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f45:	c9                   	leaveq 
  803f46:	c3                   	retq   

0000000000803f47 <devpipe_stat>:
  803f47:	55                   	push   %rbp
  803f48:	48 89 e5             	mov    %rsp,%rbp
  803f4b:	48 83 ec 20          	sub    $0x20,%rsp
  803f4f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  803f53:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803f57:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803f5b:	48 89 c7             	mov    %rax,%rdi
  803f5e:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  803f65:	00 00 00 
  803f68:	ff d0                	callq  *%rax
  803f6a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  803f6e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803f72:	48 be ae 4e 80 00 00 	movabs $0x804eae,%rsi
  803f79:	00 00 00 
  803f7c:	48 89 c7             	mov    %rax,%rdi
  803f7f:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  803f86:	00 00 00 
  803f89:	ff d0                	callq  *%rax
  803f8b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f8f:	8b 50 04             	mov    0x4(%rax),%edx
  803f92:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f96:	8b 00                	mov    (%rax),%eax
  803f98:	29 c2                	sub    %eax,%edx
  803f9a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803f9e:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  803fa4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803fa8:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  803faf:	00 00 00 
  803fb2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803fb6:	48 b9 e0 60 80 00 00 	movabs $0x8060e0,%rcx
  803fbd:	00 00 00 
  803fc0:	48 89 88 88 00 00 00 	mov    %rcx,0x88(%rax)
  803fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  803fcc:	c9                   	leaveq 
  803fcd:	c3                   	retq   

0000000000803fce <devpipe_close>:
  803fce:	55                   	push   %rbp
  803fcf:	48 89 e5             	mov    %rsp,%rbp
  803fd2:	48 83 ec 10          	sub    $0x10,%rsp
  803fd6:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803fda:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803fde:	48 89 c6             	mov    %rax,%rsi
  803fe1:	bf 00 00 00 00       	mov    $0x0,%edi
  803fe6:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  803fed:	00 00 00 
  803ff0:	ff d0                	callq  *%rax
  803ff2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803ff6:	48 89 c7             	mov    %rax,%rdi
  803ff9:	48 b8 3e 22 80 00 00 	movabs $0x80223e,%rax
  804000:	00 00 00 
  804003:	ff d0                	callq  *%rax
  804005:	48 89 c6             	mov    %rax,%rsi
  804008:	bf 00 00 00 00       	mov    $0x0,%edi
  80400d:	48 b8 e8 1d 80 00 00 	movabs $0x801de8,%rax
  804014:	00 00 00 
  804017:	ff d0                	callq  *%rax
  804019:	c9                   	leaveq 
  80401a:	c3                   	retq   

000000000080401b <wait>:
  80401b:	55                   	push   %rbp
  80401c:	48 89 e5             	mov    %rsp,%rbp
  80401f:	48 83 ec 20          	sub    $0x20,%rsp
  804023:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804026:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80402a:	75 35                	jne    804061 <wait+0x46>
  80402c:	48 b9 b5 4e 80 00 00 	movabs $0x804eb5,%rcx
  804033:	00 00 00 
  804036:	48 ba c0 4e 80 00 00 	movabs $0x804ec0,%rdx
  80403d:	00 00 00 
  804040:	be 0a 00 00 00       	mov    $0xa,%esi
  804045:	48 bf d5 4e 80 00 00 	movabs $0x804ed5,%rdi
  80404c:	00 00 00 
  80404f:	b8 00 00 00 00       	mov    $0x0,%eax
  804054:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  80405b:	00 00 00 
  80405e:	41 ff d0             	callq  *%r8
  804061:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804064:	25 ff 03 00 00       	and    $0x3ff,%eax
  804069:	48 98                	cltq   
  80406b:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  804072:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  804079:	00 00 00 
  80407c:	48 01 d0             	add    %rdx,%rax
  80407f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  804083:	eb 0c                	jmp    804091 <wait+0x76>
  804085:	48 b8 ff 1c 80 00 00 	movabs $0x801cff,%rax
  80408c:	00 00 00 
  80408f:	ff d0                	callq  *%rax
  804091:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804095:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80409b:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  80409e:	75 0e                	jne    8040ae <wait+0x93>
  8040a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8040a4:	8b 80 d4 00 00 00    	mov    0xd4(%rax),%eax
  8040aa:	85 c0                	test   %eax,%eax
  8040ac:	75 d7                	jne    804085 <wait+0x6a>
  8040ae:	c9                   	leaveq 
  8040af:	c3                   	retq   

00000000008040b0 <cputchar>:
  8040b0:	55                   	push   %rbp
  8040b1:	48 89 e5             	mov    %rsp,%rbp
  8040b4:	48 83 ec 20          	sub    $0x20,%rsp
  8040b8:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8040bb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8040be:	88 45 ff             	mov    %al,-0x1(%rbp)
  8040c1:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
  8040c5:	be 01 00 00 00       	mov    $0x1,%esi
  8040ca:	48 89 c7             	mov    %rax,%rdi
  8040cd:	48 b8 f5 1b 80 00 00 	movabs $0x801bf5,%rax
  8040d4:	00 00 00 
  8040d7:	ff d0                	callq  *%rax
  8040d9:	c9                   	leaveq 
  8040da:	c3                   	retq   

00000000008040db <getchar>:
  8040db:	55                   	push   %rbp
  8040dc:	48 89 e5             	mov    %rsp,%rbp
  8040df:	48 83 ec 10          	sub    $0x10,%rsp
  8040e3:	48 8d 45 fb          	lea    -0x5(%rbp),%rax
  8040e7:	ba 01 00 00 00       	mov    $0x1,%edx
  8040ec:	48 89 c6             	mov    %rax,%rsi
  8040ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8040f4:	48 b8 33 27 80 00 00 	movabs $0x802733,%rax
  8040fb:	00 00 00 
  8040fe:	ff d0                	callq  *%rax
  804100:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804103:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804107:	79 05                	jns    80410e <getchar+0x33>
  804109:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80410c:	eb 14                	jmp    804122 <getchar+0x47>
  80410e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804112:	7f 07                	jg     80411b <getchar+0x40>
  804114:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  804119:	eb 07                	jmp    804122 <getchar+0x47>
  80411b:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80411f:	0f b6 c0             	movzbl %al,%eax
  804122:	c9                   	leaveq 
  804123:	c3                   	retq   

0000000000804124 <iscons>:
  804124:	55                   	push   %rbp
  804125:	48 89 e5             	mov    %rsp,%rbp
  804128:	48 83 ec 20          	sub    $0x20,%rsp
  80412c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80412f:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  804133:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804136:	48 89 d6             	mov    %rdx,%rsi
  804139:	89 c7                	mov    %eax,%edi
  80413b:	48 b8 01 23 80 00 00 	movabs $0x802301,%rax
  804142:	00 00 00 
  804145:	ff d0                	callq  *%rax
  804147:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80414a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80414e:	79 05                	jns    804155 <iscons+0x31>
  804150:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804153:	eb 1a                	jmp    80416f <iscons+0x4b>
  804155:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804159:	8b 10                	mov    (%rax),%edx
  80415b:	48 b8 20 61 80 00 00 	movabs $0x806120,%rax
  804162:	00 00 00 
  804165:	8b 00                	mov    (%rax),%eax
  804167:	39 c2                	cmp    %eax,%edx
  804169:	0f 94 c0             	sete   %al
  80416c:	0f b6 c0             	movzbl %al,%eax
  80416f:	c9                   	leaveq 
  804170:	c3                   	retq   

0000000000804171 <opencons>:
  804171:	55                   	push   %rbp
  804172:	48 89 e5             	mov    %rsp,%rbp
  804175:	48 83 ec 10          	sub    $0x10,%rsp
  804179:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  80417d:	48 89 c7             	mov    %rax,%rdi
  804180:	48 b8 69 22 80 00 00 	movabs $0x802269,%rax
  804187:	00 00 00 
  80418a:	ff d0                	callq  *%rax
  80418c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80418f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804193:	79 05                	jns    80419a <opencons+0x29>
  804195:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804198:	eb 5b                	jmp    8041f5 <opencons+0x84>
  80419a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80419e:	ba 07 04 00 00       	mov    $0x407,%edx
  8041a3:	48 89 c6             	mov    %rax,%rsi
  8041a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8041ab:	48 b8 3d 1d 80 00 00 	movabs $0x801d3d,%rax
  8041b2:	00 00 00 
  8041b5:	ff d0                	callq  *%rax
  8041b7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8041ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8041be:	79 05                	jns    8041c5 <opencons+0x54>
  8041c0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041c3:	eb 30                	jmp    8041f5 <opencons+0x84>
  8041c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8041c9:	48 ba 20 61 80 00 00 	movabs $0x806120,%rdx
  8041d0:	00 00 00 
  8041d3:	8b 12                	mov    (%rdx),%edx
  8041d5:	89 10                	mov    %edx,(%rax)
  8041d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8041db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  8041e2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8041e6:	48 89 c7             	mov    %rax,%rdi
  8041e9:	48 b8 1b 22 80 00 00 	movabs $0x80221b,%rax
  8041f0:	00 00 00 
  8041f3:	ff d0                	callq  *%rax
  8041f5:	c9                   	leaveq 
  8041f6:	c3                   	retq   

00000000008041f7 <devcons_read>:
  8041f7:	55                   	push   %rbp
  8041f8:	48 89 e5             	mov    %rsp,%rbp
  8041fb:	48 83 ec 30          	sub    $0x30,%rsp
  8041ff:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804203:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  804207:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80420b:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804210:	75 07                	jne    804219 <devcons_read+0x22>
  804212:	b8 00 00 00 00       	mov    $0x0,%eax
  804217:	eb 4b                	jmp    804264 <devcons_read+0x6d>
  804219:	eb 0c                	jmp    804227 <devcons_read+0x30>
  80421b:	48 b8 ff 1c 80 00 00 	movabs $0x801cff,%rax
  804222:	00 00 00 
  804225:	ff d0                	callq  *%rax
  804227:	48 b8 3f 1c 80 00 00 	movabs $0x801c3f,%rax
  80422e:	00 00 00 
  804231:	ff d0                	callq  *%rax
  804233:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804236:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80423a:	74 df                	je     80421b <devcons_read+0x24>
  80423c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804240:	79 05                	jns    804247 <devcons_read+0x50>
  804242:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804245:	eb 1d                	jmp    804264 <devcons_read+0x6d>
  804247:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  80424b:	75 07                	jne    804254 <devcons_read+0x5d>
  80424d:	b8 00 00 00 00       	mov    $0x0,%eax
  804252:	eb 10                	jmp    804264 <devcons_read+0x6d>
  804254:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804257:	89 c2                	mov    %eax,%edx
  804259:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80425d:	88 10                	mov    %dl,(%rax)
  80425f:	b8 01 00 00 00       	mov    $0x1,%eax
  804264:	c9                   	leaveq 
  804265:	c3                   	retq   

0000000000804266 <devcons_write>:
  804266:	55                   	push   %rbp
  804267:	48 89 e5             	mov    %rsp,%rbp
  80426a:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  804271:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  804278:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  80427f:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  804286:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80428d:	eb 76                	jmp    804305 <devcons_write+0x9f>
  80428f:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  804296:	89 c2                	mov    %eax,%edx
  804298:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80429b:	29 c2                	sub    %eax,%edx
  80429d:	89 d0                	mov    %edx,%eax
  80429f:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8042a2:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8042a5:	83 f8 7f             	cmp    $0x7f,%eax
  8042a8:	76 07                	jbe    8042b1 <devcons_write+0x4b>
  8042aa:	c7 45 f8 7f 00 00 00 	movl   $0x7f,-0x8(%rbp)
  8042b1:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8042b4:	48 63 d0             	movslq %eax,%rdx
  8042b7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8042ba:	48 63 c8             	movslq %eax,%rcx
  8042bd:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8042c4:	48 01 c1             	add    %rax,%rcx
  8042c7:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  8042ce:	48 89 ce             	mov    %rcx,%rsi
  8042d1:	48 89 c7             	mov    %rax,%rdi
  8042d4:	48 b8 32 17 80 00 00 	movabs $0x801732,%rax
  8042db:	00 00 00 
  8042de:	ff d0                	callq  *%rax
  8042e0:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8042e3:	48 63 d0             	movslq %eax,%rdx
  8042e6:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  8042ed:	48 89 d6             	mov    %rdx,%rsi
  8042f0:	48 89 c7             	mov    %rax,%rdi
  8042f3:	48 b8 f5 1b 80 00 00 	movabs $0x801bf5,%rax
  8042fa:	00 00 00 
  8042fd:	ff d0                	callq  *%rax
  8042ff:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804302:	01 45 fc             	add    %eax,-0x4(%rbp)
  804305:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804308:	48 98                	cltq   
  80430a:	48 3b 85 58 ff ff ff 	cmp    -0xa8(%rbp),%rax
  804311:	0f 82 78 ff ff ff    	jb     80428f <devcons_write+0x29>
  804317:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80431a:	c9                   	leaveq 
  80431b:	c3                   	retq   

000000000080431c <devcons_close>:
  80431c:	55                   	push   %rbp
  80431d:	48 89 e5             	mov    %rsp,%rbp
  804320:	48 83 ec 08          	sub    $0x8,%rsp
  804324:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  804328:	b8 00 00 00 00       	mov    $0x0,%eax
  80432d:	c9                   	leaveq 
  80432e:	c3                   	retq   

000000000080432f <devcons_stat>:
  80432f:	55                   	push   %rbp
  804330:	48 89 e5             	mov    %rsp,%rbp
  804333:	48 83 ec 10          	sub    $0x10,%rsp
  804337:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80433b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80433f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804343:	48 be e8 4e 80 00 00 	movabs $0x804ee8,%rsi
  80434a:	00 00 00 
  80434d:	48 89 c7             	mov    %rax,%rdi
  804350:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  804357:	00 00 00 
  80435a:	ff d0                	callq  *%rax
  80435c:	b8 00 00 00 00       	mov    $0x0,%eax
  804361:	c9                   	leaveq 
  804362:	c3                   	retq   

0000000000804363 <_panic>:
  804363:	55                   	push   %rbp
  804364:	48 89 e5             	mov    %rsp,%rbp
  804367:	53                   	push   %rbx
  804368:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  80436f:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  804376:	89 b5 14 ff ff ff    	mov    %esi,-0xec(%rbp)
  80437c:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804383:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80438a:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  804391:	84 c0                	test   %al,%al
  804393:	74 23                	je     8043b8 <_panic+0x55>
  804395:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80439c:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  8043a0:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8043a4:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8043a8:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8043ac:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  8043b0:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  8043b4:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  8043b8:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
  8043bf:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8043c6:	00 00 00 
  8043c9:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8043d0:	00 00 00 
  8043d3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8043d7:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8043de:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8043e5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8043ec:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  8043f3:	00 00 00 
  8043f6:	48 8b 18             	mov    (%rax),%rbx
  8043f9:	48 b8 c1 1c 80 00 00 	movabs $0x801cc1,%rax
  804400:	00 00 00 
  804403:	ff d0                	callq  *%rax
  804405:	8b 8d 14 ff ff ff    	mov    -0xec(%rbp),%ecx
  80440b:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  804412:	41 89 c8             	mov    %ecx,%r8d
  804415:	48 89 d1             	mov    %rdx,%rcx
  804418:	48 89 da             	mov    %rbx,%rdx
  80441b:	89 c6                	mov    %eax,%esi
  80441d:	48 bf f0 4e 80 00 00 	movabs $0x804ef0,%rdi
  804424:	00 00 00 
  804427:	b8 00 00 00 00       	mov    $0x0,%eax
  80442c:	49 b9 59 08 80 00 00 	movabs $0x800859,%r9
  804433:	00 00 00 
  804436:	41 ff d1             	callq  *%r9
  804439:	48 8d 95 28 ff ff ff 	lea    -0xd8(%rbp),%rdx
  804440:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  804447:	48 89 d6             	mov    %rdx,%rsi
  80444a:	48 89 c7             	mov    %rax,%rdi
  80444d:	48 b8 ad 07 80 00 00 	movabs $0x8007ad,%rax
  804454:	00 00 00 
  804457:	ff d0                	callq  *%rax
  804459:	48 bf 13 4f 80 00 00 	movabs $0x804f13,%rdi
  804460:	00 00 00 
  804463:	b8 00 00 00 00       	mov    $0x0,%eax
  804468:	48 ba 59 08 80 00 00 	movabs $0x800859,%rdx
  80446f:	00 00 00 
  804472:	ff d2                	callq  *%rdx
  804474:	cc                   	int3   
  804475:	eb fd                	jmp    804474 <_panic+0x111>

0000000000804477 <ipc_recv>:
  804477:	55                   	push   %rbp
  804478:	48 89 e5             	mov    %rsp,%rbp
  80447b:	48 83 ec 30          	sub    $0x30,%rsp
  80447f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804483:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  804487:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80448b:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  804490:	75 0e                	jne    8044a0 <ipc_recv+0x29>
  804492:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  804499:	00 00 00 
  80449c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8044a0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8044a4:	48 89 c7             	mov    %rax,%rdi
  8044a7:	48 b8 66 1f 80 00 00 	movabs $0x801f66,%rax
  8044ae:	00 00 00 
  8044b1:	ff d0                	callq  *%rax
  8044b3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8044b6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8044ba:	79 27                	jns    8044e3 <ipc_recv+0x6c>
  8044bc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8044c1:	74 0a                	je     8044cd <ipc_recv+0x56>
  8044c3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8044c7:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  8044cd:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8044d2:	74 0a                	je     8044de <ipc_recv+0x67>
  8044d4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8044d8:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  8044de:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8044e1:	eb 53                	jmp    804536 <ipc_recv+0xbf>
  8044e3:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8044e8:	74 19                	je     804503 <ipc_recv+0x8c>
  8044ea:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8044f1:	00 00 00 
  8044f4:	48 8b 00             	mov    (%rax),%rax
  8044f7:	8b 90 0c 01 00 00    	mov    0x10c(%rax),%edx
  8044fd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804501:	89 10                	mov    %edx,(%rax)
  804503:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804508:	74 19                	je     804523 <ipc_recv+0xac>
  80450a:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804511:	00 00 00 
  804514:	48 8b 00             	mov    (%rax),%rax
  804517:	8b 90 10 01 00 00    	mov    0x110(%rax),%edx
  80451d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804521:	89 10                	mov    %edx,(%rax)
  804523:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80452a:	00 00 00 
  80452d:	48 8b 00             	mov    (%rax),%rax
  804530:	8b 80 08 01 00 00    	mov    0x108(%rax),%eax
  804536:	c9                   	leaveq 
  804537:	c3                   	retq   

0000000000804538 <ipc_send>:
  804538:	55                   	push   %rbp
  804539:	48 89 e5             	mov    %rsp,%rbp
  80453c:	48 83 ec 30          	sub    $0x30,%rsp
  804540:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804543:	89 75 e8             	mov    %esi,-0x18(%rbp)
  804546:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  80454a:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  80454d:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  804552:	75 10                	jne    804564 <ipc_send+0x2c>
  804554:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  80455b:	00 00 00 
  80455e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  804562:	eb 0e                	jmp    804572 <ipc_send+0x3a>
  804564:	eb 0c                	jmp    804572 <ipc_send+0x3a>
  804566:	48 b8 ff 1c 80 00 00 	movabs $0x801cff,%rax
  80456d:	00 00 00 
  804570:	ff d0                	callq  *%rax
  804572:	8b 75 e8             	mov    -0x18(%rbp),%esi
  804575:	8b 4d dc             	mov    -0x24(%rbp),%ecx
  804578:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  80457c:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80457f:	89 c7                	mov    %eax,%edi
  804581:	48 b8 11 1f 80 00 00 	movabs $0x801f11,%rax
  804588:	00 00 00 
  80458b:	ff d0                	callq  *%rax
  80458d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804590:	83 7d fc f8          	cmpl   $0xfffffff8,-0x4(%rbp)
  804594:	74 d0                	je     804566 <ipc_send+0x2e>
  804596:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80459a:	79 30                	jns    8045cc <ipc_send+0x94>
  80459c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80459f:	89 c1                	mov    %eax,%ecx
  8045a1:	48 ba 15 4f 80 00 00 	movabs $0x804f15,%rdx
  8045a8:	00 00 00 
  8045ab:	be 44 00 00 00       	mov    $0x44,%esi
  8045b0:	48 bf 2b 4f 80 00 00 	movabs $0x804f2b,%rdi
  8045b7:	00 00 00 
  8045ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8045bf:	49 b8 63 43 80 00 00 	movabs $0x804363,%r8
  8045c6:	00 00 00 
  8045c9:	41 ff d0             	callq  *%r8
  8045cc:	c9                   	leaveq 
  8045cd:	c3                   	retq   

00000000008045ce <ipc_find_env>:
  8045ce:	55                   	push   %rbp
  8045cf:	48 89 e5             	mov    %rsp,%rbp
  8045d2:	48 83 ec 14          	sub    $0x14,%rsp
  8045d6:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8045d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8045e0:	eb 4e                	jmp    804630 <ipc_find_env+0x62>
  8045e2:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  8045e9:	00 00 00 
  8045ec:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8045ef:	48 98                	cltq   
  8045f1:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  8045f8:	48 01 d0             	add    %rdx,%rax
  8045fb:	48 05 d0 00 00 00    	add    $0xd0,%rax
  804601:	8b 00                	mov    (%rax),%eax
  804603:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  804606:	75 24                	jne    80462c <ipc_find_env+0x5e>
  804608:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  80460f:	00 00 00 
  804612:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804615:	48 98                	cltq   
  804617:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  80461e:	48 01 d0             	add    %rdx,%rax
  804621:	48 05 c0 00 00 00    	add    $0xc0,%rax
  804627:	8b 40 08             	mov    0x8(%rax),%eax
  80462a:	eb 12                	jmp    80463e <ipc_find_env+0x70>
  80462c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  804630:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%rbp)
  804637:	7e a9                	jle    8045e2 <ipc_find_env+0x14>
  804639:	b8 00 00 00 00       	mov    $0x0,%eax
  80463e:	c9                   	leaveq 
  80463f:	c3                   	retq   

0000000000804640 <pageref>:
  804640:	55                   	push   %rbp
  804641:	48 89 e5             	mov    %rsp,%rbp
  804644:	48 83 ec 18          	sub    $0x18,%rsp
  804648:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80464c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804650:	48 c1 e8 15          	shr    $0x15,%rax
  804654:	48 89 c2             	mov    %rax,%rdx
  804657:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  80465e:	01 00 00 
  804661:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  804665:	83 e0 01             	and    $0x1,%eax
  804668:	48 85 c0             	test   %rax,%rax
  80466b:	75 07                	jne    804674 <pageref+0x34>
  80466d:	b8 00 00 00 00       	mov    $0x0,%eax
  804672:	eb 53                	jmp    8046c7 <pageref+0x87>
  804674:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804678:	48 c1 e8 0c          	shr    $0xc,%rax
  80467c:	48 89 c2             	mov    %rax,%rdx
  80467f:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  804686:	01 00 00 
  804689:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80468d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  804691:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804695:	83 e0 01             	and    $0x1,%eax
  804698:	48 85 c0             	test   %rax,%rax
  80469b:	75 07                	jne    8046a4 <pageref+0x64>
  80469d:	b8 00 00 00 00       	mov    $0x0,%eax
  8046a2:	eb 23                	jmp    8046c7 <pageref+0x87>
  8046a4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8046a8:	48 c1 e8 0c          	shr    $0xc,%rax
  8046ac:	48 89 c2             	mov    %rax,%rdx
  8046af:	48 b8 00 00 a0 00 80 	movabs $0x8000a00000,%rax
  8046b6:	00 00 00 
  8046b9:	48 c1 e2 04          	shl    $0x4,%rdx
  8046bd:	48 01 d0             	add    %rdx,%rax
  8046c0:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8046c4:	0f b7 c0             	movzwl %ax,%eax
  8046c7:	c9                   	leaveq 
  8046c8:	c3                   	retq   
