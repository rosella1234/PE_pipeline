%% function for the user selection of the first inner contour in correction process

%input:
%- Imask: binary images of inner chest region

%output:
%-firstslice= number of slice from which the inner contour correction
%process starts

function [firstslice] = innermask_select(Imask)
    
    %window creation
    fig=uifigure('WindowState','maximized');

    ax=uiaxes(fig,'Position',[0 0 1000 800]);
    imagedata= Imask;

    montage(imagedata,'Parent',ax);
    ax.Visible='off';

    %panel creation
    panel = uipanel(fig,'Title','User selection','Position',[1000 300 300 200],'BackgroundColor',[0.3010 0.7450 0.9330],'FontWeight','bold');

    uilabel(panel,'HorizontalAlignment','left','Position',[1 100 300 20],'Text','Select correct inner mask:','FontWeight','bold');
    
    ef1 = uieditfield(panel,'numeric','Position',[200 100 50 20]);
   

    uibutton( panel,'Text','OK','HorizontalAlignment','right','Position',[150 50 50 20],...
        'ButtonPushedFcn',@(src,event)uiresume(gcbf));

    % wait until the user press the button and save input entered by user
    uiwait(fig)
    firstslice=ef1.Value;
   
    close (fig)

    
end