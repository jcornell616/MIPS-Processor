library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_ext is
port (
	input : in std_logic_vector(15 downto 0);
	issigned : in std_logic;
	output : out std_logic_vector(31 downto 0);
	shifted_out : out std_logic_vector(31 downto 0));
end sign_ext;

architecture bhv of sign_ext is
begin
	process(input, issigned)
	
		variable temp : std_logic_vector(31 downto 0);
	
	begin
	
		if (issigned = '1') then
			temp := std_logic_vector(to_unsigned(0, 16)) & input;
		else
			if (input(15) = '0') then
				temp := std_logic_vector(to_unsigned(0, 16)) & input;
			else
				temp := "1111111111111111" & input;
			end if;
		end if;
	
		output <= temp;
		shifted_out <= std_logic_vector(shift_left(signed(temp), 2));
	
	end process;
end bhv;
	
	