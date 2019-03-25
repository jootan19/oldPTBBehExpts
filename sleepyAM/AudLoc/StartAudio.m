try
    InitializePsychSound(1);
    nrchannels      = 1;
    audioSampleFreq = sf;
    sugLat          = [];
    volume          = 1;
    if IsWin,
        sugLat      = 0.015;
    end
    pamaster = PsychPortAudio('Open', [], 1+8, 1, audioSampleFreq, nrchannels, [], sugLat); %Master
    PsychPortAudio('Start', pamaster, 0, 0, 1); %initialise master
    PsychPortAudio('Volume', pamaster, volume);    %set volume
    pasound1    = PsychPortAudio('OpenSlave', pamaster, 1); %Open slave device
%     pamodulator = PsychPortAudio('OpenSlave', pasound1, 32);
    
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
