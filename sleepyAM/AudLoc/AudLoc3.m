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
[QuitSignal,subNo, runNo, behav, SAVELOG] =  GetInputs(debug,runtime);
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


% Timing specs ======================================
if debug
    duration_block    = 10;
    duration_fixation = 2;
else
    if behav == 0
        duration_block    = 20;
        duration_fixation = 20;
    else
        duration_block    = 10;
        duration_fixation = 2;
    end
    
end
duration_total    = duration_block + duration_fixation;

SAVELOG.Timing.StimBlkDur = duration_block;
SAVELOG.Timing.FixDur     = duration_fixation;

% Paradigm  ======================================
% paradigm = [randperm(3) randperm(3)];
para_orders = perms(1:3);
if mod(runNo,3)==1
    paradigm = [para_orders(1,:),para_orders(2,:)];
elseif mod(runNo,3)==2
    paradigm = [para_orders(3,:),para_orders(4,:)];
elseif mod(runNo,3)==0
    paradigm = [para_orders(5,:),para_orders(6,:)];
end

nblocks  = length(paradigm);
makeparafile(duration_fixation, duration_block, subNo, runNo, paradigm)

SAVELOG.Paradigm = paradigm;


% Stim specs  ======================================
sf = 48000; %sampling frequency
duration_cycle = 5; %
reps = duration_block/duration_cycle;
snd = cell(1,3);
snd(1) = {MakeChirp(sf,duration_cycle,2370,5900,[],2,reps)}; % HIGH
snd(2) = {MakeChirp(sf,duration_cycle, 880,2170,[],2,reps)}; % MED
snd(3) = {MakeChirp(sf,duration_cycle, 340, 870,[],2,reps)}; % LOW
StartAudio;

% Secondary task
peakTime     = duration_cycle/2;
acceptRange  = 0.5; % time after peak freq
acceptRangeA = abs(peakTime+(acceptRange*2)); % time after peak freq
acceptRangeB = abs(peakTime-acceptRange); % time before peak freq


ResultSet = zeros(nblocks*reps,6);
ResultSet(:,1) = sort(repmat([1:nblocks]',reps,1));
ResultSet(:,2) = repmat([1:reps]', nblocks,1);
ResultSet(:,3) = 1:nblocks*reps;
% [format] = 1) BlockNo. 2) Cycle No. in block 3) CycleNo. overall 4) keypresstime_rightAns 5) keypresstime_wrongAns 6)num wrong ans in cycle
wrongcount2 = zeros(1,nblocks*reps);
cycleNum  = 0;
cycleNum2 = 0;

% Input devices specs ======================================
KbName('UnifyKeyNames')
quitkey   = 'Q';
startkey1 = 'space';
startkey2 = 'enter';
RKey      = 'RightArrow';
% NNL Grips {from CNL}
% Hand      Finger       Code
% Left      Thumb        a
% Left      Index        b
% Right     Thumb        d
% Right     Index        c
LThumb = 'a';
LIndex = 'b';
RThumb = 'd';
RIndex = 'c';
% Current designs box --------------------
Left1 = '1!'; % little finger
Left2 = '2@'; % left ring;
Left3 = '3#'; % left middle
Left4 = '4$'; % left index
Right1 = '6^'; % Right Little
Right2 = '7&'; % ring
Right3 = '8*'; % middle
Right4 = '9('; % index

RKey2 = Right2;

% % [INPUT 1] = trigger  : 1 = apple keyboard | 2 = scanner pulse | 3 = A4Tech keyboard
% % [INPUT 2] = response : 1 = apple keyboard | 2 = old response boxes | 3 = NNL Grips | 4 = Current designs button boxes.
ResponseDevice = 4;
if behav == 1
    [DevIDs,devices, QuitSignal] = getDevID2(1,ResponseDevice);
else
    [DevIDs,devices, QuitSignal] = getDevID2(2,ResponseDevice);
end
TrigDevID = DevIDs{1};
RespDevID = DevIDs{2};
if QuitSignal ==1 ,
    sca;    ShowCursor;    return,
end
% TrigDevID = [4]; % 8-keyboard; 2-NNL Grips; 4-scanner pulse
% RespDevID = [2];

QuitSignal = 0;
ListenChar;
KbQueueCreate(TrigDevID);
KbQueueStart(TrigDevID);

% Open screen & visual stim specs ======================================
AssertOpenGL;
OpenScreen;
fixlen = 25;

% Waiting for start trigger ======================================
DrawFixation(wPtr, centerX, centerY, fixlen,2,[255 255 255])
Screen('Flip', wPtr);
while 1,
    QuitKeyWait; if QuitSignal ==1 , return, end
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

try
    for x=1:nblocks+1
        if x~=nblocks+1,   condition = paradigm(x);     end
        sndstim = snd{condition};
        
        starttime_block = runStartTime + ((x-1)*duration_total);
        if x ~=nblocks+1,   endtime_block = starttime_block + duration_total;
        else                endtime_block = starttime_block + duration_fixation;        end
        
        AudSwitch = 1;
        rightCount = zeros(1,reps);
        wrongCount = 0;
        keypresstime = 0;
        tic
        while GetSecs <= endtime_block
            if GetSecs - starttime_block > duration_fixation % stim on
                DrawFixation(wPtr, centerX, centerY, fixlen,4,[255 0 0])
                if AudSwitch ==1
                    PsychPortAudio('FillBuffer', pasound1, sndstim);
                    audstartTime=PsychPortAudio('Start', pasound1,1,0,1);
                    AudSwitch = 0;
                end
                [keyIsDown, FirstKeyDownTime] = KbQueueCheck(RespDevID);
                if keyIsDown
                    if FirstKeyDownTime(KbName(RKey))  || FirstKeyDownTime(KbName(RThumb)) || FirstKeyDownTime(KbName(RKey2)) ,
                        if  FirstKeyDownTime(KBName(RKey2))
                            keypresstime = FirstKeyDownTime(KbName(RKey2))-starttime_block-duration_fixation;
                        elseif FirstKeyDownTime(KbName(RThumb)),
                            keypresstime = FirstKeyDownTime(KbName(RThumb))-starttime_block-duration_fixation;
                        end
                        %  if keypresstime<0
                        %       keypresstime = 0;
                        %  end
                        cycletime = mod(keypresstime,duration_cycle);
                        cycleNum  = floor(keypresstime/duration_cycle)+1;
                        cycleNum2 = ((x-1)*reps)+cycleNum;
                        if cycleNum>0
                            if cycletime >=acceptRangeB && cycletime <= acceptRangeA
                                disp('correct')
                                rightCount(cycleNum) = 1;
                                ResultSet(cycleNum2,4) = keypresstime;
                            else
                                disp('wrong')
                                wrongCount = wrongCount +1;
                                wrongcount2(cycleNum2) = wrongcount2(cycleNum2)+1;
                                ResultSet(cycleNum2,6) = wrongcount2(cycleNum2);
                                ResultSet(cycleNum2,5) = keypresstime;
                            end
                        else
                            disp('early')
                        end
                    end
                end
                
            else % fixation
                DrawFixation(wPtr, centerX, centerY, fixlen,4,[255 255 255])
                [startTime endPositionSecs xruns estStopTime]=PsychPortAudio('Stop', pasound1, 1);
            end
            
            Screen('Flip',wPtr);
            QuitKeyWait;
            if QuitSignal ==1 ,
                if cycleNum2>1, OutputBehData(ResultSet(1:cycleNum2-1,:), outputfName); end
                return,
            end
        end
        if x ~=nblocks+1
            wrongCount
            rightCount
            percentRight_CurrentBlock = 100*length(find(rightCount(:)==1))/length(rightCount)
            SAVELOG.Response.PercentRight(x) = percentRight_CurrentBlock;
        end
        toc
    end
catch err
    sca
    ShowCursor;
    fprintf('\n\n Error in main experiment body\n\n')
    rethrow(err)
end
runEndTime   = Screen(wPtr,'Flip');
totalRunTime = runEndTime-runStartTime

SAVELOG.Response.ResultSet = ResultSet;

try
    
    disp('saving...')
    save([fNameStr '_SAVELOG.mat'],'SAVELOG')
    
    disp('zipping...')
    zip([zipDir '/' outputtimestr '_AUDL.zip'],{'*.m',[fNameStr '_SAVELOG.mat']})
    
    disp('moving...')
    copyfile([fNameStr '_SAVELOG.mat'], outputDir);
    movefile([fNameStr '_SAVELOG.mat'], backupDir);
    
    disp('all done')
    
catch err
    fprintf('--------------------Error saving \n')
    ShowCursor;
    sca;
    commandwindow
    rethrow(err);
end

ShowCursor;
sca;

% Summary stats =================================
fprintf('\n\nSummary stats =================================\n\n');
WrongAnsSet = ResultSet(:,reps+2);
RightAnsSet = ResultSet(:,reps+1);
MeanNumWrongAnsEachBlock = mean(WrongAnsSet)
MeanPercentRightAns      = mean(RightAnsSet)
fprintf('===============================================\n\n')