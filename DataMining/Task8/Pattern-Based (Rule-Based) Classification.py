from itertools import combinations
import time

def create_k_items(current_items, k):
    return [val1.union(val2) for i, val1 in enumerate(current_items) for j, val2 in enumerate(current_items[i+1:], start=i+1) if len(val1.union(val2)) == k]

def rule(items, frequent_items, min_confidence):
    rules = []
    diseases = {'BreastCancer', 'ColonCancer'}

    for itemset, support in frequent_items.items():
        itemset = set(itemset)
        rules.extend([(set(comb), itemset - set(comb), support) for size in range(1, len(itemset)) for comb in
                      combinations(itemset, size) if any(disease in (itemset - set(comb)) for disease in diseases)])

    filtered_rules = calculate_confidence(items, rules, min_confidence)
    return filtered_rules

def count_items(items, itemset):
    return sum(itemset.issubset(s) for s in items)

def calculate_confidence(items, rules, min_confidence):
    filtered_rules = [
        (comb_set, T_set, support, confidence)
        for comb_set, T_set, support in rules
        if (confidence := support / (count_items(items, comb_set) / len(items))) >= min_confidence
    ]
    return filtered_rules

def filter_items(items, k_items, min_support, num):
    return dict(
        (tuple(sorted(itemset)), count / num)
        for itemset, count in ((itemset, count_items(items, itemset)) for itemset in k_items)
        if count / num >= min_support
    )

def apriori_item(items, min_support):
    frequent_items = {}
    num = len(items)
    f_item_counts = {}

    for itemset in items:
        for item in itemset:
            f_item_counts[item] = f_item_counts.get(item, 0) + 1

    frequent_items = {
        item: count / num
        for item, count in f_item_counts.items()
        if count / num >= min_support
    }
    current_items = [set([item]) for item in frequent_items]

    while current_items:
        k_items = create_k_items(current_items, len(current_items[0]) + 1)
        datas = filter_items(items, k_items, min_support, num)

        if not datas:
            break

        frequent_items.update(datas)
        current_items = [set(itemset) for itemset in datas]

    return frequent_items

def input_data(file_name):
    with open(file_name, 'r') as file:
        lines = file.readlines()

    items = [set([f'gene{i - 1} {value.lower()}' for i, value in enumerate(line.strip().split('\t')[1:-1], start=1)] + [line.strip().split('\t')[-1]]) for line in lines]

    return items

def output_file(filename, rules):
    with open(filename, 'w') as file:
        for gene_set, outcome_set, support, confidence in rules:
            if len(gene_set) < 2:
                continue

            gene_str = ', '.join(gene_set)
            outcome_str = ', '.join(outcome_set)
            support_percent = support * 100
            confidence_percent = confidence * 100
            output_line = f"{{{gene_str}}} → {{{outcome_str}}}: {support_percent:.2f}% support, {confidence_percent:.2f}% confidence\n"
            file.write(output_line)
    return 0

def main():
    file_name = 'assignment8_input.txt'
    min_support = 0.30
    min_confidence = 0.60
    start_time = time.time()

    items = input_data(file_name)
    frequent_items = apriori_item(items, min_support)
    rules = rule(items, frequent_items, min_confidence)

    output_name = 'assignment8_output.txt'
    output_file(output_name, rules)

    elapsed_time = time.time() - start_time
    print(f"Elapsed time: {elapsed_time * 1e6} microsecond")

if __name__ == "__main__":
    main()