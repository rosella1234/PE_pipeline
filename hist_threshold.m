%% function that detects the threshold based on histogram partitioning method
% the function identifies the concavity surrounding the two main
% peaks of the histogram by looking for the position of maximum divergence
% between the histogram and a Guassian fitting.
% The function can be applied both to eliminate background pixels and
% than to identify the threshold for lung segmentation, depending on
% of the greyvaluemax and greyvaluemin values ​​entered in input

%inputs:
%- counts: counts resulting from image histogram 
%- binlocations: grey values resulting from image histogram
%- greyvaluemin: minimum grey value considered by function 
%- greyvaluemax: maximum grey value considered by function 
%outputs:
%- l: threshold resulting from histogram partitioning method 
%- iltot: index in binilocation matrix corresponding to threshold value


function [l,iltot] = hist_threshold(counts,binlocations,greyvaluemin,greyvaluemax)
    
    %counts preparation
    counts=smooth(binlocations,counts);
    %elimination of zero element in histogram 
    a=find(counts==0);
    counts(a)=[];
    binlocations(a)=[];
    
%     figure
%     plot(binlocations,counts)

    % binlocations indices corrisponding to grey values considered as input
    iselected=find(binlocations>=greyvaluemin & binlocations<=greyvaluemax);
    counts1=counts(iselected);
    binlocations1=binlocations(iselected);
    
    %% definition of a Gaussian curve in the same range of histogram grey values
    
    countstot=sum(counts1);
    % mean value 
    mmatrix=binlocations1.*counts1;
    m=sum(mmatrix)/countstot;
    % variance 
    variancematrix=((binlocations1-m).^2).*counts1;
    variance2=sum(variancematrix)/countstot;
    variance=sqrt(variance2);
    
    x1lim=m-variance;
    x2lim=m+variance;
    
    %gaussian equation
    y = normpdf(binlocations1,m,variance);
    sumy=sum(y);
    %gaussian curve has the same area under the curve as the one under the histogram 
    y1=(countstot/sumy).*y;

%     figure
%     plot(binlocations1,counts1)
%     hold on
%     plot(binlocations1,y1,'g')
%     hold on
%     xline(m,'color','c')
% %     xline(x1lim,'color','y')
% %     xline(x2lim,'color','y')
%     hold on

    %indices of values included around the mean value area
    n=find(binlocations1>=x1lim & binlocations1 <= x2lim);
    
    %difference between gaussian and histogram points 
    d=y1(n)-counts1(n);
    
    %index that maximizes the difference between gaussian and histogram points 
    [~,il]=max(d);
    iltot=il+n(1)-1;
    
    %threshold value 
    l=binlocations1(iltot);
%      
%     xline(l,'color','r')
%     xlabel('Bin locations')
%     ylabel('Counts')
%     ylim([0 3000])
%     hold off
%     countsnew=counts;
%     binlocationsnew=binlocations;
%     countsnew(1:il)=[];
%     binlocationsnew(1:il)=[];



end

