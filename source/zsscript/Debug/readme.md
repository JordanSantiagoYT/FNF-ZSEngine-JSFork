How to debug
- Step 1: Go to `setup/` folder and install libraries
- Step 2: Install `hxparse` and `hxjsonast`
- Step 3: Go to `DebugTranspiler.hx` and run `haxe -main DebugTranspiler -cp . -lib hxparse -lib hxjsonast -dce no --interp`