# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y9 [get_ports SYS_CLK_I]

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN T21 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN U22 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN U21 [get_ports {LEDS[3]}]
set_property PACKAGE_PIN V22 [get_ports {LEDS[4]}]
set_property PACKAGE_PIN W22 [get_ports {LEDS[5]}]
set_property PACKAGE_PIN U19 [get_ports {LEDS[6]}]
set_property PACKAGE_PIN U14 [get_ports {LEDS[7]}]

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN P16 [get_ports {BUTTONS[0]}]
set_property PACKAGE_PIN R16 [get_ports {BUTTONS[1]}]
set_property PACKAGE_PIN N15 [get_ports {BUTTONS[2]}]
set_property PACKAGE_PIN R18 [get_ports {BUTTONS[3]}]
set_property PACKAGE_PIN T18 [get_ports {BUTTONS[4]}]

# ----------------------------------------------------------------------------
# User DIP Switches - Bank 35
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN F22 [get_ports {SWITCHES[0]}]
set_property PACKAGE_PIN G22 [get_ports {SWITCHES[1]}]
set_property PACKAGE_PIN H22 [get_ports {SWITCHES[2]}]
set_property PACKAGE_PIN F21 [get_ports {SWITCHES[3]}]
set_property PACKAGE_PIN H19 [get_ports {SWITCHES[4]}]
set_property PACKAGE_PIN H18 [get_ports {SWITCHES[5]}]
set_property PACKAGE_PIN H17 [get_ports {SWITCHES[6]}]
set_property PACKAGE_PIN M15 [get_ports {SWITCHES[7]}]

# ----------------------------------------------------------------------------
# TIMING Constraints
# ----------------------------------------------------------------------------
create_clock -period 10.000 -waveform {0.000 5.000} [get_ports SYS_CLK_I]

create_clock -period 11.000 -waveform {0.000 5.500} [get_ports GPMC_CLK_I]

# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];

set_max_delay -from [get_pins {ARM_Interface/GPMC_interface/adr_ms_reg[*]/C}] 5.000
set_max_delay -from [get_pins {ARM_Interface/GPMC_interface/dat_ms_reg[*]/C}] 5.000
