# xDOM - regular DOM with that little extra

This library adds a few convenient niceties on top of the DOM. Think jQuery, but less runtime wrapping and with Haxe in mind.

1. **type safe querying**, i.e. `document.find('form input:checked')[0]` is known to be an input element and so accessing its `value` property is done in a type safe manner - with auto completion:

  ![]()

  Also, selectors are parsed at compile time.

  The resulting collection allows for array access, iteration or more jQuery-esque chaining:

  ```haxe
  document.find('form input:checked').each(e -> e.checked = false);
  //Or the slightly shorter version
  document.each('form input:checked', e -> e.checked = false);
  ```

2. **type safe event handling**

  The standard `onevent` properties are shadowed in xDOM in favor of a different API:

  - Call with a `Callback` and get back a `CallbackLink`, e.g. `document.onclick(function (e) {})`
  - Call `once` with a `Callback` and get back a `CallbackLink`, e.g. `document.onclick.once(function (e) {})`
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

  - With just a selector, chaining with `once`

    ```haxe
    document.onclick.within('button.big.red').once(launchMissiles);
    ```

  Note that the `currentTarget` of the event will point to the element that was matched (the big red button in this case), not the one where the handler was registered (the document in this case).