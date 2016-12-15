`define ADDR 8'h7A

`define IIC_CMD	8'h00
`define IIC_DATA	8'h40

`define IIC_NONE	8'd0
`define IIC_START	8'd1
`define IIC_STOP	8'd2
`define IIC_WAIT	8'd3
`define IIC_SEND	8'd4

module OLED(clk, rst, scl, sda);
	input clk, rst;
	output scl, sda;
	wire sign;
	reg[31:0] step;
	reg[7:0] dc, data;
	reg cls;
	
	IICSend send(clk, cls, scl, sda, dc, data, sign);
	
	initial begin
		step <= 32'b0;
		dc <= 8'h80;
		data <= 8'b0;
	end
	
	always @(posedge clk) begin
		if (!rst) begin 
			step <= 32'b0;
			dc <= 8'h80;
			data <= 8'b0;
		end
		case (step)
			8'd01: begin
				dc <= `IIC_CMD;
				data <= 8'hAE;
				cls <= 1;
			end
			8'd02: cls <= 0;
			8'd03: begin
				data <= 8'h00;
				cls <= 1;
			end
			default: cls <= 1;
		endcase
		if (!step[7] && sign) step <= step + 32'b1;
	end

endmodule

module IICSend(clk, rst, scl, sda, dc, dat, sign);
	input clk, rst;
	input[7:0] dc, dat;
	output scl, sda, sign;
	wire isign;
	reg[7:0] step, type, data;
	reg sign;
	
	IIC iic(clk, rst, scl, sda, type, data, isign);
	
	initial begin
		step <= 8'b0;
		type <= `IIC_NONE;
	end
	
	always @(posedge clk) begin
		if (!rst) begin 
			step <= 8'b0;
			type <= `IIC_NONE;
		end
		case (step)
			8'd00: type <= `IIC_NONE;
			8'd01: type <= `IIC_START;
			8'd02: type <= `IIC_NONE;
			8'd03: data <= `ADDR;
			8'd04: type <= `IIC_SEND;
			8'd05: type <= `IIC_NONE;
			8'd06: type <= `IIC_WAIT;
			8'd07: type <= `IIC_NONE;
			8'd08: data <= dc;
			8'd09: type <= `IIC_SEND;
			8'd10: type <= `IIC_NONE;
			8'd11: type <= `IIC_WAIT;
			8'd12: type <= `IIC_NONE;
			8'd13: data <= dat;
			8'd14: type <= `IIC_SEND;
			8'd15: type <= `IIC_NONE;
			8'd16: type <= `IIC_WAIT;
			8'd17: type <= `IIC_NONE;
			8'd18: type <= `IIC_STOP;
			default: step <= 8'h80;
		endcase
		if (!step[7] && isign) step <= step + 8'b1;
		sign <= step[7];
	end

endmodule

module IIC(clk, rst, scl, sda, type, data, sign);
	input clk, rst;
	input[7:0] type, data;
	output scl, sda, sign;
	reg[8:0] step;
	reg scl, sda, sign;
	
	initial begin
		step <= 8'b0;
		sign <= 0;
	end
	
	always @(posedge clk) begin
		if (!rst) begin 
			step <= 8'b0;
			sign <= 0;
		end
		case (type)
			`IIC_NONE: step <= 8'h81;
			`IIC_START: begin
				if (step == 8'h81) step <= 8'b0;
				case (step)
					8'd0: scl <= 1;
					8'd1: sda <= 1;
					8'd2: sda <= 0;
					8'd3: scl <= 0;
					default: step <= 8'h80;
				endcase
				if (!step[7]) step <= step + 8'b1;
			end
			`IIC_STOP: begin
				if (step == 8'h81) step <= 8'b0;
				case (step)
					8'd0: scl <= 1;
					8'd1: sda <= 0;
					8'd2: sda <= 1;
					default: step <= 8'h80;
				endcase
				if (!step[7]) step <= step + 8'b1;
			end
			`IIC_WAIT: begin
				if (step == 8'h81) step <= 8'b0;
				case (step)
					8'd0: scl <= 1;
					8'd1: scl <= 0;
					default: step <= 8'h80;
				endcase
				if (!step[7]) step <= step + 8'b1;
			end
			`IIC_SEND: begin
				if (step == 8'h81) step <= 8'b0;
				case (step)
					8'd00: scl <= 0;
					8'd01: sda <= data[7];
					8'd02: scl <= 1;
					8'd03: scl <= 0;
					8'd04: sda <= data[6];
					8'd05: scl <= 1;
					8'd06: scl <= 0;
					8'd07: sda <= data[5];
					8'd08: scl <= 1;
					8'd09: scl <= 0;
					8'd10: sda <= data[4];
					8'd11: scl <= 1;
					8'd12: scl <= 0;
					8'd13: sda <= data[3];
					8'd14: scl <= 1;
					8'd15: scl <= 0;
					8'd16: sda <= data[2];
					8'd17: scl <= 1;
					8'd18: scl <= 0;
					8'd19: sda <= data[1];
					8'd20: scl <= 1;
					8'd21: scl <= 0;
					8'd22: sda <= data[0];
					8'd23: scl <= 1;
					8'd24: scl <= 0;
					default: step <= 8'h80;
				endcase
				if (!step[7]) step <= step + 8'b1;
			end
		endcase
		sign <= step[7];
	end

endmodule

module Cnter(rst, clk, count, out);
	input rst, clk, count;
	output out;
	reg[31:0] cnt;
	reg out;
	
	initial begin
		cnt <= 32'b0;
		out <= 0;
	end
	
	always @(posedge clk) begin
		if (!rst) begin 
			cnt <= 32'b0;
			out <= 0;
		end
		if (cnt < count) begin 
			cnt <= cnt + 32'b1;
			out <= 0;
		end else begin
			cnt <= 32'b0;
			out <= 1;
		end
	end

endmodule
