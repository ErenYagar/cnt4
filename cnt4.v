`timescale 1ns / 1ps
module cnt4
(
input clk,
input rst_n,
input start,
output busy,
output finish,
output [3:0] cnt
);

parameter div_num = 10000000;

reg start_d1;
reg start_d2;
wire start_TG;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
    start_d1 <= 1'b0;
    start_d2 <= 1'b0;
    end
    else
    begin
    start_d1 <= start;
    start_d2 <= start_d1;
    end
end
assign start_TG = start_d1 & !start_d2;

reg busy_r;
reg fin_r;
reg [5:0] cnt_r;

always@(posedge clk or negedge rst_n or posedge fin_r)
begin
    if(!rst_n || fin_r)
    begin
    busy_r <= 1'b0;
    end
    else
    begin
        if(start_TG )
        begin
        busy_r <= 1'b1;
        end
        else
        begin
        busy_r <= busy_r;
        end
    end
end
assign busy = busy_r;

always@(posedge clk or negedge rst_n or posedge start_TG)
begin
    if(!rst_n || start_TG)
    begin
    fin_r <= 1'b0;
    end
    else
    begin
        if(cnt == 4'd15)
        begin
        fin_r <= 1'b1;
        end
        else
        begin
        fin_r <= fin_r;
        end
    end
end
assign finish = fin_r;


reg [23:0] div_cnt;
always@(posedge clk or negedge rst_n or negedge busy_r)
begin
    if(!rst_n || !busy_r)
    begin
    div_cnt <= 24'd0;
    end
    else
    begin
        if(div_cnt < div_num-1)
        begin
        div_cnt <= div_cnt + 24'd1;
        end
        else
        begin
        div_cnt <= 24'd0;
        end
    end
end

reg div_clk;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n )
    begin
    div_clk <= 1'b0;
    end
    else
    begin
        if(busy_r && (div_cnt < div_num/2))
        begin
        div_clk <= 1'b1;
        end
        else
        begin
        div_clk <= 1'b0;
        end
    end
end

always@(posedge div_clk or negedge rst_n )
begin
    if(!rst_n )
    begin
    cnt_r <= 4'd0;
    end
    else
    begin          
            if(busy_r && (cnt_r < 4'd15))
            begin
            cnt_r <= cnt_r + 4'd1;
            end
            else
            begin
            cnt_r <= cnt_r;
            end
    end
end


assign cnt = cnt_r;

endmodule