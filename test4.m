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

% Apply cepstrum by using DCT
cepstrum = dct(melSpectrum);
