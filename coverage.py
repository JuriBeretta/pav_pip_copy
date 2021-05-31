import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sys 
import os

tot_genes_file=sys.argv[1]
BUSCO_exons_file=sys.argv[2]
cov_file=sys.argv[3]

def flatten_exons(gene):
    global cov_map 
    contig = gene.contig.values[0]
    start = min(gene.start.values)-1
    end = max(gene.end.values)
    size = end - start
    mask = np.full([size], False)
    pairs= np.array([gene.start.values, gene.end.values])
    startendarray = pairs.flatten('F')
    for i in range(0, startendarray.size, 2):
        this_exon = np.arange(startendarray[i]-start,startendarray[i+1]-start)
        mask[this_exon] = True
    sub_cov_map = cov_map[contig][start:start+size]
    try:
        return sub_cov_map[mask].mean()
    except Exception as e:
        return np.nan

BUSCO_exons = pd.read_csv(BUSCO_exons_file, sep="\t" , names= ["contig", "start", "end", "ID_gene"])

tot_genes = pd.read_csv(tot_genes_file, sep = "\t", names = ["contig", "start", "end", "ID_gene"])

cov = pd.read_csv(cov_file, sep = "\t", names = ["contig", "position", "coverage"])

base_name = cov_file.split("/")[-1]

cov_map = cov.groupby("contig")["coverage"].apply(np.array).to_dict()

coverage_genes_busco = BUSCO_exons.groupby("ID_gene").apply(flatten_exons)

SOGLIA = coverage_genes_busco.median()/8

coverage_tot_genes = tot_genes.groupby("ID_gene").apply(flatten_exons)

sns.distplot(coverage_tot_genes[coverage_tot_genes<100]).set_title(base_name)
try: 
    os.mkdir("coverage/"+base_name+".d")
except:
    pass

with open("coverage/"+base_name+".d/"+base_name+".absent.list", "w") as of:
    for gene in coverage_tot_genes[coverage_tot_genes<SOGLIA].index:
        of.write("{}\n".format(gene))
del cov_map

plt.savefig("coverage/"+base_name+".d/"+base_name+".coverage.png")

coverage_tot_genes.to_csv("coverage/"+base_name+".d/"+base_name+"genes.coverage.csv")

