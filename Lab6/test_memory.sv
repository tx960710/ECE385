//-------------------------------------------------------------------------
//      test_memory.vhd                                                  --
//      Stephen Kempf                                                    --
//      Summer 2005                                                      --
//                                                                       --
//      Revised 3-15-2006                                                --
//              3-22-2007                                                --
//              7-26-2013                                                --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                      --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

// This memory has similar behavior to the SRAM IC on the DE2 board.  This
// file should be used for simulations only.  In simulation, this memory is
// guaranteed to work at least as well as the actual memory (that is, the
// actual memory may require more careful treatment than this test memory).

// To use, you should create a seperate top-level entity for simulation
// that connects this memory module to your computer.  You can create this
// extra entity either in the same project (temporarily setting it to be the
// top module) or in a new one, and create a new vector waveform file for it.

`include "SLC3_2.sv"
import SLC3_2::*;

module test_memory ( input 			Clk,
					 input          Reset, 
                     inout  [15:0]  I_O,
                     input  [19:0]  A,
                     input          CE,
                                    UB,
                                    LB,
                                    OE,
                                    WE );
												
   parameter size = 64; // expand memory as needed (current is 64 words)
	 
   logic [15:0] mem_array [size-1:0];
   logic [15:0] mem_out;
   logic [15:0] I_O_wire;
	 
   assign mem_out = mem_array[A[5:0]];  //ATTENTION: Size here must correspond to size of
              // memory vector above.  Current size is 64, so the slice must be 6 bits.  If size were 1024,
              // slice would have to be 10 bits.  (There are three more places below where values must stay
              // consistent as well.)
	 
   always_comb
   begin
      I_O_wire = 16'bZZZZZZZZZZZZZZZZ;

      if (~CE && ~OE && WE) begin
         if (~UB)
            I_O_wire[15:8] = mem_out[15:8];
				
         if (~LB)
            I_O_wire[7:0] = mem_out[7:0];
		end
   end
	  
   always_ff @ (posedge Clk or posedge Reset)
   begin
		if(Reset)   // Insert initial memory contents here
		begin
			mem_array[   0 ] <=    opCLR(R0)                ;  // 16'b0101 0000 0010 0000	// Clear the register so it can be used as a base
			mem_array[   1 ] <=    opLDR(R1, R0, inSW)      ;  // 16'b0110 0010 0011 1111	// Load switches
			mem_array[   2 ] <=    opJMP(R1)                ;  // 16'b1100 0000 0100 0000	// Jump to the start of a program
																						// Basic I/O test 1
			mem_array[   3 ] <=    opLDR(R1, R0, inSW)      ;  // 16'b0110 0010 0011 1111	// Load switches
			mem_array[   4 ] <=    opSTR(R1, R0, outHEX)    ;  // 16'b0111 0010 0011 1111	// Output
			mem_array[   5 ] <=    opBR(nzp, -3)            ;  // 16'b0000 1111 1111 1101	// Repeat
			
			mem_array[   6 ] <=    opPSE(12'h801)           ;       // Checkpoint 1 - prepare to input
			mem_array[   7 ] <=    opLDR(R1, R0, inSW)      ;       // Load switches
			mem_array[   8 ] <=    opSTR(R1, R0, outHEX)    ;       // Output
			mem_array[   9 ] <=    opPSE(12'hC02)           ;       // Checkpoint 2 - read output, prepare to input
			mem_array[  10 ] <=    opBR(nzp, -4)            ;       // Repeat
			mem_array[  11 ] <=    opPSE(12'h801)           ;       // Checkpoint 1 - prepare to input
			mem_array[  12 ] <=    opJSR(0)                 ;       // Get PC address
			mem_array[  13 ] <=    opLDR(R2,R7,3)           ;       // Load pause instruction as data
			mem_array[  14 ] <=    opLDR(R1, R0, inSW)      ;       // Load switches
			mem_array[  15 ] <=    opSTR(R1, R0, outHEX)    ;       // Output
			mem_array[  16 ] <=    opPSE(12'hC02)           ;       // Checkpoint 2 - read output, prepare to input
			mem_array[  17 ] <=    opINC(R2)                ;       // Increment checkpoint number
			mem_array[  18 ] <=    opSTR(R2,R7,3)           ;       // Store new checkpoint instruction (self-modifying code)
			mem_array[  19 ] <=    opBR(nzp, -6)            ;       // Repeat
			mem_array[  20 ] <= 	  16'h0564;
			
			
			
			for (integer i = 20; i <= size - 1; i = i + 1)		// Assign the rest of the memory to 0
			begin
				mem_array[i] <= 16'h0;
			end
		end
		else if (~CE && ~WE && A[15:6]==10'b0000000000)
		begin
            if(~UB)
			    mem_array[A[5:0]][15:8] <= I_O[15:8];   // A(15 downto X+1): X must
														// be the same as above
		    if(~LB)
			    mem_array[A[5:0]][7:0] <= I_O[7:0];     // A(X downto 0): X
		end                                             // must be the same as above

   end
	  
   assign I_O = I_O_wire;
	  
endmodule