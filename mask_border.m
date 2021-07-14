%% function for the definition and application of mask that deletes pixel on the image borders not belonging to the chest 

%inputs:
%- I_imadjustpre: grey-scale image 
%- BW: binary image after manual thresholding 
 
%- i1mask: vector containing the number of columns on the right side not belonging to chest 
%- iendmask: vector containing the number of columns on the left side not belonging to chest

%outputs:
%- I_imadjust: grey-scale image after mask application 
%- BWt: binary image after mask application 
%- yhalf: y position of the point located in the half of the image (horizontal line)
%- xhalf: x position of the point located in the half of the image (vertical line)

function [Imask,BWt,yhalf,xhalf] = maskborder(I_imadjustpre,BW,i1mask,iendmask)
      
    
    %mean of number of cloumns (found for each slice) that have to be deleted: same mask for each slice
    mimask=floor(mean(i1mask));
    miendmask=floor(mean(iendmask));
    
    %mak definition
    mask=false(size(I_imadjustpre));
    %first columns of mask assigned to 1 
    mask(:,1:mimask)=true;
    %last columns of mask assigned to 1
    mask(:,end-miendmask:end)=true;
    
    % application of the mask to binary image
    BWt=BW;
    BWt(mask)=0;
    %operation that only keeps the largest element (chest)
    BWt=bwareafilt(BWt,1);
    
    % coordinates of the half point of image    
    [y ,x]=find(BWt);
    ymin=min(y);
    ymax=max(y);
    yhalf=round((ymin+ymax)/2);    
    xmin=min(x);
    xmax=max(x);
    xhalf=round((xmin+xmax)/2);
    
    %application of the mask to gray-scale image
    Imask=I_imadjustpre;
    Imask(~BWt)=0;
    
   
end

