function varargout = bootstrap_gravivac(data,nReps,active)

%% initialize parameters

data = data(:,active);
data(data<0) = 0;                           % shift from index to probability
nf = sum(active);                           % num flies
nc = sum(~isnan(data));                     % num choices each individual
p = nansum(data)./nc;                       % geotactic choice probability
p_all = repmat(sum(p.*nc)/sum(nc),1,nf);    % light choice probability for all the data

bs.sim=zeros(nReps,nf);

for i=1:nReps;
   
    % randomize num choices
    tmp_nc = nc(randi([1 nf],[1,nf]));
    bs.sim(i,:) = binornd(tmp_nc,p_all) ./ tmp_nc; 
    
end

bs.obs=p;

%% plot results

% create histogram of choice probabilities
binmin=0;
binmax=1;
w = binmax - binmin;
plt_res = w/(10^floor(log10(nf)));
binlabels = binmin:plt_res:binmax;
bs.bins = linspace(binmin-plt_res/2, binmax+plt_res/2, length(binlabels)+1);
c = histc(bs.sim,bs.bins) ./ repmat(sum(histc(bs.sim,bs.bins)),numel(bs.bins),1);
[bs.avg,~,bs.ci95,~] = normfit(c');


f=figure();
hold on

% plot bootstrapped trace
plot(bs.avg,'b','LineWidth',2);
set(gca,'Xtick',linspace(1,length(bs.avg),11),'XtickLabel',linspace(0,1,11),...
    'XLim',[1 length(bs.avg)],'YLim',[0 ceil(max(bs.ci95(:))*100)/100]);

% plot observed data
c = histc(bs.obs,bs.bins) ./ sum(sum(histc(bs.obs,bs.bins)));
plot(c,'r','LineWidth',2);
legend({['bootstrapped (nReps = ' num2str(nReps) ')'];'observed'});
title(['light choice probability histogram (obs v. bootstrapped)']);

% add confidence interval patch
vx = [1:length(bs.bins) fliplr(1:length(bs.bins))];
vy = [bs.ci95(1,:) fliplr(bs.ci95(2,:))];
ph = patch(vx,vy,[0 0.9 0.9],'FaceAlpha',0.3);
uistack(ph,'bottom');

for i=1:nargout
    switch i
        case 1, varargout{i} = bs;
        case 2, varargout{i} = f;
    end
end