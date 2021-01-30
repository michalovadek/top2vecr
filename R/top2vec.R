#' Run the top2vecr model
#'
#' Runs an R implementation of the top2vec model as described here: https://arxiv.org/abs/2008.09470.
#' The R implementation is very similar to the original Python
#' implementation which can be found here: https://github.com/ddangelov/Top2Vec
#'
#' @importFrom magrittr %>%
#'
#' @param x A `data.frame` object with columns `doc_id` and `text` storing document ids and texts as character vectors
#'
#' @return
#' An object of class ...
#' @export
#' @examples
#' \donttest{
#' topic_words <- top2vecr(x)
#' }

top2vecr <- function(x, type = "PV-DBOW", dim = 300L, iter = 40L,
                     hs = TRUE, window = 15L, negative = 0L, sample = 0.00001,
                     min_count = 50, lr = 0.05, threads = 4L,
                     n_neighbours = 15L, n_components = 5L, metric = "cosine",
                     minPts = 15L){

  # checks:

  # check number of words < 1000
  # check number of documents > n_neighbours

  x$text <- x$text %>%
    stringr::str_squish() %>%
    stringr::str_trim() %>%
    stringr::str_remove_all("[:punct:]|[:digit:]") %>%
    stringr::str_to_lower()

  stopifnot(stringr::str_count(x$text, " ") < 1000)
  stopifnot(length(x$text) > n_neighbours)

  model <- doc2vec::paragraph2vec(x = x, type = type, dim = dim, iter = iter,
                                  hs = hs, window = window, negative = negative, sample = sample,
                                  min_count = min_count, lr = lr, threads = threads)

  embeddings_docs <- as.matrix(model, which = "docs")
  embeddings_words <- as.matrix(model, which = "words")

  docs_umap <- uwot::umap(embeddings_docs, n_neighbors = n_neighbours,
                          n_components = n_components, metric = metric)

  cl <- dbscan::hdbscan(docs_umap, minPts = minPts)

  emb_cl <- cbind(embeddings_docs, topic = cl$cluster)

  topic_centroids <- emb_cl %>%
    as.data.frame() %>%
    dplyr::mutate(topic = as.character(topic)) %>%
    dplyr::group_by(.data$topic) %>%
    dplyr::summarise_if(is.numeric, mean) # centroid => topic = new vector

  topic_medoids <- emb_cl %>%
    as.data.frame() %>%
    dplyr::mutate(topic = as.character(topic)) %>%
    dplyr::group_by(.data$topic) %>%
    dplyr::summarise_if(is.numeric, median) # medoid => topic = most similar document in cluster

  topic_words <- vector("list", nrow(topic_centroids))

  for (k in 1:nrow(topic_centroids)){

    topic <- topic_centroids[k,] %>%
      dplyr::select(-topic) %>%
      as.matrix()

    rownames(topic) <- deframe(topic_centroids[k,1])

    topic_words[[k]] <- doc2vec::paragraph2vec_similarity(y = embeddings_words, x = topic, top_n = 10) %>%
      dplyr::rename(topic = term1,
                    word = term2)

  }

  return(topic_words)

}

