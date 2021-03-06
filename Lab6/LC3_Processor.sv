module LC3_Processor(input logic Clk, Reset, Run, Continue,
							input [15:0] S,
							output logic CE, UB, LB, OE, WE,
							output [11:0] LED,
							output [6:0]  HEX0, HEX1, HEX2, HEX3,
							output [19:0] ADDR,
							inout [15:0]  Data);

	wire [15:0] Data_CPU;
	logic [3:0] X0, X1, X2, X3;
							
	/* PHYSICAL MEMORY SECTION */
/*	Mem2IO			Bridge(.*, .Reset(~Reset), .A(ADDR), .Switches(S), .Data_CPU, .Data_Mem(Data), .HEX0(X0), .HEX1(X1), .HEX2(X2), .HEX3(X3));
	CPU				mCPU(.*, .Data(Data_CPU), .HEX0(X0), .HEX1(X1), .HEX2(X2), .HEX3(X3));
*/
	/* TEST_MEMORY SECTION */
	wire [15:0] Data_Mem; // for test_mem only
	Mem2IO			Bridge(.*, .Reset(~Reset), .A(ADDR), .Switches(S), .Data_CPU, .Data_Mem, .HEX0(X0), .HEX1(X1), .HEX2(X2), .HEX3(X3));
	CPU				mCPU(.*, .Data(Data_CPU));
	test_memory		MEM(.*, .Reset(~Reset), .I_O(Data_Mem), .A(ADDR));

	
	
	
	
	HexDriver HexAL (
						.In0(X0),
                  .Out0(HEX0));
	HexDriver HexAU (
                  .In0(X1),
                  .Out0(HEX1));
	HexDriver HexBL (
                  .In0(X2),
                  .Out0(HEX2));
	HexDriver HexBU (
                  .In0(X3),
                  .Out0(HEX3));
						
endmodule 





