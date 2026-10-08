#!/usr/bin/env bash

# Define scratch directory by expanding snakemake param value:
export TMPDIR=$(envsubst <<< ${snakemake_params[scratch]})
echo "Temporary working directory: $TMPDIR"

# Get full path name for outputs
INBAM=$(readlink -e ${snakemake_input[bam]})
OUTH5=$(dirname $(readlink -m ${snakemake_output[h5]}))


# Work in temporary dir
cd $TMPDIR || exit 1

# Build command from snakemake input and output
CMD=(bash cellbender remove-background \
    --cuda \
    --input $INBAM \
    --output $TMPDIR)

# Print command to terminal for log
echo ${CMD[@]}

# Run command
${CMD[@]}

# Copy outputs to permanent storage
OUT_FILES=(
output_report.html
output.h5
output_filtered.h5
output_cell_barcodes.csv
output.log
output_metrics.csv
)

mv ${OUT_FILES[@]} $OUTDIR/
