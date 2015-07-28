/** 
 * This is the C/MEX code of dynamic time warping of two signals
 *
 * compile: 
 *     mex dtw_c.c
 *
 * usage:
 *     d=dtw_c(s,t)  or  d=dtw_c(s,t,w)
 *     where s is signal 1, t is signal 2, w is window parameter 
 */

#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

 typedef enum {CELL, CELLSCALAR, CELL2, CELL2SCALAR} inputType; 
double vectorDistance(double *s, double *t, int ns, int nt, int k, int i, int j)
{
    double result=0;
    double ss,tt;
    int x;
    for(x=0;x<k;x++)
    {
        ss=s[i+ns*x];
        tt=t[j+nt*x];
        result+=((ss-tt)*(ss-tt));
    }
    result=sqrt(result);
    return result;
}

double dtw_2sets(double *s, double *t, int w, int ns, int nt, int k)
{
    double d=0;
    int sizediff=ns-nt>0 ? ns-nt : nt-ns;
    double ** D;
    int i,j;
    int j1,j2;
    double cost,temp;
    
    /* printf("ns=%d, nt=%d, w=%d, s[0]=%f, t[0]=%f\n",ns,nt,w,s[0],t[0]); */
    
    
    if(w!=-1 && w<sizediff) w=sizediff; /* adapt window size */
    
    /* create D */
    D=(double **)malloc((ns+1)*sizeof(double *));
    for(i=0;i<ns+1;i++)
    {
        D[i]=(double *)malloc((nt+1)*sizeof(double));
    }
    
    /* initialization */
    for(i=0;i<ns+1;i++)
    {
        for(j=0;j<nt+1;j++)
        {
            D[i][j]=-1;
        }
    }
    D[0][0]=0;
    
    /* dynamic programming */
    for(i=1;i<=ns;i++)
    {
        if(w==-1)
        {
            j1=1;
            j2=nt;
        }
        else
        {
            j1= i-w>1 ? i-w : 1;
            j2= i+w<nt ? i+w : nt;
        }
        for(j=j1;j<=j2;j++)
        {
            cost=vectorDistance(s,t,ns,nt,k,i-1,j-1);
            
            temp=D[i-1][j];
            if(D[i][j-1]!=-1) 
            {
                if(temp==-1 || D[i][j-1]<temp) temp=D[i][j-1];
            }
            if(D[i-1][j-1]!=-1) 
            {
                if(temp==-1 || D[i-1][j-1]<temp) temp=D[i-1][j-1];
            }
            
            D[i][j]=cost+temp;
        }
    }
    
    
    d=D[ns][nt];
    
    /* view matrix D */
    /*
    for(i=0;i<ns+1;i++)
    {
        for(j=0;j<nt+1;j++)
        {
            printf("%f  ",D[i][j]);
        }
        printf("\n");
    }
    */ 
    
    /* free D */
    for(i=0;i<ns+1;i++)
    {
        free(D[i]);
    }
    free(D);
    
    return d;
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    

    double *s,*t;
    int w;
    int ns,nt,k;
    double *dp;
    inputType type;
    
    mwSize total_num_of_cells1, total_num_of_cells2;
    mwIndex index1, index2;
    mwSize loc, len;
    mwSize *shift;
    const mxArray *cell_element_ptr1, *cell_element_ptr2;  
    
    /*  check for proper number of arguments */
    if(nrhs !=1 && nrhs!=2 && nrhs!=3)
    {
        mexErrMsgIdAndTxt( "MATLAB:dtw_2sets:invalidNumInputs",
                "Two or three inputs required.");
    }
    if(nlhs>1)
    {
        mexErrMsgIdAndTxt( "MATLAB:dtw_2sets:invalidNumOutputs",
                "dtw_c: One output required.");
    }
    
    /* check to make sure w is a scalar */
    if(nrhs == 1)
    {
        if(!mxIsCell(prhs[0]))
            mexErrMsgIdAndTxt("wrong type of input",
                    "the input should be cell array");
        w = -1;
        type = CELL;
    }
    else if(nrhs==2)
    {
        if(mxIsCell(prhs[0]) && mxIsCell(prhs[1]))
        { w = -1; type = CELL2;}
        else if(mxIsCell(prhs[0]) && mxIsDouble(prhs[1]))
        { w = (int) mxGetScalar(prhs[1]); type = CELLSCALAR;}
        else mexErrMsgIdAndTxt("In case of two inputs: wrong type", 
                "the 1st should be a cell, while the 2nd is a scalar");
    }
    else if(nrhs==3)
    {
        if( !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) ||
                mxGetN(prhs[2])*mxGetM(prhs[2])!=1 )
        {
            mexErrMsgIdAndTxt( "MATLAB:dtw_2sets:w NotScalar",
                    "dtw_2sets: Input w must be a scalar.");
        }
        
        /*  get the scalar input w */
        w = (int) mxGetScalar(prhs[2]);
        
        if( !mxIsCell(prhs[0]) || !mxIsCell(prhs[1]))
            mexErrMsgIdAndTxt("wrong type of the 1st or 2nd inputs",
                    "the 1st and 2nd inputs should be of type cell");
        type = CELL2SCALAR;
    }   
   
    
    switch(type)
    {
        case CELL:
              
              total_num_of_cells1 = (mwSize) mxGetNumberOfElements(prhs[0]); 
              len = total_num_of_cells1*(total_num_of_cells1-1)/2;
              plhs[0] = mxCreateDoubleMatrix( len, 1, mxREAL);
              /*  create a C pointer to a copy of the output matrix */
              shift = malloc(sizeof(mwSize)*total_num_of_cells1);
              memset(shift,0,total_num_of_cells1*sizeof(mwSize));
              for(index1=total_num_of_cells1-1; index1>=1; index1--)
              {
                  shift[total_num_of_cells1-index1] = shift[total_num_of_cells1-index1-1] +
                                            index1;
              }
              dp = mxGetPr(plhs[0]);
              for (index1=0; index1<total_num_of_cells1; index1++)            
              {
                    cell_element_ptr1 = mxGetCell(prhs[0], index1);
                    s = mxGetPr(cell_element_ptr1);
                    ns = mxGetM(cell_element_ptr1);
                    k = mxGetN(cell_element_ptr1);
                    /*if(index1%100 == 0)
                        printf("processing row: %d\n",index1+1);*/
                    for(index2 = index1+1; index2 < total_num_of_cells1; index2++)
                    {
                        cell_element_ptr2 = mxGetCell(prhs[0], index2);
                        t = mxGetPr(cell_element_ptr2);
                        nt = mxGetM(cell_element_ptr2);
                        loc = shift[index1] + index2-1-index1;
                        dp[loc]=dtw_2sets(s,t,w,ns,nt,k);

                    }
              }
              free(shift);
            break;
        case CELL2:
                break;
        case CELLSCALAR:
                break;
        case CELL2SCALAR:
                break;
        default:
            break;
        
    }

     
   
  
    return;
    
}