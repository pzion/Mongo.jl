
Mongo.jl
===========

[![Build Status](https://api.travis-ci.org/ScottPJones/Mongo.jl.svg?branch=master)](https://travis-ci.org/ScottPJones/Mongo.jl)
[![0.6 Status](http://pkg.julialang.org/badges/Mongo_0.6.svg)](http://pkg.julialang.org/?pkg=Mongo)
[![Coverage Status](https://img.shields.io/coveralls/ScottPJones/Mongo.jl.svg)](https://coveralls.io/r/ScottPJones/Mongo.jl?branch=master)

[MongoDB](http://www.mongodb.org) bindings for [The Julia Language](http://julialang.org/). You may however want to use the newer [[Mongoc]](https://github.com/felipenoris/Mongoc.jl).


License
-------

This software is licensed under the simplified BSD license; see the file LICENSE for details.


Installing
----------

Building this package should build and/or install the MongoDB C driver for you.


Setup
-----

You must have a MongoDB server running somewhere.  You can specify the host and port in the MongoClient constructor, otherwise it uses the Mongo default locahost:27017.

````julia
using Mongo, LibBSON

# Create a client connection
client = MongoClient() # default locahost:27017

# Get a handle to collection named "cats" in database "db".
# Client object, database name, and collection name are stored as variables.
cats = MongoCollection(client, "db", "cats")

# Insert a document
# Mokie is a pretty old cat
m_oid = insert(cats, Dict("name" => "Mokie", "age" => 17))
````

Dictionary Syntax
-----------------

With MongoDB, documents and queries are represented as `BSONObject` structures.
In Julia, we can create these from `Associative` data structures like `Dict`.
However, most functions in this package also accept a `Union{Pair,Tuple}` in
lieu of that, allowing us to omit the `Dict` constructor:

````julia
# Pebbles is an even older cat
p_oid = insert(cats, ("name" => "Pebbles", "age" => 19))

# Ensure they were inserted by counting
println(count(cats, ("name" => "Mokie"))) # 1
println(count(cats)) # 2
````

Query Syntax
------------

MongoDB queries are also BSON documents, and can include certain
[modifiers](https://docs.mongodb.org/manual/reference/operator/query-modifier/)
and [operators](https://docs.mongodb.org/manual/reference/operator/query/) which
allow for the construction of complex queries. This package includes shortcut
functions for many of them so, for instance instead of typing:

````julia
Dict("\$query" => Dict("age" => Dict("\$lt" => 19)))
````

We can do the following:

````julia
# Print all cats under age 19
for doc in find(cats, query("age" => lt(19)))
    println("$(doc["name"]) is younger than 19")
end
````

Operators and modifiers can be combined by encasing them in parenthesis.

````julia
# It's Mokie's birthday!
# We can use the shortcut for the "$inc" operator to increase Mokie's age by 1
update(cats, ("_id" => m_oid), inc("age" => 1))

for doc in find(cats, (query(), orderby("age" => 1)))
    println("$(doc["name"]) is $(doc["age"]) years old.")
end

# Delete the document and ensure it is no more by counting
delete(cats, ("_id" => m_oid))
println(count(cats, ("name" => "Mokie")))
````

Command Syntax
--------------

The `command_simple` function allows broad access to MongoDB actions. For example, creating an index:

```julia
command_simple(client,
               "db",
               Dict(
                  "createIndexes" => "cats",
                  "indexes" => [
                      Dict(
                          "key" => Dict("name" => 1),
                          "name" => "cats_name",
                          "unique" => 1)
                      ]
                  ))
```

`command_simple` returns a `BSONObject` reply, so you can also perform aggregations:

```julia
command_simple(client,
               "db",
               OrderedDict(
                  "aggregate" => "cats",
                  "pipeline" => [
                      Dict("\$match" => Dict("age" => 19)),
                      Dict("\$group" => Dict("_id" => "\$name", "count" => Dict("\$sum" => 1)))
                  ]
                )
              )
```

Refer to the [MongoDB database commands docs](https://docs.mongodb.org/manual/reference/command/) for further commands.

Contributing
------------

Contributions are welcome!  Please fork on github.com and submit a pull request if you have a contribution you think is worthwhile!
