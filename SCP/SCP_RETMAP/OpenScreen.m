function [wPtr, rect,ifi] = OpenScreen(bgc,debugmode)
% OPEN SCREEN------------------
% screensAvail = Screen('Screens');
% screenid = screensAvail(1);
screenid = max(Screen('Screens'));

% iMac screen aspect ratio: 16:9 (1920 x 1080)
x1       = 50;
y1       = 50; % position of screen from left and top
scrsz    = {[x1 y1 x1+1024 y1+765];[]};
if debugmode
    dispSize = 1; %1=mini screen 2=full screen
elseif ~debugmode
    dispSize = 2;
end
bkgrdClr = bgc;

try
    if dispSize==2,   HideCursor;    end
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [wPtr, rect] = PsychImaging('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
%     [wPtr, rect] = Screen('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
catch err
    ShowCursor;
    sca;
    disp('Error opening display window')
    rethrow(err);
end
% Alpha blending to prevent wonky looking gabors
% Screen('BlendFunction', wPtr, GL_ONE, GL_ONE);
% Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE);
% Screen('BlendFunction', wPtr, GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA);

ifi = Screen('GetFlipInterval', wPtr);