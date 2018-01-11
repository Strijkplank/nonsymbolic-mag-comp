% This code checks how many stimuli can be trimmed off the edges of the
% stimuli


imageFolder = '/Users/lincoln/GitHub/NonSymbolicDistanceEffect/functions/imagesDenes/full400N/';

imageFiles = struct2table(dir(imageFolder));
imageFiles = imageFiles(imageFiles.isdir == 0,:);

 br = zeros(400,1175);

for i = 1 : height(imageFiles)
    
   thisFile = [imageFiles.folder{i,1},filesep, imageFiles.name{i,1}];
   
    M = imread(thisFile);
    
    
    for t = 1 : 1175
        br(i,t) = mean(mean(M(:,t,:)));
    end
end

i = 0;
bla = 0;
while bla == 0
    bla = mean(mean([br(:,1+i) br(:,1175-i)]));
    i = i + 1;
end