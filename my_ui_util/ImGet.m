%{
Image = ImCtrl(@imread, FilePick());
Thresh = Slider([0 1]);
Bw = ImCtrl(@im2bw, ImGet(Image), Thresh);
Fig.subimshow(Image, Bw);


%% Example 2
Image = ImCtrl(@imread, FilePick());
Gray = ImCtrl(@rgb2gray, ImGet(Image));

thresh = Slider([0 0.2], 'Value', 0.05);
direction = Popupmenu({'both','horizontal','vertical'});
thinning = Popupmenu({'thinning','nothinning'});

Sobel = ImCtrl(@edge, ImGet(Gray), 'sobel', thresh, direction, thinning);
Prewitt = ImCtrl(@edge, ImGet(Gray), 'prewitt', thresh, direction, thinning);

Fig.subimshow(Image, Gray, Sobel, Prewitt);
%}
classdef ImGet < UiModel
    properties (GetAccess = public, SetAccess = public)
        h_watch
    end
    
    methods (Access = public)
        function obj = ImGet(imctrl)
            % a handle object is like a pointer, so it will not 
            % cause memory copy.
            obj.h_watch = imctrl;
            % imctrl.h_call
        end
        
        function value = val(obj,h)
            value = getimage(obj.h_watch.h_axes);
        end
        
        function h = plot(obj)
            % TODO: change watch axes
            h = obj.text('ImGet');
        end
    end
end% classdef