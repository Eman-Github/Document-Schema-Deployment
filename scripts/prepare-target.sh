if [[ -z $1 ]]; then
    echo "Commit range cannot be empty"
    exit 1
fi

echo "Before Git diff command"
git diff --name-only $1 | sort -u | uniq | grep $DEV_TEST_TARGET > /dev/null
echo "Before Git diff command"

