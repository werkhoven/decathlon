function [r, c] = temporalAnalysisAcrossDays(ft1, ft2)

% make option to calculate probability that two flies are on the same side
% of tunnel

runlen = 80; % number of frames to include in each sample
ct = 0;

% Un-comment, find and replace 'centroid' with 'orientation'
% for k = 1:ft1.nFlies
%     a = ft1.centroid(:,k);
%     ft1.centroid(a < 0,k) = 180 + a(a<0);
% end
%
% for k = 1:ft2.nFlies
%     a = ft2.centroid(:,k);
%     ft2.centroid(a < 0,k) = 180 + a(a<0);
% end

for k = 1:ft2.nFlies
    
    for kk = (k+1):ft2.nFlies
        
        ct = ct+1;
        
        for i = 1:200
            
            % first correlate matched trace samples
            % m = min([length(ft1.centroid) length(ft2.centroid)]);        % find the lower limit on length for the two days
            m = 3800;                                                      % limit analysis to pre-odor period
            rangeStart = randsample((m - runlen), 1);
            sampleRange = rangeStart:(rangeStart + runlen);                % take a behavioral snapshot that is RUNLEN long
            %tmp = corr(squeeze(ft1.centroid(sampleRange,[k kk])));
            
            if i <= 100
                tmp = corr(squeeze(ft1.centroid(sampleRange,2,[k kk])));   % Take half of samples from Day 1
                out(i) = tmp(2);
            else
                tmp = corr(squeeze(ft2.centroid(sampleRange,2,[k kk])));   % The other half from Day 2
                out(i) = tmp(2);
            end
            
            % then correlate non-overlapping trace samples as control
            %             tmp1 = squeeze(ft1.centroid(sampleRange,k));
            %             tmp2 = squeeze(ft2.centroid(sampleRange,k));
            tmp1 = squeeze(ft1.centroid(sampleRange,2,k));
            tmp2 = squeeze(ft2.centroid(sampleRange,2,k));
            
            outtmp = corr([tmp1 tmp2]);
            outr(i) = outtmp(2);
        end
        
        c(ct) = mean(out);
        r(ct) = mean(outr);
        
%         if c(ct) < -0.25
%             plot(squeeze(ft1.centroid(:,2,[k kk])))
%         end
        
        out = [];
        outr = [];
    end
end