%% function for the segmentation of inner chest area and of lungs after correction
%% funzione per la segmentazione della porzione interna del torace e dei polmoni dopo la correzione 

%inputs:
%- c_corr: coordinates of inner chest contour points after correction process 
%- I_imadjust: grey-scale image

%outputs:
%- innermaskn: binary image of inner chest area
%- Iinner: grey-scale image of inner chest are
%- Ilung: binary image of lungs after correct segmentation 

function [innermaskn,Iinner,Ilung] = inneranalysis(c_corr,I_imadjust)
    
    %maschera contorno interno
    innermask= poly2mask(c_corr(:,1),c_corr(:,2),size(I_imadjust,1),size(I_imadjust,2));
    
    %morphological operators applied to inner mask 
    ser=strel('line',5,0);
    innermaskn=imclose(innermask,ser);
    innermaskn=imfill(innermaskn,'holes');
    
    %inner mask applied to grey-scale image
    Iinner=I_imadjust;
    Iinner(~innermaskn)=0;
    
    %background pixel assigned to a (white) 
    background=(~Iinner);
    Iinner(background)=1;
    
    %manual threshold for blacking out the vessel 
    I=Iinner;
    Iheart=I>0.3;
    Ivessel=bwareafilt(Iheart,[1 50]);
    I(Ivessel)=0;
    
    %manual threshold for lung segmentation 
    Ilungpre=I<0.3;
    
    %application of morphological operators 
    Ilung1=imfill(Ilungpre,'holes');
    ser=strel('line',3,90);
    Ilung2=imerode(Ilung1,ser);
    Ilung3=bwareaopen(Ilung2,30);
    sec=strel('disk',7);
    Ilung=imclose(Ilung3,sec);
    Ilung=imfill(Ilung,'holes');
    Ilung=bwareafilt(Ilung,2);
    

    
end

