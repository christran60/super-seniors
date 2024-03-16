[x, fs] = audioread('Twelve_test1.wav');

% Number of samples in a block
block_size = 256;

overlap_size = 85;

% Compute the duration of speech in milliseconds in a block of 256 samples
duration_ms = (block_size / fs) * 1000;
disp(['Duration of speech in a block of 256 samples: ', num2str(duration_ms), ' ms']);

t = (0:length(x)-1) / fs; 
figure;
plot(t, x);
xlabel('Time (s)');
ylabel('Amplitude');
title('Speech Signal in Time Domain');

x_normalized = x / max(abs(x)); 

figure;
plot(t, x_normalized);
xlabel('Time (s)');
ylabel('Amplitude');
title('Normalized Speech Signal in Time Domain');
