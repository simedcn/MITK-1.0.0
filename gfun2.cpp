#include "mex.h"

// matlab 调用格式：g = gfun(t, M, Ftemp, Mgrid)
// t : 形变场，256 * 256 * 2
// M : 原始的移动图像
// Ftemp : 固定模板图像，256 * 256
// Mgrid : 插值用网格点
void mexFunction(int nout, mxArray * out[], int nin, mxArray * in[])
{
	/*mxArray * a = mxCreateDoubleScalar(1.0);
	mxArray * b = mxCreateDoubleScalar(2.0);
	mxArray * c = mxCreateDoubleScalar(7.0);
	mexPrintf("a =%.1f\tb =%.1f\tc = %.1f\n", *mxGetPr(a), *mxGetPr(b), *mxGetPr(c));
	mxArray * pl[1];
	mxArray * pr[2];
	pl[0] = c;
	pr[0] = a;
	pr[1] = b;

	int ss = mexCallMATLAB(1, pl, 2, pr, "plus");
	c = pl[0];
	mexPrintf("ss = %d\na =%.1f\tb =%.1f\tc = %.1f\n", ss, *mxGetPr(a), *mxGetPr(b), *mxGetPr(c));*/

	const mwSize * dim = mxGetDimensions(in[0]);
	mxDouble * t = (mxDouble *)mxGetPr(in[0]);
	out[0] = mxCreateNumericArray(3, dim, mxDOUBLE_CLASS, mxREAL);
	mxDouble * g = (mxDouble *)mxGetPr(out[0]);
	
	mxArray * y1 = mxCreateDoubleScalar(0.0);
	mxArray * y2 = mxCreateDoubleScalar(0.0);
	mxArray * pl[1];
	mxArray * pr[4];
	pr[1] = in[1];
	pr[2] = in[2];
	pr[3] = in[3];

	for (size_t i = 0; i < dim[0] * dim[1] * dim[2]; i++)
	{
		mxArray * T1 = in[0];
		mxDouble * t1 = (mxDouble *)mxGetPr(T1);
		mxArray * T2 = in[0];
		mxDouble * t2 = (mxDouble *)mxGetPr(T2);
		t1[i] += 10.0;
		t2[i] -= 10.0;
		
		pr[0] = T1;
		mexCallMATLAB(1, &y1, 4, pr, "fun2");
		pr[0] = T2;
		mexCallMATLAB(1, &y2, 4, pr, "fun2");

		g[i] = (((mxDouble *)mxGetPr(y1))[0] - ((mxDouble *)mxGetPr(y2))[0]) / 20.0;
		
	}
}