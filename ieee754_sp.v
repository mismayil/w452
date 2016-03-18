module ieee754_sp(output [31:0] d, output reg done,
  input clk, input [31:0] a, b, input [1:0] op, input go, reset);

    parameter sign_bit = 31,
              exp_msb = 30,
              exp_lsb = 23,
              frac_msb = 22,
              frac_lsb = 0;

    parameter [7:0] bias = 127;

    parameter [1:0] st_ready = 0,
                    st_calc = 1,
                    st_norm = 2;

    parameter [1:0] op_mult = 0,
                    op_div = 1,
                    op_add = 2,
                    op_sub = 3;

    parameter [31:0] PZERO = {1'b0, {8{1'b0}}, {23{1'b0}}},
                     NZERO = {1'b1, {8{1'b0}}, {23{1'b0}}},
                     PINFINITY = {1'b0, {8{1'b1}}, {23{1'b0}}},
                     NINFINITY = {1'b1, {8{1'b1}}, {23{1'b0}}},
                     NAN = {1'bx, {8{1'b1}}, {23{1'b1}}};

    reg [1:0] state;
    reg [31:0] regA, regB;
    reg [7:0] shift;
    reg [7:0] exp;
    reg [47:0] sig;
    reg sign, signA, signB;
    reg [7:0] expA, expB;
    reg [23:0] sigA, sigB;
    integer iexp, UNDERFLOW = 0, OVERFLOW = 255;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            done <= 0;
            state <= st_ready;
        end
        else
          case (state)
              st_ready: if (go) state <= st_calc;
              st_calc: state <= st_norm;
              st_norm: if (sig[47:46] == 2'b01) state <= st_ready;
          endcase
    end

    always @(posedge clk, posedge reset) begin
        if (reset == 0) begin

            if (state == st_ready && go) begin
                regA <= a;
                regB <= b;
                done <= 0;
            end
            else if (state == st_calc) begin
                if (op == op_sub) regB[sign_bit] = ~regB[sign_bit];

                sigA = {1'b1, regA[frac_msb:frac_lsb]};
                sigB = {1'b1, regB[frac_msb:frac_lsb]};
                expA = regA[exp_msb:exp_lsb];
                expB = regB[exp_msb:exp_lsb];
                signA = regA[sign_bit];
                signB = regB[sign_bit];
                shift = 0;
                iexp = 0;

                if (op == op_add || op == op_sub) begin
                    if ((regA[30:23] == NAN[30:23] && regA[22:0] > 0) || (regB[30:23] == NAN[30:23] && regB[22:0] > 0)) {sign, exp, sig[45:23]} = NAN;
                    else if (regA == PINFINITY && regB == PINFINITY) {sign, exp, sig[45:23]} = PINFINITY;
                    else if (regA == NINFINITY && regB == NINFINITY) {sign, exp, sig[45:23]} = NINFINITY;
                    else if ((regA == PINFINITY && regB == NINFINITY) || (regA == NINFINITY && regB == PINFINITY)) {sign, exp, sig[45:23]} = NAN;
                    else begin
                        if (expA > expB) begin
                            exp = expA;
                            iexp = expA;
                            shift = expA - expB;
                            sigB = sigB >> shift;
                        end
                        else begin
                            exp = expB;
                            iexp = expB;
                            shift = expB - expA;
                            sigA = sigA >> shift;
                        end

                        if (signA == signB) begin
                            sig[47:23] = sigA + sigB;
                            sign = signA & signB;
                        end
                        else begin
                            if (sigA >= sigB) begin
                                sig[47:23] = sigA - sigB;
                                sign = signA;
                            end
                            else begin
                                sig[47:23] = sigB - sigA;
                                sign = signB;
                            end
                        end
                    end
                end

                if (op == op_mult) begin
                    if (((regA == PZERO || regA == NZERO) && (regB == PINFINITY || regB == NINFINITY)) ||
                       ((regB == PZERO || regB == NZERO) && (regA == PINFINITY || regA == NINFINITY))) {sign, exp, sig[45:23]} = NAN;
                    else if ((regA == PINFINITY || regA == NINFINITY) || (regB == PINFINITY || regB == NINFINITY)) {sign, exp, sig[45:23]} = {signA ^ signB, PINFINITY[30:0]};
                    else if (regA == PZERO || regA == NZERO || regB == PZERO || regB == NZERO) {sign, exp, sig[45:23]} = {signA ^ signB, PZERO[30:0]};
                    else begin
                        sign = signA ^ signB;
                        exp = expA + expB - bias;
                        iexp = expA + expB - bias;
                        sig = sigA * sigB;
                    end
                end

                if (op == op_div) begin
                    if (((regA == PZERO || regA == NZERO) && (regB == PZERO || regB == NZERO)) ||
                        ((regA == PINFINITY || regB == NINFINITY) && (regB == PINFINITY || regB == NINFINITY))) {sign, exp, sig[45:23]} = NAN;
                    else if (regB == PZERO || regB == NZERO) {sign, exp, sig[45:23]} = {signA ^ signB, PINFINITY[30:0]};
                    else if (regA == PZERO || regA == NZERO || regB == PINFINITY || regB == NINFINITY) {sign, exp, sig[45:23]} = {signA ^ signB, PZERO[30:0]};
                    else begin
                        sign = signA ^ signB;
                        exp = expA - expB + bias;
                        iexp = expA - expB + bias;
                        sig = {sigA, {46{1'b0}}} / sigB;
                    end
                end

                if (iexp <= UNDERFLOW) {exp, sig[45:23]} = PZERO[30:0];
                if (iexp >= OVERFLOW) {exp, sig[45:23]} = PINFINITY[30:0];
            end
            else if (state == st_norm) begin
                if ({sign, exp, sig[45:23]} == PINFINITY ||
                    {sign, exp, sig[45:23]} == NINFINITY ||
                    {sign, exp, sig[45:23]} == PZERO ||
                    {sign, exp, sig[45:23]} == NZERO ||
                    (exp == NAN[30:23] && exp[22:0] > 0)) begin sig[47:46] = 2'b01; done = 1; end
                else if (sig[47:46] != 2'b01) begin
                    if (sig[47]) begin
                        sig = sig >> 1;
                        exp = exp + 1;
                    end
                    else begin
                        sig = sig << 1;
                        exp = exp - 1;
                    end
                end
                if (exp == UNDERFLOW) begin
                    sig[47:46] = 2'b01;
                    {exp, sig[45:23]} = PZERO[30:0];
                    done = 1;
                end
                if (exp == OVERFLOW) begin
                    sig[47:46] = 2'b01;
                    {exp, sig[45:23]} = PINFINITY[30:0];
                    done = 1;
                end
                else done = 1;
            end
        end
    end

    assign d[sign_bit] = sign;
    assign d[exp_msb:exp_lsb] = exp;
    assign d[frac_msb:frac_lsb] = sig[45:23];

endmodule
