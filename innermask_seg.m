%% function for the segmentation of the inner chest posrtion using thresholding
%elimination of the vertebral body, using the mask that isolates the inner portion of the thorax

%inputs:
%- I: grey-scale image
%- contourmask: mask that isolates inner chest portion, resulting from
%contourinterpolation function
%- maskest: binary image of the chest used as mask
%- tl: threshold value for lung segmentation resulting from hist_thereshold function
%- th: threshold value for heart segmentation resulting from hist_thereshold function

%outputs:
%- Ic: binary image of inner chest portion (vertebral body excluded)
%- contpoint: coordinates of Ic boundary points 

function [Ic,contpoint] = innermask_seg(I,contourmask,maskest,tl,th)
    
    %% heart and cardiac structures segmentation
    
    %application of mask to isolate inner chest portion
    Inew=I;
    Inew(~contourmask)=0;
    
    %cardiac threshold applied to the new image
    Iheartpre=Inew>th;

    %isolation of pixels corresponding to vessels (low area elements)
    Ivessel=bwareafilt(Iheartpre,[1 30]);
    % pixels related to vessels assigned to 0 
    I(Ivessel)=0;
    
    %isolation of pixels corresponding to the heart
    Iheart=bwareaopen(Iheartpre,400);  
    %morpological operation of dilation
    se1h=strel('diamond',2);
    Iheart=imdilate(Iheart,se1h);
    %pixels related to vessels assigned to 0 
    I(Iheart)=0;


    %% thresholding for inner chest portion 

    %application of lung threshold 
    Ithpre=I>tl;
    
    %complementary image
    Icompl= imcomplement(Ithpre);
    
    %application of the binary mask (after erosion operation) to delete elements outside the chest 
    seI=strel('line',20,90);
    maskr=imerode(maskest,seI);
    Icompl(~maskr)=0;
    
    %elimination of small elements
    Itho=bwareaopen(Icompl,300);
    
    %application of morphological operations 
    Ifill=imfill(Itho,'holes');
    ser=strel('diamond',2);
    Ie=imopen(Ifill,ser);
    Ie=bwareaopen(Ie,200);    
    sec=strel('disk',5);
    Ic=imclose(Ie,sec);
    Ic=imfill(Ic,'holes');
    
    
    %count of inner mask elements
    [~, numObject] = bwlabel(Ic);
    % if innner mask is composed by more than 1 element
    if numObject>1
        %inner mask is the one resulting from previous function (with
        %vertebral body included)
        secme=strel('disk',3);
        contourmaske=imerode(contourmask,secme);
        Ic=contourmaske;
    end
    
    %coordinates of inner chest contour 
    contpoint=bwboundaries(Ic,'noholes');
    contpoint=contpoint{1};
    contpoint(:,[1 2]) = contpoint(:,[2 1]);
    
end