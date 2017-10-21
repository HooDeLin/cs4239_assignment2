void func()
{
	int a[4];
	int *b = &a[1];
	int **c = &b;
	int ***d = &c;
	b = (**d) + 1;
}
