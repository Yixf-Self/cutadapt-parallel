This is a simple wrapper to parallelize cutadapt because it's too damn slow.

Right now, I assume you're using paired end reads and you're using the -o -p flags to indicate output read1/read2 files (see example below). I recommend using the '--ramdisk' option so you get maximum speed gains, but this means you have to have a ramfs or tmpfs volume. Mine is at '/ramdisk' so that is the default. If yours is in a different location, use '--ramdisklocation PATH' to enter its path. If you do not use a ramdisk, you will see modest speed gains, but splitting files of course takes time. 

Example:

    cutadapt-parallel.sh --threads 32 --ramdisk  -f fastq -g GTTTCCCAGTCACGATA -a TATCGTGACTGGGAAAC -g ACACTCTTTCCCTACACGACGCTCTTCCGATCT -a AGATCGGAAGAGC -q 10 -m 50 -n 5 -o trim1.fastq -p trim2.fastq READ2.fastq  READ2.fastq
