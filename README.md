# Hello Dependencies

This is a small project being used to develop some cargo2nix features and
demonstrate cargo2nix in a non-self-hosting context.

You can test the build using either the `nix-shell` or `nix-build` workflows.
Note that the `nix-build` is defaulted to using the musl libc and produces a
binary that's distinct from the vanilla build with cargo.  See the musl default
in `default.nix` and how `nix-shell` will default to `crossSystem = null` for
more to think about.

```shell
$ nix-build -A package.bin
/nix/store/jqnxvhadmqxixjn5azss5l8rz23bgcbq-crate-hello-deps-0.1.0-x86_64-unknown-linux-musl-bin

$ ./result/bin/hello-deps 
char: 󵩾

$ file result/bin/hello-deps 
result/bin/hello-deps: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /nix/store/97x80nw1a5xr5a2vyg6n5yygwan5ndpy-musl-1.1.24-x86_64-unknown-linux-musl/lib/ld-musl-x86_64.so.1, not stripped

$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/hello-deps`
char: 򶺳

$ file target/debug/hello-deps
target/debug/hello-deps: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /nix/store/wx1vk75bpdr65g6xwxbj4rw0pk04v5j3-glibc-2.27/lib/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, with debug_info, not stripped
```
