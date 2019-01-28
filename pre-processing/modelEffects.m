function [S,linModels] = modelEffects(S,n,varargin)

TimeofDay = true;
for i=1:length(varargin)
    arg=varargin{i};
    if ischar(arg)
        switch arg
            case 'TimeofDay'
                i=i+1;
                TimeofDay = varargin{i};
        end
    end
end

catvars = {'Plate';'Box';'Tray'};
linModels = cell(n,5);
ct=0;
pct = 0;
warning('off','stats:LinearModel:RankDefDesignMat');

for i=1:length(S)
   
    if ~isempty(S(i).data)

        rf = fieldnames(S(i).data);
        rf(strcmp(rf,'filter'))=[];
    
        for j=1:length(rf)

            if mod(pct,24)==0
                figure;
            end
        
            ct=ct+1;
            pf = fieldnames(S(i).meta);
            varnames = [pf; rf(j)];
            vars = cellfun(@(x) S(i).meta.(x),pf,'UniformOutput',false);
            vars = [vars;S(i).data.(rf{j})];
            tbl = table(vars{:},'VariableNames',varnames);
            mdl = fitlm(tbl,'ResponseVar',rf{j},'PredictorVars',...
                pf,'CategoricalVar',catvars(cellfun(@(x) any(strcmp(x,pf)),catvars)));
            sigTerms = mdl.Coefficients{:,4} < 0.05;
            sigTerms(1) = false;

            % remove non-significant terms from model and re-run
            if any(sigTerms)

                sigFields = mdl.CoefficientNames(sigTerms);
                if ~TimeofDay
                    sigFields(strmatch('TimeofDay',sigFields))=[];
                    sigFields(strmatch('Day',sigFields))=[];
                end        
                pf = pf(cellfun(@(x) ~isempty(strmatch(x,sigFields)),pf));
                
                vars = cellfun(@(x) S(i).meta.(x),pf,'UniformOutput',false);
                vars = [vars;S(i).data.(rf{j})];
                varnames = [pf; rf(j)];
                tbl = table(vars{:},'VariableNames',varnames);
                mdl = fitlm(tbl,'ResponseVar',rf{j},'PredictorVars',...
                    pf,'CategoricalVar',catvars(cellfun(@(x) any(strcmp(x,pf)),catvars)));
                
                if ~isempty(pf)

                    label = rf{j};
                    label(label=='_')=' ';
                    pd = makedist('Normal','mu',0,'sigma',0.08);
                    xx = repmat(random(pd,1,numel(vars{1})), 1, 1);
                    opts = {'Marker'; 'o'; 'LineStyle'; 'none';...
                        'MarkerFaceColor'; 'k'; 'MarkerEdgeColor'; 'none';...
                        'MarkerSize'; 3; 'LineWidth'; 1};
                    
                    
                    subplot(4,6,mod(pct,24)+1);
                    pct = pct+1;
                    if iscell(vars{1})
                        p = cellfun(@(v) find(strcmp(unique(vars{1}),v)), vars{1});
                    else
                        p = vars{1};
                    end
                    plot(p+xx',S(i).data.(rf{j}),opts{:});
                    xlabel(pf);
                    ylabel(label);
                    title(S(i).name);
                    set(gca,'XLim',[0 numel(unique(p))+1],...
                        'XTick',unique(p),'XTickLabel',unique(vars{1})); 
                    
                    
                    subplot(4,6,mod(pct,24)+1);
                    pct = pct+1;
                    plot(p+xx',mdl.Residuals.Raw,opts{:});
                    xlabel(pf);
                    ylabel(label);
                    title(S(i).name);
                    set(gca,'XLim',[0 numel(unique(p))+1],...
                        'XTick',unique(p),'XTickLabel',unique(vars{1})); 
                end

                linModels(ct,1) = {[S(i).name '-' rf{j}]};
                linModels(ct,2) = {mdl.CoefficientNames};
                linModels(ct,3) = {mdl.Coefficients{:,1}};
                linModels(ct,4) = {mdl.Coefficients{:,4}};
                linModels(ct,5) = {S(i).data.(rf{j})};

                S(i).data.(rf{j}) = mdl.Residuals.Raw;
            end

        end
    
    end
    
end