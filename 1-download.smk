configfile= "config.yaml"
threads_tot=config['thereads_config']
with open ('sample_list.txt') as f:
    sample=f.read().splitlines()

rule fetch_and_rename:
    output:
        fetch_done="flag_files/fetchngs.done",
        reads_SRR1=expand("downloads/fastq/{sample}_1.fastq.gz", sample=samples),
        reads_SRR2=expand("downloads/fastq/{sample}_2.fastq.gz", sample=samples)
    group: "preprocessing"
	params:	
		sample_list=config['fetchngs']['accession_list']
		outdir=config['fetchngs']['outdir']
	
    priority: 10
    shell:
        """
        # Run fetchngs to download the files
        nextflow run nf-core/fetchngs --input {sample_list} -profile conda --outdir {outdir}

        # Rename the files to remove the SRX prefix
        for file in downloads/fastq/SRX*_SRR*.fastq.gz; do
            mv "$file" "$(echo $file | sed -E 's/^.*_SRR/SRR/')"
        done

        # Create the checkpoint file
        touch {output.fetch_done}
        """