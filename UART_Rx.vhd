-- Recepción de datos via UART con baud Rate 115200 bit/s
-- con frecuencia de reloj de 50 MHz

library ieee;
use ieee.std_logic_1164.all;


entity UART_Rx is 
port(		clk: 	in std_logic;
			Rx: 	in std_logic;
			RegOut: out std_logic_vector(7 downto 0)

);
end UART_Rx;

architecture Arq1 of UART_Rx is
type State_t is (Idle, Start, DataReceive, Stop) ;
signal State: State_t := Idle;
signal clkC: integer range 0 to 216 :=0 ;
signal C: integer range 0 to 7 :=7 ;
signal RegOut_A: std_logic_vector(7 downto 0);
begin
process(clk)
begin
	if rising_edge(clk) then 
		case State is 
			when Idle => 
				if Rx = '0' then 					--Si Detecta el bit de start entra:
					State <= Start; 				-- Cambia de estado
				end if;
			when Start => 
				if clkC = 107 then 
						if Rx = '0' then 			-- Verifica que Rx siga en cero después de 107 ciclos
							clkC <= 0;				-- Reinicio contador
							State <= DataReceive; -- Cambia de estado
						else 
							clkC <= 0;				-- Reinicio contador
							State <= Idle;			-- Regresa A estado Idle si no coninua en cero 
						end if;
				else
					clkC <= clkC +1 ; 		--Incrementa contador para primera muestra
				end if;
			when DataReceive =>
				if clkC = 216 then 
						RegOut_A(C) <= Rx ; 	-- Guardo el valor de Rx en la posición C del reistro RegOut
							if C > 0	then			-- Verifica haya terminado de muestrear los datos
								C <= C -1 ; 			-- Decremento contador
								clkC <= 0;				-- Reinicio contador
							else 
								C <= 7; 			-- Reinicio Contador
								clkC <= 0;		-- Reinicio contador
								State <= Stop;  -- Cuando termina cambia de estado
							end if; 
				else
					clkC <= clkC +1 ; 		--Incrementa contador para primera muestra
				end if;
			when Stop =>
				if clkC = 216 then 			-- Espera otros 217 ciclos de reloj (50 MHZ)
						if Rx = '1' then		-- Verifica que el ultimo bit sea uno 
							clkC <= 0;		-- Reinicio contador
							State <= Idle;
						else 
							clkC <= 0;		-- Reinicio contador
							State <= Idle;
						end if; 
				else
					clkC <= clkC +1 ; 		--Incrementa contador para primera muestra
				end if;
			when others =>	null;
		end case;
	end if;

end process;
--Asignación de señales:
RegOut <= RegOut_A; 
end Arq1;