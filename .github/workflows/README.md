For now I'm leaving this file empty since the game isn't even properly built,
but once we have a functional build of the game, we could run some unit tests automatically
to make sure we didn't accidentally break anything. Godot have some actions that build files,
which is nice, but we'll probably need to clean up the builds every once in a while due to 
github's max size for free projects.

We can only automate stuff that has a hard and obvious way to track, so we can't catch stuff
like unintended situations or visual glitches.

### Tests we'll need:
- Making sure the game properly builds, first and foremost.
- Make sure matchengine.rs's virtual frame updating takes less than 1600ms. The lower the better.

### Tests that may come in handy:
- Check what's the maximal amount of virtual frames we can rollback in 16mls.