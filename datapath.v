module datapath(input [15:0]x,input [7:0]y,input start,clk,rst,output [15:0]sinx,output reg ready);
  parameter [2:0] idle =3'b000, starting = 3'b001,loading = 3'b 010, mult1 = 3'b011,mult2 = 3'b100,add = 3'b101,endcheck =3'b 110;
  reg [2:0] ps,ns;
  reg ldx2,inc,icc,co,ldrom,sel_reg,sel_rom,sel_x,sel_mult,ldterm,sel_sinx,ldsin,tff_inp,tff_oup,init_tff,ldy,inity,comp;
  reg [15:0] x2,x2_reg,rom_oup,mux_oup,mux_mult_oup,mult_oup,term_oup,mux_sin_oup,sin_reg_oup,add_oup;
  reg [2:0] cnt_oup;
  reg [31:0] temp_x2;
  reg [7:0] y_oup;
  always@(x,posedge rst)begin //x^2
    if(rst) x2 = 16'b 0;
    else begin
      temp_x2 = x*x;
      x2 = temp_x2[23:8];
    end
  end
  
  always@(ldx2,posedge rst,posedge clk)begin //xreg
    if(rst) x2_reg <= 16'b 0;
    else if(ldx2) x2_reg <= x2;
  end
  
  always@(posedge clk,inc,posedge rst)begin//counter
    if(rst || inc)begin cnt_oup <=3'b 0; co=0;end
    else if(icc) cnt_oup = cnt_oup + 1;
    if (cnt_oup == 8) co<=1;
  end
  
  always@(posedge rst,cnt_oup,ldrom)begin//rom
    if(rst) rom_oup = 16'b 0;
    else if(ldrom)begin
      case (cnt_oup)
        0: rom_oup = 1;
        1: rom_oup = 1/(2*3);
        2: rom_oup = 1/(4*5);
        3: rom_oup = 1/(6*7);
        4: rom_oup = 1/(8*9);
        5: rom_oup = 1/(10*11);
        6: rom_oup = 1/(12*13);
        7: rom_oup = 1/(14*15);
      endcase
    end
  end
  
  always@(posedge rst,sel_reg,sel_rom)begin//mux1
    if(rst) mux_oup = 16'b 0;
    else if(sel_reg) mux_oup = x2_reg;
    else if(sel_rom) mux_oup = rom_oup;
  end
  
  always@(posedge rst,sel_x,sel_mult)begin//mux2
    if(rst) mux_mult_oup = 16'b 0;
    else if(sel_x) mux_mult_oup = x;
    else if(sel_mult) mux_mult_oup = mult_oup;
  end
  
  always@(posedge rst,posedge clk,ldterm)begin//term reg
    if(rst) term_oup <= 16'b 0;
    else if(ldterm) term_oup <= mux_mult_oup;
  end
  
  always@(posedge rst,mux_oup,term_oup)begin //multiplier
    if(rst)mult_oup = 16'b 0;
    else  mult_oup = mux_oup * term_oup;
  end
  
  always@(posedge rst,sel_x,sel_sinx)begin//mux3
    if(rst) mux_sin_oup = 16'b 0;
    else if(sel_x) mux_sin_oup = x;
    else if(sel_sinx) mux_sin_oup = add_oup;
  end
  
  always@(posedge rst,posedge clk,ldsin)begin//sin reg
    if(rst) sin_reg_oup <= 16'b 0;
    else if(ldsin) sin_reg_oup <= mux_sin_oup;
  end
  
  always@(posedge rst,posedge clk)begin//tff
    if(init_tff || rst) tff_oup <= 0;
    else if(tff_inp) tff_oup <= ~tff_oup;
  end
  
  always@(term_oup, sin_reg_oup,posedge rst)begin//add sub
    if(rst) add_oup = 16'b 0;
    else if(tff_inp) add_oup = sin_reg_oup - term_oup;
    else if(tff_oup ==0) add_oup = sin_reg_oup + term_oup;
  end
  
  always@(posedge clk,posedge rst,ldy)begin//y reg
    if(rst) y_oup <= 8'b 0;
    else if(inity) y_oup <= 8'b 0;
    else if(ldy) y_oup <= y;
  end
  
  always@(posedge rst,y_oup,term_oup)begin//comparator
    if(rst) comp = 0;
    if (term_oup  < y_oup ) comp =1;
    else comp = 0;
  end
  
  always@(posedge rst,posedge clk)begin
    if(rst) begin ps <= idle; end     
    else ps <=ns;
  end
  always@(ps,co,ready,start)begin
    ready =0; inc=0;icc=0;init_tff=0;inity=0;sel_x=0;sel_rom=0; 
    case(ps)
      idle:begin
         ns = start?starting:idle;
      end
      
      starting:begin
        if(start == 1)begin
          inc =1;
          init_tff = 1;
          inity = 1;
          sel_x = 1;
          ns = starting;
        end
        else 
         ns = loading;
      end
      
      loading:begin
        ldrom = 1;
        ldx2 = 1;
        ns= mult1;
      end
      
      mult1:begin
        sel_reg = 1;
        sel_mult = 1;
        ldterm = 1;
        icc = 1;
        ns = mult2;
      end
      
      mult2:begin
        sel_rom = 1;
        ldterm = 1;
        ns = add;
      end
        
      add:begin
        sel_sinx = 1;
        ldsin = 1;
        ns =endcheck;
      end
      
      endcheck:begin
        if(comp == 0)begin tff_inp = 1; icc = 1; ns =mult1;end
        else begin ready = 1;ns=idle; end
      end
    endcase
  end
  assign sinx = sin_reg_oup;
endmodule
  
    
  
    
  