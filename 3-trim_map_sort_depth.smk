

rule trimming:
	input:
                read1="{sample}_1.fastq.gz",
                read2="{sample}_2.fastq.gz"
	output:
		trimmed1="trimmed/{sample}_1.trimmed.fastq.gz",
		trimmed2="trimmed/{sample}_2.trimmed.fastq.gz"
	group: "preprocessing"
	priority: 8
	threads: threads_tot
	conda:
		"fastp"

	shell: "/home/thanatos/miniforge3/envs/fastp/bin/fastp -i {input.read1} -I {input.read2} -o {output.trimmed1} -O {output.trimmed2} --detect_adapter_for_pe -V -w {threads} -x -g -n 2 -5 -3 -p -l 75 -M 24"

rule delete_raw:
	input:
			read_trimmed1="trimmed/{sample}_1.trimmed.fastq.gz",
			read_trimmed2="trimmed/{sample}_2.trimmed.fastq.gz",
			read_deleted1="downloads/fastq/{sample}_1.fastq.gz",
			read_deleted2="downloads/fastq/{sample}_2.fastq.gz",

	priority: 7
	output:
			delete_complete=touch("flag_files/delete_{sample}.done")

	shell:
			"""
			if [ -e {input.read_trimmed1} ]; then rm {input.read_deleted1}; fi
			if [ -e {input.read_trimmed2} ]; then rm {input.read_deleted2}; touch {output.delete_complete}; fi
			"""

rule mapping:
	input:
		genome=expand("{genome}", genome = genome),
		trimmed1="trimmed/{sample}_1.trimmed.fastq.gz",
		trimmed2="trimmed/{sample}_2.trimmed.fastq.gz"
	output:
		mapping="mapped/{sample}.mapping.bam"
	group: "pipeline"
	threads: threads_tot
	priority: 6
	conda:
		"bwa" #use bwa-mem2 but only if there is more than 256Gb of RAM
	shell:
		"/home/thanatos/miniforge3/envs/bwa/bin/bwa-mem2 mem -t {threads} -M {input.genome} {input.trimmed1} {input.trimmed2} | /home/thanatos/miniforge3/envs/bwa/bin/samtools view -bS - > {output.mapping}"

rule sorting:
	input:
		mapping="mapped/{sample}.mapping.bam"
	output:
		sorted="mapped/{sample}.sorted.mapping.bam"
	threads: threads_tot
	priority: 5
	conda:
		"bwa"
	shell:
		"/home/thanatos/miniforge3/envs/bwa/bin/samtools sort -@ {threads} -O bam -o {output.sorted} {input.mapping}"
rule depth:
	input:
		sorted="mapped/{sample}.sorted.mapping.bam"

	output:
		coverage="coverage/{sample}.sorted.mapping.depth"

	group: "pipeline"
	priority: 4
	conda:
		"bwa"
	shell:
		"/home/thanatos/miniforge3/envs/bwa/bin/samtools depth -aa {input.sorted} > {output.coverage}"

rule delete_mapping_trimming:
	input:
			read_trimmed_deleted1="trimmed/{sample}_1.trimmed.fastq.gz",
			read_trimmed_delete2="trimmed/{sample}_2.trimmed.fastq.gz",
			mapping_deleted="mapped/{sample}.mapping.bam",
			sorted_mapped="coverage/{sample}.sorted.mapping.depth"
	priority: 2
	output:
			delete_complete2=touch("flag_files/delete2_{sample}.done")

	shell:
			"""
			if [ -e {input.sorted_mapped} ]; then rm {input.read_trimmed_deleted1}; fi
			if [ -e {input.sorted_mapped} ]; then rm {input.read_trimmed_deleted2}; fi
			if [ -e {input.sorted_mapped} ]; then rm {input.mapping_deleted}; touch(output.deleted2{sample}.done); fi
			"""