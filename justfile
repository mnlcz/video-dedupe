test:
    c3c test debug

rrelease:
    c3c run release

rdebug:
    c3c run debug

[default]
bdebug:
    c3c build debug

brelease:
    c3c build release

alias r := brelease
alias d := bdebug
