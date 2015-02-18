function stimulus = myInitStimulus(stimulus,myscreen,task,contrast)
global MGL;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to init the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's get the linearized gamma table
stimulus.linearizedGammaTable = mglGetGammaTable;
stimulus.linearizedGammaTable.redTable(1:3) = 0; % this is just to provisionally deal with what appears to be some bug: the first value in each of these gamma tables is a NaN
stimulus.linearizedGammaTable.greenTable(1:3) = 0;
stimulus.linearizedGammaTable.blueTable(1:3) = 0;


stimulus.xpxpcm = myscreen.screenWidth/myscreen.displaySize(1);
stimulus.ypxpcm = myscreen.screenHeight/myscreen.displaySize(2);

stimulus.xpxpdeg = ceil(tan(2*pi/360)*myscreen.displayDistance*stimulus.xpxpcm);
stimulus.ypxpdeg = ceil(tan(2*pi/360)*myscreen.displayDistance*stimulus.ypxpcm);


stimulus.frameThick = .08;
stimulus.reservedColors = [0 0 0; 1 1 1; 0 .6 0];


stimulus.nReservedColors=size(stimulus.reservedColors,1);
stimulus.nGratingColors = 256-(2*floor(stimulus.nReservedColors/2)+1);
stimulus.minGratingColors = 2*floor(stimulus.nReservedColors/2)+1;
stimulus.midGratingColors = stimulus.minGratingColors+floor(stimulus.nGratingColors/2);
stimulus.maxGratingColors = 255;
stimulus.deltaGratingColors = floor(stimulus.nGratingColors/2);

stimulus.nDisplayContrasts = stimulus.deltaGratingColors;

% to set up color values

stimulus.black = [0 0 0];
stimulus.white = [255 255 255];
stimulus.green = [0 160 0];
stimulus.blue = [0 0 160];
stimulus.greencorrect = [0 200 20];
stimulus.redincorrect = [255 0 0];
stimulus.orangenoanswer = [255 215 0];
stimulus.grey = [.025 .025 .025];
stimulus.background = [stimulus.midGratingColors/255 stimulus.midGratingColors/255 stimulus.midGratingColors/255];
stimulus.fixation.color = [0; .6; 0]'; % green
stimulus.grayColor = stimulus.background;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stimulus parameters:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gabors
stimulus.width = 24;% bigger than filter size        % in deg
stimulus.height = 24;% bigger than filter size           % in deg
stimulus.sizeGrating = 24;%should be reset to 3degs

stimulus.rotation = [1,-1]; % this is the tilt orientation of the gabor stimulus from vertical in Degrees
stimulus.init = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_points = 9;
rect_width = 3;
cuts = (stimulus.sizeGrating/2)*linspace(0,1, num_points).^2;
cuts = sort([-cuts setdiff(cuts,0)]);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make stim texture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g = mglMakeGrating(stimulus.width,stimulus.width,stimulus.sf,0,0);
res = mkR([size(g,1) size(g,2)]);

numVals = size(g,1);
[Xtbl,Ytbl] = rcosFn2(numVals/40,stimulus.sizeGrating*16.5,[1,0],numVals);
alphaLayer =  255*pointOp(res, Ytbl, Xtbl(1), Xtbl(2)-Xtbl(1), 0);

scaleMTX = (size(g,1)/stimulus.sizeGrating);
rectWidthPIX = floor(scaleMTX*rect_width);
rectRng = cell(length(cuts),1);
for pos = 2:length(cuts)
    posIndex = pos-1;
    edge0 = floor((size(g,1)/2))+floor(scaleMTX*cuts(pos));
    if pos == 2
        rectRng{posIndex} = 1:edge0;
    elseif pos < length(cuts)
        rectRng{posIndex} = edge0-rectWidthPIX+1:edge0;
    else
        rectRng{posIndex} = size(g,1)-rectWidthPIX+1:size(g,1);
    end
end

contVect = [1,-1];%repmat([1,-1],[1,2]);
g4  = cell(length(cuts)-1,length(contVect),2);
g4b = cell(length(cuts)-1,length(contVect),2);
tex = cell(length(cuts)-1,length(contVect),2);

disppercent(-inf,'Calculating gabors');
for tt = 1:stimulus.numTrials
    for sweep = 1:2
        sweepDir = stimulus.dir(tt,sweep);
        if sweepDir <= 2, ori = 90;else ori = 0;end
        for pos = 1:(length(cuts)-1)
            posIndex=pos;
            ph = rand*360; stimulus.phase(tt,sweep,pos) = ph;
            for phaseCont = 1:length(contVect)
                g = mglMakeGrating(stimulus.sizeGrating,stimulus.sizeGrating,stimulus.sf,ori,ph).*contVect(phaseCont);
                g = 255*(g+1)/2;
%                 g(g<0)=0;
                g4{posIndex,phaseCont}(:,:,1) = g;
                g4{posIndex,phaseCont}(:,:,2) = g;
                g4{posIndex,phaseCont}(:,:,3) = g;
                g4{posIndex,phaseCont}(:,:,4) = alphaLayer;
                
                g4b{posIndex,phaseCont} = g4{posIndex,phaseCont};
                g4b{posIndex,phaseCont}(:,:,4) = g4{posIndex,phaseCont}(:,:,4).*0;
                
                if sweepDir <= 2 %right or left sweep
                    g4b{posIndex,phaseCont}(:,rectRng{posIndex},4) = g4{posIndex,phaseCont}(:,rectRng{posIndex},4);
                else                 %up or down sweep
                    g4b{posIndex,phaseCont}(rectRng{posIndex},:,4) = g4{posIndex,phaseCont}(rectRng{posIndex},:,4);
                end
                stimulus.tex{posIndex,phaseCont,sweep,tt} = mglCreateTexture(g4b{posIndex,phaseCont},[],1);
%                 mglBindTexture(stimulus.tex{posIndex,phaseCont,sweep,tt},g4b{posIndex,phaseCont});
            end
%             sprintf('Constructed texture %d of %d',pos,length(cuts))```
        end
    end
    disppercent((tt)/(stimulus.numTrials));
end




end