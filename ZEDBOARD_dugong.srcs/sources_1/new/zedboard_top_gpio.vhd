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
-- Name:		RHINO TOP GPIO (002)
-- Type:		Top Level Module (F)
-- Description:		This is a top level module joining all cores and controllers to ports and 
--			top level signals. The addressing of cores is also done in this module.
--			This top level module has 1 master, the ARM, on-board GPIOs16 and on-board LEDs8
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-F-002
--
-- Last Modified:	08-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_MASTER_Lib;
use DUGONG_MASTER_Lib.dcomponents.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity zedboard_top_gpio is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 1;
		NUMBER_OF_SLAVES  : NATURAL := 4
	);
	port(
		--System Control Inputs
		SYS_CLK_I         : in    STD_LOGIC;
		--SYS_RST           : in    STD_LOGIC;
		--System Control Outputs
		--SYS_PWR_ON        : out   STD_LOGIC;
		--SYS_PLL_Locked    : out   STD_LOGIC;
		--ZYNQ PS signals
		DDR_addr          : inout STD_LOGIC_VECTOR(14 downto 0);
		DDR_ba            : inout STD_LOGIC_VECTOR(2 downto 0);
		DDR_cas_n         : inout STD_LOGIC;
		DDR_ck_n          : inout STD_LOGIC;
		DDR_ck_p          : inout STD_LOGIC;
		DDR_cke           : inout STD_LOGIC;
		DDR_cs_n          : inout STD_LOGIC;
		DDR_dm            : inout STD_LOGIC_VECTOR(3 downto 0);
		DDR_dq            : inout STD_LOGIC_VECTOR(31 downto 0);
		DDR_dqs_n         : inout STD_LOGIC_VECTOR(3 downto 0);
		DDR_dqs_p         : inout STD_LOGIC_VECTOR(3 downto 0);
		DDR_odt           : inout STD_LOGIC;
		DDR_ras_n         : inout STD_LOGIC;
		DDR_reset_n       : inout STD_LOGIC;
		DDR_we_n          : inout STD_LOGIC;
		FIXED_IO_ddr_vrn  : inout STD_LOGIC;
		FIXED_IO_ddr_vrp  : inout STD_LOGIC;
		FIXED_IO_mio      : inout STD_LOGIC_VECTOR(53 downto 0);
		FIXED_IO_ps_clk   : inout STD_LOGIC;
		FIXED_IO_ps_porb  : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC;
		--USER LEDS
		LEDS              : inout STD_LOGIC_VECTOR(7 downto 0);
		-- USER switches
		SWITCHES          : inout STD_LOGIC_VECTOR(7 downto 0);
		-- USER pushbuttons
		BUTTONS           : inout STD_LOGIC_VECTOR(4 downto 0)
	);
end entity zedboard_top_gpio;

architecture RTL of zedboard_top_gpio is
	component SoC is
		port(
			DDR_cas_n         : inout STD_LOGIC;
			DDR_cke           : inout STD_LOGIC;
			DDR_ck_n          : inout STD_LOGIC;
			DDR_ck_p          : inout STD_LOGIC;
			DDR_cs_n          : inout STD_LOGIC;
			DDR_reset_n       : inout STD_LOGIC;
			DDR_odt           : inout STD_LOGIC;
			DDR_ras_n         : inout STD_LOGIC;
			DDR_we_n          : inout STD_LOGIC;
			DDR_ba            : inout STD_LOGIC_VECTOR(2 downto 0);
			DDR_addr          : inout STD_LOGIC_VECTOR(14 downto 0);
			DDR_dm            : inout STD_LOGIC_VECTOR(3 downto 0);
			DDR_dq            : inout STD_LOGIC_VECTOR(31 downto 0);
			DDR_dqs_n         : inout STD_LOGIC_VECTOR(3 downto 0);
			DDR_dqs_p         : inout STD_LOGIC_VECTOR(3 downto 0);
			FIXED_IO_mio      : inout STD_LOGIC_VECTOR(53 downto 0);
			FIXED_IO_ddr_vrn  : inout STD_LOGIC;
			FIXED_IO_ddr_vrp  : inout STD_LOGIC;
			FIXED_IO_ps_srstb : inout STD_LOGIC;
			FIXED_IO_ps_clk   : inout STD_LOGIC;
			FIXED_IO_ps_porb  : inout STD_LOGIC;
			M_AXI_awaddr      : out   STD_LOGIC_VECTOR(31 downto 0);
			M_AXI_awprot      : out   STD_LOGIC_VECTOR(2 downto 0);
			M_AXI_awvalid     : out   STD_LOGIC;
			M_AXI_awready     : in    STD_LOGIC;
			M_AXI_wdata       : out   STD_LOGIC_VECTOR(31 downto 0);
			M_AXI_wstrb       : out   STD_LOGIC_VECTOR(3 downto 0);
			M_AXI_wvalid      : out   STD_LOGIC;
			M_AXI_wready      : in    STD_LOGIC;
			M_AXI_bresp       : in    STD_LOGIC_VECTOR(1 downto 0);
			M_AXI_bvalid      : in    STD_LOGIC;
			M_AXI_bready      : out   STD_LOGIC;
			M_AXI_araddr      : out   STD_LOGIC_VECTOR(31 downto 0);
			M_AXI_arprot      : out   STD_LOGIC_VECTOR(2 downto 0);
			M_AXI_arvalid     : out   STD_LOGIC;
			M_AXI_arready     : in    STD_LOGIC;
			M_AXI_rdata       : in    STD_LOGIC_VECTOR(31 downto 0);
			M_AXI_rresp       : in    STD_LOGIC_VECTOR(1 downto 0);
			M_AXI_rvalid      : in    STD_LOGIC;
			M_AXI_rready      : out   STD_LOGIC;
			clk_100MHz        : in    STD_LOGIC;
			clk_100MHz_rst    : in    STD_LOGIC
		);
	end component SoC;

	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;

	signal M_AXI_awaddr  : std_logic_vector(31 downto 0);
	signal M_AXI_awprot  : std_logic_vector(2 downto 0);
	signal M_AXI_awvalid : std_logic;
	signal M_AXI_awready : std_logic;
	signal M_AXI_wdata   : std_logic_vector(31 downto 0);
	signal M_AXI_wstrb   : std_logic_vector(3 downto 0);
	signal M_AXI_wvalid  : std_logic;
	signal M_AXI_wready  : std_logic;
	signal M_AXI_bresp   : std_logic_vector(1 downto 0);
	signal M_AXI_bvalid  : std_logic;
	signal M_AXI_bready  : std_logic;
	signal M_AXI_araddr  : std_logic_vector(31 downto 0);
	signal M_AXI_arprot  : std_logic_vector(2 downto 0);
	signal M_AXI_arvalid : std_logic;
	signal M_AXI_arready : std_logic;
	signal M_AXI_rdata   : std_logic_vector(31 downto 0);
	signal M_AXI_rresp   : std_logic_vector(1 downto 0);
	signal M_AXI_rvalid  : std_logic;
	signal M_AXI_rready  : std_logic;

	signal nlock_adr : std_logic;

	--Wishbone Master Lines
	signal adr_o : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal dat_i : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal dat_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal we_o  : std_logic;
	signal stb_o : std_logic;
	signal ack_i : std_logic;
	signal cyc_o : std_logic;
	signal err_i : std_logic;

	---------------------------
	-- Bussing Interconnects --
	---------------------------
	signal wb_ms_bus : WB_MS_type;
	signal wb_ms     : WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
	signal wb_sm_bus : WB_SM_type;
	signal wb_sm     : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
	signal wb_gnt    : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);

	signal debug_arm : DWORD_vector(3 downto 0);

begin
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------

	System_Controller : sys_con
		port map(
			SYS_CLK_P      => SYS_CLK_I,
			SYS_CLK_N      => '0',
			SYS_RST        => '0',      --SYS_RST,
			SYS_PWR_ON     => open,     --SYS_PWR_ON,
			SYS_PLL_Locked => open,     --SYS_PLL_Locked,
			CLK_100MHz_P   => sys_con_clk,
			CLK_100MHz_N   => sys_con_clk_n,
			RST_O          => sys_con_rst,
			CLK_10MHz_P    => open,
			CLK_10MHz_N    => open
		);

	----------------------------
	-- ZYNQ PROCESSING SYSTEM --
	----------------------------

	ZYNQ_PS_block : component SoC
		port map(
			DDR_cas_n         => DDR_cas_n,
			DDR_cke           => DDR_cke,
			DDR_ck_n          => DDR_ck_n,
			DDR_ck_p          => DDR_ck_p,
			DDR_cs_n          => DDR_cs_n,
			DDR_reset_n       => DDR_reset_n,
			DDR_odt           => DDR_odt,
			DDR_ras_n         => DDR_ras_n,
			DDR_we_n          => DDR_we_n,
			DDR_ba            => DDR_ba,
			DDR_addr          => DDR_addr,
			DDR_dm            => DDR_dm,
			DDR_dq            => DDR_dq,
			DDR_dqs_n         => DDR_dqs_n,
			DDR_dqs_p         => DDR_dqs_p,
			FIXED_IO_mio      => FIXED_IO_mio,
			FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
			FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
			FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
			FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
			FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
			M_AXI_awaddr      => M_AXI_awaddr,
			M_AXI_awprot      => M_AXI_awprot,
			M_AXI_awvalid     => M_AXI_awvalid,
			M_AXI_awready     => M_AXI_awready,
			M_AXI_wdata       => M_AXI_wdata,
			M_AXI_wstrb       => M_AXI_wstrb,
			M_AXI_wvalid      => M_AXI_wvalid,
			M_AXI_wready      => M_AXI_wready,
			M_AXI_bresp       => M_AXI_bresp,
			M_AXI_bvalid      => M_AXI_bvalid,
			M_AXI_bready      => M_AXI_bready,
			M_AXI_araddr      => M_AXI_araddr,
			M_AXI_arprot      => M_AXI_arprot,
			M_AXI_arvalid     => M_AXI_arvalid,
			M_AXI_arready     => M_AXI_arready,
			M_AXI_rdata       => M_AXI_rdata,
			M_AXI_rresp       => M_AXI_rresp,
			M_AXI_rvalid      => M_AXI_rvalid,
			M_AXI_rready      => M_AXI_rready,
			clk_100MHz        => sys_con_clk,
			clk_100MHz_rst    => sys_con_rst
		);

	AXI4_LITE_TO_WB_proc : process(sys_con_clk) is
	begin
		if rising_edge(sys_con_clk) then
			if sys_con_rst = '1' then
				M_AXI_awready <= '0';
				M_AXI_wready  <= '0';
				M_AXI_bresp   <= (others => '0');
				M_AXI_bvalid  <= '0';
				M_AXI_arready <= '0';
				M_AXI_rresp   <= (others => '0');
				M_AXI_rvalid  <= '0';
				nlock_adr     <= '1';
			else
				M_AXI_awready <= M_AXI_awvalid;
				M_AXI_wready  <= M_AXI_wvalid;
				M_AXI_arready <= M_AXI_arvalid;

				if (stb_o = '1') then
					M_AXI_bvalid <= we_o and (ack_i or err_i);
				elsif (M_AXI_bready) = '1' then
					M_AXI_bvalid <= '0';
				end if;

				if (stb_o = '1') then
					M_AXI_rvalid <= (not we_o) and (ack_i or err_i);
				elsif (M_AXI_rready) = '1' then
					M_AXI_rvalid <= '0';
				end if;

				if (ack_i or err_i) = '1' then
					nlock_adr <= '1';
				else
					if (M_AXI_awvalid or M_AXI_arvalid) = '1' then
						nlock_adr <= '0';
					end if;
				end if;
			end if;

			if (nlock_adr = '1') then
				if (M_AXI_awvalid = '1') then
					adr_o <= M_AXI_awaddr(29 downto 2);
				else
					adr_o <= M_AXI_araddr(29 downto 2);
				end if;
			end if;

			if (ack_i = '1') then
				M_AXI_rdata <= dat_i;
			elsif (err_i = '1') then
				M_AXI_rdata <= err_i & we_o & adr_o & "00";
			end if;

			if M_AXI_wvalid = '1' then
				dat_o <= M_AXI_wdata;
			end if;

			if (ack_i or err_i) = '1' then
				we_o  <= '0';
				stb_o <= '0';
				cyc_o <= '0';
			else
				if (M_AXI_wvalid or M_AXI_arvalid) = '1' then
					we_o <= M_AXI_wvalid;
				end if;

				if (M_AXI_wvalid = '1') then
					stb_o <= we_o;
					cyc_o <= we_o;
				elsif (M_AXI_arvalid = '1') then
					stb_o <= '1';
					cyc_o <= '1';
				end if;
			end if;
		end if;
	end process AXI4_LITE_TO_WB_proc;

	wb_m_inst : component wb_m
		port map(
			CLK_I     => sys_con_clk,
			RST_I     => sys_con_rst,
			WB_MS     => wb_ms(0),
			WB_SM     => wb_sm_bus,
			GNT_I     => wb_gnt(0),
			ADR_O     => adr_o,
			DAT_I     => dat_i,
			DAT_O     => dat_o,
			WE_O      => we_o,
			STB_O     => stb_o,
			ACK_I     => ack_i,
			CYC_O     => cyc_o,
			ERR_I     => err_i,
			T_COUNT_O => debug_arm(2),
			E_COUNT_O => debug_arm(3)
		);

	---------------------------
	-- Bussing Interconnects --
	---------------------------

	WB_Intercon : wb_arbiter_intercon
		generic map(
			NUMBER_OF_MASTERS => NUMBER_OF_MASTERS,
			NUMBER_OF_SLAVES  => NUMBER_OF_SLAVES
		)
		port map(
			CLK_I     => sys_con_clk,
			RST_I     => sys_con_rst,
			WB_MS     => wb_ms,
			WB_MS_BUS => wb_ms_bus,
			WB_SM     => wb_sm,
			WB_SM_BUS => wb_sm_bus,
			WB_GNT_O  => wb_gnt
		);

	-----------------------
	-- Wishbone IP CORES --
	-----------------------

	LEDs_8 : gpio_ip
		generic map(
			BASE_ADDR       => x"08000000",
			CORE_DATA_WIDTH => 8
		)
		port map(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(0),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => LEDS
		);

	SWITCHs_8 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08000020",
			CORE_DATA_WIDTH => 8
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(1),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => SWITCHES
		);

	BUTTONs_5 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08000040",
			CORE_DATA_WIDTH => 5
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(2),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => BUTTONS
		);

	-------------------------
	---- DEBUGGING CORES ----
	-------------------------

	debug_latches : wb_multi_latch_ip
		generic map(
			BASE_ADDR => x"08F00000"
		)
		port map(
			CLK_I   => sys_con_clk,
			RST_I   => sys_con_rst,
			WB_MS   => wb_ms_bus,
			WB_SM   => wb_sm(3),
			LATCH_D => debug_arm
		);

	debug_register_proc : process(sys_con_clk) is
	begin
		if rising_edge(sys_con_clk) then
			if sys_con_rst = '1' then
				debug_arm(0) <= (others => '0');
				debug_arm(1) <= (others => '0');
			else
				debug_arm(0) <= debug_arm(2);
				debug_arm(1) <= debug_arm(3);
			end if;
		end if;
	end process debug_register_proc;

end architecture RTL;
