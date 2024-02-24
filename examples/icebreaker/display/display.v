// -------------------------------------------------------
// display.v Gatemate character LCD demo   @20240218 fm4dd
//
// Requires: pmod-charlcd connected to PMOD A/B
//
// Description:
// ------------
// This program tests writing to a character LCD display
// -------------------------------------------------------
module display(
  input clk,
  input rst, 
  output lcd_rs,
  output lcd_en,
  input  lcd_rw,
  output [7:0] lcd_d,
  output [7:0] led
);

// -------------------------------------------------------
// First define a pushbutton handling for display control:
// The 'rst' button (SW3) cylces between 2 states that are
// used to switch between displaying text, and sending CLS
// The pushbutton state is displayed on E1 LEDs D6 and D7.
// -------------------------------------------------------
parameter BTNSTATE1 = 2'b01,
          BTNSTATE2 = 2'b10;

reg [1:0] btnstate;
reg [1:0] btnnext;

initial btnstate = BTNSTATE1;
initial btnnext = BTNSTATE1;

assign led[7:6] = btnstate; // show button state on D7/D8

// -------------------------------------------------------
// Module debounce gets a clean push-button state signal
// -------------------------------------------------------
reg btn0;
wire btn0_down;
wire btn0_up;

debounce d0 (rst, clk, btn0, btn0_down, btn0_up);

always@(posedge clk)
begin
   btnstate <= btnnext;
   if(btn0_down) btnnext=~btnstate;
end

// -------------------------------------------------------
// End of the rst/SW3 button handling. Start LCD control:
// -------------------------------------------------------

reg [7:0] data_reg, data_next;
reg [2:0] state_reg, state_next;
reg [7:0] count_reg, count_next;
reg cd_next, cd_reg;
reg d_start_reg, d_start_next;
wire done_tick;
reg lcd_busy;

localparam [2:0] INIT   = 3'b000, // state machine
		 IDLE 	= 3'b001,
		 SEND	= 3'b010,
		 FIN 	= 3'b011,
		 CLS 	= 3'b100;

initial state_reg = INIT;

reg [0:4*8-1] initm;
initial initm = { 8'h38,  // LCD_mode 8-bit
                  8'h06,  // Entry mode
                  8'h0E,  // Curson on
                  8'h01 };  // Clear Display
 
// -------------------------------------------------------
// Set LCD display ASCII data for line 1 and 2 (33 chars)
// -------------------------------------------------------
reg [0:33*8-1] line1;
initial line1 = { "HELLO WORLD FPGA", 8'hc0,
                         "IceBreakerLCD OK" };

// -------------------------------------------------------
// Module lcd_transmit: sends a single byte to display
// -------------------------------------------------------
lcd_transmit t1(data_reg, clk, rst, d_start_reg, cd_reg, lcd_d, lcd_rs, lcd_en, done_tick);

always @(posedge clk)
begin
    state_reg   <= state_next;
    count_reg   <= count_next;
    data_reg    <= data_next;
    cd_reg      <= cd_next;
    d_start_reg <= d_start_next;
end

always @(*)
begin
  state_next = state_reg;
  count_next = count_reg;
  cd_next = cd_reg;
  d_start_next = d_start_reg;

  case(state_reg)
    INIT:                            // State INIT: Initialize the LCD
    begin                            // ------------------------------------
      led[5:0] = 6'b000001;       // light up state led1
      data_next <= initm[count_reg*8+7:count_reg*8];  // Load initm data
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
      led[5:0] = 6'b000010;       // Light up board led2 to indicate IDLE
      if(btnstate == BTNSTATE1)
         state_next = CLS;           // if PB1 is pressed clear display
      if(btnstate == BTNSTATE2)
         state_next = SEND;          // if PB0 is pressed send text to display
    end
	 
	 
    SEND:                            // State SEND: transmit LCD characters
    begin                            // ------------------------------------
      led[5:0] = 6'b000100;       // Light up board led3 to indicate SEND
      data_next = line1[count_reg*8+7:count_reg*8];  // Load next data set from line1
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
      led[5:0]    = 6'b001000;    // Light up board led4 to indicate FIN
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
      led[5:0] = 6'b010000;       // Light up board led5 to indicate CLR
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
