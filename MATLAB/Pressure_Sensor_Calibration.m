%#ok<*NOPTS>
% voltage and depth data
voltage = [2.64, 2.62, 2.60, 2.59, 2.57, 2.56, 2.54, 2.52];
depth = 0:0.05:0.35;


confLev = 0.95; % The confidence level
N = length(depth); % The number of data points
voltagebar = mean(voltage);
depthbar = mean(depth);
Sxx = dot((voltage-voltagebar),(voltage-voltagebar));
%Sxx = (voltage-voltagebar)*transpose(voltage-voltagebar);
% beta1 is the estimated best slope of the best-fit line
beta1 = dot((voltage-voltagebar),(depth-depthbar))/Sxx;
% beta1 = ((voltage-voltagebar)*transpose(depth-depthbar))/Sxx
% beta0 is the estimated best-fit y-intercept of the best fit line
beta0 = depthbar - beta1*voltagebar;
yfit = beta0 + beta1*voltage;
SSE = dot((depth - yfit),(depth - yfit)); % Sum of the squared residuals
% SSE = (depth - yfit)*transpose(depth - yfit) % Sum of the squared residuals
Se = sqrt(SSE/(N-2)); % The Root Mean Square Residual
Sbeta0 = Se*sqrt(1/N + voltagebar^2/Sxx);
Sbeta1 = Se/sqrt(Sxx);
% tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
StdT = tinv((1-0.5*(1-confLev)),N-2); % The Student's t factor
lambdaBeta1 = StdT*Sbeta1; % The 1/2 confidence interval on beta1
lambdaBeta0 = StdT*Sbeta0; % The 1/2 confidence interval on beta0
range = max(voltage) - min(voltage);
xplot = min(voltage):range/30:max(voltage); % Generate array for plotting
yplot = beta0 + beta1*xplot; % Generate array for plotting
Syhat = Se*sqrt(1/N + (xplot - voltagebar).*(xplot - voltagebar)/Sxx);
lambdayhat = StdT*Syhat;
Sy = Se*sqrt(1+1/N + (xplot - voltagebar).*(xplot - voltagebar)/Sxx);
lambday = StdT*Sy;
figure(1)
plot(voltage,depth,'o', LineWidth=2)
hold on
plot(xplot,yplot, LineWidth=1)
plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
xlabel('Voltage [V]')
ylabel('Depth [m]')
if beta1 > 0 % Fix this
    location = 'northwest';
else
    location = 'northeast';
end
legend('Data Points','Best Fit Line','Upper Func. Bound',...
    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
    'Location', location)
print("Pressure Calibration.png", "-dpng");
hold off

slope = beta1
intercept = beta0 