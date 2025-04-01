###
#samples=[]
#with open('sample_list.txt') as f:
#        samples = f.read().splitlines()
###

def get_biosamples():
    """Extract unique BioSample IDs from the mapping file."""
    biosamples = set()
    for sample in samples #RN samples is not defined, 
                          #should i add it here or is it enough to define it in rule_all.snakefile
        filepath = f"downloads/metadata/{sample}.runinfo_ftp.tsv"
        with open(filepath) as f:
            for line in f:
                biosample = line.strip().split("\t")[3]
                biosamples.add(biosample)
        return list(biosamples)

def get_srr_files(biosample):
    """Find all SRR FASTQ files corresponding to a given BioSample."""
    for sample in samples #RN samples is not defined, 
                          #should i add it here or is it enough to define it in rule_all.snakefile
        filepath = f"downloads/metadata/{sample}.runinfo_ftp.tsv"
        srr_files = []
        with open(filepath) as f:
            for line in f:
                columns = line.strip().split("\t")
                srr = columns[1]  # Assuming SRR is in the second column
                sample = columns[3]  # Assuming BioSample is in the fourth column
                if sample == biosample:
                    srr_files.append(f"fetchngs_output/{srr}.fastq.gz")
        return srr_files

rule merge_fastq:
    input:
        lambda wildcards: get_srr_files(wildcards.biosample)
    output:
        "merged/{biosample}.fastq.gz"
    shell:
        "cat {input} > {output}"