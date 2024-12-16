# Comparison AB test on Julia

```
julia main.jl
```

# Set up Package

Reference: [Pkg · The Julia Language](https://docs.julialang.org/en/v1/stdlib/Pkg/)

```
julia

# Push `]` to install package

add HypothesisTests Turing Distributions CSV DataFrames MCMCChains

# Push `backspace` to exit package mode

exit()
```

# Set up Julia

Check your Platform

```
uname -m
```

And then download the corresponding version of Julia from [Download Julia](https://julialang.org/downloads/) (since I use Ubuntu, I can use glibc version in my case)

Check sha256sum
```
sha256sum julia-1.11.2-linux-x86_64.tar.gz
```

Extract the tarball
```
tar -xvzf julia-1.11.2-linux-x86_64.tar.gz
```

Move the extracted folder to opt
```
sudo mv julia-1.11.2 /opt/
```

Create a symbolic link
```
sudo ln -s /opt/julia-1.11.2/bin/julia /usr/local/bin/julia
```

Check the installation
```
julia --version
```
