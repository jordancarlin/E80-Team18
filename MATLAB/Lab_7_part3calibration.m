x = [1, 3, 8, 9]; 
y = [2, 5, 8, 10]; 
scatter(x, y, '*')
xlabel("Depth(m)")
ylabel("Teensy-reported Voltage(V)")
lsline
h = lsline;
h.Color = 'r'; 
legend('Data','Least Square Line')