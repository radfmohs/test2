//--------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_nirs_ppg.sv
// Description  : Assertion to check NIRS_PPG timing daigram 
// Designer     : Supriya
// Date         : 11-03-2026
// Revision     : 0.1
//--------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

//add checkers nirs_ppg
//1) T_RESET_STABLE should be grater than zero (>0) else throw error
//"2) // After D2A_NIRS_RESET_SW deasserts(===1), 
//    2.a) RESET_SW signals must be stable for N cycles cycles
//    2.b)  During which LED/IPD remain quiet and INN_SW HIGH *N time or INN_SW HIGH  when RESET_SW rising edge occured"
//3) LED_ON can only be turon td0(receiver stable) Plus RESET_SW gets stable(this timing is missing in timing diagram of ENS2_NIRS_PPG_controller dic provided by truong)
//4) LED ON stability ==> LED ON time == N cycles
//5) During IPD_SW activity(rise or fall) check LED_ON rising and falling edge
//6) does it needs to be checked LED MIN TIME and MAX TIME
//7) When LED_ON==1, toggle IPD_SW and IIN_SW(falling edge) and rising edge toggle is not allowed when LED_ON is HIGH
//8) Coarse fine chnaged only when LED is off
//9) Minimum gap between iref coarse and iref fine
//10) IREF coarse chnage and hold for sometime (ON TIME)
//11) IREF FINE change and hold for some time(ON TIME)
