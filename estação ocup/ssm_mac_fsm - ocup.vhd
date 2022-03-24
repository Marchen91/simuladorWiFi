-- VHDL Entity DNP3_802_11_lib.SSM_MAC.interface
--
-- Created:
--          by - Lucas.UNKNOWN (LUCAS-ACER64)
--          at - 16:02:48 23/07/2013
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2012.1 (Build 6)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.STD_LOGIC_UNSIGNED.all;



ENTITY SSM_MAC_ocup IS
   PORT( 
    -- general
    clk_80211          : IN     std_logic;
    rst_80211          : IN     std_logic;
--    myaddress          : in     std_logic_vector (47 downto 0);
--    destaddress        : in     std_logic_vector (47 downto 0);
    
    -- time management interface
    nav2                : in     std_logic;
    sifs_flag2          : in     std_logic;
    difs_flag2          : in     std_logic;
    backoff_flag2       : in     std_logic;
    sifs_req2           : out    std_logic;
    difs_req2           : out    std_logic;
    backoff_req2        : out    std_logic;
    nav_req2            : out    std_logic;       ----- Adicionado
    
    -- tcp_ip_llc interface
    sen_tcpipllc2      : IN     std_logic_vector (2719 DOWNTO 0);
    rec_tcpipllc2      : OUT    std_logic_vector (2719 DOWNTO 0);
    sta_send_ack2       : IN     std_logic;
    sta_rec_ack2        : OUT    std_logic;
    duration22           : out    integer;
    
    -- phy layer interface
    endtx2             : in     std_logic;
    endtx222           : in     std_logic;
    channel_idle2      : in     std_logic;
    chanid             : out     std_logic;
    cwflag             : in     integer;
    sta_rec_frame2      : IN     std_logic_vector (3007 DOWNTO 0);
    sta_rec_frame_len2  : IN     std_logic_vector (15 DOWNTO 0);
    sta_send_frame2     : OUT    std_logic_vector (3007 DOWNTO 0);
    sta_send_frame_len2 : OUT    std_logic_vector (15 DOWNTO 0)
    );
END SSM_MAC_ocup ;
  
ARCHITECTURE fsm OF SSM_MAC_ocup IS

   -- Architecture Declaration
   
   TYPE STATE_TYPE IS (
      Idle,
      PerformCCADIFS,
      TransRTS,
      WaitCTS,
      WaitEndTX,
      WaitACK,
      WaitDATA,
      WaitNAV,
      WaitBackoff,
      WaitSIFS,
      RecDATA
   );
 
    -- Declare current state signals
    SIGNAL current_state : STATE_TYPE;
    
    signal failure       : std_logic;
    signal performcca    : std_logic;
    signal endtransm     : std_logic;
    SIGNAL acktime       : std_logic;  
    SIGNAL backofftime   : std_logic;  
    SIGNAL ctstime       : std_logic;  
    SIGNAL datatime      : std_logic;  
    SIGNAL difstime      : std_logic;  
    SIGNAL rtstime       : std_logic;  
    SIGNAL sifstime      : std_logic;  
    SIGNAL starttransm   : std_logic;
    signal firstloop            : std_logic_vector (1 downto 0);
    signal ftloop            : std_logic_vector (1 downto 0);
--    signal
    signal duration2             : std_logic_vector (15 downto 0);
    signal datagram_int         : std_logic_vector (15 downto 0);
    SIGNAL duration_int         : std_logic_vector (15 downto 0);
    SIGNAL duration_int_cts     : std_logic_vector (15 downto 0);
    SIGNAL duration_int_rts     : std_logic_vector (15 downto 0);
    SIGNAL duration_int_ack     : std_logic_vector (15 downto 0);
    SIGNAL duration_int_data    : std_logic_vector (15 downto 0);
    signal sen_frame_len_buffer : std_logic_vector (15 downto 0);
    signal rec_frame_len_buffer : std_logic_vector (15 downto 0); 
    signal datagram_len         : std_logic_vector (15 downto 0); 
    signal sen_frame_buffer     : std_logic_vector (3007 DOWNTO 0);
    signal rec_frame_buffer     : std_logic_vector (3007 DOWNTO 0);
    signal datagram_buffer      : std_logic_vector (2719 downto 0);
    signal VALOR1               : integer;
    signal VALOR2               : integer;
    signal VALOR3               : std_logic_vector (15 downto 0);
    signal VALOR4               : integer;
    signal VALOR5               : integer;
    signal VALOR6               : unsigned(7 downto 0);
    signal VALOR7               : unsigned(7 downto 0);
    signal VALOR8               : integer;
    signal VALOR9               : integer;
    signal VALOR10               : integer;
    
    
    constant ack_frame_fc       : std_logic_vector (15 downto 0) := x"80d4";
    constant rts_frame_fc       : std_logic_vector (15 downto 0) := x"84B4";
    constant cts_frame_fc       : std_logic_vector (15 downto 0) := x"84C4";
    constant data_frame_fc      : std_logic_vector (15 downto 0) := x"8708";
    constant rate_bps           : integer := 11534336; --11 Mbps * 1024 * 1024
    
    BEGIN
    duration_int_cts <= x"0014"; --30*8 000 000/ rate_bps
    duration_int_rts <= x"0018"; --36*8 000 000/ rate_bps
    duration_int_ack <= x"0014"; --30*8 000 000/ rate_bps

    fsm_mac_proc : process(clk_80211)
    begin
    if rising_edge(clk_80211) then
        if rst_80211 = '1' then
            firstloop <= "00";
            sifs_req2 <= '0';
            difs_req2 <= '0';
          
            rec_frame_buffer <= (others => '0');
            duration2 <= x"0000";
        else
            case current_state is
                ------------------------ generico ------------------------   
                when idle => 
                    IF sta_rec_frame2 (3007 downto 2992) = x"84B4" then--sta_rec_frame (3007 downto 2992) = rts_frame_fc then
                        
                        if sta_rec_frame2 (2975 downto 2928) = x"000000000010" then
                        -- processar recep��o
                        -- v� para wait sifs
                            sifs_req2 <= '1';
                            rec_frame_buffer <= sta_rec_frame2;
                            current_state <= WaitSIFS;
                            duration2 <= std_logic_vector (unsigned(sta_rec_frame2(2991 downto 2976))
                                                                   -unsigned(duration_int_rts)); -- duration - rts time
                        else
                        -- quadro n�o pertence � este n�
                            if firstloop = "00" then 
                                nav_req2 <= '1';
                                duration22 <= to_integer (unsigned(sta_rec_frame2(2991 downto 2976)));
    --                                                                                           -unsigned(duration_int_rts));
                                firstloop <= "01";  
                             elsif firstloop = "01" then    
                                current_state <= WaitNAV;
                                
                                
                                
--                            if nav2= '1' then
--                                nav_req2<= '0';
----                                firstloop <= "00";
                            end if;
                        end if;






                            
                                 
                             
                         
                    elsif sen_tcpipllc2 (2719 downto 2712) > x"00" then
                        -- processar envio
                        datagram_buffer <= sen_tcpipllc2;
                        datagram_len <= sen_tcpipllc2(2639 downto 2624);
                        if nav2 = '1' then
                            -- espere o per�odo de conten��o
                            current_state <= WaitNAV;
                        else
                            -- perform CCA
                            current_state <= PerformCCADIFS;
                        end if;
                    else
                        current_state <= idle;
                        firstloop <= "00";
                        nav_req2<= '0';
                    end if;
                    
                when WaitSIFS => 
                    if firstloop = "00" then
                        --duration cts = duration - sifs
                        duration2 <= std_logic_vector(unsigned(duration2) - 28);
                        current_state <= WaitSIFS;
                        firstloop <= "01";
                        sifs_req2 <= '0';
                    elsif firstloop = "01" then
                        current_state <= WaitSIFS;
                        firstloop <= "10";
                        if rec_frame_buffer(3007 downto 2992) = rts_frame_fc then
                            
                            --montando frame CTS para envio
                            sen_frame_buffer (3007 downto 2992) <= x"84C4"; --cabe�alho cts
                            sen_frame_buffer (2991 downto 2976) <= x"0024";--duration field
                            sen_frame_buffer (2975 downto 2928) <= x"000000000010";--endere�o desta esta��o
                            sen_frame_buffer (2927 downto 2896) <= x"ffffffff";--crc32bits 8 bytes
                            sen_frame_buffer (2895 downto 0) <= (others => '0');--zeros
                            sen_frame_len_buffer <= x"0070";
                        elsif rec_frame_buffer (3007 downto 2992) = data_frame_fc then
                            -- montando frame ACK para envio
                            sen_frame_buffer (3007 downto 2992) <= ack_frame_fc; --cabe�alho ack
                            sen_frame_buffer (2991 downto 2976) <= duration2; --duration/id (15 downto 0) = #dura��o em microsegundos do ack
                            sen_frame_buffer (2975 downto 2928) <= x"000000000000"; --endere�o de quem confirma
                            sen_frame_buffer (2927 downto 2896) <= x"ffffffff"; --crc32bits
                            sen_frame_len_buffer <= x"0070";
                        elsif rec_frame_buffer (3007 downto 2992) = cts_frame_fc then
                            -- montando frame DATA para envio
                            sen_frame_buffer (3007 downto 2992) <= x"8708";
                            sen_frame_buffer (2991 downto 2976) <= duration2; --duration/id (15 downto 0) #dura��o em microsegundos data frame+ sifs+ ack frame
                            sen_frame_buffer (2975 downto 2928) <= x"000000000000"; --address1 (47 downto 0) = AP =n�o ser� setado
                            sen_frame_buffer (2927 downto 2880) <= x"000000000000"; --address2 (47 downto 0) = Fonte =
                            sen_frame_buffer (2879 downto 2832) <= x"000000000001"; --address3 (47 downto 0) = Destino =
                            sen_frame_buffer (2831 downto 2816) <= x"0011"; --sequencecontrol (15 downto 0) <= "0000000000010001"
                            sen_frame_buffer (2815 downto 2768) <= x"000000000000"; --n�o ser� setado--address4 (47 downto 0) =
                            sen_frame_buffer (2767 downto 2752) <= x"0000"; --n�o ser� setado qoscontrol (15 downto 0) = 
                            sen_frame_buffer (2751 downto 2752-(conv_integer(datagram_len)*8)) <= 
                             datagram_buffer (2719 downto 2720-(conv_integer(datagram_len)*8));
                            sen_frame_buffer (2751-(conv_integer(datagram_len)*8) downto
                                              2720-(conv_integer(datagram_len)*8)) <= x"ffffffff"; --= crc32bits (31 downto 0)
                            sen_frame_len_buffer <= std_logic_vector(unsigned(datagram_len)+288);
                        end if;
                    elsif firstloop = "10" and sifs_flag2 = '1' then
                        --send mac frame
                        sta_send_frame2 <= sen_frame_buffer;
                        sta_send_frame_len2 <= sen_frame_len_buffer;
                        current_state <= WaitEndTX;
                        firstloop <= "00";
                        sifs_req2 <= '0';
                    end if;
                
                   
                when WaitEndTX => 
                    -- espera fim da transmiss�o do quadro
                    -- flag endtx deve ser dada pela camada f�sica
                    if endtx222 = '0' then
                        current_state <= WaitEndTX;
--                        sta_send_frame0 <= (others => '0');
--                        sta_send_frame_len0 <= x"0000";

                    else
                        sta_send_frame2 <= (others => '0');
                        sta_send_frame_len2 <= x"0000";
                        if rec_frame_buffer (3007 downto 2992) = rts_frame_fc then
                            -- wait for data
                            current_state <= WaitDATA;
                            firstloop <= "00";
                        elsif rec_frame_buffer (3007 downto 2992) = data_frame_fc then
                            -- v� para idle
                            current_state <= Idle;
                        elsif rec_frame_buffer (3007 downto 2992) = cts_frame_fc then
                            -- v� para trans data
                            current_state <= WaitACK;
                        end if;
                    end if;
                
                ------------------------ recebimento ------------------------    
                when WaitDATA =>
                    if sta_rec_frame2 (3007 downto 2992) = data_frame_fc then
                        current_state <= RecData;
                        firstloop <= "01";
                        rec_frame_buffer <= sta_rec_frame2;
                        datagram_len <= std_logic_vector(unsigned(sta_rec_frame_len2)-36*8);
                        rec_frame_len_buffer <= sta_rec_frame_len2;
                        duration2 <= std_logic_vector (sta_rec_frame2(2991 downto 2976)); -- duration
                        
                       
                    else
                        current_state <= WaitDATA;
                        
                    end if;
                
                when RecDATA =>
                    if rec_frame_buffer (3007 downto 2992) = data_frame_fc and firstloop = "01" then
                        current_state <= RecDATA;
                        firstloop <= "10";
                        valor9 <= to_integer(unsigned(rec_frame_len_buffer));
                         Valor8<= to_integer(unsigned(duration2));
                        valor10 <= conv_integer(datagram_len);
--                        duration0 <=
--duration0 <= std_logic_vector(unsigned(duration0) - 
--                                                     (unsigned(rec_frame_len_buffer))*0.7);
                    elsif firstloop = "10" then
                        current_state <= RecDATA;
                        firstloop <= "11";
--                        duration0 <= std_logic_vector(valor8 - valor9*.7)
                        rec_tcpipllc2 (2719 downto (2720-(conv_integer(datagram_len)))) <= 
                        rec_frame_buffer (2751 downto (2752-conv_integer(datagram_len)));
                    elsif firstloop = "11" and sta_send_ack2 = '1' then
                        
                            current_state <= WaitSIFS;
                            firstloop <= "00";
                            sifs_req2 <= '1';
                            rec_tcpipllc2 <= (others => '0');
                        
                        
                    end if;
                
                ------------------------ envio ------------------------    
                when WaitNAV =>
                    if nav2 = '1' then
--				        nav_req2 <= '1' ;      ------- Adicionado 
                        
                        current_state <= WaitNAV;
                    else
                        nav_req2<= '0'; 
                        if sen_tcpipllc2 (2719 downto 2712) > x"00" then
                            current_state <= PerformCCADIFS;
                            firstloop <= "00";
                        else
                            current_state <= idle;
                            firstloop <= "00";
                        end if;
                    end if;
                    
                when PerformCCADIFS =>
                    if nav2 = '1' then
                        current_state <= WaitNAV;
                    else
                        backoff_req2 <= '0';
                        if firstloop = "00" then
                            difs_req2 <= '1';
                            firstloop <= "01";
                            
                        elsif firstloop = "01" then
                            difs_req2<= '0';
                            if difs_flag2 = '1' then
                                if channel_idle2 = '0' then 
                                    current_state <= WaitBackoff;
                                    ftloop <= "00";
                                end if;
                                VALOR1 <= to_integer (unsigned(datagram_len));
                                VALOR2 <=  (115343360/11534336); 
                                firstloop <= "10";
                                
                            else
                                current_state <= PerformCCADIFS;
                            end if;
                                
                        elsif firstloop = "10" then
                            
                                current_state <= TransRTS;
                                firstloop <= "00";
                                            -- x"00"
                                            
                                 VALOR6 <= to_unsigned(VALOR1,8);
                                 VALOR7 <= to_unsigned(VALOR2,8);                                                
                        end if;
                     end if;
                                                                                
                                                          
                                                                           
                when WaitBackoff =>
                    backoff_req2 <= '1';
                    current_state <= WaitBackoff;
                    ftloop <= "01";
                    if ftloop = "01" then
                        
                       ftloop <= "10";
                    elsif ftloop= "10" then
--                     backoff_req2 <= '0';
                        
                        
--                    elsif firstloop = "01" then
--                        backoff_req2 <= '0';
                        if backoff_flag2 = '1' then
                            current_state <= PerformCCADIFS;
--                            firstloop <= "00";
--                            backoff_req2 <= '0';
                        else
                            current_state <= WaitBackoff;
                        end if;
                        firstloop <= "00";
                    end if;
                    
                when TransRTS =>
                    if firstloop = "00" then
                        firstloop <= "01";
                        current_state <= TransRTS;
--                        VALOR1 <= to_integer (unsigned(datagram_len));
--                        VALOR2 <=  ((8000000/11534));
--                        VALOR6 <= to_unsigned(VALOR1,8);
--                        VALOR7 <= to_unsigned(VALOR2,8);
--                        VALOR4 <= (VALOR1*8000000000);;
--                        VALOR5 <= (VALOR4/11534336);
--                        VALOR3 <= std_logic_vector(VALOR1);
                        duration_int_data <= std_logic_vector(VALOR6*VALOR7);                      --      NAO ESTA ADICIONADO
--                          duration_int_data <= std_logic_vector(unsigned(datagram_len)*8000000/11534336);
                    elsif firstloop = "01" then
                        firstloop <= "10";
                        current_state <= TransRTS;
                        duration2 <= std_logic_vector( unsigned(duration_int_rts) + 
                                                      unsigned(duration_int_cts) +
                                                     unsigned(duration_int_data)+
                                                      unsigned(duration_int_ack) +
                                                                              84 ); --3*28 (sifs) ADICIONAR unsigned(duration_int_data)  AO CODIGO
                      
                    elsif firstloop = "10" then
                        firstloop <= "11";
                        current_state <= TransRTS;
                        --preparar rts
                        sen_frame_buffer (3007 downto 2992) <= rts_frame_fc;--framecontrol (15 downto 0) <= "1000010010110100" = x"84B4"
                        sen_frame_buffer (2991 downto 2976) <= duration2; --duration/id (15 downto 0) dura��o em microsegundos do rts_frame+sifs+cts_fram+sifs+dataframe+sifs+ack
                        sen_frame_buffer (2975 downto 2928) <= x"000000000001"; --endere�o de destino
                        sen_frame_buffer (2927 downto 2880) <= x"000000000010" ; --endere�o de origem
                        sen_frame_buffer (2879 downto 2848) <= x"ffffffff"; --crc32bits
                    elsif firstloop = "11" then
                        sta_send_frame2 <= sen_frame_buffer;
                        sta_send_frame_len2 <= x"00a0"; --112 bits
                        firstloop <= "00";
                        current_state <= WaitCTS;
                    end if;
                
                when WaitCTS =>
                    
                    
                        sta_send_frame2 <= (others => '0'); 
                        if sta_rec_frame2 (3007 downto 2992) = cts_frame_fc and endtx2= '1' then
                            
                            current_state <= WaitSIFS;
                            duration2 <= std_logic_vector(unsigned(duration_int_data) +
                                                          unsigned(duration_int_ack) +
                                                                                  56 ); --1*28 (sifs)
                           rec_frame_buffer <= sta_rec_frame2; -----------------------------------Adicionado
                            sifs_req2 <= '1';---------------------------- Adicionado -----------------------------
                            
                        else
                            current_state <= WaitCTS;
                        end if;
                       
                   
                when WaitACK =>
                    if sta_rec_frame2 (3007 downto 2992) = ack_frame_fc then
                        current_state <= Idle;
                    else
                        current_state <= WaitACK;
                    end if;
                    
            end case;
        end if;
    end if;
    end process;

 
END fsm;
