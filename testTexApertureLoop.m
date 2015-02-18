
sizeGrating = 24;
sdGauss = sizeGrating/10;

sf = 1.5;

mglOpen(2);
mglVisualAngleCoordinates(57,[37.51 30.18]);
mglClearScreen(.5);

num_points = 8;
rect_width = 3;
cuts = (sizeGrating/2)*linspace(0,1, num_points).^2;
cuts = sort([-cuts setdiff(cuts,0)]);

ori = 0;
dir = 1;
hz = 10;

contVect = [1,-1,1,-1];
for pos = 2:length(cuts)
    ph = rand*360;
    
    g = mglMakeGrating(sizeGrating,sizeGrating,sf,ori,ph);
    g = 255*(g+1)/2;
    g4(:,:,1) = g;
    g4(:,:,2) = g;
    g4(:,:,3) = g;
    
    numVals = size(g,2);
    [Xtbl,Ytbl] = rcosFn2(numVals/30,sizeGrating*17,[1,0],numVals);
    res = mkR([size(g,1) size(g,2)]);
    
    g4(:,:,4) = 255*pointOp(res, Ytbl, Xtbl(1), Xtbl(2)-Xtbl(1), 0);
    
    g4b = g4;
    g4b(:,:,4) = zeros(size(g4,1),size(g4,2));
    
    scaleMTX = (size(g,1)/sizeGrating);
    
        mglClearScreen(.5);
        if ori == 90
            if dir > 0
                edge0 = round((size(g,1)/2))+floor(scaleMTX*cuts(pos));
                if pos == 2
                    xRng = 1:edge0;
                elseif pos < length(cuts)
                    xRng = edge0-round(scaleMTX*rect_width):edge0;
                else
                    xRng = size(g,1)-round(scaleMTX*rect_width):size(g,1);
                end
            else
                cuts = sort(cuts,2,'descend');
                edge0 = round((size(g,1)/2))+floor(scaleMTX*cuts(pos));
                if pos == 2
                    xRng = edge0:size(g,1);
                elseif pos < length(cuts)
                    xRng = edge0:edge0+floor(scaleMTX*rect_width);
                else
                    xRng = 1:round(scaleMTX*rect_width);
                end
            end
            g4b(:,xRng,4) = g4(:,xRng,4);
            
        else
            if dir > 0
                edge0 = round((size(g,1)/2))+floor(scaleMTX*cuts(pos));
                if pos == 2
                    yRng = 1:edge0;
                elseif pos < length(cuts)
                    yRng = edge0-round(scaleMTX*rect_width):edge0;
                else
                    yRng = size(g,1)-round(scaleMTX*rect_width):size(g,1);
                end
            else
                cuts = sort(cuts,2,'descend');
                
                edge0 = round((size(g,1)/2))+floor(scaleMTX*cuts(pos));
                if pos == 2
                    yRng = edge0:size(g,1);
                elseif pos < length(cuts)
                    yRng = edge0:edge0+floor(scaleMTX*rect_width);
                else
                    yRng = 1:floor(scaleMTX*rect_width);
                end
            end
            g4b(yRng,:,4) = g4(yRng,:,4);
        end
        
        tex = mglCreateTexture(g4b,[],1);
        mglBindTexture(tex,g4b);
        mglBltTexture(tex,[0 0 sizeGrating sizeGrating]);
        mglFlush
        pause(.1)
end