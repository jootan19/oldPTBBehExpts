try
    InitializePsychSound(1);
    
    % Get ready for audio playback
    sf         = 48000;
    nChns      = 1;
    sugLat     = [];
    vol_master = 0.5;    
    
    if IsWin, sugLat = 0.015; end
    
    pamaster = PsychPortAudio('Open', [], 1+8, 1, sf, nChns, [], sugLat); % Master
    PsychPortAudio('Start', pamaster, 0, 0, 1);             % initialise master
    PsychPortAudio('Volume', pamaster, vol_master);         % set volume of master
    pasound     = PsychPortAudio('OpenSlave', pamaster, 1); % Open slave device
    pamodulator = PsychPortAudio('OpenSlave', pasound , 32);
    
catch err
    ShowCursor;
    sca;
    fprintf('\n\nError starting audio\n\n')
    rethrow(err);
end



% tone = MakeBeep(3000,10,[48000]);
% PsychPortAudio('FillBuffer', pasound1, tone)
% PsychPortAudio('Start', pasound1, 1, 0, 1);
%
% KbWait;
%
% PsychPortAudio('Stop', pasound1, 1)
