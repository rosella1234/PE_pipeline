clear all
close all

%% folder selection containing all images beloning to a specific patient

patient=uigetdir;
myImages = dir([patient '/*.dcm']);
myImages([myImages.isdir])=[];


%% pre-processing: image importation

numimagestot = length(myImages);

Ipretot = cell(numimagestot,1);
Igreytot= cell(numimagestot,1);
I_imadjusttotpre= cell(numimagestot,1);


for m = 1:numimagestot
    
    Ipretot{m} = dicomread(fullfile(myImages(m).folder,myImages(m).name)); 
    Igreytot{m}=mat2gray(Ipretot{m});
    %contrast adjustment
    I_imadjusttotpre{m}=imadjust(Igreytot{m});
    
    
end

% dicom informations
info=dicominfo(fullfile(myImages(1).folder,myImages(1).name));
pixel_distance=info.PixelSpacing;
distance_b_slices=info.SpacingBetweenSlices;
voxel_volume=pixel_distance(1)*pixel_distance(2)*distance_b_slices;


%%  pre-processing 1: slices selection by user

% label addition to each slice
position=[size(I_imadjusttotpre{1},1)/2 10];
Ilabel=cell(numel(I_imadjusttotpre),1);

for i = 1:numimagestot

    Ilabel{i}=insertText(I_imadjusttotpre{i},position,i,'AnchorPoint','CenterTop','FontSize',25,'TextColor','white','BoxColor','black');
    
end

% figure
% montage(Ilabel,'Size',[6 round(numel(I_imadjusttotpre)/6)])

%slice visualization and selection
[n1,ndend,ns,s1,send,numimages,numdep,srange,gender] = visualize_select(Ilabel,numimagestot);



%% pre-processing2: border correction

BWs=cell(numimages,1);
imask=zeros(numimages,1);
iendmask=zeros(numimages,1);
I_imadjusttot=cell(numimages,1);
BWt=cell(numimages,1);
yhalf=zeros(numimages,1);
xhalf=zeros(numimages,1);


for b=1:numimages 
    
    [BWs{b},imask(b),iendmask(b)] = bordercontrol(I_imadjusttotpre{b+n1-1},0.1);
    [I_imadjusttot{b},BWt{b},yhalf(b),xhalf(b)] = maskborder(I_imadjusttotpre{b+n1-1},BWs{b},imask(1:b),iendmask(1:b));

end



figure
montage(I_imadjusttot,'indices',1:numimages)

% figure
% montage(BWt,'indices',1:numimages)



%% depression quantification : outer contour analysis + depression correction  

pmax1=zeros(numimages,2);
pmax2=zeros(numimages,2);
pmin=zeros(numimages,2);
Bcontest=cell(numimages,1);
contornocorr=cell(numimages,1);
b1=cell(numimages,1);

BWcorrect=cell(numimages,1);
BWdepression=cell(numimages,1);
Iellipse=cell(numimages,1);
depression_area=zeros(numimages,1);
corrchest_area=zeros(numimages,1);

%lowering factor found after normal patient chest analysis   
loweringfactor=round(15*size(I_imadjusttotpre{1},2)/320);

    for j=1:numimages

        [pmax1(j,:),pmax2(j,:),pmin(j,:),Bcontest{j},contornocorr{j}] = outercontour(BWt{j},xhalf(j),yhalf(j));
        
        %lowering of maximum points
        pmax1(j,2)=pmax1(j,2)+loweringfactor;
        pmax2(j,2)=pmax2(j,2)+loweringfactor;
        
        %further analysis is done only if patient is male and by considering slices selected for depression quantification 
        if gender=='M' &&  j<=(numdep)    
                
            [BWcorrect{j},Iellipse{j},BWdepression{j},depression_area(j),corrchest_area(j)] = depression_eval(pmax1(j,:),pmax2(j,:),BWt{j},I_imadjusttot{j},yhalf(j),pixel_distance);
        
        end
    end
    


%% depression quantification: images and results 



if gender=='M'  
%     figure
%     montage(BWcorrect,'indices',1:numdep)

    figure
    montage(Iellipse,'indices',1:numdep)

%     figure
%     montage(BWdepression,'indices',1:numdep)

    % depression volume computation
    depression_volume=(sum((depression_area).*distance_b_slices))/1000;

    % correct chest volume computation 
    corrchest_volume=(sum((corrchest_area).*distance_b_slices))/1000;
    
    %new marker computation: depression fraction
    depress_fraction=(depression_volume/corrchest_volume)*100;

end


%% inner contour analysis: elimination of slices that preceed the one selected for indices computation 

I_imadjusttots=cell(srange,1);
Bcontests=cell(srange,1);
contornocorrs=cell(srange,1);
xhalfs=zeros(srange,1);
yhalfs=zeros(srange,1);
pmax1s=zeros(srange,2);
pmax2s=zeros(srange,2);
pmins=zeros(srange,2);
BWts=cell(srange,1);

for g=1:srange
    I_imadjusttots{g}=I_imadjusttot{g+s1-1};
    Bcontests{g}=Bcontest{g+s1-1};
    contornocorrs{g}=contornocorr{g+s1-1};
    xhalfs(g)=xhalf(g+s1-1);
    yhalfs(g,:)=yhalf(g+s1-1);
    pmax1s(g,:)=pmax1(g+s1-1,:);
    pmax2s(g,:)=pmax2(g+s1-1,:);
    pmins(g,:)=pmin(g+s1-1,:);
    BWts{g}=BWt{g+s1-1};
end

%  figure
% montage(I_imadjusttots)



%% inner contour analysis: lung and heart segmentation by using histogram partitioning method 

counts=cell(srange,1);
binlocations=cell(srange,1);
countsbd=cell(srange,1);
binlocationsbd=cell(srange,1);

tb=zeros(srange,1);
itb=zeros(srange,1);
t=zeros(srange,1);
tc=zeros(srange,1);


 for h=1:srange
    
    [counts{h},binlocations{h}]=imhist(I_imadjusttots{h});
    [tb(h),itb(h)]=hist_threshold(counts{h},binlocations{h},0,0.3);
    countsbd{h}=counts{h};
    binlocationsbd{h}=binlocations{h};
    countsbd{h}(1:itb(h))=[];
    binlocationsbd{h}(1:itb(h))=[];
    [t(h),~]=hist_threshold(countsbd{h},binlocationsbd{h},tb(h),0.4);
    [tc(h),~]=hist_threshold(countsbd{h},binlocationsbd{h},0.3,0.8);
         
     
 end
 

%% inner contour analysis: correction of thresholds
%correction of threshold values that differ from mean value 

tmean=mean(t);
tdelete=(round(abs(t-mean(t)),2))>0.05;
tcorr=t;
tcorr(tdelete)=mean(t);

theart=mean(tc);
tcdelete=(round(abs(tc-mean(tc)),2))>0.05;
tcheart=tc;
tcheart(tcdelete)=mean(tc);

%% inner contour analysis: application of thresholds for lung segmentation 

BWlung=cell(srange,1);
polm1=cell(srange,1);
polm2=cell(srange,1);
lung_fraction=zeros(srange,1);


for k=1:srange
    
    [BWlung{k},polm1{k},polm2{k},lung_fraction(k)] = lungsegmentation(I_imadjusttots{k},tcorr(k),Bcontests{k},xhalfs(k),BWts{k});

end
% 
% figure
% montage(BWlung)


%% inner contour analysis: elimination of slices where lungs are not visible 

%threshold: 0.2
incorrslice=lung_fraction<0.2;
srange=srange-max(size(find(incorrslice)));

%maximum number of slices: 15
if srange>15
   srange=15; 
end


I_imadjusttots(incorrslice,:)=[];
Bcontests(incorrslice,:)=[];
contornocorrs(incorrslice,:)=[];
xhalfs(incorrslice,:)=[];
yhalfs(incorrslice,:)=[];
pmax1s(incorrslice,:)=[];
pmax2s(incorrslice,:)=[];
pmins(incorrslice,:)=[];
BWlung(incorrslice,:)=[];
polm1(incorrslice,:)=[];
polm2(incorrslice,:)=[];
tcorr(incorrslice,:)=[];
tcheart(incorrslice,:)=[];
% 
figure
montage(I_imadjusttots)



 %% inner contour analysis: inner contour segmentation

intpoint=cell(srange,1);
pcontorno=cell(srange,1);
contourmask=cell(srange,1);

for w=1:srange

    [intpoint{w}] = innercontour_seg(I_imadjusttots{w},BWlung{w},contornocorrs{w},xhalfs(w),polm1{w},polm2{w});
    
    [pcontorno{w},contourmask{w}] = contourinterpolation(pmins(w),pmax1s(w),pmax2s(w),intpoint{w},I_imadjusttots{w},contornocorrs{w});
    
end



    
%% inner contour analysis: vertebral body exclusion 

contpoint=cell(srange,1);
contpointd=cell(srange,1);
Icont=cell(srange,1);
masksel=cell(srange,1);


for q=1:srange
    

    [Icont{q},contpoint{q}] = innermask_seg(I_imadjusttots{q},contourmask{q},Bcontests{q},tcorr(q),tcheart(q));
    contpointd{q}= downsample(contpoint{q},3);
    masksel{q}=insertText(double(Icont{q}),position,q,'AnchorPoint','CenterTop','FontSize',25,'TextColor','white','BoxColor','black');
    
end

%%
% figure
% imshow(Icont{9})
% figure
% imshow(I_imadjusttots{9})
% hold on
% plot(contpointd{9}(:,1),contpointd{9}(:,2),'r.')
% hold off

%% inner contour analysis: inner contour correction

%selection of first slice for inner contour correction
ncorr = innermask_select(masksel);

figure
imshow(I_imadjusttots{ncorr})
hold on
plot(contpointd{ncorr}(:,1),contpointd{ncorr}(:,2),'r.')
hold off

%% inner contour analysis: correction of slices preceeding the one selected by user

c2corr=cell(srange,1);
innermask=cell(srange,1);
innermaskn=cell(srange,1);
Iinner=cell(srange,1);
Ipolmoni=cell(srange,1);


if ncorr>1
    for u=ncorr:-1:1
        if u==ncorr
            c2corr{u}=contpointd{ncorr};
        else

            [c2corr{u}] = innercontourcorrection(c2corr{u+1},contpointd{u},yhalfs(u));

%             figure(u)
%             imshow(I_imadjusttots{u})
%             hold on
%             plot(contpointd{u}(:,1),contpointd{u}(:,2),'g')
%             hold on
%             plot(c2corr{u+1}(:,1),c2corr{u+1}(:,2),'b')
% 
%             hold on
%             plot(c2corr{u}(:,1),c2corr{u}(:,2),'r.')
% 
%             hold off

        end

        [innermask{u},Iinner{u},Ipolmoni{u}] = inneranalysis(c2corr{u},I_imadjusttots{u});
  

    end
    
end

%% inner contour analysis: correction of slices following the one selected by user


    for u=ncorr:srange
        if u==ncorr
            c2corr{u}=contpointd{ncorr};
        else

            [c2corr{u}] = innercontourcorrection(c2corr{u-1},contpointd{u},yhalfs(u));

%             figure(u)
%             imshow(I_imadjusttots{u})
%             hold on
%             plot(contpointd{u}(:,1),contpointd{u}(:,2),'g')
%             hold on
%             plot(c2corr{u-1}(:,1),c2corr{u-1}(:,2),'b')
% 
%             hold on
%             plot(c2corr{u}(:,1),c2corr{u}(:,2),'r.')
% 
%             hold off

        end


        [innermask{u},Iinner{u},Ipolmoni{u}] = inneranalysis(c2corr{u},I_imadjusttots{u});
  

    end



%%
figure
montage(innermask)

figure
montage(Iinner,'BackgroundColor',[1 1 1])

figure
montage(Ipolmoni)



%% index computation: visualization of the slice selected by user and the one picked by algorithm
%  figure
% montage(I_imadjusttots)
indslice=1;
% figure
% imshow(I_imadjusttots{indslice})
selslice=ns;
% figure
% imshow(I_imadjusttotpre{selslice})

%% index computation: inner contour preparation 

[pcontornoint,p1in,p2in,ipr] = contcorrinterpolation(c2corr{indslice},I_imadjusttots{indslice},pmins(indslice,:),pmax1s(indslice,:),yhalfs(indslice,:));

%exclusion of slices where upper half of inner contour isn't correct
%%
while ipr>1
    indslice=indslice+1;

    [pcontornoint,p1in,p2in,ipr] = contcorrinterpolation(c2corr{indslice},I_imadjusttots{indslice},pmins(indslice,:),pmax1s(indslice,:),yhalfs(indslice,:));

end


if abs(p1in(:,1)-pmax1s(indslice,1))>20
    pmax1s(indslice,1)=p1in(1,1);

end

%% index computation on the slice picked by algorithm

[diamtrasv,d_emitsx,d_emitdx,iAsymetry,iFlatness,minsternum,...
maxAPd,minAPd,iHaller,iCorrection,iDepression,pcvert]= inner_index(pcontornoint,pmax1s(indslice,:),pmax2s(indslice,:),I_imadjusttots{indslice},pixel_distance,1);

%creation of a table containing results of inner thoracic distances,
%thoracic indices and depression factor resulting from depression quantification 
Results={'transversed diameter (cm)'; 'min APd (cm)'; 'max APd (cm)'; 'APd right emitorax (cm)'; 'APd left emitorax (cm)'; 'iHaller';'iCorrection (%)'; 'iAsymetry'; 'iFlatness';'depression_factor(%)'};
values=[diamtrasv; minAPd; maxAPd; d_emitdx; d_emitsx; iHaller; iCorrection; iAsymetry; iFlatness; depress_fraction];
Tdresult=table(Results,values);

%results saved as an Excel table in the same folder where images are located
table_path_format = fullfile(patient, 'results_1.xlsx');
writetable(Tdresult,table_path_format,'WriteRowNames',true);

%% index computation on the slice selected by user (if it is different from the one picked by algorithm)

if incorrslice(1)==1 || indslice>1
    
    [diamtrasv2,d_emitsx2,d_emitdx2,iAsymetry2,iFlatness2,minsternum2,...
    maxAPd2,minAPd2,iHaller2,iCorrection2,iDepression2,pcvert2]= inner_index(pcontornoint,pmax1s(indslice,:),pmax2s(indslice,:),I_imadjusttotpre{selslice},pixel_distance,2);
    values2=[diamtrasv2; minAPd2; maxAPd2; d_emitdx2; d_emitsx2; iHaller2; iCorrection2; iAsymetry2; iFlatness2; depress_fraction];

    %table containing results
    Tdresult=table(Results,values2);
    %results saved as an Excel table in the same folder where images are
    %located (with a different name)
    table_path_format = fullfile(patient, 'results_2.xlsx');
    writetable(Tdresult,table_path_format,'WriteRowNames',true);
    

end

