function plot_data_point( feature , label )
    figure() ;
    point_color = [ 'r' , 'g' , 'b' , 'c' , 'm' , 'y' , 'k' ] ;
        
    label_count = max( label ) ;
    legend_cell = cell( 1 , label_count ) ;
    hold on
    for i = 1 : label_count
        subf = feature( label == i , : ) ;
        plot( subf( : , 1 ) , subf( : , 2 ) , 'o' , ...
            'markerfacecolor' , point_color( i ) , ...
            'markeredgecolor' , point_color( i ) ) ;
        legend_cell{ i } = num2str( i ) ;
    end
    hold off
    axis([0 1 0 1]);
    
    legend_handle = legend( legend_cell ) ;
    set(legend_handle,'Location','NorthWest');
    set(legend_handle,'Interpreter','none');
    set(gca,'color','none');
end
