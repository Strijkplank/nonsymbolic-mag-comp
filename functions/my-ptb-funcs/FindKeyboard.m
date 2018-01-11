function [deviceNameToUse, deviceIndexToUse] = FindKeyboard()
commandwindow;

[keyboardIndices, productNames, ~] = GetKeyboardIndices;
WaitSecs(.1);

deviceToUse = [];
commandwindow;
keyIsDown = 0;
i = 0;


while keyIsDown == 0
    i = i + 1;
    deviceToUse = keyboardIndices(i);
    KbQueueCreate(deviceToUse);
    KbQueueStart(deviceToUse);
    KbQueueFlush(deviceToUse);
    disp(['Trying ' productNames{i}])
    disp('Press space')
    WaitSecs(2);
    [keyIsDown] = KbQueueCheck(deviceToUse);
    
    if i == length(keyboardIndices)
        i = 0;
    end
    if keyIsDown == 0
        disp('Didn''t detect anything. Trying another keyboard')
    end
    KbQueueRelease(deviceToUse)
    KbQueueStop(deviceToUse)
 
end

if(length(keyboardIndices)) == 1
    i = 1;
end
deviceNameToUse = productNames{i};
deviceIndexToUse = keyboardIndices(i);

