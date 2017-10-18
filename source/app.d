import base;

/**
	The Main
 */
int main(string[] args) {
    import std.stdio;

    immutable program = "Way Master";
	version(Windows) {
		writeln( "This is a Windows version of " ~ program );
	}
	version(OSX) {
		writeln( "This is a Mac version of " ~ program );
	}
	version(linux) {
		writeln( "This is a Linux version of " ~ program );
	}

	if (setupAndStuff != 0) {
		writeln("Error in setupAndStuff!");
	}

    run;

	return 0;
}

auto setupAndStuff() {
	immutable WELCOME = "Welcome to Way Master";
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

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s", __FILE__, __FUNCTION__, __LINE__, retVal);
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

        writefln("File: %s, Error function: %s, Line: %s, Return value: %s", __FILE__, __FUNCTION__, __LINE__, retVal);
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

	g_letterBase = new LetterManager("lemgreen32.bmp", 8, 17, Square(0,0, g_window.getSize.x, g_window.getSize.y));
    assert(g_letterBase, "Error loading bmp");

	with(g_letterBase) {
		updateFileNLetterBase("Welcome to Way Master - Recall program" ~ newline);
		setLockAll(true);
	}

	run();

	return 0;
}

void run() {
    struct Info {
		string text;
		
		string toString() {
			return text;
		}
	}
	
	Info[string] lines;
	lines["W"] = Info("W Would you consider yourself to be a good person?");
	lines["D1"] = Info("D Do you think you have kept the Ten Commandments?");
	lines["J"] = Info("J Judgement -- If God were to judge you by the Ten Commandments, do you think you would be innocent or guilty?");
	lines["D2"] = Info("D Destiny -- Do you think you would go to heaven or hell?");
	
	lines["C"] = Info("C Concern -- Does that concern you?");
	lines["c"] = Info("c Cross -- Jesus suffered for our sins, died and rose from the dead.");
	lines["R"] = Info("R Repentance -- Confess and forsake all sin.");
	lines["A"] = Info("A and");
	lines["F"] = Info("F Faith -- More than belief, it's trust in Jesus for salvation.");
	lines["T"] = Info("T Truth -- Point to the truth of the Bible and encourage them to get right with God today.");


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

        if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
            Keyboard.isKeyPressed(Keyboard.Key.Q))
            done = YES;

        // print for prompt, text depending on whether the section has any verses or not
        if (enterPressed || firstRun) {
            firstRun = false;
            enterPressed = false;
            updateFileNLetterBase("Enter query, (Enter 'h' for help):");
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
                userInput = g_letterBase.getText()[ prefix .. $  ].stripRight;
                upDateStatus(userInput);

                if (userInput in lines) {
                    updateFileNLetterBase(lines[userInput]);
                    continue;
                }
            }
        }
        else
            userInput = "q";
        if (userInput.length > 0) {
            // If command not used, the user input is treated as thing typed from memory
            // Switch on command
            switch (userInput) {
                // Display help
                case "h":
                    g_letterBase.addTextln("Help:" ~ newline ~
                        "q - Quit" ~ newline ~
                        "h - This help" ~ newline ~
                        "v - View stuff to recall" ~ newline ~
                        "cls/clear - Clear screen (hide memory verse)"
                    );
                break;
                case "cls", "clear":
                    clearScreen;
                break;
                case "v":
                    updateFileNLetterBase(
`WDJD:

W Would you consider yourself to be a good person?
D1 Do you think you have kept the Ten Commandments?
J Judgement -- If God were to judge you by the Ten Commandments, do you think you would be innocent or guilty?
D2 Destiny -- Do you think you would go to heaven or hell?


CcRAFT:

C Concern -- Does that concern you?
c Cross -- Jesus suffered for our sins, died and rose from the dead.
R Repentance -- Confess and forsake all sin.
A and
F Faith -- More than belief, it's trust in Jesus for salvation.
T Truth -- Point to the truth of the Bible and encourage them to get right with God today.`);
                break;
                // quit program
                case "q":
                    done = true;
                break;
                default:
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
