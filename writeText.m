function writeText(wPtr, text, xPos, yPos, textColor, bgColor, penPos, font, fontSz)

if ~exist('textColor','var')
    textColor = [0 0 0 0];
end
if ~exist('bgColor','var')
    bgColor = [0 0 0 0];
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

