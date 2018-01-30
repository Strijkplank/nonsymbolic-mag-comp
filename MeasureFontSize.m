load([cd filesep 'functions/params.mat'])


onecmpixelheight = mean(horzcat(params.rawInfo.sizeparams.rectWidth));

Screen('Preference', 'SkipSyncTests', 1)
[w,rect] = PsychImaging('OpenWindow',0,[]);
i = 40;

Screen('TextSize',w,i);

[xCenter,yCenter] = RectCenter(rect); % get the centre coordinates
Screen('TextSize',w,i) % Set text size to 12
DrawFormattedText(w,'0','center','center')
Screen('Flip',w)
M = Screen('GetImage',w);


%find top line
y = 1;
e = 0;
while e == 0
    pixels = find(M(y,:) ~= 255);
    if ~isempty(pixels)
        e = 1;
    end
    y = y + 1;
end

top = y - 1;

y = size(M,1);
e = 0;
while e == 0
    pixels = find(M(y,:) ~= 255);
    if ~isempty(pixels)
        e = 1;
    end
    y = y - 1;
end

bottom = y + 1;

sca;

disp(['The Symbolic Stimuli will be ' num2str(abs(top-bottom)/onecmpixelheight) ' cms height'])
disp(['Give this number to lincoln!'])
