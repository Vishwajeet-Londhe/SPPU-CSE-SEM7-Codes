#include<iostream>
#include <chrono>
using namespace std;
using namespace std::chrono;

void printFibonacci(int n) {
static int n1 = 0, n2 = 1, n3;

if (n > 0) {
n3 = n1 + n2;
n1 = n2;
n2 = n3;
cout << n3 << " ";
printFibonacci(n - 1);
}
}

int main() {
int n;
cout << "Enter the number of elements: ";
cin >> n;

cout << "Fibonacci Series: ";

cout << "0 " << "1 ";

auto start_time = high_resolution_clock::now();

printFibonacci(n - 2); // n-2 because 2 numbers are already printed

auto end_time = high_resolution_clock::now();
auto duration = duration_cast<microseconds>(end_time - start_time);

cout << "\nElapsed Time: " << duration.count() << " microseconds" << endl;

// Additional space tracking
cout << "Estimated Space Used: " << sizeof(int) * 3 * (n - 2) << " bytes" <<
endl;

return 0;
}