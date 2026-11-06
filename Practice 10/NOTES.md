# Practice 10 notes

## Level 1 · event order

Predicted order before running the temporary experiment:

1. `A`
2. `C`
3. the app's first frame
4. after about two seconds, `B`
5. `6 students`

Actual order: `A`, `C`, the first frame, then `B` and `6 students` after the delay. The two timers became later events; `main()` and the first frame did not wait for either Future.

The deliberate third unhandled fetch printed:

`Unhandled Exception: Instance of 'NoConnectionException'`

Replacing the awaited delay with `sleep(const Duration(seconds: 2))` blocked the isolate and delayed the first frame. Restoring `await Future.delayed(...)` let Flutter render while the operation waited.

## Level 2 · mounted

After temporarily removing both mounted guards and leaving the screen before the response, Flutter's first error line was:

`setState() called after dispose()`

Restoring `if (!mounted) return;` means a response can arrive safely after its State has gone.

## Level 4 · countdown ownership

Version B without `cancel()` kept printing `tick 6`, `tick 5` … through `tick 0` after Back and also produced `setState() called after dispose()`. With `_sub.cancel()` restored, output stops when the screen leaves.

Version A needs no explicit cancellation in this screen. Leaving while its StreamBuilder is subscribed makes StreamBuilder cancel its subscription, so its generator stops at the next await and no later ticks appear.

## Level 5 · awaited errors

The deliberately un-awaited Save produced:

`Unhandled Exception: Bad state: server rejected 6`

The screen popped as if saving worked even though the server rejected the value. The final handler awaits the request, catches only `StateError`, shows its message, and pops only after success. `_saving` disables the button immediately so two fast taps still make one request.
