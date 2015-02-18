num_points = 9;
max_r = 12;
bar_width= .25*max_r;
[x,y] = meshgrid(linspace(-max_r,max_r, 401), linspace(-max_r,max_r, 401));
circular_aperture = x.^2+y.^2<max_r^2;
cpd = 1;
% cuts = [0.3, 0.7, 1.3, 2.3, 3.6, 5.5, 8.2] ;
% cuts = logspace(log10(0.1), log10(max_r), num_points);
cuts = max_r*linspace(0,1, num_points).^2;
cuts = sort([-cuts setdiff(cuts,0)]);

figure(1), clf
temporal_mod = sin(linspace(0,1,24)*2*pi);
h = fspecial('gaussian', 10, 5);

for iter = 1:10
    for pos = 1:length(cuts)
        ph = rand*2*pi;
        carrier = sin(x*2*pi*cpd+ph);
        bar_aperture = x < cuts(pos) & x > cuts(pos) - bar_width;
        stim_aperture = double(bar_aperture .* circular_aperture);
        stim_aperture = conv2(stim_aperture, h, 'same');
        stim = carrier .* stim_aperture;
        
        for frame = 1:24
            imagesc([-1 1]*max_r, [-1 1]*max_r, stim*temporal_mod(frame), [-1 1]);colormap gray
            xx = cuts(pos);
            X = xx + [-3 0 0 -3];
            %     Y = [-12 -12 12 12];
            %     fill(X,Y,'r');
            title(pos)
            set(gca, 'XTick', cuts, 'XGrid', 'on', 'XTickLabel', [], 'YTickLabel', [])
            axis([-1 1 -1 1]*12), axis square
            pause(0.01);
        end
        %
    end
    
end