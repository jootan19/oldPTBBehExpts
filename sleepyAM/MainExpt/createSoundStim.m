function [SoundLib] = createSoundStim(SAVELOG)
fprintf('Running %s...',mfilename())
try
    
    % Make White Noise Library
    audioSampleFreq = 48000;
    wnoisefName = 'WhiteNoise.wav';
    whitenoise = (wavread(wnoisefName))';
    whitenoise = repmat(whitenoise,[1 SAVELOG.Paradigm.StimBlockDur]);
    filterset = [SAVELOG.Paradigm.Pitch_Hi; SAVELOG.Paradigm.Pitch_Lo];
    Library_noise_raw = cell(1,2);
    
    for y = 1:2
        % MAIN PITCH - NO CHANGE
        filter_main = filterset(y);
        fNorm       = filter_main/(audioSampleFreq/2); %normalising filter
        [b,a]       = butter(10, fNorm, 'high'); % creating butterworth 10 order high pass filter.
        noise_filt  = filtfilt(b, a, whitenoise);    % filtering noise to create newnoise
        Library_noise_raw(y)={noise_filt};
    end
    
    % Normalising and fading in and out
    fade_duration = 0.5;
    nsamples      = fade_duration *audioSampleFreq;
    fade_rate     = 1/nsamples;
    fade_in       = zeros(1,nsamples);
    fade_out      = zeros(1,nsamples);    
    
    for x=1:nsamples
        fade_in(x)  = fade_rate*x;
        fade_out(x) = 1-fade_rate*x;
    end
    
    for n = 1:2
        snd = Library_noise_raw{n};
        snd_sz = size(snd,2);
        snd(1:nsamples) = fade_in.*snd(1:nsamples); %fade IN
        snd(snd_sz-nsamples+1:snd_sz) = fade_out.*snd(snd_sz-nsamples+1:snd_sz); %fade out
        minVal = abs(min(snd));
        maxVal = abs(max(snd));
        if minVal>maxVal, normVal = minVal;
        else              normVal = maxVal;
        end
        snd_norm = snd / normVal;% normalise
        eval(sprintf('SoundLib.Pitch_%i = snd_norm;',filterset(n)))        
    end
    
    % Make AM envelope library
    AMFreqSet  = [SAVELOG.Paradigm.AM_Hi SAVELOG.Paradigm.AM_Lo];    
    for AM = 1:2        
        AMRate = AMFreqSet(AM);
        eval(sprintf('SoundLib.AM_%i = (1+MakeBeep(AMRate,1/AMRate,audioSampleFreq))/2;',AMRate));
    end
        
    fprintf('[Done]\n\n')
    
catch err
    fprintf('\n\nError in %s \n\n',mfilename())
    CleanUp
    rethrow(err)
end
