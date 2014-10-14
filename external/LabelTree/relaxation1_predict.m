function [ label ] = relaxation1_predict( feature , tree )
% Predict label from label tree

    [ feature_count , ~ ] = size( feature ) ;
    node_count = length( tree.father ) ;
    
    label = zeros( feature_count , 1 ) ;
    innode = ones( size( label ) ) ;
    for i = 1 : node_count 
        if ( sum( tree.l( i , : ) ) == 1 )
            label( innode == i ) = find( tree.l( i , : ) ) ;
            continue ;
        end
        list = find( innode == i ) ;
        esti = feature( list , : ) * tree.w( i , : )' + tree.b( i ) ;
        innode( list( esti >= 0 ) ) = tree.goto( i , 1 ) ;
        innode( list( esti < 0  ) ) = tree.goto( i , 2 ) ;
    end
end
