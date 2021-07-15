clc;clear;
% Encoding the SIGNAL field with convolutional encoder Figure 114 Standard
fid = fopen('signal.txt');
datachar = fgetl(fid);
signal(1:24) = 0;
for i=1:24
    signal(i) = datachar(i)-48;
end
fclose(fid);

shift(1:6) = 0; % the shift register
% 2 output bits for each input bit
% a has to come prior to b
% ex : input bit -> ( encoder ) -> ab ( 2 bit )
a(1:24) = 0;
b(1:24) = 0;

for i=1:24
  a(i) = rem((signal(i) + shift(2) + shift(3) + shift(5) + shift(6)),2);
  b(i) = rem((signal(i) + shift(1) + shift(2) + shift(3) + shift(6)),2);
  shift = [signal(i) shift(1:5)]; % enter the input bit and shift reg to right every clk  
end  
%%
% combine a and b ( a comes prior to b)
% 24 bit input -> (encoder) -> 48 bit output like
% [a1b1a2b2a3b3a4b4a5b5a6b6...a48b48]
c(1:48) = 0;
for i=1:24
    c(2*i-1) = a(i);
    c(2*i) = b(i);
end
%% for SIGNAL Ncbps = 48
Ncbps = 48;
k(1:48) = 0;
for lp = 1:48
    k(lp) = lp-1;
end

ii(1:48)=0;
for lp = 1:48
    ii(lp) = (Ncbps/16)*mod(k(lp),16) + floor(k(lp)/16); 
end

c_inleaved(1:48)=0;
for lp = 1:48
    c_inleaved((ii(lp)+1)) = c(lp);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN code
clc;clear;
fid = fopen('encoded_frame_12.txt'); % this is the output of encoder which needs to be interleaved
datachar = fgetl(fid);
length = numel(datachar);
encoded(1:length) = 0;
for i=1:length
    encoded(i) = datachar(i)-48;
end
fclose(fid);
 
%first 48 bits are encoded signal field which has been encoded
%by rate = 6 Mhz, BPSK whch Ncbps = 48 
%but the 49th bit is the start of encoded DATA field
%Which in our project could have been encoded with 12 or 18 Mhz QPSK
% and both yield Ncbps = 96!

encoded_sig(1:48) = encoded(1:48);
encoded_data(1:length - 48) = encoded(49:length);
%%

%%%%%%SIGNAL
Ncbps_sig = 48;
k(1:48) = 0;
for lp = 1:48
    k(lp) = lp-1;
end

ii(1:48)=0;
for lp = 1:48
    ii(lp) = (Ncbps_sig/16)*mod(k(lp),16) + floor(k(lp)/16); 
end

sig_inleaved(1:48)=0;
for lp = 1:48
    sig_inleaved((ii(lp)+1)) = encoded_sig(lp);
end
%%
%%%%% DATA
Ncbps_data = 96;
k(1:96) = 0;
for lp = 1:96
    k(lp) = lp-1;
end

ii(1:96)=0;
for lp = 1:96
    ii(lp) = (Ncbps_data/16)*mod(k(lp),16) + floor(k(lp)/16); 
end

data_inleaved(1:96)=0;
sym = (length - 48)/Ncbps_data;

for cntr = 1:sym
    for lp = 1:96
        data_inleaved((ii(lp)+1)) = encoded_data(lp);   
    end
    encoded_data = encoded_data(97:end);
    data_final(96*cntr-95:96*cntr) = data_inleaved(1:96);
end

%% Integration
    
 inleaved = [sig_inleaved data_final];   
 fid = fopen('interleaved12.txt','wt');
 fprintf(fid,'%d\n',inleaved);
 fclose(fid);

%%
%%%%%%%%%%%%%%%%%%%%%cherknevis
fid = fopen('interleaved_12_hdl.txt'); % this is the output of encoder which needs to be interleaved
datachar = fgetl(fid);
length = numel(datachar);
encoded(1:length) = 0;
for i=1:length
    encoded(i) = datachar(i)-48;
end
fclose(fid);

%%  
 fid = fopen('encoded_frame_12_hdl.txt','wt');
 fprintf(fid,'%d\n',encoded);
 fclose(fid);
%%
fid = fopen('.txt'); % this is the output of encoder which needs to be interleaved
datachar = fgetl(fid);
length = numel(datachar);
encoded(1:length) = 0;
for i=1:length
    encoded(i) = datachar(i)-48;
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% deinterleaver

clc;clear;
fid = fopen('interleaved12.txt'); % needs to be deinterleaved
rx = fscanf(fid,'%d'); % what we have received in deinterleaver
rx = rx';
fclose(fid);
length = max(size(rx));
rx_sig(1:48) = rx(1:48);
rx_data(1:length - 48) = rx(49:length);
%%

%%%%%%SIGNAL
Ncbps_sig = 48;
k(1:48) = 0;
for lp = 1:48
    k(lp) = lp-1;
end

ii(1:48)=0;
for lp = 1:48
    ii(lp) = 16*k(lp)-(Ncbps_sig-1)*floor(16*k(lp)/Ncbps_sig); 
end

sig_deinleaved(1:48)=0;
for lp = 1:48
    sig_deinleaved((ii(lp)+1)) = rx_sig(lp);
end
%%
%%%%% DATA
Ncbps_data = 96;
k(1:96) = 0;
for lp = 1:96
    k(lp) = lp-1;
end

ii(1:96)=0;
for lp = 1:96
    ii(lp) = 16*k(lp)-(Ncbps_data-1)*floor(16*k(lp)/Ncbps_data); 
end

data_deinleaved(1:96)=0;
sym = (length - 48)/Ncbps_data;

for cntr = 1:sym
    for lp = 1:96
        data_deinleaved((ii(lp)+1)) = rx_data(lp);   
    end
    rx_data = rx_data(97:end);
    data_final(96*cntr-95:96*cntr) = data_deinleaved(1:96);
end

%% Integration  
 deinleaved = [sig_deinleaved data_final];   
 fid = fopen('deinterleaved12.txt','wt');
 fprintf(fid,'%d\n',deinleaved);
 fclose(fid);

