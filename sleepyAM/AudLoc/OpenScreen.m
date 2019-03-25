% Open screen
screenid = max(Screen('Screens'));
x1       = 100;
y1       = 100; % position of screen from left and top
scrsz    = {[x1 y1 x1+1024 y1+765];[]};
if debug
    dispSize = 1; %1=mini screen 2=full screen
elseif ~debug
    dispSize = 2;
end
bkgrdClr = [0 0 0];

try
    if dispSize==2,   HideCursor;    end
    [wPtr, rect] = Screen('OpenWindow', screenid,bkgrdClr, scrsz{dispSize});
    resX         = rect(3);
    resY         = rect(4);
    
    white=WhiteIndex(screenid);    
    AssertGLSL;  % Make sure this GPU supports shading at all:    
    
    % Enable alpha blending for typical drawing of masked textures:
    Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
catch err
    ShowCursor;
    sca;
    fprintf('\n\nError opening display window\n\n')
    fclose all
    rethrow(err);
end

% % Define center of screen
centerX = resX/2;
centerY = resY/2;