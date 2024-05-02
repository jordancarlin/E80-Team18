% LED_Plotter.m
% for files 000 and 001

clear all;
figure(1);
fs = 18;
clf

LEDColor = "#77AC30";
photoColor = "#6A44B1";

%% Resistor Values
IRPhotoResistance = 3.0214e6;
yellowResistance = 56.24e6;
greenResistance = 27.3335e6;
visibleResistance = 14.78e3;
IRLEDResistance = 79.68e3;
redResistance = 12.65e6;

%% Setup
filenum = '001'; % file number for the data you want to read
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

%% Convert data to voltages
IRPhotoVoltage = cast(A00, "double")*(3.3/1023);
IRLEDVoltage = cast(A11, "double")*(3.3/1023);

%% Only get data on the way down
[M, Imax] = max(z);
Imin = find(z >= 0, 1, 'first');
z = z(Imin:Imax);
IRPhotoVoltage = IRPhotoVoltage(Imin:Imax);
IRLEDVoltage = IRLEDVoltage(Imin:Imax);

%% Filter to only one point per depth
newZ = [];
newIRPhotoVoltage = [];
newIRLEDVoltage = [];

for i=1:length(z)
    if not(ismembertol(z(i), newZ, 0.00000))
        newZ(end+1) = z(i);
        newIRPhotoVoltage(end+1) = IRPhotoVoltage(i);
        newIRLEDVoltage(end+1) = IRLEDVoltage(i);
    else
        j = find(newZ == z(i));
        if newIRPhotoVoltage(j) < IRPhotoVoltage(i)
            newIRPhotoVoltage(j) = IRPhotoVoltage(i);
        end
        if newIRLEDVoltage(j) < IRLEDVoltage(i)
            newIRLEDVoltage(j) = IRLEDVoltage(i);
        end
    end
end

z=newZ;
IRPhotoVoltage = newIRPhotoVoltage;
IRLEDVoltage = newIRLEDVoltage;

%% Apply moving average
IRPhotoVoltage = movmean(IRPhotoVoltage, 5);
IRLEDVoltage = movmean(IRLEDVoltage, 5);

%% Stop when current reaches zero
IRPhotoVoltage = IRPhotoVoltage(1:find(IRPhotoVoltage <= 0.001, 1, "first"));
IRLEDVoltage = IRLEDVoltage(1:find(IRLEDVoltage <= 0.001, 1, "first"));

%% Convert voltages to currents
IRPhotoCurrent = (IRPhotoVoltage/IRPhotoResistance)*10^6;
IRLEDCurrent = (IRLEDVoltage/IRLEDResistance)*10^6;

%% Calculate IR photodiode irradiance using data sheet
IRPhotoIrradiance = (1/12.5)*IRPhotoCurrent;

%% Plot IR LED current vs irradiance from photodiode and find line of best fit
ah1 = gca;
minLen = max(length(IRPhotoIrradiance), length(IRPhotoCurrent));
[beta0, beta1] = regPlot(IRLEDCurrent(1:minLen), IRPhotoIrradiance(1:minLen), LEDColor);
xlabel("IR LED Current [µA]")
ylabel("IR Irradiance [mW/cm^2]")
title("Irradiance vs Current for IR LED")
axis tight
ah1.LineWidth = 1.5;
ah1.FontSize = fs;
ah1.TitleFontSizeMultiplier = 0.9;
print('Dana Point IR LED Irradiance.png', "-dpng")

%% Calculate IR LED irradiance using line of best fit
IRLEDIrradiance = beta1*IRLEDCurrent + beta0;

%% Normalize irradiance
IRPhotoIrradianceNorm = IRPhotoIrradiance/max(IRPhotoIrradiance);
IRLEDIrradianceNorm = IRLEDIrradiance/max(IRLEDIrradiance);

%% Model irradiance
modelPoints = 0:0.01:z(minLen);
irradianceModel = exp(-8*modelPoints);

figure(2)
clf
ah2 = gca;
plot(modelPoints, irradianceModel, "r", LineWidth=2)
hold on
plot(z(1:minLen), IRLEDIrradianceNorm(1:minLen), "*", Color=LEDColor)
plot(z(1:minLen), IRPhotoIrradianceNorm(1:minLen), "*", Color=photoColor)
xlabel("Depth [m]")
ylabel("Normalized IR Irradiance")
title("Normalized Irradiance vs Depth for IR LED")
axis tight
legend("Model", "IR LED Points", "IR Photodiode")
ah2.LineWidth = 1.5;
ah2.FontSize = fs;
ah2.TitleFontSizeMultiplier = 0.9;
print('Dana Point IR LED Irradiance vs Depth with Model.png', "-dpng")


% % plot(IRPhotoCurrent, IRLEDCurrent, "*")

% %% Plot voltages
% subplot(3, 2, 1);
% % plot(z, redVoltage, "r*")
% % plot(z, yellowVoltage, "*", Color="#EDB120")
% % plot(z, greenVoltage, "g*")
% % plot(z, visibleVoltage, "b*")
% regPlot(z(1:length(IRLEDVoltage)), IRLEDVoltage, green)
% xlabel("Depth [m]", FontSize=16);
% ylabel("Voltage [V]", FontSize=16);
% title("Voltage vs Depth", FontSize=20);
% xlim([0 1.5])

% subplot(3, 2, 2)
% regPlot(z(1:length(IRPhotoVoltage)), IRPhotoVoltage, purple)
% hold off
% xlabel("Depth [m]", FontSize=16);
% ylabel("Voltage [V]", FontSize=16);
% title("Voltage vs Depth", FontSize=20);
% % legend("Red LED Voltage", "Yellow LED Voltage", "Green LED Voltage", ...
% %     "Visible Photodiode Voltage", "IR LED Voltage", "IR Photodiode Voltage", ...
% %     fontsize=12);
% axis tight


% %% Plot currents
% subplot(3,2,3);
% % plot(z, redCurrent, "r*")
% % plot(z, yellowCurrent, "*", Color="#EDB120")
% % plot(z, greenCurrent, "g*")
% % plot(z, visibleCurrent, "b*")
% regPlot(z(1:length(IRLEDCurrent)), IRLEDCurrent, green)
% xlabel("Depth [m]", FontSize=16);
% ylabel("Current [A]", FontSize=16);
% title("Current vs Depth", FontSize=20);

% subplot(3,2,4);
% regPlot(z(1:length(IRPhotoCurrent)), IRPhotoCurrent, purple)
% xlabel("Depth [m]", FontSize=16);
% ylabel("Current [A]", FontSize=16);
% title("Current vs Depth", FontSize=20);
% % legend("Red LED Current", "Yellow LED Current", "Green LED Current", ...
% %     "Visible Photodiode Current", "IR LED Current", "IR Photodiode Current", ...
% %     fontsize=12);
% axis tight


% %% Plot normalized currents
% subplot(3,2,5:6);
% hold on
% % plot(z, redCurrentNorm, "r*")
% % plot(z, yellowCurrentNorm, "*", Color="#EDB120")
% % plot(z, greenCurrentNorm, "g*")
% % plot(z, visibleCurrentNorm, "b*")
% regOnlyPlot(z(1:length(IRLEDCurrentNorm)), IRLEDCurrentNorm, green)
% hold on
% regOnlyPlot(z(1:length(IRPhotoCurrentNorm)), IRPhotoCurrentNorm, purple)
% hold off
% xlabel("Depth [m]", FontSize=16);
% ylabel("Normalized Current Relative to Max", FontSize=16);
% title("Normalized Current vs Depth", FontSize=20);

% legend("IR LED", "IR Photodiode", ...
%     'Position',[0.836049968900604 0.857068811310621 0.145490196078431 0.12002567394095], fontsize=12);
% axis tight


function [beta0, beta1] = regPlot(x, y, color)
    confLev = 0.95; % The confidence level
    N = length(y); % The number of data points
    xbar = mean(x);
    ybar = mean(y);
    Sxx = dot((x-xbar),(x-xbar));
    %Sxx = (x-xbar)*transpose(x-xbar);
    % beta1 is the estimated best slope of the best-fit line
    beta1 = dot((x-xbar),(y-ybar))/Sxx
    % beta1 = ((x-xbar)*transpose(y-ybar))/Sxx
    % beta0 is the estimated best-fit y-intercept of the best fit line
    beta0 = ybar - beta1*xbar
    yfit = beta0 + beta1*x;
    SSE = dot((y - yfit),(y - yfit)) % Sum of the squared residuals
    % SSE = (y - yfit)*transpose(y - yfit) % Sum of the squared residuals
    Se = sqrt(SSE/(N-2)) % The Root Mean Square Residual
    Sbeta0 = Se*sqrt(1/N + xbar^2/Sxx)
    Sbeta1 = Se/sqrt(Sxx)
    % tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
    StdT = tinv((1-0.5*(1-confLev)),N-2) % The Student's t factor
    lambdaBeta1 = StdT*Sbeta1 % The 1/2 confidence interval on beta1
    lambdaBeta0 = StdT*Sbeta0 % The 1/2 confidence interval on beta0
    range = max(x) - min(x);
    xplot = min(x):range/30:max(x); % Generate array for plotting
    yplot = beta0 + beta1*xplot; % Generate array for plotting
    Syhat = Se*sqrt(1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
    lambdayhat = StdT*Syhat;
    Sy = Se*sqrt(1+1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
    lambday = StdT*Sy;
    scatter(x,y,"*", "Color", color)
    hold on
    plot(xplot,yplot)
    plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
    plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
    if beta1 > 0 % Fix this
        location = 'northwest';
    else
        location = 'northeast';
    end
    legend('Data Points','Best Fit Line','Upper Func. Bound',...
        'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
        'Location', location)
    hold off
end

function regOnlyPlot(x, y, color)
    xbar = mean(x);
    ybar = mean(y);
    Sxx = dot((x-xbar),(x-xbar));
    %Sxx = (x-xbar)*transpose(x-xbar);
    % beta1 is the estimated best slope of the best-fit line
    beta1 = dot((x-xbar),(y-ybar))/Sxx;
    % beta1 = ((x-xbar)*transpose(y-ybar))/Sxx
    % beta0 is the estimated best-fit y-intercept of the best fit line
    beta0 = ybar - beta1*xbar;
    range = max(x) - min(x);
    xplot = min(x):range/30:max(x); % Generate array for plotting
    yplot = beta0 + beta1*xplot; % Generate array for plotting
    plot(x,y,"*", "Color", color)
    hold on
    plot(xplot,yplot, "Color", color)
    % if beta1 > 0
    %     location = 'northwest';
    % else
    %     location = 'northeast';
    % end
    % legend('Data Points','Best Fit Line','Location', location)
end