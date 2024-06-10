ruleorder: admixture > cv_errors

rule admixture:
    input:
        plink_dir_path / "{prefix}.bed",
    output:
        Q = admixture_dir_path / "{seed}" / "{prefix}.{k}.Q",
        P = admixture_dir_path / "{seed}" / "{prefix}.{k}.P",
        log = touch(admixture_dir_path/ "{seed}" / "{prefix}.{k}.log")
    params:
        outpath = admixture_dir_path,
        k="{k}",
        seed="{seed}",
        admixture_options = config["admixture_options"],
    log:
        std=log_dir_path / "admixture.{seed}.{prefix}.{k}.log",
        cluster_log=cluster_log_dir_path / "admixture.{seed}.{prefix}.{k}.cluster.log",
        cluster_err=cluster_log_dir_path / "admixture.{seed}.{prefix}.{k}.cluster.err"
    benchmark:
        benchmark_dir_path / "admixture.{seed}.{prefix}.{k}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["admixture_threads"],
        time=config["admixture_time"],
        mem_mb=config["admixture_mem_mb"]
    threads:
        config["admixture_threads"]
    shell:
        "mkdir -p {params.outpath}/{params.seed}; cd {params.outpath}/{params.seed}; "
        "admixture --seed={params.seed} -j{threads} --cv ../../../{input} {params.k} > ../../../{output.log} 2> ../../../{log.std}; "


rule cv_errors:
    input:
        expand(admixture_dir_path / "{seed}" / "{prefix}.{k}.log", seed=config["admixture_seeds"], prefix=vcf_stem, k=config["admixture_K"])
    output:
        admixture_dir_path / "{seed}" / "{prefix}.cv_errors.csv"
    params:
        outpath = admixture_dir_path,
        k=config["admixture_K"],
        seed="{seed}",
        prefix="{prefix}"
    log:
        std=log_dir_path / "cv_errors.{seed}.{prefix}.log",
        cluster_log=cluster_log_dir_path / "cv_errors.{seed}.{prefix}.cluster.log",
        cluster_err=cluster_log_dir_path / "cv_errors.{seed}.{prefix}.cluster.log"
    benchmark:
        benchmark_dir_path / "cv_errors.{seed}.{prefix}.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["cv_errors_threads"],
        time=config["cv_errors_time"],
        mem_mb=config["cv_errors_mem_mb"]
    threads:
        config["cv_errors_threads"]
    shell:
        "grep -h CV {input} >> {output} 2> {log.std}" # пофиксить, чтобы не все сиды попадали в каждый файл


