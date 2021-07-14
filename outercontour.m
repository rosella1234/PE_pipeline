%% funzione per il calcolo dei due massimi e del minimo del contorno esterno del torace

%input:
%- BWt= immagine binaria dopo pre-processing
%- yhalf= posizione della metà verticale dell'immagine

%output:
%- max1: coordinate punto del primo max del contorno esterno del torace
%- max2: coordinate punto del secondo max del contorno esterno del torace
%- min: coordinate punto del minimo del contorno esterno del torace
%- BWthorax: immagine binaria del torace
%- boundaryn: coordinate dei punti appartenenti al contorno esterno, in cui
%il primo punto si trova all'altezza della metà dell'immagine

function [max1,max2,pmin,BWthorax,boundaryn] = outercontour(BWt,xhalf,yhalf)
    
    %% rilevamento coordinate contorno esterno prima di operazioni morfologiche (utili per calcolo minimo)
      
    boundarytotpre = bwboundaries(BWt,'noholes');
    boundarypre = boundarytotpre{1};
    %scambio colonne di boundary (bwboundaries le dà invertite)
    boundarypre(:,[1 2]) = boundarypre(:,[2 1]);

    %% applicazione operatori morfologici a immagine binaria del torace
    
    
    se = strel('disk', 20);
    BWthorax = imclose(BWt, se);  
    s1=strel('rectangle',[1 20]);
    BWthorax=imclose(BWthorax,s1);
    s2=strel('rectangle',[1 3]);
    BWthorax=imerode(BWthorax,s2);
    
    %% coordinate del contorno esterno (utili per calcolo dei due max)


    boundarytot = bwboundaries(BWthorax,'noholes');
    boundary = boundarytot{1};
    boundary(:,[1 2]) = boundary(:,[2 1]);

    %% ricerca dei due massimi del contorno esterno

    %differenza tra elementi consecutivi delle coordinate y dei pixel del contorno: dove c'è un max la differenza 
    %passa da negativa a positiva (+1 perchè pixel più alti hanno y minori) dove c'è un minimo viceversa (-1)
    d=diff(boundary(:,2));

    % indice relativo a primo max che corrisponde al primo elemento di d che vale 1 (voglio primo punto della differenza)
    imax1=find(d==1);
    % primo max usando indice in boundary
    max1=boundary(imax1(1),:);

    %indice del minimo che corrisponde al primo elemento di d che vale
    %-1 considerando gli elementi di d da indice del primo max in poi
    imin=find(d(imax1(1)+1:end)==-1);

    %indice relativo a secondo max che corrisponde al primo elemento di d
    %che vale 1 considerando gli elementi di d da indice del minimo in poi
    imax2=find(d(imin(1)+imax1(1)+1:end)==1);
    
    
    if isempty(imax2)==0
        %se imax2 è vuoto prendo come max2 il primo punto dopo il minimo
        %(per evitare errori dovuti alla mancanza del 2 max)
        max2=boundary(imin(1)+imax1(1)+imax2(1),:);
    else
        %secondo max usando indice in boundary
        imax2=imax1(2);
        max2=boundary(imax2,:);
        
    end
    
%%    ricerca del minimo

    %considero coordinate contorno esterno di partenza con y appartenenti alla metà superiore dell'immagine
    minmatrix=boundarypre(boundarypre(:,2)<=yhalf,:);
    %minimo trovato come il punto con y max (y maggiori sono in basso) nell'intervallo compreso tra i due massimi trovati sopra)
    minmatrix=minmatrix(minmatrix(:,1)>max1(1)&minmatrix(:,1)<max2(1),:);
    [mincy,~]=max(minmatrix(:,2));
    %se ci sono più punti alla stessa y considero l'ultimo
    iminclast=find(minmatrix(:,2)==mincy,1,'last');
    pmin=minmatrix(iminclast,:);
    
    %% correzione eventuali errori nell'individuazione dei 2 max
    %se la x di max1 è >xhalf
    if max1(:,1)>xhalf
        %considera come x del minimo xhalf
        ixhalfall=(boundary(:,1)==xhalf);
        [minhalf]=min(boundary(ixhalfall,2));
        pmin(1,1)=xhalf;
        pmin(1,2)=minhalf;
        ixhalf=find(boundary(:,1)<xhalf);
        %calcolo il max tra i punti del contorno minori di xhalf
        [imax1,~]=min(boundary(ixhalf(1):ixhalf(end),2));     
        max1=boundary(imax1+ixhalf(1),:);
    %se la x di max2 è <xhalf
    elseif max2(:,1)<xhalf
        %considera come x del minimo xhalf
        ixhalfall=(boundary(:,1)==xhalf);
        [minhalf]=min(boundary(ixhalfall,2));
        pmin(1,1)=xhalf;
        pmin(1,2)=minhalf;
        ixhalf=find(boundary(:,1)>xhalf);
        %calcolo il max tra i punti del contorno maggiori di xhalf
        [imax2,~]=min(boundary(ixhalf(1):ixhalf(end),2));
        max2=boundary(imax2+ixhalf(1),:);
    end
    
    

    %% correzione punto di partenza del contorno esterno
    
    if boundary(1,2)<yhalf
        i1=find(boundary(:,2)==yhalf,1,'last');
        firstboundary=boundary(i1:end-1,:);
        boundaryn=boundary;
        boundaryn(i1+1:end,:)=[];
        boundaryn=[firstboundary; boundaryn];
    else
        boundaryn=boundary;
    end
    



end