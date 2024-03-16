% Apply FIR notch filter
fs = 44100;
cutoff = 200 / (fs/2);
bw = 100 / (fs/2);
[b, a] = iirnotch(cutoff, bw);
fvtool(b, a);