rule hyde_sample_map:
    output:
        hyde_dir_path / "sample.map"
    params:
        outdir = hyde_dir_path
    run:
        shell("mkdir -p {params.outdir}")
        with open(str(output), "w") as outfile:
            for sample in [x.strip() for x in config["parent_1_samples"].split(",")]:
                outfile.write(f"{sample}\t{config['parent_1']}\n")
            for sample in [x.strip() for x in config["parent_2_samples"].split(",")]:
                outfile.write(f"{sample}\t{config['parent_2']}\n")
            for sample in [x.strip() for x in config["hybrids_samples"].split(",")]:
                outfile.write(f"{sample}\t{config['hybrid']}\n")
            outfile.write(f"{config['outgroup_sample']}\tOutgroup")


rule sort_fasta_to_phylip:
    input:
        plink_dir_path / "{prefix}.fasta",
        hyde_dir_path / "sample.map"
    output:
        hyde_dir_path / "{prefix}.sorted.phylip"
    log:
        std=log_dir_path / "sort_fasta_to_phylip.{prefix}.log",
        cluster_log=cluster_log_dir_path / "sort_fasta_to_phylip.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "sort_fasta_to_phylip.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "sort_fasta_to_phylip.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["plink_to_fasta_threads"],
        time=config["plink_to_fasta_time"],
        mem_mb=config["plink_to_fasta_mem_mb"]
    threads:
        config["plink_to_fasta_threads"]
    shell:
        "python3 workflow/scripts/sort_fasta_to_phylip.py {input[0]} {output} {input[1]} > {log.std} 2>&1; "


rule run_hyde:
    input:
        phylip = hyde_dir_path / "{prefix}.sorted.phylip",
        map = hyde_dir_path / "sample.map"
    output:
        hyde_dir_path / "{prefix}-out.txt",
        hyde_dir_path / "{prefix}-out-filtered.txt",
        hyde_dir_path / "{prefix}-ind.txt",
        # hyde_dir_path / "{prefix}-boot.txt",
    params:
        prefix = expand(hyde_dir_path / "{prefix}", prefix=vcf_stem),
        outdir = hyde_dir_path
    log:
        std=log_dir_path / "hyde.{prefix}.log",
        cluster_log=cluster_log_dir_path / "hyde.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "hyde.{prefix}.cluster.err"
    benchmark:
        benchmark_dir_path / "hyde.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["hyde_threads"],
        time=config["hyde_time"],
        mem_mb=config["hyde_mem_mb"]
    threads:
        config["hyde_threads"]
    shell:
        "firstline=$(head -n 1 {input.phylip}); "
        "arr=($firstline); "
        "spscount=${{arr[0]}} > {log.std} 2>&1; "
        "seqlength=${{arr[1]}} >> {log.std} 2>&1; "
        "echo Number of species = $spscount; "
        "echo Sequence length = $seqlength; "
        ""
        "run_hyde_mp.py --infile {input.phylip} --map {input.map} --outgroup Outgroup --num_ind $spscount "
        "--num_sites $seqlength --num_taxa 4 --threads {threads} --prefix {params.prefix} >> {log.std} 2>&1; "
        ""
        "individual_hyde_mp.py --infile {input.phylip} --map {input.map} --triples {params.prefix}-out-filtered.txt "
        "--outgroup Outgroup --num_ind $spscount --num_sites $seqlength --num_taxa 4 --threads {threads} --prefix {params.prefix} >> {log.std} 2>&1; "
        # ""
        # "bootstrap_hyde_mp.py --infile {input.phylip} --map {input.map} --triples {params.prefix}-out-filtered.txt "
        # "--outgroup Outgroup --num_ind $spscount --num_sites $seqlength --num_taxa 4 --threads {threads} --reps 100 >> {log.std} 2>&1; "
        # "mv {params.outdir}/hyde-boot.txt {params.prefix}-boot.txt; "


