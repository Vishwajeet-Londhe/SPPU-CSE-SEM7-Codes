def fractional_knapsack():
    # Step 1: Take number of items
    n = int(input("Enter number of items: "))

    weights = []
    values = []

    # Step 2: Take weight and value together on same line
    print("\nEnter weight and value for each item (separated by space):")
    for i in range(n):
        w, v = map(float, input(f"Item {i+1}: ").split())
        weights.append(w)
        values.append(v)

    # Step 3: Take knapsack capacity
    capacity = float(input("\nEnter knapsack capacity: "))

    # Step 4: Fractional knapsack logic
    res = 0.0
    items = sorted(zip(weights, values), key=lambda x: x[1] / x[0], reverse=True)

    print("\nItem selection process:")
    for weight, value in items:
        if capacity <= 0:
            break

        if weight <= capacity:
            res += value
            capacity -= weight
            print(f"  Took full item (weight={weight}, value={value})")
        else:
            res += capacity * (value / weight)
            print(f"  Took {capacity} weight fraction of item (weight={weight}, value={value})")
            capacity = 0

    print(f"\n💰 Maximum value in knapsack = {res:.2f}")


if __name__ == "__main__":
    fractional_knapsack()

# Output:
# Enter weight and value for each item (separated by space):
# Item 1: 10 60
# Item 2: 20 100
# Item 3: 30 120

# Enter knapsack capacity: 50