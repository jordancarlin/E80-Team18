x = 0:0.1:100;
y = 100*exp(-0.016*x); 

ah = gca;

plot(x, y, LineWidth=2);
xlabel("Depth [m]", "FontSize", 17)
ylabel("Percentage of Light Irradiance [%]", "FontSize", 17)
title("Normalized Light Irradiance VS Depth in Saltwater", "FontSize", 17)
grid on

ah.FontSize = 17;
ah.LineWidth = 1.5;