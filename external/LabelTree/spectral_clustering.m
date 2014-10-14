function idx = spectral_clustering(W, k)
    D = diag(sum(W));
    L = D-W ;
    [V , ~] = eigs( L ) ;
    V = V( : , end - 1 : end ) ;
%     disp( eigs(L) ) ;
%     disp( eigs(D) ) ;
%     opt = struct('issym', true, 'isreal', true);
%     [V , ~] = eigs(L, D, k, 'SM', opt);
    idx = kmeans(V, k);
end
