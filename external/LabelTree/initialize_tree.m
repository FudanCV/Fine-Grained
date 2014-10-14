function [ tree ] = initialize_tree( feature , label )
%
% Input
%       feature[N*D] - N feature vector with D dimension
%       label[N*1] - A label vector with N rows
%
% Output
%       tree[struct] - Label Tree structure
% 
    [ feature_count , dimension ] = size( feature ) ;
    label_count = max( label ) ;
    node_count = label_count * 2 - 1 ;
    
    tree = struct() ;
    tree.label_count = label_count ;
    tree.node_count = node_count ;
    tree.feature_dimension = dimension ;
    tree.child = zeros( node_count , 2 ) ;
    tree.father = zeros( node_count , 1 ) ;
    tree.l = zeros( node_count , label_count ) ;
    tree.l( 1 , : ) = 1 ;
    
    % Train one-vs-all svm for each label
    disp( 'Train one-vs-all svm for each label' ) ;
    SVMs = cell( label_count , 1 ) ;
    LABMDA = 0.0001 ;
    for i = 1 : label_count 
        disp( [ 'Train one-vs-all SVM: ' , num2str( i ) ] ) ;
        temp_label_list = ones( feature_count , 1 ) ;
        temp_label_list( label ~= i ) = -1 ;
        weight_vector = ones( feature_count , 1 ) ;
        weight_vector( label ~= i ) = sum( label == i ) / sum( label ~= i ) ;
        
        SVMs{ i } = struct() ;
        [ SVMs{ i }.w , SVMs{ i }.b , SVMs{ i }.info ] = vl_svmtrain( feature' , temp_label_list' , LABMDA , ...
            'Weights' , weight_vector ) ;
    end

    % Test each one-vs-all svm by all feature
    disp( 'Calc confusion matrix' ) ;
    svm_test = zeros( feature_count , label_count ) ;
    for i = 1 : label_count
        disp( [ 'Calc for confusion matrix: [' , num2str(i) ,'/', num2str(label_count) ,']' ] ) ;
        esti = feature * SVMs{ i }.w + SVMs{ i }.b ;
        svm_test( : , i ) = 1 ./ ( 1 + exp( -esti ) ) ; % sigmoid function
    end

    % Calc confusion matrix C
    C = zeros( label_count , label_count ) ;
    for i = 1 : feature_count
        C( label( i ) , : ) = C( label( i ) , : ) + svm_test( i , : ) / sum( label == label( i ) ) ;
    end
    C = ( C + C' ) / 2 ;

    node_counter = 1 ;
    for i = 1 : node_count
        disp( [ 'Learning Tree Structure... ' , num2str( i ) , '/' , num2str( node_count ) ] ) ;
        
        % Initialize for each node
        node_label_count = sum( tree.l( i , : ) ) ;
        node_label = find( tree.l( i , : ) ) ;
        if ( node_label_count == 1 )
            continue ;
        end
        
        CC = C( node_label , node_label ) ;
        
        % And using spectral clustering
        % label_split = spectral_clustering( CC + 1e-6 , 2 ) ;
        [label_split,~,~] = ncutW( CC + 1e-6 , 2 ) ;
        
        % Split label to two child node
        for j = 1 : 2 
            node_counter = node_counter + 1 ;
            tree.child( i , j ) = node_counter ;
            tree.father( node_counter ) = i ;
            % tree.l( node_counter , node_label( label_split == j ) ) = 1 ;
            tree.l( node_counter , node_label( find( label_split( : , j ) ) ) ) = 1 ;
        end
      
    end
end