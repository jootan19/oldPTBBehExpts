function [QuitSignal,subNo, runNo, Order, eyetrack,SAVELOG] =  GetInputs(debug,runtime)

try     
    commandwindow;
    subNo = 99;
    runNo = 999;
    Order = 2;
    eyetrack = 0;
    QuitSignal = 0;
    
    if ~exist('debug', 'var'),    debugmode = 0;    end
    
    
    if ~debug
        prompt    = {'subNo', 'runNo', 'Order [1 = Hi 1st / 2 = Low 1st]', 'EyeTracking? [1/0]'};
        outputReq = {'subNo', 'runNo', 'Order', 'eyetrack'};
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
                    if ~ismember(tempinput,[1 2])
                        disp('Only 2 Orders available')
                        checked = 0;
                    end
                end
                if x == 4
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
    SAVELOG.Order   = Order;
    SAVELOG.Debug   = debug;
    SAVELOG.Eyetracking  = eyetrack;
    

catch err
    CleanUp    
    rethrow(err);
end