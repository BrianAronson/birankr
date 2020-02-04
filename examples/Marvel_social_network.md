Marvel Social Network Example
================

### Overview

This notebook contains an example of how to use the R version of this
package to analyze the [Marvel character social
network](https://arxiv.org/abs/cond-mat/0202174), a bipartite network of
ties between characters and comic books. An edge between a character and
a comic book indicates that the character appears in that comic book.

### Installation

Let’s first load the package. Uncomment the first line if you have not
yet installed the birankr package.

``` r
#install.packages("birankr")
library(birankr)
```

    ## Loading required package: Matrix

    ## Loading required package: data.table

We will also need to download the data and format the column names. We
will use the cleaned edge list provided at
<http://syntagmatic.github.io/exposedata/marvel/data/source.csv>.

``` r
marvel_df <- 
  fread("http://syntagmatic.github.io/exposedata/marvel/data/source.csv")
names(marvel_df) <- c('character', 'comic_book')
```

### Browse data

To get a sense of the data, let’s print the number of unique characters
and comic books, and print the first few lines of the data.

``` r
marvel_df[, lapply(.SD, function(x) length(unique(x)))]
```

    ##    character comic_book
    ## 1:      6444      12849

``` r
head(marvel_df)
```

    ##               character comic_book
    ## 1: KILLRAVEN/JONATHAN R     AA2 35
    ## 2:             M'SHULLA     AA2 35
    ## 3: 24-HOUR MAN/EMMANUEL     AA2 35
    ## 4:            OLD SKULL     AA2 35
    ## 5:               G'RATH     AA2 35
    ## 6: 3-D MAN/CHARLES CHAN   M/PRM 35

### Estimate Ranks

Now we can try the bipartite\_rank algorithm with two different
normalizers: HITS and CoHITS. Because the first column of this data
contains the `character` column, the `character` column will be treated
as the senders (or top nodes), and the `comic_book` column will be
treated as the receivers (or bottom nodes). Since the algorithm defaults
to returning only the rankings of senders, the syntax below will provide
us with rank scores for the `character` column.

``` r
HITS_ranks <- bipartite_rank(data = marvel_df, normalizer='HITS')
CoHITS_ranks <- bipartite_rank(data = marvel_df, normalizer='CoHITS')
```

Notice that the results are slightly different, with the HITS normalizer
returning Captain America as the highest ranked/most central comic book
character, and the CoHITS normalizer returning Spider-Man as the highest
ranked comic book character.

``` r
head(HITS_ranks[order(HITS_ranks$rank, decreasing = T), ])
```

    ##                character       rank
    ## 14       CAPTAIN AMERICA 0.02703070
    ## 63  IRON MAN/TONY STARK  0.01993319
    ## 34  THING/BENJAMIN J. GR 0.01990385
    ## 115 HUMAN TORCH/JOHNNY S 0.01924820
    ## 113 MR. FANTASTIC/REED R 0.01882251
    ## 26  INVISIBLE WOMAN/SUE  0.01772762

``` r
head(CoHITS_ranks[order(CoHITS_ranks$rank, decreasing = T), ])
```

    ##                character        rank
    ## 80  SPIDER-MAN/PETER PAR 0.014299452
    ## 14       CAPTAIN AMERICA 0.011231753
    ## 63  IRON MAN/TONY STARK  0.009827441
    ## 23  HULK/DR. ROBERT BRUC 0.007843040
    ## 34  THING/BENJAMIN J. GR 0.007838295
    ## 105 THOR/DR. DONALD BLAK 0.007142875
