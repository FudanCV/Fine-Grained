function [ tree ] = relaxation1_train_params( feature , label , tree )
% Training w and b for tree by relaxation 1
%
% Input :
%      feature[n*d] :
%      label[n*1] :
%      tree[STRUCT] :
    LAMBDA = 0.0001 ;

    [ ~ , dimension ] = size( feature ) ;
    node_count = length( tree.father ) ;
    
    tree.w = zeros( node_count , dimension ) ;
    tree.b = zeros( node_count , 1 ) ;
    tree.goto = zeros( node_count , 2 ) ;
    
    for i = 1 : node_count 
        disp( sprintf( 'Training Parameter %d/%d' , i , node_count ) ) ;
        if ( sum( tree.l( i , : ) ) == 1 )
            continue ;
        end
        child = find( tree.father == i ) ;
        tree.goto( i , 1 ) = child( 1 ) ; %  1
        tree.goto( i , 2 ) = child( 2 ) ; % -1
        left_label_set = find( tree.l( child( 1 ) , : ) ) ;
        rigt_label_set = find( tree.l( child( 2 ) , : ) ) ;
        left_set = find( ismember( label , left_label_set ) ) ;
        rigt_set = find( ismember( label , rigt_label_set ) ) ;
        temp_set = [ left_set ; rigt_set ] ;
        temp_feature = feature( temp_set , : ) ;
        temp_label = zeros( size( temp_set ) ) ;
        temp_label( 1 : length( left_set ) ) = 1 ;
        temp_label( length( left_set ) : end ) = -1 ;
%         weight_vector = zeros( size( temp_set ) ) ;
%         weight_vector( 1 : length( left_set ) ) = 1 / length( left_set ) ;
%         weight_vector( length( left_set ) : end ) = 1 / length( rigt_set ) ;
        
        [ w , b , ~ ] = vl_svmtrain( temp_feature' , temp_label' , LAMBDA ) ;
%             'Weights' , weight_vector ) ;
        tree.w( i , : ) = w ;
        tree.b( i ) = b ;
    end
end
