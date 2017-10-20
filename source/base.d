//#Why doesn't this work, get weird effects
module base;

import std.conv;
import std.datetime;
import std.range;
import std.stdio;
import std.string;

public import jec;

immutable newline = "\n";
enum YES = true, NO = false;

LetterManager g_letterBase;

void updateFileNLetterBase(T...)(T args) {
	import std.typecons: tuple; // untested
	import std.conv: text;

	//g_letterBase.addTextln(text(tuple(args).expand));
	g_letterBase.addTextln(args); //#Why doesn't this work, get weird effects
	upDateStatus(args);
}

StopWatch g_sw;

static this() {
	g_sw.start;
}
