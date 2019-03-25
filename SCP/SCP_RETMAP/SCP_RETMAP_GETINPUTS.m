function [SUBNO , RUNNO , ATTENTIONCOND, PRACTICE, QuitSignal] = SCP_RETMAP_GETINPUTS(debugmode)

SUBNO = 999;
RUNNO = 999;
ATTENTIONCONDAVAIL = {'Left_Right', 'Up_Down'};
ATTENTIONCOND      = ATTENTIONCONDAVAIL{1};
PRACTICE = 1;
QuitSignal   = 0;


if ~exist('debugmode', 'var'),    debugmode = 0;    end
try
    if ~debugmode
        
        outputReq = {'SUBNO', 'RUNNO','ATTENTIONLOC', 'PRACTICE'};
        
        for X = 1:length(outputReq)
            checked = 0;
            for tries = 1:5
                switch X
                    case 1
                        prompt = sprintf('Subject no. or ''q'' to quit: ');
                    case 2
                        prompt = sprintf('Run no. or ''q'' to quit: ');
                    case 3
                        prompt = sprintf('Attention loc, 1=left/right, 2=up/down: ');
                    case 4
                        prompt = sprintf('Practice mode? 1=practice, 0=fmri: ');
                end
                tempinput = input(prompt);
                if strcmpi(tempinput , 'q')
                    disp('Giving up now...')
                    QuitSignal = 1; return
                end
                if numel(tempinput)==1 && isnumeric(tempinput)
                    if X == 3
                        if ~ismember(tempinput,[1 2])
                            disp('Only 2 options available')
                        else
                             ATTENTIONCOND = ATTENTIONCONDAVAIL{tempinput};
                            checked = 1;
                        end
                    elseif X == 4
                        if ~ismember(tempinput,[1 0])
                            disp('Only 2 options available')
                        else
                            checked = 1;
                        end
                    else
                        checked = 1;
                    end
                else
                    disp('Incorrect inputs, try again or ''q'' to quit');
                end
                
                if checked
                    eval(sprintf('%s = tempinput;', outputReq{X}))
                    break
                end
            end
        end
    end
   
catch err
    sca;
    ShowCursor;
    commandwindow;
    rethrow(err)
end

