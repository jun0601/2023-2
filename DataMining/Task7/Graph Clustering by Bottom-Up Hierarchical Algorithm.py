import copy
import sys
import time
import os


def get_input_data(filename):
    models = []

    with open(filename, 'r') as input_file:
        for line in input_file:
            node1, node2 = line.strip().split('\t')

            matching_models = [model for model in models if node1 in model[0] or node2 in model[0]]

            if not matching_models:
                new_model = ({node1, node2}, {(node1, node2)})
                models.append(new_model)
            elif len(matching_models) == 1:
                matching_model = matching_models[0]
                matching_model[0].update({node1, node2})
                matching_model[1].add((node1, node2))
            else:
                merged_nodes = {node1, node2}
                merged_edges = {(node1, node2)}
                for matching_model in matching_models:
                    merged_nodes.update(matching_model[0])
                    merged_edges.update(matching_model[1])
                    models.remove(matching_model)
                models.append((merged_nodes, merged_edges))

    return models


def Jaccard_index(graph):
    results = []

    for node1, node2 in graph[1]:
        set_x = {edge[0] for edge in graph[1] if node1 in edge} | {edge[1] for edge in graph[1] if node1 in edge}
        set_y = {edge[0] for edge in graph[1] if node2 in edge} | {edge[1] for edge in graph[1] if node2 in edge}

        set_x.discard(node1)
        set_y.discard(node2)

        intersection, union = len(set_x.intersection(set_y)), len(set_x.union(set_y))
        jaccard_index = intersection / union

        result = (node1, node2, jaccard_index) if node1 < node2 else (node2, node1, jaccard_index)
        results.append(result)

    sorted_results = sorted(results, key=lambda x: (x[2], sorted([x[0], x[1]])), reverse=True)
    filtered_results = [item for item in sorted_results if item[2] > 0.1]
    final_results = [(item[0], item[1]) for item in filtered_results]

    return final_results if len(final_results) > 9 else None


def calculate_compact(sub_graph):
    return (len(sub_graph[1]) * 2) / (len(sub_graph[0]) * (len(sub_graph[0]) - 1)) >= 0.4

def create_graph(sub_graph):
    result_set = []

    for sub in sub_graph:
        val1, val2 = sub
        found_graphs = [graph for graph in result_set if val1 in graph[0] or val2 in graph[0]]

        if not found_graphs:
            new_graph = ({val1, val2}, {(val1, val2)})
            result_set.append(new_graph)
        elif len(found_graphs) == 1:
            check_graph = copy.deepcopy(found_graphs[0])
            check_graph[0].update({val1, val2})
            check_graph[1].add((val1, val2))
            compact = calculate_compact(check_graph)

            if compact:
                found_graph = found_graphs[0]
                found_graph[0].update({val1, val2})
                found_graph[1].add((val1, val2))
        else:
            merged_nodes = {val1, val2}
            merged_edges = {(val1, val2)}

            for found_graph in found_graphs:
                merged_nodes.update(found_graph[0])
                merged_edges.update(found_graph[1])

            compact = calculate_compact((merged_nodes, merged_edges))

            if compact:
                for found_graph in found_graphs:
                    result_set.remove(found_graph)

                result_set.append((merged_nodes, merged_edges))

    return result_set

def Bottom_up(model_set):
    clusters_set = set()

    for graph in model_set:
        sub_graph = Jaccard_index(graph)
        complete_clust = create_graph(sub_graph) if sub_graph else None

        if complete_clust:
            for complete in complete_clust:
                if len(complete[0]) > 9:
                    clusters_set.add(tuple(complete[0]))

    return clusters_set

def Sorted_cluster(cluster, filename):
    sorted_cluster = sorted(cluster, key=lambda x: len(x), reverse=True)
    printed_graphs = set()

    with open(filename, 'w') as file:
        for graph in sorted_cluster:
            if graph not in printed_graphs:
                file.write(f"{len(graph)}: {' '.join(graph)}\n")
                printed_graphs.add(graph)

    return 0


def main():
    input_filename = 'assignment6_input.txt'
    output_filename = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assignment7_output.txt')
    start_time = time.time()
    model_set = get_input_data(input_filename)
    completed = Bottom_up(model_set)
    Sorted_cluster(completed, output_filename)

    elapsed_time = time.time() - start_time
    print(f"Elapsed time: {elapsed_time * 1e6} microsecond")


if __name__ == '__main__':
    main()
