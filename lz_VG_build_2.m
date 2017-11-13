%%%% 12/27/2015 build multi-layer visibility graph based on multivariate
%%%% time-series

%%%% ts: multivariate time-series, with dimension of (time point, n) X (channel, m) 
%%%% VG: n X n X m

function VG = lz_VG_build_2(ts)

[n, m] = size(ts);

% initiate VG
VG = ones(n,n,m);

for vi = 1:m  % loop for variables
    
    for timei = 1:n-1 % loop for time index i
        VG(timei, timei, vi)   = 0; % self connection should be excluded
        VG(timei, timei+1, vi) = 1; % neigbhore points are always connected.
        
        for timej = timei+2: n % loop for time index j
            
            if ts(timei,vi) < ts(timej,vi) % for the case value at time point i being less than that at time point j
                for timek = timei+1 : timej-1
                    if ts(timek,vi) >= ts(timei,vi) + ( ts(timej,vi)-ts(timei,vi) ) * (timek - timei) / (timej - timei)
                        VG(timei, timej, vi) = 0;
                    end
                end
            else
                for timek = timei+1 : timej-1
                    if ts(timek,vi) >= ts(timej,vi) + ( ts(timei,vi)-ts(timej,vi) ) * (timej - timek) / (timej - timei)
                        VG(timei, timej, vi) = 0;
                    end
                end
            end
        
            VG(timej, timei, vi) = VG(timei, timej, vi); % mirror by diognose
        end % end for time index j
        
    end % end for time index i
    
    VG(n, n, vi) = 0;
    
end % end for variables
        
        
        
                