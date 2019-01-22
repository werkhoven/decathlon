%%

load(['D:\Decathlon Raw Data\decathlon 2-2018\data\Assays\Optomotor\'...
    '02-09-2018-13-31-48__Optomotor_bk-iso-1_f_23C_337-384_Day4\'...
    '02-09-2018-13-31-48__Optomotor_bk-iso-1_f_23C_337-384_Day4.mat']);

%%
[v,p]=sort(expmt.Optomotor.n);
n = 4;
ids = p(numel(p):-1:numel(p)-n+1);
%ids = randperm(expmt.nTracks,n);
win_size = 1800;
down_smpl = find(mod(1:expmt.nFrames,10)==0);
down_smpl = down_smpl(numel(down_smpl)-win_size:end);
o=expmt.Orientation.data(down_smpl,ids);
o=[zeros(1,n);diff(o)];
o(o>90) = o(o>90)-180;
o(o<-90) = o(o<-90)+180;
%o = abs(o);
o(isnan(o)) = 0;
o = medfilt1(o,5,[],1);
t = cumsum(expmt.Time.data);
t = t./60;
t = t(down_smpl);
t = t-t(1);
tx = expmt.StimStatus.data(down_smpl,ids);
texture = expmt.Texture.data(down_smpl,ids);
trans = num2cell(diff(tx),1);
starts = cellfun(@(t) find(t==1), trans, 'UniformOutput', false);
stops = cellfun(@(t) find(t==-1), trans, 'UniformOutput', false);
d2 = [zeros(1,4); diff(o,1)];
y_range = (max(o(:))-min(o(:)));
x_tri = y_range*0.01*sin(2*pi/3);
x_tri = [-x_tri*0.1 0 x_tri*0.1];
y_tri = y_range*0.05*cos(2*pi/3);
y_tri = [-y_tri 0 -y_tri];

figure;
hold('on');
vx = cell(n,1);
vy = cell(n,1);
vtx = cell(n,1);
vx2 = cell(n,1);
vy2 = cell(n,1);
for k=1:n
    
    if numel(starts{k}) > numel(stops{k})
        starts{k}(end) = [];
    elseif numel(stops{k}) > numel(starts{k})
        stops{k}(1) = [];
    end
    
    tmp = arrayfun(@(i,j) [t(i) t(i) t(j) t(j) t(i)]', starts{k}-1, stops{k}+1, ...
        'UniformOutput', false);
    tmp_tx = texture(stops{k},k);
    vtx{k} = tmp_tx;
    pos_starts = starts{k}(tmp_tx);
    pos_stops = stops{k}(tmp_tx);
    pos_bouts = arrayfun(@(i,j) [t(i:j) o(i:j,k); NaN NaN], ...
        pos_starts, pos_stops,'UniformOutput', false);
    pos_bouts = cat(1,pos_bouts{:});
    neg_starts = starts{k}(~tmp_tx);
    neg_stops = stops{k}(~tmp_tx);
    neg_bouts = arrayfun(@(i,j) [t(i:j) o(i:j,k); NaN NaN], ...
        neg_starts, neg_stops,'UniformOutput', false);
    neg_bouts = cat(1,neg_bouts{:});

    tmp_xtri = arrayfun(@(i) t(i) + x_tri', starts{k},'UniformOutput', false);
    tmp_ytri = arrayfun(@(i) o(i,k)+y_range*0.2 + y_tri' + (k-1)*y_range,...
        starts{k},'UniformOutput', false);

    vx{k} = cat(2,tmp{:});
    yvec = (k-1)*y_range*1.2+([y_range -y_range -y_range y_range y_range].*0.53)';
    vy{k} = repmat(yvec, 1, numel(tmp));
    vx2{k} = cat(2,tmp_xtri{:});
    vy2{k} = cat(2,tmp_ytri{:});
    y = o(:,k)+y_range*(k-1)*1.2;
    z=zeros(size(t));
%     surface([t';t'],[y';y'],[z';z'],[o(:,k)';o(:,k)'],...
%         'facecol','no','edgecol','interp','linew',2);
    ti = linspace(t(1),t(end),numel(t)*5);
    yi = interp1(t,y,ti);
    ci = interp1(t,d2(:,k),ti);
    th=plot(ti,yi,'Color',[.3 .3 .3],'Linewidth',2);
%     plot(pos_bouts(:,1),pos_bouts(:,2)+y_range*(k-1),'Color','r','Linewidth',1.5);
%     plot(neg_bouts(:,1),neg_bouts(:,2)+y_range*(k-1),'Color','b','Linewidth',1.5);
	pause(.1);
    eh = th.Edge;
    eh.ColorType = 'truecoloralpha';
    cblend = interp1([1 256],[255 0 255 255; 0 255 0 255],[1 51 128 205 255]);
    trail_cdata= uint8(interp1([-100 -15 0 15 100],cblend,ci));
    set(eh,'ColorBinding','interpolated','ColorData',trail_cdata');
    shading flat;
    text(t(end)*1.01, (k-1)*y_range*1.2, ...
        sprintf('index = %.2f%',-expmt.Optomotor.index(ids(k))),...
        'HorizontalAlignment','left','VerticalAlignment', 'middle');

    
end
%
ntrials = cellfun(@(a) numel(a), starts);
vx = cat(2,vx{:});
vy = cat(2,vy{:});
vtx = cat(1,vtx{:});

vx2 = cat(2,vx2{:});
vy2 = cat(2,vy2{:});
colors = repmat([1 0 1], size(vx,2), 1);
colors(vtx,:) = repmat([0 1 0], sum(vtx), 1);

ph = patch('Faces',1:size(vx,2),...
    'XData',vx,'YData',vy,'FaceVertexCData',colors,'FaceColor','flat',...
    'EdgeColor','none','FaceAlpha',0.35);
uistack(ph,'down');
% ph = patch('Faces',1:size(vx2,2),...
%     'XData',vx2,'YData',vy2,'FaceColor',[0 0 0],...
%     'EdgeColor',[.3 .3 .3],'FaceAlpha',1);
xlabel('time (min)')
ylabel('angular velocity')
set(gca,'Ytick',[]);
% colormap(interp1([1 256],[1 0 0; 0 0 1],1:256))
