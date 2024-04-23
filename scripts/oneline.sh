oneline() {
    # Print a command's output as a single line only.
    # Example usage: for f in 'first line' 'second line' '3rd line'; do echo "$f"; sleep 1; done | oneline
    local ws
    while IFS= read -r line; do
        if ((${#line} >= $COLUMNS)); then
            # Moving cursor back to the front of the line so user input doesn't force wrapping
            printf '\r%s\r' "${line:0:$COLUMNS}"
        else
            ws=$(($COLUMNS - ${#line}))
            # by writing each line twice, we move the cursor back to position
            # thus: LF, content, whitespace, LF, content
            printf '\r%s%*s\r%s' "$line" "$ws" " " "$line"
        fi
    done
    echo
}
