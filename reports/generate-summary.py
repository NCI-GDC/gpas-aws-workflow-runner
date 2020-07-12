import argparse
from statistics import median

parser = argparse.ArgumentParser(description="Summarizes processed system activity reports")
parser.add_argument('--input', dest="InputFile", type=str, help="The name of the input file", required=True)

args = parser.parse_args()

header = "Workflow\tInstance_Type\tMin\tMax\tMedian"


def main():
    with open(vars(args)["InputFile"], "r") as input_file:

        current_instance_type = ""
        current_workflow = ""
        val_collector = []

        print(header)

        for line in input_file:
            line = line.strip()

            # check if this is a header
            if line.startswith("Workflow") or len(line) == 0:
                continue

            x = line.split()
            workflow = x[0]
            instance_type = x[1]

            if current_workflow == "":
                current_workflow = workflow
            if current_instance_type == "":
                current_instance_type = instance_type

            # if the workflow, or instance type has changed then its a new summary
            if (current_workflow != workflow or current_instance_type != instance_type) and len(val_collector) > 0:
                emit_summary(current_workflow, current_instance_type, val_collector)
                val_collector = []
                current_instance_type = instance_type
                current_workflow = workflow

            val_collector.append(float(x[5]))

        if len(val_collector) > 0:
            emit_summary(workflow, instance_type, val_collector)


def emit_summary(workflow, instance_type, values):
    minimum, maximum, med = summarize_values(values)
    print(f"{workflow}\t{instance_type}\t{minimum}\t{maximum}\t{med}")

def summarize_values(values):
    minimum = min(values)
    maximum = max(values)
    med = median(values)
    return minimum, maximum, med


if __name__ == '__main__':
    main()
