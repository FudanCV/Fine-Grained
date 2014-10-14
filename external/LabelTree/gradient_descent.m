function [ w , b ] = gradient_descent( feature , label , tree )
% 
% Input
%       feature[N*D] - N feature vector with D dimension
%       label[N*1] - Label vector with N rows
%       tree[struct] - Label Tree structure
%
% Output
%       w[M*D] - M parameters vector for each tree node
%                (M is node count)
%
eta =   0.1 ;
gamma = 0.001 ;

w = zeros( tree.node_count , tree.feature_dimension ) ;
b = zeros( tree.node_count , 1 ) ;
[ n , d ] = size( feature ) ;
if ( d ~= tree.feature_dimension )
    error( 'vector demension not matching' ) ;
end

% Start Iteration
tic ;
for iter_perm = 1 : 5
    disp( [ 'gradient descent: ' , num2str(iter_perm) ] ) ;
    perm = randperm( n ) ;
%     perm = 1 : n ;
    batch_size = 1 ;
    r = zeros( n , 1 ) ;
    s = zeros( n , 1 ) ;
    for iter_batch = 1 : ceil( n / batch_size ) 
%         disp( sprintf( '%d %d' , iter_batch , iter_perm ) ) ;
%         toc ;
        start_pointer  = ( iter_batch - 1 ) * batch_size + 1 ;
        finish_pointer = min( n , iter_batch * batch_size ) ;
        
        for iter = start_pointer : finish_pointer
            sample_index = perm( iter ) ;
            sample_feature = feature( sample_index , : ) ;
            sample_label = label( sample_index ) ;
        
            % Finding r,s
            r( iter ) = -1 ;
            s( iter ) = -1 ;
            max_delta = 0 ;
            path = find( tree.l( : , sample_label ) ) ;
            for i = 1 : length( path )
                child = find( tree.father == path( i ) ) ;
                if ( isempty( child )  )
                    continue ;
                end
                true_child = child( ismember( child , path ) ) ;
                for j = 1 : length( child )
                    if ( child( j ) ~= true_child )
                        delta = w( child( j ) , : ) * sample_feature' - ...
                                w( true_child , : ) * sample_feature' + ... 
                                + b( child( j ) ) - b( true_child ) ;
                        if ( delta >= max_delta )
                            max_delta = delta ;
                            r( iter ) = true_child ;
                            s( iter ) = child( j ) ;
                        end
                    end
                end
            end
        end

        % descent for every vector
        for i = 1 : tree.node_count 
            w( i , : ) = w( i , : ) - eta * 2 * gamma * w( i , : ) ;
        end
    
        % descent for r,s 
        for i = start_pointer : finish_pointer
%             disp( [ r( i ) , s( i ) ] ) ;
            if ( r( i ) ~= -1 && s( i ) ~= -1 )
                w( r( i ) , : ) = w( r( i ) , : ) + ...
                    eta * sample_feature / batch_size ;
                w( s( i ) , : ) = w( s( i ) , : ) - ...
                    eta * sample_feature / batch_size ;
                b( r( i ) ) = b( r( i ) ) + eta * 1 / batch_size ;
                b( s( i ) ) = b( s( i ) ) - eta * 1 / batch_size ;
            end
        end
    end
end

end
