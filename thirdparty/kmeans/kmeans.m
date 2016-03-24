function [mu,mask]=kmeans(ima,k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   kmeans image segmentation
%
%   Input:
%          ima: grey color image
%          k: Number of classes
%   Output:
%          mu: vector of class means 
%          mask: clasification image mask
%
%   Author: Jose Vicente Manjon Herrera
%    Email: jmanjon@fis.upv.es
%     Date: 27-08-2005
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check image
ima=double(ima);
copy=ima;         % make a copy
ima=ima(:);       % vectorize ima
mi=min(ima);      % deal with negative 
ima=ima-mi+1;     % and zero values

s=length(ima);

% create image histogram

m=max(ima)+1;
h=zeros(1,m);
hc=zeros(1,m);

for i=1:s
  if(ima(i)>0) h(ima(i))=h(ima(i))+1;end;
end
ind=find(h);
hl=length(ind);

% initiate centroids

mu=(1:k)*m/(k+1);

% start process

while(true)
  
  oldmu=mu;
  % current classification  
 
  for i=1:hl
      c=abs(ind(i)-mu);
      cc=find(c==min(c));
      hc(ind(i))=cc(1);
  end
  
  %recalculation of means  
  
  for i=1:k, 
      a=find(hc==i);
      mu(i)=sum(a.*h(a))/sum(h(a));
  end
  
  if(mu==oldmu) break;end;
  
end

% calculate mask
s=size(copy);
mask=zeros(s);
for i=1:s(1),
for j=1:s(2),
  c=abs(copy(i,j)-mu);
  a=find(c==min(c));  
  mask(i,j)=a(1);
end
end

mu=mu+mi-1;   % recover real range

