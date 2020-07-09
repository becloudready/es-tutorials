## Create a Ingest pipeline
### Create CSV parsing Ingest pipeline using CSV procesor

```
curl --location --request PUT 'http://<yourhost>:9200/_ingest/pipeline/mycsv-pipeline' \
--header 'Content-Type: application/json' \
--data-raw '{
  "description": "A pipeline parse movie CSV file",
  "processors": [
    {
      "csv" : {
        "field" : "movie_line",
        "target_fields" : ["movieid", "title","genres"]
      }
    }
  ]
}'
```

## Load Sample Movie Data

```

curl --location --request PUT 'http://localhost:9200/bulk_movies/_bulk?pipeline=csv-movie' \
--header 'Content-Type: application/json' \
--data-raw '{"index": {"_id": "0"}}
{"movie_line": "1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy"}
{"index": {"_id": "1"}}
{"movie_line": "2,Jumanji (1995),Adventure|Children|Fantasy"}
{"index": {"_id": "2"}}
{"movie_line": "3,Grumpier Old Men (1995),Comedy|Romance"}
{"index": {"_id": "3"}}
{"movie_line": "4,Waiting to Exhale (1995),Comedy|Drama|Romance"}
{"index": {"_id": "4"}}
{"movie_line": "5,Father of the Bride Part II (1995),Comedy"}
{"index": {"_id": "5"}}

{"movie_line": "6,Heat (1995),Action|Crime|Thriller"}
```
## Check output, the input CSV data has been stored into separate field

```
curl --location --request GET 'http://159.203.61.164:9200/mymovie-index/_doc/1'

{
    "_index": "mymovie-index",
    "_type": "_doc",
    "_id": "1",
    "_version": 1,
    "_seq_no": 4,
    "_primary_term": 1,
    "found": true,
    "_source": {
        "movie_line": "2,Jumanji (1995),Adventure|Children|Fantasy",
        "genres": "Adventure|Children|Fantasy",
        "movieid": "2",
        "title": "Jumanji (1995)"
    }
}

```
## Create an Ingest pipeline to modify amazon review data based on rating

```
curl --location --request PUT 'http://localhost:9200/_ingest/pipeline/modify-reviews' \
--header 'Content-Type: application/json' \
--data-raw '{"description": "Ingest pipeline to modify some fields based on review ratings",
  "processors": [
{
  "set": {
    "if": "ctx.overall == 5.0",
    "field": "summary",
    "value": "Good Review"
  },
  
  "rename": {
    "field": "helpful",
    "target_field": "useful"
  }

 
}
]
}'
```
## Load sample data 

```
curl --location --request PUT 'http://<yourhost>:9200/amazon-reviews/_doc/1?pipeline=amazon-reviews' \
--header 'Content-Type: application/json' \
--data-raw '{"reviewerID": "A14VAT5EAX3D9S", "asin": "1384719342", "reviewerName": "Jake", "helpful": [13, 14], "reviewText": "The product does exactly as it should and is quite affordable.I did not realized it was double screened until it arrived, so it was even better than I had expected.As an added bonus, one of the screens carries a small hint of the smell of an old grape candy I used to buy, so for reminiscent'\''s sake, I cannot stop putting the pop filter next to my nose and smelling it after recording. :DIf you needed a pop filter, this will work just as well as the expensive ones, and it may even come with a pleasing aroma like mine did!Buy this product! :]", "overall": 5.0, "summary": "Jake", "unixReviewTime": 1363392000, "reviewTime": "03 16, 2013"}'

```
## Check data

```
curl --location --request GET 'http://<yourhost>:9200/amazon-reviews/_doc/1' \
--header 'Content-Type: application/json' \
--data-raw ''

{
    "_index": "amazon-reviews",
    "_type": "_doc",
    "_id": "1",
    "_version": 2,
    "_seq_no": 5,
    "_primary_term": 1,
    "found": true,
    "_source": {
        "summary": "Good Review",
        "reviewerID": "A14VAT5EAX3D9S",
        "unixReviewTime": 1363392000,
        "reviewerName": "Jake",
        "overall": 5.0,
        "asin": "1384719342",
        "useful": [
            13,
            14
        ],
        "reviewText": "The product does exactly as it should and is quite affordable.I did not realized it was double screened until it arrived, so it was even better than I had expected.As an added bonus, one of the screens carries a small hint of the smell of an old grape candy I used to buy, so for reminiscent's sake, I cannot stop putting the pop filter next to my nose and smelling it after recording. :DIf you needed a pop filter, this will work just as well as the expensive ones, and it may even come with a pleasing aroma like mine did!Buy this product! :]",
        "reviewTime": "03 16, 2013"
    }
}

```
