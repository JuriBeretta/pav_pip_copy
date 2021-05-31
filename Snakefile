configfile:"config.yaml" 
samples=[]
with open('lista_totale') as f:
	samples = f.read().splitlines()

rule all: 
	input:
		expand("trimmed/{sample}_{read}.trimmed.fastq.gz", sample=samples, read=['1', '2']),
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.coverage.png", sample = samples),
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.absent.list", sample = samples),
		expand("coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depthgenes.coverage.csv", sample = samples)
rule trimming:
	input: 
		read1="path_to_samples/{sample}_1.fastq.gz",
		read2="path_to_samples/{sample}_2.fastq.gz"
	output:
		trimmed1="trimmed/{sample}_1.trimmed.fastq.gz",
		trimmed2="trimmed/{sample}_2.trimmed.fastq.gz"
	
	group: "pipeline"
	
	shell:
		"fastp -i {input.read1} -I {input.read2} -o {output.trimmed1} -O {output.trimmed2} --detect_adapter_for_pe -V -w 16 -x -g -n 2 -5 -3 -p -l 75 -M 24" 

rule mapping:
	input:  
		genome="genome/GCF_902806645.1_cgigas_uk_roslin_v1_genomic.fna",
		trimmed1="trimmed/{sample}_1.trimmed.fastq.gz",
		trimmed2="trimmed/{sample}_2.trimmed.fastq.gz"
	output:
		mapping="mapped/{sample}.mapping.bam"
	group: "pipeline"

	shell:
		"bwa mem -t 64 -M {input.genome} {input.trimmed1} {input.trimmed2} |samtools view -bS - > {output.mapping}"

rule sorting:
	input:
		mapping="mapped/{sample}.mapping.bam"
	output: 
		sorted="mapped/{sample}.sorted.mapping.bam"
	threads: 1
	shell:	
		"samtools sort -@ 64 -O bam -o {output.sorted} {input.mapping}"

rule depth:
	input: 
		sorted="mapped/{sample}.sorted.mapping.bam"
	output:
		coverage="coverage/{sample}.sorted.mapping.depth"
	group: "pipeline"
	shell:
		"samtools depth -aa {input.sorted} > {output.coverage}"

rule analysis:
	input:
		coverage="coverage/{sample}.sorted.mapping.depth"
	 
	output:
		#results_dir = "{sample}.sorted.mapping.depth.d",
		results_fig = "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.coverage.png", 
		results_tab = "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depthgenes.coverage.csv",
		results_lista = "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.absent.list"
		#tempdir = "{sample}.sorted.mapping.depth.d"

	group : "pipeline"
		
	shell:
		"python coverage.py exons_to_gene.tsv busco_exons_to_gene.tsv {input.coverage}" 
