            
sizeGrating = 4;
sdGauss = sizeGrating/7;



mglOpen(2);
            mglVisualAngleCoordinates(57,[16 12]);
            mglClearScreen(0.5);
            g = mglMakeGrating(sizeGrating,sizeGrating,1.5,90,0);
            g = 255*(g+1)/2;
            g4(:,:,1) = g;
            g4(:,:,2) = g;
            g4(:,:,3) = g;
            g4(:,:,4) = 128;
            tex = mglCreateTexture(g4,[],1);
 
            mglBltTexture(tex,[-5 0 sizeGrating sizeGrating]);
             mglBindTexture(tex,255);
             mglBltTexture(tex,[5 0 sizeGrating sizeGrating]);
             mglFlush;


mglClearScreen;
             
             
            g = round(255*mglMakeGaussian(sizeGrating,sizeGrating,sdGauss,sdGauss,0,0));
            
            mglBindTexture(tex,g);
            mglBltTexture(tex,[0 0 sizeGrating sizeGrating],0,0);
            mglFlush
            
%%
sizeGrating = 4;
sdGauss = sizeGrating/20;

mglOpen(2);
            mglVisualAngleCoordinates(57,[16 12]);
            mglClearScreen(.5);
            g = mglMakeGrating(sizeGrating,sizeGrating,1.5,90,0);
            g = 255*(g+1)/2;
            g4(:,:,1) = g;
            g4(:,:,2) = g;
            g4(:,:,3) = g;
            g4(:,:,4) = round(255*mglMakeGaussian(sizeGrating,sizeGrating,sdGauss,sdGauss));
            
            tex = mglCreateTexture(g4,[],1);
            mglBindTexture(tex,g4);
            
            
            mglBltTexture(tex,[0 0 sizeGrating sizeGrating]);
            mglFlush
            
            
            
            
%%

sizeGrating = 20;
% sdGauss = sizeGrating/20;


mglOpen(2);
            mglVisualAngleCoordinates(57,[16 12]);
% mglGetScreenParams;
            mglClearScreen(.5);
            g = mglMakeGrating(sizeGrating,sizeGrating,1.5,90,0);
            g = 255*(g+1)/2;
            g4(:,:,1) = g;
            g4(:,:,2) = g;
            g4(:,:,3) = g;
            
            numVals = size(g,1);
            [Xtbl,Ytbl] = rcosFn2(sizeGrating/10,sizeGrating*17,[1,0],numVals);
            res = mkR([size(g,1) size(g,2)]);

            g4(:,:,4) = 255*pointOp(res, Ytbl, Xtbl(1), Xtbl(2)-Xtbl(1), 0);
            
            tex = mglCreateTexture(g4,[],1);
%             mglBindTexture(tex,g4);
            
            
            mglBltTexture(tex,[0 0 sizeGrating sizeGrating]);
            mglFlush

