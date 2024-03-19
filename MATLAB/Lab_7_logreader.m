% logreader.m
% Use this script to read data from your micro SD card

clear;
clf;

filenum = '003'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
dataSizes.('float') = 4
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


% Process your data here
%% First integration for y-direction
% specified confidence level.
dt = 0.099; % The sampling rate
t = 0:dt:20; % The time array
Y = 0; % The modeled acceleration
sigma = .2; % The standard deviation of the noise in the accel.
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration
ry = 0; % Integrate the true velocity to get the true position.
Yn = accelY; % Generate measured acceleration
vny = cumtrapz(t,Yn); % Integrate the measured acceleration to get the velocity
vnpy = vny + plusie; % Velocity plus confidence bound
vnmy = vny - plusie; % Velocity minus confidence bound
rny = cumtrapz(t,vny); % Integrate the velocity to get the position
rnpy = rny + plusiie; % Position plus confidence bound
rnmy = rny - plusiie; % Position minus confidence bound

figure(1);
plot(t, rny, t, rnpy,'-.', t, rnmy,'-.')
xlabel('Time [s]')
ylabel('Y Position [m]')
title('Calculated Position from Measured Acceleration in Y direction')
legend('Y Position','Upper Confidence Bound',...
    'Lower Confidence Bound','location','southeast')

%% Second integration for x-direction
Xn = accelX; % The measured acceleration
vnx = cumtrapz(t,Xn); % Integrate the measured acceleration to get the velocity
% vnpx = vnx + plusie; % Velocity plus confidence bound
% vnmx = vnx - plusie; % Velocity minus confidence bound
rnx = cumtrapz(t,vnx); % Integrate the velocity to get the position
% rnpx = rnx + plusiie; % Position plus confidence bound
% rnmx = rnx - plusiie; % Position minus confidence bound


%ideal function overlay
x5 = linspace(0, 0.5, length(rnx));
y5 = zeros(length(x5));


%plotting of the x,y coordinates of board stack overlaid on ideal 0.5 m path
figure(2);
plot(rnx, rny, x5, y5, LineWidth=2);
xlabel('X coordinate [m]')
ylabel('Y coordinate [m]')
title('Measured x,y coordinates overlaid on ideal 0.5 m path')
legend('Measured Position','Ideal Positon','location','southeast')




