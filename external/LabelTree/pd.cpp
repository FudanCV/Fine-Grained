/*
 * Label Tree Predict - Matlab Mex
 *
 * Usage :
 *     [ label ] = gd( feature , father , L , w , b )
 *
 * Input :
 *     feature[feature*dimension] : feature matrix for training data
 *     father[node*1] : tree struct vector (father[0] == -1)
 *     L[node*label] : label set for each node
 *     w[node*dimension] : parameter w for each node
 *     b[node*1] : parameter b for each node 
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
	/* ===================== Input Checker ======================== */
	if ( nrhs < 5 )
		mexErrMsgTxt( "Dimension of two matrix differs." ) ;
    if ( mxGetM( prhs[ 2 ] ) != mxGetM( prhs[ 1 ] ) )
        mexErrMsgTxt( "Incorrect of \'L\'s size" ) ;
    if ( mxGetM( prhs[ 3 ] ) != mxGetM( prhs[ 1 ] ) ||
         mxGetN( prhs[ 3 ] ) != mxGetN( prhs[ 0 ] ) )
        mexErrMsgTxt( "Incorrect of \'w\'s size" ) ;
    if ( mxGetM( prhs[ 4 ] ) != mxGetM( prhs[ 1 ] ) || 
         (int) mxGetN( prhs[ 4 ] ) != 1 )
        mexErrMsgTxt( "Incorrect of \'b\'s size") ;
	
	/* ===================== Input Labels ========================= */
    /* [ label ] = gd( feature , father , L , w , b )
     *
     * mxGetM - get number of row count
     * mxGetN - get number of column count 
     */
    int feature_count = (int) mxGetM( prhs[ 0 ] ) ;
    int dimension = (int) mxGetN( prhs[ 0 ] ) ;
    int label_count = (int) mxGetN( prhs[ 2 ] ) ;
    int node_count = (int) mxGetM( prhs[ 1 ] ) ;
    
    MatDoubleMatrix feature  = MatDoubleMatrix( feature_count , dimension , (double *) mxGetPr( prhs[ 0 ] ) ) ;
    MatDoubleMatrix father   = MatDoubleMatrix( node_count , 1 , (double *) mxGetPr( prhs[ 1 ] ) ) ;
    MatDoubleMatrix labelset = MatDoubleMatrix( node_count , label_count , (double *) mxGetPr( prhs[ 2 ] ) ) ;
    MatDoubleMatrix w        = MatDoubleMatrix( node_count , dimension , (double *) mxGetPr( prhs[ 3 ] ) ) ;
    MatDoubleMatrix b        = MatDoubleMatrix( node_count , 1 , (double *) mxGetPr( prhs[ 4 ] ) ) ;
    
	/* ===================== Output Labels ======================== */
	nlhs = 1 ;
	plhs[ 0 ] = mxCreateDoubleMatrix( feature_count , 1 , mxREAL ) ;
	MatDoubleMatrix label = MatDoubleMatrix( feature_count , 1 , ( double * ) mxGetPr( plhs[ 0 ] ) ) ;

    for ( int i = 0 ; i < feature_count ; i ++ )
        MPTR( label , i , 0 ) = 0 ;
	
	/* ===================== Calc ======================== */

    // Tree Structure
    vector<vector<int> > son( node_count ) ;
    for ( int i = 1 ; i < node_count ; i ++ ) {
        int fa = (int) MPTR( father , i , 0 ) - 1 ;
        son[ fa ].push_back( i ) ;
    }

    // Label of each node
    vector<int> node_label( node_count , 0 ) ;
    for ( int i = 0 ; i < node_count ; i ++ )
        for ( int j = 0 ; j < label_count ; j ++ )
            if ( (int) MPTR( labelset , i , j ) == 1 ) {
                if ( node_label[ i ] != 0 ) node_label[ i ] = -1 ;
                if ( node_label[ i ] == 0 ) node_label[ i ] = j ;
            }

    // Predicting
    for ( int i = 0 ; i < feature_count ; i ++ ) {
        int now_pt = 0 ;
        while ( son[ now_pt ].size() != 0 ) {
            int best_pt = -1 ;
            double best_product = 0 ;
            for ( int j = 0 ; j < son[ now_pt ].size() ; j ++ ) {
                double inner_product = MPTR( b , son[ now_pt ] [ j ] , 0 ) ;
                #pragma omp parallel for reduction(+:inner_product)
                for ( int k = 0 ; k < dimension ; k ++ )
                    inner_product += MPTR( feature , i , k ) * MPTR( w , son[ now_pt ] [ j ] , k ) ;

                if ( best_pt == -1 || inner_product > best_product ) {
                    best_product = inner_product ;
                    best_pt = son[ now_pt ] [ j ] ;
                }
            }
            now_pt = best_pt ;
        }
        MPTR( label , i , 0 ) = node_label[ now_pt ] + 1 ;
    }
}
