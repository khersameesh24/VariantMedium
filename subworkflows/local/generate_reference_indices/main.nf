include { SAMTOOLS_FAIDX                 } from '../../../modules/nf-core/samtools/faidx/main'
include { GATK4_CREATESEQUENCEDICTIONARY } from '../../../modules/nf-core/gatk4/createsequencedictionary/main'

workflow GENERATE_REFERNCE_INDICES {

    take:
    ch_reference_fasta // channel: [ val(meta), [ reference-sequence ] ]

    main:

    ch_versions        = channel.empty()
    ch_reference_index = channel.empty()
        
    // generate .fai with samtools faidx
    SAMTOOLS_FAIDX (ch_reference_fasta, [], [])
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    ch_reference_index.mix (SAMTOOLS_FAIDX.out.fai)


    // generate seqeunce dict with gatk createseqdict
    GATK4_CREATESEQUENCEDICTIONARY(ch_reference_fasta)
    ch_versions = ch_versions.mix(GATK4_CREATESEQUENCEDICTIONARY.out.versions)

    ch_reference_index.mix (GATK4_CREATESEQUENCEDICTIONARY.out.dict)

    emit:
    
    ch_ref_idx = ch_reference_index  // channel: [val(meta), ["index-files"]]

    versions = ch_versions           // channel: [ versions.yml ]
}
