library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_controller is
    port(
	opcode		: in std_logic_vector(5 downto 0);
	br				: in std_logic;
	ir				: in std_logic_vector(5 downto 0);
	aluop			: in std_logic_vector(1 downto 0);
	alu_sel		: out std_logic_vector(5 downto 0);
	alu_lo_hi	: out std_logic_vector(1 downto 0);
	hi_en			: out std_logic;
	lo_en			: out std_logic);
end alu_controller;

architecture cont of alu_controller is
begin
	
	process(ir, aluop, opcode)
	begin
	
		alu_sel 		<= "000000";
		alu_lo_hi 	<= "00";
		hi_en 		<= '0';
		lo_en 		<=  '0';
	
		if (aluop = "00") then
		
			alu_sel <= "100001";
			alu_lo_hi <= "00";
			hi_en <= '0';
			lo_en <= '0';
			
		elsif (aluop = "01") then
		
			if (opcode = "000001") then
				if (br = '0') then
					alu_sel <= "000001";
				else
					alu_sel <= "111110";
				end if;
			else
				alu_sel <= opcode;
			end if;
			
			alu_lo_hi <= "00";
			hi_en <= '0';
			lo_en <= '0';
			
		elsif (aluop = "10") then
		
			if (opcode = "000000") then
				alu_sel <= ir;
				if (ir = "010010") then
					alu_lo_hi <= "01";
				elsif (ir = "010000") then
					alu_lo_hi <= "10";
				else
					alu_lo_hi <= "00";
				end if;
				if (ir = "011000" OR ir = "011001") then
					hi_en <= '1';
					lo_en <= '1';
				else
					hi_en <= '0';
					lo_en <= '0';
				end if;
			elsif (opcode = "001001") then
				alu_sel <= "100001";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "010000") then
				alu_sel <= "100011";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "001100") then
				alu_sel <= "100100";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "001101") then
				alu_sel <= "100101";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "001110") then
				alu_sel <= "100110";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "001010") then
				alu_sel <= "101010";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			elsif (opcode = "001011") then
				alu_sel <= "101011";
				alu_lo_hi <= "00";
				hi_en <= '0';
				lo_en <= '0';
			end if;
			
			
		end if;
	
	end process;
end cont;
	