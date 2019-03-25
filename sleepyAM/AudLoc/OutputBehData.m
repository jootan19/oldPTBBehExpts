function OutputBehData(ResultSet, outputfName)

fprintf('\n\n\t\tWriting output beh file......')
fd           = fopen(outputfName, 'w');
for n=1:size(ResultSet,1)
    fprintf(fd,'%2d\t%2d\t%2d\t%6.4f\t%6.4f\t%2d\n',ResultSet(n,:));
end
fclose('all');
fprintf('[DONE]\n')

% Output Beh data - AUDIO

% no. clolor change: 4 (if non debug mode) 2 (if debug mode)

% if debug,      fmt = '%2d\t%2d\t';
% elseif ~debug, fmt = '%2d\t%2d\t%2d\t%2d\t'; end
% 
% fprintf(fd, [fmt '%6.2f\t%3d\n'], ResultSet(x,:));