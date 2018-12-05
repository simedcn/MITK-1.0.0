#pragma once
#include "mex.h"
#include <vector>

class DeformableBrush
{
public:
	DeformableBrush();
	~DeformableBrush();

	void SetInput(double * inputimagepointer);

	void SetOutput(double * outputimagepointer);

	void SetSeed(const std::vector<int> & seed);

	void SetSeedType(const int seedtype);

	void SetThre(double threlow, double threhigh);

	void SetNeibType(const int neibtype);

	void SetRadius(const double radius);

	void SetImageSize(int x, int y);

	void Update();

private:
	int xy2i(const int x, const int y);
	
	// �����ӿ�ƽ��ֵ
	double GetSubBoxMean(const int x, const int y);

	void Initialize();

	double * I;					// ����ԭʼͼ��
	double * M;					// Mask ͼ��

	// ���ӵ����ͣ�Ĭ�� 2���� 5*5 ƽ��
	// 0, 1, 2, 3, etc. ���������� 5 ������
	// 0 ��ʾȡ����
	// 1 ��ʾ 3*3 ƽ��
	// 2 ��ʾ 5*5 ƽ��
	int SeedType;

	std::vector<int> Seed;		// ���ӵ㣬���ȱ���3�ı�������Ϊ��3ά����
	double Mean;				// ���ӵ㴦��ֵ

	// �������ͣ�Ĭ�� 6
	// 2 ά��4, 8
	// 3 ά��6, 18, 28
	int NeibType;

	std::vector<int> Neib;		// ��ʾ����������

	// ������ ThreLow > ThreHigh ʱ������ֵ��Ч�������ڲ��Զ����� threlow �� threhigh
	// ������ ThreLow == ThreHigh ʱ����ʵ�ʵ��ϣ��£���Ϊ���ӵ��ֵ���ϣ���ȥ����ֵ
	// ������ ThreLow < ThreHigh ʱ��ʵ��ֵΪ������ֵ
	// Ĭ�� ThreLow = 30; ThreHigh = 30;
	double ThreLow;
	double ThreHigh;

	int xs, ys;					// ͼ������size

	double Radius;				// ��ˢ�뾶
};

DeformableBrush::DeformableBrush()
{
	NeibType = 8; // Ĭ�ϲ��� 6 ��������
	SeedType = 2; // Ĭ�� 5*5 ƽ��
	ThreLow = 30; // Ĭ����ֵ
	ThreHigh = 30;
	Mean = -1.0e300;
}

DeformableBrush::~DeformableBrush()
{
}

inline void DeformableBrush::SetInput(double * inputimagepointer)
{
	I = inputimagepointer;
}

inline void DeformableBrush::SetOutput(double * outputimagepointer)
{
	M = outputimagepointer;
}

inline void DeformableBrush::SetSeed(const std::vector<int>& seed)
{
	Seed = seed;
}

inline void DeformableBrush::SetSeedType(const int seedtype)
{
	SeedType = seedtype;
}

inline void DeformableBrush::SetThre(double threlow, double threhigh)
{
	ThreLow = threlow;
	ThreHigh = threhigh;
}

inline void DeformableBrush::SetNeibType(const int neibtype)
{
	NeibType = neibtype;
}

inline void DeformableBrush::SetRadius(const double radius)
{
	Radius = radius;
}

inline void DeformableBrush::SetImageSize(int x, int y)
{
	xs = x;
	ys = y;
}

inline void DeformableBrush::Update()
{
	Initialize();

	M[xy2i(Seed[0], Seed[1])] = 1; // �Ƚ����ӵ㴦 Mask ֵ��Ϊ 1

	std::vector<int> cseed = Seed; // ��ǰ�����ӵ㣬ÿ��ѭ�������ж��������
	while (true)
	{
		int nseed = int(cseed.size() / 2); // ��ǰ�������õ����ĵ����
		int count = 0; // �±�ǵ�Ŀ���ĸ���
		std::vector<int> newseed(cseed.size() * NeibType); // ��¼ÿ��whileѭ���±�ǵ�Ŀ���
		for (int j = 0; j < NeibType; j++)
		{
			for (int i = 0; i < nseed; i++)
			{
				int x = cseed[2 * i] + Neib[2 * j];
				int y = cseed[2 * i + 1] + Neib[2 * j + 1];
				if (x >= 0 && x < xs && y >= 0 && y < ys && 
					(x - Seed[0]) * (x - Seed[0]) + (y - Seed[1]) * (y - Seed[1]) <= Radius * Radius)
				{
					int idx = xy2i(x, y);
					if (M[idx] < 1e-16) // ����õ㻹δ�����ΪĿ���
					{
						double v = GetSubBoxMean(x, y);
						if (v >= ThreLow && v <= ThreHigh) // �������ֵ��Χ��
						{
							M[idx] = 1; // ����ΪĿ���
							newseed[2 * count] = x;
							newseed[2 * count + 1] = y;
							++count;
						}
					}
				}
			}
		}
		if (count == 0)
		{
			break;
		}
		cseed.resize(2 * count);
		cseed.assign(newseed.begin(), newseed.begin() + 2 * count);
	}
}

inline int DeformableBrush::xy2i(const int x, const int y)
{
	return x + y * xs;
}

inline double DeformableBrush::GetSubBoxMean(const int x, const int y)
{
	double m = 0; // ���� return
	if (SeedType == 0) // ���ӵ�����Ϊ��ȡ���㡱ʱ��ֱ���Ըõ��ֵΪ����ֵ
	{
		m = I[xy2i(x, y)];
	}
	else
	{
		int count = 0;
		for (int i = -SeedType; i <= SeedType; i++)
		{
			for (int j = -SeedType; j <= SeedType; j++)
			{
				if (x + i >= 0 && x + i < xs && y + j >= 0 && y + j < ys)
				{
					m += I[xy2i(x + i, y + j)];
					count++;
				}
			}
		}
		m /= double(count);
	}

	// �����ݶ�����
	if (0)
	{
		double sign = 1;
		if (m > Mean)
		{
			sign = -1;
		}

		double check = 0;
		int count = 0;
		for (int i = 1; i <= SeedType; i++)
		{
			for (int j = -SeedType; j <= SeedType; j++)
			{
				if (x - i >= 0 && x + i < xs && y + j >= 0 && y + j < ys)
				{
					double a = abs(double(I[xy2i(x + i, y + j)]) - double(I[xy2i(x - i, y + j)])) / (2 * i);
					check += a * a;
					count++;
				}

			}
		}
		for (int j = 1; j <= SeedType; j++)
		{
			for (int i = -SeedType; i <= SeedType; i++)
			{
				if (y - j >= 0 && y + j < ys && x + i >= 0 && x + i < xs)
				{
					double a = abs(double(I[xy2i(x + i, y + j)]) - double(I[xy2i(x + i, y - j)])) / (2 * j);
					check += a * a;
					count++;
				}

			}
		}
		check = sqrt(check / double(count));
		m += 1.0 * sign * check;
	}

	return m;
}


inline void DeformableBrush::Initialize()
{
	// ȷ������
	Neib.resize(2 * NeibType);
	if (NeibType == 4) // for 2 ά
	{
		int a[] = { 1,0, -1,0, 0,1, 0,-1 };
		Neib.assign(a, a + 8);
	}
	else if (NeibType == 8) // for 2 ά
	{
		int a[] = { 1,0, -1,0, 0,1, 0,-1, 1,1, -1,1, 1,-1, -1,-1 };
		Neib.assign(a, a + 16);
	}


	// �������ӵ���Ϣ
	Mean = GetSubBoxMean(Seed[0], Seed[1]);

	// �����û����� ThreLow, ThreHigh�������ڲ�ʵ��ʹ�õ���ֵ
	if (ThreLow == ThreHigh) // ������ threlow == threhigh ʱ
	{
		ThreLow = Mean - ThreLow;
		ThreHigh = Mean + ThreHigh;
	}
	else if (ThreLow > ThreHigh) // ������ threlow > threhigh ʱ�����ñ�׼��������
	{
		double Std = 0;
		int count = 0;
		for (int i = -2; i <= 2; i++)
		{
			for (int j = -2; j <= 2; j++)
			{
				int x = Seed[0] + i;
				int y = Seed[1] + j;
				if (x >= 0 && x < xs && y >= 0 && y < ys)
				{
					Std += std::pow(Mean - I[xy2i(x, y)], 2);
					count++;
				}
			}
		}
		Std = std::sqrt(Std / double(count));
		ThreLow = Mean - 3 * Std;
		ThreHigh = Mean + 3 * Std;
	}
}
