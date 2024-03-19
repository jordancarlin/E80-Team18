% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '003'; % file number for the data you want to read
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

%% Process your data here
%%% First integration for y-direction
%% Accel Demo
% This file simulates a 1-D acceleration measured by an accelerometer with
% noise. It cacluates the true acceleration, velocity and position, and
% then adds gaussian white noise to the true acceleration to generate the
% simulated measured acceleration. It then integrates the measured
% acceleration once to get calculated velocity, and then a second time to
% get calculated position. It calculates the error bounds for the position
% and velocity based on the standard deviation of the sensor and the
% specified confidence level.
dt = 0.01; % The sampling rate
t = 0:dt:10; % The time array
a = 1 + sin( pi*t -pi/2); % The modeled acceleration
la = length(a);
la2 = round(length(a)/5);
a([la2:end]) = 0; % We only want one cycle of the sine wave.
sigma = .2; % The standard deviation of the noise in the accel.
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration
v = cumtrapz(t,a); % Integrate the true acceleration to get the true velocity
r = cumtrapz(t,v); % Integrate the true velocity to get the true position.
an = accelY; % Generate measured acceleration
vn = cumtrapz(t,an); % Integrate the measured acceleration to get the velocity
vnp = vn + plusie; % Velocity plus confidence bound
vnm = vn - plusie; % Velocity minus confidence bound
rn = cumtrapz(t,vn); % Integrate the velocity to get the position
rnp = rn + plusiie; % Position plus confidence bound
rnm = rn - plusiie; % Position minus confidence bound

plot(t, r, t, rn, t, rnp,'-.', t, rnm,'-.')
xlabel('Time (s)')
ylabel('Position')
title('Calculated Position from Measured Acceleration')
legend('True Position','Calculated Position','Upper Confidence Bound',...
    'Lower Confidence Bound','location','southeast')

%%% Second integration for x-direction
%% Accel Demo
% This file simulates a 1-D acceleration measured by an accelerometer with
% noise. It cacluates the true acceleration, velocity and position, and
% then adds gaussian white noise to the true acceleration to generate the
% simulated measured acceleration. It then integrates the measured
% acceleration once to get calculated velocity, and then a second time to
% get calculated position. It calculates the error bounds for the position
% and velocity based on the standard deviation of the sensor and the
% specified confidence level.
dt = 0.01; % The sampling rate
t = 0:dt:10; % The time array
a = 1 + sin( pi*t -pi/2); % The modeled acceleration
la = length(a);
la2 = round(length(a)/5);
a([la2:end]) = 0; % We only want one cycle of the sine wave.
sigma = .2; % The standard deviation of the noise in the accel.
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration
v = cumtrapz(t,a); % Integrate the true acceleration to get the true velocity
r = cumtrapz(t,v); % Integrate the true velocity to get the true position.
an = accelX; % Generate measured acceleration
vn = cumtrapz(t,an); % Integrate the measured acceleration to get the velocity
vnp = vn + plusie; % Velocity plus confidence bound
vnm = vn - plusie; % Velocity minus confidence bound
rn = cumtrapz(t,vn); % Integrate the velocity to get the position
rnp = rn + plusiie; % Position plus confidence bound
rnm = rn - plusiie; % Position minus confidence bound

plot(t, r, t, rn, t, rnp,'-.', t, rnm,'-.')
xlabel('Time (s)')
ylabel('Position')
title('Calculated Position from Measured Acceleration')
legend('True Position','Calculated Positon','Upper Confidence Bound',...
    'Lower Confidence Bound','location','southeast')



