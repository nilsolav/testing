
%% Master script for analysing the WBAT data
clear
close all
% Data directories
d0 = 'D:\DATA\cruise_data';
file{1} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT\LSSS\Reports\ListUserFile04__F200000_T1_L0.0-0.0_HERR.txt');
file{2} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OTHER_PLATFORMS\WBAT70kHz\LSSS\Reports\ListUserFile04__F70000_T1_L0.0-0.0_HERR.txt');

%% Import data
% Import sa data
[sa.dat,sa.sa,sa.time] = REDUStokt_importluf4(file{1});
% Import pos files
metadata_file='D:\DATA\cruise_data\2017\S2017836_PVendla[3670]\CRUISE_LOG\S2017836_metadata.xlsx';

[~,wbat,~] = REDUStokt_readmetadata(metadata_file);

%% Depth table for WBAT deployment (taken from the echo sounder files)
depth_table =[datenum(2017,05,14,19,30,00) 58.5;...
    datenum(2017,05,14,23,15,00) 69.5;...
    datenum(2017,05,15,18,40,00) 69.5;...
    datenum(2017,05,16,19,30,00) 58.5];

%% Get the WBAT and vessel profile per transect for the star experiment (and remove the Vendla passing times)
s=size(sa.sa);
for i=2:length(wbat)
    for j=1:length(wbat(i).transect)
        t0 = [wbat(i).transect(j).start.time wbat(i).transect(j).stop.time];
        % Average time as time stamp
        wbat(i).transect(j).avgtime = .5*(wbat(i).transect(j).stop.time+wbat(i).transect(j).start.time);
        wbat(i).transect(j).avglat = .5*(wbat(i).transect(j).stop.lat+wbat(i).transect(j).start.lat);
        wbat(i).transect(j).avglon = .5*(wbat(i).transect(j).stop.lon+wbat(i).transect(j).start.lon);
        % wbat depth vector
        
        % Find depth of the transducer (channnel 1 = øverst i LSSS =
        % nederst i vannsøyla)
        %        depth_table(:,1)>t0(1)
        dpth=depth_table(find(depth_table(:,1)<t0(1),1, 'last' ),2);
        wbat(i).transect(j).wbat.depth = -(dpth - (1:s(1))*5);
        %disp(wbat(i).transect(j).wbat.depth )
        % Wbat sa values by depth
        warning('Remove passings!')
        tind = (t0(1)<sa.time.datenum)&(t0(2)>sa.time.datenum);
        dum = sa.sa(:,tind);
        wbat(i).transect(j).wbat.sabydepth = mean(dum,2);
    end
end
%% Plot the WBAT star transects

close all
figure

col={'r','b','g'};

for i=2:length(wbat)
    hold on
    for j=1:length(wbat(i).transect)
        plot(wbat(i).transect(j).wbat.sabydepth,wbat(i).transect(j).wbat.depth,col{i})
    end
end

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
