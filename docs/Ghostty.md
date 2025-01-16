# Ghostty

[Documentation](https://ghostty.org/docs)

## Tips

### Export Ghostty's terminfo to a remote server

Ghostty's terminfo is not yet available in most Linux distributions, so use the following command to add it.

```
infocmp -x | ssh remote_server -- tic -x -
```

The tic command on the server may give the warning `"<stdin>", line 2, col 31, terminal 'xterm-ghostty': older tic versions may treat the description field as an alias`, this can be safely ignored.
