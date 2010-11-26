var maxMUDlines = 10;
var MUD_content = [];

var wipeMUD = func {
    MUD_content = [];
    filled_index = 0;
    foreach (var p; mud.getChildren("line")) {
        p.setValue('');
    }
    mud.getNode("title").setValue('');
}

var setMUDTitle = func (t) {
    mud.getNode("title").setValue(t);
}

var addToMUD = func (content, callback = void) {
    append(MUD_content, [content, callback]);
}

var openMUD = func (callback = void) {
    fillMUD();
    largeFMSknob = selectMUDblock;
    ENTsoftkey = applyMUDcallback;
    callback();
    mud.getNode("displayed").setBoolValue(1);
    mud.getNode("selected-block").setIntValue(0);
}

var closeMUD = func (callback = void) {
    mud.getNode("displayed").setBoolValue(0);
    mud.getNode("selected-block").setIntValue(0);
    largeFMSknob = void;
    ENTsoftkey = void;
    callback();
    wipeMUD();
}

var fillMUD = func (starting_block = 0) {
    var f = 0;
    var b = 0;
    for (b = starting_block; b < size(MUD_content); b += 1) {
        var s = size(MUD_content[b][0]);
        f + s <= maxMUDlines or break;
        for (var i = 0; i < s; i += 1) {
            var c = f + i;
            mud.getNode("line[" ~ c ~ "]").setValue(MUD_content[b][0][i]);
        }
        f += s;
    }
    mud.getNode("first-displayed-block").setIntValue(starting_block);
    mud.getNode("last-displayed-block").setIntValue(b - 1);
}

var highlightSelectedMUDblock = func (block = 0) {
    block < size(MUD_content) or return;
    block >= 0 or return;
    
    var last = mud.getNode("last-displayed-block").getValue();
    var first = mud.getNode("first-displayed-block").getValue();
    if (block > last) fillMUD(first + block - last);
    if (block < first) fillMUD(block);
    
    foreach (var c; mud.getChildren("sel-line")) c.setBoolValue(0);
    
    var begin = 0;
    for (var i = mud.getNode("first-displayed-block").getValue(); i < block; i += 1) begin += size(MUD_content[i][0]);
    var end = begin + size(MUD_content[block][0]);
    for (var i = begin; i < end; i += 1) mud.getNode("sel-line[" ~ i ~ "]").setBoolValue(1);
    mud.getNode("selected-block").setIntValue(block);
}

var selectMUDblock = func (dir) {
    highlightSelectedMUDblock(mud.getNode("selected-block").getValue() + dir);
}

var applyMUDcallback = func {
    MUD_content[mud.getNode("selected-block").getValue()][1]();
}

