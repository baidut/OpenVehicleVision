function ok = foreach_frame_do(file, func, frameRate)
%FOREACH_FRAME_DO batch processing each frame of video
% USAGE:
%  foreach_frame_do('./ronda42_mpeg4.avi', @imshow)
%  foreach_frame_do('./ronda42_mpeg4.avi', @(frame, index) imwrite(frame, num2str(index, 'ronda42_mpeg4/%05d.jpg')))
%  foreach_frame_do('videos/road.avi', @imdetectlane)
% Probelme to be solved(7.14.0.739 (R2012a))
% 	Error using VideoReader/init (line 447)
% 	The file requires the following codec(s) to be installed on your system:
		% H264

if verLessThan('matlab', '7.11')
% R2010a(7.10) Functions and Function Elements Being Removed [includes aviread]
% R2010b(7.11) mmreader Renamed VideoReader 
% view the release notes page for detail http://www.mathworks.com/help/matlab/release-notes-older.html
	mov = mmreader(file);
	frames = read(mov);
    if nargin < 3
       frameRate = mov.FrameRate; 
    end
	for idx = 1 : mov.FrameRate/frameRate : size(frames, 4)
		image = frames(:,:,:,idx);
		func(image, idx);
	end
else
	vidObj = VideoReader(file);
	
    if nargin < 3 % vidObj.FrameRate == frameRate
        idx = 0;
        while hasFrame(vidObj)
            vidFrame = readFrame(vidObj);
            idx = 1 + idx;
            func(vidFrame, idx);
        end
    else
        for n = 1 : vidObj.FrameRate/frameRate : vidObj.NumberOfFrames
            vidFrame = read(vidObj, round(n));
            func(vidFrame, n);
        end
    end

end


 % MMREADER has been removed. Use VIDEOREADER instead.

% VERSION

% For example:
% >> version
% 7.14.0.739 (R2012a)
% >> verLessThan('matlab', '7.15')
% 1
% >> verLessThan('matlab', '7.14')
% 0

% Here are the MCR and MATLAB Compiler versions for some releases of MATLAB:
 % ----------------------------------------------
 % MATLAB            | MATLAB        | MATLAB   | 
 % Release           | Component     | Compiler | 
 %                   | Runtime (MCR) | Version  | 
 % ----------------------------------------------
 % R14    (7.0)      | 7.0           | 4.0      | 
 % R14SP1 (7.0.1)    | 7.1           | 4.1      | 
 % R14SP2 (7.0.4)    | 7.2           | 4.2      | 
 % R14SP3 (7.1)      | 7.3           | 4.3      | 
 % R2006a (7.2)      | 7.4           | 4.4      | 
 % R2006b (7.3)      | 7.5           | 4.5      | 
 % R2007a (7.4)      | 7.6           | 4.6      | 
 % R2007b (7.5)      | 7.7           | 4.7      | 
 % R2008a (7.6)      | 7.8           | 4.8      | 
 % R2008b (7.7)      | 7.9           | 4.9      | 
 % R2009a (7.8)      | 7.10          | 4.10     | 
 % R2009b (7.9)      | 7.11          | 4.11     | 
 % R2009bSP1 (7.9.1) | 7.12          | 4.12     | 
 % R2010a (7.10)     | 7.13          | 4.13     | 
 % R2010b(7.11)      | 7.14          | 4.14     |
 % R2010bSP1 (7.11.1)| 7.14.1        | 4.14.1   |
 % R2010bSP2 (7.11.2)| 7.14.2        | 4.14.1   |
 % R2011a (7.12)     | 7.15          | 4.15     |
 % R2011b (7.13)     | 7.16          | 4.16     |
 % R2012a (7.14)     | 7.17          | 4.17     |
 % R2012b (8.0)      | 8.0           | 4.18     |
 % R2013a (8.1)      | 8.1           | 4.18.1   |
 % R2013b (8.2)      | 8.2           | 5.0      |
 % R2014a (8.3)      | 8.3           | 5.1      |
 % R2014b (8.4)      | 8.4           | 5.2      |
 % ----------------------------------------------