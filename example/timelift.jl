using Revise
using DynamicIterators
import DynamicIterators: dyniterate, State

struct Squares <: DynamicIterator
end

U = TimeLift(Squares())
dyniterate(S::Squares, (state,)::State) = (state*state, State(state+1))
dyniterate(S::Squares, ::Nothing) = (1, State(2))

collect(from(bind(4:2:8, U), NextKeys(State(1))))
