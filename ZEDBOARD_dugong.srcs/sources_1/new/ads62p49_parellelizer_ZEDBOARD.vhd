library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library unisim;
use unisim.vcomponents.all;

entity ads62p49_parallelizer is
	port(
		--System Control Inputs
		RST_I        : in  STD_LOGIC;
		--Signal Channel Inputs
		ADC_CLK_O    : out STD_LOGIC;
		CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
		CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
		-- FMC150 ADC interface
		ADC_DCLK_P   : in  STD_LOGIC;
		ADC_DCLK_N   : in  STD_LOGIC;
		ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
	);
end entity ads62p49_parallelizer;

architecture RTL of ads62p49_parallelizer is
	signal adc_dclk   : std_logic;
	signal ioclk      : std_logic;
	signal adc_dclk_b : std_logic;

	signal adc_data_a_b : STD_LOGIC_VECTOR(6 downto 0);
	signal adc_data_b_b : STD_LOGIC_VECTOR(6 downto 0);

	signal i : std_logic_vector(13 downto 0);
	signal q : std_logic_vector(13 downto 0);

begin

	----------------------------SET UP CLOCKING AND PLLs----------------------------

	ADC_DCLK_IBUFDS : IBUFDS
		generic map(
			IOSTANDARD => "LVDS_25",
			DIFF_TERM  => TRUE
		)
		port map(
			O  => adc_dclk,
			I  => ADC_DCLK_P,
			IB => ADC_DCLK_N
		);

	ADC_CLK_BUFR : BUFR
		port map(
			O   => adc_dclk_b,
			CE  => '1',
			CLR => '0',
			I   => adc_dclk
		);

	----------------------------DATA(6:0) IO AND BUFFERING----------------------------

	ADC_DATA_pins : for pin_count in 6 downto 0 generate
		ADC_DATA_A_IBUFDS : IBUFDS
			generic map(
				IOSTANDARD => "LVDS_25",
				DIFF_TERM  => TRUE
			)
			port map(
				O  => adc_data_a_b(pin_count),
				I  => ADC_DATA_A_P(pin_count),
				IB => ADC_DATA_A_N(pin_count)
			);

		ADC_DATA_B_IBUFDS : IBUFDS
			generic map(
				IOSTANDARD => "LVDS_25",
				DIFF_TERM  => TRUE
			)
			port map(
				O  => adc_data_b_b(pin_count),
				I  => ADC_DATA_B_P(pin_count),
				IB => ADC_DATA_B_N(pin_count)
			);

		ADC_DATA_A_IDDR : IDDR
			generic map(
				DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
				-- or "SAME_EDGE_PIPELINED" 
				INIT_Q1      => '0',    -- Initial value of Q1: '0' or '1'
				INIT_Q2      => '0',    -- Initial value of Q2: '0' or '1'
				SRTYPE       => "SYNC"  -- Set/Reset type: "SYNC" or "ASYNC" 
			)
			port map(
				Q1 => i(2 * pin_count + 1), -- 1-bit output for positive edge of clock 
				Q2 => i(2 * pin_count), -- 1-bit output for negative edge of clock
				C  => adc_dclk_b,       -- 1-bit clock input
				CE => '1',              -- 1-bit clock enable input
				D  => adc_data_a_b(pin_count), -- 1-bit DDR data input
				R  => RST_I,            -- 1-bit reset
				S  => '0'               -- 1-bit set
			);

		ADC_DATA_B_IDDR : IDDR
			generic map(
				DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
				-- or "SAME_EDGE_PIPELINED" 
				INIT_Q1      => '0',    -- Initial value of Q1: '0' or '1'
				INIT_Q2      => '0',    -- Initial value of Q2: '0' or '1'
				SRTYPE       => "SYNC"  -- Set/Reset type: "SYNC" or "ASYNC" 
			)
			port map(
				Q1 => q(2 * pin_count + 1), -- 1-bit output for positive edge of clock 
				Q2 => q(2 * pin_count), -- 1-bit output for negative edge of clock
				C  => adc_dclk_b,       -- 1-bit clock input
				CE => '1',              -- 1-bit clock enable input
				D  => adc_data_b_b(pin_count), -- 1-bit DDR data input
				R  => RST_I,            -- 1-bit reset
				S  => '0'               -- 1-bit set
			);
	end generate ADC_DATA_pins;

	----------------------------Output Pipelining----------------------------

	process(adc_dclk_b)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(adc_dclk_b)) then
			CH_A_O <= i;
			CH_B_O <= q;
		end if;
	end process;

	ADC_CLK_O <= adc_dclk_b;

end architecture RTL;
