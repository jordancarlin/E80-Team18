data = readmatrix('datafile.csv'); % Read in data

depth = data(1:ind, col_num); % Replace col_num with corresponding number
depth_des = data(1:ind, col_num); 
uV = data(1:ind, col_num);
time = linspace(0, 10, 100); % Example time vector

% Plot depth and depth_des vs. time
figure;
subplot(2,1,1)
plot(time, depth, 'b');
hold on
plot(time, depth_des, 'r--');
xlabel('Time (s)');
ylabel('Depth (m)');
legend('Depth', 'Depth\_des', 'Location', 'best');
title('Depth and Depth\_des vs. Time');

% Plot uV vs. time as a subplot
subplot(2,1,2);
plot(time, uV, 'g');
xlabel('Time (s)');
ylabel('uV (logged)');
title('uV vs. Time');