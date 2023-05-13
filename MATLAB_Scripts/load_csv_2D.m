function [x_ppm, y_ppm, matrix] = load_csv_2D(fpath)

temp = dlmread(fpath);
x_ppm = temp(1, 1:end-1);
y_ppm = temp(2:end, 1);
matrix = temp(2:end, 2:end);

