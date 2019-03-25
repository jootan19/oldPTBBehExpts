function [varargout,devices, QuitSignal] = getDevID2(varargin)
try
    fprintf('\n\n---------------------Getting Device IDs---------------------\n')
    %% ------------------------ INPUTS ------------------------ % %
    trigger  = varargin{1};     % % trigger  : 1 = apple keyboard | 2 = scanner pulse | 3 = A4Tech keyboard
    response = varargin{2};     % % response : 1 = apple keyboard | 2 = old response boxes | 3 = NNL Grips | 4 = Current designs button boxes.
    devices = PsychHID('devices');
    if trigger<0 || trigger>3
        fprintf('Trigger requested not recognised....Possible triggers accepted are 1-3 only\n')
        QuitSignal = 1;
        varargout{1}=[];
        return;
    end
    if response<0 || response>5
        fprintf('Response requested not recognised....Possible triggers accepted are 1-5 only\n')
        QuitSignal = 1;
        varargout{1}=[];
        return;
    end
    QuitSignal = 0;
    
    possibleTrigs = {'Apple, Inc','NOVATEK', 'A4Tech'};
    possibleResp  = {'Apple, Inc','P.I. Engineering', 'Code Mercenaries', 'Current Designs, Inc.','A4Tech'};
    
    %% ------------------------ TRIGGER ------------------------ % %
    trigName = possibleTrigs(trigger);
    fprintf(' Trigger requested is: %s\n', trigName{:})
    if trigger ~=1
        trigID= find(strcmpi(trigName,{devices.manufacturer}) & strcmpi('Keyboard',{devices.usageName}));
        if isempty(trigID)
            fprintf('\tRequested device "%s" not connected........\n', trigName{:})
            fprintf('\tChanging trigger to default: Apple Keyboard \n')
            trigger =1 ;
        end
    end
    
    if trigger ==1
        %         keybID= find(strcmpi('Keyboard',{devices.usageName}));
        keybID=find(strcmpi('Apple, Inc',{devices.manufacturer}) & strcmpi('Keyboard',{devices.usageName}));
        if isempty(keybID)
            keybID=find(strcmpi('Apple Inc.',{devices.manufacturer}) & strcmpi('Keyboard',{devices.usageName}));
        end
        
        %     trigID = keybID(keybID2);
        trigID = keybID;
    end
    varargout{1} = trigID;
    
    
    %% ------------------------ RESPONSE ------------------------ % %
    respName = possibleResp(response);
    fprintf('Response requested is: %s\n', respName{:})
    if response ~=1
        respID= find([strcmpi(respName,{devices.manufacturer}) &  strcmpi('Keyboard',{devices.usageName})]);
        if isempty(respID)
            fprintf('\tRequested device "%s" not connected........\n', respName{:})
            fprintf('\tChanging response to default: Apple Keyboard \n')
            response = 1;
        end
    end
    if response == 1
        %         keybID= find(strcmpi('Keyboard',{devices.usageName}));
        keybID=find(strcmpi('Apple, Inc',{devices.manufacturer}) & strcmpi('Keyboard',{devices.usageName}));
        if isempty(keybID)
            keybID=find(strcmpi('Apple Inc.',{devices.manufacturer}) & strcmpi('Keyboard',{devices.usageName}));
        end
        %     respID = keybID(keybID2);
        respID = keybID;
        
    end
    varargout{2} = respID;   
    
    %% ------------------------ OUTPUT ------------------------ % %
    fprintf('\n Trigger ID = %i\n',trigID)
    fprintf('Response ID = %i\n',respID)
    fprintf('------------------Getting Device IDs [DONE]------------------\n\n')
catch err
    sca;
    ShowCursor;
    fprintf('\n\nERROR GETTING DEVICE ID !!!!!!------\n\n')
    rethrow(err)
end
