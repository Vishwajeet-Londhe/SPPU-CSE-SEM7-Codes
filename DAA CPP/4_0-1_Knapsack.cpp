#include <iostream>
#include <vector>
using namespace std;

int knapsack(int W, vector<int> &wt, vector<int> &val, int n) {
    // Create DP table
    vector<vector<int>> dp(n + 1, vector<int>(W + 1, 0));

    // Build table dp[][] in bottom-up manner
    for (int i = 0; i <= n; i++) {
        for (int w = 0; w <= W; w++) {
            if (i == 0 || w == 0)
                dp[i][w] = 0;  // Base case
            else if (wt[i - 1] <= w)
                dp[i][w] = max(val[i - 1] + dp[i - 1][w - wt[i - 1]], dp[i - 1][w]);
            else
                dp[i][w] = dp[i - 1][w];
        }
    }

    // dp[n][W] contains the maximum value
    return dp[n][W];
}

int main() {
    int n, W;
    cout << "Enter number of items: ";
    cin >> n;

    vector<int> val(n), wt(n);
    cout << "Enter value and weight of each item:\n";
    for (int i = 0; i < n; i++)
        cin >> val[i] >> wt[i];

    cout << "Enter capacity of knapsack: ";
    cin >> W;

    int maxValue = knapsack(W, wt, val, n);
    cout << "Maximum value in 0-1 Knapsack = " << maxValue << endl;

    return 0;
}

// Input

// Number of items: 3
// Values & weights:
// 60 10
// 100 20
// 120 30
// Knapsack capacity: 50