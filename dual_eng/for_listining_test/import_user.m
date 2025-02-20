function [index,id,sex,age,school,parent,spend,teach,ip] = import_user(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [INDEX,ID,SEX,AGE,SCHOOL,PARENT,SPEND,TEACH,IP] = IMPORTFILE(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   [INDEX,ID,SEX,AGE,SCHOOL,PARENT,SPEND,TEACH,IP] = IMPORTFILE(FILENAME,
%   STARTROW, ENDROW) Reads data from rows STARTROW through ENDROW of text
%   file FILENAME.
%
% Example:
%   [index,id,sex,age,school,parent,spend,teach,ip] = importfile('user.csv',2, 26);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/10/31 19:25:50

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%q)
%   column3: text (%q)
%	column4: double (%f)
%   column5: text (%q)
%	column6: text (%q)
%   column7: text (%q)
%	column8: text (%q)
%   column9: text (%q)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%q%q%f%q%q%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
index = dataArray{:, 1};
id = dataArray{:, 2};
sex = dataArray{:, 3};
age = dataArray{:, 4};
school = dataArray{:, 5};
parent = dataArray{:, 6};
spend = dataArray{:, 7};
teach = dataArray{:, 8};
ip = dataArray{:, 9};


