function [CHECKEREDBOARD, CHECKEREDBOARD_COMP,CIRCLE] = MakeRadialCheckeredBoard(RADIUS,RCYCLES,TCYCLES,CONTRAST)

if ~exist('RADIUS','var'),  RADIUS = 500; end % Radius of checkeredboard
if ~exist('RCYCLES','var'), RCYCLES = 10; end % Number of white/black circle pairs
if ~exist('TCYCLES','var'), TCYCLES = 10; end % Number of white/black angular segment pairs (integer)
if ~exist('CONTRAST','var'), CONTRAST = 1; end % MICHELSON CONTRAST VALUE 0 TO 1;

GREYID   = 0.5;
WHITEID  = GREYID + (CONTRAST/2); 
BLACKID  = GREYID - (CONTRAST/2);
DIAMETER = RADIUS*2;

try
    XYLIM  = 2 * pi * RCYCLES;    
    [X, Y] = meshgrid(-XYLIM: 2 * XYLIM / (DIAMETER  - 1): XYLIM,...
        -XYLIM: 2 * XYLIM / (DIAMETER  - 1): XYLIM);    
    ATAN   = atan2(Y, X);
    CHECKEREDBOARD      = ((1 + sign(sin(ATAN * TCYCLES) + eps)...
        .* sign(sin(sqrt(X.^2 + Y.^2)))) / 2) * (WHITEID - BLACKID) + BLACKID;
    CIRCLE              = X.^2 + Y.^2 <= XYLIM^2;
    CHECKEREDBOARD      = CIRCLE .* CHECKEREDBOARD + GREYID * ~CIRCLE;
    CHECKEREDBOARD_COMP = imcomplement(CHECKEREDBOARD);    

catch err
    sca;
    ShowCursor;
    commandwindow
    rethrow(err)
end