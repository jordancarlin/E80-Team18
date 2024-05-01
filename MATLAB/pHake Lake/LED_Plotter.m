% LED_Plotter.m
clear all;
figure(3)
clf

green = "#77AC30";
purple = "#6A44B1";

%% Resistor Values
IRPhotoResistance = 8.7e3;
yellowResistance = 3.15e6;
greenResistance = 2.8e6;
visibleResistance = 1.43e3;
IRLEDResistance = 1.25e6;
redResistance = 11.75e6;

%% Setup
filenum = '008'; % file number for the data you want to read
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

%% Only get data on the way down
[M, Imax] = max(z);
Imin = find(z >= 0, 1, 'first');
z = z(Imin:Imax);
IRPhotoVoltage = IRPhotoVoltage(Imin:Imax);
yellowVoltage = yellowVoltage(Imin:Imax);
greenVoltage = greenVoltage(Imin:Imax);
visibleVoltage = visibleVoltage(Imin:Imax);
IRLEDVoltage = IRLEDVoltage(Imin:Imax);
redVoltage = redVoltage(Imin:Imax);


%% Filter 0s
% IRPhotoVoltage(IRPhotoVoltage <= 0.0000) = NaN;
% yellowVoltage(yellowVoltage <= 0.0000) = NaN;
% greenVoltage(greenVoltage <= 0.0000) = NaN;
% visibleVoltage(visibleVoltage <= 0.0000) = NaN;
% IRLEDVoltage(IRLEDVoltage <= 0.0000) = NaN;
% redVoltage(redVoltage <= 0.0000) = NaN;

%% Filter to only one point per depth
newZ = [];
newIRPhotoVoltage = [];
newYellowVoltage = [];
newGreenVoltage = [];
newVisibleVoltage = [];
newIRLEDVoltage = [];
newRedVoltage = [];

for i=1:length(z)
    if not(ismembertol(z(i), newZ, 0.00000))
        newZ(end+1) = z(i);
        newIRPhotoVoltage(end+1) = IRPhotoVoltage(i);
        newYellowVoltage(end+1) = yellowVoltage(i);
        newGreenVoltage(end+1) = greenVoltage(i);
        newVisibleVoltage(end+1) = visibleVoltage(i);
        newIRLEDVoltage(end+1) = IRLEDVoltage(i);
        newRedVoltage(end+1) = redVoltage(i);
    else
        j = find(newZ == z(i));
        if newIRPhotoVoltage(j) < IRPhotoVoltage(i)
            newIRPhotoVoltage(j) = IRPhotoVoltage(i);
        end
        if newYellowVoltage(j) < yellowVoltage(i)
            newYellowVoltage(j) = yellowVoltage(i);
        end
        if newGreenVoltage(j) < greenVoltage(i)
            newGreenVoltage(j) = greenVoltage(i);
        end
        if newVisibleVoltage(j) < visibleVoltage(i)
            newVisibleVoltage(j) = visibleVoltage(i);
        end
        if newIRLEDVoltage(j) < IRLEDVoltage(i)
            newIRLEDVoltage(j) = IRLEDVoltage(i);
        end
        if newRedVoltage(j) < redVoltage(i)
            newRedVoltage(j) = redVoltage(i);
        end
    end
end

z=newZ;
IRPhotoVoltage = newIRPhotoVoltage;
yellowVoltage = newYellowVoltage;
greenVoltage = newGreenVoltage;
visibleVoltage = newVisibleVoltage;
IRLEDVoltage = newIRLEDVoltage;
redVoltage = newRedVoltage;

%% Apply moving average
IRPhotoVoltage = movmean(IRPhotoVoltage, 5);
yellowVoltage = movmean(yellowVoltage, 5);
greenVoltage = movmean(greenVoltage, 5);
visibleVoltage = movmean(visibleVoltage, 5);
IRLEDVoltage = movmean(IRLEDVoltage, 5);
redVoltage = movmean(redVoltage, 5);

%% Stop when current reaches zero
IRPhotoVoltage = IRPhotoVoltage(1:find(IRPhotoVoltage <= 0.0001, 1, "first"));
yellowVoltage = yellowVoltage(1:find(yellowVoltage <= 0.0001, 1, "first"));
greenVoltage = greenVoltage(1:find(greenVoltage <= 0.0001, 1, "first"));
visibleVoltage = visibleVoltage(1:find(visibleVoltage <= 0.0001, 1, "first"));
% IRLEDVoltage = IRLEDVoltage(1:find(IRLEDVoltage <= 0.0001, 1, "first"));
redVoltage = redVoltage(1:find(redVoltage <= 0.0001, 1, "first"));

%% Convert voltages to currents
IRPhotoCurrent = IRPhotoVoltage/IRPhotoResistance;
yellowCurrent = yellowVoltage/yellowResistance;
greenCurrent = greenVoltage/greenResistance;
visibleCurrent = visibleVoltage/visibleResistance;
IRLEDCurrent = IRLEDVoltage/IRLEDResistance;
redCurrent = redVoltage/redResistance;

%% Normalize currents
IRPhotoCurrentNorm = IRPhotoCurrent/max(IRPhotoCurrent);
yellowCurrentNorm = yellowCurrent/max(yellowCurrent);
greenCurrentNorm = greenCurrent/max(greenCurrent);
visibleCurrentNorm = visibleCurrent/max(visibleCurrent);
IRLEDCurrentNorm = IRLEDCurrent/max(IRLEDCurrent);
redCurrentNorm = redCurrent/max(redCurrent);

% plot(IRPhotoCurrent, IRLEDCurrent, "*")

%% Plot voltages
subplot(3, 2, 1);
% plot(z, redVoltage, "r*")
% plot(z, yellowVoltage, "*", Color="#EDB120")
% plot(z, greenVoltage, "g*")
% plot(z, visibleVoltage, "b*")
regPlot(z(1:length(IRLEDVoltage)), IRLEDVoltage, green)
xlabel("Depth [m]", FontSize=16);
ylabel("Voltage [V]", FontSize=16);
title("Voltage vs Depth", FontSize=20);
xlim([0 1.5])

subplot(3, 2, 2)
regPlot(z(1:length(IRPhotoVoltage)), IRPhotoVoltage, purple)
hold off
xlabel("Depth [m]", FontSize=16);
ylabel("Voltage [V]", FontSize=16);
title("Voltage vs Depth", FontSize=20);
% legend("Red LED Voltage", "Yellow LED Voltage", "Green LED Voltage", ...
%     "Visible Photodiode Voltage", "IR LED Voltage", "IR Photodiode Voltage", ...
%     fontsize=12);
axis tight


%% Plot currents
subplot(3,2,3);
% plot(z, redCurrent, "r*")
% plot(z, yellowCurrent, "*", Color="#EDB120")
% plot(z, greenCurrent, "g*")
% plot(z, visibleCurrent, "b*")
regPlot(z(1:length(IRLEDCurrent)), IRLEDCurrent, green)
xlabel("Depth [m]", FontSize=16);
ylabel("Current [A]", FontSize=16);
title("Current vs Depth", FontSize=20);

subplot(3,2,4);
regPlot(z(1:length(IRPhotoCurrent)), IRPhotoCurrent, purple)
xlabel("Depth [m]", FontSize=16);
ylabel("Current [A]", FontSize=16);
title("Current vs Depth", FontSize=20);
% legend("Red LED Current", "Yellow LED Current", "Green LED Current", ...
%     "Visible Photodiode Current", "IR LED Current", "IR Photodiode Current", ...
%     fontsize=12);
axis tight


%% Plot normalized currents
subplot(3,2,5:6);
hold on
% plot(z, redCurrentNorm, "r*")
% plot(z, yellowCurrentNorm, "*", Color="#EDB120")
% plot(z, greenCurrentNorm, "g*")
% plot(z, visibleCurrentNorm, "b*")
regOnlyPlot(z(1:length(IRLEDCurrentNorm)), IRLEDCurrentNorm, green)
hold on
regOnlyPlot(z(1:length(IRPhotoCurrentNorm)), IRPhotoCurrentNorm, purple)
hold off
xlabel("Depth [m]", FontSize=16);
ylabel("Normalized Current Relative to Max", FontSize=16);
title("Normalized Current vs Depth", FontSize=20);

legend("IR LED", "IR Photodiode", ...
    'Position',[0.836049968900604 0.857068811310621 0.145490196078431 0.12002567394095], fontsize=12);
axis tight


function regPlot(x, y, color)
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
    plot(x,y,"*", "Color", color)
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
    plot(x,y,"*", "Color", color)
    hold on
    plot(xplot,yplot, "Color", color)
    % plot(xplot,yplot+lambdayhat,'-.', 'Color', color,xplot,yplot-lambdayhat,'-.', 'Color', color)
    % plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
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