function abnormal_points = abnormalAnalyze(x,window_size)
   
    window_size=size(x);
    window_mean = mean(x);
    window_std = std(x);
    threshold = window_mean + 2.5 * window_std;
    abnormal_points= x > threshold;


end