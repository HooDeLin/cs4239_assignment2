void func()
{
	int a = 1;
	int b[4] = {1,2,3,4};
	int *c;
	if (a == 1)
	{
		c = &a;
		c ++;	
	} else {
		c = &b[1];
		c ++;
	}
}
