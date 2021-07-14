
%% function for the segmentation of the inner chest contour (vertebral body included)
% Method: the algorithm goes through the outer curvature in clockwise direction
%until the start point is found again. While going through the outer curvature,
%the number of steps is counted. Every 12 steps the actual point and the point
%12 steps before are connected and a perpendicular line in the mid-point 
%is generated. Then the algorithm has to find the intersection point between 
%the perpendicular line and the first point crossed by it on the two lungs.
%If the perpendicular does not meet the lungs the point is located at the 
%same distance as the previous point.

%inputs: 
%- I_imadjust: grey-scale image 
%- BWlung: binary image representing segmented lungs 
%- contour: coordinates of outer chest contour 
%- xhalf: x position of the point located in the half of the image
%- lung1: coordinates of pixels releted to the right lung 
%- lung2: coordinates of pixels releted to the left lung 

%outputs:
%-inters: points representing the inner chest contour 

function [inters] = innercontour_seg(I_imadjust,BWlung,contour,xhalf,lung1,lung2)


%     figure
%     imshow(BWlung)

    
    nsteps=12;
    %number of intersection points to find (calculated from the number of outer 
    %chest contour points  and step number) 
    nrow=round((max(size(contour))-nsteps)/nsteps);

    %initialization
    %middle point
    midX=zeros(nrow,1);
    midY=zeros(nrow,1);
    
    %intersection points
    inters=zeros(nrow,2);
    
    %distance between mean point and intersection point
    distancemidint=zeros(nrow,1);
    
    %mean distances
    distancem=zeros(nrow,1);
    %varianza delle distanze
    stdm=zeros(nrow,1);
    
    %counter
    a=0;

    %partition of the image in 4 quarters: image partitioned in a right and
    %left half (indices: ic2 and ic4)
    icx=find(contour(:,1)==xhalf);
    ic2=icx(1,1);
    ic4=icx(2,1);
    
    % image partitioned in a upper and lower half (indices: ic1 and ic3)
    %index on outer contour corresponding to the first point: 
    ic1=find(contour(1,1));
    %indices on outer contour at the same y as the first point 
    ic3x=find(contour(:,2)==contour(1,2));
    %elimination of consecutive points at the same y
    ic3delete=find(diff(ic3x)==1);
    ic3x(ic3delete+1)=[];
    % index corresponding to the point with greater x:
    ic3=ic3x(2,1);

    %algorithm goes through the entire outer chest contour 
    for i=1:nsteps:max(size(contour))-nsteps

        a=a+1;
        %starter and end point of each segment
        p1=contour(i,:);
        p2=contour(i+nsteps,:);
        
%        %segment between the 2 points
%         hold on
%         plot([p1(1) p2(1)],[p1(2) p2(2)],'y-')
%         hold on

        %middle point of segment
        midX(a,1) = round(mean([p1(1), p2(1)]));
        midY(a,1) = round(mean([p1(2), p2(2)]));

        %if the 2 points are at the same y, perpendicular line is: x=midX 
        if p2(2)==p1(2)
            % vector with the same pixel number of the image
            y = linspace(1,size(I_imadjust,1),size(I_imadjust,2));
            %perpendicular line
            x=midX(a,1).*ones(1,size(I_imadjust,2));
            %slope assigned to 'a' 
            slope='a';

       %if the 2 points are at the same x, perpendicular line is: y=midY
        elseif p2(1)==p1(1)
            x = linspace(1,size(I_imadjust,1),size(I_imadjust,2));
            y=midY(a,1).*ones(1,size(I_imadjust,2));
            %slope assigned to '0'
            slope=0;

        %otherwise segment slope is computed
        else
            slope = (p2(2)-p1(2)) / (p2(1)-p1(1));

            % perpendicular line slope 
            slope = -1/slope;

            % x vector with the same pixel number of the image 
            x = round(linspace(1,size(I_imadjust,1),size(I_imadjust,2)));

            % y corresponding to x coordinates calculated from equation
            % (perpendicular line passing through middle point of the
            % segment)
            y = round(slope * (x - midX(a,1)) + midY(a,1));

            %elimination of y values outside the image (and corresponding x values)  
            idelete=find(y>size(I_imadjust,1) | y<=0);
            y(idelete)=[];
            x(idelete)=[];

        end

%         %perpendicular line
%         plot(x,y, 'b-');
%         hold on
        
        %matrix containing x and y coordinates of perpendicular line points 
        mat=[x' y'];

        %% application of algorithm with different conditions based on the quadrant analyzed 
        
        %first quadrant: right lung considered (outer contour upper border):
        %if the slope of the perpendicular increases (> 0) the intersection point
        % is the first one(that with the smallest y), if the slope is negative the point is
        % the last one(that with the lowest y), if the slope is 0 (parallel to the y axis)
        % and if the slope does not exist (parallel to the x axis) the point of
        % intersection is the first one.
        if i>=ic1 && i<=ic2 
            %common points between perpendicular line and right lung region
            [v,~,ib] = intersect(lung1,mat,'rows');

            %if there are common points
            if isempty(ib)==0
                
                %if the slope is negative, the y of the intersection points
                % decrease (y (end) <y (2)) so the order of the indices is 
                %reversed because I want the point with lower y coordinate
                %that is the last one
                if (v(1,2)>v(end,2))
                    ib=sort(ib,'descend');
                end
                
                %otherwise the intersection point is the first one
                inters(a,:)=mat(ib(1),:);

            end
            
        %second quadrant: left lung considered (outer contour upper border): 
        %same method as for the first quadrant except in the case of
        %slope=0 (y = cost) where I want the last point
        elseif i>=ic2 && i<=ic3

             [v,~,ib] = intersect(lung2,mat,'rows');

            
            if isempty(ib)==0
                %if slope<0 or y=cost the order of the indices is 
                %reversed because I want the point with lower y coordinate
                %that is the last one
                if (v(1,2)>=v(end,2))
                 ib=sort(ib,'descend');
                end
                %otherwise the intersection point is the first one
                inters(a,:)=mat(ib(1),:);

            end
            
        %third quarter: left lung considered (outer countour lower border):
        %if the slope of the perpendicular increases (> 0) the intersection point
        % is the last one (that with the greatest y), if the slope is negative (<0) 
        %the point is the first one (that with the greatest y), if the slope is 0 
        %(parallel to the y axis) and if the slope does not exist (parallel to the x axis) 
        %the intersection point is the last one.
        elseif i>=ic3 && i<=ic4

            [v,~,ib] = intersect(lung2,mat,'rows');

            if isempty(ib)==0
                %if slope<0 the order of the indices is reversed because 
                %I want the first point 
                if (v(1,2)>v(end,2))
                 ib=sort(ib,'descend');
                end
                %intersection point is the last one
                inters(a,:)=mat(ib(end),:);

            end
            
        %fourth quadrant: rightlung considered (outer contour lower border): 
        %same method as for the third quadrant except in the case of
        %slope=0 (y = cost) where I want the first point   
        else
            [v,~,ib] = intersect(lung1,mat,'rows');
 
            if isempty(ib)==0

                %if slope<0 or y=cost the order of the indices is reversed
                %because I want the first point 
                if (v(1,2)>=v(end,2))
                 ib=sort(ib,'descend');
                end
                %intersection point is the last one
                inters(a,:)=mat(ib(end),:);
             end


        end



    %%  cases where the perpendicular line doesn't cross the lungs
       
        mid=[midX, midY];
        %distance between middle point and intersection point
        distancemidint(a)=sqrt((mid(a,1)-inters(a,1)).^2+(mid(a,2)-inters(a,2)).^2);
        %mean value 
        distancem(a)=mean(distancemidint(1:a));
        %standard deviation
        stdm(a)=std(distancemidint(1:a));

        %analysis beging to the second intersection point
        if a>1
        %if the distance between the midpoint and the intersection point is 
        %greater than 2*mean distance-standard deviation (threshold)
        if distancemidint(a)>=(2*floor(distancem(a)))-floor(stdm(a))
            %distance replaced by the previous one
            distancemidint(a)=distancemidint(a-1);
            %mean value recomputed 
            distancem(a)=mean(distancemidint(1:a));
            %distance between the midpoint and perpendicular line points 
            distmatmid=round(sqrt((mid(a,1)-mat(:,1)).^2+(mid(a,2)-mat(:,2)).^2));
            %midpoint index
            imid=find(distmatmid==0);
            slope=round(slope);
            %analysis diversified based on the quadrant
                %first quadrant
                if i>=ic1 && i<=ic2     
                    if slope<0
                        %elimination of the points after the mid point
                        %(the last ones: y decreases) 
                        distmatmid(imid+1:end)=[];
                        mat(imid+1:end,:)=[];  
                    %if slope >0, x=cost(slope=a) and y=cost(slope=0)
                    else
                        %elimination of the points before the mid point
                        %(the first ones: y increases)
                        distmatmid(1:imid-1)=[];
                        mat(1:imid-1,:)=[];

                    end

                %second quadrant
                elseif i>ic2 && i<=ic3

                    if slope<=0
                        %elimination of the points after the mid point
                        %(the last ones: y decreases)
                        distmatmid(imid+1:end)=[];
                        mat(imid+1:end,:)=[];                     

                    %if slope >0, x=cost(slope=a) 
                    else
                        %elimination of the points before the mid point
                        %(the first ones: y increases)
                        distmatmid(1:imid-1)=[];
                        mat(1:imid-1,:)=[];

                    end
                    
                %third quadrant    
                elseif i>ic3 && i<=ic4
                    
                    %elimination of the points before the mid point
                    %(the first ones: y decreases)
                    if slope<0
                        distmatmid(1:imid-1)=[];
                        mat(1:imid-1,:)=[];

                    %slope >0, x=cost(slope=a) and y=cost(slope=0)
                    else
                        %elimination of the points after the mid point
                        %(the last ones: y increases)
                        distmatmid(imid+1:end)=[];
                        mat(imid+1:end,:)=[];
                    end
                %fourth quadrant    
                else
                    if slope<=0
                        %elimination of the points before the mid point
                        %(the first ones: y decreases) 
                        distmatmid(1:imid-1)=[];
                        mat(1:imid-1,:)=[];

                    %slope >0, x=cost(slope=a) 
                    else
                        %elimination of the points after the mid point
                        %(the last ones: y increases) 
                        distmatmid(imid+1:end)=[];
                        mat(imid+1:end,:)=[];
                    end

                end
              % index of the point closer to the wanted distance
              [~,iinters]=min(abs(distmatmid-distancemidint(a)));  
              if isempty(iinters)==0
                inters(a,:)=mat(iinters,:);   
              end
        end
        %if intersection point is zero: error in the computation
         if ~any(inters(a,:))
             %point replaced by a point at the same distance as the
             %previous one
             distancemidint(a)=distancemidint(a-1);
             distancem(a)=distancem(a-1);
         end

        end

%         hold on
%         plot(inters(a,1),inters(a,2),'r.');
% 
%         hold off


    end

    

end