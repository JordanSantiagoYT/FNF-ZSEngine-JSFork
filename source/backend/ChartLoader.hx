package backend;

import sys.io.File;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import sys.thread.Thread;

class ChartLoader
{
    public static var useBinary:Bool = false;
    public static var useThreaded:Bool = false;
    public static var onProgress:Float->Void = null;
    
    static final MAGIC:Int = 0x43484152; // "CHAR"
    static final VERSION:Int = 1;
    
    public static function saveBinary(song:SwagSong, path:String):Void
    {
        var output = new BytesOutput();
        
        // Header
        output.writeInt32(MAGIC);
        output.writeInt32(VERSION);
        output.writeString(song.song);
        output.writeFloat(song.bpm);
        
        // Sections
        output.writeInt32(song.notes.length);
        for (section in song.notes)
        {
            output.writeFloat(section.sectionBeats);
            output.writeBool(section.mustHitSection);
            output.writeBool(section.changeBPM);
            output.writeFloat(section.bpm);
            output.writeBool(section.altAnim);
            output.writeBool(section.gfSection);
            
            // Notes in this section
            output.writeInt32(section.sectionNotes.length);
            for (note in section.sectionNotes)
            {
                output.writeFloat(note[0]); // strumTime
                output.writeInt32(note[1]); // noteData
                output.writeFloat(note[2]); // sustainLength
                if (note.length > 3)
                    output.writeString(note[3]); // noteType
                else
                    output.writeString("");
            }
        }
        
        File.saveBytes(path, output.getBytes());
    }
    
    public static function loadBinary(path:String, ?chunkSize:Int = 10000):SwagSong
    {
        var bytes = File.getBytes(path);
        var input = new BytesInput(bytes);
        
        if (input.readInt32() != MAGIC)
            throw "Invalid binary chart file";
        if (input.readInt32() != VERSION)
            throw "Unsupported binary version";
        
        var song:SwagSong = {
            song: input.readString(),
            bpm: input.readFloat(),
            notes: []
        };
        
        var sectionCount = input.readInt32();
        var processedNotes:Int = 0;
        
        for (i in 0...sectionCount)
        {
            var section:SwagSection = {
                sectionNotes: [],
                sectionBeats: input.readFloat(),
                mustHitSection: input.readBool(),
                changeBPM: input.readBool(),
                bpm: input.readFloat(),
                altAnim: input.readBool(),
                gfSection: input.readBool()
            };
            
            var noteCount = input.readInt32();
            var notes:Array<Dynamic> = [];
            
            for (j in 0...noteCount)
            {
                var note:Array<Dynamic> = [
                    input.readFloat(),
                    input.readInt32(),
                    input.readFloat()
                ];
                var noteType = input.readString();
                if (noteType != "") note.push(noteType);
                notes.push(note);
                processedNotes++;
                
                if (onProgress != null && processedNotes % chunkSize == 0)
                {
                    onProgress(processedNotes / (sectionCount * noteCount));
                }
            }
            section.sectionNotes = notes;
            song.notes.push(section);
        }
        
        return song;
    }
    
    public static function loadAsync(path:String, onComplete:SwagSong->Void, onError:String->Void):Void
    {
        var thread = Thread.create(function()
        {
            try
            {
                var chart:SwagSong = null;
                if (useBinary && FileSystem.exists(path + ".bin"))
                    chart = loadBinary(path + ".bin");
                else
                    chart = Song.loadFromJson(Paths.formatToSongPath(Path.withoutExtension(path)));
                
                Thread.current().send(chart);
            }
            catch(e:Dynamic)
            {
                Thread.current().send(e);
            }
        });
        
        while (true)
        {
            var msg = thread.readMessage(false);
            if (msg != null)
            {
                if (Std.is(msg, SwagSong))
                    onComplete(msg);
                else
                    onError(Std.string(msg));
                break;
            }
            if (onProgress != null) onProgress(0.5);
            Sys.sleep(0.01);
        }
    }
}