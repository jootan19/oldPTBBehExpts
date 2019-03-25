savelog       = struct;

savelog.SubNo = subno;
savelog.RunNo = runno;
savelog.practice   = practice;
savelog.debugmode  = debugmode;
savelog.RunTime    = RunTime;
savelog.AttendLoc  = attendcond;

% STIMULUS PARAMS
savelog.stimParams.backgrdClr = bgc;

savelog.stimParams.Checkeredboard.AngleSz           = wedgeAngleSz;
savelog.stimParams.Checkeredboard.radius            = boardRadius;
savelog.stimParams.Checkeredboard.contrast          = boardContrast;
savelog.stimParams.Checkeredboard.nradialCyclePairs = rCycles;
savelog.stimParams.Checkeredboard.nSegmentPairs     = tCycles;

savelog.stimParams.Cue.WedgeFillClr  = wedgeCueClr;
savelog.stimParams.Cue.FrameClr      = cueFrameClr;
savelog.stimParams.Cue.FrameSz       = cueFrameSz;
savelog.stimParams.Cue.FrameRadius   = cueFrameRad;

savelog.stimParams.Timings.blockDur            = blockDur;
savelog.stimParams.Timings.cueDur              = cueDur;
savelog.stimParams.Timings.fixDur              = fixDur;
savelog.stimParams.Timings.screenflipInterval  = ifi;
savelog.stimParams.Timings.boardflipwaitframes = waitframes;
savelog.stimParams.Timings.boardFlipInterval   = ifi*waitframes;

% PARADIGM FILE
savelog.paradigm.nblocks = nblocks;
savelog.paradigm.ConditionCode = para(3,:);
savelog.paradigm.CheckeredBoardStartAngle = para(1,:);
savelog.paradigm.CueStartAngle = para(2,:);

[savelog.FSFASTPARAFILE] = makeparafile(subno, runno,blockDur,fixDur,attendcond,para(3,:), practice);

savelog.Note = 'Angles go clockwise, 0 deg = 12noon position';
