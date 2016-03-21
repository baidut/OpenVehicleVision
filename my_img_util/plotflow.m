function plotFlow(u, v, rSize, scale)
%功能：绘制光流场
%输出：u-横向光流矢量  scale-光流场规模
%输出：v-纵向光流矢量  imgOriginal-光流场显示的图像 rSize-可见光流矢量区域的尺寸
%输出：fz-参考像素点的灰度值沿z方向的偏导数
% 修改自 http://www.ilovematlab.cn/thread-280248-1-1.html
% 原图不需要，仅仅plot光流
% 添加两个方向的显示
% set(gca,'YDir','reverse');似乎没什么用

nargneed = 4;

if nargin < nargneed
    scale = 3;
    nargneed = nargneed - 1;
	if nargin < nargneed
		rSize = 5;
	end
end

% Enhance the quiver plot visually by showing one vector per region
for i = 1:size(u,1) %u的行数 u v 一样大小
    for j = 1:size(u,2) %u的列数
        if floor(i/rSize)~=i/rSize || floor(j/rSize)~=j/rSize %判断不等 5的倍数出有点
            u(i,j)=0;
            v(i,j)=0;
        end
    end
end

quiver(u, v, scale, 'color', 'r', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色
% set(gca,'YDir','reverse');%gca当前轴处理 
quiver(u, zeros(size(v)), scale, 'color', 'g', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色
quiver(zeros(size(u)), v, scale, 'color', 'b', 'linewidth', 2);%线宽是2，颜色是b，即蓝色，r是红色