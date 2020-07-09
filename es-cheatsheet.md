
## Show cluster health

```
curl --user $pwd  -H 'Content-Type: application/json' -XGET https://<your-host>/_cluster/health?pretty
```
## list all indexes
```
curl -X GET 'http://localhost:9200/_cat/indices?v'
```
## list all docs in index
```
curl -X GET 'http://localhost:9200/sample/_search'
```


## Delete index
```
curl -X DELETE 'http://localhost:9200/samples'
```
## Query using URL parameters

```
curl -X GET http://localhost:9200/samples/_search?q=school:BHU
```

## Elasticsearch Query DSL

```
curl -XGET --header 'Content-Type: application/json' http://localhost:9200/samples/_search -d '{
      "query" : {
        "match" : { "school": "BHU" }
    }
}'
```

## list index mapping
```
curl -X GET http://localhost:9200/samples/_mapping
```

## Add Data

```
curl -XPUT --header 'Content-Type: application/json' http://localhost:9200/samples/_doc/1 -d '{
   "school" : "BHU"			
}'
```
## Update Doc Here is how to add fields to an existing document. First we create a new one. Then we update it.

```
curl -XPUT --header 'Content-Type: application/json' http://localhost:9200/samples/_doc/2 -d '
{
    "school": "UFT"
}'

curl -XPOST --header 'Content-Type: application/json' http://localhost:9200/samples/_doc/2/_update -d '{
"doc" : {
               "students": 100}
}'
```
## backup index
```
curl -XPOST --header 'Content-Type: application/json' http://localhost:9200/_reindex -d '{
  "source": {
    "index": "samples"
  },
  "dest": {
    "index": "samples_backup"
  }
}'

```

## Exclude Node from sharding allocation
```
curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
  "transient" : {
    "cluster.routing.allocation.exclude._ip" : "<node-ip>"
  }
}
'
```