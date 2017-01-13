# Get Title and abstract given PMID
require(tidyverse)
require(RISmed)

# Load Journal annotations
ann <- read_csv("data/annotations.csv")
ann <- select(ann, evidence, evidence.type, relevant) %>%
    filter(!is.na(evidence))

# For the first 678 entries I wasn't discriminating between cancer vs. non-cancer
ann <- ann[679:nrow(ann),]

# Get PMIDs
pmids <- as.character(ann$evidence)

# Get PUBMED data given search elements
get.pubmed.data = function(search.elements){
    res = EUtilsSummary(search.elements)
    res_records = EUtilsGet(res)
    res = data.frame(cbind(PMID(res_records),
                           ArticleTitle(res_records),
                           AbstractText(res_records)))
    
    res = as.data.frame(res)
    colnames(res) = c("PMID",
                      "article_title",
                      "abstract_text")
    return(res)
}


abstracts <- data_frame("PMID", "article_title", "abstract_text")
for (i in 1:length(pmids)){
    p <- pmids[i]
    d <- get.pubmed.data(paste(p, "[PMID]", sep = ""))
    abstracts <- bind_rows(abstracts, d)
}

# Transform the abstracts table and join to annotations
abstracts <- filter(abstracts, !is.na(abstract_text))
abstracts <- abstracts[,4:6]
colnames(abstracts) <- c("evidence", "article_title", "abstract_text")
ann$evidence <- as.character(ann$evidence)
abstracts <- left_join(abstracts, ann)

# Create two data sets
cancer <- filter(abstracts, !relevant == 3)
non.cancer <- filter(abstracts, relevant == 3)

write_tsv(cancer, "output/cancer.tsv")
write_tsv(cancer, "output/non_cancer.tsv")
