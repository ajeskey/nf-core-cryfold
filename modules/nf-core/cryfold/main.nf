#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process CRYFOLD {
    tag "$meta.id"
    label 'process_medium'
    label 'aws'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cryfold:1.0.0--hdfd78af_0' :
        'quay.io/biocontainers/cryfold:1.0.0--hdfd78af_0' }"

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    tuple val(meta), path(fasta)
    val   outdir

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("${meta.id}/*.pdb"), emit: pdb
    tuple val(meta), path("${meta.id}/*.log"), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    // CryFold specific parameters
    def model_type = task.ext.model_type ? "--model-type ${task.ext.model_type}" : ''
    def temperature = task.ext.temperature ? "--temperature ${task.ext.temperature}" : ''
    def num_recycles = task.ext.num_recycles ? "--num-recycles ${task.ext.num_recycles}" : ''
    def num_models = task.ext.num_models ? "--num-models ${task.ext.num_models}" : ''
    def use_amber = task.ext.use_amber ? "--use-amber" : ''
    def use_templates = task.ext.use_templates ? "--use-templates" : ''
    def template_dir = task.ext.template_dir ? "--template-dir ${task.ext.template_dir}" : ''
    def msa_dir = task.ext.msa_dir ? "--msa-dir ${task.ext.msa_dir}" : ''
    def output_dir = task.ext.output_dir ? "--output-dir ${task.ext.output_dir}" : ''
    def verbose = task.ext.verbose ? "--verbose" : ''
    def quiet = task.ext.quiet ? "--quiet" : ''

    """
    # Create output directory
    mkdir -p ${prefix}

    # Run CryFold with all available parameters
    cryfold \
        --input ${fasta} \
        --output ${prefix} \
        --threads $task.cpus \
        ${model_type} \
        ${temperature} \
        ${num_recycles} \
        ${num_models} \
        ${use_amber} \
        ${use_templates} \
        ${template_dir} \
        ${msa_dir} \
        ${output_dir} \
        ${verbose} \
        ${quiet} \
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cryfold: \$(cryfold --version 2>&1 | head -n1 | cut -f2 -d' ')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def model_type = task.ext.model_type ? "--model-type ${task.ext.model_type}" : ''
    def temperature = task.ext.temperature ? "--temperature ${task.ext.temperature}" : ''
    def num_recycles = task.ext.num_recycles ? "--num-recycles ${task.ext.num_recycles}" : ''
    def num_models = task.ext.num_models ? "--num-models ${task.ext.num_models}" : ''
    def use_amber = task.ext.use_amber ? "--use-amber" : ''
    def use_templates = task.ext.use_templates ? "--use-templates" : ''
    def template_dir = task.ext.template_dir ? "--template-dir ${task.ext.template_dir}" : ''
    def msa_dir = task.ext.msa_dir ? "--msa-dir ${task.ext.msa_dir}" : ''
    def output_dir = task.ext.output_dir ? "--output-dir ${task.ext.output_dir}" : ''
    def verbose = task.ext.verbose ? "--verbose" : ''
    def quiet = task.ext.quiet ? "--quiet" : ''

    """
    # Create output directory
    mkdir -p ${prefix}

    # Create stub output files with realistic names
    touch ${prefix}/${prefix}_model_1.pdb
    touch ${prefix}/${prefix}_model_2.pdb
    touch ${prefix}/${prefix}.log

    # Create a realistic log file
    cat <<-END_LOG > ${prefix}/${prefix}.log
    CryFold prediction log
    Input: ${fasta}
    Model type: ${model_type ?: 'default'}
    Temperature: ${temperature ?: 'default'}
    Number of recycles: ${num_recycles ?: 'default'}
    Number of models: ${num_models ?: 'default'}
    Use AMBER: ${use_amber ?: 'false'}
    Use templates: ${use_templates ?: 'false'}
    END_LOG

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cryfold: \$(cryfold --version 2>&1 | head -n1 | cut -f2 -d' ')
    END_VERSIONS
    """
}
