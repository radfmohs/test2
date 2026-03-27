#OTP works with 3V, so level shifters added manually with OTP inside a wrapper. 
  #Same lib and same connection naming, different layout due to level shifters
  set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XA* -setup
  set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XCE -setup
  #set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XREAD -setup
  #set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XPGM -setup
  #set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XTM -setup
  set_path_margin 4.25 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XDIN* -setup
  
  set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XA* -setup
  set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XCE -setup
  #set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XREAD -setup
  #set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XPGM -setup
  #set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XTM -setup
  set_path_margin 3.77 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/XDIN* -setup
  
  #set_path_margin 0.25 -rise_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/DQ* -setup
  #set_path_margin 0.8 -fall_to u_top_dig/u_otp_ctrl_top/u_512x8_otp/DQ* -setup
