library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
	clk			: in std_logic;
	rst			: in std_logic;
	opcode		: in std_logic_vector(5 downto 0);
	ir				: in std_logic_vector(5 downto 0);
	branch_tkn	: in std_logic;
	pcwrite		: out std_logic;
	iord			: out std_logic;
	memread		: out std_logic;
	memwrite		: out std_logic;
	memtoreg		: out std_logic;
	irwrite		: out std_logic;
	jmpandlnk	: out std_logic;
	issigned		: out std_logic;
	pcsource		: out std_logic_vector(1 downto 0);
	aluop			: out std_logic_vector(1 downto 0);
	alusrcb		: out std_logic_vector(1 downto 0);
	alusrca		: out std_logic;
	regwrite		: out std_logic;
	regdst		: out std_logic);
end controller;

architecture FSM2P of controller is
----------- your signals here -----------
	type STATE_TYPE is (INST_FETCH, INST_DECODE, ADDR_COMP, LW_ACCESS, SW_ACCESS,
							  LW_COMP, LW_ACCESS_DELAY, LW_COMP_DELAY, SW_ACCESS_DELAY, SW_DELAY, R_EX, R_COMP, B_COMP, B_DELAY, B_DELAY2, J_COMP, J_DELAY, MFLOHI, HALT);
	signal state, next_state : STATE_TYPE;

begin
----------- your code for 2 Process FSM -----------
	process(rst, clk)
	begin
		
		if (rst = '1') then
		
			state <= INST_FETCH;
			
		elsif (rising_edge(clk)) then
		
			state <= next_state;
			
		end if;
		
	end process;
	
	process(state, opcode, branch_tkn)
	
		variable pcwritecond : std_logic;
		variable pcwritetemp	: std_logic;
	
	begin
	
		next_state	<= state;
		
		pcwritecond	:= '0';
		pcwritetemp := '0';
		
		pcwrite		<= '0';
		iord			<= '0';
		memread		<= '0';
		memwrite		<= '0';
		memtoreg		<= '0';
		irwrite		<= '0';
		jmpandlnk	<= '0';
		issigned		<= '0';
		pcsource		<= "10";
		aluop			<= "00";
		alusrcb		<= "00";
		alusrca		<= '1';
		regwrite		<= '0';
		regdst		<= '0';
	
		case state is
		
			when INST_FETCH =>
			
				memread 		<= '1';
				alusrca 		<= '0';
				iord			<= '0';
				irwrite		<= '1';
				alusrcb		<= "01";
				aluop			<= "00";
				pcwritetemp	:= '1';
				pcsource		<= "00";
				
				next_state <= INST_DECODE;
				
			when INST_DECODE =>
			
				alusrca 	<= '0';
				alusrcb	<= "11";
				aluop		<= "00";
				
				if ((opcode = "100011") OR (opcode = "101011")) then
					next_state <= ADDR_COMP;
				elsif ((opcode = "000000") OR (opcode = "001001") OR (opcode = "010000") OR (opcode = "001100") OR
						(opcode = "001101") OR (opcode = "001110") OR (opcode = "001010") OR (opcode = "001011")) then
					next_state <= R_EX;
				elsif ((opcode = "000010") OR (opcode = "000011")) then
					next_state <= J_COMP;
				elsif (opcode = "010000") OR (opcode = "010010") then
					next_state <= MFLOHI;
				elsif (opcode = "111111") then
					next_state <= HALT;
				else
					next_state <= B_COMP;
				end if;
			
			when ADDR_COMP =>
			
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
		
				if (opcode = "100011") then
					next_state <= LW_ACCESS;
				else
					next_state <= SW_ACCESS;
				end if;
	
			when LW_ACCESS =>
			
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				memread 	<= '1';
				iord 		<= '1';
				
				next_state <= LW_ACCESS_DELAY;
				
			when LW_ACCESS_DELAY =>
				
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				memread 	<= '1';
				iord 		<= '1';
				
				next_state <= LW_COMP;

			when SW_ACCESS =>
			
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				iord		<= '1';
				
				next_state <= SW_ACCESS_DELAY;
				
			when SW_ACCESS_DELAY =>
			
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				memwrite	<= '1';
				iord		<= '1';
			
				next_state <= SW_DELAY;
				
			when SW_DELAY =>
				
				iord		<= '0';
				
				next_state <= INST_FETCH;
			
			when LW_COMP =>
				
				memread 	<= '1';
				iord 		<= '1';
				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				regdst	<= '0';
				regwrite	<= '0';
				memtoreg	<= '1';
				
				next_state <= LW_COMP_DELAY;
				
			when LW_COMP_DELAY =>

				alusrca 	<= '1';
				alusrcb 	<= "10";
				aluop		<= "00";
				regdst	<= '0';
				regwrite	<= '1';
				memtoreg	<= '1';
				
				next_state <= INST_FETCH;

			when R_EX =>
			
				alusrca 	<= '1';
				aluop		<= "10";
				
				if (opcode = "000000") then
					alusrcb 	<= "00";
					if (ir = "001000") then
						next_state <= J_COMP;
					else
						next_state <=  R_COMP;
					end if;
				else
					alusrcb 	<= "10";
					next_state <= R_COMP;
				end if;
				
			when R_COMP =>

				regwrite <= '1';
				memtoreg	<= '0';
				aluop		<= "10";
				
				if (opcode = "000000") then
					alusrcb 	<= "00";
					regdst 	<= '1';
				else
					alusrcb 	<= "10";
					regdst 	<= '0';
				end if;
				
				next_state <= INST_FETCH;
			
			when B_COMP =>
			
				alusrca		<= '1';
				alusrcb		<= "00";
				aluop			<= "01";
				pcwritecond	:= '0';
				pcsource		<= "01";
				
				next_state <= B_DELAY;
				
			when B_DELAY =>
			
				alusrca		<= '1';
				alusrcb		<= "00";
				aluop			<= "01";
				pcwritecond	:= '1';
				pcsource		<= "01";
				
				next_state <= B_DELAY2;
				
			when B_DELAY2 =>
				
				next_state <= INST_FETCH;
			
			when J_COMP =>
			
				pcwritetemp	:= '1';
				pcsource		<= "10";
				
				if (opcode = "000011") then
					alusrca 	<= '0';
					alusrcb	<= "00";
					aluop		<= "00";
					jmpandlnk 	<= '1';
					regwrite		<= '1';
					memtoreg		<= '0';
				elsif (opcode = "000000" AND ir = "001000") then
					pcsource <= "01";
				end if;
				
				next_state <= J_DELAY;
				
			when J_DELAY =>
			
				pcwritetemp	:= '1';
				pcsource		<= "10";
				
				if (opcode = "000011") then
					alusrca 	<= '0';
					alusrcb	<= "00";
					aluop		<= "00";
					jmpandlnk 	<= '1';
					memtoreg		<= '0';
				elsif (opcode = "000000" AND ir = "001000") then
					pcsource <= "01";
				end if;
				
				next_state <= INST_FETCH;
				
			when MFLOHI =>
			
				aluop 	<= "10";
				memtoreg	<= '0';
				regdst	<= '1';
				regwrite	<= '1';
				
				next_state <= INST_FETCH;
				
			when HALT =>
			
				next_state <= HALT;

			when others => null;
		end case;
		
		pcwrite <= pcwritetemp OR (pcwritecond AND branch_tkn);
	
	end process;

end FSM2P;