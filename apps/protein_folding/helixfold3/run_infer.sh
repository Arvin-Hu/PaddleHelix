#!/bin/bash
start=$(date +%s)

PYTHON_BIN="/opt/conda/envs/helixfold/bin/python3"  # conda环境中的Python路径
ENV_BIN="/opt/conda/envs/helixfold/bin"  # conda环境中的二进制文件路径
MAXIT_SRC="/usr/local/maxit"  # Maxit的安装路径
export OBABEL_BIN="/opt/conda/envs/helixfold/bin"  # OpenBabel的安装路径
DATA_DIR="/a100_nas/ai4s/data_set_helixfold3"
export PATH="$MAXIT_SRC/bin:$PATH"

export OMP_NUM_THREADS=1  # 设置 OpenMP 线程数,多了不行的
#export MKL_NUM_THREADS=1  # 设置 MKL 线程数,多了不行的

CUDA_VISIBLE_DEVICES=0,1,2,3 "$PYTHON_BIN" inference.py \
    --maxit_binary "$MAXIT_SRC/bin/maxit" \
    --jackhmmer_binary_path "$ENV_BIN/jackhmmer" \
	--hhblits_binary_path "$ENV_BIN/hhblits" \
	--hhsearch_binary_path "$ENV_BIN/hhsearch" \
	--kalign_binary_path "$ENV_BIN/kalign" \
	--hmmsearch_binary_path "$ENV_BIN/hmmsearch" \
	--hmmbuild_binary_path "$ENV_BIN/hmmbuild" \
    --nhmmer_binary_path "$ENV_BIN/nhmmer" \
    --preset='reduced_dbs' \
    --bfd_database_path "$DATA_DIR/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt" \
    --small_bfd_database_path "$DATA_DIR/small_bfd/bfd-first_non_consensus_sequences.fasta" \
    --uniclust30_database_path "$DATA_DIR/uniclust30/uniclust30_2018_08" \
    --uniprot_database_path "$DATA_DIR/uniprot/uniprot.fasta" \
    --pdb_seqres_database_path "$DATA_DIR/pdb_seqres/pdb_seqres.txt" \
    --uniref90_database_path "$DATA_DIR/uniref90/uniref90.fasta" \
    --mgnify_database_path "$DATA_DIR/mgnify/mgy_clusters_2018_12.fa" \
    --template_mmcif_dir "$DATA_DIR/pdb_mmcif/mmcif_files" \
    --obsolete_pdbs_path "$DATA_DIR/pdb_mmcif/obsolete.dat" \
    --ccd_preprocessed_path "$DATA_DIR/ccd_preprocessed_etkdg.pkl.gz" \
    --rfam_database_path "$DATA_DIR/Rfam-14.9_rep_seq.fasta" \
    --max_template_date=2020-05-14 \
    --input_json data/demo_6zcy.json \
    --output_dir ./output \
    --model_name allatom_demo \
    --init_model /a100_nas/ai4s/public_dataset/helixfold3_official_db/model_checkpoint/HelixFold3-params-240814/HelixFold3-240814.pdparams \
    --infer_times 1 \
    --diff_batch_size 1 \
    --precision "fp32"

end=$(date +%s)
echo "运行时间: $((end-start)) 秒"


    #--init_model init_models/HelixFold3-240814.pdparams \
    #--preset='reduced_dbs'
    #--preset='full_dbs' \
    #--input_json data/demo_6zcy.json \
