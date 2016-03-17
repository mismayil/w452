module mem(
		input [31:1] wr_addr, input [31:0] wr_data, input wr_en,
		input [31:1] rd0_addr, output [15:0] rd0_data,
		input [31:1] rd1_addr, output [31:0] rd1_data,
		input clk);

    parameter filename = "addArray.data";

    reg[7:0] data [0:2**10-1]; // 1kB of mem

    initial $readmemb(filename, data);

	wire [31:0] wr_ad32 = {wr_addr,1'b0};
	wire [31:0] rd0_ad32 = {rd0_addr,1'b0};
	wire [31:0] rd1_ad32 = {rd1_addr,1'b0};

	// big-endian
    always @(posedge clk)
        if(wr_en)
			{data[wr_ad32+0],data[wr_ad32+1],data[wr_ad32+2],data[wr_ad32+3]}
				<= wr_data;

	assign rd0_data = {data[rd0_ad32+0],data[rd0_ad32+1]};
	assign rd1_data = {data[rd1_ad32+0],data[rd1_ad32+1],data[rd1_ad32+2],data[rd1_ad32+3]};

endmodule
