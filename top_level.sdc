create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
create_clock -name VERT_SYNC -period 16666.667 [get_ports {VGA_VS}]
create_clock -name MOUSE_CLK -period 100000.000 [get_ports {PS2_CLK}]

derive_pll_clocks
derive_clock_uncertainty
