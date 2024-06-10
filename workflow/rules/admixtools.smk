rule plink_to_eigenstrat:
    input:
        plink_dir_path / "{prefix}.bed",
        plink_dir_path / "{prefix}.bim",
        plink_dir_path / "{prefix}.fam"
    output:
        admixtools_dir_path / "{prefix}.geno",
        admixtools_dir_path / "{prefix}.snp",
        admixtools_dir_path / "{prefix}.ind",
    params:
        prefix = expand("{prefix}", prefix=vcf_stem),
        prink_dir = plink_dir_path,
        outdir = admixtools_dir_path
    log:
        std=log_dir_path / "plink_to_eigenstrat.{prefix}.log",
        cluster_log=cluster_log_dir_path / "plink_to_eigenstrat.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "plink_to_eigenstrat.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "plink_to_eigenstrat.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["plink_to_fasta_threads"],
        time=config["plink_to_fasta_time"],
        mem_mb=config["plink_to_fasta_mem_mb"]
    threads:
        config["plink_to_fasta_threads"]
    shell:
        'convertf -p <(echo "genotypename: {params.prink_dir}/{params.prefix}.bed\n'
        'snpname: {params.prink_dir}/{params.prefix}.bim\n'
        'indivname: {params.prink_dir}/{params.prefix}.fam\n'
        'outputformat: EIGENSTRAT\n'
        'genotypeoutname: {params.outdir}/{params.prefix}.geno\n'
        'snpoutname: {params.outdir}/{params.prefix}.snp\n'
        'indivoutname: {params.outdir}/{params.prefix}.ind") 2> {log.std} '

    with

with open(output, “w”) as out:
    for l in sorted(open(input.a)):
        out.write(l)
# rule D_stat:
    # input:
    #     admixtools_dir_path / "{prefix}.geno",
    #     admixtools_dir_path / "{prefix}.snp",
    #     admixtools_dir_path / "{prefix}.ind",
    # output:
    #     admixtools_dir_path / "{prefix}.geno",
    #     admixtools_dir_path / "{prefix}.snp",
    #     admixtools_dir_path / "{prefix}.ind",
    # # params:
    # #     prefix = expand("{prefix}", prefix=vcf_stem),
    # #     prink_dir = plink_dir_path,
    # #     outdir = admixtools_dir_path
    # # log:
    # #     std=log_dir_path / "plink_to_eigenstrat.{prefix}.log",
    # #     cluster_log=cluster_log_dir_path / "plink_to_eigenstrat.{prefix}.cluster.log",
    # #     cluster_err=cluster_log_dir_path / "plink_to_eigenstrat.{prefix}.cluster.err"
    # # benchmark:
    # #     benchmark_dir_path / "plink_to_eigenstrat.{prefix}.benchmark.txt"
    # # conda:
    # #     "../../%s" % config["conda_config"]
    # # resources:
    # #     cpus=config["plink_to_fasta_threads"],
    # #     time=config["plink_to_fasta_time"],
    # #     mem_mb=config["plink_to_fasta_mem_mb"]
    # # threads:
    # #     config["plink_to_fasta_threads"]
    # # shell:
    # #     'convertf -p <(echo "genotypename: {params.prink_dir}/{params.prefix}.bed\n'
    # #     'snpname: {params.prink_dir}/{params.prefix}.bim\n'
    # #     'indivname: {params.prink_dir}/{params.prefix}.fam\n'
    # #     'outputformat: EIGENSTRAT\n'
    # #     'genotypeoutname: {params.outdir}/{params.prefix}.geno\n'
    # #     'snpoutname: {params.outdir}/{params.prefix}.snp\n'
    # #     'indivoutname: {params.outdir}/{params.prefix}.ind") 2> {log.std} '


