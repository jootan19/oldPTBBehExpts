function [data]=MakeChirp(sf,d,f0,f1,t0,mode,reps)

if ~exist('sf',   'var'), sf   = 48000; end % sampling freq
if ~exist('d',    'var'), d    = 5;     end % duration
if ~exist('f0',   'var'), f0   = 2370;   end % starting freq
if ~exist('f1',   'var'), f1   = 5900;  end % freq when time crosses t0
if ~exist('t0',   'var'), t0   = d;     end
if ~exist('mode', 'var'), mode = 0;     end
if ~exist('reps', 'var'), reps = 3;     end


try
    switch mode
        case 1
            n = sf*d;     % number of samples
            t = 0:1/sf:d;
            y = chirp(t(1:n),f0,t0,f1);
        otherwise
            d = d/2;
            t0 = d;
            n = sf*d;     % number of samples
            t = 0:1/sf:d;
            y = chirp(t(1:n),f0,t0,f1);
            y=[y fliplr(y)];
    end
    
    data = repmat(y,1,reps);
catch err
    ShowCursor;
    sca;
    fprintf('\n\nError making chirp\n\n')
    rethrow(err);
end

% spectrogram(data,256,200,256,sf,'yaxis');