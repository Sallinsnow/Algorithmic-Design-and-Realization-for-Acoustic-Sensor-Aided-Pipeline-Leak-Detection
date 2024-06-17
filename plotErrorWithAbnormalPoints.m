function plotErrorWithAbnormalPoints(e2, abnormal_points)
    global width height;    
    figure(2);set(gcf, 'Position', [100 + width + 20, 100, width, height]);
    plot(e2);
    hold on;
    plot(find(abnormal_points), e2(abnormal_points), 'ro', 'MarkerSize', 10);
    title('Absolute Error with Abnormal Points');
    xlabel('Time');
    ylabel('Absolute Error');
    legend('Absolute Error', 'Abnormal Points');
end