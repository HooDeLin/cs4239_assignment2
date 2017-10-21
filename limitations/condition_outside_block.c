void func()
{
	int a = 1;
	int b[4] = {1,2,3,4};
	int *c;
	int d;
	if (d == 1)
	{
		c = &a;	
	} else {
		c = &b[1];
	}
	c ++;
}
