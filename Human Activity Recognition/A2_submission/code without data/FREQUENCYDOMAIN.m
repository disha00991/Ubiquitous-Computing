classdef FREQUENCYDOMAIN
    methods(Static)    
        
        function [energyVal, freqs] = extractFFT(x)
                    fs = 32; % We have to assume that this is the sampling rate for this assignment: 32Hz
                    FFTLen = 1024; % Length of FFT
                    y1 = abs(fft(x,FFTLen));
                    y1 = y1(1:FFTLen/2+1); 
                    y1(2:end) = y1(2:end)*2;    
                    energyVal = y1.';
                    freqs = [0:FFTLen/2]*fs/FFTLen;
        end
        
        function specCentroid = findSpectralCentroid(energyVal, freqs)
                   specCentroid = sum(energyVal.*freqs)/sum(energyVal);
        end    
        
        function [energy_low_band, energy_high_band] = filterBank(energyVal, freqs)
                    energy_low_band = sum(energyVal(1:floor(length(freqs)/2)));
                    energy_high_band = sum(energyVal(floor(length(freqs)/2)+1:end));
        end
        
        function specSpread = findSpectralSpread(energyVal, freqs)
                    mu = mean(freqs);
                    % Got this formula here: https://bit.ly/3K2azNo
                    specSpread = sqrt(sum(energyVal.*((freqs - mu).*(freqs - mu)))/sum(energyVal));
        end
            
        function specRollOffPoint = findSpectralRolloffPoint(energyVal, freqs, energy_percent)
                totalEnergy = sum(energyVal);
                rollOffEnergy = energy_percent * totalEnergy;
                energy_accumulated = 0;
                for j=1:length(freqs)
                    energy_accumulated = energy_accumulated + energyVal(j);
                    if (energy_accumulated > rollOffEnergy)
                        break;
                    end
                end
                specRollOffPoint = freqs(j-1);
        end

    end
end