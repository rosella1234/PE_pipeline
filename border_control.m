%% function that identifies the columns on the right and left sides of image not belonging to chest (arms)
%input:
%- I_imadjust: grey-scale image
%- th: manual threshold

%output:
%- BWt: binary image after manual threshold application 
%- i1mask: vector containing the number of columns on the right side not belonging to chest 
%- iendmask: vector containing the number of columns on the left side not belonging to chest 

function [BWt,i1mask,iendmask] = bordercontrol(I_imadjust,th)
    
    % manual threshold (low value) for background removal
    BW=I_imadjust>th;
    
    %morphological operations for holes fill 
    se=strel('rectangle',[10 1]);
    BWt=imclose(BW,se);
    BWt=imfill(BWt,'holes');
    
    %pixel number of binary image
    npixel=max(size(find(BWt)));
    
    %if pixel number is >=20000 (large chest image: it valuates only the
    %first and last 20 columns)

    if npixel>=20000
        a1=20;
        a2=20;
        
    %if pixel number is <20000 (small chest image: it valuates the
    %first 30 and the last 25 columns)
    else
       
        a1=30;
        a2=25;
    end
    
    %% right side control
    
    
    nrowborder=cell(a1,1);
    l1=zeros(a1,1);
    
    
    for n=1:a1
        
        %for each columns it add to cellarray the vector containing the
        %white pixels of image
        nrowborder{n}=find(BWt(:,n));
        l1(n)=length(nrowborder{n});

    end   
    
    %vector of consecutive differences of l1 (containing the length of
    %first a1 columns of image
    ldiff=diff(l1);
    ildiff=[0; ldiff>=0];
    
    %it finds the index corresponding yo the last column whose length is lower than prevoius ones 
    i1mask=find(ildiff==0,1,'last');
    
    
    %% left side contorl (same process as for right side)
    
    nrowborderend=cell(a2,1);
    lend=zeros(a2,1);
    
    for k=1:a2
        nrowborderend{k}=find(BWt(:,end-k));
        lend(k)=length(nrowborderend{k});
    end
    
    lenddiff=diff(lend);
    ilenddiff=[0; lenddiff>=0];
    iendmask=find(ilenddiff==0,1,'last');
    
    
    

end

