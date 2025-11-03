import random

# Global step counters
det_steps = 0
rand_steps = 0

def partition(arr, low, high, steps_counter):
    steps = 0
    pivot = arr[high]
    i = low - 1
    for j in range(low, high):
        steps += 1  # comparison
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    steps_counter[0] += steps
    return i + 1

def random_partition(arr, low, high, steps_counter):
    rand_index = random.randint(low, high)
    arr[rand_index], arr[high] = arr[high], arr[rand_index]  # random pivot
    return partition(arr, low, high, steps_counter)

def quick_sort_det(arr, low, high, steps_counter):
    if low < high:
        pi = partition(arr, low, high, steps_counter)
        quick_sort_det(arr, low, pi - 1, steps_counter)
        quick_sort_det(arr, pi + 1, high, steps_counter)

def quick_sort_rand(arr, low, high, steps_counter):
    if low < high:
        pi = random_partition(arr, low, high, steps_counter)
        quick_sort_rand(arr, low, pi - 1, steps_counter)
        quick_sort_rand(arr, pi + 1, high, steps_counter)

# --- Main program ---
if __name__ == "__main__":
    n = int(input("Enter number of elements: "))
    arr1 = list(map(int, input("Enter elements: ").split()))
    arr2 = arr1.copy()

    det_counter = [0]
    rand_counter = [0]

    quick_sort_det(arr1, 0, n - 1, det_counter)
    quick_sort_rand(arr2, 0, n - 1, rand_counter)

    print("\nDeterministic QuickSort:", *arr1)
    print("Steps (approx comparisons):", det_counter[0])

    print("\nRandomized QuickSort:", *arr2)
    print("Steps (approx comparisons):", rand_counter[0])
