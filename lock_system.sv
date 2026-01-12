`default_nettype none
// Empty top module

typedef enum logic [3:0] {
  LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
  INIT=8, OPEN=9, ALARM=10
} state_t;

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  logic [4:0] keycode;
  logic strobe;
  logic [7:0] seq;
  logic [3:0] state;
  logic strobeNew;

  clock_psc psc (.clk(hz100), .rst(reset), .lim(8'd49), .hzX(strobeNew));
  keysync sk1 (.clk(hz100), .rst(reset), .keyin(pb[19:0]), .keyout(keycode), .keyclk(strobe)); 
  sequence_sr sqr (.clk(strobe), .rst(reset), .en(~|keycode[4:1] && (state == INIT)), .button(keycode[0]), .seq(seq));
  fsm fsm1 (.clk(strobe), .rst(reset), .keyout(keycode), .seq(seq), .state(state));                                                            
  display dis (.hzX(strobeNew), .state(state), .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}), .red(red), .green(green), .blue(blue));
  
  assign right = seq;
endmodule

module clock_psc(input logic clk, rst, input logic [7:0] lim, output logic hzX);

  logic [7:0] count, n_count;
  logic hz, n_hz;

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      count <= 0;
      hzX <= 0;
    end else if (lim == 0) begin
      hzX <= 0;
    end else begin
      if (count == lim) begin
        count <= 0;
        hzX <= ~hzX;
      end else begin
        count <= count + 8'h1;
      end
    end
  end
endmodule

module keysync(
  input logic clk, rst,
  input logic [19:0] keyin,
  output logic keyclk,
  output logic [4:0] keyout                                            
);                                                                     
  always_comb begin
    keyout[0] = (keyin[1] | keyin[3] | keyin[5] | keyin[7] | keyin[9] | keyin[11] | keyin[13] | keyin[15] | keyin[17] | keyin[19]);
    keyout[1] = |(keyin[3:2] | keyin[7:6] | keyin[11:10] | keyin[15:14] | keyin[19:18]);
    keyout[2] = |(keyin[7:4] | keyin[15:12]);
    keyout[3] = |keyin[15:8];
    keyout[4] = |keyin[19:16];
  end
  logic strobe_reg;
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      keyclk <= 1'b0;
      strobe_reg <= 1'b0;
    end else begin
      strobe_reg <= |keyin[19:0];
      keyclk <= strobe_reg;
    end
  end
endmodule

module sequence_sr(
  input logic clk, rst, en, button,
  output logic [7:0] seq
);

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      seq <= 8'b00000000;
    end
    else if (en) begin
      seq <= {seq[6:0], button};
    end
  end
endmodule

module fsm(
  input logic clk, rst,
  input logic [4:0] keyout,
  input logic [7:0] seq,
  output logic [3:0] state
);
  state_t lockstate, n_lockstate;
  
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        // initialize lockstate to INIT
        lockstate <= INIT;
    end else begin
        // update lockstate to n_lockstate
        lockstate <= n_lockstate;
    end                                                                
  end
  logic M, R;

  // M is true if current num in sequence is the same
  assign M = (keyout[0] == seq[~lockstate[2:0]]);

  // R is true if W is pressed, false if not
  assign R = (keyout == 5'b10000);
  
  always_comb begin
    casez({lockstate, M, R})
      {INIT, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS1, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS2, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS3, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS4, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS5, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS6, 1'b?, 1'b1}: n_lockstate = LS0;
      {LS7, 1'b?, 1'b1}: n_lockstate = LS0;
      {OPEN, 1'b?, 1'b1}: n_lockstate = LS0;
      
      {LS0, 1'b1, 1'b0}: n_lockstate = LS1;
      {LS1, 1'b1, 1'b0}: n_lockstate = LS2;
      {LS2, 1'b1, 1'b0}: n_lockstate = LS3;
      {LS3, 1'b1, 1'b0}: n_lockstate = LS4;
      {LS4, 1'b1, 1'b0}: n_lockstate = LS5;
      {LS5, 1'b1, 1'b0}: n_lockstate = LS6;
      {LS6, 1'b1, 1'b0}: n_lockstate = LS7;
      {LS7, 1'b1, 1'b0}: n_lockstate = OPEN;
      
      {LS0, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS1, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS2, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS3, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS4, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS5, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS6, 1'b0, 1'b0}: n_lockstate = ALARM;
      {LS7, 1'b0, 1'b0}: n_lockstate = ALARM;
      default n_lockstate = lockstate;
    endcase
  end
  
  assign state = lockstate;

endmodule


module display(
  input logic hzX,
  input logic [3:0] state,
  output logic [63:0] ss,
  output logic red, green, blue
);
  // "SeCuRE" - 64'b01101101_01111001_00111001_00111110_01010000_01111001; 
  // "OPEN" - 64'b00111111_01110011_01111001_01010100;  
  // "CALL 911" - 64'b00111001_01110111_00111000_00111000_00000000_01100111_00000110_00000110;
  always_comb begin 
    case (state) 
      LS0, LS1, LS2, LS3, LS4, LS5, LS6, LS7: begin     
        ss = 64'b01101101_01111001_00111001_00111110_01010000_01111001 | 64'b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000 >> (8 * state);
        blue = 1'b1;
        red = 1'b0;
        green = 1'b0;
      end
      OPEN: begin
        ss = 64'b00111111_01110011_01111001_01010100;
        green = 1'b1;
        red = 1'b0;
        blue = 1'b0;
      end
      ALARM: begin
        ss = 64'b00111001_01110111_00111000_00111000_00000000_01100111_00000110_00000110;
        red = hzX;
        green = 1'b0;
        blue = 1'b0;
      end
      default: begin
        ss = 64'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        red = 1'b0;
        green = 1'b0;                                                          blue = 1'b0;
      end
    endcase
  end
endmodule
