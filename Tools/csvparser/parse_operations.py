import csv
import os

import file_operations
import csv_operations

def parse_file(filename="armedcar", category_custom=""):
    
    print(f"\n<------- Currently parsing: {filename}.csv ------->\n")

    if filename != "":

        with open(f'csv/{filename}.csv', newline='', errors="ignore") as csvfile:
            reader = csv.reader(csvfile, delimiter=',', quotechar='|')
            data = read_parsed_file(reader, filename, category_custom)

    return data

def read_parsed_file(parsed_data, filename, category_custom=""):
    data_write = []
    classes = []
    cur_modset = ""

    modsets = []
    categories = []

    if (category_custom != ""):

        category = [category_custom]

    else:

        category = [filename]

    categories.extend(category)

    data_write.append(category)

    for row in parsed_data:
        row_joined = ":".join(row)
        row_split = row_joined.split(":")
        
        for test in [row_split]:
            if (test != ''):
                modset = test[0]
                classname = test[1]
                name = test[2]
                price = test[-1]

                # Not a fuckin clue, don't ask
                if (type(price) == str and price.isdigit()):
                    price = int(float(price))

                # If price isn't an integer (usually due to a comment in the last row), step back 1 element
                if (type(price) != int):
                    price = test[-2]

                # If price is a float, yeet that out
                # (int() didn't work)
                if (type(price) == str and "." in price):
                    price = price[:-2]

                data = [classname, name, price, category]
                
                # Grab the modset if applicable
                if (classname != "className" and name == "" and price == ""):
                    if (modset != cur_modset or cur_modset == ""):
                        cur_modset = modset.replace(".", "").lower()
                        cur_modset = modset.replace(" ", "").lower()
                        modsets.append(cur_modset)

                data.insert(0, cur_modset)

                # Get rid of data that isn't needed (headers, basically)
                if (classname == "className"):
                    data = ['', '', '']

                if ('' not in data):
                    # print(data)

                    data_write.append(data)

                    # file_operations.generate_config(data, category, cur_modset, classes)

    # file_operations.write_to_file("output", classes, category)

    return [data_write, modsets, categories]

def parse_all_csv_files_in_dir(prefix="BlackMarketVehicles - "):
    files = csv_operations.grab_csv_files_in_dir(prefix=prefix)

    all_vehicles = []
    all_categories = []
    all_classes = []

    for file in files:
        category_custom = file[:-4]

        if (prefix == ""):
            data = parse_file(f"{file[:-4]}", category_custom)
        else:
            data = parse_file(f"{prefix}{file[:-4]}", category_custom)

        data_vehicles = data[0]
        data_categories = data[2]

        all_vehicles.extend(data_vehicles)
        all_categories.extend(data_categories)
    
    list_dict = convert_list_to_dict(all_vehicles, all_categories)
    modsets = list(list_dict.keys())
    # print(list_dict)

    for modset in modsets:

        arma_classes = generate_config_list(list_dict, modset)
        all_classes.extend(arma_classes + ["\n"])
        file_operations.write_to_file("output", arma_classes, [modset])

    file_operations.write_to_file("output", all_classes, ["ALL"])

    # for modset in data_modsets:

def generate_config_list(list_data, modset):
    print(list_data)

    arma_classes = []
    mod_header = (f"class vehicles_{modset.lower()} : vehicles_base")
    arma_classes.append(mod_header + "\n{")
    
    vehicle_types = list(list_data[modset].keys())

    print(f"Vehicle types are: {vehicle_types}")

    for vehicle_type in vehicle_types:
        vehicles = list(list_data[modset][vehicle_type].keys())

        if (vehicles == {} or vehicles == []):
            continue

        print(f"Vehicles are: {vehicles}")

        for vehicle in vehicles:
            vehicle_classname = vehicle
            vehicle_name = list_data[modset][vehicle_type][vehicle_classname]["name"]
            vehicle_price = list_data[modset][vehicle_type][vehicle_classname]["price"]

            arma_class = f'    ITEM({vehicle_classname}, {vehicle_price}, "{vehicle_type}", "true");'

            # print([vehicle_type, vehicle_classname, vehicle_name, vehicle_price])
            # print(arma_class)
            arma_classes.append(arma_class)
        
    arma_classes.append("};")
    print(arma_classes)
    return arma_classes


def convert_list_to_dict(list_data, list_categories):
    item_dictionary = {}
    print(list_categories)

    for item in range(len(list_data)):
        modset = [element for element in list_data[item] if element == list_data[item][0]]

        for category in list_categories:
            if (category in modset or isinstance(modset, str)):
                modset.remove(category)

        # print(modset)

        if (modset != [] and (modset[0] not in list_categories)):
            item_dictionary.update({modset[0]: {}})

        for category in list_categories:
            if (modset != []):
                # print(modset)
                item_dictionary[modset[0]].update({category: {}})

    for item in list_data:

        modset = item[0]

        # print(modset)

        if (modset in list_categories):
            continue

        # print(item)

        classname = item[1]
        name = item[2]
        price = item[3]
        category = item[4]

        # print(category)

        item_dictionary[modset][category[0]][classname] = ({"name": name, "price": price, "category": category})

    return item_dictionary