-- Se describe un circuito que transmite información via UART con un Baud Rate de 115200 bits/s
library ieee;
use ieee.std_logic_1164.all;

entity UART_tx is
port(		clk : 	in	std_logic;
			Reset: 	in	std_logic;
			Enable: 	in std_logic;
			Tx: 		out std_logic
);


end UART_tx;

architecture Arq1 of  UART_tx is 
type State_t is (Idle, Start, DataSend, Stop);	-- Creo tipo de señal
signal State: State_t := Idle; 						-- Creo una señal tipo State_t inicilizada en Idle
signal Data: std_logic_vector(7 downto 0) := "01010101";		-- Señal a transmitir
signal C: integer range 0 to 7 := 7;				-- Creo señal contadora
signal Tx_A: std_logic;
begin
Process(clk, Reset)								-- Proceso sensible a clk y Reset
begin
if Reset = '1' then 
	Tx_A <= '1';
	State <= Idle;
elsif rising_edge(clk) and Enable = '1' then 
	case State is 
		when Idle => 
			Tx_A <= '1'; 						-- Tx se le asigna un '1' (No esta transmitiendo)
			State <= Start ; 				-- State cambia a Start
		when Start =>
			Tx_A <= '0';						-- Se le asigna un cero (Bit de start)
			State <= DataSend ; 				-- State cambia a DataSend
		when DataSend =>
			if C = 0 then
				Tx_A <= Data(C); 
				C <= 7;						-- Reinicio contador
				State <= Stop;				-- Cambio de estado
			else
				Tx_A <= Data(C); 				-- Envia un byte partiendo del más significativo
				C <= C -1;						-- Decremento contador
			end if;
		when Stop =>
			Tx_A <= '1';						-- Coloco en '1' Tx para dejar de transmitir
		when others => null;
	end case;
end if;		
end process;

--Asignación de señales:
Tx <= Tx_A;
end Arq1;