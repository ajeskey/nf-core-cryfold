# CryFold

## Description

This module runs CryFold, a protein structure prediction tool. CryFold uses deep learning to predict protein structures from amino acid sequences.

## Usage

```nextflow
include { CRYFOLD } from 'nf-core/cryfold'

workflow {
    CRYFOLD (
        input,
        params.outdir,
        ext: [
            model_type: 'monomer',    // Type of model to use
            temperature: '0.8',       // Temperature for sampling
            num_recycles: '3',        // Number of recycling iterations
            num_models: '5',          // Number of models to generate
            use_amber: true,          // Use AMBER for refinement
            use_templates: true,      // Use template structures
            template_dir: '/path/to/templates',  // Directory containing template structures
            msa_dir: '/path/to/msa',  // Directory containing MSA files
            output_dir: '/path/to/output',  // Custom output directory
            verbose: true,            // Enable verbose output
            quiet: false              // Suppress output
        ]
    )
}
```

## Input

The module requires the following input:

- `input`: A tuple containing:
  - `meta`: A map containing sample information (must include `id`)
  - `fasta`: Path to the input FASTA file

Example:
```groovy
input = [
    [id: 'sample1'],
    file('path/to/sequence.fasta')
]
```

## Output

The module produces the following outputs:

- `pdb`: Tuple containing:
  - `meta`: The input meta information
  - `*.pdb`: Predicted protein structure files
- `log`: Tuple containing:
  - `meta`: The input meta information
  - `*.log`: Log files from the prediction process
- `versions`: YAML file containing software versions

## Parameters

### Required Parameters

- `--input`: Input FASTA file containing the protein sequence
- `--output`: Output directory for results

### Optional Parameters

All optional parameters can be set through the `ext` map:

- `model_type`: Type of model to use (default: 'monomer')
- `temperature`: Temperature for sampling (default: 0.8)
- `num_recycles`: Number of recycling iterations (default: 3)
- `num_models`: Number of models to generate (default: 5)
- `use_amber`: Use AMBER for refinement (default: false)
- `use_templates`: Use template structures (default: false)
- `template_dir`: Directory containing template structures
- `msa_dir`: Directory containing MSA files
- `output_dir`: Custom output directory
- `verbose`: Enable verbose output (default: false)
- `quiet`: Suppress output (default: false)

Additional parameters can be passed using `ext.args`:

```groovy
CRYFOLD (
    input,
    params.outdir,
    ext.args: '--additional-param value'
)
```

## Example

```nextflow
workflow {
    input = [
        [id: 'protein1'],
        file('path/to/protein1.fasta')
    ]

    CRYFOLD (
        input,
        params.outdir,
        ext: [
            model_type: 'monomer',
            temperature: '0.8',
            num_recycles: '3',
            num_models: '5',
            use_amber: true,
            verbose: true
        ]
    )
}
```

## Requirements

- Nextflow >= 20.04.0
- CryFold >= 1.0.0

## Container

The module uses Docker/Singularity containers with the following images:
- Docker: `quay.io/biocontainers/cryfold:1.0.0--hdfd78af_0`
- Singularity: `https://depot.galaxyproject.org/singularity/cryfold:1.0.0--hdfd78af_0`

## Support

For questions and support, please visit:
- [nf-core/modules GitHub repository](https://github.com/nf-core/modules)
- [nf-core Slack workspace](https://nf-co.re/join) 