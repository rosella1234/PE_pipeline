%% function for the interpolation of points found by innercontour_seg function
% the innercontour_seg function depends on the correct segmentation of the
% lungs, which often does not occur due to similarity in the grey values
%between lungs and thoracic tissue. This function has the goal of
% check the points found, delete the invalid ones and then
% do an interpolation of the correct points to obtain the inner contour
% of the thorax with the vertebral body include


%inputs:
%- pmin: coordinates of minimum point of outer chest contour 
%- pmax1: coordinates of first maximum point of outer chest contour 
%- pmax2: coordinates of second maximum point of outer chest contour 
%- pint: intersection points found by innercontour_seg function
%- I_imadjust: grey-scale image
%- contour: coordinates of outer contour points 

%output:
%- pcontour: coordinates of inner contour points
%- contourmask: binary image of mask representng the inner chest portion


function [pcontour,contourmask] = contourinterpolation(pmin,pmax1,pmax2,pint,I_imadjust,contour)

%% preparation of points for interpolation 

    %deletion of points outside the outer chest contour (errors in the previous function)
    contestmax=max(contour(:,1));
    contestmin=min(contour(:,1));
    icpintdelete1=find(pint(:,1)>=contestmax);
    icpintdelete2=find(pint(:,1)<=contestmin);
    icpintdelete=[icpintdelete1;icpintdelete2];
    pint(icpintdelete,:)=[];

    %end point of upper contour: point with maximum x coordinate  
    [pmax,ixmax]=max(pint(:,1));
    %deletion of points at the same x coordinate as the end point 
    isamexmax=find(pint(ixmax+1:end,1)==pmax);
    pint(isamexmax+ixmax,:)=[];

    %partition in 2 groups of points: upper and lower contour
    pint1=pint(1:ixmax,:);
    pint2=pint(ixmax:length(pint),:);
    
    %x coordinates sorted in ascending order (upper contour)
    [pint1x,ip1]=sort(pint1(:,1));
    %x coordinates sorted in descending order (lower contour)
    [pint2x,ip2]=sort(pint2(:,1),'descend');

    %y coordinates corresponding to x coordinates
    pint1=[pint1x pint1(ip1,2)];
    pint2=[pint2x pint2(ip2,2)];

    %deletion of consecutive points with same x coordinate (previous point)
    xdelete1=(~diff(pint1(:,1)));
    pint1(xdelete1,:)=[];
    xdelete2=(~diff(pint2(:,1)));
    pint2(xdelete2,:)=[];

    %starting point of upper contour: the point with minimum x coordinate
    [~,ixmin]=min(pint1(:,1));

    % deletion of points with a grater y coordinate as the one with maximum x
    ip1control=(pint1(:,2)>pint(ixmax,2));
    pint1(ip1control,:)=[];

    %deletion of points in pint2 with a lower x coordiante than the first point of pint1
    ixincorrect=pint2(:,1)<=pint1(ixmin,1);
    pint2(ixincorrect,:)=[];

    %first point of pint1 added as the end point of pint2
    pint2(end+1,:)=pint1(ixmin,:);

    
    %% selection of different range of contour points
    %x coordinates of outer contour maximum and minimum points taken as reference points 
 
    %intersection points < first maximum point (upper contour)
    i1max1=find(pint1(:,1)<pmax1(1,1));

    %intersection points between first maximum and minimum
    imax1min=find(pint1(:,1)>=pmax1(1,1) & pint1(:,1)<=pmin(1,1));
    
    %there are few points in this range: if there is only one point, the difference isn't computed
    if length(imax1min)>1 
        %point with minimum y coordinate
        [~,imax1minf]=min(pint1(imax1min,2));
        imax1minf=imax1minf+imax1min(1)-1;
        %deletion of previous points (points with greater y)
        pint1(imax1min(1):imax1minf-1,:)=[];
        %indices recomputed
        imax1min=find(pint1(:,1)>=pmax1(1,1) & pint1(:,1)<=pmin(1,1));
    end
    
    %intersection points between the minimum and the second maximum point (upper contour)
    iminmax2=find(pint1(:,1)>pmin(1,1) & pint1(:,1)<=pmax2(1,1));

    %intersection points > second maximum
    imax2end=find(pint1(:,1)>pmax2(1,1));
    %point with minimum y coordinate
    [~,imax2endf]=min(pint1(imax2end,2));
    imax2endf=imax2endf+imax2end(1)-1;
    %deletion of previous points (points with greater y)
    pint1(imax2end(1):imax2endf-1,:)=[];
    %indices recomputed
    imax2end=find(pint1(:,1)>pmax2(1,1));

    %points > second maximum point (lower contour)
    i1max2=find(pint2(:,1)>pmax2(1,1));
    
    %difference between consecutive y coordinates
    dpint1=diff(pint1(:,2));
    dpint2=diff(pint2(:,2));
    
    %% control on upper contour points 

    %for points < max1, y must decrease: deletion of y that increase (positive diff)
    if length(i1max1)>1 
        ipint1delete1=find(dpint1(i1max1(1):i1max1(end-1))>=0);
        %addition of 1 because I want the second point 
        ipint1delete1=ipint1delete1+1;
    else
        ipint1delete1=[];
    end
    
    %for points ranging between max1 and min, y must increase: deletion of y that decrease (negative diff) 
    if length(imax1min)>1 
        ipint1delete2=find( dpint1(imax1min(1):imax1min(end-1))<0);
        ipint1delete2=ipint1delete2+imax1min(1);
    else
        ipint1delete2=[];
    end

    %for points ranging between min and max2, y must decrease: deletion of y that increase (positive diff)
    if length(iminmax2)>1
        ipint1delete3=find(dpint1(iminmax2(1):iminmax2(end-1))>=0 );
        ipint1delete3=ipint1delete3+iminmax2(1);
    else
        ipint1delete3=[];
    end
    
    %for points >max2, y must increase: deletion of y that decrease (negative diff)
    ipint1delete4=find(dpint1(imax2end(1):imax2end(end-1))<0);
    ipint1delete4=ipint1delete4+imax2end(1);
    
    
    ipint1delete=[ipint1delete1;ipint1delete2;ipint1delete3;ipint1delete4];
    %% control on lower contour points 
    
    %for points >max2, y must increase: deletion of y that decrease (negative diff)
    ipint2delete1=find(dpint2(i1max2(1):i1max2(end-1))<0);
    ipint2delete1=ipint2delete1+1;
    
    %elimination of incorrecti points
    pint1(ipint1delete,:)=[];
    pint2(ipint2delete1,:)=[];

    %intersection points between the first and second maximum points (lower
    %contour): y must remain relatively constant (vertebral body included)
    imax1max2=find(pint2(:,1)>pmax1(1,1) & pint2(:,1)<=pmax2(1,1));
    
    %first point of the interval
    pfirst=pint2(imax1max2(1),2);
    %last point of the interval 
    plast=pint2(imax1max2(1)-1,2);
    
    %if first point is lower than the last one (greater y)
    if pfirst>=plast
        %difference from to the first point
        diffdelete=(pint2(imax1max2,2)-pfirst);
    else
        %difference from last point (because first point is invalid)
        diffdelete=(pint2(imax1max2,2)-plast);
    end
    
    %deletion of invalid points
    ipint2delete2=find(diffdelete>5 | diffdelete <-2);
    ipint2delete2=ipint2delete2+imax1max2(1)-1;
    pint2(ipint2delete2,:)=[];

    %intersection points < first maximum point (lower contour)
    imax1end=find(pint2(:,1)<=pmax1(1,1));

    %point with the maximum y 
    [~,imax1endf]=max(pint2(imax1end,2));
    imax1endf=imax1endf+imax1end(1)-1;
    %deletion of previous points (with lower y)
    pint2(imax1end(1):imax1endf-1,:)=[];
    %recomputed indices 
    imax1end=find(pint2(:,1)<=pmax1(1,1));

    %difference recomputed after incorrect point deletion
    dpint2=diff(pint2(:,2));
    %nei punti <max1, y deve diminuire elimino le y che aumentano
    ipint2delete3=find(dpint2(imax1end(1):imax1end(end-1))>0);

    %point deletion
    ipint2delete3=ipint2delete3+imax1end(1);
    pint2(ipint2delete3,:)=[];



    %% interpolation
    %upper contour points
    x1=pint1(:,1);
    y1=pint1(:,2);
    xq1=pint1(1,1):0.05:pint1(end,1);

    %lower contour points
    x2=pint2(length(pint2):-1:1,1);
    y2=pint2(length(pint2):-1:1,2);
    xq2=pint2(length(pint2),1):0.05:pint2(1,1);

    %interpolation 
    sp=interp1(x1,y1,xq1,'pchip');
    sp2=interp1(x2,y2,xq2,'pchip');
    
%% images
%     figure
%     imshow(I_imadjust)
%     hold on
%     
%     plot(pint1(:,1),pint1(:,2),'r.');
%     plot(pint2(:,1),pint2(:,2),'r.');
%     hold on
%     plot(xq1,sp,'g--')
%     hold on
%     plot(xq2,sp2,'g--')
%     hold off
    
    %% mask creation for inner chest portion
    
    %inner contour points after interpolation 
    pcontour1=[xq1';xq2(end-1:-1:1)'];
    pcontour2=[sp';sp2(end-1:-1:1)'];
    pcontour=[pcontour1 pcontour2];

    % inner chest mask 
    contourmask=poly2mask(pcontour(:,1),pcontour(:,2),size(I_imadjust,1),size(I_imadjust,2));
    %dilation operation 
    sed=strel('disk',5);
    contourmask=imdilate(contourmask,sed);


end
