function fid = Mean_zero_spectrum(fid)
if length(fid) == 1
    return
end
[counts,centers] = hist(fid, 1000);
[~, index] = max(counts);
Mean = centers(index);
fid = fid-Mean;

