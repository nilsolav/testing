%% Master script for analysing the WBAT data
clear
clc
close all
% Data directories
d0 = 'D:\DATA\cruise_data';
file{1} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT\LSSS\Reports\ListUserFile04__F200000_T1_L0.0-0.0_HERR.txt');
file{2} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT70kHz\LSSS\Reports\ListUserFile04__F070000_T1_L0.0-0.0_HERR.txt');
file{3} = fullfile(d0,'\2017\S2017836_PVendla[3670]\ACOUSTIC_DATA\LSSS\Reports\1_ListUserFile04__F070000_T1_L3729.7-0.0_HERR.txt');
file{4} = fullfile(d0,'\2017\S2017836_PVendla[3670]\ACOUSTIC_DATA\LSSS\Reports\1_ListUserFile04__F038000_T2_L3729.7-0.0_HERR.txt');

%% Import data
% Import wbat sa data
% 200kHz
[sa{1}.dat,sa{1}.sa,sa{1}.time] = REDUStokt_importluf4(file{1});
% 70 kHz
[sa{2}.dat,sa{2}.sa,sa{2}.time] = REDUStokt_importluf4(file{2});

% Import Vendla sa data
% 70 kHz
[sa{3}.dat,sa{3}.sa,sa{3}.time] = REDUStokt_importluf4(file{3});
%38kHz
[sa{4}.dat,sa{4}.sa,sa{4}.time] = REDUStokt_importluf4(file{4});

%% Import metadata files
metadata_file='D:\DATA\cruise_data\2017\S2017836_PVendla[3670]\CRUISE_LOG\S2017836_metadata.xlsx';
[~,wbat,~] = REDUStokt_readmetadata(metadata_file);

%% Depth table for WBAT deployments (taken from the echo sounder files)
depth_table =[datenum(2017,05,14,19,30,00) 58.5;...
    datenum(2017,05,14,23,15,00) 69.5;...
    datenum(2017,05,15,18,40,00) 69.5;...
    datenum(2017,05,16,19,30,00) 58.5];

%% Get the WBAT and vessel profile per transect for the star experiment (and remove the Vendla passing times)
wbat = REDUStokt_depthdistributions(wbat,sa{1},depth_table,2:3);
wbat = REDUStokt_depthdistributions(wbat,sa{2},depth_table,4:7);

%wbat = REDUStokt_depthdistributions(wbat,sa{2},depth_table,5:7);

%% Plot the WBAT star transects
close all
figure
col={'r','b','r','g','c','c','c'};

for i=2:7%length(wbat)
    meansa=[];
    hold on
    for j=1:length(wbat(i).transect)
        plot(wbat(i).transect(j).wbat.sabydepth,wbat(i).transect(j).wbat.depth,col{i})
        wbat(i).transect(j).wbat.sabydepth
        meansa = [meansa wbat(i).transect(j).wbat.sabydepth];
        [~,nils]=max(wbat(i).transect(j).wbat.sabydepth);
        if i<5
            text(wbat(i).transect(j).wbat.sabydepth(nils),wbat(i).transect(j).wbat.depth(nils),num2str(j))
        else
            text(wbat(i).transect(j).wbat.sabydepth(nils),wbat(i).transect(j).wbat.depth(nils),num2str(i))
        end
    end
    plot(nanmean(meansa,2),wbat(i).transect(j).wbat.depth,col{i},'LineWidth',2)
end
title('Blå=utsetting 2, Raud=utsetting 3, green=utsetting 4')

%% Get the Vendla profile per Star transect

for i=1:length(wbat)
    for j=1:length(wbat(i).transect)
        t0 = [wbat(i).transect(j).start wbat(i).transect(j).start];
        % Vessel depth vector
        wbat(i).transect(j).vessel.depth = 1;
        
        % Vessel sa values by depth
        wbat(i).transect(j).vessel.sabydepth = mean(dum,2);
    end
end
%% Get the wbat profile for Shale's circles



%% Get the Vendla profile for Shale's circles (during trawling!)

%% Get the Vendla profiles for the transect (per unit distance east/west)

%% Plot the results
figure
%imagesc(10*log10(sa))
imagesc(sa)

figure
plot(mean(sa,2))
