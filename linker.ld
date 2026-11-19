ENTRY(_start)
OUTPUT_FORMAT(elf64-x86-64)

PHDRS {
  RX PT_LOAD FLAGS(4 | 1); #Read/execute
  RW PT_LOAD FLAGS(4 | 2); #Read/write
  RO PT_LOAD FLAGS(4);     #Read only
}

#Last 2GiB on memory
_kernel = 0xffffffff80000000;

#Kernel sections
SECTIONS {
  . = _kernel;
  
  .kernel_text : {
    *(.text .text*)
  } :RX

  #Align to page size between each section
  . = ALIGN(0x1000);
    
  .kernel_data : {
    *(.data .data*)
  } :RW

  .kernel_bss (NOLOAD) : {
    *kernel.o(.bss .bss*)
  } :RW

  . = ALIGN(0x1000);
  
  .kernel_rodata : {
    *(.rodata .rodata*)

    #Keep init_array to call c++ constructors
    . = ALIGN(8);
    _init_array = .;
    KEEP(*(.init_array))
    _init_array_end = .;
  } :RO

  _kernel_end = .;
}
