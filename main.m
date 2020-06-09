%==========================================================================
%% STEP-1: SET PROJECT FOLDER PATHS
%==========================================================================
close all; clear; clc; rng('shuffle');



% SPECIFY PROJECT FOLDER PATH
PROJECT_FOLDER_PATH = ...
    '/Users/bradleymonk/GIT/trackpupil';



% ADD PATHS TO WORKSPACE
P.home  = PROJECT_FOLDER_PATH; cd(P.home);
P.funs  = [P.home filesep 'funs'];
P.vids  = [P.home filesep 'vids'];
P.data  = [P.home filesep 'data'];
addpath(join(string(struct2cell(P)),pathsep,1))
cd(P.home); P.f = filesep;



% SPECIFY DEFAULT FIGURE PREFS
set(groot,'defaultFigureColor','w')
set(groot,'defaultAxesFontSize',14)
set(groot,'defaultLineLineWidth',2)
set(groot,'defaultFigurePosition',[100 35 700 600])







%==========================================================================
%% STEP-2: SEGMENT FRAME-1 OF VIDEO
%==========================================================================
clc; clearvars -except P




% CREATE VIDEO OBJECT
obj = VideoReader('eye.mp4');
NFRAMES = obj.NumFrames;




% IMPORT FRAME-1
IM = read(obj,1);


% MP4 IMPORTS AS RBG. CONVERT TO GRAYSCALE
IM = rgb2gray(IM);



% SHOW FRAME-1
close all; imshow(IM)





% SEGMENT FRAME USING BAG OF TRICKS
IMG = ~imbinarize(IM,0.20); close all; imagesc(IMG);

IMG = bwmorph(IMG,'close'); close all; imagesc(IMG);

IMG = bwmorph(IMG,'open'); close all; imagesc(IMG);

IMG = bwareaopen(IMG,200); close all; imagesc(IMG);

IMG = imfill(IMG,'holes'); close all; imagesc(IMG);




% TAG OBJECTS
LABMX = bwlabel(IMG);  close all; imagesc(LABMX);



% GET REGION PROPERTIES
RPROPS = regionprops(LABMX);



% COUNT NUMBER OF ROIs
N = size(RPROPS,1);



% FIND THE LARGEST OBJECT
A = [RPROPS.Area];
[~, pj] = max(A);



% GET CENTER OF LARGEST OBJECT
CENTER = round(RPROPS(pj).Centroid);
X = CENTER(1);
Y = CENTER(2);




% PLOT IMAGE AND BOUNDING TRACES
close all; imagesc(IM); 
colormap gray; axis equal; 
axis off; hold on;


rectangle('Position',RPROPS(pj).BoundingBox,'EdgeColor',[1 0 0],...
    'Curvature', [1,1],'LineWidth',3); hold on;


plot(X,Y,'g+'); hold off;

drawnow;









%==========================================================================
%% STEP-3: SEGMENT ALL FRAMES
%==========================================================================
clc; close all; clearvars -except P




% CREATE VIDEO OBJECT
obj = VideoReader('eye.mp4');
NFRAMES = obj.NumFrames;





for ii = 1:NFRAMES


    % IMPORT FRAME-1
    IM = read(obj,ii);

    % MP4 IMPORTS AS RBG. CONVERT TO GRAYSCALE
    IM = rgb2gray(IM);

    % SEGMENT FRAME USING BAG OF TRICKS
    IMG = ~imbinarize(IM,0.20);
    IMG = bwmorph(IMG,'close');
    IMG = bwmorph(IMG,'open');
    IMG = bwareaopen(IMG,200);
    IMG = imfill(IMG,'holes');

    % TAG OBJECTS
    LABMX = bwlabel(IMG);

    % GET REGION PROPERTIES
    RPROPS = regionprops(LABMX);

    % COUNT NUMBER OF ROIs
    N = size(RPROPS,1);

    % FIND THE LARGEST OBJECT
    A = [RPROPS.Area];
    [~, pj] = max(A);


    if isempty(pj)

        imagesc(IM); 
        colormap gray; axis equal; 
        axis off; hold on;

    else


        % GET CENTER OF LARGEST OBJECT
        CENTER = round(RPROPS(pj).Centroid);
        X = CENTER(1);
        Y = CENTER(2);


        % PLOT IMAGE AND BOUNDING TRACES
        imagesc(IM); 
        colormap gray; axis equal; 
        axis off; hold on;

        rectangle('Position',RPROPS(pj).BoundingBox,'EdgeColor',[1 0 0],...
            'Curvature', [1,1],'LineWidth',3); hold on;

        plot(X,Y,'g+'); hold off;

    end

    drawnow; %pause(.01)

end




%==========================================================================
%% TBD
%==========================================================================
% 
% 
% Is first frame during a blink?
% 
% 
% How to dealing with blinks in general?
% 
% 
% How to deal with black objects larger than a pupil?
%     - When would this happen?
% 
% 
% Is it more reliable to use a stack projection image or the first frame?
% 
% 
% How to convert AU into real-world length measurements?
%   - determine if person is male or female, then use mean eye size
%     as reference benchmark
% 
% 
% 
%% EOF