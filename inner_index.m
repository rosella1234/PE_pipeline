%% function for computation of inner thoracic distances and indices 

%inputs:
%- pcontour: coordinates of inner contour points 
%- pmax1: coordinates of first outer contour maximum point  
%- pmax2: coordinates of second outer contour maximum point 
%- Isel: slice for index computation picked by algorithm
%- pixel_distance: vector containing vertical and horizontal distances between pixels(mm)
%- c: if it is equal to 1, the index computation is performed on the same
%slice selected by user, otherwise if the slices are different c is equal to 2

%outputs:
%- transversed: transversed diameter 
%- emitdxd: right hemithorax antero-posterior diameter (APd) 
%- emitsxd: left hemithorax antero-posterior diameter (APd) 
%- iAsymetry: asymmetry index 
%- iFlateness: flatness index
%- minsternum: sternum position 
%- maxAPd: maximum antero-posterior diameter 
%- minAPd: minimum antero-posterior diameter 
%- Haller_ind: Haller index
%- Correction_ind: correction index 
%- depression_ind: depression index 
%- pvertebral body: vertebral body position 


function [transversed,emitsxd,emitdxd,iAsymmetry,iFlatness,minsternum,...
    maxAPd,minAPd,Haller_ind,Correction_ind,depression_ind,pvertebralbody]= inner_index(pcontour,pmax1,pmax2,Isel,pixel_distance,c)


%% transversed diameter 

%minimum x coordinate of inner contour
[xmin,idmin]=min(pcontour(:,1));
%maximum x coordinate of inner contour 
[xmax,~]=max(pcontour(:,1));

%y coordinate of points with maximum and minimum x coordinate
y_xmin=pcontour(idmin,2);
y_xmax=pcontour(idmin,2);


%extreme points of transversed diamter 
p1contour=[xmin,y_xmin];
p2contour=[xmax,y_xmax];
%transversed diameter computation: distance between the point with minimum
%x coordinate and the point at the same y coordinate on the opposite side
transversed_p=sqrt((p2contour(1,1)-p1contour(1,1))^2+(p2contour(1,2)-p1contour(1,2))^2);
transversed=(transversed_p*pixel_distance(1))./10;




%% sternum position 

% point corresponding to max1 point on the inner contour (upper half of contour)
imax1=find(pcontour(:,1)==pmax1(1),1,'first');
% point corresponding to max2 point on the inner contour (upper half of contour)
imax2=find(pcontour(:,1)==pmax2(1),1,'first');

% pmax1inner=round(pcontour(imax1,:));
% pmax2inner=round(pcontour(imax2,:));

%minimum point of inner contour: sternum position (point with the maximum y
%coordinate among the points found above)
[minsternumv,~]=max(pcontour(imax1:imax2,2));
iminsternuma=find(pcontour(imax1:imax2,2)==minsternumv);
%among the points with the same y coordinate it is selected the middle one
iminsternum=abs((iminsternuma(end)+iminsternuma(1))/2)+imax1-1;
minsternum=pcontour(iminsternum,:);



%% right and left hemithorax antero-posterior distances 

%points on the inner contour at the same x coordinate of the two outer contour maximum points
iemitsx=find(pcontour(:,1)==pmax2(1));
iemitdx=find(pcontour(:,1)==pmax1(1));

%antero-posterior distances computation 
emitsxd_p=sqrt((pcontour(iemitsx(1),1)-pcontour(iemitsx(2),1))^2+(pcontour(iemitsx(1),2)-pcontour(iemitsx(2),2))^2);
emitsxd=(emitsxd_p*pixel_distance(1))./10;
emitdxd_p=sqrt((pcontour(iemitdx(1),1)-pcontour(iemitdx(2),1))^2+(pcontour(iemitdx(1),2)-pcontour(iemitdx(2),2))^2);
emitdxd=(emitdxd_p*pixel_distance(1))./10;

%asymmetry index computation 
iAsymmetry=emitdxd/emitsxd;

%flatness index computation 
iFlatness=transversed/(max(emitsxd,emitdxd));

%% maxAPd and minAPd computation

%vertebral body position: maximum point on the lower half on inner contour 

%point corresponding to max1 point on the inner contour (lower half of contour)
i2max1=find(pcontour(:,1)==pmax1(1),1,'last');
%point corresponding to max2 point on the inner contour (lower half of contour)
i2max2=find(pcontour(:,1)==pmax2(1),1,'last');

%vertebral body position: point with minimum y coordinate among the x
%position of the two outer contour maximum points (the starting point is max2
%because the x coordinates of lower half are in descending)
[~,ivertebralPoint]=min(pcontour(i2max2:i2max1,2));
ivertebralPoint=ivertebralPoint+i2max2-1;
vertebralPoint=pcontour(ivertebralPoint,:);

%if c=2 the user is asked to selected the sternum position and the
%vertebral body position
if c==2
%     figure
%     imshow(Isel)
    %window creation
    fig1=uifigure('Position',[100 100 1000 600]);
    lbl = uilabel(fig1);
    lbl.Text = 'The slice is not the one selected by user';
    lbl.Position = [300 500 1000 60];
    lbl.FontSize = 20;
    lbl.FontColor='r';
    ax=uiaxes(fig1,'Position',[500 50 450 450]);
    %visualization of the slice selected by user
    imshow(Isel,'Parent',ax);
    ax.Visible='off';
    uilabel(fig1,'Text','1. Insert sternum position','Position',[50 50 300 600],'FontSize',15);
    hold (ax,'on')
    
    %first user input: vertebral body position
    pminsternum=drawpoint('Parent',ax);
    uilabel(fig1,'Text','2. Insert vertebral body position','Position',[50 20 300 600],'FontSize',15);
    hold (ax,'on')
    %second user input: sternum position
    pvertebral=drawpoint('Parent',ax);
    hold (ax,'off')
    minsternum=round(pminsternum.Position(1,:));
    vertebralPoint=round(pvertebral.Position(1,:));
  
    close (fig1)

end

%extreme points on inner contour with the same y coordinate as the vertebral body position punti sul contorno interno alla stessa y del punto sulla colonna
%(points with minimum and maximum x coordinate)
p1vertebraline=[xmin,vertebralPoint(2)];
p2vertebraline=[xmax,vertebralPoint(2)];


%maximum left hemithorax point  
pmaxemitsx=pcontour(iemitsx(1),:);
%maximum right hemithorax point
pmaxemitdx=pcontour(iemitdx(1),:);

%point at the same x coordinate of the maximum left/right hemithorax point and at
%the vertebral body position 
pvlinemitsx=[pmaxemitsx(1) p1vertebraline(2)];
pvlinemitdx=[pmaxemitdx(1) p1vertebraline(2)];

%max APd computation: distance between the maximum right/left hemithorax point
%and at the vertebral body y position
maxAPd_psx=sqrt((pvlinemitsx(1)-pmaxemitsx(1))^2+(pvlinemitsx(2)-pmaxemitsx(2))^2);
maxAPd_pdx=sqrt((pvlinemitdx(1)-pmaxemitdx(1))^2+(pvlinemitdx(2)-pmaxemitdx(2))^2);
%maximum between left and right max APd distances
maxAPd_p=max(maxAPd_psx,maxAPd_pdx);
maxAPd=(maxAPd_p*pixel_distance(1))./10;

%point at the same x coordinate of sternum and at the the vertebral body y position
pvertebralbody=[minsternum(1),p1vertebraline(2)];

% min APd calculation: minimum distance between sternum and vertebral body 
minAPd_p=sqrt((pvertebralbody(1)-minsternum(1))^2+(pvertebralbody(2)-minsternum(2))^2);
minAPd=(minAPd_p*pixel_distance(1))./10;

%Haller index
Haller_ind=transversed/minAPd;

%correction index
Correction_ind=((maxAPd-minAPd)/maxAPd)*100;

%depression index
depression_ind=emitsxd/minAPd;


%% image with inner thoracic distances
figure;
imshow(Isel);

hold on

% transversed diameter
line([p2contour(1,1) p1contour(1,1)],[p2contour(1,2) p1contour(1,2)],'color','r','LineWidth', 1.5)

%right and left hemithorax APd
line([pcontour(iemitsx,1) pcontour(iemitdx,1)],[pcontour(iemitsx,2) pcontour(iemitdx,2)],'color','b','LineWidth', 1.5)

%min Apd
line([pvertebralbody(1) minsternum(1)],[pvertebralbody(2) minsternum(2)],'color','y','LineWidth',1.5)

%horizontal line at the position of vertebral body 
line([p1vertebraline(1) p2vertebraline(1)],[p1vertebraline(2) p2vertebraline(2)],'color','c')

%max APd: maximum distance between left (index imaxAPd=1) and right (index imaxAPd=2)one
if maxAPd_p==maxAPd_psx
    line([pcontour(iemitsx(1),1) pvlinemitsx(1)],[pcontour(iemitsx(1),2)  pvlinemitsx(2)],'color','g','LineWidth',1.5)
    plot(pvlinemitsx(1),pvlinemitsx(2),'r.','MarkerSize', 6);
else
    line([pcontour(iemitdx(1),1) pvlinemitdx(1)],[pcontour(iemitdx(1),2)  pvlinemitdx(2)],'color','g','LineWidth',1.5)
    plot(pvlinemitdx(1),pvlinemitdx(2),'r.','MarkerSize', 6);
end


%point at sternum position
plot(minsternum(1,1),minsternum(1,2),'r.','MarkerSize', 6)
%extreme points of left APd
plot(pcontour(iemitsx,1),pcontour(iemitsx,2),'r.','MarkerSize', 6);
%extreme points of right APd
plot(pcontour(iemitdx,1),pcontour(iemitdx,2),'r.','MarkerSize', 6);
%point at vertebral body position
plot(vertebralPoint(1,1),vertebralPoint(1,2),'r.','MarkerSize', 6)



hold off



end


