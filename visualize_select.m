%% function for the user selection of slices for the further analysis

%inputs: 
%- I_imadjusttotpre: all slices belonging to a patient
%- numtot: number of slices

%outputs:
%- n1: first slice for depression quantification
%- ndend: last slice for depression quantification
%- ns: slice selected for indices computation
%- s1: first slice for inner contour analysis
%- send: last slice for inner contour analysis
%- numimages: number of images analyzed (both for depression quantification and inner contour analysis)
%-deprange: number of images for depression quantification
%- srange: number of images for inner contour analysis
%- gender: patient's gender

function [n1,ndend,ns,s1,send,numimages,deprange,srange,gender] = visualize_select(I_imadjusttotpre,numtot)
    
    
    %% window creation
    fig=uifigure('WindowState','maximized');
    s = get(0, 'ScreenSize');
    
    %% montage representing all slices
    ax=uiaxes(fig,'Position',[0 0 s(3)-200 s(4)-100]);
    imagedata= I_imadjusttotpre;
    
    %row number of montage corresponds of first digit of slice number
    nums=num2str(numtot);
    numrow=str2double(nums(1));
   
    montage(imagedata,'Parent',ax,'Size',[numrow round(numel(I_imadjusttotpre)/(numrow))]);
    ax.Visible='off';

    %% panel creation for input insertion by user
    
    panel=uipanel(fig,'Title','User selection','Position',[s(3)-260 50 250 300],'BackgroundColor',[0.3010 0.7450 0.9330],'FontWeight','bold');

    uilabel(panel,'HorizontalAlignment','right','Position',[10 200 100 20],'Text','First slice','FontWeight','bold');
    ef1 = uieditfield(panel,'numeric','Position',[150 200 50 20]);

    uilabel(panel,'HorizontalAlignment','right','Position',[10 150 100 20],'Text','Last slice','FontWeight','bold');
    ef2=uieditfield(panel,'numeric','Position',[150 150 50 20]);
     
    uilabel(panel,'HorizontalAlignment','right','Position',[10 100 100 20],'Text','Selected slice','FontWeight','bold');
    ef3=uieditfield(panel,'numeric','Position',[150 100 50 20]);
    
    uilabel(panel,'HorizontalAlignment','right','Position',[10 50 100 20],'Text','Gender','FontWeight','bold');
    d4 = uidropdown(panel,'Position',[150 50 50 20],'Items',{'M','F'});
    
   uibutton( panel, 'Text','OK','HorizontalAlignment','right','Position',[100 10 50 20],...
       'ButtonPushedFcn',@(src,event)uiresume(gcbf));
    
   % wait until the user press the button and save inputs entered by user
    uiwait(fig)
         n1=ef1.Value;
         ndend=ef2.Value;
         ns=ef3.Value;
         nend=ns+14;
         gender=d4.Value;
    close (fig)


    %correction of last slice 
    if nend>numtot
       nend=numtot;
    end
    if nend<ndend
       nend=ndend; 
    end

    %total number of slices analyzed 
    numimages=nend-n1+1;
    
    %number of slices for depression quantification
    deprange=ndend-n1+1;

    %first slice for inner contour analysis
    s1=ns-n1+1;
    %last slice for inner contour analysis
    send=numimages;
    %number of slices for inner contour analysis
    srange=send-s1+1;
    
end

