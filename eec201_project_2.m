% file = "Twelve_test1.wav";
file = 'GivenSpeech_Data/Training_Data/s4.wav';

[audio_in, fs] = audioread(file);

% Size of each frame in samples
frame_size = 256;
% How much overlap should there be between frames, in samples?
overlap_size = 85;
% What window should be used for each frame
window = hann(frame_size, "periodic");
% Number of coefficients to generate
num_mel_coeffs = 20;

% Split the audio signal into frames
[S, F, t] = stft(audio_in, "Window", window, "OverlapLength", overlap_size, ...
                     "FFTLength", frame_size, "FrequencyRange", "onesided");

% Take the magnitude of the frames
S = abs(S);

% Generate the mel-spaced filterbank
[filter_bank, cf] = designAuditoryFilterBank(fs, 'FFTLength', frame_size, ...
    'NumBands', num_mel_coeffs, "FrequencyRange", [0 fs/2]);

% Plot the mel-spaced filterbank
plot((F / pi) * (fs / 2), filter_bank.');
grid on;
title("Mel Filter Bank");
xlabel("Frequency (Hz)");

% Apply the filter bank to the frames to create the mel spectrogram
mel_spec = filter_bank * S;

% Generate cepstral coefficients with the mel spectrogram
melcc = cepstralCoefficients(mel_spec, "NumCoeffs", num_mel_coeffs);

% ------------------ BOILERPLATE LBG IMPLEMENTATION --------------------

% Little has been modified / optimized here from online resources, has not
% been sufficiently tested (may need to be reimplemented).

% Number of clusters (codevectors)
num_clusters = 20;

% Initialize codebook using random vectors from melcc
codebook = melcc(randperm(size(melcc, 1), num_clusters), :);

% Maximum number of iterations
max_iterations = 100;
epsilon = 1e-10; % Convergence threshold

for iter = 1:max_iterations
    % Vector quantization step: Assign each vector to the nearest centroid
    [~, assignments] = pdist2(codebook, melcc, 'euclidean', 'Smallest', 1);
    
    % Update centroids
    new_codebook = zeros(size(codebook));
    for i = 1:num_clusters
        cluster_indices = (assignments == i);
        if any(cluster_indices)
            new_codebook(i, :) = mean(melcc(cluster_indices, :), 1);
        else
            % If no vectors were assigned to this centroid, keep it unchanged
            new_codebook(i, :) = codebook(i, :);
        end
    end
    
    % Check for convergence
    if max(vecnorm(new_codebook - codebook, 2, 2)) < epsilon
        disp("Iterations: " + iter);
        break;
    end
    
    % Update codebook
    codebook = new_codebook;
end

% First dimension to plot
dim1_index = 5;
% Second dimension to plot
dim2_index = 6;

% Extract the specified dimensions from melcc
dimension1_values = melcc(:, dim1_index);
dimension2_values = melcc(:, dim2_index);

% Plot the intersection of the two dimensions
figure;
scatter(dimension1_values, dimension2_values, 'filled');
xlabel(['mfcc-', num2str(dim1_index)]);
ylabel(['mfcc-', num2str(dim2_index)]);

% Graph all codevectors at this intersection point
% hold on
% for i = 1:num_clusters
%     plot(codebook(i, dim1_index), codebook(i, dim2_index), 'xr', 'MarkerSize',20)
% end
% hold off
grid on;