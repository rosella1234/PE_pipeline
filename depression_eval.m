%% function for depression quantification 

%inputs: 
%- pmax1: coordinates of first maximum point of outer chest contour 
%- pmax2: coordinates of second maximum point of outer chest contour 
%- BWt: binary image after pre-processing
%- I_imadjust: grey-scale image after pre-processing
%- yhalf: y position of the half point of image
%- pixel_distance: vector containing vertical and horizontal distances between pixels(mm)

%outputs:
%- Bfill: binary image of chest after depression correction with elliptical curve between the two maximum points 
%- I: grey-scale image with elliptical curve 
%- depression: binary image of depression 
%- depressione_area: depression area 
%- corrthorax_area: thorax area after correction

function [Bfill,I,depression,depression_area,corrthorax_area] = depression_eval(pmax1,pmax2,BWt,I_imadjust,yhalf,pixel_distance)
  
    %matrix containing pixel coordinates of chest
    [r,c]=find(BWt);
    mat=[c,r];
   
    %points at the same y coordinate as the first maximum point 
    ix1all=(mat(:,2)==pmax1(1,2));
    %point with the minimum x coordinate
    px1=min(mat(ix1all,1));
    pmax1(1,1)=px1;
    %points at the same y coordinate as the second maximum point 
    ix2all=(mat(:,2)==pmax2(1,2));
    %point with the minimum x coordinate
    px2=max(mat(ix2all,1));
    pmax2(1,1)=px2;
    
    %ellipse major axis extreme points 
    x1=pmax1(1);
    x2=pmax2(1);
    y1=pmax1(2);
    y2=pmax2(2);
    xm=[x1 x2];
    ym=[y1 y2];
    
    %ellipse eccentricity 
    eccentricity = 0.99;
    
    %number of points between the 2 maximum points 
    numPoints = max(abs(diff(xm)),abs(diff(ym)))+1; 
    
    % ellipse equation
    a = (1/2) * sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
    b = a * sqrt(1-eccentricity^2);
    
    %angle varies between 0 and pi (half ellipse)
    t = linspace(0, -pi, numPoints);
    X = a * cos(t);
    Y = b * sin(t);
    
    %ellipse rotation angle respect to horizontal line
    angles = atan2(y2 - y1, x2 - x1);
    
    %ellipse coordinates
    x = (x1 + x2) / 2 + X * cos(angles) - Y * sin(angles);
    y = (y1 + y2) / 2 + X * sin(angles) + Y * cos(angles);

    %indices corrresponding to x and y coordinates belonging to ellipse 
    index = sub2ind(size(BWt), round(y), round(x));
    
    %pixel corrisponding to ellipse added to binary and grey-scale images 
    BWline=BWt;
    BWline(index)=1;
    I1=I_imadjust;
    I1(index)=1;
    
    %depression correction with morpholigical operation
    se=strel('disk',20);
    Bfill=imclose(BWline,se);
    Bfill=imfill(Bfill,'holes');
    
    %depression area found after image subtraction
    depression = imsubtract(Bfill,BWt);
    depression=imbinarize(depression);
    %operation that only keeps the largest element and the upper half of
    %image
    depression(yhalf:end,:)=0;
    depression=bwareafilt(depression,1);
    
    %depression correction on grey-scale image
    I=I_imadjust;
    I(depression)=1;
    
    %% depression area computation
    
    %number of nonzero elements in matrix representing depression area
    depression_area_p=nnz(depression);

    %single pixel area in mm
    pixel_area=pixel_distance(1)*pixel_distance(2);

    %depression area in mm
    depression_area=depression_area_p*pixel_area;
    
    
    %% correct chest area computation
    
    %number of nonzero elements in matrix representing correct chest
    corrthorax_area_p=nnz(Bfill);
    %correct chest area in mm
    corrthorax_area=corrthorax_area_p*pixel_area;
    
end

