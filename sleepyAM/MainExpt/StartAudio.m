disp('Starting  audio...')

try    
    InitializePsychSound(1);
    nrchannels      = 1;
    audioSampleFreq = 48000;
    audTime         = 1 ;
    sugLat          = [];
    % volume          = 1.0;
    volume          = 0.5;
    if IsWin,
        sugLat      = 0.015;
    end
    pamaster = PsychPortAudio('Open', [], 1+8, 1, audioSampleFreq, nrchannels, [], sugLat); %Master
    PsychPortAudio('Start', pamaster, 0, 0, 1); %initialise master
    PsychPortAudio('Volume', pamaster, volume);    %set volume
    pasound1    = PsychPortAudio('OpenSlave', pamaster, 1); %Open slave device
    pamodulator = PsychPortAudio('OpenSlave', pasound1, 32);
catch err
    CleanUp
    disp('\n\nError starting audio\n\n')
    rethrow(err);
end

fprintf('%s [Done]\n\n',mfilename())