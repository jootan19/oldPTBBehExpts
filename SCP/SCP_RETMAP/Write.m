function Write(wPtr, text, xPos, yPos, fontSz,textColor, bgColor, font,  penPos)

if ~exist('textColor','var')
    textColor = [255 255 255];
end
if ~exist('bgColor','var')
    bgColor = [128 128 128 128];
end
if ~exist('penPos','var')
    penPos=1;
end
if ~exist('font','var')
    font = [];
end
if ~exist('fontSz','var')
    fontSz = [];
end

Screen('TextFont',wPtr,font);
Screen(wPtr,'TextSize', fontSz);
Screen('DrawText',wPtr,text, xPos,  yPos, textColor  ,bgColor ,penPos);


