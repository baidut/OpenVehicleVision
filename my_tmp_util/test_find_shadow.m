function test_find_shadow(imgFile)
% First do lane marking detection
% novel: detect in shadow and non-shadow area

%% Params Setting

% caltech_shaodw.png

boundAngleRange = 30:75;%30:75;

if nargin < 1
    imgFile = '%datasets\roma\BDXD54\IMG00002.jpg'; %  '%datasets\roma\LRAlargeur26032003\IMG00579.jpg'; %
end
% strong shadow IMG00002 IMG00071 IMG00146 (one side) IMG00164 (high light)
% IMG00030
% weak shadow '%datasets\roma\LRAlargeur26032003\IMG00579.jpg'
Raw = RawImg(imgFile);

[R,G,B] = Raw.eachChn();
[Rd,Gd,Bd] = getChannel(im2double(Raw.data));
S2 = vvFeature.S2(Raw.data);

%% Explore color feature
% plot_ycbcr;return
plot_rgb;return
% plot_rg_minus_b;return

%% Explore lane-marking feature
% test_dld;return


%% Explore Strong Shadow Edge Feature
% test_gb;return

%% Test strong shadow detection , shadow removal and ii iamge(shadow and light)
% Note it is strong shadow detection!, no shadow detected in weak shadow
% cases

Mask = zeros([Raw.rows*Raw.cols, 3],'like',Raw.data);% 'uint8'
LowerB = ~im2bw(B, graythresh(B));
Shadow = (B>G&LowerB); %&B<80 adaptive thresh B
Mask(Shadow,3) = 125;% Mask(B>G&B<120,:) = [0 0 255];
Mask = reshape(Mask,[Raw.rows, Raw.cols, 3] );

% ----------------------------------------------------------------------- %
% figure;Fig.subimshow(Raw, imadd(Raw.data,Mask));return

SSEdge = bwperim(Mask(:,:,3)~=0); %bwboundaries(Mask, 8); % Strong Shadow Edge
Mask = imoverlay(Mask, SSEdge, [255 255 0]);

% ----------------------------------------------------------------------- %
% figure;imshow(imadd(Raw.data,Mask));return

%% For this time we don't need to do shadow removal, just remove the false edges
% don't use shadow's boudary since it is variable to threshold

%% Road Edge detection(no strong shadow edge)
% vvEdge.testCanny(R);% don't use G or B to extract Edge

%% Dealing with large shadow: Edge detection in strong shadow area
% in strong shadow area, cannot find edge in R image.
% show hist and enhancement effects
% in shadow area, the influence of false edge is very severe,
% so instead of using edge, use region feature
ShadowArea = R; %R;%vvFeature.S2(Raw.data);%R;

ShadowArea(~Shadow) = 0;
Enhanced = ShadowArea;
Enhanced(Shadow) = histeq(ShadowArea(Shadow));
% bw = im2bw(ShadowArea, graythresh(ShadowArea(Shadow)));

% vvEdge.testCanny(Enhanced);return;
EdgeInShadow = edge(Enhanced,'canny',[0.0200,0.2900],4.6323);
BminsG = histeq(mat2gray(B - G));

% ----------------------------------------------------------------------- %
% figure;Fig.subimshow(BminsG, Enhanced);return;

%% Edge in other area: using S2 to deal with weak shadow
% use canny ... cannot find the true edge, we need filtering the edge with
% directrion

% vvEdge.testCanny(S2);return;
% EdgeInS2 = edge(S2,'canny',[0.0900,0.2000],6.5441);

EdgeAll = EdgeInShadow | EdgeInS2;

se = strel('square',5); %ceil(Raw.cols/100)*2+1);
ErodedSSEdge = imdilate(SSEdge,se);
EdgeTrue = EdgeAll & (~ErodedSSEdge);


% ----------------------------------------------------------------------- %
% use different color to show different kind of Edges
figure;Fig.subimshow(EdgeInShadow, EdgeInS2);return; % EdgeAll,
% figure;Fig.subimshow(ErodedSSEdge, EdgeTrue);return; % EdgeAll,

%% Straight line Detection

% detect many lines in one time
BoundL = vvBoundModel.houghStraightLine(EdgeTrue, boundAngleRange);
BoundR = vvBoundModel.houghStraightLine(EdgeTrue, -boundAngleRange); % -75:-30

Result = Raw;
f = Fig();f.subimshow(Raw,Result);
BoundL.plot('r');
BoundR.plot('g');

% saveas(gcf, ['%Temp/', Raw.name, '.jpg']);
% close(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plot_rgb()
        %% Find the k
        
        %% plot rgb
        line_segment = {floor(Raw.rows*5/8):floor(Raw.rows*6/8), ceil(Raw.cols/2)};
        figure,
        subplot(121); imshow(Raw);hold on;
        x = ones([numel(line_segment{1}) 1])*line_segment{2};
        y = line_segment{1};
%         plot(x,y,'m*','LineWidth',2);
        plot(x, y, 'm*');
        
        subplot(122);
%         low_half = floor(Raw.rows/2):floor(Raw.rows*3/4); %floor(Raw.rows/2):Raw.rows;
        
        %         show_rgb(low_half, ceil(Raw.cols/2));
        
        show_rgb(line_segment{:});
        
        % to make it clear, we duplicate the selected column
        
        % purpose: strong shadow detection
        % idea: using color information
        % S2 notice that B component in road strong shadow is very high.
        % R,G or B,G can detect shadow edge
        
        function show_rgb(rows,c) % rows c
            % only show the low half image
            ratio = 20; % scale the y axis
            
            image = repmat(Raw.data(rows,c,:), [1 ceil(ratio)]);
            imshow(rot90(image));
            hold on;
            
            X = rows - rows(1);
            plot(X, (1-Rd(rows,c))*ratio, 'r', 'LineWidth', 1);
            plot(X, (1-Gd(rows,c))*ratio, 'g', 'LineWidth', 1);
            plot(X, (1-Bd(rows,c))*ratio, 'b', 'LineWidth', 1);
            plot(X, (ones([numel(rows),1]))*ratio, 'm*');
%             SF = Gd(rows,c) - 2*Bd(rows,c);
%             plot(X, (1-SF)*ratio, 'b', 'LineWidth', 1);
            %             axis on;
            % explain x and y
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plot_ycbcr()
        hold on;
        [Y,Cb,Cr] = getChannel(rgb2ycbcr(im2double(Raw.data)));
        low_half = floor(Raw.rows/2):floor(Raw.rows*3/4); %floor(Raw.rows/2):Raw.rows;
        
        show_ycbcr(1:floor(Raw.rows), ceil(Raw.cols*1/4));
        
        function show_ycbcr(rows,c) % rows c
            % only show the low half image
            ratio = 100;% 20; % scale the y axis
            
            maxfig;
            image = repmat(Raw.data(rows,c,:), [1 ceil(ratio)]);
            imshow(rot90(image));
            hold on;
            
            % plot
            % plot
            % plot will shelter previous curve
            
            X = rows - rows(1);
            plot(X, (1-Y(rows,c))*ratio, 'r', 'LineWidth', 1);
            plot(X, (1-Cb(rows,c))*ratio, 'g', 'LineWidth', 1);
            plot(X, (1-Cr(rows,c))*ratio, 'b', 'LineWidth', 1);
            %             axis on;
            %             SF = ( Bd(rows,c)-( Gd(rows,c) + 0.2)/2 )./ Bd(rows,c);
            % %             SF(isinf(SF)) = 0;
            %             SF(SF<0) = 0;
            %             plot(X, (1-SF)*ratio, 'm');
            % explain x and y
        end
    end
    function plot_rg_minus_b()
        hold on;
        low_half = floor(Raw.rows/2):floor(Raw.rows*3/4); %floor(Raw.rows/2):Raw.rows;
        
        show_rg_minus_b(1:floor(Raw.rows), ceil(Raw.cols*1/4));
        %         show_rg_minus_b(low_half, ceil(Raw.cols/2));
        
        %         show_rg_minus_b(floor(Raw.rows*5/8):floor(Raw.rows*6/8), ceil(Raw.cols/2));
        
        % to make it clear, we duplicate the selected column
        
        % purpose: strong shadow detection
        % idea: using color information
        % S2 notice that B component in road strong shadow is very high.
        % R,G or B,G can detect shadow edge
        
        function show_rg_minus_b(rows,c) % rows c
            % only show the low half image
            ratio = 100;% 20; % scale the y axis
            
            maxfig;
            image = repmat(Raw.data(rows,c,:), [1 ceil(ratio)]);
            imshow(rot90(image));
            hold on;
            
            % plot
            % plot
            % plot will shelter previous curve
            
            X = rows - rows(1);
            %             plot(X, (1+Bd(rows,c)-Rd(rows,c))*ratio, 'r', ...
            %             	 X, (1+Bd(rows,c)-Gd(rows,c))*ratio, 'g', ...
            %                  X, (1+Bd(rows,c)-Bd(rows,c))*ratio, 'b', 'LineWidth', 3);
            %             axis on;
            SF = ( Bd(rows,c)-( Gd(rows,c) + 0.2)/2 )./ Bd(rows,c);
            %             SF(isinf(SF)) = 0;
            SF(SF<0) = 0;
            plot(X, (1-SF)*ratio, 'm');
            % explain x and y
        end
    end
    function test_gb()
        % Conclusion: strong shadow edge occurs at delta B-G peak
        % don't support weak shadow
        % IMPROVE: plot more in one figure.
        % select one column
        
        figure;
        imshow(rot90(Raw.data));%, 'Xdata',[1 Raw.cols]- 255);
        
        hold on;
        show_column_gb(ceil(Raw.cols/2));
        show_column_gb(ceil(Raw.cols/4));
        show_column_gb(ceil(Raw.cols*3/4)); % basevalue is fixed for one axes, so `area` cannot be used
        camroll(-90);
        
        function show_column_gb(c)
            b = Raw.cols-c;
            baseline = ones(1,Raw.rows)*b;
            fill_between_lines = @(X,Y1,Y2,C) fill( [X fliplr(X)],  [Y1 fliplr(Y2)], C );
            fill_between_lines( 1:Raw.rows, 2*double(B(:,c)-G(:,c))'+b, baseline,'b');
            fill_between_lines( 1:Raw.rows, -2*double(G(:,c)-B(:,c))'+b, baseline,'g');
            % http://stackoverflow.com/questions/6245626/matlab-filling-in-the-area-between-two-sets-of-data-lines-in-one-figure
        end
    end

    function test_dld()
        
        figure;
        imshow(Raw.data);%, 'Xdata',[1 Raw.cols]- 255);
        
        hold on;
        %         show_row_dld(ceil(Raw.rows*9/16), R, 'r');
        %         show_row_dld(ceil(Raw.rows*10/16), G, 'g');
        %         show_row_dld(ceil(Raw.rows*11/16), B, 'b');
        %         show_row_dld(ceil(Raw.rows*13/16), R, 'r');
        %         show_row_dld(ceil(Raw.rows*14/16), G, 'g');
        %         show_row_dld(ceil(Raw.rows*15/16), B, 'b');
        
        [H,S,V] = getChannel(rgb2hsv(Raw.data));
        
        show_row_dld(ceil(Raw.rows*9/16), im2uint8(H), 'y');
        show_row_dld(ceil(Raw.rows*10/16), im2uint8(S), 'm');
        show_row_dld(ceil(Raw.rows*11/16), im2uint8(V), 'c');
        show_row_dld(ceil(Raw.rows*12/16), im2uint8(S2), 'w');
        show_row_dld(ceil(Raw.rows*13/16),  im2uint8(H), 'y');
        show_row_dld(ceil(Raw.rows*14/16), im2uint8(S), 'm');
        show_row_dld(ceil(Raw.rows*15/16), im2uint8(V), 'c');
        
        function show_row_dld(r, chn, color)
            % left: show row light
            % middle: show row hsv (very unstable) color based method are
            % quite unstable. S2 is good at weak shadow cases. S2 is very
            % unstable
            % hsv segmentation is good for road boundary
            % detection. note we only dealing with limited cases.
            % Conclusion: low blue diff in shadow cases
            
            % since most algorithm precess along each line, we plot...
            b = r;
            baseline = ones(1,Raw.cols)*b;
            fill_between_lines = @(X,Y1,Y2,C) fill( [X fliplr(X)],  [Y1 fliplr(Y2)], C );
            fill_between_lines( 1:Raw.cols, -double(chn(r,:))/4+b, baseline,color);
        end
    end

    function edge_detection_by_column_scan()
        % not robust
        E = zeros([Raw.rows, Raw.cols]);
        
        for r = 1:Raw.rows-1
            b1 = Raw.data(r,:,3);
            b2 = Raw.data(r+1,:,3);
            g1 = Raw.data(r,:,2);
            g2 = Raw.data(r+1,:,2);
            % max == b1
            E(r,(b1>=g1) & (b2<=g2) ) = 128;
            E(r,(b1<=g1) & (b2>=g2) ) = 255;
        end
        
        for c = 1:Raw.cols-1
            b1 = Raw.data(:,c,3);
            b2 = Raw.data(:,c+1,3);
            g1 = Raw.data(:,c,2);
            g2 = Raw.data(:,c+1,2);
            % max == b1
            E((b1>=g1) & (b2<=g2),c ) = 128;
            E((b1<=g1) & (b2>=g2),c ) = 255;
        end
    end

    function direction_edge()
        
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
% % select a rect region
% rect = ceil([601.30519322064 488.665679488886 14.3181818181818 14.0454545454545]);
% ROI = ColorImg(Raw.data(rect(1):rect(1)+rect(3),rect(2):rect(2)+rect(4),:));
%
% [R,G,B] = ROI.eachChn();
% % imshow(R');
% hold on;
% plot(R(:,1),'r');
% plot(G(:,1),'g');
% plot(B(:,1),'b');
%
% return;
%
% % ¶Ô±ÈÍ¼Ïñ
%
% RGB = ColorImg(Raw.data(624:624+20,582:582+20,:)); % ceil(end/2):end,ceil(end/2):end imresize(Raw.data(590:590+121,620:620+46,:), [15 20])
% % [620.259882869693 575.46925329429 46.4773060029283 35.9824304538798]
%
% % [624.757686676428 582.965592972182 20.9897510980967 19.4904831625183]
% [R,G,B] = RGB.eachChn();
% R = im2double(R);
% G = im2double(G);
% B = im2double(B);
%
% subplot(121)
% [pxB,pyB] = gradient(B);%,.2,.2
% [pxG,pyG] = gradient(G);%,.2,.2
% imshow(RGB);
% hold on
% quiver(1:RGB.cols,1:RGB.rows,pxG-pxB,pxG-pyB);
%
% subplot(122)
% imshow(G);
% hold on
% quiver(1:RGB.cols,1:RGB.rows,pxG,pyG);
%
% return;
%
% I= imoverlay(Raw.data,E~=0,[255 0 0]);
% Fig.subimshow(I);
% imtool(I);


