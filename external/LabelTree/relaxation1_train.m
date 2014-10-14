function [ tree ] = relaxation1_train( feature , label )
    tree = initialize_tree( feature , label ) ;
    tree = relaxation1_train_params( feature , label , tree ) ;
end
