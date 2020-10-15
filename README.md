# Notes

The aim of this project is to build a "print" server for LaTeX fils.  Such files (which must
by self-contained) can be sent to the server via a POST request. It is received, `pdflatex` is
run on it, and the client can then request a webpages with a download link to the PDF file.

The project is incomplete.


## Setup

```
$ stack build
$ stack exec pdfServer
```

The above will create an SqlLite database in the project root.

## Commands to test the database (POST and GET data)

```
curl -H 'Content-type: application/json' localhost:3000/user --data '{"docId": "abc44", "owner": "santa", "content": "This s a test. Ho ho ho! }'

curl -H localhost:3000/doc/abc44
```

## Test production of PDF files

```
$ stack ghci
> pubishPdf lambda
```

The file `lambda.tex` is found in directory `texFiles`.
After runing the commands, open `pdfFiles/lambda.pdf` in a browser.
Then click on the link.


## Notes from the seed project:


This project is a small example for how to set up a web-server with
[servant-server](http://haskell-servant.readthedocs.io/) that uses
[persistent](https://www.stackage.org/package/persistent) for saving data to a
database.

You can build and run the project with [stack](http://haskellstack.org/), e.g.:

```shell
stack build
stack exec pdfServer
```

Then you can query the server from a separate shell:

```shell
curl -H 'Content-type: application/json' localhost:3000/user --data '{"name": "Alice", "age": 42}'
curl -H 'Content-type: application/json' localhost:3000/user/Alice
```
