# SAMSA2 - A complete metatranscriptome analysis pipeline

This is a fork of the [original repository](https://github.com/transcript/samsa2). Refer to there for details.

## Modifications and Improvements
The work done on this repo is to adapt the pipeline to work with a Slurm scheduler and some additional parallelisation.
* `bash_scripts/master_scripts.sh` is modified to:
    * use Slurm job arrays
    * utilize tuning parameters in `diamond blastx` (currently tuned to suit 32 threads on 16 CPU cores with hyper threading)
* `python_scripts/DIAMOND_analysis_counter.py` utilizes Python multiprocessing to parallelise the work.

## How To Use
### Preparing input files
The pipeline is designed to work with fastq samples with filenames of the form `*_R{1,2}*.fastq*`. 
`bash_scripts/create_array_dirs.sh` takes a collection of these pairs of fastq files and subdivides them into isolated folders using soft links.
If your files follow a different schema, you may need to modify the script accordingly or create your own.

For example
```{bash}
$ ls -1 input_files
48E_S68_L001_R1_001.fastq
48E_S68_L001_R2_001.fastq
48F_S69_L001_R1_001.fastq
48F_S69_L001_R2_001.fastq
48R1_S73_L001_R1_001.fastq
48R1_S73_L001_R2_001.fastq

$ bash_scripts/create_array_dirs.sh input_files input_files_seperated

$ tree input_files_seperated
./input_files_seperated/
├── 48E_S68_L001
│   ├── 48E_S68_L001_R1_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48E_S68_L001_R1_001.fastq
│   └── 48E_S68_L001_R2_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48E_S68_L001_R2_001.fastq
├── 48F_S69_L001
│   ├── 48F_S69_L001_R1_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48F_S69_L001_R1_001.fastq
│   └── 48F_S69_L001_R2_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48F_S69_L001_R2_001.fastq
├── 48R1_S73_L001
    ├── 48R1_S73_L001_R1_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48R1_S73_L001_R1_001.fastq
    └── 48R1_S73_L001_R2_001.fastq -> /vast/projects/SAMSA/samsa2/input_files/48R1_S73_L001_R2_001.fastq
```

### Modifying input and output dirs
in `bash_scripts/master_script.sh`: 
* modify `INPUT_DIR` to point to the directory with subdivided input files.
* if needed, modify `OUT_DIR` to change the location of where seperate output files are stored.
* if needed, modify `CENTRAL_OUT_DIR` to change the location of where collated output files are stored.

### Submitting the job
Like any other Slurm script, you can submit the master script by
```
sbatch bash_scripts/master_script.sh
```
Note that the most memory intensive step, `diamond blastx`, is currently tuned for performance at the cost of memory. If your nodes do not have the 150G RAM required for the current parameters, you may wish to modify them by reducing the `-b` (block size) and `-c` (number of chunks) values. See the [DIAMOND wiki](https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options#memory--performance-options).

### Output directory structure
```
$ tree seperated_outputs
seperated_outputs
├── output_48E_S68_L001
│   ├── step_1_output
│   │   ├── 48E_S68_L001.cleaned.forward
│   │   ├── 48E_S68_L001.cleaned.forward_unpaired
│   │   ├── 48E_S68_L001.cleaned.reverse
│   │   └── 48E_S68_L001.cleaned.reverse_unpaired
│   ├── step_2_output
│   │   ├── 48E_S68_L001.merged.assembled.fastq
│   │   ├── 48E_S68_L001.merged.assembled.fastq.ribosomes.fastq
│   │   ├── 48E_S68_L001.merged.assembled.fastq.ribosomes.log
│   │   ├── 48E_S68_L001.merged.discarded.fastq
│   │   ├── 48E_S68_L001.merged.unassembled.forward.fastq
│   │   ├── 48E_S68_L001.merged.unassembled.reverse.fastq
│   │   └── raw_counts.txt
│   ├── step_3_output
│   │   └── 48E_S68_L001.merged.ribodepleted.fastq
│   ├── step_4_output
│   │   ├── 48E_S68_L001.merged.RefSeq_annotated
│   │   ├── 48E_S68_L001.merged.subsys_annotated
│   │   └── daa_binary_files
│   │       ├── 48E_S68_L001.merged.ribodepleted.fastq.RefSeq.daa
│   │       └── 48E_S68_L001.merged.ribodepleted.fastq.Subsys.daa
│   ├── step_5_output
│   │   ├── RefSeq_results
│   │   │   ├── func_results
│   │   │   │   └── 48E_S68_L001.merged.RefSeq_annot_function.tsv
│   │   │   └── org_results
│   │   │       └── 48E_S68_L001.merged.RefSeq_annot_organism.tsv
│   │   └── Subsystems_results
│   │       ├── 48E_S68_L001.merged.subsys_annotated.hierarchy.reduced
│   │       └── receipts
│   │           └── 48E_S68_L001.merged.subsys_annotated.receipt
│   └── step_6_output
├── output_48F_S69_L001
│   ├── step_1_output
│   │   ├── 48F_S69_L001.cleaned.forward
│   │   ├── 48F_S69_L001.cleaned.forward_unpaired
│   │   ├── 48F_S69_L001.cleaned.reverse
│   │   └── 48F_S69_L001.cleaned.reverse_unpaired
│   ├── step_2_output
│   │   ├── 48F_S69_L001.merged.assembled.fastq
│   │   ├── 48F_S69_L001.merged.assembled.fastq.ribosomes.fastq
│   │   ├── 48F_S69_L001.merged.assembled.fastq.ribosomes.log
│   │   ├── 48F_S69_L001.merged.discarded.fastq
│   │   ├── 48F_S69_L001.merged.unassembled.forward.fastq
│   │   ├── 48F_S69_L001.merged.unassembled.reverse.fastq
│   │   └── raw_counts.txt
│   ├── step_3_output
│   │   └── 48F_S69_L001.merged.ribodepleted.fastq
│   ├── step_4_output
│   │   ├── 48F_S69_L001.merged.RefSeq_annotated
│   │   ├── 48F_S69_L001.merged.subsys_annotated
│   │   └── daa_binary_files
│   │       ├── 48F_S69_L001.merged.ribodepleted.fastq.RefSeq.daa
│   │       └── 48F_S69_L001.merged.ribodepleted.fastq.Subsys.daa
│   ├── step_5_output
│   │   ├── RefSeq_results
│   │   │   ├── func_results
│   │   │   │   └── 48F_S69_L001.merged.RefSeq_annot_function.tsv
│   │   │   └── org_results
│   │   │       └── 48F_S69_L001.merged.RefSeq_annot_organism.tsv
│   │   └── Subsystems_results
│   │       ├── 48F_S69_L001.merged.subsys_annotated.hierarchy.reduced
│   │       └── receipts
│   │           └── 48F_S69_L001.merged.subsys_annotated.receipt
│   └── step_6_output
└── output_48R1_S73_L001
    ├── step_1_output
    │   ├── 48R1_S73_L001.cleaned
    │   └── 48R1_S73_L001_R2_001.fastq.cleaned
    ├── step_2_output
    │   ├── 48R1_S73_L001.merged.assembled.fastq
    │   ├── 48R1_S73_L001.merged.assembled.fastq.ribosomes.fastq
    │   ├── 48R1_S73_L001.merged.assembled.fastq.ribosomes.log
    │   ├── 48R1_S73_L001_R2_001.fastq.merged.assembled.fastq
    │   ├── 48R1_S73_L001_R2_001.fastq.merged.assembled.fastq.ribosomes.fastq
    │   ├── 48R1_S73_L001_R2_001.fastq.merged.assembled.fastq.ribosomes.log
    │   └── raw_counts.txt
    ├── step_3_output
    │   ├── 48R1_S73_L001.merged.ribodepleted.fastq
    │   └── 48R1_S73_L001_R2_001.fastq.merged.ribodepleted.fastq
    ├── step_4_output
    │   ├── 48R1_S73_L001.merged.RefSeq_annotated
    │   ├── 48R1_S73_L001.merged.subsys_annotated
    │   ├── 48R1_S73_L001_R2_001.fastq.merged.RefSeq_annotated
    │   ├── 48R1_S73_L001_R2_001.fastq.merged.subsys_annotated
    │   └── daa_binary_files
    │       ├── 48R1_S73_L001.merged.ribodepleted.fastq.RefSeq.daa
    │       ├── 48R1_S73_L001.merged.ribodepleted.fastq.Subsys.daa
    │       ├── 48R1_S73_L001_R2_001.fastq.merged.ribodepleted.fastq.RefSeq.daa
    │       └── 48R1_S73_L001_R2_001.fastq.merged.ribodepleted.fastq.Subsys.daa
    ├── step_5_output
    │   ├── RefSeq_results
    │   │   ├── func_results
    │   │   │   ├── 48R1_S73_L001.merged.RefSeq_annot_function.tsv
    │   │   │   └── 48R1_S73_L001_R2_001.fastq.merged.RefSeq_annot_function.tsv
    │   │   └── org_results
    │   │       ├── 48R1_S73_L001.merged.RefSeq_annot_organism.tsv
    │   │       └── 48R1_S73_L001_R2_001.fastq.merged.RefSeq_annot_organism.tsv
    │   └── Subsystems_results
    │       ├── 48R1_S73_L001.merged.subsys_annotated.hierarchy.reduced
    │       ├── 48R1_S73_L001_R2_001.fastq.merged.subsys_annotated.hierarchy.reduced
    │       └── receipts
    │           ├── 48R1_S73_L001.merged.subsys_annotated.receipt
    │           └── 48R1_S73_L001_R2_001.fastq.merged.subsys_annotated.receipt
    └── step_6_output

$ tree combined_outputs
combined_outputs
├── step_1_output
│   ├── 48E_S68_L001.cleaned.forward
│   ├── 48E_S68_L001.cleaned.forward_unpaired
│   ├── 48E_S68_L001.cleaned.reverse
│   ├── 48E_S68_L001.cleaned.reverse_unpaired
│   ├── 48F_S69_L001.cleaned.forward
│   └── 48F_S69_L001.cleaned.forward_unpaired
├── step_2_output
│   ├── 48E_S68_L001.merged.assembled.fastq
│   ├── 48E_S68_L001.merged.discarded.fastq
│   └── 48E_S68_L001.merged.unassembled.forward.fastq
├── step_3_output
├── step_4_output
│   ├── 48E_S68_L001.merged.RefSeq_annotated
│   ├── 48E_S68_L001.merged.subsys_annotated
│   └── 48F_S69_L001.merged.RefSeq_annotated
├── step_5_output
│   ├── RefSeq_results
│   │   ├── func_results
│   │   └── org_results
│   │       ├── 48E_S68_L001.merged.RefSeq_annot_organism.tsv
│   │       ├── 48F_S69_L001.merged.RefSeq_annot_organism.tsv
│   │       └── 48R1_S73_L001.merged.RefSeq_annot_organism.tsv
│   └── Subsystems_results
│       ├── 48E_S68_L001.merged.subsys_annotated.hierarchy.reduced
│       ├── 48F_S69_L001.merged.subsys_annotated.hierarchy.reduced
│       ├── 48R1_S73_L001.merged.subsys_annotated.hierarchy.reduced
│       ├── 48R1_S73_L001_R2_001.fastq.merged.subsys_annotated.hierarchy.reduced
│       └── receipts
└── step_6_output
