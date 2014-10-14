function tree = labeltree_train( feature , label )
%Build a Label Tree Structure based on input features 
%and labels
%
%Usage
%    tree = labeltree_train( feature , label )
%
%Input
%    feature[N*D] - N feature vector with D dimension
%    label[N*1] - A label vector with N rows
%
%Output
%    tree[struct] - Label Tree structure
%
    if ( size( feature , 1 ) ~= size( label , 1 ) )
        error( 'number of faeture and label not matching' ) ;
    end

    tree = initialize_tree( feature , label ) ;
    [ tree.w , tree.b ] = gd( feature , label , tree.father , tree.l , ...
        0.02 , 0.0001 , 25 , 5 ) ;
    % eta * iter * 2 == 1
%     [ tree.w , tree.b ] = gradient_descent( feature , label , tree ) ;
end
