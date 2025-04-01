rule analysis:
	input:
		coverage="coverage/{sample}.sorted.mapping.depth"
	output:
		results_dir = directory("coverage/{sample}.sorted.mapping.depth.d"),
		results_fig= "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.coverage.png",
		results_tab = "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depthgenes.coverage.csv",
		results_lista = "coverage/{sample}.sorted.mapping.depth.d/{sample}.sorted.mapping.depth.absent.list"
		#tempdir = "{sample}.sorted.mapping.depth.d"
	priority: 1
	group: "analysis"

	shell:
		"python coverage.py ./exons_coordinates_transcriptome.tsv ./complete_busco_coordinates_transcriptome.tsv {input.coverage}"

rule sort_abs_lists:
#prendi da SRA_biosample_Bioproject_dati_ecologici.csv i dati su biosample e ecotype
# e fai il sorting del sample tra i diversi ecotipi
