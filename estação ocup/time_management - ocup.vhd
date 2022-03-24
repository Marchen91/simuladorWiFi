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
use ieee.math_real.all;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_management_ocup is
   PORT( 
    -- general
    clk_80211          : IN     std_logic;
    clk_10mhz          : in     std_logic;
    rst_80211          : IN     std_logic;
    
    -- time management interface
    nav2                : out     std_logic;
    sifs_flag2          : out     std_logic;
    difs_flag2          : out     std_logic;
    backoff_flag2       : out     std_logic;
    sifs_req2           : in      std_logic;
    difs_req2           : in      std_logic;
    backoff_req2        : in      std_logic;
    nav_req2            : in      std_logic;
    duration22           : in     integer;     --simulador de valor duração 
    chanid             : in      std_logic;
    cwflag             : out     integer
    
);
end time_management_ocup;

architecture Behavioral of time_management_ocup is

type flag_state is (idle, wait_count_sifs, wait_count_difs); --define um tipo específico de máquina de estado
type cnt_state  is (idle, counting);
type state_nav is (idle, wait_count_nav);
type nav_state  is (idle, counting);
type state_bckoff is (idle, wait_count_backoff);
type bckoff_state  is (idle, counting);  ---------- Adicionado

signal current_state : flag_state; -- utiliza o tipo definido anteriormente
signal clk_cnt_state : cnt_state;
signal nav_cont_state : state_nav;   -------- Adicionado
signal nav_cnt_state  : nav_state;
signal bckoff_cont_state : state_bckoff; 
signal bckoff_cnt_state  : bckoff_state;

signal  count, clock_count, count_nav, clock_count_nav, count_backoff, clock_count_backoff : integer ;
signal  wait_done , wait_done_nav, wait_done_backoff : std_logic;


signal be, cw, nb : integer ;
SIGNAL SEED,acount1,acount2 : real := 0.0;
SIGNAL contadorSF : real := 0.0;
SIGNAL contSF : integer := 0; 
signal firstloop            : std_logic_vector (1 downto 0);


begin

time_man_proc : process (clk_80211)
begin
-- maquina de estado que espera requisições da camada MAC
-- deve se informar ao cont_clk quantos ciclos ele deve esperar
if rising_edge(clk_80211) then -- Lucas
	if rst_80211='1' then
		-- inicializar variáveis (pode ser feito depois)
		
		current_state<= idle;
		sifs_flag2 <= '0';
        difs_flag2 <= '0';
        
        
        count <= 0;
        
	else
		case current_state is
			when idle =>
				if sifs_req2= '1' then
					current_state <= wait_count_sifs;
				elsif difs_req2 = '1' then
					current_state <= wait_count_difs;
				
				
				else
					sifs_flag2 <= '0';
					difs_flag2 <= '0';
					
					count <= 0;
					
				end if;

			when wait_count_sifs =>
				count <= 13;                      --- ALEATORIO
				if wait_done = '1' then
					sifs_flag2 <= '1';
					current_state <= idle;
				else
					current_state <= wait_count_sifs;
				end if;

			when wait_count_difs =>
				count <= 13;                       --- ALEATORIO
				if wait_done ='1' then
					current_state <= idle;
					difs_flag2 <= '1';
				else
					current_state <= wait_count_difs;-- Lucas
				end if;

			
                
			 
			
			end case;-- Lucas
		end if;-- Lucas
	end if;-- Lucas
end process;




aleat : PROCESS (clk_10mhz) --contclk
      BEGIN
      if (clk_10mhz'EVENT and clk_10mhz = '1') then
	       contSF <= contSF + 1;
	       if (contSF > 31) then
	         contSF <= 0;
	       end if;
      end if;
    END PROCESS;






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

cont_nav_proc : process (clk_80211)
begin
 if rising_edge(clk_10MHz) then -- Lucas
        if rst_80211='1' then -- Lucas
            nav_cont_state <= idle;
            count_nav <= 0;
            nav2 <= '0'; 
            
        else 
            case nav_cont_state is
                when idle =>
            
                    if nav_req2 ='1' then
                       
		               nav_cont_state <= wait_count_nav;
		               nav2 <= '1';
                     else 
                        nav_cont_state <= idle;
                        
                    end if;			
                when wait_count_nav =>
                    count_nav <= duration22;
                    if wait_done_nav = '1' then
                        nav_cont_state <= idle;
                        nav2 <= '0';
                        count_nav <= 0 ;
                     else
                        nav_cont_state <= wait_count_nav;
                        nav2 <= '1';
                     end if;            
                
                
            end case;
        end if;
end if;
end process;


cont_nav_proc_clk : process (clk_10MHz)
begin
if rising_edge(clk_10MHz) then -- Lucas
	if rst_80211='1' then -- Lucas
	
	   clock_count_nav <= 0;
	   wait_done_nav <= '0'; -- Lucas
      nav_cnt_state <= idle;
	-- inicializar variáveis (pode ser feito depois)
	else -- Lucas
		case nav_cnt_state is
			when idle =>
				if count_nav > 0 then
				    
					nav_cnt_state <= counting;
				else
					nav_cnt_state <= idle;
					wait_done_nav <= '0'; -- Lucas
					clock_count_nav <= 0; -- Lucas
				end if;
			
			when counting =>
				if clock_count_nav < count_nav then
				  clock_count_nav <= clock_count_nav + 1;
                                
					nav_cnt_state <= counting; -- Lucas
				else 
					wait_done_nav <= '1';
					nav_cnt_state <= idle;
--					count_nav <= 0;
				end if;
				
		end case; -- Lucas
	end if;-- Lucas
end if;-- Lucas
end process;


--###################################################################################################################################33

bckoff_nav_proc : process (clk_80211)
begin
 if rising_edge(clk_10MHz) then -- Lucas
        if rst_80211='1' then -- Lucas
            bckoff_cont_state <= idle;
            count_backoff <= 0;
            backoff_flag2 <= '0';
                    
                    
            be <= 3;
            cw <= 2;
            nb <= 0;
            firstloop <= "00";
            
        else 
            case bckoff_cont_state is
                when idle =>
            
                  if  backoff_req2 = '1' then
                      bckoff_cont_state <= wait_count_backoff;
                       
		             
                  else 
                        bckoff_cont_state <= idle;
                        count_backoff <= 0;
                        backoff_flag2 <= '0';
                                
                                
                        be <= 3;
                        cw <= 2;
                        nb <= 0;
                        firstloop <= "00";
                        
                  end if;			
                
                
                when wait_count_backoff =>
                            -- inserir o calculo do backoff aleatorio
                               
                                     firstloop <= "01";
                                     seed <=  real((2**be)-1);
                                     contadorsf <= real(contsf);
                                     if firstloop = "01" then
                                         acount1 <= contadorSF/16.0;
                                         firstloop <="10";
                                     elsif firstloop = "10" then
                                         acount2  <= floor(seed*acount1);
                                         firstloop <= "11";
                                     elsif firstloop = "11" then
                    --                 seed <=  real((2**be)-1);
                    --                 contadorsf <= real(contsf);
                    --                 count <= (seed*(contadorSF/16.0));
                                            count_backoff <= 1+ integer(acount2);
                                                           
                                     end if;
                                 
                                 if chanid = '1' then
                                 
                                      cwflag <= cw;
                                      
                                 else 
                                 
                            
                                 
                                     if wait_done_backoff ='1' then
                                         
                                         cw <= cw -1;
                                         bckoff_cont_state <= idle;
                                         
                                         if cw = 0 then
                                           backoff_flag2 <= '1';  
                                           bckoff_cont_state <= idle;
                                         end if;
                                        
                                     else
                                         bckoff_cont_state <= wait_count_backoff;
                                     end if;
                                 end if; 
                                 
                                 --######################################################
                
                
                
                
                
               
                
                
            end case;
        end if;
end if;
end process;


count_bckoff_proc_clk : process (clk_10MHz)
begin
if rising_edge(clk_10MHz) then -- Lucas
	if rst_80211='1' then -- Lucas
	
	  clock_count_backoff <= 0;
	  wait_done_backoff <= '0'; -- Lucas
      bckoff_cnt_state <= idle;
	-- inicializar variáveis (pode ser feito depois)
	else -- Lucas
		case bckoff_cnt_state is
			when idle =>
				if count_backoff > 0 then
				    
					bckoff_cnt_state <= counting;
				else
					bckoff_cnt_state <= idle;
					wait_done_backoff <= '0'; -- Lucas
					clock_count_backoff <= 0; -- Lucas
				end if;
			
			when counting =>
				if clock_count_backoff < count_backoff then
				  clock_count_backoff <= clock_count_backoff + 1;
                                
					bckoff_cnt_state <= counting; -- Lucas
				else 
					wait_done_backoff <= '1';
					bckoff_cnt_state <= idle;
--					count_nav <= 0;
				end if;
				
		end case; -- Lucas
	end if;-- Lucas
end if;-- Lucas
end process;





end Behavioral;
