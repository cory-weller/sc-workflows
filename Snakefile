#!/usr/bin/env python3

from snakemake.utils import min_version
import yaml
 
min_version("9.0")


class DotDict(dict):
    """
    A dictionary subclass that enables dot notation for accessing, 
    setting, and deleting keys recursively.
    """
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Recursively convert any nested dict inputs into DotDicts
        for key, value in self.items():
            self[key] = self._convert(value)

    def __getattr__(self, key):
        try:
            return self[key]
        except KeyError:
            raise AttributeError(f"'DotDict' object has no attribute '{key}'")

    def __setattr__(self, key, value):
        self[key] = self._convert(value)

    def __delattr__(self, key):
        try:
            del self[key]
        except KeyError:
            raise AttributeError(f"'DotDict' object has no attribute '{key}'")

    def _convert(self, value):
        """Recursively process values to handle nested dictionaries and lists."""
        if isinstance(value, dict) and not isinstance(value, DotDict):
            return DotDict(value)
        elif isinstance(value, list):
            return [self._convert(item) for item in value]
        return value


# Make more easily-accessible dicts
config = DotDict(config)
slurm = config.slurm
cellranger = config.cellranger
cellbender = config.cellbender

rule run_cellranger:
    input: csv = cellranger.dir + '/{library}/libraries.csv'
    output: bam = cellranger.dir + '/{library}/possorted_genome_bam.bam'
    envmodules: cellranger.module
    params:
        create_bam = cellranger.create_bam,
        transcriptome = cellranger.transcriptome,
        scratch = slurm.scratch_dir
    resources:
        slurm_partition = slurm.norm_partition,
        gres = cellbender.scratch_gb,
        slurm_extra = slurm.gpu_extra
    script: cellranger.script

rule run_cellbender:
    input: bam= cellranger.dir + '/{library}/possorted_genome_bam.bam'
    output: h5= cellbender.dir + '/{library}/filtered.h5'
    envmodules: cellbender.module
    resources:
        slurm_partition = slurm.gpu_partition,
        gres = cellbender.scratch_gb,
        slurm_extra = slurm.gpu_extra
    params:
        scratch=slurm.scratch_dir
    script: cellbender.script

