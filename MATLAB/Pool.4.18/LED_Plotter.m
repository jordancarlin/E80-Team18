% LED_Plotter.m
clear all;
figure(1)
clf

%% Resistor Values
IRPhotoResistance = 185.6e3;
yellowResistance = 2.225e6;
greenResistance = 1.61e6;
visibleResistance = 1.431e3;
IRLEDResistance = 10.03e3;
redResistance = 218.5e3;

%% Setup
filenum = '033'; % file number for the data you want to read
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

%% Testing Data
% z = 1:1:length(z);
% 
% val00 = 100;
% val02 = 500;
% val03 = 300;
% val10 = 200;
% val11 = 600;
% val12 = 400;
% 
% for i=1:length(A00)
%     A00(i) = val00;
%     A02(i) = val02;
%     A03(i) = val03;
%     A10(i) = val10;
%     A11(i) = val11;
%     A12(i) = val12;
%     if mod(i, 5) == 0 & val00 > 0
%         val00 = val00 - 5;
%     end
%     if mod(i, 3) == 0  & val02 > 0
%         val02 = val02 - 5;
%     end
%     if mod(i, 2) == 0 & val03 > 0
%         val03 = val03 - 4;
%     end
%     if mod(i, 6) == 0 & val10 > 0
%         val10 = val10 - 5;
%     end
% 
%     if mod(i, 4) == 0 & val11 > 0
%         val11 = val11 - 12;
%     end
%     if mod(i, 9) == 0 & val12 > 0
%         val12 = val12 - 10;
%     end
% end

%% Convert data to voltages
IRPhotoVoltage = cast(A00, "double")*(3.3/1023);
yellowVoltage = cast(A02, "double")*(3.3/1023);
greenVoltage = cast(A03, "double")*(3.3/1023);
visibleVoltage = cast(A10, "double")*(3.3/1023);
IRLEDVoltage = cast(A11, "double")*(3.3/1023);
redVoltage = cast(A12, "double")*(3.3/1023);

%% Plot voltages
% subplot(3,1,1);
hold on
% plot(z, redVoltage, "r*")
% plot(z, yellowVoltage, "*", Color="#EDB120")
% plot(z, greenVoltage, "g*")
% plot(z, visibleVoltage, "b*")
% plot(z, IRLEDVoltage, "c*")
plot(z, IRPhotoVoltage, "m*")
hold off
xlabel("Depth [m]", FontSize=16);
ylabel("Voltage [V]", FontSize=16);
title("Voltage vs Depth", FontSize=20);
% legend("Red LED Voltage", "Yellow LED Voltage", "Green LED Voltage", ...
%     "Visible Photodiode Voltage", "IR LED Voltage", "IR Photodiode Voltage", ...
%     fontsize=12);
axis tight

% %% Convert voltages to currents
% IRPhotoCurrent = IRPhotoVoltage/IRPhotoResistance;
% yellowCurrent = yellowVoltage/yellowResistance;
% greenCurrent = greenVoltage/greenResistance;
% visibleCurrent = visibleVoltage/visibleResistance;
% IRLEDCurrent = IRLEDVoltage/IRLEDResistance;
% redCurrent = redVoltage/redResistance;

% %% Plot currents
% subplot(3,1,2);
% hold on
% plot(z, redCurrent, "r*")
% plot(z, yellowCurrent, "*", Color="#EDB120")
% plot(z, greenCurrent, "g*")
% plot(z, visibleCurrent, "b*")
% plot(z, IRLEDCurrent, "c*")
% plot(z, IRPhotoCurrent, "m*")
% hold off
% xlabel("Depth [m]", FontSize=16);
% ylabel("Current [A]", FontSize=16);
% title("Current vs Depth", FontSize=20);
% % legend("Red LED Current", "Yellow LED Current", "Green LED Current", ...
% %     "Visible Photodiode Current", "IR LED Current", "IR Photodiode Current", ...
% %     fontsize=12);
% axis tight

% %% Normalize currents
% IRPhotoCurrentNorm = IRPhotoCurrent/max(IRPhotoCurrent);
% yellowCurrentNorm = yellowCurrent/max(yellowCurrent);
% greenCurrentNorm = greenCurrent/max(greenCurrent);
% visibleCurrentNorm = visibleCurrent/max(visibleCurrent);
% IRLEDCurrentNorm = IRLEDCurrent/max(IRLEDCurrent);
% redCurrentNorm = redCurrent/max(redCurrent);

% %% Plot normalized currents
% subplot(3,1,3);
% hold on
% plot(z, redCurrentNorm, "r*")
% plot(z, yellowCurrentNorm, "*", Color="#EDB120")
% plot(z, greenCurrentNorm, "g*")
% plot(z, visibleCurrentNorm, "b*")
% plot(z, IRLEDCurrentNorm, "c*")
% plot(z, IRPhotoCurrentNorm, "m*")
% hold off
% xlabel("Depth [m]", FontSize=16);
% ylabel("Normalized Current Relative to Max", FontSize=16);
% title("Normalized Current vs Depth", FontSize=20);
% legend("Red LED Current", "Yellow LED Current", "Green LED Current", ...
%     "Visible Photodiode Current", "IR LED Current", "IR Photodiode Current", ...
%     'Position',[0.836049968900604 0.857068811310621 0.145490196078431 0.12002567394095], fontsize=12);
% axis tight


