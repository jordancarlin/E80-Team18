% Depth and voltage data
depth = [1, 2.2, 3.1, 4.5, 5, 6.9, 7.3]; 
voltage = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]; 

% Fit a line to the data
[p, S] = polyfit(depth, voltage, 1); % p(1) is slope & p(2) is the y-intercept

% 95% confidence interval of fit
[~, delta] = polyval(p, depth, S);

% Plot Data
figure;
errorbar(depth, voltage, delta, 'o');
hold on;

% Best fit
depthFit = linspace(min(depth), max(depth), 100); 
voltageFit = polyval(p, depthFit);
plot(depthFit, voltageFit, '-');

% Labels
xlabel('Depth (m)');
ylabel('Teensy Reported Voltage (V)');
title('Depth (m) vs. Teensy Voltage (V)');

% depthCal_slope and depthCal_intercept
depthCal_slope = p(1);
depthCal_intercept = p(2);

% Slope and intercept
disp(['Slope: ', num2str(depthCal_slope)]);
disp(['y-intercept: ', num2str(depthCal_intercept)]);

% Legend
legend('Data Points with Uncertainty', 'Line of Best Fit', 'Location', 'best');


