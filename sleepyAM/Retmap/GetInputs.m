function [QuitSignal,subNo, runNo, order, behav, SAVELOG] =  GetInputs(debug,runtime)

try     
    commandwindow;
    subNo = 99;
    runNo = 999;
    order  = 1;
    behav = 1;    
    
    QuitSignal = 0;
    
    if ~exist('debug', 'var'),    debugmode = 0;    end
    
    
    if ~debug
        prompt    = {'subNo', 'runNo','Order [1,2 or 3]','Behav? [1/0]'};
        outputReq = {'subNo', 'runNo','order','behav'};
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
                if x == 4
                      if ~ismember(tempinput,[1 2 3])
                        disp('Only 1/2/3 accepted')
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
    SAVELOG.Order   = order;
    SAVELOG.Behav   = behav;
    SAVELOG.Debug   = debug;        

catch err
    CleanUp    
    rethrow(err);
end