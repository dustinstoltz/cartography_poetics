# Reproduction Repository for "Cultural Cartography with Word Embeddings"

*Updated on 2024-02-19*

[Marshall A. Taylor](https://www.marshalltaylor.net) and [Dustin S. Stoltz](https://www.dustinstoltz.com)

This repository contains all R code and data necessary to reproduce the plots "Cultural Cartography with Word Embeddings" forthcoming in *Poetics*. You can read the article at *Poetics* [[PDF](https://drive.google.com/file/d/1cTyHza-3PMIGYA50bFYMXwmG3oGcvUGj/view?usp=sharing)][[DOI](https://doi.org/10.1016/j.poetic.2021.101567)][[preprint on SocArxiv](https://osf.io/preprints/socarxiv/5djcn/)].

## Data

To reproduce the figures, you will need to two sets of pretrained word embeddings: [English fastText embeddings](https://fasttext.cc/docs/en/crawl-vectors.html) and the [Historical Word2Vec](https://nlp.stanford.edu/projects/histwords/) embeddings trained on the Corpus of Historical American English. You can get them from the linked sites. We have prepared an `R` package ([`text2map.pretrained`](https://culturalcartography.gitlab.io/text2map.pretrained/)) for downloading and loading the embeddings: 

```r

# install the package
remotes::install_gitlab("culturalcartography/text2map.pretrained")

# load the package
library(text2map.pretrained)
```

You only need to download the embeddings models once per machine:

```r
# download the fasttext embeddings
download_pretrained("vecs_fasttext300_commoncrawl")
# download the histwords embeddings
download_pretrained("vecs_sgns300_coha_histwords")
```

```r
# Load them into the session
data("vecs_fasttext300_commoncrawl")
data("vecs_sgns300_coha_histwords")

# assign to new (shorter) object 
ft.wv <- vecs_fasttext300_commoncrawl
hi_wv <- vecs_sgns300_coha_histwords
# then remove the original
rm(vecs_fasttext300_commoncrawl)
rm(vecs_sgns300_coha_histwords)

```

Next, we use roughly 200,000 news articles from the [All The News (ATN) dataset](https://components.one/datasets/all-the-news-articles-dataset/) covering 2013-2018. We also convert the texts of the articles into a Document-Term Matrix (for our preprocessing procedure see the paper), which is 11,271 unique terms, 197,814 documents, and 79,483,124 total terms. It is also a smidge too big for Github, so we've hosted on Dropbox:

- [All the News DTM](https://www.dropbox.com/scl/fi/34ic6nw4bw8ku3tdodrf7/dtm_news.Rds?rlkey=8mwuaedqpiqe6zut11ryhvg3o&dl=0)

You can also download it directly using R:

```r 

temp <- tempfile()
download.file("https://www.dropbox.com/scl/fi/34ic6nw4bw8ku3tdodrf7/dtm_news.Rds?rlkey=8mwuaedqpiqe6zut11ryhvg3o&raw=1",
  destfile = temp
)
news_dtm_99 <- readRDS(temp)

nrow(news_dtm_99) == 197814
ncol(news_dtm_99) == 11271

```

Then load the metadata for the ATN corpus:

```r
  news_data   <- readRDS("data/news_metadata.Rds")
```

Finally, below are a few extra pieces of data: our anchor lists for building semantic directions and some event data for figure 5.

```r
  df_anchors <- readRDS("data/anchor_lists.Rds")
  df_events <- read.csv("data/events.csv")
```
## Packages 

We use the following packages:

```r
  library(tidyverse)
  library(reshape2)
  library(ggpubr)
  library(text2vec)
  library(text2map)
```

For the ggplot aesthetics, we use another package we've developed:
```r

  # this will change the colorscheme to viridis
  # and tweak the rest of the ggplot2 aesthetics
  remotes::install_gitlab("culturalcartography/text2map.theme")
  text2map.theme::set_theme()
  
```

## Figures 

Provided the above dataframes, matrices, and packages are loaded, the R scripts in the Scripts folder will reproduce figures 1-6 in the paper. For a more detailed guide for using Concept Mover's Distance (used for figures 4-6) see the vignette in [text2map](https://culturalcartography.gitlab.io/text2map/articles/CMDist-concept-movers-distance.html).

## February 2024 Update

We updated this repository as some of the links to data were broken and we have updated some of the code due to dependency changes.
