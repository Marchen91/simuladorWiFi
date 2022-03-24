--
-- VHDL Architecture DNP3_802_11_lib.SAR2_PHY.Ass_Seg
--
-- Created:
--          by - Lucas.UNKNOWN (LUCAS-ACER64)
--          at - 14:39:14 18/07/2013
--
-- using Mentor Graphics HDL Designer(TM) 2012.1 (Build 6)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;




--############################################################################################################################################


entity tx_rx_physical1 is
   PORT( 
    -- general
    clk_80211          : IN     std_logic;
    clk_10mhz          : in     std_logic;
    rst_80211          : IN     std_logic;
    
    sta_send_frame_len1 : IN     std_logic_vector (15 DOWNTO 0);
    sta_send_frame1     : IN     std_logic_vector (3007 DOWNTO 0);
    sta_rec_frame1      : OUT    std_logic_vector (3007 DOWNTO 0);
    sta_rec_frame_len1  : OUT    std_logic_vector (15 DOWNTO 0);
    tx_fromsta11        : IN     std_logic_vector (3199 DOWNTO 0);
    sta_phy_tx1         : OUT    std_logic_vector (3199 DOWNTO 0);
    endtx1              : OUT     std_logic;
    endtx10             : IN     std_logic;
    endtx11             : OUT     std_logic;
    endtx111             : OUT     std_logic;
    channel_idle1       : out     std_logic
    

);
end tx_rx_physical1;


architecture Behavioral of tx_rx_physical1 is

type physi_state is (idle,  tx_phy, rx_phy);
type count_physi_state is ( idle, counting);
signal state_phy : physi_state;
signal clk_cnt_transm : count_physi_state;

signal firstloop,firstloop1            : std_logic_vector (1 downto 0);


signal frame_buffer : std_logic_vector (3007 downto 0);
signal frame_len : integer := 0;
signal rxtx_buffer : std_logic_vector (3199 downto 0);
signal rxtx_len : integer := 0;

signal transm_cont : integer := 0; -- em us
signal rate_bps : integer := 11534336;
signal  count_trans : std_logic;
signal clock_count : integer;


begin
SPHY_process : process (clk_80211)
begin

if rising_edge(clk_80211) then -- Lucas
	if rst_80211='1' then
		
		
		
        
        endtx111 <= '0';
        endtx11 <= '0';
--		count_trans <='0';
		state_phy <= idle;
--		count_trans <='0';
        firstloop <= "00";
        firstloop1 <= "00";
        channel_idle1 <= '1';
	else
		case state_phy is
			when idle =>
				if (sta_send_frame1 (3007) > '0') then  --  transmite dado
					state_phy <= tx_phy;
					frame_buffer <= sta_send_frame1;
			    elsif (tx_fromsta11 (3007) > '0') then   --recebe
					state_phy <= rx_phy;
						
				else
                    state_phy <= idle;
                    firstloop <= "00";
                    frame_buffer <= (others => '0');
                    rxtx_buffer <=  (others => '0');
--                    count_trans <='0';
                    endtx1<='0';
                    endtx11 <='0';
                    endtx111 <= '0';
                    channel_idle1 <= '1';
                    firstloop1 <= "00";
                    sta_phy_tx1 <= (others => '0');
                    
                
                end if;
                    
                    
			when tx_phy  =>
				if firstloop = "00" then
				
				    channel_idle1 <= '0';
--                    frame_buffer <= sta_send_frame1;
                    frame_len <= conv_integer (sta_send_frame_len1);
                    firstloop <= "01";
                
                elsif firstloop = "01" then
               
                    rxtx_len <= frame_len+(24*8);
                    firstloop <= "10";
                    
                elsif firstloop ="10" then 
                    
                    rxtx_buffer (3199 downto 3072) <= x"00000000000000000000000000000000"; --sync (127 downto 0)
                    rxtx_buffer (3071 downto 3056) <= x"F3A0"; --start frame delimiter (15 downto 0) <= "1111 0011 1010 0000"
                    rxtx_buffer (3055 downto 3048) <= x"6e";   -- signal (7 downto 0) <= 11 Mbps
                    rxtx_buffer (3047 downto 3040) <= x"01"; -- service (7 downto 0) <=
                    rxtx_buffer (3039 downto 3024) <= conv_std_logic_vector (frame_len,16); --tamanho (15 downto 0) <= 
                    rxtx_buffer (3023 downto 3008) <= x"ffff"; --crc16bits (15 downto 0) <=
                          --rxtx_buffer (3199 downto 3072)<= header_rxtx;
                          --rxtx_buffer (927 downto 920)<= conv_std_logic_vector((rxtx_len/8),8); -- lenght
                    rxtx_buffer (3007 downto 0) <= frame_buffer (3007 downto 0);
                    
                    firstloop <= "11";
                
                elsif firstloop = "11" then
                     transm_cont <= rxtx_len*1000000/rate_bps;
                     sta_phy_tx1 <= rxtx_buffer;
                                     
                
                    if count_trans ='1' then  
                                   -- count_trans tem que ir pra 0 em algum lugar depois
                        if firstloop1 = "00" then   
                            
                             endtx1 <= '1';
                             endtx11 <= '1';
                             endtx111 <= '1';
                                             -- ir pra zero 
--                             sta_phy_tx1 <= (others => '0');
                             firstloop1 <= "01";
                        elsif firstloop1 = "01" then
                           endtx1 <= '0';
                           endtx111 <= '0';
                           firstloop <= "00";
                           firstloop1 <= "00";
                           state_phy <= idle;
                           transm_cont <= 0 ;
                           sta_phy_tx1 <= (others => '0');
                            
                        end if;
                     else
                             state_phy <= tx_phy;-- Lucas
                             
                             
                      end if;
                end if;
                
                
                
           when rx_phy   =>
                   
--                 wait for 400 ns;
                 if firstloop = "00" then
                     channel_idle1 <= '0';
                     rxtx_buffer <= tx_fromsta11;
                         --rxtx_len <= (conv_integer (ed_tx(927 downto 920))*8)+48;
                     frame_len <= conv_integer (tx_fromsta11(3039 downto 3024)); -- bits
--                     wait for 400 ns;
                     
                     firstloop <= "01";
                 
                elsif firstloop = "01" then
                     sta_rec_frame1 <= rxtx_buffer (3007 downto 0);
                     sta_rec_frame_len1 <= conv_std_logic_vector((frame_len),16); --bits
                     
                  
                     
                     if endtx10 = '1' then
                     
                        endtx1 <= '1';
                        state_phy <= idle;
                        firstloop <= "00";
--                        tx_fromsta11 <= (others =>'0');       PROBLEMA COM ATUALIZAÇÃO
                     else
                        state_phy <= rx_phy;
                     end if;
               end if; 
         end case;
      end if;
    end if;
  end process;
               
               
               
               
trans_cont_proc : process (clk_10MHz)
  begin
  if rising_edge(clk_10MHz) then -- Lucas
      if rst_80211='1' then -- Lucas
      
         clock_count <= 0;
         count_trans <= '0'; -- Lucas         Sinal a ser mandado para a fsm  TX
         
         clk_cnt_transm <= idle;
      -- inicializar variáveis (pode ser feito depois)
      else -- Lucas
          case clk_cnt_transm is
              when idle =>
                  if transm_cont > 0 then
                      
                      clk_cnt_transm <= counting;
                  else
                      clk_cnt_transm <= idle;
                      count_trans <= '0'; -- Lucas
                      clock_count <= 0; -- Lucas
                  end if;
              
              when counting =>
                  if clock_count < transm_cont then
                      clock_count <= clock_count + 1;
                      clk_cnt_transm <= counting; -- Lucas
                  else 
                      count_trans <= '1';
                      
                      clk_cnt_transm <= idle;
                  end if;
                  
          end case; -- Lucas
      end if;-- Lucas
end if;-- Lucas
end process;
end Behavioral;               
               
               
				
				
				
				
