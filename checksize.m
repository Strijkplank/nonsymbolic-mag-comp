files  =dir([cd filesep 'error' filesep '*.mat']);

file = [files.folder filesep files.name];
load(file)
screenWidth = errorData.rawInfo.d.screenXpixels;
imageWidth = size(errorData.rawInfo.newImg,2);

if imageWidth < screenWidth 
    disp('OK!');
else
    disp('To small!');
end