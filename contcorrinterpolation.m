%% function for the preparation of the inner contour belonging to the slice where indices calculation is performed

%inputs:
%- contcorr: coordinates of inner chest contour points
%- I_imadjust: grey-scale image
%- pmin: coordinates of outer chest minimum point 
%- pmax1: coordinates of outer chest first maximum point
%- yhalf: y position of the point located in the half of the image

%outputs:
%- pcontour: coordinates of inner chest contour points after interpolation 
%- max1in: coordinates of first inner chest maximum point 
%- max2in: coordinates of second inner chest maximum point
%- ncontrol: if ncontrol is equal to 1, it means that inner chest contour doesn't present errors in the upper half, 
%otherwise ncontrol is equal to 2 and thus the algorithm pass to analyze the inner chest contour of the consecutive slice

function [pcontour,max1in,max2in,ncontrol] = contcorrinterpolation(contcorr,I_imadjust,pmin,pmax1,yhalf)
    
    %% preparation of points for interpolation 
    
    %elimination of points at the same x as the point with maximum x coordinate 
    [xmax,ixmax]=max(contcorr(:,1));
    isamexmax=find(contcorr(ixmax+1:end,1)==xmax);
    cnew=contcorr;
    cnew(isamexmax+ixmax,:)=[];

    %partition of contour in two parts: upper and lower part 
    pint1=cnew(1:ixmax,:);
    pint2=cnew(ixmax:length(cnew),:);
    
    %x sorted in ascendent order (superior contour) 
    [pint1x,ip1]=sort(pint1(:,1));
    %x sorted in descendent order (inferior contour) 
    [pint2x,ip2]=sort(pint2(:,1),'descend');

    %trovo le y corrispondenti alle x ordinate
    pint1=[pint1x pint1(ip1,2)];
    pint2=[pint2x pint2(ip2,2)];

    %elimination of consecutive points with same x coordinate (previous point in the difference) 
    xdelete1=(~diff(pint1(:,1)));
    pint1(xdelete1,:)=[];
    xdelete2=(~diff(pint2(:,1)));
    pint2(xdelete2,:)=[];

    %starting point of contour upper half: the one with minimum x coordinate 
    [~,ixmin]=min(pint1(:,1));

    %points in pint2 with x coordinates lower than the first point of pint1 (minimum point) are deleted 
    ixincorrect=pint2(:,1)<=pint1(ixmin,1);
    pint2(ixincorrect,:)=[];

    %starting point of upper half added to lower half as the end point 
    pint2(end+1,:)=pint1(ixmin,:);

    
    %% control on upper half points 

    %indices of upper half points within the x position of outer chest 
    %minimum point and first outer chest maximum point 
    ix=find(pint1(:,1)<(pmin(1,1)-5) & pint1(:,1)>pmax1(1,1)-15);
    % points among the one found with a distance >4 from yhalf (errors on inner contour upper half)      
    pinner=yhalf;
    iy=abs((pint1(ix(1):ix(end),2)-pinner))<4;
    %if there are points that soddisfy this condition, the inner contour
    %analyzed can't be used for indices computation and the function stops
    if any(iy)
        ncontrol=2;
        pcontour=[];
        max1in=[];
        max2in=[];
        return
        %otherwise the function continues with interpolation 
    else
        ncontrol=1;
    end


    %% interpolation
    %inner contour upper half points
    x1=pint1(:,1);
    y1=pint1(:,2);
    xq1=pint1(1,1):0.5:pint1(end,1);

    %inner contour lower half 
    x2=pint2(length(pint2):-1:1,1);
    y2=pint2(length(pint2):-1:1,2);
    xq2=pint2(length(pint2),1):0.5:pint2(1,1);
    
    %application of interpolation 
    sp=interp1(x1,y1,xq1,'pchip');
    sp2=interp1(x2,y2,xq2,'pchip');

    pcontour1=[xq1';xq2(end-1:-1:1)'];
    pcontour2=[sp';sp2(end-1:-1:1)'];
    
    %result of interpolation
    pcontour=[pcontour1 pcontour2];

   %% images


%     figure
%     imshow(I_imadjust)
%     hold on
% 
%     plot(pint1(:,1),pint1(:,2),'g.');
%     plot(pint2(:,1),pint2(:,2),'g.');
%     hold on
%     plot(xq1,sp,'r-')
%     hold on
%     plot(xq2,sp2,'r-')
%     hold off

    %% calculation of inner contour maximum points 
    
    %points with x coordinate lower than the outer contour minimum point(first maximum point) 
    inner1=pint1(:,1)<pmin(1,1);
    pinner1=pint1(inner1,:);
    %points with x coordinate greater than the outer contour minimum point(first maximum point) 
    inner2=pint1(:,1)>pmin(1,1);
    pinner2=pint1(inner2,:);
    
    %first inner contour maximum point 
    [~,imax1in]=min(pinner1(:,2));
    max1in=pinner1(imax1in,:);
    
    %second inner contour maximum point 
    [~,imax2in]=min(pinner2(:,2));
    max2in=pinner2(imax2in,:);



end

