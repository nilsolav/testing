%% Master script for analysing Sindre's roses data

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
wbat = REDUStokt_depthdistributions(wbat,sa{1},depth_table,2:3,'wbat');
wbat = REDUStokt_depthdistributions(wbat,sa{2},depth_table,4:7,'wbat');

%wbat = REDUStokt_depthdistributions(wbat,sa{3},depth_table,2:3,'vessel');

wbat = REDUStokt_depthdistributions(wbat,sa{4},depth_table,2:7,'vessel');

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


%% Plot the results

%% The 200kHz results - Sindre's roses
% Conversion from 70kHz -> 38kHz and 200kHz -> 38kHz.

close all
figure
col={'r','b','r','g','c','c','c'};

for i=2:4
    meansa=[];
    subplot(2,2,i)
    hold on
    for j=1:length(wbat(i).transect)
        % Wbat data
        plot(wbat(i).transect(j).wbat.sabydepth,wbat(i).transect(j).wbat.depth,col{i})
        % Vessel data
        plot(wbat(i).transect(j).vessel.sabydepth,wbat(i).transect(j).vessel.depth,'k')
        
        meansa = [meansa wbat(i).transect(j).wbat.sabydepth];
        [~,nils]=max(wbat(i).transect(j).wbat.sabydepth);
            text(wbat(i).transect(j).wbat.sabydepth(nils),wbat(i).transect(j).wbat.depth(nils),num2str(j))
    end
    plot(nanmean(meansa,2),wbat(i).transect(j).wbat.depth,col{i},'LineWidth',2)
    % Metadata
    title(['Rose ',num2str(i-1)])
    xlabel('sa (m^2nmi^{-2})')
    ylabel('depth')
    ylim([-100 10])
    subplot(2,2,1)
    hold on
    plot(nanmean(meansa,2),wbat(i).transect(j).wbat.depth,col{i},'LineWidth',2)
end
    title('Mean')
    xlabel('sa (m^2nmi^{-2})')
    ylabel('depth')

