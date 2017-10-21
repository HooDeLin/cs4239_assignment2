void func()
{
	int a[4];
	int *b = &a[1];
	int **c = &b;
	int ***d = &c;
	d++;
	c = (*d) + 1;
	b = (**d) + 1;
}
