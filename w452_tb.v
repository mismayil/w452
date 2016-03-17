/* tb_fetch
* Tests sequential fetching.
* Expected output:
	* pc   0
	* pc   2
	* pc   4
	* pc   6
	* pc   8
*/
module tb_fetch;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("fetch.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

	wire [31:0] pc = mem_rd_addr[0] << 1;
    initial $monitor("pc %3d", pc);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==4)
			$finish;
    end

    initial $dumpvars(0, tb_fetch);
endmodule


/* tb_math
* Tests add, sub, addi
* Expected output:
	* r1=  z, r2=  z
	* r1=  0, r2=  z
	* r1=  1, r2=  z
	* r1=  1, r2=  2
	* r1=  1, r2= -2
	* r1=  3, r2= -2
*/
module tb_math;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("math.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

	wire signed [31:0] r1 = tb_math.w452_0.regfile_0.data[1];
	wire signed [31:0] r2 = tb_math.w452_0.regfile_0.data[2];
    initial $monitor("r1=%3d, r2=%3d", r1, r2);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==6)
			$finish;
    end

    initial $dumpvars(0, tb_math);
endmodule


/* tb_ldst
* Tests ld, st and ldp
* Expected output:
	* mem[128] 00000084
	* mem[128] 0a0a0a0a
	* mem[128] 0f0f0f0f
*/
module tb_ldst;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("ldst.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

    initial $monitor("mem[128] %2h%2h%2h%2h",
		tb_ldst.mem_0.data[128], tb_ldst.mem_0.data[129],
		tb_ldst.mem_0.data[130], tb_ldst.mem_0.data[131]);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==7)
			$finish;
    end

    initial $dumpvars(0, tb_ldst);
endmodule


/* tb_fp
* Tests fad, fsb, fml, fdv
* Expected output:
	* r3 = xxxxxxxx
	* r3 = c0100000
	* r3 = 40700000
	* r3 = c0100000
	* r3 = be800000
	*
*/
module tb_fp;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("fp.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

    initial $monitor("r3 = %8h", tb_fp.w452_0.regfile_0.data[3]);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==7)
			$finish;
    end

    initial $dumpvars(0, tb_fp);
endmodule


/* tb_branch
* Tests forwards and backwards branches and various conditions.
* Expected output:
	* pc   0
	* pc   2
	* pc   4
	* pc   6 (optional)
	* pc  12
	* pc  14 (optional)
	* pc   6
	* pc   8
	* pc  10 (optional)
	* pc  14
	* pc  16
*/
module tb_branch;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("branch.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

	wire [31:0] pc = mem_rd_addr[0] << 1;
    initial $monitor("pc %3d", pc);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==8)
			$finish;
    end

    initial $dumpvars(0, tb_branch);
endmodule


/* tb_jump
* Tests jumps and linkage
* Expected output:
	* pc   0
	* pc   2
	* pc   4 (optional)
	* pc  64
	* pc  66 (optional)
	* pc   4
	* pc   6
*/
module tb_jump;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("jump.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

	wire [31:0] pc = mem_rd_addr[0] << 1;
    initial $monitor("pc %3d", pc);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==3)
			$finish;
    end

    initial $dumpvars(0, tb_jump);
endmodule


/* tb_mult
* Tests integer multiply program
* Expected output:
	* r1 =      z, r2 =      z, r3 =      z
	* r1 =      z, r2 =     96, r3 =      z
	* r1 =      z, r2 =     96, r3 =      7
	* r1 =    672, r2 =     96, r3 =      7
	* r1 =    672, r2 =     96, r3 =     -5
	* r1 =   -480, r2 =     96, r3 =     -5
*/
module tb_mult;
    wire[31:1] mem_wr_addr;
    wire[31:0] mem_wr_data;
    wire mem_wr_en;
    wire[31:1] mem_rd_addr [0:1];
    wire[15:0] mem_rd0_data;
    wire[31:0] mem_rd1_data;
    reg reset, clk;

    mem #(.filename("mult.data")) mem_0(
        .wr_data(mem_wr_data), .wr_addr(mem_wr_addr), .wr_en(mem_wr_en),
        .rd0_data(mem_rd0_data), .rd0_addr(mem_rd_addr[0]),
        .rd1_data(mem_rd1_data), .rd1_addr(mem_rd_addr[1]),
        .clk(clk));

    w452 w452_0(
        .mem_wr_data(mem_wr_data), .mem_wr_addr(mem_wr_addr),
        .mem_wr_en(mem_wr_en),
        .mem_rd0_data(mem_rd0_data), .mem_rd0_addr(mem_rd_addr[0]),
        .mem_rd1_data(mem_rd1_data), .mem_rd1_addr(mem_rd_addr[1]),
        .reset(reset), .clk(clk));

	wire signed [31:0] r1 = tb_mult.w452_0.regfile_0.data[1];
	wire signed [31:0] r2 = tb_mult.w452_0.regfile_0.data[2];
	wire signed [31:0] r3 = tb_mult.w452_0.regfile_0.data[3];
    initial $monitor("r1 = %6d, r2 = %6d, r3 = %6d", r1, r2, r3);

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset=0;
        wait(mem_rd_addr[0]==7)
			$finish;
    end

    initial $dumpvars(0, tb_mult);
endmodule
