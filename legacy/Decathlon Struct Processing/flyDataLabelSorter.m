for i = 1:length(oflyData)
    flylabel = oflyData(i).ID;
    datIndex = find(cellfun(@(x)isequal(x, flylabel), {flyData.ID}))
    flyData(datIndex).circles = oflyData(i).circles
end
    