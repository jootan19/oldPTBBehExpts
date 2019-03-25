clear all; close all; home; commandwindow; tic

debugmode = 0 ;             log       = 1;
runtime   = fix(clock);     runDate   = runtime(1,[3,2,1,4,5,6]);

if log,    logfname = sprintf('log/%s_%02i%02i%i_%02i.%02i.%02i.log',mfilename(),runDate); diary(logfname); end

[QuitSignal,subNo, runNo, SALIENTFEATURE, practice] =  GetInputs(debugmode);
if QuitSignal ==1 , return, end

% OUTPUT DIRECTORIES AND FILENAMES
if practice,
    practStr = 'practiceData'; practStr2 = 'practice/behav';
else
    practStr = 'rawData';      practStr2 = 'fMRI';
end

outputdir  = sprintf('%s_data/%s',mfilename(),practStr);
if ~isdir(outputdir),  mkdir(outputdir);     end
outputfname = sprintf('%s/%s_sub%i_run%i_%s.mat', outputdir,mfilename(),subNo,runNo,SALIENTFEATURE);
if exist(outputfname,'file')
    fprintf('\n\nData already exists [Subno: %i | Runno: %i | Feature: %s]\nDelete/rename existing data before continuing.\n',subNo,runNo,SALIENTFEATURE)
    fprintf('The offending file: %s/%s_sub%i_run%i_%s.mat\n\n', outputdir,mfilename(),subNo,runNo,SALIENTFEATURE);
    commandwindow;    return;
end

savelog                = struct;
savelog.subNo          = subNo;
savelog.runNo          = runNo;
savelog.exptmode       = practStr2;
savelog.runtime        = datestr(now,'dd-mmm-yyyy HH:MM');
savelog.debugmode      = debugmode;
savelog.salientfeature = SALIENTFEATURE;

% ENABLE PTB SCREEN FUNCTIONS
[wPtr, rect] = OpenScreen([0 0 0], debugmode);
resX = rect(3);     resY = rect(4);
XCtr = resX/2;      YCtr = resY/2;
fixlen       = 10;
ansfontSz    = 50;
LAnsXCtr     = XCtr-130;
RAnsXCtr     = XCtr+100;
AnsYCtr      = YCtr-15;
dotClr       = [255 255 255];

savelog.screenParams.resX = resX;
savelog.screenParams.resY = resY;

% EXPT PARADIGM
ExptParams;
if ~debugmode
    if ~practice
        [savelog.fsfastparafile] = makeparafile(subNo, runNo, blockDur, ansDur, fixDur, condcode, SALIENTFEATURE,practice);
    end
end

% BUILD GABOR TEX LIB
BuildGaborLib;

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

% --------------MAIN EXPERIMENT BLOCK
while 1,
    try
        Write(wPtr, 'Waiting for trigger', XCtr-140, YCtr-100, 30)
        Write(wPtr, 'Count no. of white squares', XCtr-190, YCtr+100, 30)
        DrawFixation(wPtr, XCtr, YCtr, fixlen,2,[255 0 0])
        Screen('Flip', wPtr);
        QuitKeyWait; if QuitSignal ==1 , return, end
        [keyIsDown, FirstKeyDownTime] = KbQueueCheck(TrigDevID);
        if keyIsDown
            if FirstKeyDownTime(startkey1) ||FirstKeyDownTime(startkey2)
                KbQueueCreate(RespDevID);
                KbQueueStart(RespDevID);
                runStartTime = Screen('Flip', wPtr); % ANCHORS START TIME OF RUN
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
% --------------MAIN EXPERIMENT BLOCK
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
            
            switch SALIENTFEATURE
                case 'ORI'
                    eval(sprintf('bgtex   = texlib.bg%d_theta0;',bgCond));
                    eval(sprintf('targtex = texlib.bg%d_theta%d;',bgCond,targCond))
                case 'CLR'
                    eval(sprintf('bgtex   = texlib.R%i_G%i_B%i;',round(255*bgCond)));
                    eval(sprintf('targtex = texlib.R%i_G%i_B%i;',round(255*targCond)));
            end
            
            texPtrs           = zeros(1,nele);
            texPtrs(:)        = bgtex;
            texPtrs(ctreleID) = targtex;
            
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
                    % --------------GABOR
                    switch jittertype
                        case 'pertrial'
                            eval(sprintf('gaborlocs = gaborlocs_jitter.block%i(:,:,%i);',n,trialNo))
                        case 'perblock'
                            eval(sprintf('gaborlocs = gaborlocs_jitter.block%i;',n))
                    end
                    Screen('DrawTextures',wPtr, texPtrs,[], gaborlocs);
                    % imageArray = Screen('GetImage', wPtr);
                    % eval(sprintf('ORIPOP_imgarray.block%i.trial%i=imageArray;',n,trialNo))
                else
                    % --------------FIXATION / 2NDARY TASK
                    if find(trialNo == fixclrID)
                        Screen('DrawDots',wPtr,[XCtr YCtr],30,dotClr,[],0); % square dot
                    else
                        Screen('DrawDots',wPtr,[XCtr YCtr],30,dotClr,[],2); % round dot
                    end
                end
                
                
            elseif  GetSecs - starttime_block  > fixDur + blockDur
                % --------------ANS DURATION
                switch rightAnsLoc
                    case 'R'
                        if ansSwitch
                            Write(wPtr, sprintf('%i',wrongAns), LAnsXCtr, AnsYCtr, ansfontSz);
                            Write(wPtr, sprintf('%i',rightAns), RAnsXCtr, AnsYCtr, ansfontSz);
                        else
                            if strcmpi(subjResp,'L')
                                Write(wPtr, sprintf('%i',wrongAns), LAnsXCtr, AnsYCtr, ansfontSz);
                            elseif strcmpi(subjResp,'R')
                                Write(wPtr, sprintf('%i',rightAns), RAnsXCtr, AnsYCtr, ansfontSz);
                            end
                        end
                    case 'L'
                        if ansSwitch
                            Write(wPtr, sprintf('%i',rightAns), LAnsXCtr, AnsYCtr, ansfontSz);
                            Write(wPtr, sprintf('%i',wrongAns), RAnsXCtr, AnsYCtr, ansfontSz);
                        else
                            if strcmpi(subjResp,'L')
                                Write(wPtr, sprintf('%i',rightAns), LAnsXCtr, AnsYCtr, ansfontSz);
                            elseif strcmpi(subjResp,'R')
                                Write(wPtr, sprintf('%i',wrongAns), RAnsXCtr, AnsYCtr, ansfontSz);
                            end
                        end
                end
                DrawFixation(wPtr, XCtr, YCtr, fixlen+10,5,[255 255 255])
            else
                % --------------FIXATION DURATION {AT START OF BLOCK}
                DrawFixation(wPtr, XCtr, YCtr, fixlen+10,5,[255 255 255])
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
            
            Screen('Flip',wPtr);
            
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