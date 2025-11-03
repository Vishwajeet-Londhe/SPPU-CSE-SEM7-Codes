def knapsack_dp():
    # Step 1: Take user input
    n = int(input("Enter number of items: "))

    weights = []
    values = []

    print("\nEnter weight and value (profit) for each item separated by space:")
    for i in range(n):
        w, v = map(int, input(f"Item {i+1}: ").split())
        weights.append(w)
        values.append(v)

    W = int(input("\nEnter maximum capacity of knapsack: "))

    # Step 2: Create DP table
    dp = [[0 for _ in range(W + 1)] for _ in range(n + 1)]

    # Step 3: Build table bottom-up
    for i in range(1, n + 1):
        for w in range(1, W + 1):
            if weights[i - 1] <= w:
                include = values[i - 1] + dp[i - 1][w - weights[i - 1]]
                exclude = dp[i - 1][w]
                dp[i][w] = max(include, exclude)
            else:
                dp[i][w] = dp[i - 1][w]

    # Step 4: Output result
    print("\n💰 Maximum profit that can be obtained:", dp[n][W])


if __name__ == "__main__":
    knapsack_dp()