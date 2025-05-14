#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { CRYFOLD as CRYFOLD_BASIC } from '../main.nf'
include { CRYFOLD as CRYFOLD_ADVANCED } from '../main.nf'
include { CRYFOLD as CRYFOLD_CUSTOM } from '../main.nf'

workflow {
    // Test with basic parameters
    input_basic = Channel.value([
        [id: 'test_basic'],
        file(params.test_data['sarscov2']['genome']['fasta'], checkIfExists: true)
    ])
    CRYFOLD_BASIC(input_basic, params.outdir)

    // Test with advanced parameters
    input_advanced = Channel.value([
        [id: 'test_advanced'],
        file(params.test_data['sarscov2']['genome']['fasta'], checkIfExists: true)
    ])
    CRYFOLD_ADVANCED(
        input_advanced,
        params.outdir,
        ext: [
            model_type: 'monomer',
            temperature: '0.8',
            num_recycles: '3',
            num_models: '5',
            use_amber: true,
            use_templates: true,
            verbose: true
        ]
    )

    // Test with custom output directory
    input_custom = Channel.value([
        [id: 'test_custom'],
        file(params.test_data['sarscov2']['genome']['fasta'], checkIfExists: true)
    ])
    CRYFOLD_CUSTOM(
        input_custom,
        params.outdir,
        ext: [
            output_dir: "${params.outdir}/custom_output"
        ]
    )
} 