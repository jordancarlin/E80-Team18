% % logreader.m
% % Use this script to read data from your micro SD card
% 
% clear;
% %clf;
% 
% filenum = '003'; % file number for the data you want to read
% infofile = strcat('INF', filenum, '.TXT');
% datafile = strcat('LOG', filenum, '.BIN');
% 
% %% map from datatype to length in bytes
% dataSizes.('float') = 4;
% dataSizes.('ulong') = 4;
% dataSizes.('int') = 4;
% dataSizes.('int32') = 4;
% dataSizes.('uint8') = 1;
% dataSizes.('uint16') = 2;
% dataSizes.('char') = 1;
% dataSizes.('bool') = 1;
% 
% %% read from info file to get log file structure
% fileID = fopen(infofile);
% items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
% fclose(fileID);
% [ncols,~] = size(items{1});
% ncols = ncols/2;
% varNames = items{1}(1:ncols)';
% varTypes = items{1}(ncols+1:end)';
% varLengths = zeros(size(varTypes));
% colLength = 256;
% for i = 1:numel(varTypes)
%     varLengths(i) = dataSizes.(varTypes{i});
% end
% R = cell(1,numel(varNames));
% 
% %% read column-by-column from datafile
% fid = fopen(datafile,'rb');
% for i=1:numel(varTypes)
%     %# seek to the first field of the first record
%     fseek(fid, sum(varLengths(1:i-1)), 'bof');
% 
%     %# % read column with specified format, skipping required number of bytes
%     R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
%     eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
% end
% fclose(fid);


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
dt = 0.099; % The sampling rate
t = 0:dt:20; % The time array
Y = 0; % The modeled acceleration
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration
ry = 0; % Integrate the true velocity to get the true position.
Yn = [0,1,2,4,8,2,4,7,0,3,6,89,2,4,8,9,4,1,5,8,8]%accelY; % Generate measured acceleration
vny = cumtrapz(t,Yn); % Integrate the measured acceleration to get the velocity
vnpy = vny + plusie; % Velocity plus confidence bound
vnmy = vny - plusie; % Velocity minus confidence bound
rny = cumtrapz(t,vny); % Integrate the velocity to get the position
rnpy = rny + plusiie; % Position plus confidence bound
rnmy = rny - plusiie; % Position minus confidence bound

plot(t, rny, t, rnpy,'-.', t, rnmy,'-.')
xlabel('Time (s)')
ylabel('Y Position')
title('Calculated Position from Measured Acceleration in Y direction')
legend('True Position','Calculated Position','Upper Confidence Bound',...
    'Lower Confidence Bound','location','southeast')
% 
% %%% Second integration for x-direction
% %% Accel Demo
% % This file simulates a 1-D acceleration measured by an accelerometer with
% % noise. It cacluates the true acceleration, velocity and position, and
% % then adds gaussian white noise to the true acceleration to generate the
% % simulated measured acceleration. It then integrates the measured
% % acceleration once to get calculated velocity, and then a second time to
% % get calculated position. It calculates the error bounds for the position
% % and velocity based on the standard deviation of the sensor and the
% % specified confidence level.
% dt = 0.099; % The sampling rate
% t = 0:dt:10; % The time array
% X = accelX; % The modeled acceleration
% lX = length(X);
% lX2 = round(length(X)/5);
% Y([la2:end]) = 0; % We only want one cycle of the sine wave.
% sigma = .2; % The standard deviation of the noise in the accel.
% confLev = 0.95; % The confidence level for bounds
% preie = sqrt(2)*erfinv(confLev)*sigma*sqrt(dt); % the prefix to the sqrt(t)
% preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
% plusie=preie*t.^0.5; % The positive noise bound for one integration
% plusiie = preiie*t.^1.5; % The positive noise bound for double integration
% vx = cumtrapz(t,X); % Integrate the true acceleration to get the true velocity
% rx = cumtrapz(t,vx); % Integrate the true velocity to get the true position.
% Xn = accelX; % Generate measured acceleration
% vnx = cumtrapz(t,Xn); % Integrate the measured acceleration to get the velocity
% vnpx = vnx + plusie; % Velocity plus confidence bound
% vnmx = vnx - plusie; % Velocity minus confidence bound
% rnx = cumtrapz(t,vnx); % Integrate the velocity to get the position
% rnpx = rnx + plusiie; % Position plus confidence bound
% rnmx = rnx - plusiie; % Position minus confidence bound
% 
% 
% %ideal function overlay
% x5 = 0:0.1:0.5;
% y5 = 0;
% z5 = 0;
% 
% %plotting of the x,y coordinates of board stack overlaid on ideal 0.5 m path
% plot (accelX, accelY, )
% xlabel('X coordinate')
% ylabel('Y coordinate')
% title('Measured x,y coordinates overlaid on ideal 0.5 m path')
% legend('Measured Position','Ideal Positon','location','southeast')
% 
% 
% 
% 
