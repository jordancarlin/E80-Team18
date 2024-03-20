% Depth and voltage data
depth = [1.07, 1.13, 1.20, 1.25, 1.32, 1.38, 1.45, 1.51, 1.57];
voltage = 0:0.05:0.4;


confLev = 0.95; % The confidence level
N = length(voltage); % The number of data points
depthbar = mean(depth);
voltagebar = mean(voltage);
Sxx = dot((depth-depthbar),(depth-depthbar));
%Sxx = (depth-depthbar)*transpose(depth-depthbar);
% beta1 is the estimated best slope of the best-fit line
beta1 = dot((depth-depthbar),(voltage-voltagebar))/Sxx;
% beta1 = ((depth-depthbar)*transpose(voltage-voltagebar))/Sxx
% beta0 is the estimated best-fit y-intercept of the best fit line
beta0 = voltagebar - beta1*depthbar;
yfit = beta0 + beta1*depth;
SSE = dot((voltage - yfit),(voltage - yfit)); % Sum of the squared residuals
% SSE = (voltage - yfit)*transpose(voltage - yfit) % Sum of the squared residuals
Se = sqrt(SSE/(N-2)); % The Root Mean Square Residual
Sbeta0 = Se*sqrt(1/N + depthbar^2/Sxx);
Sbeta1 = Se/sqrt(Sxx);
% tinv defaults to 1-sided test. We need 2-sises, hence:(1-0.5*(1-confLev))
StdT = tinv((1-0.5*(1-confLev)),N-2); % The Student's t factor
lambdaBeta1 = StdT*Sbeta1; % The 1/2 confidence interval on beta1
lambdaBeta0 = StdT*Sbeta0; % The 1/2 confidence interval on beta0
range = max(depth) - min(depth);
xplot = min(depth):range/30:max(depth); % Generate array for plotting
yplot = beta0 + beta1*xplot; % Generate array for plotting
Syhat = Se*sqrt(1/N + (xplot - depthbar).*(xplot - depthbar)/Sxx);
lambdayhat = StdT*Syhat;
Sy = Se*sqrt(1+1/N + (xplot - depthbar).*(xplot - depthbar)/Sxx);
lambday = StdT*Sy;
figure(1)
plot(depth,voltage,'o', LineWidth=2)
hold on
plot(xplot,yplot, LineWidth=1)
plot(xplot,yplot+lambdayhat,'-.b',xplot,yplot-lambdayhat,'-.b')
plot(xplot,yplot+lambday,'--m',xplot,yplot-lambday,'--m')
xlabel('Depth [m]')
ylabel('Teensy Voltage [V]')
if beta1 > 0 % Fix this
    location = 'northwest';
else
    location = 'northeast';
end
legend('Data Points','Best Fit Line','Upper Func. Bound',...
    'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
    'Location', location)
print("lab 7 section 3.1.png", "-dpng");
hold off

slope = beta1
intercept = beta0

% % Fit a line to the data
% [p, S] = polyfit(depth, voltage, 1); % p(1) is slope & p(2) is the y-intercept
% 
% % 95% confidence interval of fit
% [~, delta] = polyval(p, depth, S);
% 
% % Plot Data
% figure;
% errorbar(depth, voltage, delta, 'o');
% hold on;
% 
% % Best fit
% depthFit = linspace(min(depth), max(depth), 100); 
% voltageFit = polyval(p, depthFit);
% plot(depthFit, voltageFit, '-');
% 
% % Labels
% xlabel('Depth (m)');
% ylabel('Teensy Reported Voltage (V)');
% title('Depth (m) vs. Teensy Voltage (V)');
% 
% % depthCal_slope and depthCal_intercept
% depthCal_slope = p(1);
% depthCal_intercept = p(2);
% 
% % Slope and intercept
% disp(['Slope: ', num2str(depthCal_slope)]);
% disp(['y-intercept: ', num2str(depthCal_intercept)]);
% 
% % Legend
% legend('Data Points with Uncertainty', 'Line of Best Fit', 'Location', 'best');
% 
% 
% 

