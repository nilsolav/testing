%% TODO liste
% - Korriger for frekvensrespons
% - Lag finare figurar
% - Korriger til 4 milsmiddel før og etter for Shale's circles
%

%% Master script for analysing Sindre's roses data

clear
clc
close all
% Data directories
d0 = 'D:\DATA\cruise_data';

% Vendla toktet
file{1} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OBSERVATION_PLATFORMS\WBAT\LSSS\Reports\ListUserFile04__F200000_T1_L0.0-0.0_HERR.txt');
file{2} = fullfile(d0,'\2017\S2017836_PVendla[3670]\OBSERVATION_PLATFORMS\WBAT70kHz\LSSS\Reports\ListUserFile04__F070000_T1_L0.0-0.0_HERR.txt');
%file{3} = fullfile(d0,'\2017\S2017836_PVendla[3670]\ACOUSTIC_DATA\LSSS\Reports\ListUserFile04__F070000_T1_L3729.7-5099.0_HERR.txt');
file{4} = fullfile(d0,'\2017\S2017836_PVendla[3670]\ACOUSTIC_DATA\LSSS\Reports\ListUserFile04__F038000_T2_L3729.7-5300.0_HERR.txt');

% Kings Bay toktet
%file{5} = fullfile(d0,'\2016\S2016844_PKINGSBAY_3223\ACOUSTIC_DATA\LSSS\S1_PKings Bay[2142]\Reports\ListUserFile04__F038000_T2_L176.6-1504.9_SILD.txt');

file{5} = fullfile(d0,'\2016\S2016844_PKINGSBAY_3223\ACOUSTIC_DATA\LSSS\S1_PKings Bay[2142]\Reports\ListUserFile20__L176.6-248.1.txt');

%%
[sa_tmp]=LSSSreader_readluf20(file{5})


%% Import data
% Import wbat sa data
% 200kHz
[sa{1}.dat,sa{1}.sa,sa{1}.time] = REDUStokt_importluf4(file{1});
% 70 kHz
[sa{2}.dat,sa{2}.sa,sa{2}.time] = REDUStokt_importluf4(file{2});

% Import Vendla sa data
% 70 kHz
%[sa{3}.dat,sa{3}.sa,sa{3}.time] = REDUStokt_importluf4(file{3});
%38kHz
[sa{4}.dat,sa{4}.sa,sa{4}.time] = REDUStokt_importluf4(file{4});

% Import Kings Bay data
[sa{5}.dat,sa{5}.sa,sa{5}.time] = REDUStokt_importluf4(file{5});


%% Import metadata files
[metadata,wbat2016,wbat2017] = REDUStokt_readmetadata;

%%
fid = fopen('metadata.csv', 'w') ;
formatSpec = '%u;%u;%u;%s;%s;%3.1f\n';
fprintf(fid,'%s;',metadata{1,1:end-1})
fprintf(fid,'%s\n',metadata{1,end})
[nrows,ncols] = size(metadata);
for row = 2:nrows
    fprintf(fid,formatSpec,metadata{row,:});
end
fclose(fid) ;

%%
csvwrite('metadata.csv',metadata)



%% Get the WBAT and vessel profile per transect for the star experiment (and remove the Vendla passing times)

wbat = REDUStokt_depthdistributions(wbat,sa{1},depth_table,2:3,'wbat');
wbat = REDUStokt_depthdistributions(wbat,sa{2},depth_table,4:10,'wbat');
wbat = REDUStokt_depthdistributions(wbat,sa{4},depth_table,2:4,'vessel');
% Add the sa depth distribution before and after the wbat data deployment
% (for Shale's cirlces)
wbat = REDUStokt_depthdistributions(wbat,sa{4},depth_table,5:10,'vesselbeforeafter');

%% Test if the depths are ok
% for m=1:length(wbat)
%     for k=1:length(wbat(m).transect)
%         [wbat(m).transect(k).wbat.depth' wbat(m).transect(k).wbat.sabydepth]
%         disp(num2str([i k]))
%         pause
%     end
% end

%% Plot the results

%% The 200kHz results - Sindre's roses
% Conversion from 70kHz -> 38kHz and 200kHz -> 38kHz.

close all
figure
col={'r','r','r','r','c','c','c'};
%col={[.5 .5 .5],[.5 .5 .5],[.5 .5 .5],[.5 .5 .5],'r','b','r','g','c','c','c'};

for i=2:4
    subplot(1,3,i-1)
    hold on
    trdepth =[];
    for j=1:length(wbat(i).transect)
        % Wbat data
        plot(wbat(i).transect(j).wbat.sabydepth,wbat(i).transect(j).wbat.depth,'Color',col{i})
        % Vessel data
        plot(wbat(i).transect(j).vessel.sabydepth,wbat(i).transect(j).vessel.depth,'k')
        [~,nils]=max(wbat(i).transect(j).wbat.sabydepth);
        %        text(wbat(i).transect(j).wbat.sabydepth(nils),wbat(i).transect(j).wbat.depth(nils),num2str(j))
        trdepth = [trdepth wbat(i).transect(j).wbat.transducerdepth];
    end
    % Plot the transducer dpeth
    l=xlim;
    plot([l(1) l(2)], [-min(trdepth) -min(trdepth)],'g')
    % Metadata
    title(['Sindre''s Rose ',num2str(i-1)])
    xlabel('sa (m^2nmi^{-2})')
    ylabel('depth')
    ylim([-100 10])
end
print('SindresRoses.png','-dpng')
% subplot(2,2,1)
% title('Mean')
% xlabel('sa (m^2nmi^{-2})')
% ylabel('depth')

%% Shale's circles

% Plot before/after from vessel acoustics

figure
col={'r','b','r','g','c','c','c'};

for i=5:10
    k=i-4;
    subplot(2,3,k)
    hold on
    trdepth=[];
    for j=1:length(wbat(i).transect)
        % Wbat data
        plot(wbat(i).transect(j).wbat.sabydepth,wbat(i).transect(j).wbat.depth,'k')
        % Vessel data
        sa1 = wbat(i).transect(j).vesselbeforeafter.before.sabydepth;
        sa2 = wbat(i).transect(j).vesselbeforeafter.after.sabydepth;
        sad = wbat(i).transect(j).vesselbeforeafter.depth;
        plot(sa1,sad,'b',sa2,sad,'r')
        trdepth = [trdepth wbat(i).transect(j).wbat.transducerdepth];
    end
    % Plot the transducer dpeth
    l=xlim;
    plot([l(1) l(2)], [-min(trdepth) -min(trdepth)],'g')
    
    % Metadata
    title(['Shale''s triangle',num2str(i-4)])
    xlabel('sa (m^2nmi^{-2})')
    ylabel('depth')
    ylim([-100 10])
end
%title('Mean')
xlabel('sa (m^2nmi^{-2})')
ylabel('depth')

print('ShalesTriangles.png','-dpng')
