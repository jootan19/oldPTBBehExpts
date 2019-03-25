clear all
close all
commandwindow
home
QuitSignal = 0;
debugmode = 1;

[wPtr, rect] = OpenScreen([0 0 0], debugmode);
resX = rect(3);
resY = rect(4);

XCtr = resX/2;
YCtr = resY/2;
quitkey = 'q';

dims = [80,25];
texture = zeros(dims);
texture(:) = 255;

textPtr = Screen('MakeTexture',wPtr,texture);
fixlen  = 10;
dstrect =[ XCtr-dims(2)/2,YCtr-dims(1)/2, XCtr+dims(2)/2, YCtr+dims(1)/2];
jitter = 10;

imgArray = struct;
try
    for x = 0:360
        Screen('DrawTexture',wPtr,textPtr,[],dstrect,x,[],[],[],[],[]);
        Screen('Flip', wPtr);
        tempimgArray = Screen('GetImage',wPtr,[XCtr-(max(dims)/2+jitter) ,YCtr-(max(dims)/2+jitter), XCtr+(max(dims)/2+jitter), YCtr+(max(dims)/2+jitter)]);
        eval(sprintf('imgArray.deg%i = tempimgArray;',x))
        QuitKeyWait; if QuitSignal ==1 , return, end
    end
    sca
catch err
    sca; ShowCursor;
    disp('Error in start screen')
    rethrow(err)
end

save('imgArray.mat','imgArray')

copyfile imgArray.mat sandbox/imgArray.mat
delete imgArray.mat