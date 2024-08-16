# README

Problem description:

We need to implement a shopping list with checkable items.

- Checking/Unchecking a item should enqueue the change, wait for a safety time to elapse (to make sure user is done with changes), then perform a batch rquests using the enqueued items.
- Changes that will not update the state (as checking an item, then immediately right after unchecking it or viceversa) should be removed from the queue thus preventing an innecesary call
- UI should be optimistic

I faced a similar problem when I was a junior at V-labs, but the I way I solved
wasn't the best. 

As this is a really interesting exercise I wanted to try again with today knowledge.
Still not sure this is the best approach, but is definitely an improvement over that junior implementation, it "only" tooks me 3 complete days (😅) and a lot of talk with chatGPT.


