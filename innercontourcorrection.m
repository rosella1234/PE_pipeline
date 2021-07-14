%% function for inner chest contour correction based on comparison between consecutive slices

%inputs:
%- c1: coordinates of inner contour points belonging to the correct curve 
%- c2: coordinates  of inner contour points belonging to the curve that need to be corrected 
%- yhalf: y position of the point located in the half of the image

%output:
%- c2corr: coordinates of inner contour points belonging to the incorrect curve after correction


function [c2corr] = innercontourcorrection(c1,c2,yhalf)

%    figure
%     plot(c1(:,1),c1(:,2),'r.')
%     set(gca, 'YDir','reverse')
%     ylim([60 170])
%     xlim([10 230])
%     hold on
%     plot(c2(:,1),c2(:,2),'g.')
%     set(gca, 'YDir','reverse')
%     xlabel('x coordinates of inner chest boundary pixels')
%     ylabel('y coordinates of inner chest boundary pixels')
%     hold off
  %% lower contour points 

    %yhalf is taken as reference to divide the contour in 2 half (lower half is the one that need to be corrected)
    i1=(c1(:,2)>=yhalf);
    i2=(c2(:,2)>=yhalf);

    c1inf=c1(i1,:);
    c2infpre=c2(i2,:);

    %x sorted in descending order 
    [~,ic2infx] = sort(c2infpre(:,1),'descend');
    c2infpre=c2infpre(ic2infx,:);

    % difference between consective x: deletion of points at the same x (diff=0)
    dxc2inf=diff(c2infpre(:,1));
    %vector has to have the same length as c2infpre (addition of 1 in the last row)
    dxc2infn=[dxc2inf;ones(1,1)];
    %difference vector transformed in indices ('0' correspond to the points to delete, 
    %while '1' to the correct ones) 
    ixdelete=logical(dxc2infn);
    %deletion of points found
    c2inf=c2infpre(ixdelete,:);

    %% upper contour points  
    c1suppre=c1(~i1,:);
    c2suppre=c2(~i2,:);

    
    c2supxmax=max(c2suppre(:,1));
    %it takes the point with the grater y coordinate (last)
    ic2supxmax=find(c2suppre(:,1)==c2supxmax,1,'last');
    c2sup=c2suppre(1:ic2supxmax,:);
    %difference between consecutive x coordinates 
    dxc2sup=diff(c2sup(:,1));
    %deletion of points with incorrect x coordinate for interpolation
    ideletec2sup=[0; dxc2sup<=0];
    ideletec2sup=logical(ideletec2sup);
    c2sup(ideletec2sup,:)=[];
    
    %same analysis on c1sup
    c1supxmax=max(c1suppre(:,1));
    ic1supxmax=find(c1suppre(:,1)==c1supxmax,1,'last');
    c1sup=c1suppre(1:ic1supxmax,:);
    dxc1sup=diff(c1sup(:,1));
    ideletec1sup=[0; dxc1sup<=0];
    ideletec1sup=logical(ideletec1sup);
    c1sup(ideletec1sup,:)=[];
    
    %%
%         figure
%     plot(c1inf(:,1),c1inf(:,2),'r.')
%     hold on
%     plot(c2inf(:,1),c2inf(:,2),'g.')
%     set(gca, 'YDir','reverse')
%     xlabel('x coordinates of inner chest boundary pixels')
%     ylabel('y coordinates of inner chest boundary pixels')
%     ylim([110 170])
%     xlim([10 230])
%     hold off




    %% computation of distance between the 2 contours 

    %initialization
    dc1c2=cell(length(c2inf),1);
    dc1c2min=zeros(length(c2inf),1);
    idc1c2min=zeros(length(c2inf),1);

    %for each point of c2inf it computes the distance between each point of c2inf and all the points of c1infper ogni punto di c2inf calcolo la distanza tra quest'ultimo e i punti di
    %(c2inf point is hold still and a vector of distances between this point and c1 inf points is generated) 
    for u=1:length(c2inf)
        
        dc1c2{u}=sqrt((c2inf(u,1)-c1inf(:,1)).^2+(c2inf(u,2)-c1inf(:,2)).^2);
        
        %it creates a vector of distances where it inserts the minimum
        %distance of distances previuos computed and the corresponding index 
        %(taken as reference for c1inf points). Thus it maintains 
        %the distance between the each c2inf points and the closest point of c1inf
        
        [dc1c2min(u),idc1c2min(u)]=min(dc1c2{u});

    end

    %deletion of first points of dc1dc2min vector with distance>4 
    %(they don't have to be corrected: lack of points in the initial part)
    ifirstdelete=find(dc1c2min<4,1,'first');
    dc1c2min(1:ifirstdelete)=0;
    ilastdelete=find(dc1c2min<4,1,'last');
    dc1c2min(ilastdelete:end)=0;
    
    %% threshold for correction of contour points 

    %maximum distance value
    maxdc1c2=floor(max(dc1c2min));
    %mean distance value 
    meandc1c2=ceil(mean(dc1c2min));
    %standard deviation of distance values
    stddc1c2=(std(dc1c2min));

    %if standard deviation is greater than 1.8, correction is needed: 
    if stddc1c2>1.8

    %indices corresponding to distances > threshold chosen for correction 
    iincorrect=find(dc1c2min>=2*meandc1c2);

    %if there are consecutive indices, it takes only 1 index (the first one of the interval)
    %difference between consecutive indices:
    iincorrectdiff=(diff(iincorrect)<2);
    iincorrectdiff=[zeros(1);iincorrectdiff];
    
    %it takes indices equal to 0 (i.e. where difference isn't 1)
    irange=iincorrect(~iincorrectdiff);    


    %% correction process (c2inf): done for each irange
    
    %initialization
    ic2p1=zeros(length(irange),1);
    ic2p2=zeros(length(irange),1);
    ic1p1=zeros(length(irange),1);
    ic1p2=zeros(length(irange),1);
    ip=zeros(length(irange),1);
    ip4=zeros(length(irange),1);

    p1corr=zeros(length(irange),2);
    p2corr=zeros(length(irange),2);
    p3corr=zeros(length(irange),2);
    p4corr=zeros(length(irange),2);
    p5corr=zeros(length(irange),2);
    p6corr=zeros(length(irange),2);
    p7corr=zeros(length(irange),2);

    x=zeros(length(irange),7);
    y=zeros(length(irange),7);

    xq=cell(length(irange),1);
    yq=cell(length(irange),1);

    c2infcorrtot=cell(length(irange),1);

        for k=1:length(irange)

            %first extreme point for interpolation: point corresponding to 
            %a difference between c1 and c2 lower than 3 (points from irange to 1) 
            ic2p1k=find(dc1c2min(irange(k):-1:1)<3,1,'first');
            
            if isempty(ic2p1k)==0
                ic2p1(k)=irange(k)-ic2p1k+1;
            else
                 ic2p1(k)=1;
            end
            
            %second extreme point for interpolation: point corresponding to 
            %a difference between c1 and c2 lower than 3 (points from irange to end)
            ic2p2k=find(dc1c2min(irange(k):1:end)<3,1,'first');
            
            if isempty(ic2p2k)==0
                ic2p2(k)=irange(k)+ic2p2k-1;
            else
                ic2p2(k)=length(dc1c2min);
            end

            %% correction with c1inf points

            %c1inf indices corresponding to c2inf indices
            ic1p1(k)=idc1c2min(ic2p1(k));
            ic1p2(k)=idc1c2min(ic2p2(k));
            

            %5 middle points (in total 7 points with the 2 extreme ones):
            %found by selecting 5 equally space points of c1
            ip(k)=round(abs(ic1p2(k)-ic1p1(k))/7);
            ip4(k)=round(((ic1p1(k)+2*ip(k))+(ic1p2(k)-2*ip(k)))/2);

            %% interpolation

            % interpolation points
            p1corr(k,:)=c2inf(ic2p1(k),:);
            p2corr(k,:)=c2inf(ic2p2(k),:);
            p3corr(k,:)=c1inf(ic1p1(k)+ip(k),:);
            p4corr(k,:)=c1inf(ic1p1(k)+2*ip(k),:);
            p5corr(k,:)=c1inf(ip4(k),:);
            p6corr(k,:)=c1inf(ic1p2(k)-ip(k),:);
            p7corr(k,:)=c1inf(ic1p2(k)-2*ip(k),:);

            %a constant is added to each x coordinates in order to prevent errors 
            %in interp1 function (where x values can't be unique)           
            x(k,:)=[p1corr(k,1) p3corr(k,1)+0.01 p4corr(k,1)+0.02 p5corr(k,1)+0.03 p6corr(k,1)+0.04 p7corr(k,1)+0.05 p2corr(k,1)+0.06];
            y(k,:)=[p1corr(k,2) p3corr(k,2) p4corr(k,2) p5corr(k,2) p6corr(k,2) p7corr(k,2) p2corr(k,2)];

            %interpolation interval has the same number as the number of points that are deleted
            xq{k}=linspace(p1corr(k,1),p2corr(k,1),ic2p2(k)-ic2p1(k)+1);
            %interpolation using spline method 
            yq{k} = interp1(x(k,:),y(k,:),xq{k},'pchip');
            yq{k}(end)=y(k,end);

            
            %correction with points resulting from interpolation 
                if k==1
                    c2infcorrtot{k}=c2inf;
                else
                    c2infcorrtot{k}=c2infcorrtot{k-1};
                end
            c2infcorrtot{k}(ic2p1(k):ic2p2(k),1)=(xq{k})';
            c2infcorrtot{k}(ic2p1(k):ic2p2(k),2)=(yq{k})';
        end
        
    %elimination of points with extremely high and low y coordinates
    c2infcorr=c2infcorrtot{end};
    pdelete=(c2infcorr(:,2)>224 | c2infcorr(:,2)<10);
    c2infcorr(pdelete,:)=[];
    
    else
        
        %if correction is not necessary c2inf is maintained as the input one 
        c2infcorr=c2infpre;
        

    end


    
        %% inner contours after correction
        
        c1corr=[c1sup; c1inf; c1sup(1,:)];
        c2corr=[c2sup; c2infcorr; c2sup(1,:)];
    %%

    
%         figure
%         plot(c1corr(:,1),c1corr(:,2),'r.')
%         hold on
%         plot(c2corr(:,1),c2corr(:,2),'g.')
%         set(gca, 'YDir','reverse')
%         xlabel('x coordinates of inner chest boundary pixels')
%         ylabel('y coordinates of inner chest boundary pixels')
%         ylim([60 170])
%         xlim([10 230])
%         hold off


end
