function test_find_shadow
imgFile = '%datasets\roma\BDXD54\IMG00164.jpg';
% strong shadow IMG00002 IMG00071 IMG00146 (one side) IMG00164 (high light)
% IMG00030 
% weak shadow
Raw = RawImg(imgFile);
E = zeros([Raw.rows, Raw.cols]);

% for r = 1:Raw.rows-1
%     b1 = Raw.data(r,:,3);
%     b2 = Raw.data(r+1,:,3);
%     g1 = Raw.data(r,:,2);
%     g2 = Raw.data(r+1,:,2);
%     % max == b1
%     E(r,(b1>=g1) & (b2<=g2) ) = 128;
%     E(r,(b1<=g1) & (b2>=g2) ) = 255;
% end
%
% for c = 1:Raw.cols-1
%     b1 = Raw.data(:,c,3);
%     b2 = Raw.data(:,c+1,3);
%     g1 = Raw.data(:,c,2);
%     g2 = Raw.data(:,c+1,2);
%     % max == b1
%     E((b1>=g1) & (b2<=g2),c ) = 128;
%     E((b1<=g1) & (b2>=g2),c ) = 255;
% end

%% Explore Strong Shadow Edge Feature
% Conclusion: shadow edge occurs at delta B-G peak
% IMPROVE: plot more in one figure.
% select one column
figure;
imshow(rot90(Raw.data));%, 'Xdata',[1 Raw.cols]- 255);
%%
[~,G,B] = Raw.eachChn();
hold on;
show_column_gb(ceil(Raw.cols/2));
show_column_gb(ceil(Raw.cols/4));
show_column_gb(ceil(Raw.cols*3/4)); % basevalue is fixed for one axes, so `area` cannot be used
camroll(-90);

%% Test shadow detection , shadow removal and ii iamge(shadow and light)
figure;
Mask = zeros([Raw.rows*Raw.cols, 3],class(Raw.data));% 'uint8'
Mask(B>G&B<120,3) = 125;% Mask(B>G&B<120,:) = [0 0 255];
Mask = reshape(Mask,[Raw.rows, Raw.cols, 3] );
% imshow(Mask);
imshow(imadd(Raw.data,Mask));

%% For this time we don't need to do shadow removal, just remove the false edges
% don't use shadow's boudary since it is variable to threshold
% use B-G peak

%% B-G peak

%%
    function show_column_gb(c)
        %imshow( rot90(imoverlay(Raw.data,SelectedCol,[255 0 0])) ,'Ydata',[1 Raw.cols]- c);%, 'Xdata',[1 Raw.cols]- 255);
        % imshow( imoverlay(Raw.data,SelectedCol,[255 0 0]) );
        
        % plot(R(:,c), 1:Raw.rows, 'r');
        % plot(G(:,c), 1:Raw.rows, 'g');
        % plot(B(:,c), 1:Raw.rows, 'b');
        %         diff = int32(B(:,c))-int32(G(:,c));
        % plot(diff, 1:Raw.rows, 'b', 'MarkerFaceColor', 'b');
        %area(double(B(:,c)')-double(G(:,c)'), 'FaceColor', 'y'); % area(int32(B(:,c))-int32(G(:,c))); %  'basevalue', -255
                b = Raw.cols-c;
                baseline = ones(1,Raw.rows)*b;
                fill_between_lines = @(X,Y1,Y2,C) fill( [X fliplr(X)],  [Y1 fliplr(Y2)], C );
                fill_between_lines( 1:Raw.rows, double(B(:,c)-G(:,c))'+b, baseline,'b');
                fill_between_lines( 1:Raw.rows, -double(G(:,c)-B(:,c))'+b, baseline,'g');
        % http://stackoverflow.com/questions/6245626/matlab-filling-in-the-area-between-two-sets-of-data-lines-in-one-figure
    end
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


