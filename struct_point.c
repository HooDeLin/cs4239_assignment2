struct numbers {
	int a;
	int b;
};

void func() {
	struct numbers my_numbers = {1,2};
	int *b;
	b = &my_numbers.a;
}
