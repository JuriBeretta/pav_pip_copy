configfile:"config.yaml"
genome=config['genome']
threads_tot=config['threads_config']
samples=[]
with open('sample_list.csv') as f:
        samples = f.read().splitlines()

include: "1-download.snakefile"
include: "2-merge.snakefile"
include: "3-trim_map_sort_depth.snakefile"
include: "4-coverage.snakefile"

rule all:
	input:
		"flag_files/fetchngs.done",
		expand("trimmed/{sample}_{read}.trimmed.fastq.gz", sample=samples, read=['1', '2']),
		expand("flag_filesdelete_{sample}.done", sample=samples),
		expand("coverage/{sample}.sorted.mapping.depth", sample=samples),
		expand("flag_files/delete2_{sample}.done", sample=samples),
		#expand("coverage/{sample}.sorted.mapping.depth.d",)		
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.coverage.png", sample=samples),
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depthgenes.coverage.csv", sample=samples),
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.absent.list", sample=samples)




