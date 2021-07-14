%% function for lung segmentation (by using threshold found with hist_threshold function)

%inputs:
%- I_imadjust: grey-scale image
%- threshold: threshold found with histogram partitioning method 
%- mask: binary image representin the chest area used as mask
%- xhalf:x position of the point located in the half of the image
%- BWt: binary image of chest

%outputs:
%- BWlung: binary image resulting from lung segmentation 
%- lung1: matrix containing the coordinates relating to right lung 
%- lung2: matrix containing the coordinates relating to left lung 
%- lung_fraction: lung percentage

function [BWlung,lung1,lung2,lung_fraction] = lungsegmentation(I_imadjust,threshold,mask,xhalf,BWt)
    
    %threshold application 
    BWIt = I_imadjust > threshold;

    %complementary image
    BWlungc = imcomplement(BWIt);
    
    %application of binary image of chest as mask in order to delete white border pixels
    BWlungmask=BWlungc;
    %operation of erosion to strict the mask
    seI=strel('line',10,90);
    maskr=imerode(mask,seI);
    BWlungmask(~maskr)=0;


    %ooperation of erosion applied on lung segmentation result
    se=strel('rectangle',[2 1]);
    BWlung1 = imerode(BWlungmask,se);
    
    %operation that only keeps the two largest elements 
    BWlung2 = bwareaopen(BWlung1, 300);
    BWlung2 = bwareafilt(BWlung2, 2);
    
    
    %operation of closing
    se2=strel('disk',7);
    BWlung4=imclose(BWlung2,se2);
    %filling of holes
    BWlung=imfill(BWlung4,'holes');
   


    %% matrices corresponding to lungs 
    
    [rp, cp]=find(BWlung);
    lungs=[cp rp];

    %right half of image (right lung)
    ilung1= lungs(:,1)<=xhalf;
    lung1=lungs(ilung1,:);
    %left half of image (left lung)
    lung2=lungs(~ilung1,:);

    %% lung percentage
    lung_size=nnz(BWlung);
    thorax_size=nnz(BWt);    
    lung_fraction=round(lung_size./thorax_size,2);
    
end

