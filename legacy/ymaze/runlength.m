function out=runlength(BinaryVector,num)

% Make sure BinaryVector is a column vector

if size(BinaryVector,2) > 1
    BinaryVector = transpose(BinaryVector);
end

if num == 0
    
    % Augment binary vector
    BinaryVector = [1;BinaryVector;1];
    out = find(diff(BinaryVector)==1)-find(diff(BinaryVector)==-1);
    
elseif num == 1
    
    %Augment binary vector
    BinaryVector = [0;BinaryVector;0];
    out = find(diff(BinaryVector)==-1)-find(diff(BinaryVector)==1);
    
else
    error('Input "num" must be 0 or 1')
end

end