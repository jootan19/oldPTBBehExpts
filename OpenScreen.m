% OPEN SCREEN------------------
screenid = max(Screen('Screens'));
x1       = 100;
y1       = 100; % position of screen from left and top
scrsz    = {[x1 y1 x1+1024 y1+765];[]};
if debug
    dispSize = 1; %1=mini screen 2=full screen
elseif ~debug
    dispSize = 2;
end
bkgrdClr = [128 128 128];

try
    if dispSize==2,   HideCursor;    end
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [wPtr, rect] = PsychImaging('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
%         [wPtr, rect] = Screen('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
    resX         = rect(3);
    resY         = rect(4);
catch err
    ShowCursor;
    sca;
    fprintf('\n\nError opening display window\n\n')
    rethrow(err);
end
% Alpha blending to prevent wonky looking gabors
Screen('BlendFunction', wPtr, GL_ONE, GL_ONE);
% Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE);

% % Define center of screen
centerX = resX/2;
centerY = resY/2;