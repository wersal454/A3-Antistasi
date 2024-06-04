import csv
import os

def write_to_file(filename="output", data="", category="", extension="txt"):
    with open(f'output/{filename}_{category[0]}.{extension}', 'w+') as file:
        # file.write(str(data))
        for line in data:
            line = line.replace('"[[', "")
            line = line.replace(']]"', "") # Used to remove the string from things such as macros, which don't need strings in cfg
            file.write(str(line) + "\n")

def generate_config(data, category, cur_modset, classes):

    if (cur_modset not in classes):
        classes.append(cur_modset)

    arma_class = f'ITEM({data[1]}, {data[3]}, "{category[0]}", "condition");'

    classes.append(arma_class)