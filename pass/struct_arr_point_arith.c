struct numbers {
	int a[4];
	int b;
};

void func() {
	struct numbers my_numbers = {1,2,3,4,5};
	int *b;
	b = &my_numbers.a[1];
	b ++;
}
