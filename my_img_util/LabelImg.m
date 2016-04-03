classdef LabelImg
    
    %% Public properties
    properties (GetAccess = public, SetAccess = private)
        data
    end
    
    %% Public methods
    methods (Access = public)
	
		function obj = LabelImg(data)
			obj.data = data;
		end
		
		% rewrite the imshow methods
        function h = imshow(obj, varargin)
			h = imshow(label2rgb(obj.data), varargin{:});
        end
		
		function [bw,index] = maxarea(obj)
		% max connected area
		% http://stackoverflow.com/questions/20725603/how-to-select-the-object-with-the-largest-area
			stat = regionprops(obj.data,'Centroid','Area','PixelIdxList');
			[maxValue,index] = max([stat.Area]);
			bw = BwImg(obj.data == index);
		end
    end% methods
    
    methods(Static)
        function [bw,index] = maxareaOf(obj)
		% max connected area
		% http://stackoverflow.com/questions/20725603/how-to-select-the-object-with-the-largest-area
			stat = regionprops(obj,'Centroid','Area','PixelIdxList');
			[~,index] = max([stat.Area]);
			bw = (obj == index);
		end
    end
end% classdef

% 提取�?��联�?分量

% 先腐�?���?��下，去除杂点 也可以在前面灰度膨胀
% 找出�?��的连通分量即为路面区域�? 或采用膨�?���?��法消去噪�?
% [L, num] = bwlabel(SaturateMap, 4); % TODO 4连�?对比
% x=zeros(1,num);
% for idx=1:num
%    x(idx)=sum(sum(L == idx));
% end
% [m, idx] = max(x);
% Connected = (L == idx);
% DLD提取的为内部，�?Canny为边界，求点乘就没有了�?。�?