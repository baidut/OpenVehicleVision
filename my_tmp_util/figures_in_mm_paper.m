function figures_in_mm_paper
%% Roma Dataset
roma = { ...
    '%datasets\roma\LRAlargeur26032003\IMG01070.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG00946.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG00579.jpg' ...
    '%datasets\roma\BDXD54\IMG00002.jpg' ...
    '%datasets\roma\BDXD54\IMG00030.jpg' ...
    '%datasets\roma\BDXD54\IMG00146.jpg' ...
    '%datasets\roma\BDXD54\IMG00164.jpg' ...
    };
nicta = { ...
 '%datasets\nicta-RoadImageDatabase\Sunny-Shadows\261011_p1WBoff_BUMBLEBEE_06102716324102.tif' ...
 '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif' ...
 '%datasets\nicta-RoadImageDatabase\After-Rain\after_rain00001.tif' ...
};

shadow_detection(roma); % no shadow detected in nicta dataset
imwrite(imresize( getimage(gca), 0.2),'%results/shadow_detection.jpg');
return;

files = { ...
    '%datasets\roma\LRAlargeur26032003\IMG00579.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG01542.jpg' ...
    '%datasets\roma\LRAlargeur26032003\IMG00946.jpg' ...
    '%datasets\roma\BDXD54\IMG00002.jpg' ...
    '%datasets\roma\BDXD54\IMG00030.jpg' ...
    '%datasets\roma\BDXD54\IMG00164.jpg' ...
    };

normal = RawImg('%datasets\roma\LRAlargeur26032003\IMG00864.jpg');
strong_shadow = RawImg('%datasets\roma\BDXD54\IMG00002.jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Road Segmenation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% shadow free image.
imgs = {normal, strong_shadow};

for n = 1:numel(imgs)
    rgb2ii.test(imgs{n});
end

% figure, imshow(normal);return;

% just keep the low half
I = normal(ceil(end/2):end,:,:);
J = strong_shadow(ceil(end/2):end,:,:);
%% Lane Marking Feature Extraction in Critical Shadow Cases
%%  Color

image_hist_RGB_3d(I);
image_hist_RGB_3d(J);

return;

%%  Gradient
% http://www.mathworks.com/matlabcentral/fileexchange/28114-fast-edges-of-a-color-image--actual-color--not-converting-to-grayscale-
% false edge: red, miss edge: color blue
% Canny = edge(I, 'canny')

% gradient direction filtering

%%  Brightnesss
meshCanopy(I,I.R,@jet,200);
axis off
% remove_fig_white_border();
save_gcf('%results/normal-r-mountain.png');


meshCanopy(J,J.R,@jet,200);
axis off
save_gcf('%results/shadow-r-mountain.png');

% Conclusion: global threshold or local
% test local feature.


%% lane marking detection with the help of road detection


end
%%
%% TODO
% export_fig http://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig
% transparent background for matlab figure
function remove_fig_white_border()
% use set(gca,'LooseInset',get(gca,'TightInset'));  instead to
% get the same result
% http://cn.mathworks.com/help/matlab/creating_plots/save-figure-with-minimal-white-space.html
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
end
% print(fig,outputname,'-dpdf')

function save_gcf(outputname)
set(gca,'color','none'); % remove bg color : http://cn.mathworks.com/matlabcentral/newsreader/view_thread/140948
set(gca,'LooseInset',get(gca,'TightInset')); % http://cn.mathworks.com/matlabcentral/newsreader/view_thread/142402
% still have gray padding http://cn.mathworks.com/matlabcentral/answers/133697-saving-images-in-png-format-as-grayscale-without-white-spaces
z=getframe(gcf);
%imwrite(z.cdata, z.colormap, outputname, format); %The colormap should have three columns.
imwrite(z.cdata, outputname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shadow_detection_one()
    RawImage =  RawImg(FilePick.one);
    Shadow = vvShadow(RawImage);
    ShadowEdge = Shadow.bound();
    DetectionResult = RawImage + Shadow.tocolor([0 0 125]) ...
        + ShadowEdge.tocolor([255 0 255]);
    Fig.subimshow(RawImage, DetectionResult);
end
function shadow_detection(files)
%% shadow detection results
RawImgs = cellfun(@ColorImg, files, 'UniformOutput',false);
Shadow = cellfun(@vvShadow, RawImgs, 'UniformOutput',false);

drawShadow = @(x,y) +(x+y.tocolor([0 0 125]));
RawImgData = cellfun(@(x)(x.data), RawImgs, 'UniformOutput',false);
Results = cellfun(drawShadow, RawImgs,Shadow, 'UniformOutput',false);

% figure, montage(cat(4,RawImgData{:}),'Size',[1 NaN]);
% imwrite(getimage(gca),'figure_shadow-1.jpg');
% figure, montage(cat(4,Results{:}),'Size',[1 NaN]);
demo_shadow = [RawImgData Results];
figure, montage(cat(4,demo_shadow{:}),'Size',[2 NaN]);
end
