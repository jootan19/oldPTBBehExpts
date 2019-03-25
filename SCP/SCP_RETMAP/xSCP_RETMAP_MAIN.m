clear all; close all; home; commandwindow; tic

debugmode = 0;             log       = 0;
runtime   = fix(clock);     runDate   = runtime(1,[3,2,1,4,5,6]);
practice = 1;

if log,    logfname = sprintf('log/%s_%02i%02i%i_%02i.%02i.%02i.log',mfilename(),runDate); diary(logfname); end
QuitSignal = 0;
% [QuitSignal,subNo, runNo, SALIENTFEATURE, practice] =  GetInputs(debugmode);
if QuitSignal ==1 , return, end

% OUTPUT DIRECTORIES AND FILENAMES
% if practice,
%     practStr = 'practiceData'; practStr2 = 'practice/behav';
% else
%     practStr = 'rawData';      practStr2 = 'fMRI';
% end

% outputdir  = sprintf('%s_data/%s',mfilename(),practStr);
% if ~isdir(outputdir),  mkdir(outputdir);     end
% outputfname = sprintf('%s/%s_sub%i_run%i_%s.mat', outputdir,mfilename(),subNo,runNo,SALIENTFEATURE);
% if exist(outputfname,'file')
%     fprintf('\n\nData already exists [Subno: %i | Runno: %i | Feature: %s]\nDelete/rename existing data before continuing.\n',subNo,runNo,SALIENTFEATURE)
%     fprintf('The offending file: %s/%s_sub%i_run%i_%s.mat\n\n', outputdir,mfilename(),subNo,runNo,SALIENTFEATURE);
%     commandwindow;    return;
% end


PsychDefaultSetup(2);

bgc = 0.5;
[wPtr,rect,ifi] = OpenScreen(bgc,debugmode);
waitframes = 2;

XCtr = rect(3)/2;
YCtr = rect(4)/2;
fixlen  = 15;
fixwth  = 5;
fixclr  = [1 1 1];
fixdotsz = fixlen*2 + 5;

boardRadius = rect(4)/2;
rCycles = 10;
tCycles = 15;

[checkboard, checkboard_comp] = MakeRadialCheckeredBoard(boardRadius,rCycles,tCycles);
checkboard_tPtr      = Screen('MakeTexture',wPtr,checkboard);
checkboard_comp_tPtr = Screen('MakeTexture',wPtr,checkboard_comp);

wedgeCueClr     = [0.8 0.8 0.8];
wedgeLoc        = [XCtr-boardRadius+1 YCtr-boardRadius+1 XCtr+boardRadius YCtr+boardRadius];
wedgeMaskClr    = bgc;
wedgeAngle      = 180;
wedgeStartAngle = [0 90 180 270];
attentionLoc    = [1 2];

para1   = [repmat(wedgeStartAngle,1,length(attentionLoc));...
    sort(repmat(attentionLoc,1,length(wedgeStartAngle)))];
nblocks = size(para1,2);
para2   = [para1 ; 1:nblocks];
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

% keyboard
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
        Write(wPtr, 'Waiting for trigger', XCtr-140, YCtr-100, 30)
        Write(wPtr, 'Pls attend to cued location', XCtr-190, YCtr+100, 30)
        DrawFixation(wPtr, XCtr, YCtr, fixlen-5,fixwth,fixclr)
        vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
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

for n = 1:nblocks+1
    
    starttime_block = runStartTime + (n-1)*(blockDur + fixDur + cueDur);
    if n~=nblocks + 1,
        WedgeMaskAngle = para(1,n);
        CueLoc         = para(2,n);
        endtime_block = starttime_block + blockDur + fixDur + cueDur;
    else
        endtime_block = starttime_block + fixDur;
    end
    while GetSecs <= endtime_block
        if GetSecs - starttime_block  > fixDur && GetSecs - starttime_block  <= fixDur + cueDur
            switch CueLoc
                case 1
                    Screen('FillArc',wPtr,wedgeCueClr,wedgeLoc,WedgeMaskAngle,wedgeAngle)
                case 2
                    Screen('FillArc',wPtr,wedgeCueClr,wedgeLoc,WedgeMaskAngle+180,wedgeAngle)
            end
            
            Screen('DrawDots',wPtr,[XCtr YCtr],fixdotsz,bgc,[],2); % round dot
            DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr)
            vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
            imageArray = Screen('GetImage', wPtr);
            eval(sprintf('imgarray.block%i.cue=imageArray;',n))
            
            
        elseif GetSecs - starttime_block > fixDur + cueDur          
                        
            Screen('DrawTexture',wPtr,checkboard_tPtr);
            Screen('FillArc',wPtr,wedgeMaskClr,[],WedgeMaskAngle,wedgeAngle)
          switch CueLoc
                case 1
                    Screen('FrameArc',wPtr,[1 0 0],wedgeLoc,WedgeMaskAngle,wedgeAngle,10)               
                case 2
                    Screen('FrameArc',wPtr,[1 0 0],wedgeLoc,WedgeMaskAngle+180,wedgeAngle,10)
             end
            Screen('DrawDots',wPtr,[XCtr YCtr],fixdotsz,bgc,[],2); % round dot
            DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr)
            vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
                                   
            Screen('DrawTexture',wPtr,checkboard_comp_tPtr);
            Screen('FillArc',wPtr,wedgeMaskClr,[],WedgeMaskAngle,wedgeAngle)
            
            
             switch CueLoc
                case 1
                    Screen('FrameArc',wPtr,[1 0 0],wedgeLoc,WedgeMaskAngle,wedgeAngle,10)               
                case 2
                    Screen('FrameArc',wPtr,[1 0 0],wedgeLoc,WedgeMaskAngle+180,wedgeAngle,10)
             end
             
            Screen('DrawDots',wPtr,[XCtr YCtr],fixdotsz,bgc,[],2); % round dot
            DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr)
            vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
            imageArray = Screen('GetImage', wPtr);
            eval(sprintf('imgarray.block%i.stim=imageArray;',n))
        else
            
            Screen('DrawDots',wPtr,[XCtr YCtr],fixdotsz,bgc,[],2); % round dot
            DrawFixation(wPtr, XCtr, YCtr, fixlen,fixwth,fixclr)
            vbl = Screen('Flip', wPtr, (waitframes-0.5)*ifi + vbl);
        end
        
        QuitKeyWait; if QuitSignal ==1 , return, end
    end
end

toc
Priority(0);
sca


