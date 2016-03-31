% x = 1:1:360;
% y1 = cosd(x) ./ (cosd(x)+sind(x)); % NOTE ./ not /
% y2 = sind(x) ./ (cosd(x)+sind(x));
% hold on;
% plot(x, y1, 'b');
% plot(x, y2, 'g');
% 
% legend({'cosd(x) ./ (cosd(x)+sind(x))','sind(x) ./ (cosd(x)+sind(x))'});

% depend on x range (0-90) or (0-360)
% 181-360 is inv of 1-180
% x range is 1-180 according to README of GetInvariant code 
% `for theta=1:3:180`


clf;
x = 0:1:180;
y1 = cosd(x) ./ (cosd(x)+sind(x)); % NOTE ./ not /
y2 = sind(x) ./ (cosd(x)+sind(x));
hold on;
plot(x, y1, 'b', 'LineWidth',3);
plot(x, y2, 'g', 'LineWidth',3);
axis([0, 180, -15, 15]); 
set(gca,'Xtick',[0, 45, 90, 135, 180],'Ytick',[-15, 0, 1, 15])    %<5>
grid on

h = legend('$$\bf{\frac{cos(\theta)}{cos(\theta)+sin(\theta)}}$$', '$$\bf{\frac{sin(\theta)}{cos(\theta)+sin(\theta)}}$$', 'location', 'NorthWest');
set(h, 'Interpreter','latex');
