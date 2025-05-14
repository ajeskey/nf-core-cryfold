#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { CRYFOLD as CRYFOLD_BASIC } from '../main.nf'
include { CRYFOLD as CRYFOLD_ADVANCED } from '../main.nf'
include { CRYFOLD as CRYFOLD_CUSTOM } from '../main.nf'

workflow {
    // Test with basic parameters
    input_basic = Channel
        .fromPath(params.test_data['sarscov2']['genome']['fasta'])
        .map { file -> 
            def meta = [id: 'test_basic']
            return [meta, file]
        }
    CRYFOLD_BASIC(input_basic, params.outdir)

    // Test with advanced parameters
    input_advanced = Channel
        .fromPath(params.test_data['sarscov2']['genome']['fasta'])
        .map { file -> 
            def meta = [id: 'test_advanced']
            return [meta, file]
        }
    CRYFOLD_ADVANCED(
        input_advanced,
        params.outdir
    ).set { advanced_output }

    // Test with custom output directory
    input_custom = Channel
        .fromPath(params.test_data['sarscov2']['genome']['fasta'])
        .map { file -> 
            def meta = [id: 'test_custom']
            return [meta, file]
        }
    CRYFOLD_CUSTOM(
        input_custom,
        params.outdir
    ).set { custom_output }
} 