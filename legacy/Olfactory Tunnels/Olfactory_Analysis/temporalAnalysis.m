runlen = 640; % number of frames to include in each sample
ct = 0;

for k = 1:flyTracks.nFlies
    
    for kk = (k+1):flyTracks.nFlies
        
        ct = ct+1;
        
        for i = 1:100
            
            % first correlate matched trace samples
            rangeStart = randsample((length(flyTracks.centroid) - runlen), 1);
            sampleRange = rangeStart:(rangeStart+runlen);
            tmp = corr(squeeze(flyTracks.centroid(sampleRange,2,[k kk])));
            out(i) = tmp(2);
            
            % then correlate non-overlapping trace samples as control
            tmp1 = squeeze(flyTracks.centroid(sampleRange,2,k));
            
            rangeStart = randsample((length(flyTracks.centroid) - runlen), 1);
            sampleRange = rangeStart:(rangeStart+runlen);
            
            tmp2 = squeeze(flyTracks.centroid(sampleRange,2,kk));
%             
%             tmp2 = squeeze(flyTracks.centroid(:,2,kk));
%             pop = 1:(length(tmp2)-runlen);
%             
%             if rangeStart <= runlen
%                 lowerLim = 1;
%             else
%                 lowerLim = rangeStart-runlen;
%             end
%             
%             if (rangeStart+runlen) >= length(pop)
%                 upperLim = length(pop);
%             else
%                 upperLim = rangeStart+runlen;
%             end
%             
%             pop(lowerLim:upperLim) = [];
%             
%             rangeStart = randsample(pop, 1);
%             sampleRange = rangeStart:(rangeStart+runlen);
%             tmp2 = tmp2(sampleRange);
            
            outtmp = corr([tmp1 tmp2]);
            outr(i) = outtmp(2);
        end
        
        c(ct) = mean(out);
        r(ct) = mean(outr);
        
        out = [];
        outr = [];
    end
end