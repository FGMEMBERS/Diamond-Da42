var mudClass = {
    new: func (node, lines=10) {
        var m = { parents: [ mudClass ] };
        m.node = node.getNode("mud", 1);
        m.content = [];
        m.node.getNode("displayed", 1).setBoolValue(0);
        m.node.getNode("title", 1).setValue("");
        m.node.getNode("selected-block", 1).setIntValue(0);
        m.node.getNode("first-displayed-block", 1).setIntValue(0);
        m.node.getNode("last-displayed-block", 1).setIntValue(0);
        m.lines = lines;
        for (var i = 0; i < me.lines; i += 1) {
            m.node.getNode("line[" ~ i ~ "]", 1).setValue("");
            m.node.getNode("sel-line[" ~ i ~ "]", 1).setBoolValue(0);
        }
        return m;
    },

    lines: 10,

    wipe: func {
        me.content = [];
        me.filled_index = 0;
        foreach (var p; me.node.getChildren("line")) {
            p.setValue('');
        }
        me.node.getNode("title").setValue('');
    },

	getTitle: func () {
        return me.node.getNode("title").getValue();
    },
	
	setTitle: func (t) {
        me.node.getNode("title").setValue(t);
    },

	#34 caracteres max
    add: func (content, callback = void) {
        append(me.content, [content, callback]);
    },

    open: func (callback = void) {
        me.fill();
        me.node.getNode("displayed").setBoolValue(1);
        me.node.getNode("selected-block").setIntValue(0);
    },

    close: func (callback = void) {
        me.node.getNode("displayed").setBoolValue(0);
        me.node.getNode("selected-block").setIntValue(0);
        me.wipe();
    },

    fill: func (starting_block = 0) {
        var f = 0;
        var b = 0;
        for (b = starting_block; b < size(me.content); b += 1) {
            var s = size(me.content[b][0]);
            f + s <= me.lines or break;
            for (var i = 0; i < s; i += 1) {
                var c = f + i;
                me.node.getNode("line[" ~ c ~ "]").setValue(me.content[b][0][i]);
            }
            f += s;
        }
		for(var i=f;i<10;i=i+1){
			me.node.getNode("line[" ~ i ~ "]").setValue("");
		}
        me.node.getNode("first-displayed-block").setIntValue(starting_block);
        me.node.getNode("last-displayed-block").setIntValue(b - 1);
    },

    highlight: func (block = 0) {
        block < size(me.content) or return;
        block >= 0 or return;

        var last = me.node.getNode("last-displayed-block").getValue();
        var first = me.node.getNode("first-displayed-block").getValue();
        if (block > last) me.fill(first + block - last);
        if (block < first) me.fill(block);

        foreach (var c; me.node.getChildren("sel-line")) c.setBoolValue(0);

        var begin = 0;
        for (var i = me.node.getNode("first-displayed-block").getValue(); i < block; i += 1) begin += size(me.content[i][0]);
        var end = begin + size(me.content[block][0]);
        for (var i = begin; i < end; i += 1) me.node.getNode("sel-line[" ~ i ~ "]").setBoolValue(1);
        me.node.getNode("selected-block").setIntValue(block);
    },

    select: func (mud, dir) {
        mud.highlight(mud.node.getNode("selected-block").getValue() + dir);
    },

    apply: func {
		#print("apply=",me.node.getNode("selected-block").getValue()][1]);
        me.content[me.node.getNode("selected-block").getValue()][1]();
    },
	
	getSelectedBlock: func {
		return me.node.getNode("selected-block").getValue();
	},
	
	getSelectedBlockContent: func {
		return me.content[me.node.getNode("selected-block").getValue()][0];
	},
	
};
