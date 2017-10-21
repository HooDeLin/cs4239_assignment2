struct numbers {
	int arr_num[4];
	int a;
	int b;
};

void func() {
	struct numbers my_numbers;
	my_numbers.a = 123;
	my_numbers.b = 456;
	int *b;
	b = &my_numbers.arr_num[3];
	b ++;
}
