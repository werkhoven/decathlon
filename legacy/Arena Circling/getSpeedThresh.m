function out=getSpeedThresh(cData,speed)

parameter_lb=linspace(0.5,3,20);
parameter_ub=linspace(15,30,5);
direction=[cData(:).direction];
direction=direction(:);
r_values=NaN(length(parameter_lb),length(parameter_ub));
linspeed=tmp_speed(:);

for i=1:length(parameter_lb)
    tic
    for j=1:length(parameter_ub)
    tmp_spd=(linspeed>parameter_lb(i) & linspeed<parameter_ub(j));
    d1=direction(tmp_spd);
    d2=direction(tmp_spd);
    if ~isempty(d1) & ~isempty(d2)
    d1(end)=[];
    d2(1)=[];
    [corrMat,p_values]=corrcoef([d1 d2],'rows','pairwise');
    r_values(i,j)=corrMat(1,2);
    end
    clearvars -except linspeed parameter_lb parameter_ub r_values direction cData tmp_speed cenID motorID centroid i j
    end
    disp([num2str((length(parameter_lb)-i)*toc/60) ' estimated min remaining']);
end

[v,j]=max(r_values);
speedThresh=parameter_bins(j);