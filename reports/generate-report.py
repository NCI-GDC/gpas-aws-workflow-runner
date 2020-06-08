#!/usr/bin/python3

import argparse

header = "Workflow\tInstance type\tCumulative Time(s)\tMetric Group\tMetric\tValue"

parser = argparse.ArgumentParser(description="Reports on consolidated system activity reports")
parser.add_argument('--input', dest="InputFile", type=str, help="The name of the input file", required=True)

args = parser.parse_args()


def main():
    with open(vars(args)["InputFile"], "r") as input_file:

        accumulated_time = 0
        current_workflow = ""
        current_instance_type = ""
        print(header)

        for line in input_file:
            x = split_input_line(line.strip())
            y = split_path(x[0])
            value = x[5]
            metric = x[4]
            metric_group = x[3]
            instance_type = y[1]
            workflow = y[0]

            if workflow != current_workflow or instance_type != current_instance_type:
                accumulated_time = 0
                current_workflow = workflow
                current_instance_type = instance_type

            accumulated_time += int(x[1])
            print(f"{workflow}\t{instance_type}\t{accumulated_time}\t{metric}\t{metric_group}\t{value}")


def split_input_line(input_line):
    x = input_line.split("\t")
    return x


def split_path(path):
    x = path.split("/")
    return x


if __name__ == '__main__':
    main()
