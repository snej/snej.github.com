---
title: "Notes Toward A Social-Network Schema"
tags: []
layout: post
comments: true
---

Modeling a social network in a JSON-document-oriented database like Couchbase [Lite] or CouchDB isn't hard. Here's a basic schema that I've been playing with for a while.

## Schema

Top level items are document types (generally distinguished by a reserved `type` field), nested items are properties.

* Persona
  *  nickname
  *  Full name (optional)
  *  userpic (optional)
  *  bio (optional)
* Relation
  *  author ID
  *  target persona ID
  *  relation types (one or more of: follows, friend, …)
* Post
  *  author ID
  *  date created
  *  date updated (only if edited)
  *  privacy (public / friends-only / ...)
  *  body
  *  post type (text / quote / picture / audio…)
  *  media attachments (optional depending on post type)
* Comment
  *  author ID
  *  post ID
  *  date created
  *  body

## Notes

Properties that say "ID" contain the ID of the target document (much like a SQL foreign key.) "Author ID" specifically means the ID of the Persona who created/owns the document.

Documents can only be created or updated by the user listed in the 'author ID' property (or the doc ID in the case of a Persona.) 

Note that this means that relations are one-directional and always point outward: you specify how you relate _to_ someone. Some relationship types are intrinsically bi-directional, like "friend" or "sibling", and have to be declared in both directions to be considered valid.

I've been using the [XFN](http://gmpg.org/xfn/11) schema as a source of relationship types. It contains a ridiculous number; these might be appropriate for something like Facebook, but for a more casual system like tumblr or Twitter the only one you really need is "follows".

"Body" properties should probably be tagged with a markup type to distinguish between formats like plain text, Markdown, HTML, and bloggy-HTML (i.e. with hard linebreaks.)

The "post type" is mostly a hint to trigger different visual styling of the post, _a la_ tumblr and other tumble-logs.

"Media attachments" would be, literally, attachments in Couchbase Lite or CouchDB. Other databases might need to use URLs instead and host the media externally.

A "like" / "heart" / "+1" can be treated as a comment with no body.

If you generalize the comment "post ID" property to be able to point to things other than posts, you can easily get hierarchical/threaded comments (comment-on-comment) or "wall" posts (comment-on-persona).

If posts can be non-public, the server needs to limit access to them. Specifically, a "friends-only" type of post should be readable only by people that the post's author has the right kind of published relationship to, and obviously a "private" post can only be read by its author. (This is basically infeasible with CouchDB, which doesn't support per-document read access control. The Couchbase Sync Gateway does support it.)

## Limitations

**Comment free-for-all:** In this model anyone can comment on any post just by publishing a comment targeted at it. There are [obvious social problems](http://youtube.com) with that. A workaround is to have the post itself contain an array of "approved comment" IDs; this requires that the post author or her software moderate comments and update the post to add new ones. The UI would generally only display the comments in that list.

**Replication/P2P:** This schema will suffice in a centralized system where the server can enforce authenticity and limit the visibility of non-public posts. Once you add replication, things get trickier. Authenticating a document requiress that it be signed by its author, which in turn means a Persona document needs to contain a certificate or a public key, which in turn requires some mechanism (a PKI) for so you can verify that a Persona refers to the person you think it does. Also, non-public posts will require encryption if they're ever to be replicated through intermediary servers that don't have read access to them.