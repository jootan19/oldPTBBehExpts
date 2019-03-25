clear all;
close all;
commandwindow;
home;
tic

debugmode = 0;
log       = 1;
runtime   = fix(clock);
runDate   = runtime(1,[3,2,1,4,5,6]);
RunTime   = datestr(now);

if log,
    logDir = 'log';
    if ~exist(logDir,'dir')
        mkdir(logDir);
    end
    logfname = sprintf('log/%s_%02i%02i%i_%02i.%02i.%02i.log',mfilename(),runDate);
    diary(logfname);
end

[subno , runno , attendcond, practice, QuitSignal] = SCP_RETMAP_GETINPUTS(debugmode);
if QuitSignal, return, end

if practice, practStr = 'practiceData';
else         practStr = 'rawData';
end

OutputDir = sprintf('%s_data/%s/sub%03i',mfilename(),practStr, subno);
if ~exist(OutputDir,'dir')
    mkdir(OutputDir);
end

fNameStr = sprintf('Sub%03i_%03i_%s_%s',subno,runno,attendcond,datestr(now,'ddmmyyyy_HHMM'));

PsychDefaultSetup(2);
bgc = 0.5;
[wPtr,rect,ifi] = OpenScreen(bgc,debugmode);
waitframes = 2;

XCtr = rect(3)/2;
YCtr = rect(4)/2;
fixlen  = 15;
fixwth  = 5;
fixclr  = [1 1 1];

boardRadius = rect(4)/2;
rCycles = 10;
tCycles = 10;
boardContrast = 0.8;

[checkboard, checkboard_comp] = MakeRadialCheckeredBoard(boardRadius,rCycles,tCycles,boardContrast);
checkboard_tPtr      = Screen('MakeTexture',wPtr,checkboard);
checkboard_comp_tPtr = Screen('MakeTexture',wPtr,checkboard_comp);

wedgeCueClr     = 0.8;
wedgeLoc        = [XCtr-boardRadius+1 YCtr-boardRadius+1 XCtr+boardRadius YCtr+boardRadius];
wedgeMaskClr    = bgc;
wedgeAngleSz    = 180;
wedgeStartAngle = [0 90 180 270]; % Checkeredboard wedge start angle: 0 = 12'oclock, angle goes clockwise

cueFrameClr = [1 0 0];
cueFrameSz  = 5;
cueFrameRad = boardRadius + 3;
cueFrameLoc = [XCtr-cueFrameRad+1 YCtr-cueFrameRad+1 XCtr+cueFrameRad YCtr+cueFrameRad];

switch attendcond
    case 'Left_Right'
        cueAngle = [0 180];
    case 'Up_Down'
        cueAngle = [90 270];
end

para1   = [repmat(wedgeStartAngle,1,length(cueAngle)); repmat(cueAngle,1,length(wedgeStartAngle))];
nblocks = size(para1,2);
switch attendcond
    case 'Left_Right'
        para2   = [para1 ; 1:nblocks];
    case 'Up_Down'
        para2   = [para1 ; nblocks+1:nblocks+nblocks];
end
para    = para2(:,randperm(nblocks));

% timings
if ~debugmode
    blockDur = 16;
    cueDur   = 2;
    if practice
        fixDur = 2;
    else
        fixDur   = 14;
    end
else
    blockDur = 8;
    cueDur   = 2;
    fixDur   = 1;
end

% create savelog and fsfast file
SCP_RETMAP_SAVELOG;

% keyboard
quitkey   = 'Q';
startkey1 = KbName('space');
startkey2 = KbName('enter');

% Get Device IDs automatically
if practice,    [~, QuitSignal,TrigDevID, RespDevID] = getDevID3(1,1);
else            [~, QuitSignal,TrigDevID, RespDevID] = getDevID3(2,4);
end
KbQueueCreate(TrigDevID);   KbQueueStart(TrigDevID);

ListenChar;
if QuitSignal ==1,
    sca;     ShowCursor;    diary off;  fprintf('Experiment terminated early!!!!\n');    return,
end

topPriorityLevel = MaxPriority(wPtr);
Priority(topPriorityLevel);

vbl = Screen('Flip', wPtr);

% --------------MAIN EXPERIMENT BLOCK
while 1,
    try
        Write(wPtr, 'Waiting for trigger', XCtr-140, YCtr-100, 30)
        Write(wPtr, 'Pls attend to cued location', XCtr-190, YCtr+100, 30)
        DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr,bgc)
        vbl = Screen('Flip', wPtr, (0.5)*ifi + vbl);
        QuitKeyWait; if QuitSignal ==1 , return, end
        [keyIsDown, FirstKeyDownTime] = KbQueueCheck(TrigDevID);
        if keyIsDown
            if FirstKeyDownTime(startkey1) ||FirstKeyDownTime(startkey2)
                KbQueueCreate(RespDevID);
                KbQueueStart(RespDevID);
                vbl = Screen('Flip', wPtr);
                runStartTime = vbl; % ANCHORS START TIME OF RUN
                break
            else
                continue
            end
        end
    catch err
        sca; ShowCursor;   diary off;  fclose('all');
        disp('Error in start screen')
        rethrow(err)
    end
end
try
    for n = 1:nblocks+1
        starttime_block = runStartTime + (n-1)*(blockDur + fixDur + cueDur);
        
        if n~=nblocks + 1,
            CheckeredBoardStartAngle  = para(1,n);
            CueAngle       = para(2,n);
            endtime_block  = starttime_block + blockDur + fixDur + cueDur;
            WedgeMaskAngle = CheckeredBoardStartAngle + 180;
            
            fprintf('\nBlock %i\n',n)
            fprintf('Board Start Angle: %i deg (clockwise from 12 o''clock)\n',CheckeredBoardStartAngle)
            fprintf('        Cue Angle: %i deg\n',CueAngle)            
        else
            endtime_block = starttime_block + fixDur;
        end
        
        while GetSecs <= endtime_block
            if GetSecs - starttime_block  > fixDur && GetSecs - starttime_block  <= fixDur + cueDur
                % --- Cue
                Screen('FillArc',wPtr,wedgeCueClr,wedgeLoc,CueAngle,wedgeAngleSz)
                Screen('FrameArc',wPtr,cueFrameClr,wedgeLoc,CueAngle,wedgeAngleSz,cueFrameSz)
                DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr,bgc)
                vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
                
            elseif GetSecs - starttime_block > fixDur + cueDur
                % --- Board
                Screen('DrawTexture',wPtr,checkboard_tPtr);
                Screen('FillArc',wPtr,wedgeMaskClr,[],WedgeMaskAngle,wedgeAngleSz)
                Screen('FrameArc',wPtr,cueFrameClr,cueFrameLoc,CueAngle,wedgeAngleSz,cueFrameSz)
                DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr,bgc)
                vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
                % --- Complementary board
                Screen('DrawTexture',wPtr,checkboard_comp_tPtr);
                Screen('FillArc',wPtr,wedgeMaskClr,[],WedgeMaskAngle,wedgeAngleSz)
                Screen('FrameArc',wPtr,cueFrameClr,cueFrameLoc,CueAngle,wedgeAngleSz,cueFrameSz)
                DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr,bgc)
                vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
            else
                % --- Fixation
                DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr,bgc)
                vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
            end
            QuitKeyWait; if QuitSignal ==1 , return, end
        end
    end
catch err
    sca;    ShowCursor;    commandwindow;
    disp('Error in main expt loop')
    rethrow(err)
end

Priority(0);
sca;    ShowCursor;    commandwindow;

outputfname = sprintf('%s/%s.mat',OutputDir,fNameStr);
disp('Saving output...');
save(outputfname,'savelog');
disp('saved...')

if log, diary off; end
toc