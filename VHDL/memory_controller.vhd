library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_controller is
	port (
		sel 		: out std_logic_vector(1 downto 0);
		wr_ram	: out std_logic;
		port0_en	: out std_logic;
		port1_en : out std_logic;
		oport_en	: out std_logic;
		wren		: in std_logic;
		rden		: in std_logic;
		port_en	: in std_logic;
		port_sel	: in std_logic;
		addr		: in std_logic_vector(31 downto 0));
end memory_controller;

architecture bhv of memory_controller is
begin
	
	process (addr, wren, rden, port_en, port_sel)
	begin
		
			sel <= "00";
	
			if (addr(15 downto 0) = "1111111111111100") then
				if (wren = '1') then
					wr_ram 	<= '0';
					oport_en	<= '1';
				elsif (rden = '1') then
					wr_ram 	<= '0';
					oport_en	<= '0';
					sel <= "10";
				else
					wr_ram	<= '0';
					oport_en <= '0';
				end if;
			elsif (addr(15 downto 0) = "1111111111111000") then
				if (rden = '1') then
					wr_ram 	<= '0';
					oport_en	<= '0';
					sel <= "01";
				else
					wr_ram	<= '0';
					oport_en	<= '0';
				end if;
			else
				if (wren = '1') then
					wr_ram 	<= '1';
					oport_en	<= '0';
				else
					wr_ram	<= '0';
					oport_en <= '0';
					sel <= "00";
				end if;
			end if;
			
			if (port_en = '0') then
				if (port_sel = '1') then
					port0_en <= '0';
					port1_en <= '1';
				else
					port0_en <= '1';
					port1_en <= '0';
				end if;
			else
				port0_en <= '0';
				port1_en <= '0';
			end if;

	end process;
end bhv;