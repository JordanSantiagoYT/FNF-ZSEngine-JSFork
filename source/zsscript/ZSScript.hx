package zsscript;

import psychlua.FunkinLua;
import llua.Lua;
import llua.LuaL;
import llua.State;

class ZSScript extends FunkinLua {
    public function new(path:String, luaContent:String) {
        super(path + ".zs.lua");

        if (this.lua != null) {
            Lua.close(this.lua);
        }

        this.lua = LuaL.newstate();
        LuaL.openlibs(this.lua);

        var result = LuaL.dostring(this.lua, luaContent);
        if (result != 0) {
            var errorStr = Lua.tostring(this.lua, -1);
            Lua.pop(this.lua, 1);
            trace('Lua error in $path: $errorStr');
        }

        this.closed = false;
        this.scriptName = path;
    }

    override public function stop() {
        if (lua != null && !closed) {
            Lua.close(lua);
            lua = null;
        }
        closed = true;
    }
}