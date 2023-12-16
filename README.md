# TypingTheJuliaInterview.jl

A humorous port of [Typing the technical interview](https://aphyr.com/posts/342-typing-the-technical-interview) by Kyle Kingsbury, a.k.a "Aphyr".

This is in principle a fully functional solver for the N-Queens problem and does everything* through types & type parameters.

The problems are solved correctly:

```julia-repl

julia> using TypingTheJuliaInterview
┌ Info: Precompiling TypingTheJuliaInterview [4eb64776-e9a6-423b-90eb-541048eb2028]
└ @ Base loading.jl:2486


julia> const TTJI = TypingTheJuliaInterview
TypingTheJuliaInterview

julia> TTJI.main()
Cons{Queen{N5, N1}, Cons{Queen{N4, N3}, Cons{Queen{N3, N5}, Cons{Queen{N2, Z}, Cons{Queen{N1, N2}, Cons{Queen{Z, N4}, Nil}}}}}}```

but, unfortunately, the compiler gives up when inferring that result due to some recursion heuristics:

```julia-repl
julia> TTJI.onlyret(TTJI.Solution{N6}, ())
Any
```

Also, this solver is not at all performant, and more a toy to show what you can do with the type system. 

```julia-repl
julia> @time TTJI.Solution{N8}()
 19.508032 seconds (27.11 M allocations: 1.182 GiB, 1.98% gc time, 99.99% compilation time)
Cons{Queen{N7, N4}, Cons{Queen{N6, N6}, Cons{Queen{N5, N1}, Cons{Queen{N4, N5}, Cons{Queen{N3, N2}, Cons{Queen{N2, Z}, Cons{Queen{N1, N3}, Cons{Queen{Z, N7}, Nil}}}}}}}}
```

So please don't try to actually use this anywhere :)

---

*everything is always passed through type parameters and the program is (in principle) type ground. The caveat is that there has to be some
form of evaluation step at some point to make the types collapse/infer down to the result, which is where the recursion heuristics makes inference
give up. Maybe that'll be improved in a future version of the compiler though.
