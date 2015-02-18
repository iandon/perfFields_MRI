function myscreen = perfFields_prf(observer,varargin)

%%% main function that runs the task in the scanner using only a neutral
%%% cue
% The raised cosine reqires matlabPyrTools
global stimulus;
global MGL;

mglOpen
clear task myscreen;
% check arguments
% if ~any(nargin == 3)
%     help transientAttention
%     return
% % end
% 
eval(evalargs(varargin,0,0,{'Eye','sf','TR','easyFixTask'}));


if ieNotDefined('Eye'),Eye = 0;end % no eye-tracking
if ieNotDefined('sf'),sf = 1.5;end
if ieNotDefined('TR'),TR = 1.5;end
if ieNotDefined('flickerHz'),hz = 10;end
if ieNotDefined('easyFixTask'),easyFixTask = 0;end

thisdir = pwd;
% make a data directory if necessary
if ~isdir(fullfile(thisdir,'data'))
    disp('Making data directory');
    mkdir('data');
end

% make an observer directory if necessary
datadirname = fullfile(thisdir,'data',observer);
if ~isdir(datadirname);
    disp(sprintf('Making observer directory %s',datadirname));
    mkdir(datadirname);
end

disp(sprintf('[ DATA ] saving data in: %s',datadirname));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initalize the screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initalize the screen

stimulus.EyeTrack=Eye;
myscreen = initScreen('disp2');
myscreen.datadir = datadirname;
myscreen.allowpause = 0;
myscreen.saveData = -2;
myscreen.background=.5;
%mglVisualAngleCoordinates(57);%,[37.51, 31.11]); %[26 42] %distance from screen, height & width of monitor

if stimulus.EyeTrack
    myscreen = eyeCalibDisp(myscreen);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize fixation task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global fixStimulus;
if ~easyFixTask
  % default values
  fixStimulus.diskSize = 0.5;
  fixStimulus.fixWidth = 1;
  fixStimulus.fixLineWidth = 3;
  fixStimulus.stimTime = 0.4;
  fixStimulus.responseTime = 1;
else
  % make cross bigger and task slower
  fixStimulus.diskSize = 0.5;
  fixStimulus.fixWidth = 1+1*easyFixTask;
  fixStimulus.fixLineWidth = 3+2*easyFixTask;
  fixStimulus.stimTime = 0.4+0.4*easyFixTask;
  fixStimulus.responseTime = 1+1*easyFixTask;
end

fixStimulus.pos = [0 0];
[task{1} myscreen] = fixStairInitTask(myscreen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

task{2}{1}.waitForBacktick = 1;
task{2}{1}.segmin =     [12,1.48.*ones(1,33)];
task{2}{1}.segmax =     [12,1.52.*ones(1,33)];  
task{2}{1}.segquant =   zeros(size(task{2}{1}.segmin));
task{2}{1}.getResponse = zeros(size(task{2}{1}.segmin));

task{2}{1}.synchToVol = [0,1,zeros(1,size(task{2}{1}.segmin,2)-2)];


n_repeats = 1;%  trials per block n= 36; 3contrast*3ITIs*2location 
% Number of volumes = (n)+(n/3*2)+(n/3*3)+(n/3*4).
%n_repeats will have to be adjusted depending on our TR to keep block
%length approximately ~5minutes


[trialType,repeats] = ndgrid(1:4,1:n_repeats);

numTrials = length(trialType(:));

dir = nan(numTrials,2);
for i = 1:numTrials
    if trialType(i) == 1
        dir(i,:) = [1,3]; %blank,right,up
        ori(i,:) = [0,0];
    elseif trialType(i) == 2
        dir(i,:) = [2,4]; %blank,left,down
        ori(i,:) = [180,180];
    elseif trialType(i) == 3
        dir(i,:) = [1,4]; %blank,right,up
        ori(i,:) = [0,180];
    elseif trialType(i) == 4
        dir(i,:) = [2,3]; %blank,right,up
        ori(i,:) = [180,0];
    end
end


task{2}{1}.randVars.len_ = numTrials;
task{2}{1}.randVars.trialNum = 1:numTrials;
stimulus.sf = sf;
stimulus.trialNum=0;
stimulus.dir = dir;
stimulus.ori = ori;
task{2}{1}.trialNum = 1:size(stimulus.dir,1);
stimulus.numTrials = size(stimulus.dir,1);
stimulus.desiredHz = hz;
stimulus.phaseCont = 1;
stimulus.frameNum = 1;


task{2}{1}.random = 0;
[task{2}{1}, myscreen] = initTask(task{2}{1},myscreen,@StartSegmentCallback,@DrawStimulusCallback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myscreen = initStimulus('stimulus',myscreen);
stimulus = myInitStimulus(stimulus,myscreen,task);


myscreen = eyeCalibDisp(myscreen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main display loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mglSimulateRun(TR,164,0)
phaseNum = 1;
while (phaseNum <= length(task)) && ~myscreen.userHitEsc
    % update the task
    % runs automatically the task, you only need to change: StartSegmentCallback,DrawStimulusCallback,responseCallback
    [task{2},myscreen,phaseNum] = updateTask(task{2},myscreen,phaseNum);
    % flip screen
    [task{1},myscreen] = updateTask(task{1},myscreen,1);
    myscreen = tickScreen(myscreen,task);
end
clear stimulus.tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myscreen = endTask(myscreen,task);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TASK 1: function that gets called at the start of each segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [task, myscreen] = StartSegmentCallback(task, myscreen)
% segments: 1:ITI,   2:fixation,    3:stimulus, 4:response
global stimulus


stimulus.frameNum = 1;
stimulus.phasCont = 1;


if (task.thistrial.thisseg == 1) % fixation
disp(sprintf('starting trial number %d at volume %d',task.thistrial.trialNum,myscreen.volnum));
stimulus.trialNumChange = 0;
task.thistrial.seglen =[12,1.5.*ones(1,33)];%delay the start of the first trial by 6 TRs (6*1.75+0.5)
end


mglClearScreen(stimulus.grayColor);
setGammaTable(1);
end


%%
function [task, myscreen] = DrawStimulusCallback(task, myscreen)
global stimulus;

mglClearScreen(stimulus.grayColor);%###

if (sum(task.thistrial.thisseg ==[1,18]))  % blank
    mglClearScreen(stimulus.grayColor);
    if task.thistrial.thisseg == 1
    task.thistrial.seglen = [12,1.48.*ones(1,33)];
    end
elseif task.thistrial.thisseg < 19
    if (myscreen.framesPerSecond/stimulus.desiredHz) <= stimulus.frameNum
        if stimulus.phaseCont ==1
            stimulus.phaseCont =2;
        else
            stimulus.phaseCont = 1;
        end
        stimulus.frameNum = 0;
    end
    mglBltTexture(stimulus.tex{task.thistrial.thisseg-1,stimulus.phaseCont,1,task.thistrial.trialNum},...
                  [0 0 stimulus.sizeGrating stimulus.sizeGrating],0,0,[stimulus.ori(task.thistrial.trialNum,1),0]);
              stimulus.frameNum = stimulus.frameNum+1;
else
    if (myscreen.framesPerSecond/stimulus.desiredHz) <= stimulus.frameNum
        if stimulus.phaseCont ==1
            stimulus.phaseCont =2;
        else
            stimulus.phaseCont = 1;
        end
        stimulus.frameNum = 0;
    end
    mglBltTexture(stimulus.tex{task.thistrial.thisseg-18,stimulus.phaseCont,2,task.thistrial.trialNum},...
                  [0 0 stimulus.sizeGrating stimulus.sizeGrating],0,0,[0,stimulus.ori(task.thistrial.trialNum,2)]);
    stimulus.frameNum = stimulus.frameNum+1;
end

    
end


