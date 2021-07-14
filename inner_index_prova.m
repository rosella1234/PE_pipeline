%% funzione per il calcolo degli indici

%input:
%- pcontour: coordinate punti del contono interno
%- pmax1: coordinate primo max contorno esterno 
%- pmax2: coordinate secondo max contorno esterno
%- I_imadjust: immagine in scala di grigi della slice su cui calcolare gli
%indici
%- I: immagine in scala di grigi della slice selezionata dall'utente
%- pixel_distance: vettore contenente le distanze tra i pixel in
%orizzontale e verticale

%output:
%- transversed: diametro trasversale 
%- emitsxd: diametro anteroposteriore emitorace sinistro
%- emitsxd: diametro anteroposteriore emitorace destro
%- iAsymetry: indice di asimmetria
%- iFlateness: indice di flatness
%- minsternum: posizione sterno (limite superiore minAPd)
%- maxAPd: massimo diametro anteroposteriore
%- minAPd: minimo diametro anteroposteriore
%- Haller_ind: indice di Haller
%- Correction_ind: indice si correzione
%- depression_ind: indice di depressione
%- pvertebral body: posizione corpo vertebrale


function [transversed,emitsxd,emitdxd,iAsymetry,iFlatness,minsternum,...
    maxAPd,minAPd,Haller_ind,Correction_ind,depression_ind,pvertebralbody]= inner_index(pcontour,pmax1,pmax2,Isel,pixel_distance,c,patient1)


%% diametro trasversale

%x minima del contorno interno 
[xmin,idmin]=min(pcontour(:,1));
%x massima del contorno interno 
[xmax,~]=max(pcontour(:,1));

%trovo y dei punti a x max e min: y uguale a quella del punto a x minima
%(scelta)
y_xmin=pcontour(idmin,2);
y_xmax=pcontour(idmin,2);


%punti estremi diametro trasverale
p1contour=[xmin,y_xmin];
p2contour=[xmax,y_xmax];
%calcolo diametro trasversale come distanza tra punto con x minima e punto
%alla stessa y su confine opposto
transversed_p=sqrt((p2contour(1,1)-p1contour(1,1))^2+(p2contour(1,2)-p1contour(1,2))^2);
transversed=(transversed_p*pixel_distance(1))./10;




%% posizione sterno

% punto corrispondente a max1 sul contorno interno (parte superiore)
imax1=find(pcontour(:,1)==pmax1(1),1,'first');
% punto corrispondente a max2 sul contorno interno (parte superiore)
imax2=find(pcontour(:,1)==pmax2(1),1,'first');

% pmax1inner=round(pcontour(imax1,:));
% pmax2inner=round(pcontour(imax2,:));

%punto minimo del contorno interno: posizione sterno
%preso come il punto con y max nell'intervallo compreso tra le posizioni
%dei due max
[minsternumv,~]=max(pcontour(imax1:imax2,2));
iminsternuma=find(pcontour(imax1:imax2,2)==minsternumv);
%tra punti alla stessa y prendo quello in posizione intermedia
iminsternum=abs((iminsternuma(end)+iminsternuma(1))/2)+imax1-1;
minsternum=pcontour(iminsternum,:);



%% distanze anteroposteriori emitorace dx e sx

%punti alla stessa x del primo e secondo max sul contorno interno
iemitsx=find(pcontour(:,1)==pmax2(1));
iemitdx=find(pcontour(:,1)==pmax1(1));


%distanze anteroposteriori emitorace dx e sx
emitsxd_p=sqrt((pcontour(iemitsx(1),1)-pcontour(iemitsx(2),1))^2+(pcontour(iemitsx(1),2)-pcontour(iemitsx(2),2))^2);
emitsxd=(emitsxd_p*pixel_distance(1))./10;
emitdxd_p=sqrt((pcontour(iemitdx(1),1)-pcontour(iemitdx(2),1))^2+(pcontour(iemitdx(1),2)-pcontour(iemitdx(2),2))^2);
emitdxd=(emitdxd_p*pixel_distance(1))./10;

%indice di asimmetria
iAsymetry=emitdxd/emitsxd;

%indice di flatness
iFlatness=transversed/(max(emitsxd,emitdxd));

%% calcolo maxAPd e minAPd

%per la posizione della colonna vertebrale considero punto max del confine
%inferiore dopo la segmentazione corretta del contorno interno

%punto corrispondente a max1 sul contorno interno (parte inferiore)
i2max1=find(pcontour(:,1)==pmax1(1),1,'last');
%punto corrispondente a max2 sul contorno interno (parte inferiore)
i2max2=find(pcontour(:,1)==pmax2(1),1,'last');

%posizione corpo vertebrale: punto a y minimo compreso tra le x dei due max 
%(parto da max2 perchè nel contorno inferiore le x sono decrescenti (indice 
%di max2 è precedente a quello di max1)
[~,ivertebralPoint]=min(pcontour(i2max2:i2max1,2));
ivertebralPoint=ivertebralPoint+i2max2-1;
vertebralPoint=pcontour(ivertebralPoint,:);

if c==2
%     figure
%     imshow(Isel)
    
    fig1=uifigure('Position',[100 100 1000 600]);
    lbl = uilabel(fig1);
    lbl.Text = 'The slice is not the one selected by user';
    lbl.Position = [300 500 1000 60];
    lbl.FontSize = 20;
    lbl.FontColor='r';
    ax=uiaxes(fig1,'Position',[500 50 450 450]);
    imshow(Isel,'Parent',ax);
    ax.Visible='off';
    uilabel(fig1,'Text','1. Insert sternum position','Position',[50 50 300 600],'FontSize',15);
    hold (ax,'on')
%     panel = uipanel(fig1,'Position',[50 50 600 300]);
    
    pminsternum=drawpoint('Parent',ax);
    uilabel(fig1,'Text','2. Insert vertebral body position','Position',[50 20 300 600],'FontSize',15);
    hold (ax,'on')
    
    pvertebral=drawpoint('Parent',ax);
    hold (ax,'off')
    minsternum=round(pminsternum.Position(1,:));
    vertebralPoint=round(pvertebral.Position(1,:));
  
     close (fig1)

end

%punti sul contorno interno alla stessa y del punto sulla colonna
%vertebrale (punti con x min e x max alla stessa y della vertebra)
p1vertebraline=[xmin,vertebralPoint(2)];
p2vertebraline=[xmax,vertebralPoint(2)];


%punto su linea orizzontale alla stessa x del punto max emitorace sx
pmaxemitsx=pcontour(iemitsx(1),:);
%punto su linea orizzontale alla stessa x del punto max emitorace dx
pmaxemitdx=pcontour(iemitdx(1),:);

pvlinemitsx=[pmaxemitsx(1) p1vertebraline(2)];
pvlinemitdx=[pmaxemitdx(1) p1vertebraline(2)];

%calcolo max APd: distanze tra max punto emitorace sx e linea orizzontale
maxAPd_psx=sqrt((pvlinemitsx(1)-pmaxemitsx(1))^2+(pvlinemitsx(2)-pmaxemitsx(2))^2);
maxAPd_pdx=sqrt((pvlinemitdx(1)-pmaxemitdx(1))^2+(pvlinemitdx(2)-pmaxemitdx(2))^2);
maxAPd=max(maxAPd_psx,maxAPd_pdx);
maxAPd=(maxAPd*pixel_distance(1))./10;

%punto corripondente alla stessa x dello sterno (minimo contorno interno)
%su linea orizzontale
pvertebralbody=[minsternum(1),p1vertebraline(2)];

%calcolo min APd: distanza minima tra sterno e colonna
minAPd_p=sqrt((pvertebralbody(1)-minsternum(1))^2+(pvertebralbody(2)-minsternum(2))^2);
minAPd=(minAPd_p*pixel_distance(1))./10;

%indice di Haller 
Haller_ind=transversed/minAPd;

%indice di correzione
Correction_ind=((maxAPd-minAPd)/maxAPd)*100;

%indice di depressione
depression_ind=emitsxd/minAPd;


%%
fig=figure;
imshow(Isel);

hold on
plot(pcontour(:,1),pcontour(:,2),'g');
% %diametro trasversale
line([p2contour(1,1) p1contour(1,1)],[p2contour(1,2) p1contour(1,2)],'color','r','LineWidth', 1.5)



%rappresento distanze anteroposteriori emitorace dx e sx
line([pcontour(iemitsx,1) pcontour(iemitdx,1)],[pcontour(iemitsx,2) pcontour(iemitdx,2)],'color','b','LineWidth', 1.5)

line([pvertebralbody(1) minsternum(1)],[pvertebralbody(2) minsternum(2)],'color','y','LineWidth',1.5)
%linea orizzontale al livello del confine della colonna
line([p1vertebraline(1) p2vertebraline(1)],[p1vertebraline(2) p2vertebraline(2)],'color','c')
line([pcontour(iemitdx(1),1) pvlinemitdx(1)],[pcontour(iemitdx(1),2)  pvlinemitdx(2)],'color','g','LineWidth',1.5)
plot(pvlinemitsx(1),pvlinemitsx(2),'r.','MarkerSize', 6);
plot(minsternum(1,1),minsternum(1,2),'r.','MarkerSize', 6)
plot(pvlinemitdx(1),pvlinemitdx(2),'r.','MarkerSize', 6);

plot(pcontour(iemitsx,1),pcontour(iemitsx,2),'r.','MarkerSize', 6);
plot(pcontour(iemitdx,1),pcontour(iemitdx,2),'r.','MarkerSize', 6);

plot(vertebralPoint(1,1),vertebralPoint(1,2),'r.','MarkerSize', 6)



hold off
%%

% fig=uifigure('WindowState','maximized');
% fig=uifigure('Position',[100 100 1000 600]);
% 
% ax=uiaxes(fig,'Position',[500 50 450 450]);
% imshow(Isel,'Parent',ax);
% ax.Visible='off';
% 
% 
% hold (ax,'on')
% %diametro trasversale
% line([p2contour(1,1) p1contour(1,1)],[p2contour(1,2) p1contour(1,2)],'color','r','LineWidth', 1.5,'Parent',ax)
% 
% plot(pcontour(iminsternum,1),pcontour(iminsternum,2),'g.','MarkerSize', 10,'Parent',ax)
% 
% %rappresento distanze anteroposteriori emitorace dx e sx
% line([pcontour(iemitsx,1) pcontour(iemitdx,1)],[pcontour(iemitsx,2) pcontour(iemitdx,2)],'color','b','LineWidth', 1.5,'Parent',ax)
% plot(pcontour(iemitsx,1),pcontour(iemitsx,2),'r.','MarkerSize', 5,'Parent',ax);
% plot(pcontour(iemitdx,1),pcontour(iemitdx,2),'r.','MarkerSize', 5,'Parent',ax);
% 
% plot(vertebralPoint(1,1),vertebralPoint(1,2),'g.','MarkerSize', 10,'Parent',ax)
% %linea orizzontale al livello del confine della colonna
% line([p1vertebraline(1) p2vertebraline(1)],[p1vertebraline(2) p2vertebraline(2)],'color','c','Parent',ax)
% 
% plot(pvlinemitsx(1),pvlinemitsx(2),'r.','MarkerSize', 5,'Parent',ax);
% 
% plot(pvlinemitdx(1),pvlinemitdx(2),'r.','MarkerSize', 5,'Parent',ax);
% line([pvertebralbody(1) minsternum(1)],[pvertebralbody(2) minsternum(2)],'color','y','LineWidth', 1.5,'Parent',ax)
% 
% 
% hold (ax,'off')

% Inner_distances={'transverse diameter (cm)'; 'min APd (cm)'; 'max APd (cm)'; 'APd right emitorax (cm)'; 'APd left emitorax (cm)'; 'iHaller';'iCorrection (%)'; 'iAsymetry'; 'iFlatness'};
% 
% values=[transversed; minAPd; maxAPd; emitdxd; emitsxd; Haller_ind; Correction_ind; iAsymetry; iFlatness];
% 
% Tdresult=table(values,'RowNames',Inner_distances);
% 
% 
% uitable(fig,'Data',Tdresult,'InnerPosition',[100 200 300 250]);


% saveas(fig,'es','pdf')
% writetable(Tdresult,'result.txt','WriteRowNames',true);



% writetable(Tr,table_path_format,'WriteRowNames',true);



end


