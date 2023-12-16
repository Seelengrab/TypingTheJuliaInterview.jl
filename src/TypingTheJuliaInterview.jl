baremodule TypingTheJuliaInterview

export S,Z,True,False,Cons,Nil,Queen

import Base: only, return_types
onlyret(f, args) = only(return_types(f, args))

const nil = Union{}

struct Nil end
struct Cons{X, Xs} end

const T{S} = Type{S}

struct First{T}
    First{Nil}() = Nil
    First{Cons{X,More}}() where {X,More} = X
end

struct ListConcat{A,As}
    ListConcat{Nil, X}() where X = X
    ListConcat{Cons{a,as}, bs}() where {a,as,bs} = Cons{a, ListConcat{as, bs}()}
end

struct ListConcatAll{T}
    ListConcatAll{Nil}() = Nil
    function ListConcatAll{Cons{chunk, rest}}() where {chunk,rest}
        acc = ListConcatAll{rest}()
        ListConcat{chunk, acc}()
    end
end

struct True end
struct False end

struct Not{T}
    Not{False}() = True
    Not{True}() = False
end

struct Or{a,b}
    Or{True,  True}()  = True
    Or{True,  False}() = True
    Or{False, True}()  = True
    Or{False, False}() = False
end

struct AnyTrue{T}
    AnyTrue{Nil}() = False
    AnyTrue{Cons{True, more}}() where more = True
    AnyTrue{Cons{False, list}}() where {list} = AnyTrue{list}()
end

struct Z end
struct S{n} end

const N0 = Z
const N1 = S{N0}
const N2 = S{N1}
const N3 = S{N2}
const N4 = S{N3}
const N5 = S{N4}
const N6 = S{N5}
const N7 = S{N6}
const N8 = S{N7}

export N0,N1,N2,N3,N4,N5,N6,N7,N8

struct PeanoEqual{a,b}
    PeanoEqual{Z,Z}() = True
    PeanoEqual{s,Z}() where {s <: S} = False
    PeanoEqual{Z,s}() where {s <: S} = False
    PeanoEqual{S{a},S{b}}() where {a,b} = PeanoEqual{a,b}()
end

struct PeanoLT{a,b}
    PeanoLT{Z,Z}() = False
    PeanoLT{s,Z}() where {s <: S} = False
    PeanoLT{Z,s}() where {s <: S} = True
    PeanoLT{S{a},S{b}}() where {a,b} = PeanoLT{a,b}()
end

struct PeanoAbsDiff{a,b}
    PeanoAbsDiff{Z,Z}() = Z
    PeanoAbsDiff{Z,b}() where {b <: S} = b
    PeanoAbsDiff{a,Z}() where {a <: S} = a
    PeanoAbsDiff{S{a},S{b}}() where {a,b} = PeanoAbsDiff{a,b}()
end

struct Range{n}
    Range{Z}() = Nil
    Range{S{N}}() where N = Cons{N, Range{N}()}
end

struct LegalCompare
    LegalCompare() = PeanoEqual{N1,N1}()
end

struct IllegalCompare
    IllegalCompare() = PeanoEqual{True,Cons{Z,False}}()
end

struct Apply{f, a} end

struct Conj1{list}
    Apply{Conj1{list}, x}() where {list, x} = Cons{x, list}
end

struct Map{f, xs}
    Map{f, Nil}() where f = Nil
    function Map{f, Cons{x,xs}}() where {f,x,xs}
        y = Apply{f, x}()
        ys = Map{f,xs}()
        Cons{y, ys}
    end
end

struct MapCat{f,xs}
    MapCat{f,Nil}() where f = Nil
    function MapCat{f,xs}() where {f,xs}
        chunks = Map{f,xs}()
        ListConcatAll{chunks}()
    end
end

struct AppendIf{pred, x, ys}
    AppendIf{True, x, ys}() where {x,ys} = Cons{x, ys}
    AppendIf{False, x, ys}() where {x,ys} = ys
end

struct Filter{f,xs}
    Filter{f, Nil}() where f = Nil
    function Filter{f,Cons{x,xs}}() where {f,x,xs}
        t = Apply{f,x}()
        ys = Filter{f,xs}()
        AppendIf{t, x, ys}()
    end
end

struct Queen{x,y} end

struct Queen1{x}
    Apply{Queen1{x}, y}() where {y, x} = Queen{x, y}
end

struct QueensInRow{n,x}
    function QueensInRow{n,x}() where {n,x}
        ys = Range{n}()
        Map{Queen1{x}, ys}()
    end
end

struct Threatens{a,b}
    function Threatens{Queen{ax,ay},Queen{bx,by}}() where {ax,ay,bx,by}
        xeq = PeanoEqual{ax,bx}()
        yeq = PeanoEqual{ay,by}()
        xyeq = Or{xeq,yeq}()
        dx = PeanoAbsDiff{ax,bx}()
        dy = PeanoAbsDiff{ay,by}()
        deq = PeanoEqual{dx,dy}()
        Or{xyeq,deq}()
    end
end

struct Threatens1{a}
    Apply{Threatens1{a}, b}() where {a,b} = Threatens{a,b}()
end

struct Safe{config, queen}
    function Safe{config, queen}() where {config, queen}
        m1 = Map{Threatens1{queen}, config}()
        t1 = AnyTrue{m1}()
        Not{t1}()
    end
end

struct Safe1{c}
    Apply{Safe1{config}, queen}() where {config, queen} = Safe{config, queen}()
end

struct AddQueen{n,x,c}
    function AddQueen{n,x,c}() where {n,x,c}
        candidates = QueensInRow{n,x}()
        filtered = Filter{Safe1{c}, candidates}()
        Map{Conj1{c}, filtered}()
    end
end

struct AddQueen2{n,x}
    Apply{AddQueen2{n,x}, queen}() where {n,x,queen} = AddQueen{n, x, queen}()
end

struct AddQueenToAll{n,x,cs}
    function AddQueenToAll{n,x,cs}() where {n,x,cs}
        _cs = AddQueen2{n,x}
        MapCat{_cs,cs}()
    end
end

struct AddQueensIf{pred,n,x,cs}
    AddQueensIf{False,n,x,cs}() where {n,x,cs} = cs
    function AddQueensIf{True,n,x,cs}() where {n,x,cs} 
        cs2 = AddQueenToAll{n,x,cs}()
        AddQueens{n, S{x}, cs2}()
    end
end

struct AddQueens{n,x,cs}
    function AddQueens{n,x,cs}() where {n,x,cs}
        pred = PeanoLT{x,n}()
        AddQueensIf{pred,n,x,cs}()
    end
end

struct Solution{n}
    Solution{n}() where {n} = First{AddQueens{n,Z,Cons{Nil,Nil}}()}()
end

import Base: println
main() = println(Solution{N6}())

end # module JuliaInterview
