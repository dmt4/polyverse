
function dnlifnh {
    [ -z "$2" ] && a=${1##*/} || a=$2
    [ -f "$a" ] || wget "$1" -O "$a"
}
