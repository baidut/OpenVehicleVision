%% 3D shadow free image
classdef ying2016mm
    
    properties (Constant)
        % The params are tuned manually for good ii result
        % For tuning params, see rgb2ii.test
        ALVAREZ2011 = struct( ...
            'name', 'Alvarez2011', ...
            'func', @(x,theta)GetInvariantImage(image, theta, 0, 1), ...
            'param', {num2cell([ 66, 79, 40, 40, 39, 39, 61,108, 76, 80],1)}...
            );
        MADDERN2014 = struct( ...
            'name', 'Maddern2014', ...
            'func', @(image, alpha)rgb2ii.maddern2014(image, alpha, false), ...
            'param', {num2cell([.69,.52,.42,.42,.43,.43,.66,.90,.81,.83],1)}...
            );
        OURS = struct( ...
            'name', 'Ours', ...
            'func', @rgb2ii.ying2016, ...
            'param', {num2cell(255*[0.2,.10,.10,.06,.05,.05,.05,.13,.07,.07],1)}...
            );
    end
    
    methods (Static)
        
        function fig(no)
            % DESCRIP
            % diplay or output fig in paper ying2016mm
            %
            % PARAMS
            % #no array
            %
            % USE CASES
            % fig           % show all figures
            % fig(1)
            % fig(2:3)
            % fig([1 3 4])
            
            figs = {...
                @ii_3d ...
                @ii_ours_on_kitti ...
                @ii_ours_on_roma ...
                @road_seg_based_on_ii,...
                @ii_help_edge ...
                @ii_help_edge_param ...
                @ii_help_seg ...
                @compare_ii_road_seg ...
                @kitti_results ...
                @ii_dataset
                };
            
            if nargin == 0
                % show all figs
                no = 1:numel(figs);
            end
            
            for n = no
                figs{n}();
            end
            
        end
        
        %%
        function road_seg_based_on_ii()
            % .05*255 \LRAlargeur13032003\IMG02210
            % 0.2*255 \BDXD54\IMG00002
            rawImg = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rawImg = impyramid(rawImg,'reduce');
            rawImg = impyramid(rawImg,'reduce');
            rawImg = impyramid(rawImg,'reduce');
            rawImg = rawImg(ceil(end/2):end,:,:);
            ii_method = @(rgb) rgb2ii_2d(rgb,.2*255, [2,3]);
            ii_image = road_detection_via_ii(rawImg, ii_method, {}, 1);
        end
        
        %%
        function ii_ours_on_kitti()
            % KITTI
            
            % for kitti need to inverse
            
            % image size is not unique in kitti
            % src = '%datasets\KITTI\data_road\training\image_2\*.png';
            % rawImg = foreach_file_do(src,@imread);
            
            % src = vvDataset('%datasets\KITTI\data_road\training\image_2\');
            % E:\Documents\MATLAB\OpenVehicleVision\%datasets\KITTI\data_road_right\testing\image_3
            
            available = { '%datasets\KITTI\data_road\training\image_2\*.png'...
                '%datasets\KITTI\\data_road\testing\image_2\*.png'...
                '%datasets\KITTI\data_road_right\training\image_3\*.png'...
                '%datasets\KITTI\data_road_right\testing\image_3\*.png'...
                };
            filestr = available{4};
            
            videofilename = ['%results/', strrep(filestr(11:end-6), '\', '_') '.avi'];
            video3dfilename = ['%results/', strrep(filestr(11:end-6), '\', '_') '_3d.avi'];
            
            files = foreach_file_do(filestr,@(x)x);
            
            % %% biggest size
            % imgscell = cellfun(@imread,files,'UniformOutput',false);
            % imgsSize = cellfun(@(x)transpose(size(x)),imgscell,'UniformOutput',false);
            % maxSize = max([imgsSize{:}].'); % imgsSize is an 1*N cell array
            % disp(maxSize);% 376        1242           3
            
            N = numel(files);
            im = imread(files{1});
            maxSize = [376 1242];
            frames = zeros([maxSize.*[2 1] 3 N]);
            frame3d = zeros([maxSize.*[2 1] 3 N]);
            
            for k = 1:N
                disp(k/N);
                im = imread(files{k});
                im = padarray(im,[maxSize 3]-size(im),0,'post');
                
                imr = impyramid(im,'reduce');
                
                grayImg = im2double(rgb2gray(imr));
                alvarez2011 = rgb2ii.alvarez2011(imr,.6,true);
                will2014 = rgb2ii.will2014inv(imr,.53);
                ours = dualLaneDetector.rgb2ii_ori(imr,.06);
                
                lowhalf = repmat([grayImg alvarez2011;...
                    ours will2014], [1,1,3]); % gray to rgb
                
                % Frames of type double must be in the range 0 to 1.
                lowhalf(lowhalf>1) = 1;
                lowhalf(lowhalf<0) = 0;
                frames(:,:,:,k) = [im2double(im);lowhalf];
                
                %%% 3D shadow free
                ii3d = rgb2ii_3d(im);
                frame3d(:,:,:,k) = [im2double(im);ii3d];
            end
            
            % disp('Saving frames...'); % save/load are time-consuming
            % save('%mat/ii_KITTI_data_road_training_image_2.mat','frames','-v7.3');
            % load/save is very slow, so we do not save
            % implay(frames);
            
            disp('Writing to files...');
            
            v = VideoWriter(videofilename);
            v3d = VideoWriter(video3dfilename);
            
            open(v);
            open(v3d);
            
            for k = 1:N % N = 289
                disp(k/N);
                writeVideo(v,frames(:,:,:,k));% double image will become gray
                writeVideo(v3d,frame3d(:,:,:,k));
            end
            
            close(v);
            close(v3d);
            
            %282 285
        end
        
        function ii_ours_on_roma()
            rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            gray = im2double(rgb2gray(rgb));
            ii = rgb2ii_2d(rgb,0.2*255,[2,3]);
            alvarez2011 = rgb2ii.alvarez2011(rgb,0.1471,0);
            will2014 = rgb2ii.will2014inv(rgb,0.6029);
            
            compare_ii = [gray, ii, alvarez2011, will2014];
            compare = [im2double(rgb), repmat(compare_ii,[1 1 3])];
            imshow(compare);
            imwrite(compare,'%results/ii_ours_on_roma.jpg');
        end
        
        function ii_3d()
            rgb = imread('%datasets\KITTI\data_road\training\image_2\uu_000086.png');
            
            ii = rgb2ii_3d(rgb);
            
            fig = [im2double(rgb); ii];
            
            imwrite(fig,'%results/rgb2ii_3d.jpg');
        end
        
        function ii = rgb2ii_2d(rgb, c, chns)
            % since the / we cannot use int type
            % log
            if nargin < 3
                chns = [2,3]; % gb2ii
            end
            
            rgb = double(rgb); % im2int16 will do rescaling, so int16 should be used
            
            R1 = rgb(:,:,chns(1));
            R2 = rgb(:,:,chns(2));
            
            ii =  2 - (R1+c)./(R2+1); % +1 to avoid /0
            %     max(ii(:))
            %     min(ii(:))
            ii(ii<0) = 0;
            ii(ii>1) = 1; % ii double
        end
        
        function ii = rgb2ii_3d(rgb)
            
            ii2dRG = rgb2ii_2d(rgb,12.4501,[1,2]); % dR > dG
            ii2dGB = rgb2ii_2d(rgb,18.7499,[2,3]); % dG > GB
            ii2dRB = rgb2ii_2d(rgb,27.9750,[1,3]); % dR > GB
            % ii = cat(3, ii2dRB, ii2dRG, ii2dGB);
            ii = cat(3, ii2dGB, ii2dRG, ii2dRB);
            
        end
        
        function ii_help_edge_param()
            rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            
            %     gray = im2double(rgb2gray(rgb));
            % change gray to ii
            gray = rgb2ii_2d(rgb,[2,3],.2*255); %im2double(rgb2gray(rgb));
            rgb = repmat(gray, [1 1 3]);
            
            %% Sobel
            thresh = Slider([0 0.2]);
            direction = Popupmenu({'both','horizontal','vertical'});
            thinning = Popupmenu({'thinning','nothinning'});
            sobel = ImCtrl(@edge, gray, 'sobel', thresh, direction, thinning);
            
            %% Canny
            range = RangeSlider([0 1]);
            sigma = Slider([0 10]);
            canny = ImCtrl(@edge, gray, 'canny', range, sigma);
            
            %% PDollar
            pdollar = vvEdge.pdollar(rgb);
            
            Fig.subimshow(rgb, sobel, canny, pdollar);
        end
        
        function ii_help_edge()
            %% TODO: ADD http://cn.mathworks.com/help/fuzzy/examples/fuzzy-logic-image-processing.html
            
            rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            
            %% improve
            gray = rgb2ii_2d(rgb,.2*255, [2,3]); %im2double(rgb2gray(rgb));
            rgb = repmat(gray, [1 1 3]);
            
            sobel = edge(gray, 'sobel',0.0853,'both','thinning');
            canny = edge(gray, 'canny',[0.1000,0.4000],2.6471);
            pdollar = vvEdge.pdollar(rgb);
            %     Fig.subimshow(rgb, sobel, canny, pdollar);
            cd E:\Documents\MATLAB\OpenVehicleVision;
            imwrite(sobel,'%results/edge/sobel2.png');
            imwrite(canny,'%results/edge/canny2.png');
            imwrite(pdollar,'%results/edge/pdollar2.png');
            imwrite(rgb,'%results/edge/rgb.png');
            imwrite(gray,'%results/edge/gray.png');
            
            all = [gray sobel canny pdollar];
            imwrite(all,'%results/edge/all.png');
            return;
            
            %% ED note vcredist_x64.exe is required to install!!!
            % or no edge output
            filtered = wiener2(gray, [8 8]);
            I = repmat(filtered, [1 1 3]);
            h = figure;
            imshow(zeros(size(I)));
            hold on;
            lineSegments = EDLines(I, 1);
            plotobj(lineSegments);
            print(h, '-dpng', '%results/edge/EDLines2.png');
        end
        
        function ii_help_seg()
            
            rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            
            %% improve
            gray = rgb2ii_2d(rgb,[2,3],.2*255); %im2double(rgb2gray(rgb));
            ii = repmat(im2uint8(gray), [1 1 3]);
            
            label = vvSeg.felzen(rgb, 0.5, 600, 300);
            res = label2rgb(label.data);
            imwrite(res,'%results/seg/seg_via_raw.png');
            
            label = vvSeg.felzen(ii, 0.5, 600, 300);
            res = label2rgb(label.data);
            imwrite(res,'%results/seg/seg_via_ii.png');
        end
        
        function compare_ii_road_seg()
            tune = false;%true;

            algo.name = 'ours+felzen';
            algo.func = @ying2016mm.road_seg_via_ii_felzen;
            algo.param = {};
            
            ii_algo.func = ying2016mm.OURS.func;
            
            %% tune road_seg_via_ii_felzen
            if tune
                ii_algo.func = ying2016mm.OURS.func;
                ii_algo.param = ying2016mm.OURS.param(1);
                
                rawImg = imread('%datasets\roma\BDXD54\IMG00002.jpg');
                
                iiImg =  ii_algo.func(rawImg,ii_algo.param{:});
                ii = repmat(im2uint8(iiImg), [1 1 3]);
                
                vvSeg.felzen(ii);%1.5,600,1000
                return;
            end
            
            for param = ying2016mm.OURS.param
                ii_algo.param = param;
                algo.param{end+1} = ii_algo;
            end
            
%             RomaDataset.eval_road(algo, 1, 1)
                RomaDataset.eval_road(algo, 1)
                %TODO sep processing and evaluating
        end
        
        %% Framework of Road detection via ii
        function res = road_seg_via_ii_felzen(rawImg, ii_algo, debugLevel)
            
            if nargin < 3
                debugLevel = 0; % no debug info dumping
                % 1
                % 2
            end
            
            %% Illumination Invariant Imaging
            % RGB --> II
            iiImg =  ii_algo.func(rawImg,ii_algo.param{:});
            ii = repmat(im2uint8(iiImg), [1 1 3]);
            label = vvSeg.felzen(ii, 1.5, 600, 5000);%1.5,600,1000
%             1.5000,551.9195,77111;
            RoadFace = label.maxarea();
            Fig.subimshow(rawImg, label2rgb(label.data), RoadFace);
            res = RoadFace.data;
            
            %% Debug
            if debugLevel > 4
                %% output result
            end
            
        end
        
        function roma_results()
            
            rgb = imread('%datasets\roma\BDXD54\IMG00002.jpg');
            rgb = impyramid(rgb,'reduce');
            rgb = impyramid(rgb,'reduce');
            
            %% improve
            gray = rgb2ii_2d(rgb,.2*255,[2,3]); %im2double(rgb2gray(rgb));
            ii = repmat(im2uint8(gray), [1 1 3]);
            
            label = vvSeg.felzen(rgb, 0.5, 600, 300);
            res = label2rgb(label.data);
            imwrite(res,'%results/seg/seg_via_raw.png');
            
            label = vvSeg.felzen(ii, 0.5, 600, 300);
            res = label2rgb(label.data);
            imwrite(res,'%results/seg/seg_via_ii.png');
        end
        
        
        function kitti_results()
            % tune_ii_param;return;
            
            % extract ground truth
            
            % I = imread('%results\compare\Persp_umm_road_000025.png');
            % G = I(:,:,2);
            % G(1:ceil(end/3),:) = 0;
            % bw = BwImg(G==255);
            % gt = bw.maxarea();
            % imwrite(gt, '%results\compare\gt_umm_road_000025.png');
            % return;
            %% UU_ROAD
            
            %% UM_ROAD
            
            testImages = {'uu_000020.png','uu_000027.png' ...
                'um_000095.png'...
                'umm_000025.png'...
                'umm_000066.png'
                };
            %
            now_test = testImages{4};
            % 209 216
            % 271 44
            % 77 94 umm_000095.png
            % umm_000025
            % umm_000066
            rgb = imread(['%datasets\KITTI\data_road\testing\image_2\', now_test]);
            
            gray = im2double(rgb2gray(rgb));
            alvarez2011 = rgb2ii.alvarez2011(rgb,.1,false); % .6 bad .07
            will2014 = rgb2ii.will2014(rgb,.53);
            ours = rgb2ii_2d(rgb,18.7499); % dualLaneDetector.rgb2ii_ori(imr,.06);
            saturation = vvFeature.S(rgb);
            s2 = vvFeature.S2(rgb);
            
            % min(will2014(:)) -Inf
            % max(will2014(:)) 2.4726
            % min(alvarez2011(:)) 0-1
            % max(alvarez2011(:))
            % Fig.subimshow(alvarez2011,will2014,ours);return;
            
            test_ii_kitti(now_test, gray);
            test_ii_kitti(now_test, alvarez2011);
            test_ii_kitti(now_test, will2014);
            test_ii_kitti(now_test, ours);
            test_ii_kitti(now_test, rgb);
            test_ii_kitti(now_test, saturation);
            test_ii_kitti(now_test, s2);
            
        end
        
        function test_ii_kitti(now_test, raw_ii)
            gt = imread(['%results\compare\gt\image_2\', now_test]);
            
            %% improve
            if size(raw_ii,3) == 1
                ii = repmat(im2uint8(raw_ii), [1 1 3]);
            else
                ii = im2uint8(raw_ii);
            end
            %or
            % ii = im2uint8(rgb2ii_3d(rgb));
            
            label = vvSeg.felzen(ii, 1.5, 500, 800);% near filed should have big "min"  do segmentation in IPM image.
            % Get IPM image.
            res = label2rgb(label.data);
            % Fig.subimshow(gt, ii,res);
            
            [~,index] = LabelImg.maxareaOf(label.data(ceil(end*2/3):end,:));
            
            result = label.data == index;
            
            algoname = inputname(2);
            disp(algoname);
            eval = ConfMat({result},{gt},1);
            % imshow(roiImg/3+eval.mask{1});
            disp(eval);
            % 0.98484    0.96515    0.9737    0.011512    0.026296
            % part of error are caused by false gt label
            
            % compare with gt
            
            imwrite(label2rgb(label.data),['%results/compare/label_' algoname '_' now_test]);
            imwrite(raw_ii,['%results/compare/ii_'  algoname '_'  now_test]);
            imwrite(result,['%results/compare/res_' algoname '_' now_test]);
        end
        
        function tune_ii_param()
            inputImage = ImCtrl(@imread, FilePick());
            Ours = ImCtrl(@rgb2ii_2d, inputImage, Slider([0 50], 'Value', 0.2));
            Alvarez2011 = ImCtrl(@rgb2ii.alvarez2011, inputImage, Slider([0 1], 'Value', 0.2), 1);
            
            f = Fig;
            f.maximize();
            f.subimshow(inputImage, Ours, Alvarez2011);
        end
        
        %% Test on zhwang Illumination_Datasets and Phos
        function ii_dataset(no)
            %    images = {'%datasets\Illumination Datasets\corridor\img1.ppm'...
            %                       '%datasets\Illumination Datasets\corridor\img1.ppm'...
            %             };
            if nargin<1
                no = 1;
            end
            
            datasets = {...
                'Phos_0_8MP\scene1\nonuni_scene1_*.png'...
                'Illumination Datasets\corridor\img*.ppm'...
            };
            datasets = strcat('%datasets\',datasets);
            files = datasets{no};
%             im = cell([1 5]);
%             for n = 1:5
%                 im{n} = imread(['%datasets\Illumination Datasets\corridor\' num2str(n,'img%d.ppm')]);
%             end
            im = foreach_file_do(files, @imread);
            inputImage = [im{:}];
%             imshow(inputImage);
            
            b = Slider([0 255], 'Value', 33);
            alpha = Slider([0 1]); % 0-1 is ok, 1-255 litte change
            Alvarez2011 = ImCtrl(@rgb2ii.alvarez2011, inputImage, Slider([0 180], 'Value', 33),false); %ying2016
            Maddern2014 = ImCtrl(@rgb2ii.maddern2014, inputImage, alpha); %ying2016
            Ours = ImCtrl(@rgb2ii.ying2016, inputImage, b);
%             Fig.subimshow(Alvarez2011); %inputImage, 
%             Fig.subimshow(Maddern2014); %inputImage, 
            Fig.subimshow(Ours); %inputImage, 
        end
        
        function ii_dataset_tune()
            %    images = {'%datasets\Illumination Datasets\corridor\img1.ppm'...
            %                       '%datasets\Illumination Datasets\corridor\img1.ppm'...
            %             };
            im = cell([1 5]);
            res = cell([1 5]);
            b = Slider([0 255], 'Value', 33);
            
            for n = 1:5
                im{n} = imread(['%datasets\Illumination Datasets\corridor\' num2str(n,'img%d.ppm')]);
                res{n} = ImCtrl(@rgb2ii.ying2016, im{n}, b);
            end
            figure,maxfig;
            Fig.subimshow(res{:}); %inputImage, 
        end
        
    end
end