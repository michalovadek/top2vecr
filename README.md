
<!-- README.md is generated from README.Rmd. Please edit that file -->

# top2vecr

<!-- badges: start -->

<!-- badges: end -->

top2vecr is an R implementation of
[top2vec](https://github.com/ddangelov/Top2Vec), a topic modelling
technique relying on jointly learned document and word embeddings.

The main idea is that documents found close to each other in the joint
document-word vector space can be interpreted as topics. Words similar
to these document clusters are used as topic descriptors.
[UMAP](https://github.com/tkonopka/umap) is used to reduce the
dimensionality of the original vector space – as produced by
[doc2vec](https://github.com/bnosac/doc2vec) – and
[HDBSCAN](https://cran.r-project.org/web/packages/dbscan/vignettes/hdbscan.html)
is used to identify document clusters.

As opposed to the original Python implementation, this package does not
yet support the use of pre-trained sentence encoders and transformers.

*Development halted due to performance limitations in UMAP's R implementation*

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("michalovadek/top2vecr")
```
