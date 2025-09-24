#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

// Structure to represent an item
struct Item {
    double value;
    double weight;
};

// Comparator function to sort items by value/weight ratio
bool cmp(Item a, Item b) {
    double r1 = a.value / a.weight;
    double r2 = b.value / b.weight;
    return r1 > r2; // Descending order
}

// Function to solve fractional knapsack
double fractionalKnapsack(int n, double W, vector<Item> &items) {
    // Sort items by value/weight ratio
    sort(items.begin(), items.end(), cmp);

    double totalValue = 0.0;

    for (int i = 0; i < n; i++) {
        if (items[i].weight <= W) {
            // Take whole item
            W -= items[i].weight;
            totalValue += items[i].value;
        } else {
            // Take fractional part
            totalValue += items[i].value * (W / items[i].weight);
            break; // Knapsack is full
        }
    }

    return totalValue;
}

int main() {
    int n;
    double W;
    cout << "Enter number of items: ";
    cin >> n;
    vector<Item> items(n);

    cout << "Enter value and weight of each item:\n";
    for (int i = 0; i < n; i++) {
        cin >> items[i].value >> items[i].weight;
    }

    cout << "Enter capacity of knapsack: ";
    cin >> W;

    double maxValue = fractionalKnapsack(n, W, items);
    cout << "Maximum value in the knapsack = " << maxValue << endl;

    return 0;
}

// Input

// Number of items: 3
// Values & weights:
// 60 10
// 100 20
// 120 30
// Knapsack capacity: 50