test:
    c3c test debug

rrelease PATH:
    c3c run release -- "{{PATH}}"

rdebug PATH:
    c3c run debug -- "{{PATH}}"

[default]
bdebug:
    c3c build debug

brelease:
    c3c build release

alias br := brelease
alias r := rdebug
