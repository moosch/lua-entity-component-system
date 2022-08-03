# Entity Component System - Data Oriented Programming

This is a rehash of the old but excellent article by Erik Hazzard on ECS and data driven design found [here](http://vasir.net/blog/game-development/how-to-build-entity-component-system-in-javascript).

Except instead of writing it in JavaScript, I'm using Lua and rendering through [LÖVE2D](https://love2d.org/).

Currently, this is just something I'm looking into out of interest. As a (mostly) web/mobile dev exploring gaming programming, I'm interested in the code structure concepts, so why not hey!

## Improvements

Pass to each system only the entities that system cares about

Restructure to only do a single `for` in `love.update` and `love.draw`. For removals this would mean some kind of callback or event registering that would allow systems to make additional updates (additions/removals) _after_ a pass. Or perhaps even better, a "mark-for-removal" flag on each entitiy that a seperate system handles, and a game-level spawn count for another system to handle?
