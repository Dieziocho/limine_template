extern main

;Kernel entry point
global _start
_start:
  call main

global halt
halt:
  hlt
  jmp halt
