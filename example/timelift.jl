struct Squares
end
Base.iterate(S::Squares, state=1) = (state*state, state+1)

using DynamicIterators
# Assign iterate number as key
T = TimeLift(Squares())
# Create NextKey control slot
C = attach(NextKeys, T)
# Bind iterator 4:2:8 to the control slot and collect
collect(bind(4:2:8, C))
