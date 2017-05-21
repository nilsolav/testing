function [tableout,deployment,time] = REDUStokt_readmetadata(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   DATA = IMPORTFILE(FILE) reads data from the first worksheet in the
%   Microsoft Excel spreadsheet file named FILE and returns the data as a
%   table.
%
%   DATA = IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   S2017836metadata = importfile('S2017836_metadata.xlsx','Sheet1',2,123);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2017/05/19 07:10:05

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 195;
end

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:AF%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:AF%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
stringVectors = string(raw(:,[1,7,8,22,24,26,31]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,23,25,27,28,29,30]);
dates = dates(:,2);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),dates); % Find non-numeric cells
dates(R) = {NaN}; % Replace non-numeric Excel dates with NaN

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% Create table
tableout = table;

%% Allocate imported array to column variable names
tableout.Stationtype = categorical(stringVectors(:,1));
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
tableout.Date = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
tableout.Time = data(:,1);
tableout.Refno = data(:,2);
tableout.LocStno = data(:,3);
tableout.Log = data(:,4);
tableout.Latitude = stringVectors(:,2);
tableout.Longitude = stringVectors(:,3);
tableout.Depth = data(:,5);
tableout.Heading = data(:,6);
tableout.Speed = data(:,7);
tableout.Watertemp = data(:,8);
tableout.Wind = data(:,9);
tableout.Winddir = data(:,10);
tableout.Airtemp = data(:,11);
tableout.Airpressure = data(:,12);
tableout.Humidity = data(:,13);
tableout.Weather = data(:,14);
tableout.Seastate = data(:,15);
tableout.Clouds = data(:,16);
tableout.Ice = data(:,17);
tableout.Quantity = stringVectors(:,4);
tableout.Code = data(:,18);
tableout.Number = stringVectors(:,5);
tableout.Serialno = data(:,19);
tableout.Wirelength = stringVectors(:,6);
tableout.Mindepth = data(:,20);
tableout.Maxdepth = data(:,21);
tableout.Opening = data(:,22);
tableout.Spread = data(:,23);
tableout.Comment = stringVectors(:,7);
%tableout.VarName32 = stringVectors(:,8);

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

time = datenum(tableout.Date)+tableout.Time;
% parse the comment line

for i=1:size(tableout,1)
    lat(i)=str2num(tableout.Latitude{i}(1:2))+str2num(tableout.Latitude{i}(3:end-2))/60;
    lon(i)=str2num(tableout.Longitude{i}(1:2))+str2num(tableout.Longitude{i}(3:end-2))/60;
end

%% Get timing for Sindre's roses
for i=1:length(tableout.Comment)
    str=tableout.Comment{i};
    expression = 'utsetting';
    ind(i).utsetting = ~isempty(regexp(str,expression));
    expression = 'start';
    ind(i).start = ~isempty(regexp(str,expression));
    expression = 'stop';
    ind(i).stop = ~isempty(regexp(str,expression));
    expression = 'passering';
    ind(i).passering = ~isempty(regexp(str,expression));
    mstr = '.+(\d+).+ (\d+)';
    passtransekt = regexp(str,mstr,'tokens');
    if ~isempty(passtransekt)
        ind(i).deployment = str2num(passtransekt{1}{1});
        ind(i).transect = str2num(passtransekt{1}{2});
        if ind(i).start
            deployment(ind(i).deployment).deployment = ind(i).deployment;
            deployment(ind(i).deployment).transect(ind(i).transect).transect = ind(i).transect;
            deployment(ind(i).deployment).transect(ind(i).transect).start.time = time(i);
            deployment(ind(i).deployment).transect(ind(i).transect).start.lat = lat(i);
            deployment(ind(i).deployment).transect(ind(i).transect).start.lon = lon(i);
        elseif ind(i).stop
            deployment(ind(i).deployment).transect(ind(i).transect).stop.time = time(i);
            deployment(ind(i).deployment).transect(ind(i).transect).stop.lat = lat(i);
            deployment(ind(i).deployment).transect(ind(i).transect).stop.lon = lon(i);
        elseif ind(i).passering
            deployment(ind(i).deployment).transect(ind(i).transect).passing.time = time(i);
            deployment(ind(i).deployment).transect(ind(i).transect).passing.lat = lat(i);
            deployment(ind(i).deployment).transect(ind(i).transect).passing.lon = lon(i);
        end
    end
end

%% Get timing for Shales's circles
for i=1:length(tableout.Comment)
    str=tableout.Comment{i};
    expression = 'Shalecircle';
    ind2(i).shalecircle = ~isempty(regexp(str,expression, 'once'));
    expression = 'opptak';
    ind2(i).opptak = ~isempty(regexp(str,expression, 'once'));
    expression = 'utsetting';
    ind2(i).utsetting = ~isempty(regexp(str,expression, 'once'));
    
    mstr = '.+(\d+)';
    shalecirclenum = regexp(str,mstr,'tokens');
    
    if ~isempty(shalecirclenum)&&ind2(i).shalecircle
        ind2(i).deployment = str2num(shalecirclenum{1}{1});
        if ind2(i).opptak
            deployment(ind2(i).deployment).transect(1).deployment = ind2(i).deployment;
            deployment(ind2(i).deployment).transect(1).stop.time = time(i);
            deployment(ind2(i).deployment).transect(1).stop.lat = lat(i);
            deployment(ind2(i).deployment).transect(1).stop.lon = lon(i);
        elseif ind(i).utsetting
            deployment(ind2(i).deployment).transect(1).start.time = time(i);
            deployment(ind2(i).deployment).transect(1).start.lat = lat(i);
            deployment(ind2(i).deployment).transect(1).start.lon = lon(i);
        end
    end
end

%% Get timing for transects


