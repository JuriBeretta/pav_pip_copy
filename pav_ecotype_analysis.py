import os
import pandas as pd

# change it to take sample name from the dictionary
samples=[]
filepath="/mnt/Archive1/juri/pav_littorina/reads/pav_analysis_list.txt"
try:
    with open (filepath) as f:
        for line in f:
            samples.append(line.strip())
except FileNotFoundError:
    print (f"Error: File not found at {filepath}")
    exit(1)

def get_biosample_metadata(metadata_file:f"SRA_Biosample_Bioproject_dati_ecologici.csv"):

    df=pd.read_csv(metadata_file)
    df.columns = df.columns.str.strip()

    biosample_to_ecotype = {}
    for _, row in df.iterrows():
        biosample = str(row.iloc[1]).strip()
        ecotype = str(row.iloc[12]).strip()
        if ecotype == "" or ecotype.lower == "not applicable":
            ecotype = "no_ecotype"
    
    biosample_to_ecotype[biosample] = ecotype
    return biosample_to_ecotype

def process_files_by_ecotype (samples, metadata_file, input_folder_template= "coverage/{sample}.sorted.mapping.depth.d/"):
    metadata =get_biosample_metadata(metadata_file)

    grouped_files ={}
    for sample in samples:
        input_folder = input_folder_template.format(sample=sample)
        if not os.path.exists(input_folder):
            print(f"Folder {input_folder} does not exist")
            continue

        for filename in os.listdir(input_folder):
            if filename.endswith(".absent.list"):
                biosample=filename.split(".")[0]
                ecotype=metadata.get(biosample, "no ecotype")

                if ecotype not in grouped_files:
                    grouped_files[ecotype]=[]
                grouped_files[ecotype].append(os.path.join(input_folder, filename))
    return grouped_files

##from this starts older code

#exclude data from no_ecotype
if __name__ == "__main__":
    metadata_file = "SRA_Biosample_Bioproject_dati_ecologici.csv"
    grouped_files = process_files_by_ecotype(samples, metadata_file)

    for ecotype, files in grouped_files.items():
        genes = set()
        for filepath in files:
            try:
                with open(filepath) as f:
                    for line in f:
                        genes.add(line.strip())  # Remove duplicates
            except FileNotFoundError:
                print(f"File not found: {filepath}")

    with open(f"merged_{ecotype}.txt", "w") as out:
        for gene in sorted(genes):
            if not gene.startswith ("Trna"):
                out.write(gene + "\n")

list_merged_files=[f"merged_{ecotype}.txt" for ecotype in grouped_files.keys()]

# Load all merged gene lists

all_sets = []
for name in list_merged_files:
    filepath = f"{name}" #Add path when needed
    with open(filepath) as f:
        all_sets.append(set(f.read().splitlines()))


# Find unique genes for each list
for i, name in enumerate(list_merged_files):

    # Create a copy of all sets except the current one
    other_sets = all_sets.copy()
    current_set = other_sets.pop(i)

    # Union of all other sets

    gene_unique = set.union(*other_sets) if other_sets else set()


    unique_to_current = current_set - gene_unique

    # Write the unique genes to a file
    for ecotype in grouped_files.keys():
        with open(f"unique_to_{ecotype}.txt", "w") as out:
            for gene in sorted(unique_to_current):
                out.write(gene + "\n")
# Find unique genes for each list
for i, name in enumerate(list_merged_files):

    # Create a copy of all sets except the current one
    other_sets = all_sets.copy()
    current_set = other_sets.pop(i)

    # Union of all other sets

    gene_unique = set.union(*other_sets) if other_sets else set()


    unique_to_current = current_set - gene_unique

    # Write the unique genes to a file
    for ecotype in grouped_files.keys():
        with open(f"unique_to_{ecotype}.txt", "w") as out:
            for gene in sorted(unique_to_current):
                out.write(gene + "\n")
