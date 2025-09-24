#include <iostream>
#include <cstdlib>
#include <ctime>
using namespace std;

long long detSteps = 0, randSteps = 0;

int partition(int arr[], int low, int high, long long &steps) {
    int pivot = arr[high], i = low - 1;
    for (int j = low; j < high; j++) {
        steps++; // counting comparison
        if (arr[j] <= pivot) swap(arr[++i], arr[j]);
    }
    swap(arr[i + 1], arr[high]);
    return i + 1;
}

int randomPartition(int arr[], int low, int high, long long &steps) {
    int randIndex = low + rand() % (high - low + 1);
    swap(arr[randIndex], arr[high]); // random pivot
    return partition(arr, low, high, steps);
}

void quickSortDet(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high, detSteps);
        quickSortDet(arr, low, pi - 1);
        quickSortDet(arr, pi + 1, high);
    }
}

void quickSortRand(int arr[], int low, int high) {
    if (low < high) {
        int pi = randomPartition(arr, low, high, randSteps);
        quickSortRand(arr, low, pi - 1);
        quickSortRand(arr, pi + 1, high);
    }
}

int main() {
    srand(time(0));
    int n;
    cout << "Enter number of elements: ";
    cin >> n;
    int arr1[n], arr2[n];
    cout << "Enter elements: ";
    for (int i = 0; i < n; i++) cin >> arr1[i], arr2[i] = arr1[i];

    quickSortDet(arr1, 0, n - 1);
    quickSortRand(arr2, 0, n - 1);

    cout << "\nDeterministic QuickSort: ";
    for (int x : arr1) cout << x << " ";
    cout << "\nSteps (approx comparisons): " << detSteps;

    cout << "\n\nRandomized QuickSort: ";
    for (int x : arr2) cout << x << " ";
    cout << "\nSteps (approx comparisons): " << randSteps << "\n";
}

//Input
// Enter number of elements: 6
// Enter elements: 10 7 8 9 1 5