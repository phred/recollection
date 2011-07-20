recollection: orthogonal undo history for CouchDB documents
===

A little grease for CouchDB development!

CouchDB stores revision history, but moving beyond one CouchDB node, an application can't rely on the revision history.  Making things harder, the latest CouchDBs automatically compact the database and trim old revisions.  Unless an application is specifically built to record a version history, document changes are lost into the æther.

This is all well and good until, plugging along at my Couch application, I thrash one of my precious documents.  If I'm lucky, I can jump into Futon and resurrect the previous version, but there's no guarantee I won't be screwed at this point.

Enter `recollection`: a tiny `nodejs` proxy server that intercepts CouchDB replication and silently creates full documents for each revision change.
