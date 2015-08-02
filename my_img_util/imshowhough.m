function imshowhough(Raw)
%IMSHOWHOUGH extract the hough lines of an image.
% USAGE:
%  normal case
% 	IMSHOWHOUGH('pictures/lanemarking/light_singlelane.jpg');
%  effect of shadow
% 	IMSHOWHOUGH('pictures/lanemarking/shadow/IMG00576.jpg');

Raw = im2gray(Raw);
BW = edge(Raw, 'canny');

[H,T,R] = hough(BW); % [H,theta,rho]
P  = houghpeaks(H,2);
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
plot(T(P(:,2)),R(P(:,1)),'s','color','white');

% Finding the Hough peaks (number of peaks is set to 10)
% P = houghpeaks(H,2,'threshold',ceil(0.2*max(H(:))));

% x = T(P(:,2));
% y = R(P(:,1));

%Fill the gaps of Edges and set the Minimum length of a line
lines = houghlines(BW,T,R,P,'FillGap',170,'MinLength',50);

figure;
HoughLine = Raw;
implot(Raw, BW, HoughLine);
for i = 1:length(lines)
	xy = [lines(i).point1; lines(i).point2];
	hold on;
	plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
end