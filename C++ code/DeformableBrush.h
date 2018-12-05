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
	
	// 计算子块平均值
	double GetSubBoxMean(const int x, const int y);

	void Initialize();

	double * I;					// 输入原始图像
	double * M;					// Mask 图像

	// 种子点类型，默认 2，即 5*5 平均
	// 0, 1, 2, 3, etc. 建议最大调到 5 就行了
	// 0 表示取样点
	// 1 表示 3*3 平均
	// 2 表示 5*5 平均
	int SeedType;

	std::vector<int> Seed;		// 种子点，长度必须3的倍数，因为是3维坐标
	double Mean;				// 种子点处均值

	// 邻域类型，默认 6
	// 2 维：4, 8
	// 3 维：6, 18, 28
	int NeibType;

	std::vector<int> Neib;		// 表示邻域的坐标点

	// 当设置 ThreLow > ThreHigh 时，设置值无效，程序内部自动估计 threlow 和 threhigh
	// 当设置 ThreLow == ThreHigh 时，则实际的上（下）界为种子点均值加上（减去）该值
	// 当设置 ThreLow < ThreHigh 时，实际值为该设置值
	// 默认 ThreLow = 30; ThreHigh = 30;
	double ThreLow;
	double ThreHigh;

	int xs, ys;					// 图像矩阵的size

	double Radius;				// 画刷半径
};

DeformableBrush::DeformableBrush()
{
	NeibType = 8; // 默认采用 6 邻域生长
	SeedType = 2; // 默认 5*5 平均
	ThreLow = 30; // 默认阈值
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

	M[xy2i(Seed[0], Seed[1])] = 1; // 先将种子点处 Mask 值设为 1

	std::vector<int> cseed = Seed; // 当前的种子点，每次循环搜索判断其邻域点
	while (true)
	{
		int nseed = int(cseed.size() / 2); // 当前生长所用的中心点个数
		int count = 0; // 新标记的目标点的个数
		std::vector<int> newseed(cseed.size() * NeibType); // 记录每轮while循环新标记的目标点
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
					if (M[idx] < 1e-16) // 如果该点还未被标记为目标点
					{
						double v = GetSubBoxMean(x, y);
						if (v >= ThreLow && v <= ThreHigh) // 如果在阈值范围内
						{
							M[idx] = 1; // 则标记为目标点
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
	double m = 0; // 用于 return
	if (SeedType == 0) // 种子点类型为“取样点”时，直接以该点的值为返回值
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

	// 进行梯度修正
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
	// 确定邻域
	Neib.resize(2 * NeibType);
	if (NeibType == 4) // for 2 维
	{
		int a[] = { 1,0, -1,0, 0,1, 0,-1 };
		Neib.assign(a, a + 8);
	}
	else if (NeibType == 8) // for 2 维
	{
		int a[] = { 1,0, -1,0, 0,1, 0,-1, 1,1, -1,1, 1,-1, -1,-1 };
		Neib.assign(a, a + 16);
	}


	// 计算种子点信息
	Mean = GetSubBoxMean(Seed[0], Seed[1]);

	// 根据用户设置 ThreLow, ThreHigh，计算内部实际使用的阈值
	if (ThreLow == ThreHigh) // 当设置 threlow == threhigh 时
	{
		ThreLow = Mean - ThreLow;
		ThreHigh = Mean + ThreHigh;
	}
	else if (ThreLow > ThreHigh) // 当设置 threlow > threhigh 时，采用标准差来估计
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
