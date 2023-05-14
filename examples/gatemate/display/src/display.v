// -------------------------------------------------------
// display.v    gm-study-max demo program  @20230312 fm4dd
//
// Requires: 4x16 or 4x20 character LCD via J1 header
//
// Description:
// ------------
// This program tests writing to a character LCD display
// -------------------------------------------------------
module display(
  input clk,
  input rst, 
  input [3:0] stbtn, 
  output [7:0] sthex4,
  output [7:0] sthex5,
  output st_rs,
  output st_en,
  input  st_rw,
  output reg [9:0] stled,
  output [7:0] st_d
);

reg [7:0] data_reg, data_next;
reg [2:0] state_reg, state_next;
reg [7:0] count_reg, count_next;
reg cd_next, cd_reg;
reg d_start_reg, d_start_next;
wire done_tick;
reg lcd_busy;

wire [7:0] initm[0:3];
assign initm[0] = 8'h38;  // LCD_mode 8-bit
assign initm[1] = 8'h06;  // Entry mode
assign initm[2] = 8'h0E;  // Curson on
assign initm[3] = 8'h01;  // Clear Display
 
wire [7:0] line1 [0:32];
assign line1[0]  = "H";
assign line1[1]  = "E";
assign line1[2]  = "L";
assign line1[3]  = "L";
assign line1[4]  = "O";
assign line1[5]  = " ";
assign line1[6]  = "W";
assign line1[7]  = "O";
assign line1[8]  = "R";
assign line1[9]  = "L";
assign line1[10] = "D";
assign line1[11] = "!";
assign line1[12] = " ";
assign line1[13] = " ";
assign line1[14] = " ";
assign line1[15] = " ";
assign line1[16] = 8'hc0;
assign line1[17] = "G";
assign line1[18] = "a";
assign line1[19] = "t";
assign line1[20] = "e";
assign line1[21] = "M";
assign line1[22] = "a";
assign line1[23] = "t";
assign line1[24] = "e";
assign line1[25] = " ";
assign line1[26] = "-";
assign line1[27] = " ";
assign line1[28] = "A";
assign line1[29] = "1";
assign line1[30] = " ";
assign line1[31] = " ";
assign line1[32] = " ";

localparam [2:0] INIT   = 3'b000, // state machine
		 IDLE 	= 3'b001,
		 SEND	= 3'b010,
		 FIN 	= 3'b011,
		 CLS 	= 3'b100;

// -------------------------------------------------------
// Module debounce: get a clean push-button state signal
// -------------------------------------------------------
reg btn0, btn1;
wire btn0_down, btn1_down;
wire btn0_up, btn1_up;

debounce d0 (stbtn[0], clk, btn0, btn0_down, btn0_up);
debounce d1 (stbtn[1], clk, btn1, btn1_down, btn1_up);

// -------------------------------------------------------
//  Module hexdigit: Creates the LED pattern from 3 args:
// in:  0-15 displays the hex value from 0..F
//      16 = all_on
//      17 = - (show minus sign)
//      18 = _ (show underscore)
//      19 = S
//     >19 = all_off
// dp:  0 or 1, disables/enables the decimal point led
// out: bit pattern result driving the 7seg module leds
// -------------------------------------------------------
wire [4:0] data_4;
wire [4:0] data_5;
hexdigit h4 (data_4, 1'b0, sthex4);
hexdigit h5 (data_5, 1'b0, sthex5);

// -------------------------------------------------------
// Construct hex digit number from the counter or disable
// the hex digit if the corresponding switch # is "off".
// -------------------------------------------------------
assign data_4 = count_reg[3:0];
assign data_5 = count_reg[7:4];

// -------------------------------------------------------
// Module lcd_transmit: sends a single byte to display
// -------------------------------------------------------
lcd_transmit t1(data_reg, clk, rst, d_start_reg, cd_reg, st_d, st_rs, st_en, done_tick);

always @(posedge clk or negedge rst)
begin
  if(!rst)
  begin
    state_reg   <= INIT;
    count_reg   <= 0;
    data_reg    <= 0;
    cd_reg      <= 0;
    d_start_reg <= 0;
    lcd_busy    <= 0;
  end
  else
  begin
    stled[7:6] = 2'b00;    // turn off unused led
    stled[8] = !stbtn[0];  // light up led8 on button PB0 press
    stled[9] = !stbtn[1];  // light up led9 on button PB1 press
    state_reg   <= state_next;
    count_reg   <= count_next;
    data_reg    <= data_next;
    cd_reg      <= cd_next;
    d_start_reg <= d_start_next;
  end
end

always @*
begin
  state_next = state_reg;
  count_next = count_reg;
  cd_next = cd_reg;
  d_start_next = d_start_reg;

  case(state_reg)
    INIT:                            // State INIT: Initialize the LCD
    begin                            // ------------------------------------
      stled[5:0] = 6'b000001;        // light up state led1
      data_next = initm[count_reg];  // Load 1st data set from initm[0]
      d_start_next = 1'b1;           // set d_start_next flag=1
      cd_next = 0;                   // set cd_next = 0 (Command)
      if(done_tick) begin            // transmission of one cmd complete
        d_start_next = 0;            // set d_start_next flag=0
        count_next = count_reg+1'b1; // increment counter
        if(count_reg > 8'd4)         // if counter is at position 4
          state_next = FIN;          // Init completed, ready for data
      end
    end
	 
    IDLE:                            // State IDLE: LCD waiting to send data
    begin                            // ------------------------------------
      count_next = 0;                // reset counter
      d_start_next = 1'b0;           // dont sent anything
      stled[5:0] = 6'b000010;        // Light up board led2 to indicate IDLE
      if(btn0) state_next = SEND;    // if PB0 is pressed update display
      if(btn1) state_next = CLS;     // if PB1 is pressed clear display
    end
	 
	 
    SEND:                            // State SEND: transmit LCD characters
    begin                            // ------------------------------------
      stled[5:0] = 6'b000100;        // Light up board led3 to indicate SEND
      data_next = line1[count_reg];  // Load next data set from line1
      if(data_next == 8'hc0)         // Check if data is a command
        cd_next = 0;                 // set cd_next = 0 (Command)
      else cd_next = 1;              // set cd_next = 1 (Data)
      d_start_next = 1'b1;           // set d_start_next flag=1 to transmit
      if(done_tick) begin            // done_tick is the execution of one cmd
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        count_next = count_reg+1'b1; // increment memory counter
        if(count_reg > 8'd32)        // if counter is at end of line1
          state_next = FIN;          // Data display completed, move to FIN
      end
    end
	 
    FIN:                             // State FIN: Reset markers, return to IDLE
    begin                            // ------------------------------------
      stled[5:0]    = 6'b001000;     // Light up board led4 to indicate FIN
      data_next = 8'h80;             // set "display position line1-pos0" command
      cd_next = 0;                   // set cd_next = 0 (Command)
      d_start_next = 1;              // set d_start_next flag=1
      if(done_tick) begin            // done_tick is the execution of one cmd
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        data_next    <= 0;
        cd_next      <= 0;
        state_next = IDLE;           // return to state "IDLE"
      end
    end

    CLS:                             // State CLS: send display clear CMD
    begin                            // ------------------------------------
      stled[5:0] = 6'b010000;        // Light up board led5 to indicate CLR
      data_next = 8'h01;             // set "display clear" command
      cd_next = 0;                   // set cd_next = 0 (Command)
      d_start_next = 1;              // set d_start_next flag=1
      if(done_tick) begin            // done_tick is the execution of one cmd
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        state_next = IDLE;           // return to state "IDLE"
      end
    end
  endcase
end

endmodule
