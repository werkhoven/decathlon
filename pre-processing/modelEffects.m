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
warning('off','stats:LinearModel:RankDefDesignMat');

for i=1:length(S)
    
    if ~isempty(S(i).data)
    rf = fieldnames(S(i).data);
    rf(strcmp(rf,'filter'))=[];
    
    for j=1:length(rf)
        
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
            end        
            pf = pf(cellfun(@(x) ~isempty(strmatch(x,sigFields)),pf));
            vars = cellfun(@(x) S(i).meta.(x),pf,'UniformOutput',false);
            vars = [vars;S(i).data.(rf{j})];
            varnames = [pf; rf(j)];
            tbl = table(vars{:},'VariableNames',varnames);
            mdl = fitlm(tbl,'ResponseVar',rf{j},'PredictorVars',...
                pf,'CategoricalVar',catvars(cellfun(@(x) any(strcmp(x,pf)),catvars)));
            
            linModels(ct,1) = {[S(i).name '-' rf{j}]};
            linModels(ct,2) = {mdl.CoefficientNames};
            linModels(ct,3) = {mdl.Coefficients{:,1}};
            linModels(ct,4) = {mdl.Coefficients{:,4}};
            linModels(ct,5) = {mdl.Residuals.Raw};
            
            S(i).data.(rf{j}) = mdl.Residuals.Raw;
        end
        
    end
    
    end
            
    
    
end