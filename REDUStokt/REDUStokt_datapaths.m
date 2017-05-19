%% Script to point at the data and paths for the two REDUS survyes

% Main data directory
d.d0 = 'D:\DATA\cruise_data';

% Path to survey data
d.survey(1).name = 'S2016844_PKINGSBAY_3223';
d.survey(2).name = 'S2017836_PVENDLA_xxxx';

d.survey(1).path = '\2016\S2016844_PKINGSBAY_3223';
d.survey(2).path = '\2017\S2017836_PVENDLA_xxxx';

%% Data directories
% EK60 vessel data
d.path(1).dir = '\ACOUSTIC_DATA\EK60\EK60_RAWDATA';
d.path(1).name = 'EK60';
d.path(1).file = '*.raw';

% LSSS vessel data
d.path(2).dir = '\ACOUSTIC_DATA\EK60\LSSS';
d.path(2).name = 'EK60_lsss';
d.path(2).file = '*.lsss';

% LSSS vessel report data
d.path(3).dir = '\ACOUSTIC_DATA\EK60\LSSS\report';
d.path(3).name = 'EK60_lsss_reports';
d.path(3).file = '*.xml';

% Paths to WBAT data
d.path(4).dir = '\OBSERVATION_PLATFORMS\WBAT_BUOY';
d.path(4).name = 'WbatEK80';
d.path(4).file = '*.raw';

% Path to WBAT lsss data
d.path(5).dir = '\OBSERVATION_PLATFORMS\WBAT_BUOY\LSSS';
d.path(5).name = 'WbatEK80_lsss';
d.path(5).file = '*.lsss';

% Path to WBAT LSSS reports
d.path(6).dir = '\OBSERVATION_PLATFORMS\WBAT_BUOY\LSSS\report';
d.path(6).name = 'wbatEK80_lsss_reports';
d.path(6).file = '*.xml';

% Path to pos files
d.path(7).dir = '\xx';
d.path(7).name = 'toktlogger pos filer';
d.path(7).file = '*.pos';

% Path to pos files
d.path(8).dir = '\xx';
d.path(8).name = 'toktlogger ref filer';
d.path(8).file = '*.ref';

%% Test if files are present
for s=2%1:2
    dr = fullfile(d.d0,d.survey(s).path);
    if ~exist(dr)
        disp([dr,' does not exist'])
    end
    for i=1:length(d.path)
        dr2 = fullfile(dr,d.path(i).dir);
        file=fullfile(dr2,d.path(i).file);
        if ~exist(dr2)
            disp([dr2,' does not exist'])
            if ~exist(file)
                disp([file,' does not exist'])
            end
        end
    end
end



%

