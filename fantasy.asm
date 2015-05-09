F0 ADD 0 0xFF;
F1 ABS 100;

RA:2     = 0xa;
RC:10    = RA:2;
F2 SUB 100 RC:2;

/* comment */ RA : 0x1 = RF0;

NOP
