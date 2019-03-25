% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERSION HISTORY
%   JUL 7 - STARTED WRITING [SKELETON DONE]
%   [done 7 JUL 2017] MAIN PARADIGM
%   [done 10 JUL 17] ADD EYE TRACKER SYNC
%   [done 10 JUL 17] GENERATE FREESURFER PARA FILE
%   [done 10 JUL 17] GENERATE OUTPUT FILE
%   [done 10 JUL 17] GENERATE BACKUP
%   [done 10 JUL 17] GENERATE *ZIP
%   [done 10 JUL 17] GET INPUTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO --------
%   FINALIZE SPATIAL FREQ AND AM RATE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; commandwindow; home; tic

runtime       = now;
debug         = 0;
log           = 1;
outputtimestr = datestr(runtime,'yyyymmdd_HHMMSS');
if log
    logDir   = 'logs/';
    if ~isdir(logDir), mkdir(logDir); end
    logfName = [logDir mfilename() '_' outputtimestr '.log'];
    diary(logfName);
end

% GET INPUTS
[QuitSignal,subNo, runNo, Order, eyetrack,SAVELOG] =  GetInputs(debug,runtime);
if QuitSignal == 1 , disp('Experiment terminated early'); return , end
if runNo == 1, rng(subNo); end

fprintf('\n\n=============================\n%s\n=============================\n',mfilename())
fprintf('Subject No: %i\n',subNo)
fprintf('Run No    : %i\n',runNo)
fprintf('eyetrack? : %i\n',eyetrack)
fprintf('Debug?    : %i\n',debug)
fprintf('Run date  : %s\n',datestr(runtime))
fprintf('=============================\n\n')

% OUTPUT DIRECTORIES
outputDir = sprintf('../Data/%03i',subNo);
if ~isdir(outputDir),    mkdir(outputDir);end

backupDir = sprintf('../Data/Backup/%03i',subNo);
if ~isdir(backupDir),    mkdir(backupDir);end

zipDir   = sprintf('../ZipArchives');
if ~isdir(zipDir),      mkdir(zipDir);end

fNameStr = sprintf('%s_S%03i_R%03i_%s',mfilename(),subNo,runNo,outputtimestr);

SAVELOG.Output.fNames = fNameStr;
SAVELOG.Output.Dir    = outputDir;

% PARADIGM FILE
[EXPTPARA, SAVELOG] = ExptParadigm(SAVELOG,debug);
num_blocks          = size(EXPTPARA,1);
[SAVELOG]           = MakeFSParaFile(SAVELOG);

% AUDIO
[SoundLib] = createSoundStim(SAVELOG);
StartAudio;

% SCREEN
[wPtr, rect] = OpenScreen(debug);
resX    = rect(3);
resY    = rect(4);
centerX = resX/2;
centerY = resY/2;
fixationlength = 15;

% START EYETRACKER
if eyetrack
    try
    disp('Connecting eyetracker...')
    eyetracker_connect
    eyetracker_record;
    disp('Eye tracker recording...')
    catch err
        CleanUp        
        rethrow(err)
    end
end

% KEYBOARDS
KbName('UnifyKeyNames')
quitkey   = 'Q';
startKey1 = 'space';
startKey2 = 'enter';

% GET DEV ID
% % [INPUT 1] = trigger  : 1 = apple keyboard | 2 = scanner pulse | 3 = A4Tech keyboard
% % [INPUT 2] = response : 1 = apple keyboard | 2 = old response boxes | 3 = NNL Grips | 4 = Current designs button boxes.
[DevIDs,devices, QuitSignal] = getDevID2(2,3);
TrigDevID = DevIDs{1};
if QuitSignal ==1 ,
    sca; ShowCursor;
    if eyetrack,
        QuitEyeTracking
    end
    return,
end

ListenChar;
KbQueueCreate(TrigDevID);
KbQueueStart(TrigDevID);

% Trigger screen
fprintf('\n\nWaiting for trigger ... ')
try
    while 1,
        DrawFixation(wPtr, centerX, centerY, fixationlength+15,5,[200 200 200])
        Screen('Flip', wPtr);
        
        QuitKeyWait;
        if QuitSignal ==1 ,
            sca; ShowCursor;
            if eyetrack,
                QuitEyeTracking
            end
            return,
        end
        
        [keyIsDown, FirstKeyDownTime] = KbQueueCheck(TrigDevID);
        if keyIsDown
            if FirstKeyDownTime(KbName(startKey1)) || FirstKeyDownTime(KbName(startKey2))
                fprintf('Trigger received ... Starting Experiment \n\n')
                if eyetrack
                    eyetracker_insertMarker('TRIG')
                end
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

% Main experiment blocks
try
    for x=1:num_blocks+1,
        
        starttime_block = runStartTime+((x-1)*SAVELOG.Paradigm.BlockDur);
        
        if x ~= num_blocks+1;
            % set up block params
            AudSwitch     = 1;
            endtime_block = starttime_block + SAVELOG.Paradigm.BlockDur ;
            
            AMFreq      = EXPTPARA(x,2);
            CarrierFreq = EXPTPARA(x,3);
            
            eval(sprintf('AMmodulation = SoundLib.AM_%i;',AMFreq))
            eval(sprintf('Carrier = SoundLib.Pitch_%i;',CarrierFreq))
            
            PsychPortAudio('FillBuffer',pamodulator, AMmodulation);
            PsychPortAudio('FillBuffer', pasound1, Carrier);
            
            fprintf('\nBlock %i -- [AM Freq: %02i | Carrier Freq: %0i]\n',x,AMFreq,CarrierFreq)
            
        else
            fprintf('\nFinal fixation\n')
            AudSwitch     = 0;
            endtime_block = starttime_block + SAVELOG.Paradigm.FixationDur;
        end
        
        starttime_stim  = starttime_block+SAVELOG.Paradigm.FixationDur;
        FixSwitch = 1;
        
        while GetSecs<endtime_block && GetSecs>=starttime_block
            if GetSecs>=starttime_stim
                % turn on sound -----------------
                if AudSwitch
                    disp('Sound On')
                    if eyetrack,
                        eyetracker_insertMarker('STM+'),
                        eyetracker_insertMarker(sprintf('%03i',x)),
                    end
                    PsychPortAudio('Start', pasound1,    1,0,1); % START WHITE NOISE
                    PsychPortAudio('Start', pamodulator, 0,0,1); % START AM MODULATION
                    DrawFixation(wPtr, centerX, centerY, fixationlength,2,[255 0 0])
                    Screen('Flip', wPtr);
                    AudSwitch = 0 ;
                end                
            else                 
                % turn on fixation -----------------
                if FixSwitch                    
                    disp('Fixation On')
                    if eyetrack,
                        eyetracker_insertMarker('FIX+'),
                    end
                    DrawFixation(wPtr, centerX, centerY, fixationlength,2,[255 255 255])
                    Screen('Flip', wPtr);                    
                    FixSwitch = 0;
                end        
                
            end
            QuitKeyWait;
            if QuitSignal ==1 ,
                sca; ShowCursor;
                if eyetrack,
                    QuitEyeTrackingt
                end
                return,
            end
        end
        
        PsychPortAudio('Stop', pasound1, 1); % Stop white noise
        PsychPortAudio('Stop', pamodulator, 1); % Stop AM Modulation
        
        if x ~= num_blocks+1;
            SAVELOG.BlocksComplete = x;
        end
        QuitKeyWait;
        if QuitSignal ==1 ,
            sca; ShowCursor;
            if eyetrack,
                QuitEyeTracking
            end
            return,
        end
    end
    if eyetrack
        eyetracker_insertMarker('END')
        QuitEyeTracking
    end
    
    sca;
    
catch err
    fprintf('--------------------Error in main expt loop \n')
    PsychPortAudio('Stop', pasound1, 0); % Stop white noise
    PsychPortAudio('Stop', pamodulator, 0); % Stop AM Modulation
    if eyetrack
        QuitEyeTracking
    end
    save([backupDir '/' fNameStr '_SAVELOG_err.mat'],'SAVELOG')
    CleanUp;
    rethrow(err);
end

try
    
    disp('saving...')
    save([fNameStr '_SAVELOG.mat'],'SAVELOG')
    
    disp('zipping...')
    zip([zipDir '/' outputtimestr '_SLPY.zip'],{'*.m',[fNameStr '_SAVELOG.mat']})
    
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

disp('Completed with no errors ^5')
CleanUp
