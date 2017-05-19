
%% Master script for analysing the WBAT data
clear
close all
% Data directories
d0 = 'D:\DATA\cruise_data';
file{1} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT\LSSS\Reports\ListUserFile04__F200000_T1_L0.0-0.0_HERR.txt');
file{2} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT70kHz\LSSS\Reports\ListUserFile04__F70000_T1_L0.0-0.0_HERR.txt');

%% Import data
[dat,sa] = REDUStokt_importluf4(file{1});

%% Import pos files
metadata_file='D:\DATA\cruise_data\2017\S2017836_PVendla[3670]\CRUISE_LOG\S2017836_metadata.xlsx';
[tableout,wbat,time] = REDUStokt_readmetadata(metadata_file);

%% Depth table for WBAT deployment (read from the echo sounder files)
depth_table =[datenum(2017,05,14,19,30,00) 58.5;...
    datenum(2017,05,14,23,15,00) 69.5;...
    datenum(2017,05,15,18,40,00) 69.5;...
    datenum(2017,05,16,19,30,00) 58.5];


depth = (1:s(1))*5-2.5;

%% Plot the results
figure
%imagesc(10*log10(sa))
imagesc(sa)

figure
plot(depth(end:-1:1),mean(sa,2))
