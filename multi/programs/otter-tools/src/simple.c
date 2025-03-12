
volatile int* LED_ADDR = (int*) 0x1100C000;

typedef unsigned int size_t;

void delay_cc(size_t n) {
	for (volatile size_t i = 0; i < n; i++);
}

void main() {
	const size_t N = 5000000;
	int led = 1;
	int shift_left = 1;
	while (1) {
		if (shift_left) {
			led = led << 1;
			if (led == 0x8000) shift_left = 0;
		} else {
			led = led >> 1;
			if (led == 0x1) shift_left = 1;
		}

		*LED_ADDR = led;
		delay_cc(N);
	}

	return;
}
