function PressToGo(device,keyList)

if nargin == 2
    KbQueueCreate(device,keyList);
else
    KbQueueCreate(device);
end
KbQueueStart(device)
pressed = 0;

while pressed == 0
    [ pressed, ~] = KbQueueCheck(device);
end

KbQueueFlush(device);
KbQueueRelease(device);
KbQueueStop(device);



end