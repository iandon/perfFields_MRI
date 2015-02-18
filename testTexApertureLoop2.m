function [] = testTexApertureLoop2(sizeAperture,sfInput,ori,dir)
sizeGrating = sizeAperture;

sf = sfInput;

mglOpen(2);
mglVisualAngleCoordinates(57,[37.51 30.18]);
mglClearScreen(.5);

if dir < 0
    if ori == 90
        mglHFlip
    else
        mglVFlip
    end
end

num_points = 9;
rect_width = 3;
cuts = (sizeGrating/2)*linspace(0,1, num_points).^2;
cuts = sort([-cuts setdiff(cuts,0)]);

% ori = 0;
% dir = 1;
hz = 10;


% contVect = cos(7*2*pi*(0:.1:1));
g = mglMakeGrating(sizeGrating,sizeGrating,sf,ori,0);
res = mkR([size(g,1) size(g,2)]);


numVals = size(g,2);
[Xtbl,Ytbl] = rcosFn2(numVals/40,sizeGrating*16.5,[1,0],numVals);
alphaLayer =  255*pointOp(res, Ytbl, Xtbl(1), Xtbl(2)-Xtbl(1), 0);

scaleMTX = (size(g,1)/sizeGrating);
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
g4  = cell(length(cuts)-1,length(contVect));
g4b = cell(length(cuts)-1,length(contVect));
tex = cell(length(cuts)-1,length(contVect));

disppercent(-inf,'Calculating gabors');
for pos = 2:length(cuts)
    ph = rand*360;
    posIndex = pos-1;
    for flicker = 1:length(contVect)
        g = mglMakeGrating(sizeGrating,sizeGrating,sf,ori,ph).*contVect(flicker);
        g = 255*(g+1)/2;
        g4{posIndex,flicker}(:,:,1) = g;
        g4{posIndex,flicker}(:,:,2) = g;
        g4{posIndex,flicker}(:,:,3) = g;
        g4{posIndex,flicker}(:,:,4) = alphaLayer;
        
        g4b{posIndex,flicker} = g4{posIndex,flicker};
        g4b{posIndex,flicker}(:,:,4) = g4{posIndex,flicker}(:,:,4).*0;
     
        if ori == 90
            g4b{posIndex,flicker}(:,rectRng{posIndex},4) = g4{posIndex,flicker}(:,rectRng{posIndex},4);
        else
            g4b{posIndex,flicker}(rectRng{posIndex},:,4) = g4{posIndex,flicker}(rectRng{posIndex},:,4);
        end
        tex{posIndex,flicker} = mglCreateTexture(g4b{posIndex,flicker},[],1);
        mglBindTexture(tex{posIndex,flicker},g4b{posIndex,flicker});
    end
    sprintf('Constructed texture %d of %d',pos-1,length(cuts)-1)
    disppercent((pos-1)/(length(cuts)-1));
end


reps = 7;
contVectORD = repmat([1,2],[1,reps]);
startDisp = tic;
for pos = 1:length(cuts)-1
    for flicker = 1:length(contVectORD)
        mglClearScreen(.5);
        mglBltTexture(tex{pos,contVectORD(flicker)},[0 0 sizeGrating sizeGrating]);
        mglFlush
        pause(.1)
    end
end
doneDisp = toc(startDisp)
end