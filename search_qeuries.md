## Create an index

```
curl --location --request PUT 'http://<yourhost>:9200/bookdb_index_new' \
--header 'Content-Type: application/json' \
--data-raw ''
```
********************************************************************

## Index some documents
```	
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_bulk' \
--header 'Content-Type: application/json' \
--data-raw '{ "index":{"_id" : "1"} }
{"title": "Elasticsearch: The Definitive Guide", "authors": ["clinton gormley", "zachary tong"], "summary" : "A distibuted real-time search and analytics engine", "publish_date" : "2015-02-07", "num_reviews": 20, "publisher": "oreilly"  }
{ "index":{"_id" : "2"} }
{"title": "Taming Text: How to Find, Organize, and Manipulate It", "authors": ["grant ingersoll", "thomas morton", "drew farris"], "summary" : "organize text using approaches such as full-text search, proper name recognition, clustering, tagging, information extraction, and summarization", "publish_date" : "2013-01-24", "num_reviews": 12, "publisher": "manning" }
{ "index":{"_id" : "3"} }
{"title": "Elasticsearch in Action", "authors": ["radu gheorge", "matthew lee hinman", "roy russo"], "summary" : "build scalable search applications using Elasticsearch without having to do complex low-level programming or understand advanced data science algorithms", "publish_date" : "2015-12-03", "num_reviews": 18, "publisher": "manning"  }
{ "index":{"_id" : "4"} }
{"title": "Solr in Action", "authors": ["trey grainger", "timothy potter"], "summary" : "Comprehensive guide to implementing a scalable search engine using Apache Solr", "publish_date" : "2014-04-05", "num_reviews": 23, "publisher": "manning" }
'
```
*******************************************************
## Query to search guide word in any field

```
curl --location --request GET 'http://<yourhost>:9200/bookdb_index_new/book/_search?q=guide' \
--data-raw ''
```
******************************************************************************************
## Query to find word 'in action' in title field

curl --location --request GET 'http://<yourhost>:9200/bookdb_index_new/book/_search?q=title:in%20action' \
--data-raw ''

*********************************************************************************************
## limit resultset to a size --useful for pagination
## Query to limit result set of above query(to get title with word 'in action') to size =1 (only one result)

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "match" : {
            "title" : "in action"
        }
    },
    "size": 1,
    "from": 0,
    "_source": [ "title", "summary", "publish_date" ],
    "highlight": {
        "fields" : {
            "title" : {}
        }
    }
}
'
```


## Boosting score one 1 field by a factor to increase the importance ofthat field
we boost scores from the summary field by a factor of 3 in order to increase the importance of the summary field, which will, in turn, increase the relevance of document _id 4.

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "multi_match" : {
            "query" : "elasticsearch guide",
            "fields": ["title", "summary^3"]
        }
    },
    "_source": ["title", "summary", "publish_date"]
}
'
```


## Query to search for a book with the word “Elasticsearch” OR “Solr” in the title, AND is authored by “clinton gormley” but NOT authored by “radu gheorge”:

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
  "query": {
    "bool": {
      "must": {
        "bool" : { 
          "should": [
            { "match": { "title": "Elasticsearch" }},
            { "match": { "title": "Solr" }} 
          ],
          "must": { "match": { "authors": "clinton gormely" }} 
        }
      },
      "must_not": { "match": {"authors": "radu gheorge" }}
    }
  }
}
'
```


## Query to find books with word "comprihensiv" -fuzzy queries for similar words
##Use of Auto keyword - explaination
##Note: Instead of specifying "AUTO" you can specify the numbers 0, 1, or 2 to indicate the maximum number of edits that can be made to the string to find a match. The benefit of using "AUTO" is that it takes into account the length of the string. For strings that are only 3 characters long, allowing a fuzziness of 2 will result in poor search performance. Therefore it's recommended to stick to "AUTO" in most cases. 

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "multi_match" : {
            "query" : "comprihensiv guide",
            "fields": ["title", "summary"],
            "fuzziness": "AUTO"
        }
    },
    "_source": ["title", "summary", "publish_date"],
    "size": 1
}
'
```

## Query to find all records that have an author whose name begins with the letter ‘t’:

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "wildcard" : {
            "authors" : "t*"
        }
    },
    "_source": ["title", "authors"],
    "highlight": {
        "fields" : {
            "authors" : {}
        }
    }
}
'
```

***********************************************************************************************
## Query to find books whose author names end with letter "y" --- use od regex

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "regexp" : {
            "authors" : "t[a-z]*y"
        }
    },
    "_source": ["title", "authors"],
    "highlight": {
        "fields" : {
            "authors" : {}
        }
    }
}
'
```
*********************************************************************************************************
## Match phrase
##USe of slop - By default, the terms are required to be exactly beside each other but you can specify the slop value which indicates how far apart terms are allowed to be while still considering the document a match.
## query to find the book which have word 'search engine' in their title or summary (with max 3 word in between them)

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "multi_match" : {
            "query": "search engine",
            "fields": ["title", "summary"],
            "type": "phrase",
            "slop": 3
        }
    },
    "_source": [ "title", "summary", "publish_date" ]
}
'
```
********************************************************************************************************************
## query to et the book which have both 'scalable' and 'solr' words in their summary or title

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "multi_match" : {
            "query": "scalable solr",
            "fields": ["title", "summary"],
            "type": "phrase",
            "slop": 4
        }
    },
    "_source": [ "title", "summary", "publish_date" ]
}
'
```

********************************************************************************************************************
## match phrase_prefix
## Match phrase prefix queries provide search-as-you-type or a poor man’s version of autocomplete 
##max_expansions parameter to limit the number of terms matched in order to reduce resource intensity.
```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '
{
    "query": {
        "match_phrase_prefix" : {
            "summary": {
                "query": "search en",
                "slop": 3,
                "max_expansions": 10
            }
        }
    },
    "_source": [ "title", "summary", "publish_date" ]
}'
```

***********************************************************************************************************************
## Query to fuzzy search for the terms “search algorithm” in which one of the book authors is “grant ingersoll” or “tom morton.” 
```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "query_string" : {
            "query": "(saerch~1 algorithm~1) AND (grant ingersoll)  OR (tom morton)",
            "fields": ["title", "authors" , "summary^2"]
        }
    },
    "_source": [ "title", "summary", "authors" ],
    "highlight": {
        "fields" : {
            "summary" : {}
        }
    }
}
'
```
*********************************************************************************************************************
## term queries are used to find exact match
## query to search search all books in our index published by Manning Publications.

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "term" : {
            "publisher": "manning"
        }
    },
    "_source" : ["title","publish_date","publisher"]
}
'
```
*****************************************************************************************************************
## Query to search publisher as manning and oreilly
## use of terms keyword

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "terms" : {
            "publisher": ["manning","oreilly"]
        }
    },
    "_source" : ["title","publish_date","publisher"]
}
'
```
*********************************************************************************************************************
##term queries can be easily sorted
## query to order books publoshed by manning in their descending order of publishing date

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "term" : {
            "publisher": "manning"
        }
    },
    "_source" : ["title","publish_date","publisher"],
    "sort": [
        { "publish_date": {"order":"desc"}}
    ]
}
'
```

********************************************************************
## Range query -structured query example. 
## Query to search for books published in 2015.

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "range" : {
            "publish_date": {
                "gte": "2015-01-01",
                "lte": "2015-12-31"
            }
        }
    },
    "_source" : ["title","publish_date","publisher"]
}
'
```
*****************************************************************************************
## use of field_value_factor function score.
## Query to search the more popular books (as judged by the number of reviews) to be boosted. 

## Note - We could have just run a regular multi_match query and sorted by the num_reviews field but then we lose the benefits of having relevance scoring.

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "function_score": {
            "query": {
                "multi_match" : {
                    "query" : "search engine",
                    "fields": ["title", "summary"]
                }
            },
            "field_value_factor": {
                "field" : "num_reviews",
                "modifier": "log1p",
                "factor" : 2
            }
        }
    },
    "_source": ["title", "summary", "publish_date", "num_reviews"]
}
'
```
*****************************************************************************************************
## query to search books on “search engines” ideally published around June 2014.

```
curl --location --request POST 'http://<yourhost>:9200/bookdb_index_new/book/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": {
        "function_score": {
            "query": {
                "multi_match" : {
                    "query" : "search engine",
                    "fields": ["title", "summary"]
                }
            },
            "functions": [
                {
                    "exp": {
                        "publish_date" : {
                            "origin": "2014-06-15",
                            "offset": "7d",
                            "scale" : "30d"
                        }
                    }
                }
            ],
            "boost_mode" : "replace"
        }
    },
    "_source": ["title", "summary", "publish_date", "num_reviews"]
}
'
```
***************************************************************************************************************
