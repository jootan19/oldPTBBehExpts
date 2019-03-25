
% Checkered board and other misc stim specs ======================================
if debug, texsize = 1000;
else      texsize = 1000;
end
pxpersq        = 10;
fixlen         = 20;
fixClr_start   = [255 255 255]; % fixation white when waiting for trigger
fixClr_fix     = [255 255 225]; % fixation white during fixation

wedgeSz1       = 10; % size of checkered board % change to 20???
maskSz1        = 180 - wedgeSz1;
mask1.wedgeSz1 = wedgeSz1;
mask1.Start    = [(wedgeSz1/2) , 180+(wedgeSz1/2)];
mask1.Angle    = maskSz1;

mask2.wedgeSz1 = wedgeSz1;
mask2.Start    = [90+(wedgeSz1/2) , 270+(wedgeSz1/2)];
mask2.Angle    = maskSz1;

maskSz2        = 30; 
wedgeSz2       = 90-maskSz2; % size of checkered board
mask3.wedgeSz2 = wedgeSz2;
mask3.Start    = [90-(maskSz2/2) , 180-(maskSz2/2), 270-(maskSz2/2) , 360-(maskSz2/2)]; %STARTING ANGLES
mask3.Angle    = maskSz2; % SIZE OF MASKING WEDGE

dstRect = [centerX-texsize-5  centerY-texsize-5  centerX+texsize+5 centerY+texsize+5]; %checkered board destination

% Make checkered board inside aperture ======================================
chkdboard1 = MakeCheckeredBoard(texsize*2 ,texsize*2 ,pxpersq ,'w'); % 1st sq white
chkdboard1 = AnnulusOnTexture(texsize,chkdboard1);
chkdboardtex1 = Screen('MakeTexture', wPtr, chkdboard1, [], [], [], [], glsl);

chkdboard2 = MakeCheckeredBoard(texsize*2 ,texsize*2 ,pxpersq ,'b'); % 1st sq black
chkdboard2 = AnnulusOnTexture(texsize,chkdboard2);
chkdboardtex2 = Screen('MakeTexture', wPtr, chkdboard2, [], [], [], [], glsl);