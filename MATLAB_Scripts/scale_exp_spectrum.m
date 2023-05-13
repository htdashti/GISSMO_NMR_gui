function scale_exp_spectrum(src, eventdata)
YLIM = src.CurrentAxes.YLim;
if eventdata.VerticalScrollCount < 0
    axes(src.CurrentAxes)
    %fprintf('[%.03f, %.03f]->[%.03f, %.03f]\n', YLIM(1), YLIM(2), YLIM(1), .8*YLIM(2))
    ylim([.8*YLIM(1) .8*YLIM(2)])
else
    axes(src.CurrentAxes)
    %fprintf('[%.03f, %.03f]->[%.03f, %.03f]\n', YLIM(1), YLIM(2), YLIM(1), .8*YLIM(2))
    ylim([1.2*YLIM(1) 1.2*YLIM(2)])
end
