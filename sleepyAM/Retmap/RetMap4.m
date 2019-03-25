clear all; close all; commandwindow; home; tic

runtime       = now;
debug         = 1;
log           = 1;
outputtimestr = datestr(runtime,'yyyymmdd_HHMMSS');
if log
    logDir   = 'logs/';
    if ~isdir(logDir), mkdir(logDir); end
    logfName = [logDir mfilename() '_' outputtimestr '.log'];
    diary(logfName);
end

% GET INPUTS
[QuitSignal,subNo, runNo, order, behav, SAVELOG] =  GetInputs(debug,runtime);
if QuitSignal == 1 , disp('Experiment terminated early'); return , end


% OUTPUT DIRECTORIES
outputDir = sprintf('Data/%03i',subNo);
if ~isdir(outputDir),    mkdir(outputDir);end

backupDir = sprintf('Data/Backup/%03i',subNo);
if ~isdir(backupDir),    mkdir(backupDir);end

zipDir   = sprintf('../ZipArchives');
if ~isdir(zipDir),      mkdir(zipDir);end

fNameStr = sprintf('%s_S%03i_R%03i_%s',mfilename(),subNo,runNo,outputtimestr);

SAVELOG.Output.fNames = fNameStr;
SAVELOG.Output.Dir    = outputDir;

ExptParadigm;

% Open screen and enable alpha blending ======================================
AssertOpenGL;
OpenScreen;
glsl = MakeTextureDrawShader(wPtr, 'SeparateAlphaChannel'); % Create a special texture drawing shader for masked texture drawing
VisStimParams;

% Input devices specs ======================================
KbName('UnifyKeyNames')
quitkey   = 'Q';
startkey1 = 'space';
startkey2 = 'enter';
LKey      = 'LeftArrow';
RKey      = 'RightArrow';
LKey2 = '2@';       
RKey2 = '7&';
RThumb = 'd';
LThumb = 'a';

% GET DEV ID
% % [INPUT 1] = trigger  : 1 = apple keyboard | 2 = scanner pulse | 3 = A4Tech keyboard
% % [INPUT 2] = response : 1 = apple keyboard | 2 = old response boxes | 3 = NNL Grips | 4 = Current designs button boxes.
ResponseDevice = 4;
if behav == 1
    [DevIDs,devices, QuitSignal] = getDevID2(2,ResponseDevice);
else
    [DevIDs,devices, QuitSignal] = getDevID2(2,ResponseDevice);
end

TrigDevID = DevIDs{1};
RespDevID = DevIDs{2};
if QuitSignal ==1 ,
    sca;    ShowCursor;    return,
end

ListenChar;
KbQueueCreate(TrigDevID);   KbQueueStart(TrigDevID);
trialCounter = 0;

% Trigger screen
fprintf('\n\nWaiting for trigger ... ')
try
while 1,
    DrawFixation(wPtr, centerX, centerY, fixlen,2,fixClr_start)
    Screen('Flip', wPtr);
    QuitKeyWait; if QuitSignal ==1 , CleanUp, return, end
    [keyIsDown, FirstKeyDownTime] = KbQueueCheck(TrigDevID);
    if keyIsDown
        if FirstKeyDownTime(KbName(startkey1)) ||FirstKeyDownTime(KbName(startkey2))
            KbQueueCreate(RespDevID);
            KbQueueStart(RespDevID);
            runStartTime = Screen('Flip', wPtr); % ANCHORS START TIME OF RUN
            break
        else
            continue
        end
    end
end
catch err
    fprintf('\t\t Error while waiting for trigger \n')
    CleanUp;
    rethrow(err);
end
% Main experiment body ======================================
try
    for x=1:nblocks+1
        
        if x~=nblocks+1,   condition = paradigm(x);     end
        switch condition
            case 1 % VERTICAL MERIDIAN
                mask = mask1;
                gAlpha = 1;
            case 2 % HORIZONTAL MERIDIAN
                mask = mask2;
                gAlpha = 1;
            case 3 % EVERYTHING ELSE
                mask = mask3;
                gAlpha = 0.2;
        end
        startAngle = mask.Start;
        MaskSz     = mask.Angle;
        nMasks     = size(startAngle,2);
        
        starttime_block = runStartTime + ((x-1)*duration_total);
        if x ~=nblocks+1,   endtime_block = starttime_block + duration_total;
        else                endtime_block = starttime_block + duration_fixation;        end
        
        clrChngeSeq  = zeros(1,9999);
        clrChngeSeq1 = zeros(1,numClrChange);
        clrChngeIdx  = 1;
        clrChngeIdx2 = 0;
        
        fixClr_Order  = randi(2);% 1 = RED first
        blankFixIndx  = randperm(numClrChange);
        blankfixTrialsId = blankFixIndx(1:randi(3))
        
        if fixClr_Order == 1,  
            fixClr_task    = [0 255 0 ; 255 0 0];
        else
            fixClr_task    = [255 0 0 ; 0 255 0]; end
        
        ansLog = ones(1,numClrChange);
        ansLog(setdiff(1:numClrChange , blankfixTrialsId)) = 0;
        
        fprintf('\n===== Block %d ===== \n', x)
        tic
        while GetSecs <= endtime_block;
            
            timeElasped = GetSecs - starttime_block ;
            
            if GetSecs - starttime_block  > duration_fixation
                
                if mod(timeElasped,duration_stim*2)<duration_stim,
                    Screen('DrawTexture', wPtr, chkdboardtex1, [], [],[],[], gAlpha);
                else
                    Screen('DrawTexture', wPtr, chkdboardtex2, [], [],[],[], gAlpha);
                end
                
                for maskNum = 1:nMasks,
                    Screen('FillArc',wPtr,[0 0 0],dstRect,startAngle(maskNum),MaskSz);
                end
                
                Screen('DrawDots', wPtr, [centerX centerY], 50, [0 0 0],[],2);
                
                if mod(timeElasped,duration_fixflick*2)<duration_fixflick ,
                    fixClrId = 1; % fixation colour id
                    clrChngeIdx = clrChngeIdx + 1;
                    clrChngeSeq(clrChngeIdx) = fixClrId;
                else
                    fixClrId = 2;
                    clrChngeIdx = clrChngeIdx + 1;
                    clrChngeSeq(clrChngeIdx) = fixClrId;
                end
                % %------------------------ GETTTING START OF NEW TRIAL------------------------% %
                if clrChngeSeq(clrChngeIdx) ~= clrChngeSeq(clrChngeIdx-1)
                    trialCounter = trialCounter + 1; % TRIAL NUMBER FOR WHOLE EXPT
                    clrChngeIdx2 = clrChngeIdx2 +1;
                    clrChngeSeq1(clrChngeIdx2)=fixClrId;
                    trialstarttime = GetSecs;
                    if find(clrChngeIdx2 == blankfixTrialsId(:))
                        fprintf('Trial Number: %d --- White\n', trialCounter);
                        ResultSet(trialCounter, 2) = 0;
                        
                    else                        
                        if fixClr_Order ==1,
                            if fixClrId ==1,
                                fprintf('Trial Number: %d --- Green\n', trialCounter);
                                ResultSet(trialCounter, 2) = 1;
                            elseif fixClrId ==2,
                                fprintf('Trial Number: %d --- Red\n', trialCounter);
                                ResultSet(trialCounter, 2) = 2;
                            end
                        else
                            if fixClrId ==2,
                                fprintf('Trial Number: %d --- Green\n', trialCounter);
                                ResultSet(trialCounter, 2) = 1;
                            elseif fixClrId ==1,
                                fprintf('Trial Number: %d --- Red\n', trialCounter);
                                ResultSet(trialCounter, 2) = 2;
                            end
                        end
                    end
                    ResultSet(trialCounter, 1) = x;
                    
                end
                
                % % --------- DRAWING FIXATION --------- % %
                if find(clrChngeIdx2 == blankfixTrialsId(:))
                    DrawFixation(wPtr, centerX, centerY, fixlen,4,[255 255 255]);
                else
                    DrawFixation(wPtr, centerX, centerY, fixlen,4,fixClr_task(fixClrId,:));
                end
                
                % % --------- LOGGING BUTTON PRESSES --------- % %
                [keyIsDown, FirstKeyDownTime] = KbQueueCheck(RespDevID);
                if keyIsDown
                     % % --------- LEFT KEY = GREEN --------- % %
                    if FirstKeyDownTime(KbName(LKey)) || FirstKeyDownTime(KbName(LThumb)) ||FirstKeyDownTime(KbName(LKey2)) , % SUBJECT ANS = GREEN
                       reactiontime = GetSecs-trialstarttime;         
                        ResultSet(trialCounter, 3) = 1; % RESPONSE BUTTON PRESSED: LEFT BUTTON
                        ResultSet(trialCounter, 5) = reactiontime;
                        if find(clrChngeIdx2 == blankfixTrialsId(:))
                            ansLog(clrChngeIdx2) = 0; % wrong answer
                            ResultSet(trialCounter,4) = 2;
                            fprintf('Wrong\n');
                        else
                            if fixClr_Order == 1
                                if fixClrId == 1;                   
                                    ansLog(clrChngeIdx2) = 1; % right answer
                                    fprintf('Correct\n')                                 
                                elseif fixClrId == 2;
                                    ansLog(clrChngeIdx2) = 0; % wrong answer
                                    ResultSet(trialCounter,4) = 2;
                                    fprintf('Wrong\n');
                                end
                            elseif fixClr_Order == 2
                                if fixClrId == 2;                 
                                    ansLog(clrChngeIdx2) = 1; % right answer
                                    fprintf('Correct\n')
                                elseif fixClrId == 1;
                                    ansLog(clrChngeIdx2) = 0; % wrong answer
                                    ResultSet(trialCounter,4) = 2;
                                    fprintf('Wrong\n');
                                end
                            end
                        end
                    end
                    % % --------- RIGHT KEY = RED --------- % %
                    if FirstKeyDownTime(KbName(RKey)) || FirstKeyDownTime(KbName(RThumb))||FirstKeyDownTime(KbName(RKey2)), % SUBJECT ANS = RED
                        reactiontime = GetSecs-trialstarttime; 
                         ResultSet(trialCounter, 3) = 2; % RESPONSE BUTTON PRESSED: RIGHT BUTTON
                         ResultSet(trialCounter, 5) = reactiontime;
                        if find(clrChngeIdx2 == blankfixTrialsId(:))
                            ansLog(clrChngeIdx2) = 0; % wrong answer
                            fprintf('Wrong\n');
                        else
                            if fixClr_Order ==1
                                if fixClrId == 2;
                                    ansLog(clrChngeIdx2) = 1; % right answer
                                    fprintf('Correct\n')
                                elseif fixClrId == 1;
                                    ansLog(clrChngeIdx2) = 0; % wrong answer
                                    fprintf('Wrong\n');
                                end
                            elseif fixClr_Order == 2
                                if fixClrId == 1;                                    
                                    ansLog(clrChngeIdx2) = 1; % right answer
                                    fprintf('Correct\n')
                                elseif fixClrId == 2;
                                    ansLog(clrChngeIdx2) = 0; % wrong answer
                                    fprintf('Wrong\n');
                                end
                            end
                        end
                    end
                end
            else
                DrawFixation(wPtr, centerX, centerY, fixlen,4,fixClr_fix)
            end
            Screen('Flip',wPtr);
            QuitKeyWait; 
            if QuitSignal ==1 , 
                % OutputBehData(ResultSet(1:trialCounter-1,:), outputfName); 
                return,
            end
        end
        if x ~=nblocks+1
            ansLog
            percentRight = 100*length(find(ansLog(:)==1))/length(ansLog)
            ResponseSet(x,:) = ansLog; 
        end
        
    end
catch err

    sca
    rethrow(err)
end

totalPercentRight = (numel(find(ResponseSet == 1))/numel(ResponseSet)) * 100

SAVELOG.Responses = ResponseSet;
SAVELOG.PercentRight=totalPercentRight;

try
    
    disp('saving...')
    save([fNameStr '_SAVELOG.mat'],'SAVELOG')
    
    disp('zipping...')
    zip([zipDir '/' outputtimestr '_RTMP.zip'],{'*.m',[fNameStr '_SAVELOG.mat']})
    
    disp('moving...')
    copyfile([fNameStr '_SAVELOG.mat'], outputDir);
    movefile([fNameStr '_SAVELOG.mat'], backupDir);
    
    disp('all done')    
    
catch err
    fprintf('--------------------Error saving \n')
    save([backupDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG')
    CleanUp
    rethrow(err);
end


sca