
function [] = DrawFixationBox(wPtr,LeftXCenter,RightXCenter,YCenter,boxsize,boxcolor)
if nargin<6, boxcolor=[255 255 255]; end

fixationlength  =10;
border          =boxsize;
linewt          =2;
fixationcolor   =[255 0 0];

Screen('FrameRect', wPtr, boxcolor, [LeftXCenter-border, YCenter-border, LeftXCenter+border, YCenter+border], linewt);
Screen('FrameRect', wPtr, boxcolor, [RightXCenter-border, YCenter-border, RightXCenter+border, YCenter+border], linewt);

% FIXATION CROSSES ------------------------------------------------------------------------------
Screen('DrawLine', wPtr, fixationcolor, LeftXCenter-fixationlength, YCenter ,LeftXCenter+fixationlength, YCenter,  linewt);
Screen('DrawLine', wPtr, fixationcolor, LeftXCenter, YCenter-fixationlength ,LeftXCenter, YCenter+fixationlength,  linewt);
Screen('DrawLine', wPtr, fixationcolor, RightXCenter-fixationlength, YCenter ,RightXCenter+fixationlength,YCenter, linewt);
Screen('DrawLine', wPtr, fixationcolor, RightXCenter, YCenter-fixationlength ,RightXCenter, YCenter+fixationlength,linewt);
end