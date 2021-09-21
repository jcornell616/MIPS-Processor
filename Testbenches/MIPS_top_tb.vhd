library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MIPS_top_tb is
end MIPS_top_tb;

architecture TB of MIPS_top_tb is
	 
	 component MIPS_top
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			port_en		: in std_logic;
			port_sel		: in std_logic;
			port_in		: in std_logic_vector(8 downto 0);
			port_out		: out std_logic_vector(9 downto 0));
	end component;
		
	 signal clk				: std_logic									 := '0';
	 signal rst				: std_logic									 := '1';
    signal port_sel     : std_logic := '0';
	 signal port_en		: std_logic := '1';
	 signal port_in		: std_logic_vector(8 downto 0) := (others => '0');
	 signal port_out		: std_logic_vector(9 downto 0);

begin  -- TB

	UUT : MIPS_top
		port map (
			clk			=> clk,
			rst			=> rst,
			port_en		=> port_en,
			port_sel		=> port_sel,
			port_in		=> port_in,
			port_out		=> port_out);
			
	clk <= not clk after 10 ns;
	
	process
	begin
	
		rst <= '0';
		
		port_in <= "111111111";
		
		port_sel <= '0';
		
		port_en <= '0';
		
		wait for 40 ns;
		
		port_sel <= '1';
		
		wait for 40 ns;
		
		port_en <= '1';
		
		wait for 40 ns;

		rst <= '1';
		
		wait;
	
	end process;
end TB;