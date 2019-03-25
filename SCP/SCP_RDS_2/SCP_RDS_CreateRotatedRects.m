function IMGARRAY = SCP_RDS_CreateRotatedRects(IMGX,IMGY,RECTX,RECTY,THETAS,RECTCLR,BGCLR,BINARYSWITCH)
fprintf('%s\n',mfilename())

if ~exist('IMGX','var')    || isempty(IMGX)
    IMGX = 100;
end
if ~exist('IMGY','var')    || isempty(IMGY)
    IMGY = 100;
end
if ~exist('RECTX','var')   || isempty(RECTX)
    RECTX = 80;
end
if ~exist('RECTY','var')   || isempty(RECTY)
    RECTY = 20;
end
if ~exist('THETAS','var')  || isempty(THETAS)
    THETAS = 30;
end
if ~exist('RECTCLR','var') || isempty(RECTCLR)
    RECTCLR = [255 255 255];
end
if ~exist('BGCLR','var')   || isempty(BGCLR)
    BGCLR  = [128 128 128];
end
if ~exist('BINARYSWITCH','var') || isempty(BINARYSWITCH)
    BINARYSWITCH = 0;
end
BLANKIMG = uint8(zeros(IMGY,IMGX,3));
DIMS = round([(IMGX-RECTX)/2+1,(IMGY-RECTY)/2+1, (IMGX-RECTX)/2+RECTX, (IMGY-RECTY)/2+RECTY]);
IMGARRAY = struct;

try
    for THETAID = 1:length(THETAS)
        THETA = THETAS(THETAID);
        RECTIMG   = BLANKIMG;
        for CLRCHN = 1:3
            RECTIMG(:,:,CLRCHN) = BGCLR(CLRCHN);
            RECTIMG(DIMS(2):DIMS(4),DIMS(1):DIMS(3),CLRCHN) = RECTCLR(CLRCHN);
        end
        
        RECTIMG_ROTATED = imrotate(RECTIMG,360-THETA,'nearest','crop');
        RECTIMG_BGCFILLED = RECTIMG_ROTATED;
        RECTIMG_ROTATED_SUMMED = sum(RECTIMG_ROTATED,3);
        
        [II, JJ] = find(RECTIMG_ROTATED_SUMMED == 0);
        
        for BLKID = 1:length(II)
            RECTIMG_BGCFILLED(II(BLKID),JJ(BLKID),:) = BGCLR;
        end
        if BINARYSWITCH
            RECTIMG_BGCFILLED = rgb2gray(RECTIMG_BGCFILLED);
        end
         eval(sprintf('IMGARRAY.DEG%i = RECTIMG_BGCFILLED;',THETA))        
    end
catch err
    sca
    ShowCursor
    commandwindow
    rethrow(err)
end
fprintf('%s DONE \n',mfilename())
