library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is

    component alu

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

    end component;

    constant WIDTH  		: positive                           := 32;
    signal input1   		: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   		: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal sel      		: std_logic_vector(5 downto 0)       := (others => '0');
	 signal shift 	  		: std_logic_vector(4 downto 0)			:= (others => '0');
    signal output   		: std_logic_vector(WIDTH-1 downto 0);
    signal high_out 		: std_logic_vector(WIDTH-1 downto 0);
	 signal branch_taken : std_logic;

begin  -- TB

    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
            input1   		=> input1,
            input2   		=> input2,
            sel      		=> sel,
				shift				=> shift,
            output   		=> output,
            high_out 		=> high_out,
				branch_taken 	=> branch_taken);

    process
    begin

        -- test 10+15
        sel    <= "100001";
		  shift	<= "00000";
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(15, input2'length);
        wait for 10 ns;
        assert(output = conv_std_logic_vector(25, output'length)) report "Error : 10+15 = " & integer'image(conv_integer(output)) & " instead of 25" severity warning;

        -- test 25-10
        sel    <= "100011";
        input1 <= conv_std_logic_vector(25, input1'length);
        input2 <= conv_std_logic_vector(10, input2'length);
        wait for 10 ns;
        assert(output = conv_std_logic_vector(15, output'length)) report "Error : 25-10 = " & integer'image(conv_integer(output)) & " instead of 15" severity warning;

        -- test 10*-4
        sel    <= "011000";
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(-4, input2'length);
        wait for 10 ns;
        assert(output = conv_std_logic_vector(-40, output'length)) report "Error : 10*-4= " & integer'image(conv_integer(output)) & " instead of -40" severity warning;

        -- test 65536*131072
        sel    <= "011001";
        input1 <= conv_std_logic_vector(65536, input1'length);
        input2 <= conv_std_logic_vector(131072, input2'length);
        wait for 10 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : 65536*131072 = " & integer'image(conv_integer(output)) & " instead of 8589934592" severity warning;

        -- test 0x0000FFFF and 0xFFFF1234
		  sel    <= "100100";
        input1 <= conv_std_logic_vector(65535, input1'length);
        input2 <= conv_std_logic_vector(-60876, input2'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(4660, output'length)) report "Error : 0x0000ffff and 0xffff1234 = " & integer'image(conv_integer(output)) & " instead of 4660" severity warning;
		  
		  -- test srl 0x0000000F by 4
		  sel    <= "000010";
		  shift	<= "00100";
        input1 <= conv_std_logic_vector(15, input1'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(0, output'length)) report "Error : srl 15 by 4 = " & integer'image(conv_integer(output)) & " instead of 3" severity warning;
		  
		   -- test sra 0xF0000008 by 1
		  sel    <= "000011";
		  shift	<= "00001";
        input1 <= conv_std_logic_vector(-268435448, input1'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(-134217724, output'length)) report "Error : sra 0xf000008 by 1 = " & integer'image(conv_integer(output)) & " instead of -134217724" severity warning;
		  
		   -- test sra 0x00000008 by 1
		  sel    <= "000011";
		  shift	<= "00001";
        input1 <= conv_std_logic_vector(8, input1'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(4, output'length)) report "Error : sra 0x08 by 1 = " & integer'image(conv_integer(output)) & " instead of 4" severity warning;
		  
		   -- set on less than 10 and 15
		  sel    <= "101010";
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(15, input2'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(1, output'length)) report "Error : set when 10 less than 15 = " & integer'image(conv_integer(output)) & " instead of 1" severity warning;
		  
		   -- set on less than 15 and 10
		  sel    <= "101010";
        input1 <= conv_std_logic_vector(15, input1'length);
        input2 <= conv_std_logic_vector(10, input2'length);
        wait for 10 ns;
		  assert(output = conv_std_logic_vector(0, output'length)) report "Error : set when 15 less than 10 = " & integer'image(conv_integer(output)) & " instead of 0" severity warning;
		  
		   -- branch taken 5 <= 0
		  sel    <= "000110";
        input1 <= conv_std_logic_vector(5, input1'length);
        wait for 10 ns;
		  assert(branch_taken = '0') report "Error : branch taken incorrect for 5 <= 0" severity warning;
		  
		   -- branch taken 5 > 0
		  sel    <= "000111";
        input1 <= conv_std_logic_vector(5, input1'length);
        wait for 10 ns;
		  assert(branch_taken = '1') report "Error : branch taken incorrect for 5 > 0" severity warning;
		  
        wait;

    end process;



end TB;
