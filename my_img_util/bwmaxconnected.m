% 提取最大联通分量

% 先腐蚀膨胀一下，去除杂点 也可以在前面灰度膨胀
% 找出最大的连通分量即为路面区域。 或采用膨胀腐蚀算法消去噪点
% [L, num] = bwlabel(SaturateMap, 4); % TODO 4连通对比
% x=zeros(1,num);
% for idx=1:num
%    x(idx)=sum(sum(L == idx));
% end
% [m, idx] = max(x);
% Connected = (L == idx);
% DLD提取的为内部，而Canny为边界，求点乘就没有了。。。