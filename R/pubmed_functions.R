# Get Title and abstract given PMID
require(tidyverse)
require(RISmed)

# Load Journal annotations
ann <- read_tsv(ann)
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