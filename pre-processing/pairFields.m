function [r,p] = pairFields(A,B,varargin)

trim=false;
titlestr='';
doplot = true;
for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Trim'
                i=i+1;
                trim = varargin{i};
            case 'Title'
                i=i+1;
                titlestr = varargin{i};
            case 'Plot'
                i=i+1;
                doplot = varargin{i};
        end
    end
end

% get the field names of each datase
f1 = A.fields;
f2 = B.fields;

if trim
    % remove day of testing information from non-circadian measures
    af1 = find(cellfun(@isempty,strfind(f1,'Circadian')));
    trimmed = cellfun(@(x,y) x(1:y-2),f1(af1),strfind(f1(af1),'('),'UniformOutput',false);
    f1(af1(~cellfun(@isempty,trimmed))) = trimmed(~cellfun(@isempty,trimmed));
    af2 = find(cellfun(@isempty,strfind(f2,'Circadian')));
    trimmed = cellfun(@(x,y) x(1:y-2),f2(af2),strfind(f2(af2),'('),'UniformOutput',false);
    f2(af2(~cellfun(@isempty,trimmed))) = trimmed(~cellfun(@isempty,trimmed));
end

% get mapping between datasets A and B
permutation = cellfun(@(x) find(strcmp(x,f2(:))),f1,'UniformOutput',false);
idxA = 1:length(f1);
idxA(cellfun(@isempty,permutation))=[];
permutation(cellfun(@isempty,permutation))=[];
permutation = cat(1,permutation{:});

% permute data and fields
A.data = A.data(:,idxA);
A.fields = f1(idxA);
B.data = B.data(:,permutation);
B.fields = f2(permutation);

% compute correlation matrix
[A.r,A.p] = corrcoef(A.data,'rows','pairwise');
[B.r,B.p] = corrcoef(B.data,'rows','pairwise');
L=1:length(A.r);
subset = arrayfun(@(x) [L(L<x)' repmat(x,sum(L<x),1)],L,'UniformOutput',false);
subset = cat(1,subset{:});
subset = sub2ind(size(A.r),subset(:,1),subset(:,2));

% calculate correlation of r-values
[r,p] = corrcoef([A.r(subset),B.r(subset)],'rows','pairwise');

if doplot
    ah=gca;
    scatter(ah,A.r(subset),B.r(subset),'o','MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[.6 .6 .6],'LineWidth',1.5);
    disp(['r=' num2str(r(1,2)) ' (p=' num2str(p(1,2)) ')']);
    xlabel('r-value (dataset 1)');
    ylabel('r-value (dataset 2)');
    set(ah,'XLim',[-1 1],'YLim',[-1 1],'XTick',-1:0.5:1,'YTick',-1:0.5:1);
    text(ah,ah.XLim(1)+diff(ah.XLim)*0.075,ah.YLim(2)-diff(ah.YLim)*0.075,...
        ['r=' num2str(r(1,2),2) ' (p=' num2str(p(1,2),2) ')']);
    title(titlestr);
end

