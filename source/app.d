//#windows version needed for short cut to quit
import base;

struct Info {
    string text;
    
    string toString() {
        return text;
    }
}

Info[string] lines;
string title, list;

enum programName = "Guess Pop";
enum projects = "projects";
/**
	The Main
 */
int main(string[] args) {
    import std.stdio;

	version(Windows) {
		writeln("This is a Windows version of " ~ programName);
	}
	version(OSX) {
		writeln("This is a Mac version of " ~ programName);
	}
	version(linux) {
		writeln("This is a Linux version of " ~ programName);
	}

	if (setupAndStuff != 0) {
		writeln("Error in setupAndStuff!");
	}

	return 0;
}

auto setupAndStuff() {
	immutable WELCOME = "Welcome to " ~ programName;
	g_window = new RenderWindow(VideoMode(800, 600),
						WELCOME);

    if (setup != 0) {
		gh("Aborting...");
		g_window.close;

		return 1;
	}

    g_checkPoints = true;
    if (int retVal = jec.setup != 0) {
        import std.stdio: writefln;

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s",
            __FILE__, __FUNCTION__, __LINE__, retVal);
        return -1;
    }

    immutable g_fontSize = 40;
    g_font = new Font;
    g_font.loadFromFile("DejaVuSans.ttf");
    if (! g_font) {
        import std.stdio: writeln;
        writeln("Font not load");
        return -1;
    }

    g_checkPoints = true;
    if (int retVal = jec.setup != 0) {
        import std.stdio: writefln;

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s",
            __FILE__, __FUNCTION__, __LINE__, retVal);
        return retVal;
    }

    //immutable size = 100, lower = 40;
    immutable size = g_fontSize, lower = g_fontSize / 2;
    jx = new InputJex(/* position */ Vector2f(0, g_window.getSize.y - size - lower),
                    /* font size */ size,
                    /* header */ "Word: ",
                    /* Type (oneLine, or history) */ InputType.history);
    jx.setColour(Color(255, 200, 0));
    jx.addToHistory(""d);
    jx.edge = false;

    g_mode = Mode.edit;
    g_terminal = true;

    jx.addToHistory(WELCOME);
    jx.showHistory = false;

    g_window.setFramerateLimit(60);

	g_letterBase = new LetterManager("lemgreen32.bmp", 8, 17,
        Square(0,0, g_window.getSize.x, g_window.getSize.y));
    assert(g_letterBase, "Error loading bmp");

    updateFileNLetterBase(WELCOME, " - Recall program" ~ newline);
    g_letterBase.setLockAll(true);

    string[] files;

    doProjects(files, /* show */ false);
    run(files);

	return 0;
}

void run(string[] files) {
    import std.path;
    import std.string;
    import std.file: readText;

    auto helpText = readText("help.txt");
    with( g_letterBase )
        setTextType( TextType.line );
    scope(exit)
        g_window.close();
    string userInput;
    bool enterPressed = false; //#enter pressed
    int prefix;
    prefix = g_letterBase.count();
    auto firstRun = true;
    auto done = NO;
    while(! done) {
        if (! g_window.isOpen())
            done = YES;

        Event event;

        while(g_window.pollEvent(event)) {
            if(event.type == event.EventType.Closed) {
                done = YES;
            }
        }

        version(OSX)
            if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) ||
                Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
                Keyboard.isKeyPressed(Keyboard.Key.Q))
                done = YES;
        //#windows version needed for short cut to quit

        // print for prompt, text depending on whether the section has any verses or not
        if (enterPressed || firstRun) {
            firstRun = false;
            enterPressed = false;
            if (! done)
                updateFileNLetterBase("Enter query, (Enter 'help' for help):");
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
        }
        // exit program if set to exit else get user input
        if (done == NO) {
            import std.string;
            g_window.clear;
            
            g_letterBase.draw();

            with( g_letterBase ) {
                doInput(/* ref: */ enterPressed);
                update(); //#not much
            }

            g_window.display;
            
            if (enterPressed) {
                userInput = g_letterBase.getText[prefix .. $].stripRight;
                upDateStatus(userInput);

                if (userInput in lines) {
                    updateFileNLetterBase(lines[userInput]);
                    userInput = "";
                    continue;
                }
            }
        }
        if (userInput.length > 0) {
            import std.string: toLower;

            // If command not used, the user input is treated as thing typed from memory
            // Switch on command
            const args = userInput.split[1 .. $];
            switch (userInput.split[0].toLower) {
                // Display help
                case "help":
                    updateFileNLetterBase(helpText);
                break;
                case "projects":
                    doProjects(files);
                break;
                case "load":
                    if (args.length != 1) {
                        updateFileNLetterBase("Wrong amount of parameters!");
                        break;
                    }
                    string fileName;
                    try {
                        import std.conv;

                        int index = args[0].to!int;
                        if (index >= 0 && index < files.length)
                            fileName = files[index];
                        else
                            throw new Exception("Index out of bounds");
                    } catch(Exception e) {
                        updateFileNLetterBase("Input error!");
                        break;
                    }
                    loadProject(fileName);
                    import std.path: stripExtension;
                    updateFileNLetterBase(fileName.stripExtension, " - project loaded..");
                break;
                case "cls", "clear":
                    clearScreen;
                    updateFileNLetterBase("Screen cleared..");
                break;
                case "list":
                    updateFileNLetterBase(title, "\n\n", list);
                break;
                // quit program
                case "quit", "command+q":
                    done = true;
                break;
                default:
                    updateFileNLetterBase(userInput.split[0], " - Unhandled command, or key ..");
                break;
            }
        }
        if (enterPressed) {
            userInput.length = 0;
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
        }
    }
}

/// clear the screen
void clearScreen() {
    g_letterBase.setText("");
}

void doProjects(ref string[] files, in bool show = true) {
    import std.file: dirEntries, SpanMode;
    import std.path: dirSeparator, buildPath, stripExtension;
    import std.range: enumerate;
    import std.string: split;

    if (show)
        updateFileNLetterBase("File list:");
    files.length = 0;
    foreach(i, string name; dirEntries(buildPath(projects), "*.{txt}", SpanMode.shallow).enumerate) {
        import std.conv: to;

        name = name.split(dirSeparator)[1];
        if (show)
            updateFileNLetterBase(i, " - ", name.stripExtension);
        files ~= name;
    }
}

void loadProject(in string fileName) {
    import std.conv: to;
    import std.stdio: File;
    import std.string: split;
    import std.path: buildPath;
    import std.range: enumerate;

    enum Flag : bool {down, up}

    bool listFlag = Flag.down;
    list.length = 0;
    lines.clear;
    foreach(i, line; File(buildPath(projects, fileName)).byLine.enumerate) {
        if (i == 1)
            title = line.to!string;
        if (listFlag == Flag.up) {
            lines[line.split[0].to!string] = Info(line[line.split[0].length + 1 .. $].to!string);
            list ~= line.to!string ~ "\n";
        }
        if (line.to!string == "list:")
            listFlag = Flag.up;
    }
}
