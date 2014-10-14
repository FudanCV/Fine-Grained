function [ label ] = labeltree_predict( feature , tree )
% Predict label for feature vector
%
% Usage
%     label = labeltree_predict(feature,tree)
%
% Input
%     feature[N*D] : N test feature vector with demension D
%     tree[struct] : Label Tree struct
%
% Output
%     label[N*1] : Predict for each feature

    label = pd( feature , tree.father , tree.l , tree.w , tree.b ) ;

%     [ n , d ] = size( feature ) ;
%     if ( d ~= tree.feature_dimension )
%         error( 'vector demension not matching' ) ;
%     end
%     
%     label = zeros( n , 1 ) ;
%     tic ;
%     for i = 1 : n 
%         if ( mod( i , 1000 ) == 1 )
%             disp( [ 'labeltree testing [' , num2str(i),'/',num2str(n),']' ] ) ;
%             toc ;
%         end
%         node = 1 ;
%         while ( sum( tree.l( node , : ) ) > 1 )
%             child = find( tree.father == node ) ;
%             max_value = NaN ;
%             select_child = -1 ;
%             for j = 1 : length( child )
%                 fx = tree.w( child( j ) , : ) * feature( i , : )' + tree.b( child( j ) ) ;
%                 if ( isnan( max_value ) || fx > max_value )
%                     max_value = fx ;
%                     select_child = child( j ) ;
%                 end
%             end
%             node = select_child ;
%         end
%         label( i ) = find( tree.l( node , : ) ) ;
%     end

end

