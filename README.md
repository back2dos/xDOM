# xDOM - regular DOM with that little extra

This library adds a few convenient niceties on top of the DOM. Think jQuery, but less runtime wrapping and with Haxe in mind. It also offer integration with `tink.core.Signal`, but feel free to ignore it if that approach does not appeal to you.

The extra functionality is obtained by wrapping dom nodes in the `xdom.Wrapped<T>` abstract (which exists at compile time only) where `T` is the concrete node type, e.g. `js.html.Node` or `js.html.SelectElement`.

There are two easy entrypoints into using `xDOM`, both of which become available with `import xdom.XDom.*`:

- `X`: called with any node, you will obtain a wrapped version
- `document`: this is a wrapped document, which when queried for descendants returns wrapped versions again.

The following examples tend to use `document`, but all of them would work with any wrapped nodes.

1. **type safe querying**, i.e. `document.find('form input:checked')[0]` is known to be an input element and so accessing its `value` property is done in a type safe manner - with auto completion and code navigation:

   <img src="https://user-images.githubusercontent.com/509501/43994633-8d11a412-9da0-11e8-9425-6ab92e32c0bf.gif" width="450px">

   Also, selectors are validated at compile time:
  
   <img src="https://user-images.githubusercontent.com/509501/43994718-0fc340ea-9da2-11e8-8258-3c157dcd3cc1.gif" width="450px">

   The resulting collection allows for array access, iteration or more jQuery-esque chaining:

   ```haxe
   //Ordinary loop:
   for (e in document.find('form input:checked')) e.checked = false;
   //With function:
   document.find('form input:checked').each(e -> e.checked = false);
   //Or the slightly shorter version
   document.each('form input:checked', e -> e.checked = false);
   ```

2. **type safe event handling**

   The standard `onevent` properties are shadowed in xDOM in favor of a different API:

   - Call with a `Callback` and get back a `CallbackLink`, e.g. `document.onclick(function (e) {})`
   - Call `once` with a `Callback` and get back a `CallbackLink`, e.g. `document.onclick.once (function (e) {})`
   - Convert to `Signal`, e.g. `document.onclick.signal`. Note that this conversion is implicit. Also `map`, `join`, `filter`, `select` and `nextTime` can be called directly, e.g. `minusButton.onclick.map(e -> -1)`.

   The main "twist" is that the event type is known and that the `target` is an `Element` and the `currentTarget` is of the type of the element you registered your handler with, so e.g. `button.onclick(e -> e.currentTarget.disabled = true)` will work properly.

3. **type safe event delegation**

   Every of the above events also has a `within` macro that you may call in two different ways:

   - With a selector and a callback:

     ```haxe
     document.onclick.within('[data-tooltip]', function (e) {
       renderTooltip(e.clientX, e.clientY, e.target.dataset.tooltip);
     });
     ```

     The result of this is again a `CallbackLink`

   - With just a selector, which produces a `Signal`:

     ```haxe
     document.onchange.within('input[type="radio"][name="font-size"]').map(e -> e.target.value);
     ```

     In this case we're mapping it to produce a signal of font sizes.

   - With just a selector, chaining with `once`

     ```haxe
     document.onclick.within('button.big.red').once(launchMissiles);
     ```

     The result of this is again a `CallbackLink`

   Note that the `currentTarget` of the event will point to the element that was matched (the big red button in this case), not the one where the handler was registered (the document in this case).

And really, that's it. On top of that, you can just use the plain DOM APIs.

## Why shadow `onclick` etc.?

As a rule, this library tries not to abstract away the DOM, just add a bit of type safety and convenience. That said, using `element.onclick = function () {...}` is largely discouraged in favor of the more recent `element.addEventListener('click', function () {...})` for various reasons. Arguably no harm is done in shadowing it. And doing so results in straight forward autocompletion and short notation for events.
