library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity not_gate is
	port (
		input  : in std_logic;
		output : out std_logic);
end not_gate;

architecture BHV of not_gate is
begin
	process(input)
	begin
		output <= NOT input;
	end process;
end BHV;