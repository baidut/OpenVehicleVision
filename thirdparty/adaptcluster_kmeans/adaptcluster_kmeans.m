function [lb,center] = adaptcluster_kmeans(im)

% This code is written to implement kmeans clustering for segmenting any
% Gray or Color image. There is no requirement to mention the number of cluster for
% clustering. 
% IM - is input image to be clustered.
% LB - is labeled image (Clustered Image).
% CENTER - is array of cluster centers.
% Execution of this code is very fast.
% It generates consistent output for same image.

% Written by Ankit Dixit.
% January-2014.


if size(im,3)>1
   [lb,center] = ColorClustering(im); % Check Image is Gray or not.
else
    [lb,center] = GrayClustering(im); 
end


function [lb,center] = GrayClustering(gray)
gray = double(gray);
array = gray(:); % Copy value into an array.
% distth = 25;
i = 0;j=0; % Intialize iteration Counters.
tic
while(true)
    seed = mean(array); % Initialize seed Point.
    i = i+1; %Increment Counter for each iteration.
    while(true)
        j = j+1; % Initialize Counter for each iteration.
        dist = (sqrt((array-seed).^2)); % Find distance between Seed and Gray Value.
        distth = (sqrt(sum((array-seed).^2)/numel(array)));% Find bandwidth for Cluster Center.
        %         distth = max(dist(:))/5;
        qualified = dist<distth;% Check values are in selected Bandwidth or not.
        newseed = mean(array(qualified));% Update mean.
        
        if isnan(newseed) % Check mean is not a NaN value.
            break;
        end
        
        if seed == newseed || j>10 % Condition for convergence and maximum iteration.
            j=0;
            array(qualified) = [];% Remove values which have assigned to a cluster.
            center(i) = newseed; % Store center of cluster.
            break;
        end
        seed = newseed;% Update seed.
    end
    
    if isempty(array) || i>10 % Check maximum number of clusters.
        i = 0; % Reset Counter.
        break;
    end
    
end
toc

center = sort(center); % Sort Centers.
newcenter = diff(center);% Find out Difference between two consecutive Centers. 
intercluster = (max(gray(:)/10));% Findout Minimum distance between two cluster Centers.
center(newcenter<=intercluster)=[];% Discard Cluster centers less than distance.

% Make a clustered image using these centers.

vector = repmat(gray(:),[1,numel(center)]); % Replicate vector for parallel operation.
centers = repmat(center,[numel(gray),1]);

distance = ((vector-centers).^2);% Find distance between center and pixel value.
[~,lb] = min(distance,[],2);% Choose cluster index of minimum distance.
lb = reshape(lb,size(gray));% Reshape the labelled index vector.


function [lb,center] = ColorClustering(im)

im = double(im);
red = im(:,:,1); green = im(:,:,2); blue = im(:,:,3);

array = [red(:),green(:),blue(:)];
% distth = 25;
i = 0;j=0;
tic
while(true)
    
    seed(1) = mean(array(:,1));
    seed(2) = mean(array(:,2));
    seed(3) = mean(array(:,3));
    
    i = i+1;
    while(true)
        j = j+1;
        
        seedvec = repmat(seed,[size(array,1),1]);
        
        dist = sum((sqrt((array-seedvec).^2)),2);
        
         distth = 0.25*max(dist);
        qualified = dist<distth;
        
        newred = array(:,1);
        newgreen = array(:,2);
        newblue = array(:,3);
        
        newseed(1) = mean(newred(qualified));
        newseed(2) = mean(newgreen(qualified));
        newseed(3) = mean(newblue(qualified));
        
        if isnan(newseed)
            break;
        end
        
        if (seed == newseed) | j>10
            j=0;
            array(qualified,:) = [];
            center(i,:) = newseed;
            %             center(2,i) = nnz(qualified);
            break;
        end
        seed = newseed;
    end
    
    if isempty(array) || i>10
        i = 0;
        break;
    end
    
end
toc
centers = sqrt(sum((center.^2),2));
[centers,idx]= sort(centers);


while(true)
newcenter = diff(centers);
intercluster =25; %(max(gray(:)/10));
a = (newcenter<=intercluster);
% center(a,:)=[];
% centers = sqrt(sum((center.^2),2));
centers(a,:) = [];
idx(a,:)=[];
% center(a,:)=0;
if nnz(a)==0
    break;
end

end
center1 = center;
center =center1(idx,:);
% [~,idxsort] = sort(centers) ;
vecred = repmat(red(:),[1,size(center,1)]);
vecgreen = repmat(green(:),[1,size(center,1)]);
vecblue = repmat(blue(:),[1,size(center,1)]);

distred = (vecred - repmat(center(:,1)',[numel(red),1])).^2;
distgreen = (vecgreen - repmat(center(:,2)',[numel(red),1])).^2;
distblue = (vecblue - repmat(center(:,3)',[numel(red),1])).^2;

distance = sqrt(distred+distgreen+distblue);
[~,label_vector] = min(distance,[],2);
lb = reshape(label_vector,size(red));
%


