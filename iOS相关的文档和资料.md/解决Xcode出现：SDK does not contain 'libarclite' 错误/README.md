# Libarclite-Files

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

[toc]

> 资料来源
>
> ```javascript
> https://github.com/kamyarelyasi/Libarclite-Files.git
> ```

Xcode 14.3 and 14.3.1 has build issues with some Cocoa pods because of the absence of '.a' files in its XcodeDefaults toolchain contents.
Here are all the missing files in Xcode 14.3.

You can download and paste it into this path:
> ```javascript
> $APPLICATIONS_DIR/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain$SYSTEM_USR_DIR/lib/arc/
> ```

- Note: Create a folder called 'arc' in lib folder if it doesn't exist.
