%{
File = FileChoose();
Image = ImCtrl(@imread, File);
Fig.subimshow(Image);
%}
classdef FileChoose < UiModel
    properties (GetAccess = public, SetAccess = public)
        uigetfile_params
    end
    
    methods (Access = public)
        function obj = FileChoose(varargin)
            numvarargs = numel(varargin);
            FilterSpec = {'*.jpg;*.tif;*.png;*.gif','All Image Files';...
                    '*.*','All Files' };
            DialogTitle = 'Choose an image';
            DefaultName = fullfile('matlabroot','toolbox\images\imdata');
            
            optargs = {FilterSpec,DialogTitle,DefaultName};
            
            if numvarargs > numel(optargs)
                error('myfuns:somefun2Alt:TooManyInputs', ...
                    'requires at most 3 optional inputs');
            end
            
            optargs(1:numvarargs) = varargin;

            obj.uigetfile_params = optargs(1:3);
        end
        
        function value = val(obj,h)
            [FileName,PathName,~] = uigetfile(obj.uigetfile_params{:});
            value = fullfile(PathName, FileName);
        end
        
        function h = plot(obj)
            h = uicontrol('Style', 'pushbutton', 'String', 'Choose...');
            h.Position= obj.Position;
            h.Callback= obj.Callback;
            
            text(obj,inputname(1));
        end
    end
end% classdef