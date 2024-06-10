rule plink:
    input:
        vcf_parent / "{prefix}.vcf.gz"
    output:
        plink_dir_path / "{prefix}.prune.in",
        plink_dir_path / "{prefix}.prune.out",
        plink_dir_path / "{prefix}.nosex",
        plink_dir_path / "{prefix}.bed",
        plink_dir_path / "{prefix}.bim",
        plink_dir_path / "{prefix}.bim.raw",
        plink_dir_path / "{prefix}.fam",
        plink_dir_path / "{prefix}.fam.raw",
        plink_dir_path / "{prefix}.eigenval",
        plink_dir_path / "{prefix}.eigenvec",
        plink_dir_path / "{prefix}.log",
    params:
        output_prefix = expand(plink_dir_path / "{prefix}", prefix=vcf_stem),
        plink_ld_options = config["plink_ld_options"],
        plink_filt_options = config["plink_filt_options"],
    log:
        std=log_dir_path / "plink.{prefix}.log",
        cluster_log=cluster_log_dir_path / "plink.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "plink.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "plink.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["plink_threads"],
        time=config["plink_time"],
        mem_mb=config["plink_mem_mb"]
    threads:
        config["plink_threads"]
    shell:
        "plink --threads {threads} --vcf {input} --out {params.output_prefix} {params.plink_ld_options} 1>> {log.std} 2>&1; "
        "plink --threads {threads} --vcf {input} --out {params.output_prefix} --extract {params.output_prefix}.prune.in {params.plink_filt_options} 1>> {log.std} 2>&1; "
        "mv {params.output_prefix}.bim {params.output_prefix}.bim.raw 1>> {log.std} 2>&1; "
        "cat {params.output_prefix}.bim.raw | awk -F '_' '{{print $3\"_\"$4\"_\"$5}}' > {params.output_prefix}.bim 2>&1; "
        "mv {params.output_prefix}.fam {params.output_prefix}.fam.raw 1>> {log.std} 2>&1; "
        "cat {params.output_prefix}.fam.raw | awk '{{print $1\"\\t\"$2\"\\t\"$3\"\\t\"$4\"\\t\"$5\"\\t\"$6}}' > {params.output_prefix}.fam 2>&1; "


rule plink_to_fasta:
    input:
        plink_dir_path / "{prefix}.bed",
        plink_dir_path / "{prefix}.bim",
        plink_dir_path / "{prefix}.fam"
    output:
        plink_dir_path / "{prefix}.fasta"
    params:
        prefix = expand(plink_dir_path / "{prefix}", prefix=vcf_stem),
    log:
        std=log_dir_path / "plink_to_fasta.{prefix}.log",
        cluster_log=cluster_log_dir_path / "plink_to_fasta.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "plink_to_fasta.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "plink_to_fasta.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["plink_to_fasta_threads"],
        time=config["plink_to_fasta_time"],
        mem_mb=config["plink_to_fasta_mem_mb"]
    threads:
        config["plink_to_fasta_threads"]
    shell:
        "extract_sequences_from_plink_binary_data.py -i {params.prefix} -o {output} > {log.std} 2>&1 "


rule fasta_to_phylip:
    input:
        plink_dir_path / "{prefix}.fasta"
    output:
        plink_dir_path / "{prefix}.phylip"
    params:
        prefix = expand(plink_dir_path / "{prefix}", prefix=vcf_stem),
    log:
        std=log_dir_path / "plink_to_phylip.{prefix}.log",
        cluster_log=cluster_log_dir_path / "plink_to_phylip.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "plink_to_phylip.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "plink_to_phylip.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["plink_to_fasta_threads"],
        time=config["plink_to_fasta_time"],
        mem_mb=config["plink_to_fasta_mem_mb"]
    threads:
        config["plink_to_fasta_threads"]
    shell:
        "python3 workflow/scripts/fasta_to_phylip.py -i {input} -o {output} > {log.std} 2>&1; "


