from pathlib import Path

# ---- Setup config ----
configfile: "config/default.yaml"

# ---- Setup paths ----
cluster_log_dir_path = Path(config["cluster_log_dir"])
log_dir_path = Path(config["log_dir"])
benchmark_dir_path = Path(config["benchmark_dir"])
output_dir_path = Path(config["output_dir"])

plink_dir_path = output_dir_path / config["plink_dir"]
admixture_dir_path = output_dir_path / config["admixture_dir"]
hyde_dir_path = output_dir_path / config["hyde_dir"]
admixtools_dir_path = output_dir_path / config["admixtools_dir"]

vcf_parent = Path(config["input_vcf_path"]).parent
vcf_stem = Path(config["input_vcf_path"]).stem[:-4] # .vcf.gz

# admixture_tasks
admixture_tasks_list = []
for seed in config["admixture_seeds"]:
    for k in config["admixture_K"]:
        admixture_tasks_list.append(expand(admixture_dir_path / "{seed}/{prefix}.{k}.Q", seed=seed,prefix=vcf_stem,k=k))

localrules: all

rule all:
    input:
        # ---- ADMIXTURE ----
        admixture_tasks_list,
        expand(admixture_dir_path / "{seed}" / "{prefix}.cv_errors.csv", seed=config["admixture_seeds"], prefix=vcf_stem),
        # ---- HyDe ----
        expand(hyde_dir_path/ "{prefix}-out.txt", prefix=vcf_stem),
        # ---- Admixtools ----
        expand(admixtools_dir_path/ "{prefix}.geno", prefix=vcf_stem),



# ---- Load rules ----
include: "workflow/rules/plink.smk"
include: "workflow/rules/admixture.smk"
include: "workflow/rules/hyde.smk"
include: "workflow/rules/admixtools.smk"


