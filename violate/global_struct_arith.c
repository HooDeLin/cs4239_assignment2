struct numbers {
	int a;
	int b;
};

struct numbers mynumber = {1,2};

void func()
{
	int *b;
	b = &mynumber.a;
	b++;
}
