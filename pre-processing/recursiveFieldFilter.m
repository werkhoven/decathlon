function output = recursiveFieldFilter(input,dim_filter)

    % if input is struct, recursively search each field for data of size
    % dim_size
    if isstruct(input)
        
        all_fields = fieldnames(input);
        
        for i=1:length(all_fields)
            input.(all_fields{i}) = recursiveFieldFilter(input.(all_fields{i}),dim_filter);
            if strcmp(all_fields{i},'dim')
                input.dim(input.dim==length(dim_filter))=sum(dim_filter);
            end
                
        end
    else

        sz = size(input);
        dims = 1:ndims(input);
        filter_dim = find(sz==length(dim_filter));
        
        if ~isempty(filter_dim) && ~istable(input)
            
            dims(dims==filter_dim)=[];
            permVec = [filter_dim dims];
            [~,unpermVec] = sort(permVec);
            perm_data = permute(input,permVec);

            switch ndims(perm_data)
                case 1
                    perm_data=perm_data(dim_filter);
                case 2
                    perm_data=perm_data(dim_filter,:);
                case 3
                    perm_data=perm_data(dim_filter,:,:);
                case 4
                    perm_data=perm_data(dim_filter,:,:,:);
            end

            input = permute(perm_data,unpermVec);
            
        elseif ~isempty(filter_dim) && istable(input)
            switch filter_dim
                case 1
                    input = input(dim_filter,:);
                case 2
                    input = input(:,dim_filter);
            end
        end
        
    end
    
    output = input;

end