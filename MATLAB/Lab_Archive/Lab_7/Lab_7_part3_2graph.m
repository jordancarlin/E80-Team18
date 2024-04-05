% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '019'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

%% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

%% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%ind = length(accelX);
%depth = data(1:ind, col_num); % Replace col_num with corresponding number
%depth_des = data(1:ind, col_num); 
%uV = data(1:ind, col_num);
dt = 0.99;
time = 0:dt:dt*length(depth)-dt; % Example time vector

% Plot depth and depth_des vs. time
figure;
subplot(2,1,1)
plot(time, depth, 'b', LineWidth= 1.5);
hold on
plot(time, depth_des, 'r--', LineWidth= 1.5);
xlabel('Time [s]');
ylabel('Depth [m]');
legend('Depth', 'Depth\_des', 'Location', 'best');
title('Depth and Depth\_des vs. Time');
axis tight;

% Plot uV vs. time as a subplot
subplot(2,1,2);
plot(time, uV, 'g', LineWidth= 1.5);
xlabel('Time [s]');
ylabel('uV [uV units]');
title('uV vs. Time');
axis tight;