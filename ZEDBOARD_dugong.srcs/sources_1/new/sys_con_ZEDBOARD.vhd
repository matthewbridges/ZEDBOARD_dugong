--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		SYS_CON 
-- Type:		PRIMITIVE (2)
-- Description: 	
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-2-
--
-- Last Modified:	08-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

entity sys_con is
	port(
		--System Clock Differential Inputs 100MHz
		SYS_CLK_P      : in  STD_LOGIC;
		SYS_CLK_N      : in  STD_LOGIC;
		--System Reset Input
		SYS_RST        : in  STD_LOGIC;
		--System Status
		SYS_PWR_ON     : out STD_LOGIC;
		SYS_PLL_Locked : out STD_LOGIC;
		--System Control Outputs
		CLK_100MHz_P   : out STD_LOGIC;
		CLK_100MHz_N   : out STD_LOGIC;
		RST_O          : out STD_LOGIC;
		--SPI Clock Outputs
		CLK_10MHz_P    : out STD_LOGIC;
		CLK_10MHz_N    : out STD_LOGIC
	);
end entity sys_con;

architecture RTL of sys_con is

	--Input Buffering
	signal sys_clk_b : std_logic;

	--PLL Signals
	signal pll_locked : std_logic;
	signal clkfbout   : std_logic;
	signal clkout0    : std_logic;
	signal clkout1    : std_logic;
	signal clkout2    : std_logic;
	signal clkout3    : std_logic;

	--Internal Clock Buffering
	signal clkfbout_b : std_logic;
	signal clkout0_b  : std_logic;
	signal clkout1_b  : std_logic;
	signal clkout2_b  : std_logic;
	signal clkout3_b  : std_logic;
--signal sys_clk_o_pb : std_logic;

begin
	-- Initial Test Signal
	SYS_PWR_ON <= '1';

	-- Input buffering
	sys_clk_b <= SYS_CLK_P;

	-- System PLL 
	SYS_CLK_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "HIGH",
			CLKFBOUT_MULT         => 10,
			CLKFBOUT_PHASE        => 0.0,
			CLKIN_PERIOD          => 10.000,
			CLKOUT0_DIVIDE        => 10,
			CLKOUT0_DUTY_CYCLE    => 0.50,
			CLKOUT0_PHASE         => 0.0,
			CLKOUT1_DIVIDE        => 10,
			CLKOUT1_DUTY_CYCLE    => 0.50,
			CLKOUT1_PHASE         => 180.0,
			CLKOUT2_DIVIDE        => 100,
			CLKOUT2_DUTY_CYCLE    => 0.50,
			CLKOUT2_PHASE         => 0.0,
			CLKOUT3_DIVIDE        => 100,
			CLKOUT3_DUTY_CYCLE    => 0.50,
			CLKOUT3_PHASE         => 180.0,
			CLKOUT4_DIVIDE        => 1,
			CLKOUT4_DUTY_CYCLE    => 0.50,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_DIVIDE        => 1,
			CLKOUT5_DUTY_CYCLE    => 0.50,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT",
			COMPENSATION          => "SYSTEM_SYNCHRONOUS",
			DIVCLK_DIVIDE         => 1,
			REF_JITTER            => 0.001,
			RESET_ON_LOSS_OF_LOCK => FALSE
		)
		port map(
			CLKFBOUT => clkfbout,
			CLKOUT0  => clkout0,
			CLKOUT1  => clkout1,
			CLKOUT2  => clkout2,
			CLKOUT3  => clkout3,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => pll_locked,
			CLKFBIN  => clkfbout_b,
			CLKIN    => sys_clk_b,
			RST      => SYS_RST
		);

	-- Internal Global Buffers
	clkfbout_buf : BUFG
		port map(
			O => clkfbout_b,
			I => clkfbout
		);

	clkout0_buf : BUFG
		port map(
			O => clkout0_b,
			I => clkout0
		);

	CLK_100MHz_P <= clkout0_b;

	clkout1_buf : BUFG
		port map(
			O => clkout1_b,
			I => clkout1
		);

	CLK_100MHz_N <= clkout1_b;

	clkout2_buf : BUFG
		port map(
			O => clkout2_b,
			I => clkout2
		);

	CLK_10MHz_P <= clkout2_b;

	clkout3_buf : BUFG
		port map(
			O => clkout3_b,
			I => clkout3
		);

	CLK_10MHz_N <= clkout3_b;

	RST_O          <= not (pll_locked);
	SYS_PLL_Locked <= pll_locked;

--	--ODDR for Clock Forwarding
--	SYS_CLK_O_ODDR2 : ODDR2
--		generic map(
--			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
--			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
--			SRTYPE        => "SYNC"
--		)                               -- Specifies "SYNC" or "ASYNC" set/reset
--		port map(
--			Q  => sys_clk_o_pb,         -- 1-bit output data
--			C0 => clkout0_b,            -- 1-bit clock input
--			C1 => clkout1_b,            -- 1-bit clock input
--			CE => pll_locked,           -- 1-bit clock enable input
--			D0 => '1',                  -- 1-bit data input (associated with C0)
--			D1 => '0',                  -- 1-bit data input (associated with C1)
--			R  => '0',                  -- 1-bit reset input
--			S  => '0'                   -- 1-bit set input
--		);
--
--	-- Output buffering
--	SYS_CLK_O_OBUFDS : OBUFDS
--		port map(
--			O  => SYS_CLK_OUT_P,
--			OB => SYS_CLK_OUT_N,
--			I  => sys_clk_o_pb
--		);

end architecture RTL;
