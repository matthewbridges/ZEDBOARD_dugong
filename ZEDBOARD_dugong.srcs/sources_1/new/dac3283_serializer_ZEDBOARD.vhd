library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dac3283_serializer is
	port(
		--System Control Inputs
		RST_I          : in  STD_LOGIC;
		--Signal Channel Inputs
		DAC_CLK_O      : out STD_LOGIC;
		DAC_CLK_DIV4_O : out STD_LOGIC;
		DAC_READY      : out STD_LOGIC;
		CH_C_I         : in  STD_LOGIC_VECTOR(15 downto 0);
		CH_D_I         : in  STD_LOGIC_VECTOR(15 downto 0);
		-- DAC interface
		FMC150_CLK     : in  STD_LOGIC;
		DAC_DCLK_P     : out STD_LOGIC;
		DAC_DCLK_N     : out STD_LOGIC;
		DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P        : out STD_LOGIC;
		FRAME_N        : out STD_LOGIC;
		-- Testing
		IO_TEST_EN     : in  STD_LOGIC
	);
end entity dac3283_serializer;

architecture RTL of dac3283_serializer is
	signal fmc150_clk_b : std_logic;

	--Phase Locked Loop
	signal dac_clk_X2   : std_logic;
	signal dac_clk_X1   : std_logic;
	signal dac_clk_DIV4 : std_logic;
	signal clk_fb_out   : std_logic;
	signal pll_locked   : std_logic;
	--Buffer Signals
	signal dac_clk_X1_b : std_logic;
	signal dac_clk_X2_b : std_logic;

	signal reset        : std_logic;
	signal tx_en        : std_logic;
	signal sample_count : unsigned(2 downto 0);
	signal frame_count  : unsigned(7 downto 0);

	signal i : std_logic_vector(15 downto 0);
	signal q : std_logic_vector(15 downto 0);

	signal frame : std_logic;

	signal dac_dclk_o : std_logic;
	signal dac_dat_o  : std_logic_vector(7 downto 0);
	signal frame_o    : std_logic;

	type test_signal_type is array (0 to 7) of std_logic_vector(15 downto 0);
	constant test_pat_i : test_signal_type := (x"7AB6", X"1A16", x"7AB6", X"1A16", x"7AB6", X"1A16", x"7AB6", X"1A16");
	constant test_pat_q : test_signal_type := (x"EA45", X"AAC6", x"EA45", X"AAC6", x"EA45", X"AAC6", x"EA45", X"AAC6");
--constant test_pat_i : test_signal_type := (x"AEAF", x"AEAF", x"AEAF", x"AEAF", x"AEAF", x"AEAF", x"AEAF", x"AEAF");
--constant test_pat_q : test_signal_type := (x"AEAF", x"AEBF", x"AEAF", x"AEBF", x"AEAF", x"AEBF", x"AEAF", x"AEBF");

--constant test_pat_i : test_signal_type := (x"0000", x"5A82", x"7FFF", x"5A82", x"0000", x"A57D", x"8000", x"A57D");
--constant test_pat_q : test_signal_type := (x"7FFF", x"5A82", x"0000", x"A57D", x"8000", X"A57D", x"0000", x"5A82");

	signal io_test_en_SR : std_logic_vector(2 downto 0) := (others => '0');

	attribute ASYNC_REG : string;
	attribute shreg_extract : string;

	attribute ASYNC_REG of io_test_en_SR : signal is "true";
	attribute shreg_extract of io_test_en_SR : signal is "no";

begin
	IO_TEST_EN_CROSS_CLK_proc : process(dac_clk_X1_b) is
	begin
		if rising_edge(dac_clk_X1_b) then
			io_test_en_SR(0)          <= IO_TEST_EN;
			io_test_en_SR(2 downto 1) <= io_test_en_SR(1 downto 0);
		end if;
	end process IO_TEST_EN_CROSS_CLK_proc;

	----------------------------Input Interface----------------------------

	reset <= RST_I or not (pll_locked);

	process(dac_clk_X1_b)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(dac_clk_X1_b)) then
			if (reset = '1') then
				DAC_READY    <= '0';
				i            <= (others => '0');
				q            <= (others => '0');
				frame        <= '0';
				sample_count <= (others => '0');
				frame_count  <= (others => '1');
				tx_en        <= '0';
			else
				DAC_READY <= '1';
				if (io_test_en_SR(2) = '1') then
					i <= test_pat_i(to_integer(sample_count)); --CH_A_I;
					q <= test_pat_q(to_integer(sample_count)); --CH_B_I;
				else
					i <= CH_D_I;
					q <= CH_C_I;
				end if;

				if (sample_count = 0) then
					tx_en       <= '1';
					frame_count <= frame_count + 1;
					frame       <= '1';
				else
					frame <= '0';
				end if;
				sample_count <= sample_count + 1;
			end if;
		end if;
	end process;

	----------------------------SET UP CLOCKING AND PLLs----------------------------

	FMC150_CLK_BUFG : BUFG
		port map(
			O => fmc150_clk_b,
			I => FMC150_CLK
		);

	dac_clk_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 4, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 4.069, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 2,
			CLKOUT1_DIVIDE        => 4,
			CLKOUT2_DIVIDE        => 16,
			CLKOUT3_DIVIDE        => 1,
			CLKOUT4_DIVIDE        => 1,
			CLKOUT5_DIVIDE        => 1,
			-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
			CLKOUT0_DUTY_CYCLE    => 0.5,
			CLKOUT1_DUTY_CYCLE    => 0.5,
			CLKOUT2_DUTY_CYCLE    => 0.5,
			CLKOUT3_DUTY_CYCLE    => 0.5,
			CLKOUT4_DUTY_CYCLE    => 0.5,
			CLKOUT5_DUTY_CYCLE    => 0.5,
			-- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
			CLKOUT0_PHASE         => 0.0,
			CLKOUT1_PHASE         => 0.0,
			CLKOUT2_PHASE         => 0.0,
			CLKOUT3_PHASE         => 0.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.1, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clk_fb_out,     -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => dac_clk_X2,
			CLKOUT1  => dac_clk_X1,
			CLKOUT2  => dac_clk_DIV4,
			CLKOUT3  => open,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => pll_locked,     -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clk_fb_out,     -- 1-bit input: Feedback clock input
			CLKIN    => fmc150_clk_b,   -- 1-bit input: Clock input
			RST      => RST_I           -- 1-bit input: Reset input
		);

	dac_clk_X1_BUFG : BUFG
		port map(
			O => dac_clk_X1_b,
			I => dac_clk_X1
		);

	dac_clk_X2_BUFIO : BUFIO
		port map(
			O => dac_clk_X2_b,
			I => dac_clk_X2
		);

	dac_clk_DIV4_BUFG : BUFG
		port map(
			O => DAC_CLK_DIV4_O,
			I => dac_clk_DIV4
		);

	----------------------------DATA_CLOCK IO AND BUFFERING----------------------------

	DAC_DCLK_OSERDES2 : OSERDESE2
		generic map(
			DATA_RATE_OQ   => "DDR",    -- DDR, SDR
			DATA_RATE_TQ   => "DDR",    -- DDR, BUF, SDR
			DATA_WIDTH     => 4,        -- Parallel data width (2-8,10,14)
			INIT_OQ        => '0',      -- Initial value of OQ output (1'b0,1'b1)
			INIT_TQ        => '0',      -- Initial value of TQ output (1'b0,1'b1)
			SERDES_MODE    => "MASTER", -- MASTER, SLAVE
			SRVAL_OQ       => '0',      -- OQ output value when SR is used (1'b0,1'b1)
			SRVAL_TQ       => '0',      -- TQ output value when SR is used (1'b0,1'b1)
			TBYTE_CTL      => "FALSE",  -- Enable tristate byte operation (FALSE, TRUE)
			TBYTE_SRC      => "FALSE",  -- Tristate byte source (FALSE, TRUE)
			TRISTATE_WIDTH => 4         -- 3-state converter width (1,4)
		)
		port map(
			OFB       => open,          -- 1-bit output: Feedback path for data
			OQ        => dac_dclk_o,    -- 1-bit output: Data path output
			-- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
			SHIFTOUT1 => open,
			SHIFTOUT2 => open,
			TBYTEOUT  => open,          -- 1-bit output: Byte group tristate
			TFB       => open,          -- 1-bit output: 3-state control
			TQ        => open,          -- 1-bit output: 3-state control
			CLK       => dac_clk_X2_b,  -- 1-bit input: High speed clock
			CLKDIV    => dac_clk_X1_b,  -- 1-bit input: Divided clock
			-- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
			D1        => '1',
			D2        => '0',
			D3        => '1',
			D4        => '0',
			D5        => '0',
			D6        => '0',
			D7        => '0',
			D8        => '0',
			OCE       => tx_en,         -- 1-bit input: Output data clock enable
			RST       => '0',           -- 1-bit input: Reset
			-- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
			SHIFTIN1  => '1',
			SHIFTIN2  => '1',
			-- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
			T1        => '0',
			T2        => '0',
			T3        => '0',
			T4        => '0',
			TBYTEIN   => '0',           -- 1-bit input: Byte group tristate
			TCE       => '0'            -- 1-bit input: 3-state clock enable
		);

	DAC_DCLK_OBUFDS : OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O  => DAC_DCLK_P,
			OB => DAC_DCLK_N,
			I  => dac_dclk_o
		);

	----------------------------DATA(7:0) IO AND BUFFERING----------------------------

	DAC_DATA_pins : for pin_count in 7 downto 0 generate
	begin
		DAC_DCLK_OSERDES2 : OSERDESE2
			generic map(
				DATA_RATE_OQ   => "DDR", -- DDR, SDR
				DATA_RATE_TQ   => "DDR", -- DDR, BUF, SDR
				DATA_WIDTH     => 4,    -- Parallel data width (2-8,10,14)
				INIT_OQ        => '0',  -- Initial value of OQ output (1'b0,1'b1)
				INIT_TQ        => '0',  -- Initial value of TQ output (1'b0,1'b1)
				SERDES_MODE    => "MASTER", -- MASTER, SLAVE
				SRVAL_OQ       => '0',  -- OQ output value when SR is used (1'b0,1'b1)
				SRVAL_TQ       => '0',  -- TQ output value when SR is used (1'b0,1'b1)
				TBYTE_CTL      => "FALSE", -- Enable tristate byte operation (FALSE, TRUE)
				TBYTE_SRC      => "FALSE", -- Tristate byte source (FALSE, TRUE)
				TRISTATE_WIDTH => 4     -- 3-state converter width (1,4)
			)
			port map(
				OFB       => open,      -- 1-bit output: Feedback path for data
				OQ        => dac_dat_o(pin_count), -- 1-bit output: Data path output
				-- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
				SHIFTOUT1 => open,
				SHIFTOUT2 => open,
				TBYTEOUT  => open,      -- 1-bit output: Byte group tristate
				TFB       => open,      -- 1-bit output: 3-state control
				TQ        => open,      -- 1-bit output: 3-state control
				CLK       => dac_clk_X2_b, -- 1-bit input: High speed clock
				CLKDIV    => dac_clk_X1_b, -- 1-bit input: Divided clock
				-- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
				D1        => i(pin_count + 8),
				D2        => i(pin_count),
				D3        => q(pin_count + 8),
				D4        => q(pin_count),
				D5        => '0',
				D6        => '0',
				D7        => '0',
				D8        => '0',
				OCE       => tx_en,     -- 1-bit input: Output data clock enable
				RST       => '0',       -- 1-bit input: Reset
				-- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
				SHIFTIN1  => '1',
				SHIFTIN2  => '1',
				-- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
				T1        => '0',
				T2        => '0',
				T3        => '0',
				T4        => '0',
				TBYTEIN   => '0',       -- 1-bit input: Byte group tristate
				TCE       => '0'        -- 1-bit input: 3-state clock enable
			);
		DAC_DATA_OBUFDS : OBUFDS
			generic map(
				IOSTANDARD => "LVDS_25"
			)
			port map(
				O  => DAC_DATA_P(pin_count),
				OB => DAC_DATA_N(pin_count),
				I  => dac_dat_o(pin_count)
			);

	end generate DAC_DATA_pins;

	----------------------------FRAME IO AND BUFFERING----------------------------

	FRAME_OSERDES2 : OSERDESE2
		generic map(
			DATA_RATE_OQ   => "DDR",    -- DDR, SDR
			DATA_RATE_TQ   => "DDR",    -- DDR, BUF, SDR
			DATA_WIDTH     => 4,        -- Parallel data width (2-8,10,14)
			INIT_OQ        => '0',      -- Initial value of OQ output (1'b0,1'b1)
			INIT_TQ        => '0',      -- Initial value of TQ output (1'b0,1'b1)
			SERDES_MODE    => "MASTER", -- MASTER, SLAVE
			SRVAL_OQ       => '0',      -- OQ output value when SR is used (1'b0,1'b1)
			SRVAL_TQ       => '0',      -- TQ output value when SR is used (1'b0,1'b1)
			TBYTE_CTL      => "FALSE",  -- Enable tristate byte operation (FALSE, TRUE)
			TBYTE_SRC      => "FALSE",  -- Tristate byte source (FALSE, TRUE)
			TRISTATE_WIDTH => 4         -- 3-state converter width (1,4)
		)
		port map(
			OFB       => open,          -- 1-bit output: Feedback path for data
			OQ        => frame_o,       -- 1-bit output: Data path output
			-- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
			SHIFTOUT1 => open,
			SHIFTOUT2 => open,
			TBYTEOUT  => open,          -- 1-bit output: Byte group tristate
			TFB       => open,          -- 1-bit output: 3-state control
			TQ        => open,          -- 1-bit output: 3-state control
			CLK       => dac_clk_X2_b,  -- 1-bit input: High speed clock
			CLKDIV    => dac_clk_X1_b,  -- 1-bit input: Divided clock
			-- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
			D1        => frame,
			D2        => frame,
			D3        => frame,
			D4        => frame,
			D5        => '0',
			D6        => '0',
			D7        => '0',
			D8        => '0',
			OCE       => tx_en,         -- 1-bit input: Output data clock enable
			RST       => '0',           -- 1-bit input: Reset
			-- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
			SHIFTIN1  => '1',
			SHIFTIN2  => '1',
			-- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
			T1        => '0',
			T2        => '0',
			T3        => '0',
			T4        => '0',
			TBYTEIN   => '0',           -- 1-bit input: Byte group tristate
			TCE       => '0'            -- 1-bit input: 3-state clock enable
		);

	FRAME_OBUFDS : OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O  => FRAME_P,
			OB => FRAME_N,
			I  => frame_o
		);

	----------------------------OTHER SIGNAL ASSIGNMENT AND DEBUGING----------------------------


	DAC_CLK_O <= dac_clk_X1_b;

end architecture RTL;
