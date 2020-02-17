if [[ -z $1 ]]; then
    echo "Commit range cannot be empty"
    exit 1
fi

if [[ -z $2 ]]; then
    echo "Updated folder name cannot be empty"
    exit 1
fi

echo "Before Git diff command"

git diff --name-only $1 | sort -u | uniq | grep $2 > /dev/null

echo "After Git diff command"

