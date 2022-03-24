----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2017 17:05:26
-- Design Name: 
-- Module Name: time_management - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_management1 is
   PORT( 
    -- general
    clk_80211          : IN     std_logic;
    clk_10mhz          : in     std_logic;
    rst_80211          : IN     std_logic;
    
    -- time management interface
    nav1                : out     std_logic;
    sifs_flag1          : out     std_logic;
    difs_flag1          : out     std_logic;
    backoff_flag1       : out     std_logic;
    sifs_req1           : in      std_logic;
    difs_req1           : in      std_logic;
    backoff_req1        : in      std_logic;
    nav_req1            : in      std_logic;
    duration1           : in      integer        --simulador de valor duração 
    
);
end time_management1;

architecture Behavioral of time_management1 is

type flag_state is (idle, wait_count_sifs, wait_count_difs, wait_count_backoff); --define um tipo específico de máquina de estado
type cnt_state  is (idle, counting);
type state_nav is (idle, wait_count_nav);  ---------- Adicionado

signal current_state : flag_state; -- utiliza o tipo definido anteriormente
signal clk_cnt_state : cnt_state;
signal nav_cont_state : state_nav;   -------- Adicionado


signal  count, clock_count, count_nav : integer ;
signal  wait_done : std_logic;
signal be, cv, nb : integer ;


begin

time_man_proc : process (clk_80211)
begin
-- maquina de estado que espera requisições da camada MAC
-- deve se informar ao cont_clk quantos ciclos ele deve esperar
if rising_edge(clk_80211) then -- Lucas
	if rst_80211='1' then
		-- inicializar variáveis (pode ser feito depois)
		
		current_state<= idle;
		sifs_flag1 <= '0';
        difs_flag1 <= '0';
        backoff_flag1 <= '0';
        
        count <= 0;
        
	else
		case current_state is
			when idle =>
				if sifs_req1= '1' then
					current_state <= wait_count_sifs;
				elsif difs_req1 = '1' then
					current_state <= wait_count_difs;
				elsif backoff_req1 = '1' then
					current_state <= wait_count_backoff;
				
				else
					sifs_flag1 <= '0';
					difs_flag1 <= '0';
					backoff_flag1 <= '0';
					count <= 0;
										
--					be <= 3;
--					cw <= 2;
--					nb <= 0;
				end if;

			when wait_count_sifs =>
				count <= 13;                      --- ALEATORIO
				if wait_done = '1' then
					sifs_flag1 <= '1';
					current_state <= idle;
				else
					current_state <= wait_count_sifs;
				end if;

			when wait_count_difs =>
				count <= 13;                       --- ALEATORIO
				if wait_done ='1' then
					current_state <= idle;
					difs_flag1 <= '1';
				else
					current_state <= wait_count_difs;-- Lucas
				end if;

			when wait_count_backoff =>
			-- inserir o calculo do backoff aleatorio
			     
--			     count <=  ((2**be)-1);
			     
			     
			     
			     
			
			     
			     if wait_done ='1' then
			         current_state <= idle;
			         backoff_flag1 <= '1';
			     else
			         current_state <= wait_count_backoff;
			     end if;
		
                
			 
			
			end case;-- Lucas
		end if;-- Lucas
	end if;-- Lucas
end process;

cont_clk_proc : process (clk_10MHz)
begin
if rising_edge(clk_10MHz) then -- Lucas
	if rst_80211='1' then -- Lucas
	
	   clock_count <= 0;
	   wait_done <= '0'; -- Lucas
       clock_count <= 0;
       clk_cnt_state <= idle;
	-- inicializar variáveis (pode ser feito depois)
	else -- Lucas
		case clk_cnt_state is
			when idle =>
				if count > 0 then
				    
					clk_cnt_state <= counting;
				else
					clk_cnt_state <= idle;
					wait_done <= '0'; -- Lucas
					clock_count <= 0; -- Lucas
				end if;
			
			when counting =>
				if clock_count < count then
					clock_count <= clock_count + 1;
					clk_cnt_state <= counting; -- Lucas
				else 
					wait_done <= '1';
					clk_cnt_state <= idle;
				end if;
				
		end case; -- Lucas
	end if;-- Lucas
end if;-- Lucas
end process;

cont_nav_proc : process (clk_10MHz)
begin
 if rising_edge(clk_10MHz) then -- Lucas
        if rst_80211='1' then -- Lucas
            nav_cont_state <= idle;
            count_nav <= 0;
            nav1 <= '0'; ------
            
        else 
            case nav_cont_state is
                when idle =>
            
                    if nav_req1 ='1' then
		               nav_cont_state <= wait_count_nav;
                     else 
                        nav_cont_state <= idle;
                        nav1 <= '0';
                    end if;			
                when wait_count_nav =>
                    count_nav <= duration1;
                    if wait_done = '1' then
                        nav_cont_state <= idle;
                        nav1 <= '0';
                     else
                        nav_cont_state <= wait_count_nav;
                     end if;            
                
                
            end case;
        end if;
end if;
end process;








end Behavioral;
