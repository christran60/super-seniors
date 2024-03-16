% Load the audio file
[x, fs] = audioread('Twelve_test1.wav');

% Set parameters
frame_sizes = [128, 256, 512];
frame_increments = round(frame_sizes / 3);

% Initialize variables to store results
max_energy = -Inf;
max_energy_index = zeros(1, 2);

% Iterate over frame sizes
for i = 1:length(frame_sizes)
    N = frame_sizes(i); % Frame size
    M = frame_increments(i); % Frame increment
    window = hamming(N);

    % Compute STFT
    [S, F, T] = stft(x, fs, "Window", window, "OverlapLength", N-M, ...
        "FrequencyRange", "onesided");
 % [S, F, T] = spectrogram(x, hamming(N), N-M, N, fs);


    % Compute power spectral density
    PSD = abs(S).^2;

    % Find the region with the most energy
    [max_energy_frame, max_energy_frame_index] = max(PSD(:));
    [max_energy_freq_index, max_energy_time_index] = ind2sub(size(PSD), max_energy_frame_index);

    % Update max energy if necessary
    if max_energy_frame > max_energy
        max_energy = max_energy_frame;
        max_energy_index = [max_energy_time_index, max_energy_freq_index];
    end

    figure;
    surf(T*1000, F, 10*log10(PSD), 'EdgeColor', 'none');
    axis xy;
    xlabel('Time (ms)');
    ylabel('Frequency (Hz)');
    title(['Spectrogram with Frame Size = ', num2str(N)]);
    colormap jet;
    colorbar;
end

% Display the region with the most energy
disp(['Region with most energy: Time = ', num2str(T(max_energy_index(1))*1000), ' ms, Frequency = ', num2str(F(max_energy_index(2))), ' Hz']);
