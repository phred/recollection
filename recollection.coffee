Http = require 'http'
Util = require 'util'
Url = require 'url'
Path = require 'path'

readHost = (host_header) ->
  parts = host_header.split(':')
  { name: parts[0], port: parts[1] || 80 }
		

Http.createServer( (request, response) ->
  Util.debug "#{request.method} #{request.url}"
  Util.debug Util.inspect request.headers

  host = readHost(request.headers['host'])
  body = ""
  proxy = Http.createClient host.port, host.name
  proxy_request = proxy.request request.method, request.url, request.headers;
  
  if request.method is 'POST' and request.url.match(/_bulk_docs$/)
    # database = Path.dirname Url.parse(request.url).pathname
    request.addListener 'end', () ->
      Util.puts "Got document: " + body
      replication_doc = JSON.parse(body)
      
      for doc in replication_doc.docs
        doc._id += "_at_" + doc._rev.split('-')[0]

      doc_client = Http.createClient host.port, host.name
      doc_request = doc_client.request 'POST', Url.parse(request.url).pathname, {'content-type': 'application/json'}

      doc_request.addListener 'response', (doc_update_response) ->
        doc_update_response.addListener 'data', (chunk) ->
          Util.puts chunk

      doc_request.end JSON.stringify(replication_doc)

  proxy_request.addListener 'response', (proxy_response) ->
    proxy_response.addListener 'data', (chunk) ->
      response.write chunk, 'binary'

    proxy_response.addListener 'end', ->
      response.end()

    response.writeHead proxy_response.statusCode, proxy_response.headers

  request.addListener 'data', (chunk) ->
    body += chunk
    proxy_request.write chunk, 'binary'

  request.addListener 'end', ->
    proxy_request.end()

).listen(8080)

