#include "DeformableBrush.h"
// DeformableBrush(I, M, seed, h, neibtype, threlow, threhigh, radius)
// I : ����ͼ��
// M : ���ͼ��
// seed : ���ӵ����꣬1*2
// h : ���ӵ����͡�0, 1, 2, 3,...
// neibtype : �������͡�4, 8; 6, 18, 26
// threlow : ����ֵ
// threhigh : ����ֵ
// radius : ��ˢ�뾶


void mexFunction(int nl, mxArray * out[], int nr, const mxArray * in[])
{
	double * I = mxGetPr(in[0]);
	double * M = mxGetPr(in[1]);
	mwSize ndim = mxGetNumberOfDimensions(in[0]);
	const mwSize * dim = mxGetDimensions(in[0]);
	if (ndim != 2)
	{
		mexErrMsgIdAndTxt("�����������",
			"��һ�������������Ϊ2ά��ֵ����\n");
	}
	std::vector<int> seed(2);
	seed[0] = (int)mxGetPr(in[2])[0] - 1;
	seed[1] = (int)mxGetPr(in[2])[1] - 1;
	int seedtype = (int)mxGetScalar(in[3]);
	int neibtype = (int)mxGetScalar(in[4]);
	double threlow = mxGetScalar(in[5]);
	double threhigh = mxGetScalar(in[6]);
	double radius = mxGetScalar(in[7]);

	DeformableBrush db;
	
	try
	{
		db.SetInput(I);
		db.SetOutput(M);
		db.SetSeed(seed);
		db.SetSeedType(seedtype);
		db.SetNeibType(neibtype);
		db.SetThre(threlow, threhigh);
		db.SetImageSize(dim[0], dim[1]);
		db.SetRadius(radius);
		db.Update();
	}
	catch (...)
	{
		mexErrMsgIdAndTxt("MATLAB:mexfunction:inputOutputMismatch",
			"δ֪����XXXXXXXXX��\n");
	}

}
