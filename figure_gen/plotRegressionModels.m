%%

poly_degrees = 3;

for i = 1:poly_degrees
    
    model_spec = sprintf('poly%i',i);
    lm = fitlm(cam_dist(filt),spd(filt),model_spec);
    
    rnd = rand(numel(spd),1)>0.98;
    s = spd(rnd);
    c = cam_dist(rnd);

    subplot(poly_degrees,2,(i-1)*2+1);
    opts = {'Marker'; 'o'; 'LineStyle'; 'none';...
        'MarkerFaceColor'; 'k'; 'MarkerEdgeColor'; 'none';...
        'MarkerSize'; 2; 'LineWidth'; 1};
    plot(c,s,'o',opts{:});

    f = @(x,c) arrayfun(@(a,i) a.*x.^i, c', 0:numel(c)-1, 'UniformOutput', false);
    y = f((0:800)',lm.Coefficients{:,1});
    y = nansum(cat(2,y{:}),2);
    hold on
    plot(0:800,y,'r');
    xlabel('cam center distance');
    ylabel('speed');
    title(sprintf('poly%i, R^{2}=%.2f',i,lm.Rsquared.Ordinary));
    set(gca,'YLim',[min(s) 2]);
    
    % plot residuals
    subplot(poly_degrees,2,(i-1)*2+2);
    y = f(c,lm.Coefficients{:,1});
    y = nansum(cat(2,y{:}),2);
    plot(c,s-y,opts{:});
    xlabel('cam center distance');
    ylabel('speed');
    title(sprintf('poly%i - residuals',i));
    %set(gca,'YLim',[min(s-y) max(s-y)]);
    set(gca,'YLim',[min(s-y) 0]);
    
end

%%
poly_degrees = 3;
figure;

for i = 1:poly_degrees
    
    model_spec = sprintf('poly%i',i);
    [coefs,mdl] = polyfit(cam_dist(filt),spd(filt),i);
    
    rnd = rand(numel(spd),1)>0.98;
    s = spd(rnd);
    c = cam_dist(rnd);

    subplot(poly_degrees,2,(i-1)*2+1);
    opts = {'Marker'; 'o'; 'LineStyle'; 'none';...
        'MarkerFaceColor'; 'k'; 'MarkerEdgeColor'; 'none';...
        'MarkerSize'; 1; 'LineWidth'; 1};
    plot(c,s,'o',opts{:});

    f = @(x,c) arrayfun(@(a,i) a.*x.^i, c', (0:numel(c)-1)', 'UniformOutput', false);
    y = f(0:800,fliplr(coefs));
    y = nansum(cat(1,y{:}),1);
    hold on
    plot(0:800,y,'r');
    xlabel('cam center distance');
    ylabel('speed');
    title(sprintf('poly%i',i));
    %set(gca,'YLim',[min(s) max(s)]+[-.15 .15].*(max(s)-min(s)));
    set(gca,'YLim',[min(s) 2]);
    
    % plot residuals
    subplot(poly_degrees,2,(i-1)*2+2);
    y = f(c,fliplr(coefs));
    y = nansum(cat(2,y{:}),2);
    plot(c,s-y,opts{:});
    xlabel('cam center distance');
    ylabel('speed');
    title(sprintf('poly%i - residuals',i));
    %set(gca,'YLim',[min(s-y) max(s-y)]+[-.15 .15].*(max(s-y)-min(s-y)));
    set(gca,'YLim',[min(s-y) 0]);
    
end
