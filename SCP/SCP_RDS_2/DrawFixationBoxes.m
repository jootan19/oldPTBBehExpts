function [] = DrawFixationBoxes(wPtr,LeftXCenter,RightXCenter,YCenter,fixationlength,fixationcolour,boxsize,boxcolor,shape)

if ~exist('fixationlength','var') || isempty(fixationlength)
    fixationlength  = 4;
end
if ~exist('fixationcolour','var') || isempty(fixationcolour)
    fixationcolour   =[100 100 100];
end
if ~exist('boxcolor','var') || isempty(boxcolor)
    boxcolor = [255 255 255];
end

if ~exist('shape','var') || isempty(shape)
    shape=2;
end


penwidth        = 4;
fixationlength2 = fixationlength + penwidth;
border          = boxsize;
linewt          = 3;
fixationcolor2  =[0 0 0];



if shape==1,
    Screen('FrameOval', wPtr,boxcolor, [LeftXCenter-border, YCenter-border, LeftXCenter+border, YCenter+border], linewt );
    Screen('FrameOval', wPtr,boxcolor, [RightXCenter-border, YCenter-border, RightXCenter+border, YCenter+border], linewt);
    
end

if shape==2,
    Screen('FrameRect', wPtr, boxcolor, [LeftXCenter-border, YCenter-border, LeftXCenter+border, YCenter+border], linewt);
    Screen('FrameRect', wPtr, boxcolor, [RightXCenter-border, YCenter-border, RightXCenter+border, YCenter+border], linewt);
end

% FIXATION CROSSES ------------------------------------------------------------------------------
Screen('FillOval', wPtr,fixationcolor2,[LeftXCenter-fixationlength2,  YCenter-fixationlength2 ,LeftXCenter+fixationlength2,  YCenter+fixationlength2+1]) 
Screen('FillOval', wPtr,fixationcolor2,[RightXCenter-fixationlength2, YCenter-fixationlength2 ,RightXCenter+fixationlength2, YCenter+fixationlength2+1]) 

Screen('DrawLine', wPtr, fixationcolour, LeftXCenter-fixationlength, YCenter ,LeftXCenter+fixationlength, YCenter,  linewt);
Screen('DrawLine', wPtr, fixationcolour, LeftXCenter, YCenter-fixationlength ,LeftXCenter, YCenter+fixationlength,  linewt);
Screen('DrawLine', wPtr, fixationcolour, RightXCenter-fixationlength, YCenter ,RightXCenter+fixationlength,YCenter, linewt);
Screen('DrawLine', wPtr, fixationcolour, RightXCenter, YCenter-fixationlength ,RightXCenter, YCenter+fixationlength,linewt);

end