function [QuitSignal,subNo, runNo, behav, SAVELOG] =  GetInputs(debug,runtime)

try     
    commandwindow;
    subNo = 99;
    runNo = 999;
    behav = 1;    
    
    QuitSignal = 0;
    
    if ~exist('debug', 'var'),    debugmode = 0;    end
    
    
    if ~debug
        prompt    = {'subNo', 'runNo','Behav? [1/0]'};
        outputReq = {'subNo', 'runNo','behav'};
        for x = 1:length(prompt)
            for y = 1:3
                checked = 1;
                tempinput = input([prompt{x} ': ' ]);
                if strcmpi(tempinput , 'q')
                    disp('Giving up now...')
                    QuitSignal = 1; break
                end
                if length(tempinput)~=1 || ~isnumeric(tempinput)
                    disp('Incorrect inputs, try again or ''q'' to quit');
                    checked = 0;
                end
                if x == 3
                      if ~ismember(tempinput,[1 0])
                        disp('Only 2 options available')
                        checked = 0;
                    end
                end                
                
                if checked
                    eval(sprintf('%s = tempinput;', outputReq{x}))
                    break
                end
            end
            if QuitSignal==1
                break
            end
        end
    end
    
    SAVELOG = struct;
    SAVELOG.ExptDateTime = datestr(runtime);
    SAVELOG.SubNo   = subNo;
    SAVELOG.RubNo   = runNo;    
    SAVELOG.Behav   = behav;
    SAVELOG.Debug   = debug;        

catch err
    CleanUp    
    rethrow(err);
end