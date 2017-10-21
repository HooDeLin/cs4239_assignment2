void func()
{
	int a[4];
	int *b = a;
	int **c = &b;
	**c ++;
}
