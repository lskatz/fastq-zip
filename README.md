# fastq-zip

A method of compressing fastq files a little better

## Usage

There is one usage to compress, normally piped to `gzip`.
There is a second usage to decompress with `-d`.

```
fastq-zip.pl: compresses fastq
  Usage: cat fastq | fastq-zip.pl | gzip -c > fastq.kz
         zcat fastq.kz | fastq-zip.pl -d > fastq
  --help   This useful help menu
  --decompress
```

## Output format

The output format is an index block and then content.
These blocks are separated by a double newline.

### Index block

```
ID:137788
SEQ:2320557
QUAL:2320557
```

The Index block has three lines of the sub-content and its length.
In this example, reading the first `137788` characters of the content block
will return all the identifiers.
Reading the next `2320557` characters will return all the sequence data.
Finally, reading the next `2320557` characters will return all the qual data.

### Content block
* Identifiers retain their `@` and are separated by newline.
* Sequences are separated by newlines
* Qual lines are separated by newlines

