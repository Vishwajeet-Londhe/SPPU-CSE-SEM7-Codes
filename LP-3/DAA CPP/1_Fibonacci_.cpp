#include <iostream>
#include <chrono>
using namespace std;

// ---------- Recursive Fibonacci ----------
int fib_recursive(int n) {
    if (n <= 1)
        return n;
    return fib_recursive(n - 1) + fib_recursive(n - 2);
}

// ---------- Non-Recursive Fibonacci ----------
void fib_non_recursive(int n) {
    int n1 = 0, n2 = 1, n3;
    cout << n1 << " " << n2 << " ";
    for (int i = 2; i < n; ++i) {
        n3 = n1 + n2;
        cout << n3 << " ";
        n1 = n2;
        n2 = n3;
    }
    cout << endl;
}

// ---------- Main Function ----------
int main() {
    int n;
    cout << "Enter the number of elements: ";
    cin >> n;

    cout << "\nFibonacci Sequence (Recursive): ";
    auto start1 = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < n; i++)
        cout << fib_recursive(i) << " ";
    auto end1 = std::chrono::high_resolution_clock::now();
    auto time_recursive = std::chrono::duration_cast<std::chrono::microseconds>(end1 - start1).count();

    cout << "\n\nFibonacci Sequence (Non-Recursive): ";
    auto start2 = std::chrono::high_resolution_clock::now();
    fib_non_recursive(n);
    auto end2 = std::chrono::high_resolution_clock::now();
    auto time_nonrecursive = std::chrono::duration_cast<std::chrono::microseconds>(end2 - start2).count();

    // ---------- Time & Space Complexity ----------
    cout << "\n=== Time and Space Complexity Analysis ===\n";
    cout << "Recursive Time Taken: " << time_recursive << " microseconds\n";
    cout << "Recursive Time Complexity: O(2^n)\n";
    cout << "Recursive Space Complexity: O(n)\n\n";

    cout << "Non-Recursive Time Taken: " << time_nonrecursive << " microseconds\n";
    cout << "Non-Recursive Time Complexity: O(n)\n";
    cout << "Non-Recursive Space Complexity: O(1)\n";

    return 0;
}
