clear all; close all; home; commandwindow; tic

debugmode = 1 ;             log       = 0;
runtime   = fix(clock);     runDate   = runtime(1,[3,2,1,4,5,6]);

[QuitSignal,subNo, runNo, practice] =  SCP_RDS_GetInputs(debugmode);

if log,    logfname = sprintf('log/%s_%02i%02i%i_%02i.%02i.%02i.log',mfilename(),runDate); diary(logfname); end

if QuitSignal ==1 , return, end


if practice,
    practStr = 'practiceData'; practStr2 = 'practice/behav';
else
    practStr = 'rawData';      practStr2 = 'fMRI';
end
outputdir  = sprintf('%s_data/%s',mfilename(),practStr);
if ~isdir(outputdir),  mkdir(outputdir);     end
outputfname = sprintf('%s/%s_sub%i_run%i.mat', outputdir,mfilename(),subNo,runNo);
if exist(outputfname,'file')
    fprintf('\n\nData already exists [Subno: %i | Runno: %i]\nDelete/rename existing data before continuing.\n',subNo,runNo)
    fprintf('The offending file: %s/%s_sub%i_run%i.mat\n\n', outputdir,mfilename(),subNo,runNo);
    commandwindow;    return;
end

savelog                = struct;
savelog.subNo          = subNo;
savelog.runNo          = runNo;
savelog.exptmode       = practStr2;
savelog.runtime        = datestr(now,'dd-mmm-yyyy HH:MM');
savelog.debugmode      = debugmode;

% EXPERIMENT PARAMS
SCP_RDS_EXPTPARAMS;
if ~debugmode    
        [savelog.fsfastparafile] = makeparafile(subNo, runNo, blockDur, ansDur, fixDur, condcode, practice);    
end
% SCREEN PARAMS
[wPtr, rect, ifi] = OpenScreen([0 0 0], debugmode);
resX = rect(3);
resY = rect(4);

if debugmode
    XAdj = 130;
    YAdj = 0;
else
    XAdj = 210;
    YAdj = -150;
end


XCtr_L = resX/2 - XAdj;
XCtr_R = resX/2 + XAdj;
YCtr   = resY/2 + YAdj;

stimSz    = savelog.stimParams.templateSz/2;
stimLoc_L = [XCtr_L - stimSz(2) + 1, YCtr - stimSz(1) + 1, XCtr_L + stimSz(2), YCtr + stimSz(1)];
stimLoc_R = [XCtr_R - stimSz(2) + 1, YCtr - stimSz(1) + 1, XCtr_R + stimSz(2), YCtr + stimSz(1)];

boxsize   = stimSz(1) + 10;
boxcolour = [255 255 255];

dotClr = [255 255 255];
dotSz  = 5;

% BUILD TEXTURE LIBRARY
[RDS_LIB,savelog] = SCP_RDS_BUILDRDSLIB(wPtr,savelog,templateImgs);

% KEYBOARD
% NNL Grips {from CNL} --------------------
LThumb = 'a';       LIndex = 'b';
RThumb = 'd';       RIndex = 'c';

% Current designs box --------------------
Left1 = '1!'; % little finger
Left2 = '2@'; % left ring;
Left3 = '3#'; % left middle
Left4 = '4$'; % left index
Right1 = '6^'; % Right Little
Right2 = '7&'; % ring
Right3 = '8*'; % middle
Right4 = '9('; % index

KbName('UnifyKeyNames')
quitkey   = 'Q';
RHandResp = 'RightArrow';
LHandResp = 'LeftArrow';
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
        SCP_RDS_WRITE(wPtr, 'Waiting for trigger', XCtr_L-70, XCtr_R-70, YCtr-25, 15)
        SCP_RDS_WRITE(wPtr, 'Count no. of squares', XCtr_L-75, XCtr_R-75, YCtr+35, 15)
        DrawFixationBoxes(wPtr,XCtr_L,XCtr_R,YCtr,10,[255 0 0],boxsize,boxcolour)
        
        vbl = Screen('Flip', wPtr, vbl + (0.5*ifi));
        QuitKeyWait; if QuitSignal ==1 , return, end
        [keyIsDown, FirstKeyDownTime] = KbQueueCheck(TrigDevID);
        if keyIsDown
            if FirstKeyDownTime(startkey1) ||FirstKeyDownTime(startkey2)
                KbQueueCreate(RespDevID);
                KbQueueStart(RespDevID);
                vbl = Screen('Flip', wPtr, vbl + (0.5*ifi));
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
    for n = 1 : nblocks + 1
        starttime_block = runStartTime + (n-1)*(blockDur + fixDur + ansDur);
        
        if n~=nblocks + 1,
            % --------------STIMULUS BLOCKS
            bgCond      = para{1,n};
            targCond    = para{2,n};
            rightAnsLoc = para{3,n};
            rightAns    = rightAnsSet(n);
            wrongAns    = wrongAnsSet(n);
            fixclrID    = fixchangeID{n};
            ansSwitch   = 1;
            subjResp    = [];
            respCount   = 0;
            
            fprintf('\n\n--- BLOCK %i\n Correct Ans Loc: %s\n',n,rightAnsLoc)            
                        
            endtime_block = starttime_block + blockDur + fixDur + ansDur;
        else
            % --------------FINAL FIXATION BLOCK
            endtime_block = starttime_block + fixDur;
        end
        
        while GetSecs <= endtime_block
            
            
            if GetSecs - starttime_block  > fixDur && GetSecs - starttime_block  <= fixDur + blockDur
                % --------------STIMULUS DISPLAY DURATION
                timeElapsed = GetSecs - starttime_block - fixDur;
                trialNo     = ceil(timeElapsed/trialDur);
                
                if mod(timeElapsed,trialDur) <= stimDur
                    DrawFixationBoxes(wPtr,XCtr_L,XCtr_R,YCtr,10,[255 255 255],boxsize,boxcolour)
                    % --------------GABOR
                     eval(sprintf('TexPtr_L = RDS_LIB.block%i.LEFT;',n))
                     eval(sprintf('TexPtr_R = RDS_LIB.block%i.RIGHT;',n))
                                        
                    Screen('DrawTextures',wPtr, TexPtr_L,[], stimLoc_L);
                    Screen('DrawTextures',wPtr, TexPtr_R,[], stimLoc_R);   
                    
                else
                    DrawFixationBoxes(wPtr,XCtr_L,XCtr_R,YCtr,1,[0 0 0],boxsize,boxcolour)
                    % --------------FIXATION / 2NDARY TASK
                    if find(trialNo == fixclrID)                    
                        Screen('DrawDots',wPtr,[XCtr_L YCtr],dotSz,dotClr,[],0); % square dot
                        Screen('DrawDots',wPtr,[XCtr_R+savelog.stimParams.RDS_pixelshift YCtr],dotSz,dotClr,[],0); % square dot
                    else                    
                        Screen('DrawDots',wPtr,[XCtr_L YCtr],dotSz,dotClr,[],2); % round dot
                        Screen('DrawDots',wPtr,[XCtr_R+savelog.stimParams.RDS_pixelshift YCtr],dotSz,dotClr,[],2); % round dot
                    end
                end                
                
            elseif  GetSecs - starttime_block  > fixDur + blockDur
                DrawFixationBoxes(wPtr,XCtr_L,XCtr_R,YCtr,10,[255 255 255],boxsize,boxcolour)
                % --------------ANS DURATION
                switch rightAnsLoc
                    case 'R'
                        if ansSwitch
                           SCP_RDS_WRITE(wPtr, sprintf('%i',wrongAns), XCtr_L-50, XCtr_R-50, YCtr-5, 20)
                           SCP_RDS_WRITE(wPtr, sprintf('%i',rightAns), XCtr_L+30, XCtr_R+30, YCtr-5, 20)                            
                        else
                            if strcmpi(subjResp,'L')
                                SCP_RDS_WRITE(wPtr, sprintf('%i',wrongAns), XCtr_L-50, XCtr_R-50, YCtr-5, 20)
                            elseif strcmpi(subjResp,'R')
                                SCP_RDS_WRITE(wPtr, sprintf('%i',rightAns), XCtr_L+30, XCtr_R+30, YCtr-5, 20)
                            end
                        end
                    case 'L'
                        if ansSwitch
                            SCP_RDS_WRITE(wPtr, sprintf('%i',rightAns), XCtr_L-50, XCtr_R-50, YCtr-5, 20)
                            SCP_RDS_WRITE(wPtr, sprintf('%i',wrongAns), XCtr_L+30, XCtr_R+30, YCtr-5, 20)                           
                        else
                            if strcmpi(subjResp,'L')
                                SCP_RDS_WRITE(wPtr, sprintf('%i',rightAns), XCtr_L-50, XCtr_R-50, YCtr-5, 20)
                            elseif strcmpi(subjResp,'R')
                                SCP_RDS_WRITE(wPtr, sprintf('%i',wrongAns), XCtr_L+30, XCtr_R+30, YCtr-5, 20)                     
                            end
                        end
                end
            else
                DrawFixationBoxes(wPtr,XCtr_L,XCtr_R,YCtr,10,[255 255 255],boxsize,boxcolour)
            end
            
            % --------------KEYBOARD RESPONSE
            [keyIsDown, FirstKeyDownTime] = KbQueueCheck(RespDevID);
            if keyIsDown
                respTime = GetSecs - starttime_block - fixDur - blockDur;
                if FirstKeyDownTime(KbName(RHandResp))                    
                    if respTime > 0 && strcmpi(subjResp,'R') == 0
                        respCount = respCount +1;
                    end
                    subjResp  = 'R';
                    disp(' Right')
                elseif FirstKeyDownTime(KbName(LHandResp))                    
                    if respTime > 0 && strcmpi(subjResp,'L') == 0;
                        respCount = respCount +1;
                    end
                    subjResp  = 'L';
                    disp(' Left')
                end
                if respTime > 0
                    savelog.subjectResp{n}  = subjResp;
                    savelog.responseTime(n) = respTime;
                    ansSwitch = 0;
                else
                    savelog.QC.earlyBtnpress.flag(n)   = 1;
                    savelog.QC.earlyBtnpress.RT(n)     = respTime;
                    savelog.QC.earlyBtnpress.btnID{n}  = subjResp;
                    disp('Early btn press')
                end
                if respCount > 1
                    savelog.QC.respflip.numflips(n) = respCount;
                end
            end
                        
            vbl = Screen('Flip', wPtr, vbl + (0.5*ifi));
            QuitKeyWait; if QuitSignal ==1 ,  return, end
            
        end
    end
catch err
    sca;    ShowCursor;    commandwindow;
    disp('Error in main expt loop =(')
    rethrow(err)
end


sca
disp('Saving output...'); save(outputfname,'savelog'); disp('saved...')
[percentRight, ntrials] = SCP_GetRunStats(savelog);
toc;
if log, diary off; end
commandwindow