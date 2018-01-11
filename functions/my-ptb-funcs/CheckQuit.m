function CheckQuit(firstPress,quitKey)

if nargin == 1
    quitKey = 'q';
else
    quitKey = KbName(quitKey);
end

if firstPress(quitKey) ~= 0
    sca;
    ListenChar(0);
    ShowCursor;
    error('Quit early!')
end
