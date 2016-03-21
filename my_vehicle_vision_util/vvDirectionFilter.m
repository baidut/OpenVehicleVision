I = 'dataset\roma\BDXD54\IMG00002.jpg'; % IMG00002 IMG00071

% function Filtered = vvDirectionFilter(I, method, preprocess, varargin)
% 测试中文
% method = 'steergauss'
% vvDirectionFilter('dataset\roma\BDXD54\IMG00030.jpg')
% Gabor变换属于加窗傅立叶变换，Gabor函数可以在频域不同尺度、不同方向上提取相关的特征。Gabor 滤波器的频率和方向类似于人类的视觉系统，所以常用于纹理识别。在空间域，二维Gabor滤波器是一个高斯核函数和正弦平面波的乘积，具体的：
% 采用可调滤波器，滤去特定方向
% 用sobel算子求边缘梯度方向时先做模板操作，得到Gx,Gy,再阈值化，对检测出的边缘点计算atan(Gy/Gx)
% 筛选边缘方向

% if nargin > 2 
	% I = preprocess(I, varargin{:});
% end

if isstr(I)
	I = imread(I);
end

[lineL, lineR]= im2boundaryline(I);

% 注意不是均值
% 姑且先按照均值算吧
theta = 180 - (lineL.theta + lineR.theta)/2; % 90 - theta
% PointL = lineL.point2;
% PointR = lineR.point2;
% PointM = PointL/2.0 + PointR/2.0; %Left Middle Right
% PointO = lineL.point1;

% % 注意这个theta和houghline的theta不同
% thetaL = atan( (PointL(2) - PointO(2) )/(PointL(1) - PointO(1) ) )*360/pi;
% thetaR = atan( (PointR(2) - PointO(2) )/(PointR(1) - PointO(1) ) )*360/pi;
% theta = atan( (PointM(2) - PointO(2) )/(PointM(1) - PointO(1) ) )*360/pi;

thetaL = 180 - lineL.theta;
thetaR = 180 - lineR.theta;
Gray = rgb2gray(I);

sigma = 3;
Wx = floor((5/2)*sigma);
%x = [-Wx:Wx];
x = [Wx:-1:1, 0 1:Wx];
% 自定义的滤波模板
% h.g = exp(-(x.^2)/(2*sigma^2));
% h.gp = -(x/sigma).*h.g;% -(x/sigma).*exp(-(x.^2)/(2*sigma^2));
% h.gp = -(x/(sigma^2)).*h.g;% -(x/sigma).*exp(-(x.^2)/(2*sigma^2));
% h.theta = theta; %-theta*(180/pi);
% h.sigma = sigma;
% DLD
% y = 0 退化成一维
% h.g = ( (16*x.^4)/(sigma^8) - (48*x.^2)/(sigma^6) - 12/(sigma^4) ) .* exp(-(x.^2)/(sigma^2));
% h.gp = ( (64*x.^3)/(sigma^8) - (96*x)/(sigma^6) ) .* exp(-(x.^2)/(sigma^2)) + ...
 % h.g .* (-2*x/(sigma^2)); % -(x/sigma).*exp(-(x.^2)/(2*sigma^2));
% h.g = ( (4*x.^2)/(sigma^4) - 2/(sigma^2) ) .* exp(-(x.^2)/(sigma^2));
% h.gp = ( (8*x)/(sigma^8) ) .* exp(-(x.^2)/(sigma^2)) + ...
 % h.g .* (-2*x/(sigma^2)); 
h.g = ( (4*x)/(sigma^4) ) .* exp(-(x.^2)/(sigma^2));
h.gp = ( 4/(sigma^4) ) .* exp(-(x.^2)/(sigma^2))  ...
	+ h.g .* (-2*x/(sigma^2));  
h.theta = theta; %0; %-theta*(180/pi); 0
h.sigma = sigma;

% [J,H] = steerGauss(Gray,theta,3,true);
J = steerGauss(Gray,h,true);
figure;
implot(I, J, J>0.2*max(J(:)));

% function J = steerGauss(I,Wsize,sigma,theta)
% % USAGE:
% % Wsize = 20;sigma = 1;%Wsize = 7;
% % steerGauss(Gray,Wsize,sigma,theta);

% % 程序参考http://blog.163.com/yuyang_tech/blog/static/216050083201302324443736/
% % 将角度转化在[0,pi]之间
% theta = theta/180*pi;
% % 计算二维高斯核在x,y方向的偏导gx,gy
% k = [-Wsize:Wsize];
% g = exp(-(k.^2)/(2*sigma^2));
% gp = -(k/sigma).*exp(-(k.^2)/(2*sigma^2));
% gx = g'*gp;
% gy = gp'*g;
% % 计算图像Ｉ在x,y方向的滤波结果
% Ix = conv2(I,gx,'same');
% Iy = conv2(I,gy,'same');
% % 计算图像Ｉ在theta方向的滤波结果
% J = cos(theta)*Ix+sin(theta)*Iy;

% % figure,imshow(J);
% figure,
% subplot(1,3,1),axis image; colormap(gray);imshow(I),title('原图像');
% subplot(1,3,2),axis image; colormap(gray);imshow(cos(theta)*gx+sin(theta)*gy),title('滤波模板');
% subplot(1,3,3),axis image; colormap(gray);imshow(J),title('滤波结果'); 