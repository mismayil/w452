/*
 * Fill in this stub and submit it.
 */
module w452(
    	output [31:1] mem_wr_addr, output [31:0] mem_wr_data, output mem_wr_en,
    	output [31:1] mem_rd0_addr, input [15:0] mem_rd0_data,
    	output [31:1] mem_rd1_addr, input [31:0] mem_rd1_data,
    	input reset, clk);

	// opcodes
	parameter[3:0]
		OP_BEQ = 4'b0000, OP_BNE = 4'b0001, OP_BLT = 4'b0010, OP_BLE = 4'b0011,
		OP_JR  = 4'b0100, OP_JRL = 4'b0101, OP_LD  = 4'b0110, OP_ST  = 4'b0111,
		OP_ADD = 4'b1000, OP_SUB = 4'b1001, OP_ADI = 4'b1010, OP_LDP = 4'b1011,
		OP_FAD = 4'b1100, OP_FSB = 4'b1101, OP_FML = 4'b1110, OP_FDV = 4'b1111;

    parameter[2:0] STATE_IF = 3'b000,
                   STATE_ID = 3'b001,
                   STATE_EX = 3'b010,
                   STATE_ME = 3'b011,
                   STATE_WB = 3'b100;

	// you must use this register file
    wire[3:0] reg_rd_addr [0:1];
    wire[31:0] reg_rd_data [0:1];
    reg[3:0] reg_wr_addr;
    reg[31:0] reg_wr_data;
    reg reg_wr_en;
    regfile regfile_0(
        .wr_data(reg_wr_data), .wr_num(reg_wr_addr), .wr_en(reg_wr_en),
        .rd0_data(reg_rd_data[0]), .rd1_data(reg_rd_data[1]),
        .rd0_num(reg_rd_addr[0]), .rd1_num(reg_rd_addr[1]),
        .clk(clk));

	// you must use this module for floating-point operations
	wire[31:0] sp_out;
	wire sp_done;
	reg[1:0] sp_op;
	reg sp_go;
    parameter[1:0] SP_MULT = 0, SP_DIV = 1, SP_ADD = 2, SP_SUB = 3;
    ieee754_sp sp(.d(sp_out), .done(sp_done),
		.a(reg_rd_data[0]), .b(reg_rd_data[1]),
		.op(sp_op), .go(sp_go),
		.reset(reset), .clk(clk));

    reg[31:1] pc;
    reg[2:0] state;
    reg[15:0] instr;
    reg[3:0] op, rs, rt, rd, imm;
    reg[7:0] imm8;
    reg[31:0] rsdata, rtdata, rddata;

    assign mem_rd0_addr = pc;
    assign reg_rd_addr[0] = rs;
    assign reg_rd_addr[1] = rt;

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            pc <= 0;
            state <= STATE_IF;
        end
        else begin
            case (state)
                STATE_IF: begin
                    instr <= mem_rd0_data;
                    pc <= pc + 1;
                    state <= STATE_ID;
                end
                STATE_ID: begin
                    op <= instr[15:12];
                    rs <= instr[11:8];
                    imm8 <= instr[7:0];
                    rt <= instr[7:4];
                    imm <= instr[3:0];
                    rd <= instr[3:0];
                    state <= STATE_EX;
                end
                STATE_EX: begin
                    rsdata = (rs) ? reg_rd_data[0] : 0;
                    rtdata = (rt) ? reg_rd_data[1] : 0;
                    case (op)
                        OP_BEQ: begin
                            if (rs == 0) pc <= pc + 1 + {{23{imm8[7]}}, imm8};
                            else pc <= pc + 1;
                        end
                        OP_BNE: begin
                            if (rs != 0) pc <= pc + 1 + {{23{imm8[7]}}, imm8};
                            else pc <= pc + 1;
                        end
                        OP_BLT: begin
                            if (rs < 0) pc <= pc + 1 + {{23{imm8[7]}}, imm8};
                            else pc <= pc + 1;
                        end
                        OP_BLE: begin
                            if (rs <= 0) pc <= pc + 1 + {{23{imm8[7]}}, imm8};
                            else pc <= pc + 1;
                        end
                        OP_ADD: begin
                            rddata <= rsdata + rtdata;
                        end
                        OP_SUB: begin
                            rddata <= rsdata - rtdata;
                        end
                        OP_JR:  begin end
                        OP_JRL: begin end
                        OP_LD:  begin end
                        OP_ST:  begin end
                        OP_ADI: begin
                            rddata <= rsdata + {{24{imm8[7]}}, imm8};
                        end
                        OP_LDP: begin end
                        OP_FAD: begin end
                        OP_FSB: begin end
                        OP_FML: begin end
                        OP_FDV: begin end
                    endcase
                    state <= STATE_ME;
                end
                STATE_ME: begin
                    state <= STATE_WB;
                end
                STATE_WB: begin
                    if (op == OP_ADD || op == OP_SUB || op == OP_FAD || op == OP_FSB || op == OP_FML || op == OP_FDV) begin
                        reg_wr_en <= 1;
                        reg_wr_addr <= rd;
                        reg_wr_data <= rddata;
                    end

                    if (op == OP_ADI) begin
                        reg_wr_en <= 1;
                        reg_wr_addr <= rs;
                        reg_wr_data <= rddata;
                    end
                    state <= STATE_IF;
                end
                default: state <= STATE_IF;
            endcase
        end
    end

endmodule
