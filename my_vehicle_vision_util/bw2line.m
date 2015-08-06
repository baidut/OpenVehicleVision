function line = bw2line(BW, Theta)
%Hough Transform
if nargin < 2
	[H,theta,rho] = hough(BW);
else 
	[H,theta,rho] = hough(BW, 'Theta', Theta);
end

% Finding the Hough peaks
P = houghpeaks(H, 1);
x = theta(P(:,2));
y = rho(P(:,1));

%Fill the gaps of Edges and set the Minimum length of a line
lines = houghlines(BW,theta,rho,P, 'MinLength',10, 'FillGap',570);
line = lines(1);

% figure;
% imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');
% figure;
