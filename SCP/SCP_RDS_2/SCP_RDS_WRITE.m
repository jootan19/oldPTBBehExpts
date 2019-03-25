function SCP_RDS_WRITE(wPtr, text, xPos_L, xPos_R, yPos, fontSz,textColor, bgColor, font,  penPos)

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
Screen('DrawText',wPtr,text, xPos_L,  yPos, textColor  ,bgColor ,penPos);
Screen('DrawText',wPtr,text, xPos_R,  yPos, textColor  ,bgColor ,penPos);


