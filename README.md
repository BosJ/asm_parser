# haskell-assembly-parser

The data-types describe the formal lexical structure of a simple fantasy assembly language. Where all constructors of `Opcode`, `FUid`, `FUreg` and `RFid` become recognized tokens. With the following command (in GHCi) the fantasy.asm "program" is parsed and the abstract syntax of is obtained.

`> startParser (unsafePerformIO $ readFile "fantasy.asm")`

The above command gives us the `InstrList`:

<pre><code>
Seq [
  P1 F0 ADD (OCI 0) (OCI 255),
  P2 F1 ABS (OCI 100),
  P3 RA 2 (OCI 10),
  P3 RC 10 (OCR RA 2),
  P1 F2 SUB (OCI 100) (OCR RC 2),
  P3 RA 1 (OCF RF0),
  NOP
]
</code></pre>

A great advantage of using Parsec is that nice error messages are generated when the syntax of the code is incorrect. See the example below. Just adding the opcode OR to the Opcode ADT will resolve this error.

<pre><code>
> startParser "F0 OR 0 0xFF"
*** Exception: (line 1, column 4):
unexpected "O"
expecting "ADD", "SUB" or "ABS"
</code></pre>

