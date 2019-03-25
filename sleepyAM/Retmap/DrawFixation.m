function DrawFixation(wPtr, centerX, centerY, fixationlength,sz, clr)
try
    if ~exist('clr', 'var')
        clr = [255 255 255];
    end
    if ~exist('sz', 'var')
        sz = 2;
    end
    Screen('DrawLine', wPtr, clr, centerX-fixationlength, centerY ,centerX+fixationlength, centerY,  sz);
    Screen('DrawLine', wPtr, clr, centerX, centerY-fixationlength,centerX, centerY+fixationlength,   sz);
catch err
    sca;
    ShowCursor;
    fprintf('\n\n Error drawing fixation cross \n\n')
    rethrow(err)
end
