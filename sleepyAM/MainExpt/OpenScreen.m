function [wPtr, rect] = OpenScreen(debug)
fprintf('Running %s...',mfilename())
AssertOpenGL;
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
    %     PsychImaging('PrepareConfiguration');
    %     PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    %     [wPtr, rect] = PsychImaging('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
    [wPtr, rect] = Screen('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
    
catch err
    fprintf('\n\nError opening display window\n\n')
    CleanUp
    rethrow(err);
end


fprintf('%s [Done]\n\n',mfilename())
