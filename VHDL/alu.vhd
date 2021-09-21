library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	generic (
		WIDTH : positive := 32
	);
	port (
		input1 : in std_logic_vector(WIDTH-1 downto 0);
		input2 : in std_logic_vector(WIDTH-1 downto 0);
		sel : in std_logic_vector(5 downto 0);
		shift : in std_logic_vector(4 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0);
		high_out : out std_logic_vector(WIDTH-1 downto 0);
		branch_taken : out std_logic
	);
end alu;

architecture bhv of alu is

  -- sel constants
  
  constant C_ADD : std_logic_vector(5 downto 0) := "100001";
  constant C_SUB : std_logic_vector(5 downto 0) := "100011";
  constant C_MUL : std_logic_vector(5 downto 0) := "011000";
  constant C_MULU : std_logic_vector(5 downto 0) := "011001";
  constant C_AND : std_logic_vector(5 downto 0) := "100100";
  constant C_OR  : std_logic_vector(5 downto 0) := "100101";
  constant C_XOR : std_logic_vector(5 downto 0) := "100110";
  constant C_SRL : std_logic_vector(5 downto 0) := "000010";
  constant C_SLL : std_logic_vector(5 downto 0) := "000000";
  constant C_SRA : std_logic_vector(5 downto 0) := "000011";
  constant C_SLT : std_logic_vector(5 downto 0) := "101010";
  constant C_SLTU : std_logic_vector(5 downto 0) := "101011";
  constant C_MOV : std_logic_vector(5 downto 0) := "111111";
  constant C_BEQ : std_logic_vector(5 downto 0) := "000100";
  constant C_BNE : std_logic_vector(5 downto 0) := "000101";
  constant C_BLEZ: std_logic_vector(5 downto 0) := "000110";
  constant C_BGTZ : std_logic_vector(5 downto 0) := "000111";
  constant C_BLTZ : std_logic_vector(5 downto 0) := "000001";
  constant C_BGEZ : std_logic_vector(5 downto 0) := "111110";
  constant JR		: std_logic_vector(5 downto 0) := "001000";
  
  signal branch : std_logic_vector(width-1 downto 0);
  
begin 
  process(input1, input2, sel, shift)
  
    variable temp1 		: unsigned(width-1 downto 0) 				:= (others => '0');
	 variable temp2 		: unsigned(width-1 downto 0) 				:= (others => '0');
	 variable temp_out	: unsigned(width-1 downto 0) 				:= (others => '0');
	 variable temp_ms		: signed(2*width-1 downto 0) 				:= (others => '0');
	 variable temp_mu		: unsigned(2*width-1 downto 0) 			:= (others => '0');
	 
  begin
  
		temp1 := unsigned(input1);
		temp2 := unsigned(input2);
		temp_out	:= to_unsigned(0, temp_out'length);
		
		output 			<= (others => '0');
		high_out 		<= (others => '0');
		branch_taken 	<= '0';
		
		case sel is
      when C_ADD =>
		  temp_out := temp1 + temp2;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));

      when C_SUB =>
        temp_out := temp1 - temp2;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_MUL =>
        temp_ms := signed(input1)*signed(input2);
		  branch_taken <= '0';
		  output 	<= std_logic_vector(temp_ms(width-1 downto 0));
		  high_out	<= std_logic_vector(temp_ms(2*width-1 downto width));
		  
		when C_MULU =>
		  temp_mu := temp1*temp2;
		  branch_taken <= '0';
		  output 	<= std_logic_vector(temp_mu(width-1 downto 0));
		  high_out	<= std_logic_vector(temp_mu(2*width-1 downto width));

      when C_AND =>
        temp_out := temp1 and temp2;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));

      when C_OR =>
        temp_out := temp1 or temp2;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_XOR =>
        temp_out := temp1 xor temp2;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_SRL =>
			temp_out := shift_right(temp2, to_integer(unsigned(shift)));
			branch_taken <= '0';
			output <= std_logic_vector(temp_out);
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_SLL =>
		   temp_out := shift_left(temp2, to_integer(unsigned(shift)));
			branch_taken <= '0';
			output <= std_logic_vector(temp_out);
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_SRA =>
			temp_out := unsigned(shift_right(signed(input2), to_integer(unsigned(shift))));
			branch_taken <= '0';
			output <= std_logic_vector(temp_out);
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_SLT =>
		  if (signed(input1) < signed(input2)) then
				temp_out := to_unsigned(1, temp_out'length);
		  else
				temp_out := to_unsigned(0, temp_out'length);
		  end if;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
		when C_SLTU =>
		  if (unsigned(input1) < unsigned(input2)) then
				temp_out := to_unsigned(1, temp_out'length);
		  else
				temp_out := to_unsigned(0, temp_out'length);
		  end if;
		  branch_taken <= '0';
		  output <= std_logic_vector(temp_out);
		  high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BEQ =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) = signed(input2)) then
				branch_taken <= '1';
			else
				branch_taken <= '0';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BNE =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) = signed(input2)) then
				branch_taken <= '0';
			else
				branch_taken <= '1';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BLEZ =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) > 0) then
				branch_taken <= '0';
			else
				branch_taken <= '1';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BGTZ =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) > 0) then
				branch_taken <= '1';
			else
				branch_taken <= '0';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BLTZ =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) < 0) then
				branch_taken <= '1';
			else
				branch_taken <= '0';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when C_BGEZ =>
			temp_out := to_unsigned(0, temp_out'length);
			if (signed(input1) < 0) then
				branch_taken <= '0';
			else
				branch_taken <= '1';
			end if;
			output <= branch;
		   high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
			
		when JR =>
			temp_out := temp1;
			branch_taken <= '0';
			output <= std_logic_vector(temp_out);
			high_out	<= std_logic_vector(to_unsigned(0, high_out'length));
		  
      when others => null;
		
		branch <= std_logic_vector(temp_out);
		
    end case;
	 
  end process;
end bhv;


