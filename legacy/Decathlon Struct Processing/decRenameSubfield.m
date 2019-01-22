function out=decRenameSubfield(data_struct,parent_field,old_field_name,new_field_name)

numFlies=length(data_struct);

for i=1:numFlies
    
    tempStruct=data_struct(i).(parent_field);
    subfields=fieldnames(tempStruct);
    
    for j=1:length(subfields);
        
        if strcmp(subfields{j},old_field_name)==1
            tempStruct.(new_field_name)=tempStruct.(old_field_name);
            tempStruct=rmfield(tempStruct,old_field_name);
        end
    end
    
    data_struct(i).(parent_field)=tempStruct;
    
end

out=data_struct;