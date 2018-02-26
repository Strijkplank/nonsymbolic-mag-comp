function PressToGo(device,keyList)

if nargin == 2
    KbQueueCreate([],keyList);
else
    KbQueueCreate([]);
end
KbQueueStart([])
pressed = 0;

while pressed == 0
    [ pressed, ~] = KbQueueCheck([]);
end

KbQueueFlush([]);
KbQueueRelease([]);
KbQueueStop([]);



end