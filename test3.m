% Load the audio file
[x, fs] = audioread('Twelve_test1.wav');

% Set parameters
frame_sizes = [128, 256, 512];
frame_increments = round(frame_sizes / 3);

N = 256; % Frame size
M = round(256 / 3); % Frame increment
window = hamming(N);

% Compute STFT
[S, F, T] = stft(x, fs, "Window", window, "OverlapLength", N-M, ...
        "FrequencyRange", "onesided");

% Compute Mel filterbank
numFilters = 20; % Number of Mel filters
melFilters = melfb(numFilters, N, fs);

% Apply Mel filterbank to the spectrum
melSpectrum = melFilters * abs(S);

% Plot Mel filterbank responses
figure;
for i = 1:numFilters
    plot(F, melFilters(i,:));
    hold on;
end
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Mel-spaced Filterbank Responses');
hold off;

% Plot spectrum before and after Mel frequency wrapping
figure;
subplot(2,1,1);
imagesc(T, F, log(abs(S)));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrum of Speech File (Before Mel Wrapping)');
colorbar;

subplot(2,1,2);
imagesc(T, 1:numFilters, log(melSpectrum));
axis xy;
xlabel('Time (s)');
ylabel('Mel Filter Index');
title('Spectrum of Speech File (After Mel Wrapping)');
colorbar;


