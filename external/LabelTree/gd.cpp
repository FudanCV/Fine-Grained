/*
 * Gradient Descent for Label Tree - Matlab Mex
 *
 * Usage :
 *     [ w , b ] = gd( feature , label , father , L , ?eta , ?gamma , ?iter_num )
 *
 * Input :
 *     feature[feature*dimension] : feature matrix for training data
 *     label[feature*1] : label vector for training data
 *     father[node*1] : tree struct vector (father[0] == -1)
 *     L[node*label] : label set for each node
 *     eta : learning rate (default 0.1)
 *     gamma : step width (default 0.001)
 *     iter_num : number of iteration (default 10)
 */

#include <cmath>
#include <vector>
#include <iostream>
#include "mex.h"
using namespace std;

#define MPTR(A,i,j) A.ptr[j*A.n+i]

const double INF = 1000000000 ;

class MatDoubleMatrix {
private :
	
public :
    int n , m ; // N * M matrix
	double *ptr ; // matrix pointer
    
	MatDoubleMatrix( int n , int m , double *ptr )
	{
		this -> n = n ;
		this -> m = m ;
		this -> ptr = ptr ;
	}
	
    /*
	int set( int i , int j , double val ) 
	{
		if ( i < 0 || j < 0 || i >= n || j >= m ) 
			return -1 ;
		ptr[ n * j + i ] = val ;
		return 0 ;
	}
	double get( int i , int j )
	{
		return ( double ) ptr[ n * j + i ] ;
	}
    */
} ;

void randperm( vector<int> &p ) {
    for ( int i = 0 ; i < p.size() ; i ++ ) {
        // p[ i ] = i ;
        int j = rand() % ( i + 1 ) ;
        p[ i ] = p[ j ] ;
        p[ j ] = i ;
    }
}

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray*prhs[] )
{
    double eta , gamma ;
    int iter_num , batch_size ;
	/* ===================== Input Checker ======================== */
	if ( nrhs < 4 )
		mexErrMsgTxt( "Incorrect number of input arguments." ) ;
	if ( mxGetM( prhs[ 0 ] ) != mxGetM( prhs[ 1 ] ) )
		mexErrMsgTxt( "Dimension of two matrix differs." ) ;
    if ( (int) mxGetN( prhs[ 1 ] ) != 1 )
        mexErrMsgTxt( "\'label\' is not vector." ) ;
    if ( (int) mxGetN( prhs[ 2 ] ) != 1 )
        mexErrMsgTxt( "\'father\' is not vector." ) ;
    if ( (int) mxGetM( prhs[ 2 ] ) != (int) mxGetM( prhs[ 3 ] ) )
        mexErrMsgTxt( "Incorrect of \'L\'s size" ) ;
    if ( nrhs >= 5 )
        eta = (double) *mxGetPr( prhs[ 4 ] ) ;
    else
        eta = 0.1 ;
    if ( nrhs >= 6 )
        gamma = (double) *mxGetPr( prhs[ 5 ] ) ;
    else
        gamma = 0.001 ;
    if ( nrhs >= 7 )
        iter_num = (int) *mxGetPr( prhs[ 6 ] ) ;
    else
        iter_num = 10 ;
    if ( nrhs >= 8 )
        batch_size = (int) *mxGetPr( prhs[ 7 ] ) ;
    else
        batch_size = 20 ;
	
	/* ===================== Input Labels ========================= */
    /* [ w , b ] = gd( feature , label , father , L )
     *
     * mxGetM - get number of row count
     * mxGetN - get number of column count 
     */
    int feature_count = (int) mxGetM( prhs[ 0 ] ) ;
    int dimension = (int) mxGetN( prhs[ 0 ] ) ;
    int label_count = (int) mxGetN( prhs[ 3 ] ) ;
    int node_count = (int) mxGetM( prhs[ 2 ] ) ;
    
    MatDoubleMatrix feature  = MatDoubleMatrix( feature_count , dimension , (double *) mxGetPr( prhs[ 0 ] ) ) ;
    MatDoubleMatrix label    = MatDoubleMatrix( feature_count , 1 , (double *) mxGetPr( prhs[ 1 ] ) ) ;
    MatDoubleMatrix father   = MatDoubleMatrix( node_count , 1 , (double *) mxGetPr( prhs[ 2 ] ) ) ;
    MatDoubleMatrix labelset = MatDoubleMatrix( node_count , label_count , (double *) mxGetPr( prhs[ 3 ] ) ) ;
    
	/* ===================== Output Labels ======================== */
	nlhs = 2 ;
	plhs[ 0 ] = mxCreateDoubleMatrix( node_count , dimension , mxREAL ) ;
    plhs[ 1 ] = mxCreateDoubleMatrix( node_count , 1 , mxREAL ) ;
	MatDoubleMatrix w = MatDoubleMatrix( node_count , dimension , ( double * ) mxGetPr( plhs[ 0 ] ) ) ;
    MatDoubleMatrix b = MatDoubleMatrix( node_count , 1 , ( double * ) mxGetPr( plhs[ 1 ] ) ) ;

    for ( int i = 0 ; i < node_count ; i ++ ) {
        for ( int j = 0 ; j < dimension ; j ++ )
            MPTR( w , i , j ) = 0 ;
        MPTR( b , i , 0 ) = 0 ;
    }
	
	/* ===================== Calc ======================== */

    // Tree Structure
    vector<vector<int> > son( node_count ) ;
    for ( int i = 1 ; i < node_count ; i ++ ) {
        int fa = (int) MPTR( father , i , 0 ) - 1 ;
        son[ fa ].push_back( i ) ;
    }

    // Gradient Descent
    vector<int> permutation( feature_count ) ;
    for ( int iter = 0 ; iter < iter_num ; iter ++ ) {
        cout << "Running Iter " << iter << '/' << iter_num << endl;
        randperm( permutation ) ;

        // Count one batch with 'batch_size' everytime
        for ( int t = 0 ; t < permutation.size() ; ) {
            vector<int> r , s , x ;
            for ( int i = 0 ; i < batch_size && t < permutation.size() ; i ++ , t ++ ) {
                int sample_pt = permutation[ t ] ;
                int sample_label = (int) MPTR( label , sample_pt , 0 ) - 1 ;
                
                // Find maximum 'r' and 's' 
                int best_r = -1 , best_s = -1 ; 
                double max_delta = 0 ;
                int now_pt = 0 ;
                while  ( true ) {
                    if ( son[ now_pt ].size() == 0 ) break ;
                    int find_r , find_s = -1 ;
                    double val_r , val_s ;
                    for ( int i = 0 ; i < son[ now_pt ].size() ; i ++ ) {
                        if ( (int) MPTR( labelset , son[ now_pt ] [ i ] , sample_label ) == 1 ) {
                            find_r = son[ now_pt ] [ i ] ;
                            val_r = (double) MPTR( b , find_r , 0 ) ;
                            #pragma omp parallel for reduction(+:val_r)
                            for ( int j = 0 ; j < dimension ; j ++ )
                                val_r += MPTR( feature , sample_pt , j ) * MPTR( w , find_r , j ) ;
                        } else {
                            int temp_s = son[ now_pt ] [ i ] ;
                            double temp_val_s = MPTR( b , temp_s , 0 ) ;
                            #pragma omp parallel for reduction(+:temp_val_s)
                            for ( int j = 0 ; j < dimension ; j ++ )
                                temp_val_s += MPTR( feature , sample_pt , j ) * MPTR( w , temp_s , j ) ;
                            if ( find_s == -1 || temp_val_s > val_s ) {
                                find_s = temp_s ;
                                val_s = temp_val_s ;
                            }
                        }
                    }
                    if ( val_s - val_r >= max_delta ) {
                        max_delta = val_s - val_r ;
                        best_r = find_r ;
                        best_s = find_s ;
                    }
                    now_pt = find_r ;
                }
                if ( best_r != -1 && best_s != -1 ) {
                    r.push_back( best_r ) ;
                    s.push_back( best_s ) ;
                    x.push_back( sample_pt ) ;
                }
            }

            // Add Gradient for 'w' and 'b' 
            #pragma omp parallel for
            for ( int i = 0 ; i < node_count ; i ++ )
                for ( int j = 0 ; j < dimension ; j ++ )
                    MPTR( w , i , j ) -= 2 * eta * gamma * MPTR( w , i , j ) ;
            for ( int i = 0 ; i < r.size() ; i ++ )
            {
                #pragma omp parallel for
                for ( int j = 0 ; j < dimension ; j ++ ) {
                    MPTR( w , r[ i ] , j ) += eta * MPTR( feature , x[ i ] , j ) / ( double ) batch_size ;
                    MPTR( w , s[ i ] , j ) -= eta * MPTR( feature , x[ i ] , j ) / ( double ) batch_size ;
                }
                MPTR( b , r[ i ] , 0 ) += eta / ( double ) batch_size ;
                MPTR( b , s[ i ] , 0 ) -= eta / ( double ) batch_size ;
            }
        }
    }
}
