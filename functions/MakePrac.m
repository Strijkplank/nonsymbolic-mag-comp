function trialStruct = MakePrac(TASK_TYPE,TABLE_DESC_FILE,N_TRIALS,CURRENT_FOLDER,scaleFactor)
%clear
%TASK_TYPE = 'full';
%TABLE_DESC_FILE = 'table_desc.txt';
%N_TRIALS = 40;
%CURRENT_FOLDER =     '/Users/lincoln/GitHub/NonSymbolicDistanceEffect';
%scaleFactor = 1.2;

switch TASK_TYPE
    case 'full'
        imageInfo = load([cd filesep 'functions' filesep 'FullConditions.mat'],'-ASCII');
       
        
    case 'partial'
        imageInfo = load([cd filesep 'functions' filesep 'PartialConditions.mat'],'-ASCII');
  
end

imageInfoPrac = imageInfo(201:end,:);
uniquePairs = unique(arrayfun(@(x,y) [num2str(x) '_' num2str(y)],imageInfoPrac(:,3), imageInfoPrac(:,11),'UniformOutput',false));
allPairs = arrayfun(@(x,y) [num2str(x) '_' num2str(y)],imageInfoPrac(:,3), imageInfoPrac(:,11),'UniformOutput',false);

PRAC_TRIALS = cellfun(@(x) [min(imageInfoPrac(ismember(allPairs,x),1)) max(imageInfoPrac(ismember(allPairs,x),1))],uniquePairs,'UniformOutput',false);
PRAC_TRIALS = horzcat(PRAC_TRIALS{:});

imageInfo = imageInfo(PRAC_TRIALS,:);

imageDir = [CURRENT_FOLDER filesep 'functions' filesep 'images' filesep TASK_TYPE '400N'];

imageFiles = arrayfun(@(n) [imageDir filesep num2str(n) '.bmp'],PRAC_TRIALS,'UniformOutput',false);


tableDesc = readtable([cd filesep 'functions' filesep TABLE_DESC_FILE]);
tableDesc.Properties.VariableNames([1:3]) = {'col','desc','label'};


for i = 1 : N_TRIALS
    origImg = imread(imageFiles{i});
    
    [p, n, e] = fileparts(imageFiles{i});
    % -- Resize the images -- %
    newImg = imresize(origImg, scaleFactor);
    
    
    % -- Put them in the trialStruct -- %
    
    trialStruct(i).TASK_TYPE = TASK_TYPE;
    
    trialStruct(i).origImg = origImg;
    trialStruct(i).stimulus = newImg;
    
    trialStruct(i).fileName = [n e];
    trialStruct(i).fullPath = p;
    
    
    for t = 1 : height(tableDesc)
        trialStruct(i).(tableDesc.label{t}) = imageInfo(i,tableDesc.col(t));
    end
    
end



% -- Randomise and build trial structure -- %

newOrder = randperm(N_TRIALS,N_TRIALS);

trialStruct = struct2table(trialStruct);
trialStruct = trialStruct(newOrder,:);
trialStruct.trialNumber = [1:N_TRIALS]'; % the the trial number

% -- Now add the descriptions -- %

for t = 1 : height(tableDesc)
    trialStruct.Properties.VariableDescriptions{tableDesc.label{t}} = tableDesc.desc{t};
end

trialStruct.Properties.VariableDescriptions{'TASK_TYPE'} = 'For the full condition, congruent means: larger number with larger sensory cues for the partial condition, congruent means: larger number with larger convex hull but smaller diameter, smaller surface, smaller contour length and less dense';
trialStruct.Properties.VariableDescriptions{'fileName'} = 'filename of the image';
trialStruct.Properties.VariableDescriptions{'fullPath'} = 'full path where the image was read from';

trialStruct.Properties.VariableDescriptions{'origImg'} = 'matrix of the original image';
trialStruct.Properties.VariableDescriptions{'stimulus'} = 'matrix of the resized image';


trialStruct.trialType = repmat('pra',height(trialStruct),1);

trialStruct.Properties.VariableDescriptions{'trialType'} = 'prac trial or experimental trial';




