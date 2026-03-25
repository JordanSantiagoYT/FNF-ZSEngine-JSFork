package backend;

import haxe.Json;
import lime.utils.Assets;

import objects.Note;

typedef SwagSong =
{
	> PlayState.SONG,
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var format:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;
	
	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
	@:optional var __db:Dynamic;
    @:optional var __dbPath:String;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	@:optional var altAnim:Bool;
	@:optional var gfSection:Bool;
	@:optional var bpm:Float;
	@:optional var changeBPM:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var gameOverChar:String;
	public var gameOverSound:String;
	public var gameOverLoop:String;
	public var gameOverEnd:String;
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var format:String = 'psych_v1';

	public var originalLoading:Bool = false;

	public static function convert(songJson:Dynamic) // Convert old charts to psych_v1 format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			if(Reflect.hasField(songJson, 'player3')) Reflect.deleteField(songJson, 'player3');
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		var sectionsData:Array<SwagSection> = songJson.notes;
		if(sectionsData == null) return;

		for (section in sectionsData)
		{
			var beats:Null<Float> = cast section.sectionBeats;
			if (beats == null || Math.isNaN(beats))
			{
				section.sectionBeats = 4;
				if(Reflect.hasField(section, 'lengthInSteps')) Reflect.deleteField(section, 'lengthInSteps');
			}

			for (note in section.sectionNotes)
			{
				var gottaHitNote:Bool = (note[1] < 4) ? section.mustHitSection : !section.mustHitSection;
				note[1] = (note[1] % 4) + (gottaHitNote ? 0 : 4);

				if(!Std.isOfType(note[3], String))
					note[3] = Note.defaultNoteTypes[note[3]]; //compatibility with Week 7 and 0.1-0.3 psych charts
			}
		}
	}

	public static var chartPath:String;
	public static var loadedSongName:String;
	public static function loadFromJsonStreaming(jsonInput:String, ?folder:String, onProgress:Float->Void = null):SwagSong
	{
		if(folder == null) folder = jsonInput;

		var filePath:String = '';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modsJson(folder + '/' + jsonInput)))
			filePath = Paths.modsJson(folder + '/' + jsonInput);
		else if(FileSystem.exists(Paths.json(folder + '/' + jsonInput)))
			filePath = Paths.json(folder + '/' + jsonInput);
		#else
		if(OpenFlAssets.exists(Paths.json(folder + '/' + jsonInput)))
			filePath = Paths.json(folder + '/' + jsonInput);
		#end

		if(filePath == '')
		{
			trace('Chart not found: ' + jsonInput);
			return null;
		}

		// Use streaming parser for large files
		var file = sys.io.File.read(filePath);
		var parser = new haxe.format.JsonParser(new haxe.io.BytesInput(file.readAll()));

		try
		{
			var obj = parser.parse();
			var song:SwagSong = cast obj;

			#if cpp
			var totalNotes:Int = 0;
			for (sec in song.notes) totalNotes += sec.sectionNotes.length;

			if (totalNotes > 300000 && onProgress != null)
			{
				onProgress(0);
			}

			// Process notes in chunks
			var chunkSize:Int = 5000;
			var processedNotes:Int = 0;
			var processedSections:Int = 0;

			for (section in song.notes)
			{
				var originalNotes = section.sectionNotes;
				var newNotes:Array<Dynamic> = [];

				for (i in 0...Std.int(Math.ceil(originalNotes.length / chunkSize)))
				{
					var start = i * chunkSize;
					var end = Std.int(Math.min(start + chunkSize, originalNotes.length));

					for (j in start...end)
					{
						newNotes.push(originalNotes[j]);
						processedNotes++;
					}

					if (onProgress != null && totalNotes > 0)
					{
						onProgress(processedNotes / totalNotes);
					}

					// Force GC periodically
					if (processedNotes % 100000 == 0)
					{
						#if cpp
						cpp.vm.Gc.enable(true);
						cpp.vm.Gc.enable(false);
						#end
						Sys.sleep(0.001);
					}
				}
				section.sectionNotes = newNotes;
				processedSections++;
			}

			trace('Loaded ' + processedNotes + ' notes from ' + filePath);
			#end

			PlayState.SONG = song;
			loadedSongName = folder;
			chartPath = _lastPath;

			#if windows
			chartPath = chartPath.replace('/', '\\');
			#end

			StageData.loadDirectory(PlayState.SONG);
			return PlayState.SONG;
		}
		catch(e:Dynamic)
		{
			trace('Error parsing JSON: ' + e);
			return null;
		}
		finally
		{
			file.close();
		}
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		if(folder == null) folder = jsonInput;

		if (!originalLoading)
		{
			// Try streaming parser first (handles large files better)
			var song = loadFromJsonStreaming(jsonInput, folder);
			if (song != null)
			{
				loadedSongName = folder;
				StageData.loadDirectory(song);
				return song;
			}
		}
		else
		{
			// Ultimate fallback to original parser
			PlayState.SONG = getChart(jsonInput, folder);
			loadedSongName = folder;
			chartPath = _lastPath;
		}

		#if windows
		chartPath = chartPath.replace('/', '\\');
		#end

		StageData.loadDirectory(PlayState.SONG);
		return PlayState.SONG;
	}

	static var _lastPath:String;
	public static function getChart(jsonInput:String, ?folder:String):SwagSong
	{
		if(folder == null) folder = jsonInput;
		var rawData:String = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		_lastPath = Paths.json('$formattedFolder/$formattedSong');

		#if MODS_ALLOWED
		if(FileSystem.exists(_lastPath))
			rawData = File.getContent(_lastPath);
		else
		#end
			rawData = Assets.getText(_lastPath);

		return rawData != null ? parseJSON(rawData, jsonInput) : null;
	}

	public static function parseJSON(rawData:String, ?nameForError:String = null, ?convertTo:String = 'psych_v1'):SwagSong
	{
		var songJson:SwagSong = cast Json.parse(rawData);
		if(Reflect.hasField(songJson, 'song'))
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if(subSong != null && Type.typeof(subSong) == TObject)
				songJson = subSong;
		}

		if(convertTo != null && convertTo.length > 0)
		{
			var fmt:String = songJson.format;
			if(fmt == null) fmt = songJson.format = 'unknown';

			switch(convertTo)
			{
				case 'psych_v1':
					if(!fmt.startsWith('psych_v1')) //Convert to Psych 1.0 format
					{
						trace('converting chart $nameForError with format $fmt to psych_v1 format...');
						songJson.format = 'psych_v1_convert';
						convert(songJson);
					}
			}
		}
		return songJson;
	}
}