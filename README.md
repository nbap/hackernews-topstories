# HackerNews Aggregator

This project is presented as a skill assessment for ESL.

It is built with:
**Erlang 23.0.1**
**Elixir 1.10.3**

### Getting started:

 1)  Get dependencies and compile project
  `$ mix deps.get && mix deps.compille --all`

2) Run tests (optional)
    `$ MIX_ENV=test mix test`

3) Start server
    `$ mix run --no-halt`

## HTTP API

### Get top 50 stories from Hacker News

`http://127.0.0.1:4001/stories`

The results are always paginated and without the page param, the first page is the default.
#### Query params
| Param name | Description | Usage |
|----------------|------------------|------|
| page | select page to navigate to | `page=<integer>`

#### Response Headers

| Header | Description |
|----------------|-----------------------------------|
| x-total-pages | Total pages available to navigate |
| x-current-page | Current page |
| last-modified | Last stories' update |

  

### Get a single story from top 50

`http://127.0.0.1:4001/stories/<story_id>`

#### Response Headers
  | Header | Description |
|----------------|-----------------------------------|
| last-modified | Last stories' update |

## WebSocket

`ws://127.0.0.1:4001/ws`

  
### Get top 50 stories from Hacker News

Send `topstories` to receive the stories.
*Remember to keep the client alive to see stories refreshed every 5 minutes.*
