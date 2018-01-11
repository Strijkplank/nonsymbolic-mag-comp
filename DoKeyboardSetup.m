addpath([cd filesep 'functions'])
addpath([cd filesep 'functions' filesep 'my-ptb-funcs'])
if length(GetKeyboardIndices) == 1
    deviceIndexToUse = GetKeyboardIndices;
else
    [deviceNameToUse, deviceIndexToUse] = FindKeyboard();
end
save('keyboard.ini','deviceIndexToUse','-ascii')
disp('DONE!')