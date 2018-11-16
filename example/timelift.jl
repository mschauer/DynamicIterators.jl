using DynamicIterators

struct Squares
end

U = TimeLift(Squares())
Base.iterate(S::Squares, state=1) = (state*state, state+1)


collect(from(bind(4:2:8, U), NextKeys(nothing)))
