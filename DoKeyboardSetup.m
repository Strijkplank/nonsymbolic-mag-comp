addpath([cd filesep 'functions'])
addpath([cd filesep 'functions' filesep 'my-ptb-funcs'])

if ~IsLinux
    if length(GetKeyboardIndices) == 1
        deviceIndexToUse = GetKeyboardIndices;
    else
        [deviceNameToUse, deviceIndexToUse] = FindKeyboard();
    end
else
    deviceIndexToUse = 'LINUX'
end
save('keyboard.ini','deviceIndexToUse','-ascii')
disp('DONE!')