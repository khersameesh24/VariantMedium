process SORT_BAM {
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/sambamba:0.8.2--0e3602d562e53f2e"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${prefix}.sorted.bam"), emit: sorted_bam
    path ("versions.yml")                        , emit: versions

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    mkdir -p tmp

    sambamba sort \
        --nthreads=${task.cpus} \
        --tmpdir=./tmp \
        --out=${prefix}.sorted.bam \
        ${bam} \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sambamba: \$(sambamba --version | grep '^sambamba' | awk '{print $2}')
    END_VERSIONS

    """

    stub:

    prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    touch ${prefix}.sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sambamba: \$(sambamba --version | grep '^sambamba' | awk '{print $2}')
    END_VERSIONS
    """
}