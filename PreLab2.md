## What does it mean for there to be EPT support, vs. software driven virtualization? 
### How do we know our VM has EPT support? 
1. EPT (Extended Page Tables) support means that extended page tables are supported 
through machine hardware. This means that there are 2 cr3 registers and the 
guest page table is first walked to get the guest physical address and then the 
host page table is walked to map the guest physical address to the host physical
 address. Software driven virtualization is done without that extra hardware, 
 and therefore requires software support through things like shadow paging or 
 other techniques. There are assembly instructions to see properties of the 
 hardware, which you can use to check if EPT is supported (which we did last lab).

## ELF Headers:  
### What is an ELF header? 
### What does it do? 
2. An ELF header is the first section at the top of an executable, and it describes
 the size and structures of the pieces of the remaining executable. It should be standardized such that the computer shouldn’t need extra information to read any one executable. It also holds information about whether the program should use 32 or 64 bit addresses.

## Set a breakpoint at the function load_icode() in env.c
### What do you notice about the Proghdr object? 
### What kinds of metadata does the object have? 
#### What is this function doing? It is described in the function header, but try to put it in your own words. 

struct Proghdr {
	uint32_t p_type;
	uint32_t p_flags;
	uint64_t p_offset;
	uint64_t p_va;
	uint64_t p_pa;
	uint64_t p_filesz;
	uint64_t p_memsz;
	uint64_t p_align;
};

It is a struct that is used to parse information of the program header file. This is done by initializing a pointer that points to the starting point of the ELF headers. The headers are then iterated through by tracking the end of the headers using the eph pointer. On each iterations, if the header is of type "ELF_PROG_LOAD", memory is allocated and set based on the variables in the headers, namely p_va, p_filesz, P_memsz, and p_offset.

The Proghdr struct has:
p_type: the type of the segment or section. This is used to determine if the header is of the loadable type.
p_flags: This field contains flags that describe various permissions associated with the segment (executable, writable, readable)
p_offset: This field represents the offset in the file where the segment's data begins.
p_va: This field represents the virtual address of the segment when loaded into memory. This is the address where the segment will be mapped in the virtual memory space of the process.
p_pa: This field represents the physical address of the segment.
p_filesz: This field specifies the size of the segment in the file.
p_memsz: This field specifies the size of the segment in memory. It indicates how much memory the segment occupies when loaded into memory. This is most likely different than p_filesz if the segment contains data that occupies space in memory but is not stored in the file.
p_align: This field specifies the alignment requirement for the segment. It indicates the boundary to which the segment's data should be aligned in memory and in the file.

It loads an ELF binary into memory for execution within a given environment. It verifies the binary's validity, sets up paging, and iterates through program headers to load program segments into memory. It allocates memory regions, copies segment data, and ensures proper alignment for the stack. Additionally, it loads debug sections if present. If the binary is invalid, it triggers a panic. Finally, it stores a pointer to the ELF binary within the environment structure. Overall, the function prepares the program in the environment for execution by handling memory allocation, segment loading, stack setup, and debug section loading.


## In our codebase, load_icode() does the work of loading the ELF binary image into the environment's user memory. Looking at this function, where does the memory for the Env get allocated? Where does the memory for the ELF header get allocated? Hint: you may have to check out what some constant values mean. 

First we allocate "physical" memory in the environment and then copy program headers from the elf into the memory we just allocated 

Additonallly one page is allocated in the enviroment for the program stack. The program stack is offset from the user stack by one poge (on top of the stack overflow guard page).

If debug information is present, space for that is also allocated in the environment and copied over

the memory for the enviroment is allocated on the host. The memory for the ELF header is allocated inside the enviroment memory. 


## The first function you implement in this project will have you check many errors, prior to the actual function logic. What are some of the reasons why we must do this in OS level code that the user never sees?

System Stability: OS-level code often operates at a high privilege level, with access to critical system resources. Errors in this code can lead to system crashes or instability. Therefore, preemptive error checking is essential to maintain the overall stability of the system.

Ease of Debugging and Maintenance: When errors are checked and handled properly, it becomes easier to debug and maintain the system. It helps in isolating and identifying the source of problems, which is crucial for the continuous development of the OS.


Recommended files to look through before starting:
inc/memlayout.h describes and provides an ASCII image of the virtual memory map. 
inc/mmu.h describes how to parse information about a page from the address itself 
vmm/ept.h has function declarations that will be helpful throughout, and a macro for page table walks 
lib/fd.c has system calls that can be used to read files 

