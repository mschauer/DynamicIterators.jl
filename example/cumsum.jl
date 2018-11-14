using DynamicIterators
import DynamicIterators: dyniterate

struct Summed <: DynamicIterator
end

function dyniterate(::Summed, ::Nothing, y)
    y, y
end

function dyniterate(::Summed, i, y)
    i + y, i + y
end

@show collect(bind(1:5, Summed()))
